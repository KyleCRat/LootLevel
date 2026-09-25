local ADDON_NAME, NS = ...

local Scanner = NS.BonusScanner
local Collector = {}
NS.UI.Collector = Collector

local function Label(parent, text, x, y, width)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", x, y)
    label:SetSize(width, 20)
    label:SetJustifyH("LEFT")
    label:SetText(text)
    return label
end

local function Button(parent, text, width, callback)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 26)
    button:SetText(text)
    button:SetScript("OnClick", callback)
    return button
end

local function Tooltip(owner, title, text)
    owner:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title)
        GameTooltip:AddLine(text, 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    owner:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function Input(parent, width, numeric)
    local input = CreateFrame("EditBox", nil, parent, "SharedEditBoxTemplate")
    input:SetSize(width, 30)
    input:OnLoad()
    input:SetAutoFocus(false)
    input:SetFontObject(GameFontHighlight)
    input:SetNumeric(numeric == true)
    input:SetMaxLetters(numeric and 10 or 4096)
    input:SetScript("OnEscapePressed", EditBox_ClearFocus)
    input:SetScript("OnEnterPressed", EditBox_ClearFocus)
    return input
end

local function SetInput(input, value)
    input:SetText(tostring(value))
    input:SetCursorPosition(0)
end

local function Window(name, title)
    local frame = CreateFrame("Frame", name, UIParent, "DefaultPanelTemplate")
    frame:SetSize(880, 600)
    frame:SetPoint("CENTER")
    frame:SetTitle(title)
    frame.TopTileStreaks:Hide()
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnShow", function(self)
        self:SetScale(math.min(1, (UIParent:GetWidth() - 40) / 880, (UIParent:GetHeight() - 40) / 600))
    end)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -1, 0)
    close:SetFrameLevel(frame.TitleContainer:GetFrameLevel() + 1)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame:Hide()
    table.insert(UISpecialFrames, name)
    return frame
end

local function BatchLabel(batch)
    return ("%d-%d (%s)"):format(batch.firstID, batch.lastID, batch.state)
end

function Collector:ShowError(message)
    self.frame.notice:SetText(message or "")
    self.frame.notice:SetTextColor(1, 0.35, 0.3)
end

function Collector:FillInputs(batch)
    local settings = Scanner.db.settings
    SetInput(self.frame.seed, batch and batch.seed or settings.seed)
    SetInput(self.frame.first, batch and batch.firstID or settings.startID)
    SetInput(self.frame.count, batch and (batch.lastID - batch.firstID + 1) or settings.count)
end

function Collector:Run(nextBatch)
    local frame = self.frame
    if nextBatch then
        local previous = Scanner:GetSelected()
        if not previous or previous.state ~= "complete" then
            return
        end
        SetInput(frame.seed, previous.seed)
        SetInput(frame.first, previous.lastID + 1)
        SetInput(frame.count, previous.lastID - previous.firstID + 1)
    end
    frame.seed:ClearFocus()
    frame.first:ClearFocus()
    frame.count:ClearFocus()
    local batch, err = Scanner:Start(frame.seed:GetText(), frame.first:GetText(), frame.count:GetText())
    if not batch then
        self:ShowError(err)
    end
end

function Collector:PauseOrResume()
    if Scanner:IsBusy() then
        Scanner:Pause("Paused by user")
    else
        local batch, err = Scanner:Resume(Scanner:GetSelected())
        if not batch then
            self:ShowError(err)
        end
    end
end

