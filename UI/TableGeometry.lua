local ADDON_NAME, NS = ...

local UI = NS.UI
local Helpers = NS.Helpers
local Coordinates = NS.Coordinates
local Metrics = UI.Metrics
local Layers = UI.Layers
local LayerResolver = UI.LayerResolver
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

local function CopyMergedCellForSpan(mergedCell, span)
    local copy = Helpers.ShallowCopy(mergedCell) or {}
    copy.coord = CoordFromIndex(span.fromColumn, span.fromRow)
    copy.startCoord = copy.coord
    copy.endCoord = CoordFromIndex(span.toColumn, span.toRow)
    copy.span = span
    copy.fragmentOf = mergedCell
    return copy
end

local function IsMultiCellSpan(span)
    return span and (span.fromColumn ~= span.toColumn or span.fromRow ~= span.toRow)
end

local function ShouldRenderInactiveSpanAsBackgroundCells(mergedCell)
    return mergedCell
        and mergedCell.layer
        and not Layers.IsLayerActive(mergedCell.layer)
        and IsMultiCellSpan(mergedCell.span)
end

local function CopyMergedCellAsBackgroundCell(mergedCell, span)
    local copy = CopyMergedCellForSpan(mergedCell, span)
    copy.text = ""
    copy.atlas = nil
    copy.vertical = false
    copy.backgroundOnly = true
    return copy
end

local function BuildTableSpanMap(tableDefinition, rowLayout, ownership)
    local tableKey = tableDefinition.key
    local spanMap = {}
    ownership = ownership or (LayerResolver and LayerResolver.BuildTableOwnership(tableKey))

    for _, mergedCell in ipairs(NS.Data.mergedCells or {}) do
        if mergedCell.table == tableKey and Layers.IsLayerVisible(mergedCell.layer) then
            local useBackgroundCells = ShouldRenderInactiveSpanAsBackgroundCells(mergedCell)
            local fragments
            if useBackgroundCells and LayerResolver then
                fragments = LayerResolver.OwnedSingleCellFragments(mergedCell, ownership)
            else
                fragments = LayerResolver and LayerResolver.OwnedSpanFragments(mergedCell, ownership)
                    or { NormalizeCellSpan(nil, nil, mergedCell.span) }
            end

            for _, span in ipairs(fragments or {}) do
                local anchorCoord = span and CoordFromIndex(span.fromColumn, span.fromRow)
                local fromColumnIndex, toColumnIndex = SpanTableColumnRange(tableDefinition, span)
                if span and anchorCoord and fromColumnIndex and toColumnIndex then
                    local isFullSpan = mergedCell.span
                        and span.fromColumn == mergedCell.span.fromColumn
                        and span.toColumn == mergedCell.span.toColumn
                        and span.fromRow == mergedCell.span.fromRow
                        and span.toRow == mergedCell.span.toRow
                    local cellData
                    if useBackgroundCells then
                        cellData = CopyMergedCellAsBackgroundCell(mergedCell, span)
                    else
                        cellData = isFullSpan and mergedCell or CopyMergedCellForSpan(mergedCell, span)
                    end
                    local record = {
                        anchorCoord = anchorCoord,
                        cellData = cellData,
                        span = span,
                        fromColumnIndex = fromColumnIndex,
                        toColumnIndex = toColumnIndex,
                        height = SpanVisualHeight(span, rowLayout),
                    }
                    ForEachCellSpanCoord(span, function(_, _, coord)
                        spanMap[coord] = record
                    end)
                end
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
