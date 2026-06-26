local ADDON_NAME, NS = ...

local UI = NS.UI
local Coordinates = NS.Coordinates
local Metrics = UI.Metrics
local Cells = UI.Cells
local BodyScroll = UI.BodyScroll
local Borders = UI.Borders
local Layers = UI.Layers
local LayerResolver = UI.LayerResolver
local TableGeometry = UI.TableGeometry
local TableLayout = UI.TableLayout
local TableRenderer = {}
UI.TableRenderer = TableRenderer

local ColumnIndex = Coordinates.ColumnIndex

local function BuildDataTableHeader(parent, tableDefinition, x, y)
    local tableKey = tableDefinition.key
    for _, headerDefinition in ipairs(tableDefinition.headers or {}) do
        local fromColumnIndex = TableGeometry.TableColumnIndex(tableDefinition, headerDefinition.fromCol or headerDefinition.col)
        local toColumnIndex = TableGeometry.TableColumnIndex(tableDefinition, headerDefinition.toCol or headerDefinition.fromCol or headerDefinition.col)
        if fromColumnIndex and toColumnIndex then
            if fromColumnIndex > toColumnIndex then
                fromColumnIndex, toColumnIndex = toColumnIndex, fromColumnIndex
            end

            local headerX = TableGeometry.TableColumnX(tableDefinition, x, fromColumnIndex)
            local width = TableGeometry.TableColumnWidth(tableDefinition, fromColumnIndex, toColumnIndex)
            local coord = headerDefinition.coord or TableGeometry.ColumnCoord(tableDefinition.columns[fromColumnIndex], fromColumnIndex, 1)
            local fromGridColumn = ColumnIndex(TableGeometry.ColumnKey(tableDefinition.columns[fromColumnIndex], fromColumnIndex))
            local toGridColumn = ColumnIndex(TableGeometry.ColumnKey(tableDefinition.columns[toColumnIndex], toColumnIndex))
            Cells.CreateHeader(parent, headerX, y, width, Metrics.headerHeight, headerDefinition.text or "", {
                table = tableKey,
                coord = coord,
                gridFromColumn = fromGridColumn,
                gridToColumn = toGridColumn,
                tooltip = headerDefinition.tooltip or { title = headerDefinition.text or tableDefinition.name },
                colTitle = headerDefinition.title or headerDefinition.text or tableDefinition.name,
            })
        end
    end
end

local function BuildDataTableRow(parent, tableDefinition, rowDefinition, x, y, rowLayout, spanMap, ownership)
    local tableKey = tableDefinition.key
    local colX = x
    for columnIndex, columnDefinition in ipairs(tableDefinition.columns or {}) do
        local coord = TableGeometry.ColumnCoord(columnDefinition, columnIndex, rowDefinition.row)
        local spanRecord = spanMap and spanMap[coord]
        if not spanRecord or spanRecord.anchorCoord == coord then
            local data = spanRecord and spanRecord.cellData or Cells.GetConfiguredData(tableKey, coord, ownership) or {}
            local columnTitle = columnDefinition.title or TableGeometry.ColumnKey(columnDefinition, columnIndex)
            local width = columnDefinition.width
            local height = Metrics.rowHeight

            if spanRecord then
                width = TableGeometry.TableColumnWidth(tableDefinition, spanRecord.fromColumnIndex, spanRecord.toColumnIndex)
                height = spanRecord.height or TableGeometry.SpanVisualHeight(spanRecord.span, rowLayout)
            end

            Cells.Create(parent, colX, y, width, height, Cells.MergeData({
                table = tableKey,
                coord = coord,
                text = data.text or "",
                defaultBg = columnDefinition.bg or "blank",
                bold = columnDefinition.bold,
                tooltip = data.tooltip or { title = TableGeometry.FormatDefaultCellTitle(tableDefinition, columnDefinition, rowDefinition) },
                colTitle = columnTitle,
            }, data))
        end
        colX = colX + columnDefinition.width
    end
end

local function BuildDataTableRows(parent, tableDefinition, rows, x, y, rowLayout, spanMap, ownership)
    local visualRowIndex = 0
    for _, rowDefinition in ipairs(rows or {}) do
        if rowDefinition.marginRows then
            visualRowIndex = visualRowIndex + (tonumber(rowDefinition.marginRows) or 0)
        else
            BuildDataTableRow(parent, tableDefinition, rowDefinition, x, y + (visualRowIndex * Metrics.rowHeight), rowLayout, spanMap, ownership)
            visualRowIndex = visualRowIndex + 1
        end
    end
end

local function BuildDataTableBodyBackdrop(parent, tableDefinition, height)
    local x = 0
    for _, columnDefinition in ipairs(tableDefinition.columns or {}) do
        local backdrop = parent:CreateTexture(nil, "BACKGROUND")
        UI.ApplyTexturePixelSnapping(backdrop)
        backdrop:SetColorTexture(UI.Color(columnDefinition.bg or tableDefinition.bodyBg or tableDefinition.bg or "blank"))
        UI.SetLayoutBounds(backdrop, parent, x, 0, columnDefinition.width, height)
        x = x + columnDefinition.width
    end
end

