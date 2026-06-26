local ADDON_NAME, NS = ...

local UI = NS.UI
local Coordinates = NS.Coordinates
local Metrics = UI.Metrics
local Layers = UI.Layers
local TableGeometry = UI.TableGeometry
local TableLayout = {}
UI.TableLayout = TableLayout

local ParseCoord = Coordinates.ParseCoord
local NormalizeCellSpan = Coordinates.NormalizeCellSpan

local function IncludeInferredBodyRow(bounds, row)
    row = tonumber(row)
    if not row or row < 2 then
        return
    end

    if not bounds.last or row > bounds.last then
        bounds.last = row
    end
end

local function IncludeInferredCoord(bounds, coord)
    local _, row = ParseCoord(coord)
    IncludeInferredBodyRow(bounds, row)
end

local function IncludeInferredCoordRange(bounds, startCoord, endCoord, range)
    local span = NormalizeCellSpan(nil, nil, range)
    if span then
        IncludeInferredBodyRow(bounds, span.fromRow)
        IncludeInferredBodyRow(bounds, span.toRow)
        return
    end

    local _, startRow = ParseCoord(startCoord)
    local _, endRow = ParseCoord(endCoord or startCoord)
    IncludeInferredBodyRow(bounds, startRow)
    IncludeInferredBodyRow(bounds, endRow)
end

local function InferTableBodyRowRange(tableDefinition)
    local tableKey = tableDefinition.key
    local bounds = {}

    for coord in pairs((NS.Data.cells and NS.Data.cells[tableKey]) or {}) do
        IncludeInferredCoord(bounds, coord)
    end

    for _, mergedCell in ipairs(NS.Data.mergedCells or {}) do
        if mergedCell.table == tableKey then
            IncludeInferredCoordRange(bounds, mergedCell.startCoord, mergedCell.endCoord, mergedCell.span)
        end
    end

    for _, block in ipairs(NS.Data.colorBlocks or {}) do
        if block.table == tableKey then
            for _, coord in ipairs(block.cells or {}) do
                IncludeInferredCoord(bounds, coord)
            end
        end
    end

    if bounds.last then
        return 2, bounds.last
    end

    return nil, nil
end

local function AddBodyRowRange(firstRow, lastRow, addRow)
    firstRow = tonumber(firstRow)
    lastRow = tonumber(lastRow)
    if not firstRow or not lastRow then
        return
    end

    if firstRow > lastRow then
        firstRow, lastRow = lastRow, firstRow
    end

    for row = firstRow, lastRow do
        addRow({ row = row })
    end
end

local function BuildTableBodyRows(tableDefinition, addRow)
    if tableDefinition.rows then
        for _, rowDefinition in ipairs(tableDefinition.rows) do
            if type(rowDefinition) == "table" then
                addRow(rowDefinition)
            else
                addRow({ row = rowDefinition })
            end
        end
        return
    end

    if tableDefinition.rowGroups then
        for groupIndex, groupDefinition in ipairs(tableDefinition.rowGroups) do
            if groupIndex > 1 then
                addRow({ marginRows = groupDefinition.marginTop or 0 })
            end
            for row = groupDefinition.firstRow, groupDefinition.lastRow do
                addRow({ row = row })
            end
        end
        return
    end

    local firstRow, lastRow = InferTableBodyRowRange(tableDefinition)
    if firstRow and lastRow then
        AddBodyRowRange(firstRow, lastRow, addRow)
        return
    end

    local rowCount = tonumber(tableDefinition.rowCount)
    if rowCount then
        AddBodyRowRange(2, 2 + rowCount - 1, addRow)
    end
end