function Collector:ShowExport()
    local batch = Scanner:GetSelected()
    if not batch or Scanner:IsBusy() then
        return
    end
    local frame = self.exportFrame
    if not frame then
        frame = Window("LootLevelCollectorExportFrame", "LootLevel - Export")
        self.exportFrame = frame
        local editor = CreateFrame("Frame", nil, frame, "ScrollingEditBoxTemplate")
        editor:SetPoint("TOPLEFT", 20, -42)
        editor:SetPoint("BOTTOMRIGHT", -42, 54)
        editor:SetFontObject("GameFontHighlightSmall")
        local editBox = editor:GetEditBox()
        editBox:SetMaxLetters(0)
        editBox:SetMaxBytes(0)
        editBox:SetAutoFocus(false)
        editBox:HookScript("OnTextChanged", function(_, userInput)
            if userInput and editor:GetText() ~= frame.exportText then
                editor:SetText(frame.exportText)
                editor:SetCursorPosition(0)
            end
        end)
        frame.editor = editor

        local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
        scrollBar:SetPoint("TOPLEFT", editor, "TOPRIGHT", 8, -4)
        scrollBar:SetPoint("BOTTOMLEFT", editor, "BOTTOMRIGHT", 8, 4)
        ScrollUtil.InitScrollBar(editor:GetScrollBox(), scrollBar)

        local selectAll = Button(frame, "Select All", 120, function()
            editor:SetFocus()
            editBox:HighlightText()
        end)
        selectAll:SetPoint("BOTTOMRIGHT", -20, 16)
        Tooltip(selectAll, "Copy Results", "Select all exported text, then press Ctrl+C.")
        frame.summary = Label(frame, "", 20, -560, 650)
        frame:SetScript("OnHide", function()
            editor:ClearFocus()
        end)
    end

    frame:SetTitle("LootLevel - Export " .. BatchLabel(batch))
    frame.exportText = Scanner:Export(batch)
    frame.summary:SetText(("%d rows | %d bytes | %s"):format(#batch.rows, #frame.exportText, batch.state))
    frame:Show()
    frame:Raise()
    frame.editor:SetText(frame.exportText)
    frame.editor:SetCursorPosition(0)
    frame.editor:SetFocus()
    frame.editor:GetEditBox():HighlightText()
end

function Collector:Refresh(reason)
    local frame = self.frame
    if not frame or not frame:IsShown() then
        return
    end
    local batch = Scanner:GetSelected()
    local busy = Scanner:IsBusy()
    local locked = NS:IsCombatLocked()
    frame.seed:SetEnabled(not busy)
    frame.first:SetEnabled(not busy)
    frame.count:SetEnabled(not busy)
    frame.run:SetEnabled(not busy and not locked)
    frame.pause:SetText(busy and "Pause" or "Resume")
    frame.pause:SetEnabled(busy or (batch and batch.state == "paused" and not locked) or false)
    frame.next:SetEnabled(not busy and not locked and batch ~= nil and batch.state == "complete" and batch.lastID < Scanner.maxBonusID)
    frame.export:SetEnabled(not busy and batch ~= nil and #batch.rows > 0)
    frame.delete:SetEnabled(not busy and batch ~= nil)
    frame.history:SetEnabled(not busy)
    frame.notice:SetTextColor(0.85, 0.85, 0.85)
    frame.notice:SetText(locked and "Paused for combat" or (batch and batch.message) or "Ready")

    if reason ~= "progress" then
        frame.history:GenerateMenu()
    end
    if reason == "selection" then
        self:FillInputs(batch)
    end

    local total = batch and (batch.lastID - batch.firstID + 1) or 1
    local count = batch and #batch.rows or 0
    frame.progress:SetMinMaxValues(0, total)
    frame.progress:SetValue(count)
    frame.progressText:SetText(batch and ("%d / %d | Next ID: %d"):format(count, total, batch.nextID) or "No batch")
    frame.stats:SetText(batch and ("Ranked tracks: %d    Above cap: %d    Missing data: %d    Errors: %d"):format(
        batch.withTrack, batch.aboveCap, batch.missing, batch.errors
    ) or "")
    frame.metadata:SetText(batch and ("%s.%s | %s | Item %d | %s"):format(
        batch.version, batch.build, batch.locale, batch.itemID, batch.source
    ) or "")

    if frame.displayedBatch ~= batch then
        frame.log:Clear()
        frame.displayedBatch = batch
        frame.displayedCount = math.max(0, count - 100)
    end
    if batch then
        for index = frame.displayedCount + 1, count do
            frame.log:AddMessage((batch.rows[index]:gsub("\t", " | ")), 0.9, 0.9, 0.9)
        end
    end
    frame.displayedCount = count
end

function Collector:Create()
    local frame = Window("LootLevelCollectorFrame", "LootLevel - Bonus Collector")
    self.frame = frame

    Label(frame, "Seed Link", 20, -38, 820)
    frame.seed = Input(frame, 836, false)
    frame.seed:SetPoint("TOPLEFT", 20, -58)
    Tooltip(frame.seed, "Seed Link", "An item hyperlink or raw item: string. Each probe replaces its entire bonus list with one ID; all other fields are retained.")

    Label(frame, "Start ID", 20, -104, 110)
    frame.first = Input(frame, 118, true)
    frame.first:SetPoint("TOPLEFT", 20, -124)
    Label(frame, "Batch Size", 156, -104, 110)
    frame.count = Input(frame, 104, true)
    frame.count:SetPoint("TOPLEFT", 156, -124)
    Tooltip(frame.count, "Batch Size", ("From 1 to %d consecutive IDs. Each batch stops at its end."):format(Scanner.maxBatchSize))

    frame.run = Button(frame, "Run Batch", 120, function()
        self:Run(false)
    end)
    frame.run:SetPoint("TOPLEFT", 292, -126)
    frame.pause = Button(frame, "Resume", 120, function()
        self:PauseOrResume()
    end)
    frame.pause:SetPoint("LEFT", frame.run, "RIGHT", 12, 0)
    frame.next = Button(frame, "Next Batch", 130, function()
        self:Run(true)
    end)
    frame.next:SetPoint("LEFT", frame.pause, "RIGHT", 12, 0)

    Label(frame, "Saved Batches", 20, -177, 116)
    local history = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    history:SetPoint("TOPLEFT", 144, -173)
    history:SetWidth(400)
    history:SetDefaultText("No saved batches")
    history:SetupMenu(function(_, root)
        for index, batch in ipairs(Scanner.db.batches) do
            root:CreateRadio(("%d: %s"):format(index, BatchLabel(batch)), function(value)
                return Scanner.db.selected == value
            end, function(value)
                Scanner:Select(value)
            end, index)
        end
    end)
    frame.history = history

    frame.export = Button(frame, "Export", 120, function()
        self:ShowExport()
    end)
    frame.export:SetPoint("TOPLEFT", 572, -175)
    frame.delete = Button(frame, "Delete", 120, function()
        local batch = Scanner:GetSelected()
        if batch then
            StaticPopup_Show("LOOTLEVEL_DELETE_PROBE_BATCH", BatchLabel(batch), nil, batch)
        end
    end)
    frame.delete:SetPoint("LEFT", frame.export, "RIGHT", 12, 0)
    Tooltip(frame.delete, "Delete Batch", "Permanently delete the selected capture. Export it first. Up to 20 batches are retained; old results are never deleted automatically.")

    frame.notice = Label(frame, "Ready", 20, -216, 836)
    frame.progress = CreateFrame("StatusBar", nil, frame)
    frame.progress:SetPoint("TOPLEFT", 20, -244)
    frame.progress:SetSize(836, 18)
    frame.progress:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.progress:SetStatusBarColor(0.15, 0.7, 0.45)
    local background = frame.progress:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.04, 0.04, 0.04, 0.9)
    frame.progressText = frame.progress:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.progressText:SetAllPoints()
    frame.stats = Label(frame, "", 20, -272, 836)
    Label(frame, "Recent Results", 20, -308, 836)
    Label(frame, "Bonus | ilvl | Track | Rank | Max | Track ID | Status | Error", 20, -332, 836)

    frame.log = CreateFrame("ScrollingMessageFrame", nil, frame)
    frame.log:SetPoint("TOPLEFT", 20, -360)
    frame.log:SetPoint("BOTTOMRIGHT", -44, 52)
    frame.log:SetFontObject(GameFontHighlightSmall)
    frame.log:SetJustifyH("LEFT")
    frame.log:SetFading(false)
    frame.log:SetMaxLines(100)
    frame.log:SetInsertMode("BOTTOM")
    local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", frame.log, "TOPRIGHT", 8, -4)
    scrollBar:SetPoint("BOTTOMLEFT", frame.log, "BOTTOMRIGHT", 8, 4)
    ScrollUtil.InitScrollingMessageFrameWithScrollBar(frame.log, scrollBar)
    frame.metadata = Label(frame, "", 20, -566, 836)

    frame:HookScript("OnShow", function()
        self:FillInputs(Scanner:GetSelected())
        self:Refresh("show")
    end)
    frame:SetScript("OnHide", function()
        Scanner:Pause("Paused when collector closed")
        frame.seed:ClearFocus()
        frame.first:ClearFocus()
        frame.count:ClearFocus()
        if self.exportFrame then
            self.exportFrame:Hide()
        end
    end)
    Scanner.onChanged = function(reason)
        self:Refresh(reason)
    end
    return frame
end

StaticPopupDialogs["LOOTLEVEL_DELETE_PROBE_BATCH"] = {
    text = "Delete LootLevel capture %s? This cannot be undone.",
    button1 = DELETE,
    button2 = CANCEL,
    OnAccept = function(_, batch)
        local ok, err = Scanner:Delete(batch)
        if not ok and err then
            Collector:ShowError(err)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function NS:ShowCollector()
    if self:BlockCombatAction("Opening the collector") then
        return false
    end
    local frame = Collector.frame or Collector:Create()
    frame:Show()
    frame:Raise()
    return true
end
