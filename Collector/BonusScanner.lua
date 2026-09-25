local ADDON_NAME, NS = ...

local Scanner = {
    defaultSeed = "item:271092::::::::90:262::6:1:3524:1:28:7362:::::",
    defaultBatchSize = 5000,
    maxBatchSize = 50000,
    maxHistory = 20,
    maxBonusID = 2147483647,
    columns = "bonus_id\tilvl\ttrack\trank\tmax_rank\ttrack_id\tstatus\terror",
}
NS.BonusScanner = Scanner

local TICK_SECONDS = 0.05
local IDS_PER_TICK = 5
local TICK_BUDGET_MS = 3

local function Integer(value, minimum, maximum)
    value = tonumber(value)
    if value and value == math.floor(value) and value >= minimum and value <= maximum then
        return value
    end
end

local function Field(value)
    if value == nil then
        return ""
    end
    return (tostring(value):gsub("[\r\n\t]", " "))
end

local function ReadItem(link)
    local level = C_Item.GetDetailedItemLevelInfo(link)
    local upgrade = C_Item.GetItemUpgradeInfo(link)
    return level, upgrade
end

function Scanner:ParseSeed(text)
    text = strtrim(text or "")
    local raw = text:match("|H(item:[^|]+)|h") or text
    if #raw > 4096 or not raw:match("^item:[%d:%-]+$") then
        return nil, "Enter an item link or raw item: string."
    end

    local fields = { strsplit(":", raw) }
    local itemID = Integer(fields[2], 1, self.maxBonusID)
    if not itemID then
        return nil, "The seed must contain a positive item ID."
    end
    for index = #fields + 1, 14 do
        fields[index] = ""
    end
    local count = Integer(fields[14] == "" and 0 or fields[14], 0, #fields - 14)
    if not count then
        return nil, "The seed has an invalid bonus count."
    end

    -- Replace the entire bonus list, retaining the context and trailing modifiers.
    local suffix = ""
    if #fields > 14 + count then
        suffix = ":" .. table.concat(fields, ":", 15 + count)
    end
    return {
        raw = raw,
        itemID = itemID,
        prefix = table.concat(fields, ":", 1, 13) .. ":1:",
        suffix = suffix,
    }
end

function Scanner:Notify(reason)
    if self.onChanged then
        self.onChanged(reason)
    end
end

function Scanner:IsBusy()
    return self.active ~= nil
end

function Scanner:StopWork()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    if self.loadTimeout then
        self.loadTimeout:Cancel()
        self.loadTimeout = nil
    end
    self.eventFrame:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
end

function Scanner:Pause(reason)
    local batch = self.active
    if not batch then
        return
    end
    self:StopWork()
    batch.state = "paused"
    batch.message = reason or "Paused"
    self.active = nil
    self:Notify("state")
end

function Scanner:Complete()
    local batch = self.active
    self:StopWork()
    batch.state = "complete"
    batch.message = "Complete"
    batch.finishedAt = GetServerTime()
    self.db.settings.startID = math.min(batch.lastID + 1, self.maxBonusID)
    self.active = nil
    self:Notify("state")
end

function Scanner:CollectOne(batch)
    local bonusID = batch.nextID
    local link = batch.prefix .. bonusID .. batch.suffix
    local ok, level, upgrade = pcall(ReadItem, link)
    local row
    if not ok then
        row = table.concat({ bonusID, "", "", "", "", "", "error", Field(level):sub(1, 512) }, "\t")
        batch.errors = batch.errors + 1
    else
        local track = upgrade and upgrade.trackString
        local rank = upgrade and upgrade.currentLevel
        local cap = upgrade and upgrade.maxLevel
        row = table.concat({
            bonusID, Field(level), Field(track), Field(rank), Field(cap),
            Field(upgrade and upgrade.trackStringID), level and "ok" or "missing", "",
        }, "\t")
        if level == nil then
            batch.missing = batch.missing + 1
        end
        if track and rank and rank > 0 then
            batch.withTrack = batch.withTrack + 1
        end
        if rank and cap and cap > 0 and rank > cap then
            batch.aboveCap = batch.aboveCap + 1
        end
    end

    batch.rows[#batch.rows + 1] = row
    batch.nextID = bonusID + 1
end

function Scanner:Tick()
    local batch = self.active
    if not batch or batch.state ~= "running" then
        return
    end
    if NS:IsCombatLocked() then
        self:Pause("Paused for combat")
        return
    end
    if not C_Item.IsItemDataCachedByID(batch.itemID) then
        self:Pause("Item data left the cache; resume to reload it")
        return
    end

    local started = debugprofilestop()
    for index = 1, IDS_PER_TICK do
        self:CollectOne(batch)
        if batch.nextID > batch.lastID then
            self:Complete()
            return
        end
        if debugprofilestop() - started >= TICK_BUDGET_MS then
            break
        end
    end
    if GetTime() >= self.nextRefresh then
        self.nextRefresh = GetTime() + 0.25
        self:Notify("progress")
    end
end

function Scanner:BeginTicks()
    local batch = self.active
    if not batch then
        return
    end
    self:StopWork()
    if NS:IsCombatLocked() then
        self:Pause("Paused for combat")
        return
    end

    local ok, level, upgrade = pcall(ReadItem, batch.seed)
    if not ok or level == nil then
        self:Pause("Seed item data unavailable; resume to retry")
        return
    end
    if not batch.baseline then
        batch.baseline = table.concat({
            Field(level), Field(upgrade and upgrade.trackString),
            Field(upgrade and upgrade.currentLevel), Field(upgrade and upgrade.maxLevel),
            Field(upgrade and upgrade.trackStringID),
        }, "\t")
    end

    batch.state = "running"
    batch.message = "Running"
    self.nextRefresh = 0
    self.ticker = C_Timer.NewTicker(TICK_SECONDS, function()
        self:Tick()
    end)
    self:Notify("state")
end

function Scanner:LoadAndRun(batch)
    self.active = batch
    if C_Item.IsItemDataCachedByID(batch.itemID) then
        self:BeginTicks()
        return
    end

    batch.state = "loading"
    batch.message = "Loading seed item"
    self.eventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    self.loadTimeout = C_Timer.NewTimer(15, function()
        if self.active == batch and batch.state == "loading" then
            self:Pause("Item load timed out; resume to retry")
        end
    end)
    self:Notify("state")
    C_Item.RequestLoadItemDataByID(batch.itemID)
end

function Scanner:Start(seed, startID, count)
    if self:IsBusy() then
        return nil, "Pause the active batch first."
    end
    if NS:IsCombatLocked() then
        return nil, "Scanning is disabled during combat."
    end
    if #self.db.batches >= self.maxHistory then
        return nil, "History is full. Export and delete an old batch first."
    end

    startID = Integer(startID, 0, self.maxBonusID)
    count = Integer(count, 1, self.maxBatchSize)
    if not startID or not count or startID + count - 1 > self.maxBonusID then
        return nil, ("Enter a nonnegative start ID and a batch size from 1 to %d within the bonus ID range."):format(self.maxBatchSize)
    end
    local parsed, err = self:ParseSeed(seed)
    if not parsed then
        return nil, err
    end

    local version, build, buildDate, interface = GetBuildInfo()
    local batch = {
        source = "synthetic_single_bonus",
        seed = parsed.raw,
        itemID = parsed.itemID,
        prefix = parsed.prefix,
        suffix = parsed.suffix,
        firstID = startID,
        lastID = startID + count - 1,
        nextID = startID,
        version = version,
        build = build,
        buildDate = buildDate,
        interface = interface,
        locale = GetLocale(),
        project = WOW_PROJECT_ID,
        addonVersion = NS.version,
        startedAt = GetServerTime(),
        state = "paused",
        rows = {},
        errors = 0,
        missing = 0,
        withTrack = 0,
        aboveCap = 0,
    }
    self.db.settings = { seed = parsed.raw, startID = startID, count = count }
    self.db.batches[#self.db.batches + 1] = batch
    self.db.selected = #self.db.batches
    self:LoadAndRun(batch)
    return batch
end

function Scanner:Resume(batch)
    if self:IsBusy() then
        return nil, "Pause the active batch first."
    end
    if NS:IsCombatLocked() then
        return nil, "Scanning is disabled during combat."
    end
    if not batch or batch.state ~= "paused" or batch.nextID > batch.lastID then
        return nil, "Select an unfinished batch."
    end
    local version, build = GetBuildInfo()
    if version ~= batch.version or build ~= batch.build or GetLocale() ~= batch.locale or WOW_PROJECT_ID ~= batch.project then
        return nil, "This batch belongs to another build or locale. Export it and start a new batch."
    end
    self:LoadAndRun(batch)
    return batch
end

function Scanner:Delete(batch)
    if self:IsBusy() then
        return nil, "Pause the active batch first."
    end
    for index, saved in ipairs(self.db.batches) do
        if saved == batch then
            table.remove(self.db.batches, index)
            self.db.selected = math.min(index, #self.db.batches)
            self:Notify("selection")
            return true
        end
    end
end

function Scanner:GetSelected()
    return self.db.batches[self.db.selected]
end

function Scanner:Select(index)
    if self:IsBusy() then
        return
    end
    self.db.selected = index
    self:Notify("selection")
end

function Scanner:Export(batch)
    local lines = {
        "# LootLevel bonus probe\tformat=1",
        "# source\t" .. batch.source,
        "# build\t" .. Field(batch.version) .. "\t" .. Field(batch.build) .. "\t" .. Field(batch.buildDate),
        "# interface\t" .. Field(batch.interface) .. "\tproject\t" .. Field(batch.project),
        "# locale\t" .. batch.locale .. "\taddon\t" .. Field(batch.addonVersion),
        "# started_unix\t" .. batch.startedAt .. "\tfinished_unix\t" .. Field(batch.finishedAt),
        "# seed\t" .. batch.seed,
        "# probe_template\t" .. batch.prefix .. "{bonus_id}" .. batch.suffix,
        "# seed_baseline\t" .. (batch.baseline or "unavailable"),
        "# range\t" .. batch.firstID .. "\t" .. batch.lastID .. "\tnext_id\t" .. batch.nextID,
        "# state\t" .. batch.state .. "\trows\t" .. #batch.rows,
        "# errors\t" .. batch.errors .. "\tmissing\t" .. batch.missing,
        self.columns,
    }
    for _, row in ipairs(batch.rows) do
        lines[#lines + 1] = row
    end
    return table.concat(lines, "\n")
end

function Scanner:Initialize()
    LootLevelCollectorDB = LootLevelCollectorDB or {}
    local db = LootLevelCollectorDB
    db.schema = db.schema or 1
    db.batches = db.batches or {}
    db.settings = db.settings or { seed = self.defaultSeed, startID = 0, count = self.defaultBatchSize }
    db.selected = math.min(db.selected or #db.batches, #db.batches)
    self.db = db
    for _, batch in ipairs(db.batches) do
        if batch.state == "running" or batch.state == "loading" then
            batch.state = "paused"
            batch.message = "Paused after reload"
        end
    end

    local events = CreateFrame("Frame")
    self.eventFrame = events
    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("PLAYER_LOGOUT")
    events:SetScript("OnEvent", function(_, event, itemID, success)
        if event == "ITEM_DATA_LOAD_RESULT" then
            local batch = self.active
            if batch and batch.state == "loading" and batch.itemID == itemID then
                if success then
                    self:BeginTicks()
                else
                    self:Pause("Item load failed; resume to retry")
                end
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            self:Pause("Paused for combat")
            self:Notify("combat")
        elseif event == "PLAYER_REGEN_ENABLED" then
            self:Notify("combat")
        elseif event == "PLAYER_LOGOUT" then
            self:Pause("Paused after logout or reload")
        end
    end)
end
