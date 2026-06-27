local ADDON_NAME, NS = ...

local Helpers = NS.Helpers
local Coordinates = NS.Coordinates
local CellCoordinate = Coordinates.CellCoordinate
local NormalizeCellRange = Coordinates.NormalizeCellRange

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
local layerSetOrder = {}
local layerSetsByKey = {}
local layerSetByLayerKey = {}
local defaultActiveLayers = {}
local layoutOrder = {}
local layoutsByKey = {}
local layerOrder = {}
local layersByKey = {}
local blocks = {}
local cellsByTable = {}
local cellRecordsByTable = {}
local cellRecordOrder = 0
local colorBlocks = {}
local mergedCells = {}
local borderRules = {}

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
        return Helpers.ShallowCopy(definition.font)
    end

    return nil
end

local function MergeFontStyles(defaultDefinition, overrideDefinition)
    local defaultFont = CopyFontStyle(defaultDefinition)
    local overrideFont = CopyFontStyle(overrideDefinition)
    if not defaultFont and not overrideFont then
        return nil
    end

    return Helpers.ShallowMerge(defaultFont, overrideFont)
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

local function SetDefaultActiveLayer(layerSetKey, layerKey)
    if not layerKey then
        return
    end

    if layerSetKey then
        defaultActiveLayers[layerSetKey] = layerKey
    end

    if not layerSetKey or layerSetKey == NS.DataDefaultLayerSet then
        NS.DataDefaultActiveLayer = layerKey
    end
    if NS.Data then
        NS.Data.defaultActiveLayer = NS.DataDefaultActiveLayer
        NS.Data.defaultActiveLayers = defaultActiveLayers
    end
end

