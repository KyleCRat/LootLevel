local ADDON_NAME, NS = ...

local UI = NS.UI
local Coordinates = NS.Coordinates
local Metrics = UI.Metrics
local Layers = UI.Layers
local Borders = UI.Borders
local TableGeometry = {}
UI.TableGeometry = TableGeometry

local ColumnName = Coordinates.ColumnName
local ColumnIndex = Coordinates.ColumnIndex
local CoordFromIndex = Coordinates.CoordFromIndex
local NormalizeCellSpan = Coordinates.NormalizeCellSpan
local ForEachCellSpanCoord = Coordinates.ForEachCellSpanCoord

local function ColumnKey(columnDefinition, fallbackIndex)
    return columnDefinition.col or ColumnName(columnDefinition.index or fallbackIndex)
end

local function ColumnCoord(columnDefinition, fallbackIndex, rowIndex)
    local columnKey = ColumnKey(columnDefinition, fallbackIndex)
    if not columnKey or not rowIndex then
        return nil
    end

    return ("%s%d"):format(columnKey, rowIndex)
end

local function TableColumnIndex(tableDefinition, columnKey)
    local requestedIndex = ColumnIndex(columnKey)
    for index, columnDefinition in ipairs(tableDefinition.columns or {}) do
        if ColumnIndex(ColumnKey(columnDefinition, index)) == requestedIndex then
            return index
        end
    end

    return nil
end

local function TableColumnX(tableDefinition, tableX, columnIndex)
    local x = tableX
    for index = 1, columnIndex - 1 do
        local columnDefinition = tableDefinition.columns[index]
        x = x + (columnDefinition and columnDefinition.width or 0)
    end

    return x
end

local function TableColumnWidth(tableDefinition, fromColumnIndex, toColumnIndex)
    local width = 0
    for index = fromColumnIndex, toColumnIndex do
        local columnDefinition = tableDefinition.columns[index]
        width = width + (columnDefinition and columnDefinition.width or 0)
    end

    return width
end

local function TableWidth(tableDefinition)
    return TableColumnWidth(tableDefinition, 1, #(tableDefinition.columns or {}))
end

local function TableColumnIndexByGridColumn(tableDefinition, gridColumn)
    return TableColumnIndex(tableDefinition, ColumnName(gridColumn))
end

local function SpanTableColumnRange(tableDefinition, span)
    local fromColumnIndex = TableColumnIndexByGridColumn(tableDefinition, span and span.fromColumn)
    local toColumnIndex = TableColumnIndexByGridColumn(tableDefinition, span and span.toColumn)
    if not fromColumnIndex or not toColumnIndex then
        return nil, nil
    end

    if fromColumnIndex > toColumnIndex then
        fromColumnIndex, toColumnIndex = toColumnIndex, fromColumnIndex
    end

    return fromColumnIndex, toColumnIndex
end

local function SpanVisualHeight(span, rowLayout)
    if not span then
        return Metrics.rowHeight
    end

    local byRow = rowLayout and rowLayout.byRow
    local startRow = byRow and byRow[span.fromRow]
    local endRow = byRow and byRow[span.toRow]
    if not startRow or not endRow then
        return Metrics.rowHeight
    end

    return math.max(1, ((endRow.visualIndex - startRow.visualIndex) + 1) * Metrics.rowHeight)
end

local function BuildTableSpanMap(tableDefinition, rowLayout)
    local tableKey = tableDefinition.key
    local spanMap = {}

    for _, mergedCell in ipairs(NS.Data.mergedCells or {}) do
        if mergedCell.table == tableKey and Layers.IsLayerVisible(mergedCell.layer) then
            local span = NormalizeCellSpan(nil, nil, mergedCell.span)
            local anchorCoord = span and CoordFromIndex(span.fromColumn, span.fromRow)
            local fromColumnIndex, toColumnIndex = SpanTableColumnRange(tableDefinition, span)
            if span and anchorCoord and fromColumnIndex and toColumnIndex then
                local record = {
                    anchorCoord = anchorCoord,
                    cellData = mergedCell,
                    span = span,
                    fromColumnIndex = fromColumnIndex,
                    toColumnIndex = toColumnIndex,
                    height = SpanVisualHeight(span, rowLayout),
                }
                ForEachCellSpanCoord(span, function(_, _, coord)
                    local existing = spanMap[coord] and spanMap[coord].cellData
                    if Borders.BlockWinsOver(existing, mergedCell) then
                        spanMap[coord] = record
                    end
                end)
            end
        end
    end

    return spanMap
end

local function FormatDefaultCellTitle(tableDefinition, columnDefinition, rowDefinition)
    local columnTitle = columnDefinition.title or ColumnKey(columnDefinition)
    if columnDefinition.tooltip and columnDefinition.tooltip.title then
        return columnDefinition.tooltip.title
    end
    if tableDefinition.tooltip and tableDefinition.tooltip.title then
        return tableDefinition.tooltip.title:format(rowDefinition.row, columnTitle)
    end

    return ("%s row %d - %s"):format(tableDefinition.name or tableDefinition.key, rowDefinition.row, columnTitle)
end

TableGeometry.ColumnKey = ColumnKey
TableGeometry.ColumnCoord = ColumnCoord
TableGeometry.TableColumnIndex = TableColumnIndex
TableGeometry.TableColumnX = TableColumnX
TableGeometry.TableColumnWidth = TableColumnWidth
TableGeometry.TableWidth = TableWidth
TableGeometry.TableColumnIndexByGridColumn = TableColumnIndexByGridColumn
TableGeometry.SpanTableColumnRange = SpanTableColumnRange
TableGeometry.SpanVisualHeight = SpanVisualHeight
TableGeometry.BuildTableSpanMap = BuildTableSpanMap
TableGeometry.FormatDefaultCellTitle = FormatDefaultCellTitle
