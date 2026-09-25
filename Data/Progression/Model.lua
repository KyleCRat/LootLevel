local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Progression = {}
NS.Progression = Progression

local seasons = {}
local seasonKeys = {}
local builtSets = {}

Progression.trackOrder = { "adventurer", "veteran", "champion", "hero", "myth" }
Progression.tracks = {
    untracked = { name = "Untracked", bg = "muted" },
    adventurer = { name = "Adventurer", bg = "pink", crest = "A" },
    veteran = { name = "Veteran", bg = "blue", crest = "V" },
    champion = { name = "Champion", bg = "yellow", crest = "C" },
    hero = { name = "Hero", bg = "red", crest = "H" },
    myth = { name = "Myth", bg = "purple", crest = "M" },
}

function Progression.Track(key)
    return assert(Progression.tracks[key], "LootLevel progression: unknown track " .. tostring(key))
end

-- Season files contain facts only. Build resolves their shared item-level axis once.
function Progression.Season(definition)
    assert(not seasonKeys[definition.key], "LootLevel progression: duplicate season " .. definition.key)
    seasonKeys[definition.key] = true
    seasons[#seasons + 1] = definition
end

function Progression.Rank(context, reward)
    if reward.track == "untracked" then return "-" end

    local track = assert(context.season.tracks[reward.track], "LootLevel progression: missing season track " .. tostring(reward.track))
    local rank = reward.rank
    if not rank then
        for index, ilvl in ipairs(track.levels) do
            if ilvl == reward.ilvl then
                rank = index
                break
            end
        end
        for _, extra in ipairs(track.extraRanks or {}) do
            if extra.ilvl == reward.ilvl then
                rank = extra.rank
                break
            end
        end
    end

    assert(rank, ("LootLevel progression: %s has no %s rank for ilvl %s"):format(context.season.key, reward.track, tostring(reward.ilvl)))
    return ("%d/%d"):format(rank, #track.levels)
end

function Progression.Add(context, role, group, bg, cell, bold)
    local key = role .. "." .. group
    local block = context.byGroup[key]
    if not block then
        block = {
            id = context.season.key .. "." .. key,
            table = assert(context.tables[role], "LootLevel progression: unknown table " .. role),
            layer = context.season.key,
            bg = bg,
            border = "solid1",
            bold = bold,
            cells = {},
        }
        if role == "raid" then
            block.innerBorder = "dashed"
        else
            block.innerRowBorder = "dashed"
            if role == "activity" then
                block.innerColBorder = "solid1"
            end
        end
        context.byGroup[key] = block
        context.blocks[#context.blocks + 1] = block
    end

    block.cells[#block.cells + 1] = cell
end

local function BuildItemLevelRows(contexts, axis)
    local levels = {}
    local seen = {}
    local function Include(ilvl)
        if ilvl == nil then return end
        assert(type(ilvl) == "number" and ilvl > 0 and ilvl == math.floor(ilvl), "LootLevel progression: item levels must be positive integers")
        if not seen[ilvl] then
            seen[ilvl] = true
            levels[#levels + 1] = ilvl
        end
    end

    for _, context in ipairs(contexts) do
        for _, block in ipairs(context.blocks) do
            for _, cell in ipairs(block.cells) do
                Include(cell.ilvl)
                Include(cell.toIlvl)
            end
        end
    end
    table.sort(levels)

    -- Preserve empty steps, but let declared values own their nearest step.
    -- Off-sequence rewards must not gain a second, estimated row beside them.
    if axis and #levels > 0 then
        assert(axis.step > 0, "LootLevel progression: item-level step must be positive")
        local occupiedSteps = {}
        for _, ilvl in ipairs(levels) do
            local step = math.floor((ilvl - axis.base) / axis.step + 0.5)
            occupiedSteps[step] = true
        end
        local first, last = levels[1], levels[#levels]
        local firstStep = math.floor((first - axis.base) / axis.step)
        local lastStep = math.ceil((last - axis.base) / axis.step)
        for step = firstStep, lastStep do
            local ilvl = axis.base + math.ceil(step * axis.step)
            if not occupiedSteps[step] and ilvl >= first and ilvl <= last then
                Include(ilvl)
            end
        end
        table.sort(levels)
    end

    local rows = {}
    for index, ilvl in ipairs(levels) do
        rows[ilvl] = index + 1
    end
    return levels, rows
end

local function ResolveCells(context, rows)
    local occupied = {}
    for _, block in ipairs(context.blocks) do
        occupied[block.table] = occupied[block.table] or {}
        for _, cell in ipairs(block.cells) do
            if cell.ilvl then
                cell.row = rows[cell.ilvl]
                cell.ilvl = nil
            end
            if cell.toIlvl then
                cell.toRow = rows[cell.toIlvl]
                cell.toIlvl = nil
            end

            local span = NS.Coordinates.NormalizeCellRange(cell.col .. cell.row, (cell.toCol or cell.col) .. (cell.toRow or cell.row))
            for _, coord in ipairs(span.coordinates) do
                assert(not occupied[block.table][coord], ("LootLevel progression: overlapping %s cell %s in %s"):format(block.table, coord, context.season.key))
                occupied[block.table][coord] = true
            end

            if cell.toRow or cell.toCol then
                Data.MergedCell(cell)
            else
                Data.Cell(cell)
            end
        end
    end
end

local function RegisterAxis(tableKey, col, levels)
    local cells = {}
    for index, ilvl in ipairs(levels) do
        cells[#cells + 1] = Data.Cell({ col = col, row = index + 1, text = tostring(ilvl) })
    end
    Data.Block({
        id = tableKey .. ".itemLevels",
        table = tableKey,
        bg = "light",
        border = "solid1",
        innerBorder = "dashed",
        bold = true,
        cells = cells,
    })
end

function Progression.Build(layerSetKey, axis)
    if builtSets[layerSetKey] then return end

    local layerSet = NS.Data.layerSets[layerSetKey]
    local tables = NS.Data.layouts[layerSet.layout].tables
    local contexts = {}
    for _, season in ipairs(seasons) do
        if season.layerSet == layerSetKey then
            local context = { season = season, tables = tables, blocks = {}, byGroup = {} }
            Progression.BuildRaid(context)
            Progression.BuildActivities(context)
            contexts[#contexts + 1] = context
        end
    end

    local levels, rows = BuildItemLevelRows(contexts, axis)
    for _, context in ipairs(contexts) do
        ResolveCells(context, rows)
        assert(rows[context.season.scrollTo], "LootLevel progression: scrollTo must be a displayed item level")
    end

    RegisterAxis(tables.raid, "a", levels)
    RegisterAxis(tables.activity, "g", levels)
    local scrollGroup = NS.Data.tables[tables.raid].bodyScrollGroup
    for _, context in ipairs(contexts) do
        local season = context.season
        Data.Layer({
            key = season.key,
            layerSet = season.layerSet,
            name = season.name,
            buttonText = season.buttonText,
            buttonWidth = season.buttonWidth,
            order = season.order,
            inactiveAlpha = season.inactiveAlpha,
            bodyScroll = { [scrollGroup] = { row = rows[season.scrollTo] } },
            footer = season.footer,
        })
        for _, block in ipairs(context.blocks) do
            Data.Block(block)
        end
    end
    builtSets[layerSetKey] = true
end