local function Layer(definition)
    if not definition then
        return nil
    end

    local key = definition.key or definition.id
    if not key then
        return nil
    end

    definition.key = key
    definition.id = definition.id or key
    definition.layerSet = definition.layerSet or definition.set
    definition.order = tonumber(definition.order) or (#layerOrder + 1)
    if definition.inactiveAlpha == nil then
        definition.inactiveAlpha = 0.3
    end
    if definition.activeAlpha == nil then
        definition.activeAlpha = 1
    end

    if not layersByKey[key] then
        layerOrder[#layerOrder + 1] = definition
    end

    layersByKey[key] = definition
    if definition.layerSet then
        layerSetByLayerKey[key] = definition.layerSet
        local layerSet = layerSetsByKey[definition.layerSet]
        if layerSet then
            layerSet.layers = layerSet.layers or {}
            layerSet.layerOrder = layerSet.layerOrder or {}
            if not layerSet.layers[key] then
                layerSet.layerOrder[#layerSet.layerOrder + 1] = definition
            end
            layerSet.layers[key] = definition
            if definition.active or definition.defaultActive then
                layerSet.defaultLayer = key
            end
        end
    end
    if definition.active or definition.defaultActive then
        SetDefaultActiveLayer(definition.layerSet, key)
    end

    return definition
end

local function LayerSet(definition)
    if not definition then
        return nil
    end

    local key = definition.key or definition.id
    if not key then
        return nil
    end

    local layerDefinitions = definition.layers or {}
    definition.key = key
    definition.id = definition.id or key
    definition.order = tonumber(definition.order) or (#layerSetOrder + 1)
    definition.defaultLayer = definition.defaultLayer or definition.activeLayer or definition.default
    definition.layout = definition.layout or definition.layoutKey
    definition.layers = {}
    definition.layerOrder = {}

    if not layerSetsByKey[key] then
        layerSetOrder[#layerSetOrder + 1] = definition
    end

    layerSetsByKey[key] = definition
    if not NS.DataDefaultLayerSet or definition.active or definition.defaultActive then
        NS.DataDefaultLayerSet = key
    end

    for layerIndex, layerDefinition in ipairs(layerDefinitions) do
        layerDefinition.layerSet = layerDefinition.layerSet or key
        layerDefinition.order = tonumber(layerDefinition.order) or layerIndex
        local layer = Layer(layerDefinition)
        if layer and (layer.active or layer.defaultActive) then
            definition.defaultLayer = layer.key
        end
    end

    if not definition.defaultLayer and definition.layerOrder[1] then
        definition.defaultLayer = definition.layerOrder[1].key
    end

    if definition.defaultLayer then
        SetDefaultActiveLayer(key, definition.defaultLayer)
    end

    if NS.Data then
        NS.Data.defaultLayerSet = NS.DataDefaultLayerSet
        NS.Data.defaultActiveLayers = defaultActiveLayers
    end

    return definition
end

local function Layout(definition)
    if not definition then
        return nil
    end

    local key = definition.key or definition.id
    if not key then
        return nil
    end

    definition.key = key
    definition.id = definition.id or key
    definition.order = tonumber(definition.order) or (#layoutOrder + 1)

    if not layoutsByKey[key] then
        layoutOrder[#layoutOrder + 1] = definition
    end

    layoutsByKey[key] = definition
    if not NS.DataDefaultLayout or definition.active or definition.defaultActive then
        NS.DataDefaultLayout = key
    end

    if NS.Data then
        NS.Data.defaultLayout = NS.DataDefaultLayout
        NS.Data.layoutOrder = layoutOrder
        NS.Data.layouts = layoutsByKey
    end

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

    cellRecordOrder = cellRecordOrder + 1
    cellsByTable[tableKey] = cellsByTable[tableKey] or {}
    local cellRecord = {
        kind = "cell",
        table = tableKey,
        coord = cellCoordinate,
        text = cellDefinition.text or "",
        atlas = cellDefinition.atlas,
        bg = cellDefinition.bg,
        layer = cellDefinition.layer or blockDefinition.layer,
        sourceLayer = cellDefinition.layer or blockDefinition.layer,
        tooltip = cellDefinition.tooltip or blockDefinition.tooltip,
        colTitle = cellDefinition.title,
        bold = ValueOrDefault(cellDefinition.bold, blockDefinition.bold),
        font = MergeFontStyles(blockDefinition, cellDefinition),
        border = cellDefinition.border,
        onClick = cellDefinition.onClick,
        order = cellRecordOrder,
    }

    cellsByTable[tableKey][cellCoordinate] = cellRecord
    cellRecordsByTable[tableKey] = cellRecordsByTable[tableKey] or {}
    cellRecordsByTable[tableKey][cellCoordinate] = cellRecordsByTable[tableKey][cellCoordinate] or {}
    local records = cellRecordsByTable[tableKey][cellCoordinate]
    records[#records + 1] = cellRecord

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

    cellRecordOrder = cellRecordOrder + 1
    local mergedCell = {
        kind = "mergedCell",
        table = tableKey,
        coord = span.fromCoord,
        startCoord = span.fromCoord,
        endCoord = span.toCoord,
        span = span,
        text = cellDefinition.text or "",
        atlas = cellDefinition.atlas,
        bg = cellDefinition.bg,
        layer = cellDefinition.layer or blockDefinition.layer,
        sourceLayer = cellDefinition.layer or blockDefinition.layer,
        tooltip = cellDefinition.tooltip or blockDefinition.tooltip or DefaultTooltip(cellDefinition.text),
        colTitle = cellDefinition.title,
        bold = ValueOrDefault(cellDefinition.bold, blockDefinition.bold),
        vertical = cellDefinition.vertical == true,
        font = MergeFontStyles(blockDefinition, cellDefinition),
        border = cellDefinition.border,
        onClick = cellDefinition.onClick,
        order = cellRecordOrder,
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
                    layer = cellDefinition.layer or definition.layer,
                    border = cellDefinition.border or definition.border or "solid1",
                    innerBorder = cellDefinition.innerBorder,
                    innerRowBorder = cellDefinition.innerRowBorder,
                    innerColBorder = cellDefinition.innerColBorder,
                    parentInnerBorder = cellDefinition.parentInnerBorder or definition.innerBorder,
                    parentInnerRowBorder = cellDefinition.parentInnerRowBorder or definition.innerRowBorder,
                    parentInnerColBorder = cellDefinition.parentInnerColBorder or definition.innerColBorder,
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
            layer = definition.layer,
            border = definition.border or "solid1",
            innerBorder = definition.innerBorder,
            innerRowBorder = definition.innerRowBorder,
            innerColBorder = definition.innerColBorder,
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
    Layout = Layout,
    LayerSet = LayerSet,
    Layer = Layer,
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
    layerSetOrder = layerSetOrder,
    layerSets = layerSetsByKey,
    layerSetByLayerKey = layerSetByLayerKey,
    layoutOrder = layoutOrder,
    layouts = layoutsByKey,
    defaultLayout = NS.DataDefaultLayout,
    layerOrder = layerOrder,
    layers = layersByKey,
    defaultLayerSet = NS.DataDefaultLayerSet,
    defaultActiveLayer = NS.DataDefaultActiveLayer,
    defaultActiveLayers = defaultActiveLayers,
    blocks = blocks,
    cells = cellsByTable,
    cellRecords = cellRecordsByTable,
    colorBlocks = colorBlocks,
    mergedCells = mergedCells,
    borderRules = borderRules,
    LayerKeys = {},
    footerLeft = "LootLevel - by Yvairel <Party Shark> <Suds with Buds>",
    footerRight = "1 Once a Week | VF: Venomforged | GV: Great Vault",
}
