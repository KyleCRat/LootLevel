local ADDON_NAME, NS = ...

local COLORS = {
    frame = { 0.11, 0.11, 0.11, 0.96 },
    panel = { 0.16, 0.16, 0.16, 0.98 },
    header = { 0.84, 0.84, 0.84, 1 },
    blank = { 0.39, 0.39, 0.38, 1 },
    light = { 0.86, 0.86, 0.86, 1 },
    pink = { 0.87, 0.76, 0.82, 1 },
    blue = { 0.58, 0.72, 0.84, 1 },
    yellow = { 0.96, 0.84, 0.54, 1 },
    red = { 0.88, 0.52, 0.52, 1 },
    purple = { 0.64, 0.57, 0.78, 1 },
    black = { 0, 0, 0, 1 },
    white = { 1, 1, 1, 1 },
    muted = { 0.72, 0.72, 0.72, 1 },
}

NS.Colors = COLORS

local levels = {
    240, 243, 246, 250, 253, 256, 259, 263, 266, 269, 272, 276, 279, 282, 285, 289,
    292, 295, 298, 302, 305, 308, 311, 315, 318, 321, 324, 328, 331, 334, 337,
}

local leftLayout = {
    worldRowCount = 19,
    delveRowCount = 11,
    delveStartRow = 24,
}

local blocks = {}
local cellsByTable = {
    main = {},
    left = {},
}
local colorBlocks = {}
local mergedCells = {}
local borderRules = {}

