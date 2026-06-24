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

local tableOrder = {}
local tablesByKey = {}
local blocks = {}
local cellsByTable = {}
local colorBlocks = {}
local mergedCells = {}
local borderRules = {}

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

local function DefaultTooltip(title)
    if title then
        return { title = title }
    end

    return nil
end

local function CellCoordinate(definition)
    if definition.coord then
        return definition.coord
    end

    if not definition.col or not definition.row then
        return nil
    end

    return ("%s%d"):format(definition.col, definition.row)
end

local function Table(definition)
    if not definition or not definition.key then
        return nil
    end

    if not tablesByKey[definition.key] then
        tableOrder[#tableOrder + 1] = definition
    end

    tablesByKey[definition.key] = definition
    return definition
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
    local tableKey = cellDefinition.table or blockDefinition.table or "main"
    local cellCoordinate = CellCoordinate(cellDefinition)
    if not cellCoordinate then
        return nil
    end

    cellsByTable[tableKey] = cellsByTable[tableKey] or {}
    cellsByTable[tableKey][cellCoordinate] = {
        text = cellDefinition.text or "",
        bg = cellDefinition.bg,
        tooltip = cellDefinition.tooltip or blockDefinition.tooltip,
        colTitle = cellDefinition.title,
        onClick = cellDefinition.onClick,
    }

    return cellCoordinate
end

local function MergedCellCoordinate(definition, isEndCoordinate)
    local coord = isEndCoordinate and definition.toCoord or definition.fromCoord
    local row = isEndCoordinate and (definition.toRow or definition.row) or (definition.fromRow or definition.row)
    local col = isEndCoordinate
        and (definition.toCol or definition.col or definition.fromCol)
        or (definition.fromCol or definition.col)

    return CellCoordinate({
        coord = coord,
        col = col,
        row = row,
    })
end

local function MergedCellCoordinates(definition)
    local startCellCoordinate = MergedCellCoordinate(definition, false)
    local endCellCoordinate = MergedCellCoordinate(definition, true)
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
    local tableKey = cellDefinition.table or blockDefinition.table or "main"
    local coordinates, startCellCoordinate, endCellCoordinate = MergedCellCoordinates(cellDefinition)
    if not coordinates then
        return nil
    end

    mergedCells[#mergedCells + 1] = {
        table = tableKey,
        startCoord = startCellCoordinate,
        endCoord = endCellCoordinate,
        text = cellDefinition.text,
        bg = cellDefinition.bg or blockDefinition.bg,
        tooltip = cellDefinition.tooltip or blockDefinition.tooltip or DefaultTooltip(cellDefinition.text),
        colTitle = cellDefinition.title,
        vertical = cellDefinition.vertical ~= false,
        font = cellDefinition.font,
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
                    id = ("%s.merged.%d"):format(definition.id, #mergedCellColorBlocks + 1),
                    parentBlockId = definition.id,
                    bg = cellDefinition.bg or definition.bg,
                    border = cellDefinition.border or definition.border or "solid1",
                    innerBorder = cellDefinition.innerBorder,
                    parentInnerBorder = cellDefinition.parentInnerBorder or definition.innerBorder,
                    cells = mergedCellCoordinates,
                    table = cellDefinition.table or definition.table or "main",
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
            id = definition.id,
            bg = definition.bg,
            border = definition.border or "solid1",
            innerBorder = definition.innerBorder,
            cells = blockCellCoordinates,
            table = definition.table or "main",
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
        axis = NormalizeBorderAxis(definition.axis),
        table = definition.table,
        tables = definition.tables,
        from = definition.fromRow,
        to = definition.toRow,
        after = definition.afterCol,
        row = definition.row,
        fromCol = definition.fromCol,
        toCol = definition.toCol,
        edge = definition.edge,
        style = definition.style,
        priority = definition.priority,
        each = definition.each,
        between = definition.between,
    }
end

NS.DataAPI = {
    Table = Table,
    Block = Block,
    Cell = Cell,
    MergedCell = MergedCell,
    BorderRule = BorderRule,
}

NS.Data = {
    levels = levels,
    tableOrder = tableOrder,
    tables = tablesByKey,
    blocks = blocks,
    cells = cellsByTable,
    colorBlocks = colorBlocks,
    mergedCells = mergedCells,
    borderRules = borderRules,
    footerLeft = "Midnight - Season 2 (12.1.0) - by Yvairel <Party Shark> <Suds with Buds>",
    footerRight = "1 Once a Week | VF: Venomforged | GV: Great Vault",
}