local function CollectTableBodyRows(tableDefinition)
    local rows = {}
    BuildTableBodyRows(tableDefinition, function(rowDefinition)
        rows[#rows + 1] = rowDefinition
    end)
    return rows
end

local function CountVisualRows(rows)
    local count = 0
    for _, rowDefinition in ipairs(rows or {}) do
        if rowDefinition.marginRows then
            count = count + (tonumber(rowDefinition.marginRows) or 0)
        else
            count = count + 1
        end
    end

    return count
end

local function BuildBodyRowLayout(rows)
    local layout = {
        byRow = {},
        totalRows = 0,
    }
    local visualRowIndex = 0

    for _, rowDefinition in ipairs(rows or {}) do
        if rowDefinition.marginRows then
            visualRowIndex = visualRowIndex + (tonumber(rowDefinition.marginRows) or 0)
        else
            local row = tonumber(rowDefinition.row)
            if row then
                layout.byRow[row] = {
                    visualIndex = visualRowIndex,
                    y = visualRowIndex * Metrics.rowHeight,
                    definition = rowDefinition,
                }
            end
            visualRowIndex = visualRowIndex + 1
        end
    end

    layout.totalRows = visualRowIndex
    return layout
end

local function DisplayedBodyRows(tableDefinition, totalRows)
    local displayedRows = tonumber(tableDefinition.displayedRows)
    if not displayedRows or displayedRows < 1 then
        return totalRows
    end

    return math.min(totalRows, math.floor(displayedRows))
end

function TableLayout.Measure(tableDefinition)
    if not tableDefinition or not tableDefinition.key then
        return nil
    end

    local rows = CollectTableBodyRows(tableDefinition)
    local rowLayout = BuildBodyRowLayout(rows)
    local totalRows = rowLayout.totalRows or CountVisualRows(rows)
    local visibleRows = totalRows > 0 and DisplayedBodyRows(tableDefinition, totalRows) or 0

    return {
        key = tableDefinition.key,
        rows = rows,
        rowLayout = rowLayout,
        totalRows = totalRows,
        visibleRows = visibleRows,
        x = tableDefinition.x or 0,
        y = tableDefinition.y or 0,
        width = TableGeometry.TableWidth(tableDefinition),
        height = Metrics.headerHeight + (visibleRows * Metrics.rowHeight),
    }
end

function TableLayout.TableInLayout(tableDefinition, layoutDefinition)
    if not tableDefinition or not tableDefinition.key then
        return false
    end

    if layoutDefinition and type(layoutDefinition.tables) == "table" then
        for _, tableKey in pairs(layoutDefinition.tables) do
            if tableDefinition.key == tableKey then
                return true
            end
        end

        return false
    end

    local layoutKey = layoutDefinition and layoutDefinition.key
    local tableLayout = tableDefinition.layout
    return not tableLayout or not layoutKey or tableLayout == layoutKey
end

function TableLayout.MeasureByKey(tableKey)
    local tableDefinition = type(tableKey) == "table" and tableKey or NS.Data and NS.Data.tables and NS.Data.tables[tableKey]
    return TableLayout.Measure(tableDefinition)
end

function TableLayout.GetLayoutDefinition(layerSetKey)
    local layoutKey = Layers.LayerSetLayoutKey(layerSetKey)
    return layoutKey and NS.Data and NS.Data.layouts and NS.Data.layouts[layoutKey] or nil
end

function TableLayout.NormalizeBounds(layouts, layoutDefinition)
    local minX
    local minY
    local maxX
    local maxY

    for _, tableDefinition in ipairs(NS.Data.tableOrder or {}) do
        local tableKey = tableDefinition and tableDefinition.key
        local layout = tableKey and layouts[tableKey]
        if layout and TableLayout.TableInLayout(tableDefinition, layoutDefinition) then
            local x = layout.x or 0
            local y = layout.y or 0
            local right = x + (layout.width or 0)
            local bottom = y + (layout.height or 0)

            minX = minX and math.min(minX, x) or x
            minY = minY and math.min(minY, y) or y
            maxX = maxX and math.max(maxX, right) or right
            maxY = maxY and math.max(maxY, bottom) or bottom
        end
    end

    if not minX then
        layouts.bounds = { x = 0, y = 0, width = 1, height = 1 }
        return layouts
    end

    for _, tableDefinition in ipairs(NS.Data.tableOrder or {}) do
        local tableKey = tableDefinition and tableDefinition.key
        local layout = tableKey and layouts[tableKey]
        if layout and TableLayout.TableInLayout(tableDefinition, layoutDefinition) then
            layout.x = (layout.x or 0) - minX
            layout.y = (layout.y or 0) - minY
        end
    end

    layouts.bounds = {
        x = 0,
        y = 0,
        width = math.max(1, (maxX or minX) - minX),
        height = math.max(1, (maxY or minY) - minY),
    }
    return layouts
end

function TableLayout.Build()
    local layerSetKey = Layers.GetActiveLayerSetKey()
    local layoutDefinition = TableLayout.GetLayoutDefinition(layerSetKey)
    local layouts = {}
    local function measure(tableKey)
        return TableLayout.MeasureByKey(tableKey)
    end

    if layoutDefinition and type(layoutDefinition.apply) == "function" then
        local appliedLayouts = layoutDefinition.apply(layouts, measure, {
            headerHeight = Metrics.headerHeight,
            rowHeight = Metrics.rowHeight,
        })
        if type(appliedLayouts) == "table" then
            layouts = appliedLayouts
        end
    end

    if layoutDefinition and type(layoutDefinition.tables) == "table" then
        for _, tableKey in pairs(layoutDefinition.tables) do
            if tableKey and not layouts[tableKey] then
                layouts[tableKey] = TableLayout.MeasureByKey(tableKey)
            end
        end
    else
        for _, tableDefinition in ipairs(NS.Data.tableOrder or {}) do
            local tableKey = tableDefinition and tableDefinition.key
            if tableKey and TableLayout.TableInLayout(tableDefinition, layoutDefinition) and not layouts[tableKey] then
                layouts[tableKey] = TableLayout.Measure(tableDefinition)
            end
        end
    end

    return TableLayout.NormalizeBounds(layouts, layoutDefinition)
end

TableLayout.CollectBodyRows = CollectTableBodyRows
TableLayout.CountVisualRows = CountVisualRows
TableLayout.BuildBodyRowLayout = BuildBodyRowLayout
TableLayout.DisplayedBodyRows = DisplayedBodyRows
UI.BuildTableLayout = function()
    return TableLayout.Build()
end