local function BuildDataTable(parent, tableDefinition, layout)
    if not tableDefinition or not tableDefinition.key then
        return
    end

    local tableKey = tableDefinition.key
    layout = layout or TableLayout.Measure(tableDefinition)
    local x = layout and layout.x or tableDefinition.x or 0
    local y = layout and layout.y or tableDefinition.y or 0
    local rows = layout and layout.rows or TableLayout.CollectBodyRows(tableDefinition)
    local rowLayout = layout and layout.rowLayout or TableLayout.BuildBodyRowLayout(rows)
    local totalRows = layout and layout.totalRows or rowLayout.totalRows or TableLayout.CountVisualRows(rows)
    if totalRows <= 0 then
        BuildDataTableHeader(parent, tableDefinition, x, y)
        return
    end

    BuildDataTableHeader(parent, tableDefinition, x, y)

    local visibleRows = layout and layout.visibleRows or TableLayout.DisplayedBodyRows(tableDefinition, totalRows)
    local tableWidth = TableGeometry.TableWidth(tableDefinition)
    local ownership = LayerResolver and LayerResolver.BuildTableOwnership(tableKey) or nil
    local spanMap = TableGeometry.BuildTableSpanMap(tableDefinition, rowLayout, ownership)
    local bodyScroll, bodyContent = BodyScroll.Create(parent, tableDefinition, x, y + Metrics.headerHeight, tableWidth, visibleRows, totalRows)
    bodyScroll.bodyRowLayout = rowLayout
    BuildDataTableBodyBackdrop(bodyContent, tableDefinition, math.max(1, totalRows * Metrics.rowHeight))
    BuildDataTableRows(bodyContent, tableDefinition, rows, 0, 0, rowLayout, spanMap, ownership)
    UI.DrawGridLines(bodyContent)
    Borders.DrawTableBodyViewportBorder(bodyScroll, tableDefinition, tableWidth, visibleRows)
    BodyScroll.Clamp(bodyScroll)
end

local function BuildRegisteredTables(parent, layouts)
    layouts = layouts or TableLayout.Build()
    local activeLayerSet = Layers.GetActiveLayerSetKey()
    local layoutDefinition = TableLayout.GetLayoutDefinition(activeLayerSet)
    for _, tableDefinition in ipairs(NS.Data.tableOrder or {}) do
        if TableLayout.TableInLayout(tableDefinition, layoutDefinition) then
            BuildDataTable(parent, tableDefinition, layouts[tableDefinition.key])
        end
    end
end

local function BuildTablePlaceholders(parent, layouts)
    if not parent then
        return
    end

    parent.placeholders = parent.placeholders or {}
    for _, placeholder in ipairs(parent.placeholders) do
        placeholder:Hide()
    end

    layouts = layouts or TableLayout.Build()
    local activeLayerSet = Layers.GetActiveLayerSetKey()
    local layoutDefinition = TableLayout.GetLayoutDefinition(activeLayerSet)
    local index = 0
    for _, tableDefinition in ipairs(NS.Data.tableOrder or {}) do
        if tableDefinition and tableDefinition.key and TableLayout.TableInLayout(tableDefinition, layoutDefinition) then
            index = index + 1

            local placeholder = parent.placeholders[index]
            if not placeholder then
                placeholder = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
                if placeholder.SetBackdrop then
                    placeholder:SetBackdrop(UI.FrameBackdrop)
                    placeholder:SetBackdropColor(0.18, 0.18, 0.18, 0.34)
                    placeholder:SetBackdropBorderColor(0.42, 0.42, 0.42, 0.85)
                end

                local header = placeholder:CreateTexture(nil, "ARTWORK")
                UI.ApplyTexturePixelSnapping(header)
                header:SetColorTexture(0.78, 0.78, 0.78, 0.28)
                placeholder.header = header

                parent.placeholders[index] = placeholder
            end

            local layout = layouts[tableDefinition.key] or TableLayout.Measure(tableDefinition)
            local x = layout.x or tableDefinition.x or 0
            local y = layout.y or tableDefinition.y or 0
            local width = layout.width or TableGeometry.TableWidth(tableDefinition)
            local height = layout.height or Metrics.headerHeight

            UI.SetLayoutBounds(placeholder, parent, x, y, width, height)
            if not placeholder.headerLayoutRegistered then
                UI.SetLayoutPoints(placeholder.header, {
                    { point = "TOPLEFT", relativeTo = placeholder, relativePoint = "TOPLEFT", x = 1, y = -1 },
                    { point = "TOPRIGHT", relativeTo = placeholder, relativePoint = "TOPRIGHT", x = -1, y = -1 },
                }, nil, Metrics.headerHeight - 2)
                placeholder.headerLayoutRegistered = true
            end
            placeholder:Show()
        end
    end
end

TableRenderer.BuildHeader = BuildDataTableHeader
TableRenderer.BuildRow = BuildDataTableRow
TableRenderer.BuildRows = BuildDataTableRows
TableRenderer.BuildBodyBackdrop = BuildDataTableBodyBackdrop
TableRenderer.BuildTable = BuildDataTable
TableRenderer.BuildRegisteredTables = BuildRegisteredTables
TableRenderer.BuildPlaceholders = BuildTablePlaceholders
UI.BuildRegisteredTables = BuildRegisteredTables
UI.BuildTablePlaceholders = BuildTablePlaceholders
