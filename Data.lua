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

local function ValueOrDefault(value, defaultValue)
    if value ~= nil then
        return value
    end

    return defaultValue
end

local function CopyFontStyle(definition)
    if type(definition) ~= "table" then
        return nil
    end

    if type(definition.font) == "table" then
        local font = {}
        for key, value in pairs(definition.font) do
            font[key] = value
        end
        return font
    end

    return nil
end

local function MergeFontStyles(defaultDefinition, overrideDefinition)
    local defaultFont = CopyFontStyle(defaultDefinition)
    local overrideFont = CopyFontStyle(overrideDefinition)
    if not defaultFont and not overrideFont then
        return nil
    end

    local merged = {}
    for key, value in pairs(defaultFont or {}) do
        merged[key] = value
    end
    for key, value in pairs(overrideFont or {}) do
        merged[key] = value
    end

    return merged
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

local function ParseCellCoordinate(coord)
    local columnKey, row = tostring(coord or ""):lower():match("^([a-z]+)(%d+)$")
    local column = ColumnIndex(columnKey)
    row = tonumber(row)
    if not column or not row then
        return nil
    end

    return column, row, ("%s%d"):format(columnKey, row)
end

local function NormalizeCellRange(startCoord, endCoord)
    local startColumn, startRow = ParseCellCoordinate(startCoord)
    local endColumn, endRow = ParseCellCoordinate(endCoord or startCoord)
    if not startColumn or not endColumn or not startRow or not endRow then
        return nil
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

    return {
        fromColumn = startColumn,
        toColumn = endColumn,
        fromRow = startRow,
        toRow = endRow,
        fromCoord = ("%s%d"):format(ColumnKeyFromIndex(startColumn), startRow),
        toCoord = ("%s%d"):format(ColumnKeyFromIndex(endColumn), endRow),
        coordinates = coordinates,
    }
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
        bold = ValueOrDefault(cellDefinition.bold, blockDefinition.bold),
        font = MergeFontStyles(blockDefinition, cellDefinition),
        border = cellDefinition.border,
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

local function MergedCellSpan(definition)
    local startCellCoordinate = MergedCellCoordinate(definition, false)
    local endCellCoordinate = MergedCellCoordinate(definition, true)
    return NormalizeCellRange(startCellCoordinate, endCellCoordinate)
end

local function RegisterMergedCell(blockDefinition, cellDefinition)
    local tableKey = cellDefinition.table or blockDefinition.table or "main"
    local span = MergedCellSpan(cellDefinition)
    if not span then
        return nil
    end

    local mergedCell = {
        table = tableKey,
        startCoord = span.fromCoord,
        endCoord = span.toCoord,
        span = span,
        text = cellDefinition.text or "",
        bg = cellDefinition.bg,
        tooltip = cellDefinition.tooltip or blockDefinition.tooltip or DefaultTooltip(cellDefinition.text),
        colTitle = cellDefinition.title,
        bold = ValueOrDefault(cellDefinition.bold, blockDefinition.bold),
        vertical = cellDefinition.vertical ~= false,
        font = MergeFontStyles(blockDefinition, cellDefinition),
        border = cellDefinition.border,
        onClick = cellDefinition.onClick,
    }

    mergedCells[#mergedCells + 1] = mergedCell

    cellsByTable[tableKey] = cellsByTable[tableKey] or {}
    cellsByTable[tableKey][span.fromCoord] = mergedCell

    return span.coordinates
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

local function BorderRuleBase(definition, kind)
    definition = definition or {}
    return {
        kind = kind,
        table = definition.table,
        tables = definition.tables,
        style = definition.style,
        priority = definition.priority,
    }
end

local function AddBorderRule(rule)
    borderRules[#borderRules + 1] = rule
end

-- Border constructors share table/tables, style, and priority:
-- table = "primary" limits the rule to one table.
-- tables = { "dungeon", "delve" } limits it to multiple tables.
-- style accepts "solid1", "solid3", "dashed", "dotted", or "none".
-- Higher priority wins when multiple rules target the same grid line.

-- RowBorders draws bottom borders for many rows.
-- Omit fromRow/toRow to draw separators between every adjacent rendered row.
-- Use fromRow/toRow to force a bottom border on each row in a range.
-- Example: RowBorders({ fromRow = 1, toRow = 1, style = "solid3" })
local function RowBorders(definition)
    definition = definition or {}
    local rule = BorderRuleBase(definition, "rowBorders")
    rule.fromRow = definition.fromRow
    rule.toRow = definition.toRow
    AddBorderRule(rule)
end

-- ColumnBorders draws right borders between every adjacent rendered column.
-- Example: ColumnBorders({ style = "dashed", priority = 1 })
local function ColumnBorders(definition)
    AddBorderRule(BorderRuleBase(definition, "columnBorders"))
end

-- TableBorder draws outside edges around the rendered table grid.
-- It uses the registered table cells, so merged headers still produce one continuous edge.
-- Example: TableBorder({ style = "solid1" })
local function TableBorder(definition)
    AddBorderRule(BorderRuleBase(definition, "tableBorder"))
end

-- RowBorder draws one horizontal border across a column range on one row.
-- edge defaults to "bottom"; use edge = "top" for the row's top border.
-- Example: RowBorder({ row = 17, fromCol = "b", toCol = "f", style = "solid3" })
local function RowBorder(definition)
    definition = definition or {}
    local rule = BorderRuleBase(definition, "rowBorder")
    rule.row = definition.row
    rule.fromCol = definition.fromCol
    rule.toCol = definition.toCol
    rule.edge = definition.edge
    AddBorderRule(rule)
end

-- ColumnBorder draws one vertical border before or after a column for a row range.
-- Use beforeCol for the column's left edge or afterCol for the column's right edge.
-- Omit toRow to extend to the last rendered row in that table.
-- Example: ColumnBorder({ beforeCol = "a", fromRow = 1, style = "solid1" })
-- Example: ColumnBorder({ afterCol = "g", fromRow = 1, style = "solid3" })
local function ColumnBorder(definition)
    definition = definition or {}
    local rule = BorderRuleBase(definition, "columnBorder")
    rule.beforeCol = definition.beforeCol
    rule.afterCol = definition.afterCol
    rule.fromRow = definition.fromRow
    rule.toRow = definition.toRow
    AddBorderRule(rule)
end

-- BetweenCellsBorder draws the shared edge between two adjacent cells.
-- The coordinates must be side-by-side or stacked in the same table.
-- Example: BetweenCellsBorder({ fromCoord = "b17", toCoord = "c17", style = "dashed" })
local function BetweenCellsBorder(definition)
    definition = definition or {}
    local rule = BorderRuleBase(definition, "betweenCellsBorder")
    rule.fromCoord = definition.fromCoord or definition.from or definition[1]
    rule.toCoord = definition.toCoord or definition.to or definition[2]
    AddBorderRule(rule)
end

NS.DataAPI = {
    Table = Table,
    Block = Block,
    Cell = Cell,
    MergedCell = MergedCell,
    RowBorders = RowBorders,
    ColumnBorders = ColumnBorders,
    TableBorder = TableBorder,
    RowBorder = RowBorder,
    ColumnBorder = ColumnBorder,
    BetweenCellsBorder = BetweenCellsBorder,
}

NS.Data = {
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