local function CopyTable(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

local function MergeTables(base, override)
    local merged = CopyTable(base)
    for key, value in pairs(override or {}) do
        merged[key] = value
    end
    return merged
end

local function RowForItemLevel(itemLevel)
    for index, candidate in ipairs(levels) do
        if candidate == itemLevel then
            return index + 1
        end
    end

    return nil
end

local function ColumnIndex(columnKey)
    columnKey = tostring(columnKey or ""):lower()
    local index = 0
    for position = 1, #columnKey do
        local byte = string.byte(columnKey, position)
        if byte < 97 or byte > 122 then
            return nil
        end
        index = (index * 26) + (byte - 96)
    end

    return index > 0 and index or nil
end

local function ColumnKeyFromIndex(index)
    index = tonumber(index)
    if not index or index < 1 then
        return nil
    end

    local columnKey = ""
    while index > 0 do
        local remainder = (index - 1) % 26
        columnKey = string.char(97 + remainder) .. columnKey
        index = math.floor((index - 1) / 26)
    end

    return columnKey
end

local function MainCellCoordinate(definition)
    local row = RowForItemLevel(definition.itemLevel)
    if not row then
        return nil
    end

    return ("%s%d"):format(definition.columnKey, row)
end

local function ExplicitRowCellCoordinate(definition)
    if not definition.columnKey or not definition.rowIndex then
        return nil
    end

    return ("%s%d"):format(definition.columnKey, definition.rowIndex)
end

local function CellCoordinate(definition, tableKey)
    if definition.cellCoordinate then
        return definition.cellCoordinate
    end

    if definition.itemLevel then
        return MainCellCoordinate(definition)
    end

    return ExplicitRowCellCoordinate(definition)
end

local function Cell(definition)
    definition.kind = "cell"
    return definition
end

local function MergedCell(definition)
    definition.kind = "mergedCell"
    return definition
end

local function RegisterBlockCell(blockDefinition, cellDefinition)
    local tableKey = cellDefinition.tableKey or blockDefinition.tableKey or "main"
    local cellCoordinate = CellCoordinate(cellDefinition, tableKey)
    if not cellCoordinate then
        return nil
    end

    cellsByTable[tableKey] = cellsByTable[tableKey] or {}
    cellsByTable[tableKey][cellCoordinate] = {
        text = cellDefinition.displayText or "",
        color = cellDefinition.backgroundColorKey or blockDefinition.backgroundColorKey,
        title = cellDefinition.tooltipTitle or blockDefinition.tooltipTitle,
        lines = cellDefinition.tooltipLines,
        level = cellDefinition.itemLevel,
        columnTitle = cellDefinition.columnTitle,
        metadata = MergeTables(blockDefinition.metadata, cellDefinition.metadata),
        onClick = cellDefinition.onClick,
        usesBlockBackgroundColor = cellDefinition.usesBlockBackgroundColor,
    }

    return cellCoordinate
end

local function MergedCellCoordinate(definition, tableKey, isEndCoordinate)
    local itemLevel = isEndCoordinate and (definition.toItemLevel or definition.fromItemLevel) or definition.fromItemLevel
    local rowIndex = isEndCoordinate and (definition.toRowIndex or definition.fromRowIndex) or definition.fromRowIndex
    local columnKey = isEndCoordinate
        and (definition.toColumnKey or definition.columnKey or definition.fromColumnKey)
        or (definition.fromColumnKey or definition.columnKey)

    return CellCoordinate({
        cellCoordinate = isEndCoordinate and definition.endCellCoordinate or definition.startCellCoordinate,
        columnKey = columnKey,
        itemLevel = itemLevel,
        rowIndex = rowIndex,
    }, tableKey)
end

local function MergedCellCoordinates(definition, tableKey)
    local startCellCoordinate = MergedCellCoordinate(definition, tableKey, false)
    local endCellCoordinate = MergedCellCoordinate(definition, tableKey, true)
    if not startCellCoordinate or not endCellCoordinate then
        return nil, nil, nil
    end

    local startColumnKey, startRow = startCellCoordinate:match("^([a-z]+)(%d+)$")
    local endColumnKey, endRow = endCellCoordinate:match("^([a-z]+)(%d+)$")
    local startColumn = ColumnIndex(startColumnKey)
    local endColumn = ColumnIndex(endColumnKey)
    startRow = tonumber(startRow)
    endRow = tonumber(endRow)
    if not startColumn or not endColumn or not startRow or not endRow then
        return nil, nil, nil
    end

    if startColumn > endColumn then
        startColumn, endColumn = endColumn, startColumn
    end
    if startRow > endRow then
        startRow, endRow = endRow, startRow
    end

    local coordinates = {}
    for row = startRow, endRow do
        for column = startColumn, endColumn do
            coordinates[#coordinates + 1] = ("%s%d"):format(ColumnKeyFromIndex(column), row)
        end
    end

    return coordinates, startCellCoordinate, endCellCoordinate
end

local function RegisterMergedCell(blockDefinition, cellDefinition)
    local tableKey = cellDefinition.tableKey or blockDefinition.tableKey or "main"
    local coordinates, startCellCoordinate, endCellCoordinate = MergedCellCoordinates(cellDefinition, tableKey)
    if not coordinates then
        return nil
    end

    mergedCells[#mergedCells + 1] = {
        tableKey = tableKey,
        startCellCoordinate = startCellCoordinate,
        endCellCoordinate = endCellCoordinate,
        displayText = cellDefinition.displayText,
        backgroundColorKey = cellDefinition.backgroundColorKey or blockDefinition.backgroundColorKey,
        tooltipTitle = cellDefinition.tooltipTitle or blockDefinition.tooltipTitle or cellDefinition.displayText,
        tooltipLines = cellDefinition.tooltipLines,
        columnTitle = cellDefinition.columnTitle,
        isTextVertical = cellDefinition.isTextVertical ~= false,
        fontSize = cellDefinition.fontSize,
        metadata = MergeTables(blockDefinition.metadata, cellDefinition.metadata),
        onClick = cellDefinition.onClick,
    }

    return coordinates
end

local function Block(definition)
    blocks[#blocks + 1] = definition

    local blockCellCoordinates = {}
    local mergedCellColorBlocks = {}
    for _, cellDefinition in ipairs(definition.cells or {}) do
        if cellDefinition.kind == "mergedCell" then
            local mergedCellCoordinates = RegisterMergedCell(definition, cellDefinition)
            if mergedCellCoordinates and #mergedCellCoordinates > 0 then
                mergedCellColorBlocks[#mergedCellColorBlocks + 1] = {
                    id = ("%s.merged.%d"):format(definition.blockId, #mergedCellColorBlocks + 1),
                    parentBlockId = definition.blockId,
                    color = cellDefinition.backgroundColorKey or definition.backgroundColorKey,
                    border = cellDefinition.outerBorderStyleKey or definition.outerBorderStyleKey or "solid1",
                    innerBorder = cellDefinition.innerBorderStyleKey,
                    parentInnerBorder = cellDefinition.parentInnerBorderStyleKey or definition.innerBorderStyleKey,
                    cells = mergedCellCoordinates,
                    tableKey = cellDefinition.tableKey or definition.tableKey or "main",
                    priority = (definition.priority or 0) + 1,
                }
            end
        else
            local cellCoordinate = RegisterBlockCell(definition, cellDefinition)
            if cellCoordinate then
                blockCellCoordinates[#blockCellCoordinates + 1] = cellCoordinate
            end
        end
    end

    if #blockCellCoordinates > 0 then
        colorBlocks[#colorBlocks + 1] = {
            id = definition.blockId,
            color = definition.backgroundColorKey,
            border = definition.outerBorderStyleKey or "solid1",
            innerBorder = definition.innerBorderStyleKey,
            cells = blockCellCoordinates,
            tableKey = definition.tableKey or "main",
            priority = definition.priority or 0,
        }
    end

    for _, mergedCellColorBlock in ipairs(mergedCellColorBlocks) do
        colorBlocks[#colorBlocks + 1] = mergedCellColorBlock
    end
end

local function NormalizeBorderAxis(axis)
    if axis == "horizontal" or axis == "h" then
        return "h"
    end
    if axis == "vertical" or axis == "v" then
        return "v"
    end

    return axis
end

local function BorderRule(definition)
    borderRules[#borderRules + 1] = {
        axis = NormalizeBorderAxis(definition.borderAxis),
        table = definition.tableKey,
        tables = definition.tableKeys,
        from = definition.fromRow,
        to = definition.toRow,
        after = definition.afterColumnKey,
        style = definition.borderStyleKey,
        priority = definition.priority,
        each = definition.appliesToEachCell,
        between = definition.betweenCellCoordinates,
    }
end

local function MainSectionBorder(definition)
    BorderRule({
        borderAxis = "vertical",
        afterColumnKey = definition.afterColumnKey,
        fromRow = 1,
        toRow = #levels + 1,
        borderStyleKey = "solid3",
        priority = 70,
    })
end

BorderRule({
    borderAxis = "horizontal",
    tableKeys = { "main", "left" },
    fromRow = 1,
    toRow = 1,
    appliesToEachCell = true,
    borderStyleKey = "solid3",
    priority = 100,
})

BorderRule({
    borderAxis = "horizontal",
    tableKey = "all",
    appliesToEachCell = true,
    borderStyleKey = "dashed",
    priority = 1,
})

MainSectionBorder({ afterColumnKey = "a" })
MainSectionBorder({ afterColumnKey = "g" })
MainSectionBorder({ afterColumnKey = "i" })
MainSectionBorder({ afterColumnKey = "j" })
MainSectionBorder({ afterColumnKey = "m" })
MainSectionBorder({ afterColumnKey = "o" })

Block({
    blockId = "raid.lfr",
    backgroundColorKey = "blue",
    outerBorderStyleKey = "solid1",
    innerBorderStyleKey = "dashed",
    metadata = { contentType = "raid", difficulty = "lfr" },
    cells = {
        Cell({ columnKey = "b", itemLevel = 272, displayText = "GV", tooltipTitle = "Champion Great Vault Reward", metadata = { valueType = "dropItemLevel" } }),
        MergedCell({ columnKey = "b", fromItemLevel = 276, toItemLevel = 282, displayText = "LFR", isTextVertical = true }),
        Cell({ columnKey = "b", itemLevel = 276, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 279, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 282, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 289, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "c", itemLevel = 272, displayText = "1/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 276, displayText = "2/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 279, displayText = "3/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 282, displayText = "4/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 285, displayText = "5/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 289, displayText = "6/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        MergedCell({ columnKey = "d", fromItemLevel = 272, toItemLevel = 289, displayText = "Veteran", isTextVertical = true }),
    },
})

-- Block({
--     blockId = "raid.veteran",
--     backgroundColorKey = "blue",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "veteran" },
--     cells = {
--         Cell({ columnKey = "d", itemLevel = 272, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 276, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 279, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 282, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 285, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 289, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "e", itemLevel = 272, displayText = "1/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 276, displayText = "2/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 279, displayText = "3/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 282, displayText = "4/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 285, displayText = "5/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 289, displayText = "6/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "d", fromItemLevel = 272, toItemLevel = 289, displayText = "Veteran", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.adventurer",
--     backgroundColorKey = "pink",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "adventurer" },
--     cells = {
--         Cell({ columnKey = "f", itemLevel = 259, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 263, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 266, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 269, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 272, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 276, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "g", itemLevel = 259, displayText = "1/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 263, displayText = "2/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 266, displayText = "3/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 269, displayText = "4/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 272, displayText = "5/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 276, displayText = "6/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "f", fromItemLevel = 259, toItemLevel = 276, displayText = "Adventurer", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.normal",
--     backgroundColorKey = "yellow",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "raid", difficulty = "normal" },
--     cells = {
--         Cell({ columnKey = "b", itemLevel = 285, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 289, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 292, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 295, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 298, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 302, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "c", itemLevel = 285, displayText = "1/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 289, displayText = "2/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 292, displayText = "3/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 295, displayText = "4/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 298, displayText = "5/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 302, displayText = "6/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "b", fromItemLevel = 285, toItemLevel = 302, displayText = "Normal", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.champion",
--     backgroundColorKey = "yellow",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "champion" },
--     cells = {
--         Cell({ columnKey = "f", itemLevel = 285, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 289, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 292, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 295, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 298, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 302, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "g", itemLevel = 285, displayText = "1/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 289, displayText = "2/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 292, displayText = "3/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 295, displayText = "4/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 298, displayText = "5/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 302, displayText = "6/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "f", fromItemLevel = 285, toItemLevel = 302, displayText = "Champion", isTextVertical = true }),
--     },
-- })

Block({
    blockId = "raid.heroic",
    backgroundColorKey = "red",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "raid", difficulty = "heroic" },
    cells = {
        Cell({ columnKey = "b", itemLevel = 298, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 302, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 305, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 308, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 311, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 315, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "c", itemLevel = 298, displayText = "1/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 302, displayText = "2/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 305, displayText = "3/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 308, displayText = "4/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 311, displayText = "5/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 315, displayText = "6/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        MergedCell({ columnKey = "b", fromItemLevel = 298, toItemLevel = 315, displayText = "Heroic", isTextVertical = true }),
    },
})

Block({
    blockId = "raid.hero",
    backgroundColorKey = "red",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "upgradeTrack", track = "hero" },
    cells = {
        Cell({ columnKey = "d", itemLevel = 298, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "d", itemLevel = 302, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "d", itemLevel = 305, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "d", itemLevel = 308, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "d", itemLevel = 311, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "d", itemLevel = 315, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "e", itemLevel = 298, displayText = "1/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "e", itemLevel = 302, displayText = "2/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "e", itemLevel = 305, displayText = "3/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "e", itemLevel = 308, displayText = "4/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "e", itemLevel = 311, displayText = "5/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "e", itemLevel = 315, displayText = "6/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
        MergedCell({ columnKey = "d", fromItemLevel = 298, toItemLevel = 315, displayText = "Hero", isTextVertical = true }),
    },
})

Block({
    blockId = "raid.mythic",
    backgroundColorKey = "purple",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "raid", difficulty = "mythic" },
    cells = {
        Cell({ columnKey = "b", itemLevel = 311, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 315, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 318, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 321, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 324, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 328, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 334, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 337, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "c", itemLevel = 311, displayText = "1/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 315, displayText = "2/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 318, displayText = "3/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 321, displayText = "4/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 324, displayText = "5/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 328, displayText = "6/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 334, displayText = "8/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 337, displayText = "9/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
        MergedCell({ columnKey = "b", fromItemLevel = 311, toItemLevel = 337, displayText = "Mythic", isTextVertical = true }),
    },
})

Block({
    blockId = "raid.myth",
    backgroundColorKey = "purple",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "upgradeTrack", track = "myth" },
    cells = {
        Cell({ columnKey = "f", itemLevel = 311, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "f", itemLevel = 315, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "f", itemLevel = 318, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "f", itemLevel = 321, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "f", itemLevel = 324, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "f", itemLevel = 328, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "f", itemLevel = 334, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "f", itemLevel = 337, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
        Cell({ columnKey = "g", itemLevel = 311, displayText = "1/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "g", itemLevel = 315, displayText = "2/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "g", itemLevel = 318, displayText = "3/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "g", itemLevel = 321, displayText = "4/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "g", itemLevel = 324, displayText = "5/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "g", itemLevel = 328, displayText = "6/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "g", itemLevel = 334, displayText = "8/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "g", itemLevel = 337, displayText = "9/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
        MergedCell({ columnKey = "f", fromItemLevel = 311, toItemLevel = 337, displayText = "Myth", isTextVertical = true }),
    },
})

Block({
    blockId = "craft.adventurer",
    backgroundColorKey = "pink",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "crafting", track = "adventurer" },
    cells = {
        Cell({ columnKey = "h", itemLevel = 259, displayText = "W", tooltipTitle = "Weathered crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 263, displayText = "C", tooltipTitle = "Carved crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 266, displayText = "R", tooltipTitle = "Runed crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 269, displayText = "G", tooltipTitle = "Gilded crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 272, displayText = "S", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "i", itemLevel = 259, tooltipTitle = "Weathered crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 263, tooltipTitle = "Carved crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 266, tooltipTitle = "Runed crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 269, tooltipTitle = "Gilded crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 272, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
        MergedCell({ columnKey = "i", fromItemLevel = 259, toItemLevel = 272, displayText = "30 Adv.", isTextVertical = true, fontSize = 12 }),
    },
})

Block({
    blockId = "craft.veteran",
    backgroundColorKey = "blue",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "crafting", track = "veteran" },
    cells = {
        Cell({ columnKey = "h", itemLevel = 276, displayText = "W", tooltipTitle = "Weathered crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 279, displayText = "C", tooltipTitle = "Carved crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 282, displayText = "R", tooltipTitle = "Runed crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 285, displayText = "S", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "i", itemLevel = 276, tooltipTitle = "Weathered crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 279, tooltipTitle = "Carved crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 282, tooltipTitle = "Runed crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 285, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
        MergedCell({ columnKey = "i", fromItemLevel = 276, toItemLevel = 285, displayText = "30 Vet.", isTextVertical = true, fontSize = 12 }),
    },
})

Block({
    blockId = "craft.champion",
    backgroundColorKey = "yellow",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "crafting", track = "champion" },
    cells = {
        Cell({ columnKey = "h", itemLevel = 289, displayText = "C", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 292, displayText = "R", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 295, displayText = "G", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 298, displayText = "S", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "i", itemLevel = 289, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 292, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 295, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 298, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
        MergedCell({ columnKey = "i", fromItemLevel = 289, toItemLevel = 298, displayText = "Spark", isTextVertical = true, fontSize = 12 }),
    },
})

Block({
    blockId = "craft.hero",
    backgroundColorKey = "red",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "crafting", track = "hero" },
    cells = {
        Cell({ columnKey = "h", itemLevel = 302, displayText = "W", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 305, displayText = "C", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 308, displayText = "R", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 311, displayText = "S", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "i", itemLevel = 302, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 305, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 308, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 311, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
        MergedCell({ columnKey = "i", fromItemLevel = 302, toItemLevel = 311, displayText = "80 Hero", isTextVertical = true, fontSize = 12 }),
    },
})

Block({
    blockId = "craft.myth",
    backgroundColorKey = "purple",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "crafting", track = "myth" },
    cells = {
        Cell({ columnKey = "h", itemLevel = 315, displayText = "C", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 318, displayText = "R", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 321, displayText = "G", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "h", itemLevel = 324, displayText = "S", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "i", itemLevel = 315, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 318, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 321, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
        Cell({ columnKey = "i", itemLevel = 324, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
        MergedCell({ columnKey = "i", fromItemLevel = 315, toItemLevel = 324, displayText = "80 Myth", isTextVertical = true, fontSize = 12 }),
    },
})

Block({
    blockId = "craft.veryrare",
    backgroundColorKey = "purple",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "crafting", track = "veryRare" },
    cells = {
        Cell({ columnKey = "h", itemLevel = 334, displayText = "VF", tooltipTitle = "Very rare craft", metadata = { valueType = "crestOrSpark" } }),
        Cell({ columnKey = "i", itemLevel = 334, tooltipTitle = "Very rare craft", metadata = { valueType = "craftingTier" } }),
        MergedCell({ columnKey = "i", fromItemLevel = 334, toItemLevel = 334, displayText = "VF", isTextVertical = true, fontSize = 12 }),
    },
})

Block({ blockId = "activity.prey.normal", backgroundColorKey = "pink", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
    Cell({ columnKey = "j", itemLevel = 266, displayText = "N", tooltipTitle = "Prey: Normal", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.prey.heroic", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
    Cell({ columnKey = "j", itemLevel = 279, displayText = "H", tooltipTitle = "Prey: Heroic", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.prey.mixed", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
    Cell({ columnKey = "j", itemLevel = 285, displayText = "NM", tooltipTitle = "Prey: Normal/Mythic", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.prey.weekly", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
    Cell({ columnKey = "j", itemLevel = 298, displayText = "NM1", tooltipTitle = "Prey: weekly cache", metadata = { valueType = "itemLevel" } }),
} })

Block({ blockId = "activity.delve.low", backgroundColorKey = "pink", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "delve" }, cells = {
    Cell({ columnKey = "k", itemLevel = 269, displayText = "1-3", tooltipTitle = "Delve tiers 1-3", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "k", itemLevel = 272, displayText = "4", tooltipTitle = "Delve tier 4", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.delve.mid", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "delve" }, cells = {
    Cell({ columnKey = "k", itemLevel = 276, displayText = "5", tooltipTitle = "Delve tier 5", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "k", itemLevel = 279, displayText = "6", tooltipTitle = "Delve tier 6", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "k", itemLevel = 282, displayText = "7", tooltipTitle = "Delve tier 7", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "k", itemLevel = 285, displayText = "8+", tooltipTitle = "Delve tier 8+", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.delve.weekly", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "delve" }, cells = {
    Cell({ columnKey = "k", itemLevel = 298, displayText = "8+1", tooltipTitle = "Delve weekly tier 8+", metadata = { valueType = "itemLevel" } }),
} })

Block({ blockId = "activity.map.mid", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "map" }, cells = {
    Cell({ columnKey = "l", itemLevel = 276, displayText = "4", tooltipTitle = "Bountiful map tier 4", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "l", itemLevel = 282, displayText = "5", tooltipTitle = "Bountiful map tier 5", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.map.high", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "map" }, cells = {
    Cell({ columnKey = "l", itemLevel = 289, displayText = "6", tooltipTitle = "Bountiful map tier 6", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "l", itemLevel = 295, displayText = "7", tooltipTitle = "Bountiful map tier 7", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.map.top", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "map" }, cells = {
    Cell({ columnKey = "l", itemLevel = 298, displayText = "8+", tooltipTitle = "Bountiful map tier 8+", metadata = { valueType = "itemLevel" } }),
} })

Block({ blockId = "activity.outdoorVault.mid", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "outdoorVault" }, cells = {
    Cell({ columnKey = "m", itemLevel = 272, displayText = "1-2", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "m", itemLevel = 276, displayText = "3", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.outdoorVault.high", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "outdoorVault" }, cells = {
    Cell({ columnKey = "m", itemLevel = 285, displayText = "4", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "m", itemLevel = 292, displayText = "5", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "m", itemLevel = 295, displayText = "6", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "m", itemLevel = 298, displayText = "7", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.outdoorVault.top", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "outdoorVault" }, cells = {
    Cell({ columnKey = "m", itemLevel = 305, displayText = "8+", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
} })

Block({ blockId = "activity.dungeon.normal", backgroundColorKey = "light", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
    Cell({ columnKey = "n", itemLevel = 253, displayText = "N", tooltipTitle = "Dungeon: Normal", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.dungeon.heroic", backgroundColorKey = "pink", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
    Cell({ columnKey = "n", itemLevel = 269, displayText = "H", tooltipTitle = "Dungeon: Heroic", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.dungeon.mythic", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
    Cell({ columnKey = "n", itemLevel = 285, displayText = "M", tooltipTitle = "Dungeon: Mythic", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "n", itemLevel = 289, displayText = "2-3", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "n", itemLevel = 292, displayText = "4", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "n", itemLevel = 295, displayText = "5", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.dungeon.mythicPlus", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
    Cell({ columnKey = "n", itemLevel = 298, displayText = "6-7", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "n", itemLevel = 302, displayText = "8-9", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "n", itemLevel = 305, displayText = "10+", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
} })

Block({ blockId = "activity.dungeonVault.heroic", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
    Cell({ columnKey = "o", itemLevel = 282, displayText = "H", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.dungeonVault.mythic", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
    Cell({ columnKey = "o", itemLevel = 295, displayText = "M", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.dungeonVault.mythicPlus", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
    Cell({ columnKey = "o", itemLevel = 298, displayText = "2-3", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "o", itemLevel = 302, displayText = "4-5", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "o", itemLevel = 305, displayText = "6", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
    Cell({ columnKey = "o", itemLevel = 308, displayText = "7-9", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
} })
Block({ blockId = "activity.dungeonVault.top", backgroundColorKey = "purple", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
    Cell({ columnKey = "o", itemLevel = 311, displayText = "10+", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
} })

Block({
    blockId = "left.questWorld.section",
    tableKey = "left",
    backgroundColorKey = "light",
    outerBorderStyleKey = "solid1",
    cells = {
        Cell({ columnKey = "a", rowIndex = 2, tooltipTitle = "Quest / World" }),
        Cell({ columnKey = "a", rowIndex = 3, tooltipTitle = "Quest / World" }),
        Cell({ columnKey = "a", rowIndex = 4, tooltipTitle = "Quest / World" }),
        Cell({ columnKey = "a", rowIndex = 5, tooltipTitle = "Quest / World" }),
        Cell({ columnKey = "a", rowIndex = 6, tooltipTitle = "Quest / World" }),
        MergedCell({ columnKey = "a", fromRowIndex = 2, toRowIndex = 6, displayText = "Quest / World", isTextVertical = true }),
    },
})

Block({
    blockId = "left.world.normal",
    tableKey = "left",
    backgroundColorKey = "light",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "normal" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 7, displayText = "N", metadata = { valueType = "difficulty" } }),
        Cell({ columnKey = "b", rowIndex = 7, displayText = "253", metadata = { valueType = "lootItemLevel" } }),
        Cell({ columnKey = "c", rowIndex = 7, displayText = "-", metadata = { valueType = "lootUpgradeRank" } }),
        Cell({ columnKey = "d", rowIndex = 7, metadata = { valueType = "vaultItemLevel" } }),
        Cell({ columnKey = "e", rowIndex = 7, metadata = { valueType = "vaultUpgradeRank" } }),
        Cell({ columnKey = "f", rowIndex = 7, backgroundColorKey = "blank", usesBlockBackgroundColor = false, metadata = { valueType = "crest" } }),
    },
})

Block({
    blockId = "left.world.heroic",
    tableKey = "left",
    backgroundColorKey = "blue",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "heroic" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 8, displayText = "H", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 8, displayText = "269" }),
        Cell({ columnKey = "c", rowIndex = 8, displayText = "4/6" }),
        Cell({ columnKey = "d", rowIndex = 8, displayText = "285" }),
        Cell({ columnKey = "e", rowIndex = 8, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 8, displayText = "10 V" }),
    },
})

Block({
    blockId = "left.world.mythicLow",
    tableKey = "left",
    backgroundColorKey = "yellow",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "mythicLow" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 9, displayText = "M", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 9, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 9, displayText = "1/6" }),
        Cell({ columnKey = "d", rowIndex = 9, displayText = "295" }),
        Cell({ columnKey = "e", rowIndex = 9, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 9, displayText = "10 C" }),
        Cell({ columnKey = "a", rowIndex = 10, displayText = "+2", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 10, displayText = "289" }),
        Cell({ columnKey = "c", rowIndex = 10, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 10, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 10, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 10, displayText = "12 C" }),
        Cell({ columnKey = "a", rowIndex = 11, displayText = "+3", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 11, displayText = "289" }),
        Cell({ columnKey = "c", rowIndex = 11, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 11, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 11, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 11, displayText = "14 C" }),
    },
})

Block({
    blockId = "left.world.mythicHigh",
    tableKey = "left",
    backgroundColorKey = "red",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "mythicHigh" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 12, displayText = "+4", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 12, displayText = "292" }),
        Cell({ columnKey = "c", rowIndex = 12, displayText = "3/6" }),
        Cell({ columnKey = "d", rowIndex = 12, displayText = "302" }),
        Cell({ columnKey = "e", rowIndex = 12, displayText = "2/6" }),
        Cell({ columnKey = "f", rowIndex = 12, displayText = "10 H" }),
        Cell({ columnKey = "a", rowIndex = 13, displayText = "+5", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 13, displayText = "295" }),
        Cell({ columnKey = "c", rowIndex = 13, displayText = "4/6" }),
        Cell({ columnKey = "d", rowIndex = 13, displayText = "302" }),
        Cell({ columnKey = "e", rowIndex = 13, displayText = "2/6" }),
        Cell({ columnKey = "f", rowIndex = 13, displayText = "12 H" }),
        Cell({ columnKey = "a", rowIndex = 14, displayText = "+6", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 14, displayText = "298" }),
        Cell({ columnKey = "c", rowIndex = 14, displayText = "1/6" }),
        Cell({ columnKey = "d", rowIndex = 14, displayText = "305" }),
        Cell({ columnKey = "e", rowIndex = 14, displayText = "3/6" }),
        Cell({ columnKey = "f", rowIndex = 14, displayText = "14 H" }),
        Cell({ columnKey = "a", rowIndex = 15, displayText = "+7", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 15, displayText = "298" }),
        Cell({ columnKey = "c", rowIndex = 15, displayText = "1/6" }),
        Cell({ columnKey = "d", rowIndex = 15, displayText = "308" }),
        Cell({ columnKey = "e", rowIndex = 15, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 15, displayText = "16 H" }),
        Cell({ columnKey = "a", rowIndex = 16, displayText = "+8", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 16, displayText = "302" }),
        Cell({ columnKey = "c", rowIndex = 16, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 16, displayText = "308" }),
        Cell({ columnKey = "e", rowIndex = 16, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 16, displayText = "18 H" }),
    },
})

Block({
    blockId = "left.world.mythicTop",
    tableKey = "left",
    backgroundColorKey = "purple",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "mythicTop" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 17, displayText = "+9", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 17, displayText = "302" }),
        Cell({ columnKey = "c", rowIndex = 17, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 17, displayText = "308" }),
        Cell({ columnKey = "e", rowIndex = 17, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 17, displayText = "10 M" }),
        Cell({ columnKey = "a", rowIndex = 18, displayText = "+10", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 18, displayText = "305" }),
        Cell({ columnKey = "c", rowIndex = 18, displayText = "3/6" }),
        Cell({ columnKey = "d", rowIndex = 18, displayText = "311" }),
        Cell({ columnKey = "e", rowIndex = 18, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 18, displayText = "12 M" }),
        Cell({ columnKey = "a", rowIndex = 19, displayText = "+11", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 19, displayText = "305" }),
        Cell({ columnKey = "c", rowIndex = 19, displayText = "3/6" }),
        Cell({ columnKey = "d", rowIndex = 19, displayText = "311" }),
        Cell({ columnKey = "e", rowIndex = 19, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 19, displayText = "14 M" }),
        Cell({ columnKey = "a", rowIndex = 20, displayText = "+12", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 20, displayText = "305" }),
        Cell({ columnKey = "c", rowIndex = 20, displayText = "3/6" }),
        Cell({ columnKey = "d", rowIndex = 20, displayText = "311" }),
        Cell({ columnKey = "e", rowIndex = 20, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 20, displayText = "16 M" }),
    },
})

Block({
    blockId = "left.world.dungeonSection",
    tableKey = "left",
    backgroundColorKey = "light",
    outerBorderStyleKey = "solid1",
    cells = {
        Cell({ columnKey = "g", rowIndex = 7 }),
        Cell({ columnKey = "g", rowIndex = 8 }),
        Cell({ columnKey = "g", rowIndex = 9 }),
        Cell({ columnKey = "g", rowIndex = 10 }),
        Cell({ columnKey = "g", rowIndex = 11 }),
        Cell({ columnKey = "g", rowIndex = 12 }),
        Cell({ columnKey = "g", rowIndex = 13 }),
        Cell({ columnKey = "g", rowIndex = 14 }),
        Cell({ columnKey = "g", rowIndex = 15 }),
        Cell({ columnKey = "g", rowIndex = 16 }),
        Cell({ columnKey = "g", rowIndex = 17 }),
        Cell({ columnKey = "g", rowIndex = 18 }),
        Cell({ columnKey = "g", rowIndex = 19 }),
        Cell({ columnKey = "g", rowIndex = 20 }),
        MergedCell({ columnKey = "g", fromRowIndex = 7, toRowIndex = 20, displayText = "Dungeon", isTextVertical = true }),
    },
})

Block({
    blockId = "left.delve.low",
    tableKey = "left",
    backgroundColorKey = "pink",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "low" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 24, displayText = "1", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 24, displayText = "259" }),
        Cell({ columnKey = "c", rowIndex = 24, displayText = "1/6" }),
        Cell({ columnKey = "d", rowIndex = 24, displayText = "272" }),
        Cell({ columnKey = "e", rowIndex = 24, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 24, backgroundColorKey = "blank", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "a", rowIndex = 25, displayText = "2", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 25, displayText = "263" }),
        Cell({ columnKey = "c", rowIndex = 25, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 25, displayText = "276" }),
        Cell({ columnKey = "e", rowIndex = 25, displayText = "2/6" }),
        Cell({ columnKey = "f", rowIndex = 25, backgroundColorKey = "blank", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "a", rowIndex = 26, displayText = "3", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 26, displayText = "266" }),
        Cell({ columnKey = "c", rowIndex = 26, displayText = "3/6" }),
        Cell({ columnKey = "d", rowIndex = 26, displayText = "279" }),
        Cell({ columnKey = "e", rowIndex = 26, displayText = "3/6" }),
        Cell({ columnKey = "f", rowIndex = 26, backgroundColorKey = "blank", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "a", rowIndex = 27, displayText = "4", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 27, displayText = "269" }),
        Cell({ columnKey = "c", rowIndex = 27, displayText = "4/6" }),
        Cell({ columnKey = "d", rowIndex = 27, displayText = "282" }),
        Cell({ columnKey = "e", rowIndex = 27, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 27, displayText = "A" }),
    },
})

Block({
    blockId = "left.delve.mid",
    tableKey = "left",
    backgroundColorKey = "blue",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "mid" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 28, displayText = "5", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 28, displayText = "272" }),
        Cell({ columnKey = "c", rowIndex = 28, displayText = "1/6" }),
        Cell({ columnKey = "d", rowIndex = 28, displayText = "285" }),
        Cell({ columnKey = "e", rowIndex = 28, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 28, displayText = "V" }),
        Cell({ columnKey = "a", rowIndex = 29, displayText = "6", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 29, displayText = "276" }),
        Cell({ columnKey = "c", rowIndex = 29, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 29, displayText = "292" }),
        Cell({ columnKey = "e", rowIndex = 29, displayText = "3/6" }),
        Cell({ columnKey = "f", rowIndex = 29, displayText = "V" }),
    },
})

Block({
    blockId = "left.delve.high",
    tableKey = "left",
    backgroundColorKey = "yellow",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "high" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 30, displayText = "7", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 30, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 30, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 30, displayText = "295" }),
        Cell({ columnKey = "e", rowIndex = 30, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 30, displayText = "C" }),
        Cell({ columnKey = "a", rowIndex = 31, displayText = "8", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 31, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 31, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 31, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 31, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 31, displayText = "C" }),
        Cell({ columnKey = "a", rowIndex = 32, displayText = "9", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 32, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 32, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 32, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 32, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 32, displayText = "C" }),
        Cell({ columnKey = "a", rowIndex = 33, displayText = "10", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 33, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 33, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 33, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 33, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 33, displayText = "C" }),
    },
})

Block({
    blockId = "left.delve.top",
    tableKey = "left",
    backgroundColorKey = "red",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "top" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 34, displayText = "11", backgroundColorKey = "light", usesBlockBackgroundColor = false }),
        Cell({ columnKey = "b", rowIndex = 34, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 34, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 34, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 34, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 34, displayText = "H" }),
    },
})

Block({
    blockId = "left.delve.section",
    tableKey = "left",
    backgroundColorKey = "light",
    outerBorderStyleKey = "solid1",
    cells = {
        Cell({ columnKey = "g", rowIndex = 24 }),
        Cell({ columnKey = "g", rowIndex = 25 }),
        Cell({ columnKey = "g", rowIndex = 26 }),
        Cell({ columnKey = "g", rowIndex = 27 }),
        Cell({ columnKey = "g", rowIndex = 28 }),
        Cell({ columnKey = "g", rowIndex = 29 }),
        Cell({ columnKey = "g", rowIndex = 30 }),
        Cell({ columnKey = "g", rowIndex = 31 }),
        Cell({ columnKey = "g", rowIndex = 32 }),
        Cell({ columnKey = "g", rowIndex = 33 }),
        Cell({ columnKey = "g", rowIndex = 34 }),
        MergedCell({ columnKey = "g", fromRowIndex = 24, toRowIndex = 34, displayText = "Delve", isTextVertical = true }),
    },
})

NS.Data = {
    levels = levels,
    leftLayout = leftLayout,
    blocks = blocks,
    cells = cellsByTable,
    colorBlocks = colorBlocks,
    mergedCells = mergedCells,
    borderRules = borderRules,
    footerLeft = "Midnight - Season 2 (12.1.0) - by Yvairel <Party Shark> <Suds with Buds>",
    footerRight = "1 Once a Week | VF: Venomforged | GV: Great Vault",
}
