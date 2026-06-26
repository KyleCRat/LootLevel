local ADDON_NAME, NS = ...

local UI = NS.UI
local Helpers = NS.Helpers
local Coordinates = NS.Coordinates
local BorderPriority = UI.BorderPriority
local StyleLayer = UI.StyleLayer
local Layers = UI.Layers
local CellStyles = UI.CellStyles
local GridLines = UI.GridLines
local Metrics = UI.Metrics
local Borders = {}
UI.Borders = Borders

local ColumnIndex = Coordinates.ColumnIndex
local CoordKey = Coordinates.CoordKey
local NormalizeCoord = Coordinates.NormalizeCoord
local ParseCoord = Coordinates.ParseCoord
local NormalizeCellSpan = Coordinates.NormalizeCellSpan
local ForEachCellSpanCoord = Coordinates.ForEachCellSpanCoord

local function NormalizeBorderStyle(value)
    if value == nil then
        return nil
    end

    if type(value) == "number" then
        value = {
            style = "solid",
            thickness = value,
        }
    end

    if type(value) == "table" and value.style == "none" then
        return {
            style = "none",
            thickness = 0,
            priority = value.priority or BorderPriority.explicitNone,
        }
    end

    local styleName
    local thickness
    local valuePriority
    local priority = BorderPriority.explicit

    if type(value) == "table" then
        styleName = value.style or value.type or value[1]
        thickness = value.thickness or value.width or value.size
        valuePriority = value.priority
    else
        styleName = value
    end

    if type(styleName) ~= "string" then
        return nil
    end

    styleName = string.lower(styleName)
    if styleName == "none" or styleName == "no" or styleName == "hidden" then
        return {
            style = "none",
            thickness = 0,
            priority = BorderPriority.explicitNone,
        }
    end

    local baseStyle, parsedThickness = styleName:match("^(solid)(%d+)$")
    if styleName == "solid" or styleName == "1px" or styleName == "1px solid" then
        styleName = "solid"
        thickness = thickness or 1
    elseif baseStyle then
        styleName = baseStyle
        thickness = thickness or tonumber(parsedThickness)
    elseif styleName == "3px" or styleName == "3px solid" then
        styleName = "solid"
        thickness = thickness or 3
    elseif styleName == "dot" then
        styleName = "dotted"
        thickness = thickness or 1
    elseif styleName == "dash" then
        styleName = "dashed"
        thickness = thickness or 1
    elseif styleName == "dashed" or styleName == "dotted" then
        thickness = thickness or 1
    else
        return nil
    end

    thickness = math.max(1, UI.Pixel(tonumber(thickness) or 1))
    if thickness >= 3 then
        priority = BorderPriority.explicitThick
    end

    return {
        style = styleName,
        thickness = thickness,
        priority = valuePriority or priority,
    }
end

local function CopyBorderStyle(value, priority, order)
    local style = NormalizeBorderStyle(value)
    if not style then
        return nil
    end

    local copy = Helpers.ShallowCopy(style) or {}
    copy.priority = priority or copy.priority or 0
    copy.order = order or copy.order or 0
    return copy
end

local function EnsureGrid(parent, tableKey)
    parent.gridTables = parent.gridTables or {}
    local grid = parent.gridTables[tableKey]
    if not grid then
        grid = {
            rows = {},
            columns = {},
        }
        parent.gridTables[tableKey] = grid
    end
    return grid
end

local function RegisterCellCoordinate(parent, cell, cellData, x, y, width, height)
    local coord = NormalizeCoord(cellData.coord)
    if not coord then
        return
    end

    local tableKey = cellData.table or "main"
    local column, row = ParseCoord(coord)
    if not column or not row then
        return
    end

    local span = NormalizeCellSpan(column, row, cellData.span or cellData)
    if not span then
        return
    end

    parent.cellsByCoord = parent.cellsByCoord or {}
    ForEachCellSpanCoord(span, function(gridColumn, gridRow, spanCoord)
        local key = CoordKey(tableKey, spanCoord)
        parent.cellsByCoord[key] = cell
        cell.gridCoveredCoords = cell.gridCoveredCoords or {}
        cell.gridCoveredCoords[#cell.gridCoveredCoords + 1] = key
    end)

    local grid = EnsureGrid(parent, tableKey)
    local anchorKey = CoordKey(tableKey, coord)
    cell.coordKey = anchorKey
    cell.tableKey = tableKey
    cell.gridTable = tableKey
    cell.gridCoord = coord
    cell.gridLabel = cellData.gridLabel
    cell.gridColumn = column
    cell.gridRow = row
    cell.gridFromColumn = span.fromColumn
    cell.gridToColumn = span.toColumn
    cell.gridFromRow = span.fromRow
    cell.gridToRow = span.toRow
    cell.gridSpan = span
    cell.gridBounds = {
        x = UI.Pixel(x),
        y = UI.Pixel(y),
        width = UI.Pixel(width),
        height = UI.Pixel(height),
    }

    for spanRow = span.fromRow, span.toRow do
        grid.rows[spanRow] = grid.rows[spanRow] or {}
        for spanColumn = span.fromColumn, span.toColumn do
            grid.rows[spanRow][spanColumn] = cell
            grid.columns[spanColumn] = grid.columns[spanColumn] or {}
            grid.columns[spanColumn][spanRow] = cell
        end
    end
end

local function BorderLineKey(line)
    if line.vertical then
        return ("v:%d:%d:%d"):format(UI.Pixel(line.x), UI.Pixel(math.min(line.y1, line.y2)), UI.Pixel(math.max(line.y1, line.y2)))
    end

    return ("h:%d:%d:%d"):format(UI.Pixel(line.y), UI.Pixel(math.min(line.x1, line.x2)), UI.Pixel(math.max(line.x1, line.x2)))
end

local function BlockGridLine(parent, key, priority)
    parent.gridLineBlocks = parent.gridLineBlocks or {}
    local existing = parent.gridLineBlocks[key]
    if existing and existing > (priority or 0) then
        return
    end

    parent.gridLineBlocks[key] = priority or 0
end

local function StoreGridLine(parent, line, borderStyle)
    if not parent or not line or not borderStyle then
        return
    end

    local key = BorderLineKey(line)
    if borderStyle.style == "none" then
        BlockGridLine(parent, key, borderStyle.priority or 0)
        parent.gridLines = parent.gridLines or {}
        parent.gridLines[key] = nil
        return
    end

    parent.gridLines = parent.gridLines or {}

    line.style = borderStyle.style
    line.thickness = borderStyle.thickness or 1
    line.priority = borderStyle.priority or BorderPriority.explicit
    line.order = borderStyle.order or 0
    line.alpha = borderStyle.alpha or UI.Grid.color[4]

    local blockedPriority = parent.gridLineBlocks and parent.gridLineBlocks[key]
    if blockedPriority and (line.priority or 0) <= blockedPriority then
        return
    end

    local existing = parent.gridLines[key]
    if not existing
        or (line.priority or 0) > (existing.priority or 0)
        or ((line.priority or 0) == (existing.priority or 0) and (line.order or 0) >= (existing.order or 0))
    then
        parent.gridLines[key] = line
    end
end

local function GetCellEdgeLine(cell, edge)
    local bounds = cell and cell.gridBounds
    if not bounds then
        return nil
    end

    if edge == "left" then
        return {
            vertical = true,
            x = bounds.x,
            y1 = bounds.y,
            y2 = bounds.y + bounds.height,
        }
    elseif edge == "right" then
        return {
            vertical = true,
            x = bounds.x + bounds.width,
            y1 = bounds.y,
            y2 = bounds.y + bounds.height,
        }
    elseif edge == "top" then
        return {
            vertical = false,
            y = bounds.y,
            x1 = bounds.x,
            x2 = bounds.x + bounds.width,
        }
    elseif edge == "bottom" then
        return {
            vertical = false,
            y = bounds.y + bounds.height,
            x1 = bounds.x,
            x2 = bounds.x + bounds.width,
        }
    end

    return nil
end

local function GetNeighborCell(parent, cell, edge)
    if not parent or not cell then
        return nil
    end

    local grid = parent.gridTables and parent.gridTables[cell.gridTable or cell.tableKey]
    if not grid then
        return nil
    end

    if edge == "left" then
        return grid.rows[cell.gridRow] and grid.rows[cell.gridRow][cell.gridFromColumn - 1] or nil
    elseif edge == "right" then
        return grid.rows[cell.gridRow] and grid.rows[cell.gridRow][cell.gridToColumn + 1] or nil
    elseif edge == "top" then
        return grid.rows[cell.gridFromRow - 1] and grid.rows[cell.gridFromRow - 1][cell.gridColumn] or nil
    elseif edge == "bottom" then
        return grid.rows[cell.gridToRow + 1] and grid.rows[cell.gridToRow + 1][cell.gridColumn] or nil
    end

    return nil
end

local function MaxBlockPriority(block, neighborBlock)
    return math.max(block and block.priority or 0, neighborBlock and neighborBlock.priority or 0)
end

local function GetRelatedBlockInnerBorderStyle(block, neighborBlock, edge)
    if not block or not neighborBlock then
        return nil, false
    end

    local isRowEdge = edge == "top" or edge == "bottom"
    local blockInnerStyle = isRowEdge and block.innerRowBorderStyle or block.innerColBorderStyle
    local neighborInnerStyle = isRowEdge and neighborBlock.innerRowBorderStyle or neighborBlock.innerColBorderStyle
    local blockParentStyle = isRowEdge and block.parentInnerRowBorderStyle or block.parentInnerColBorderStyle
    local neighborParentStyle = isRowEdge and neighborBlock.parentInnerRowBorderStyle or neighborBlock.parentInnerColBorderStyle
    blockInnerStyle = blockInnerStyle or block.innerBorderStyle
    neighborInnerStyle = neighborInnerStyle or neighborBlock.innerBorderStyle
    blockParentStyle = blockParentStyle or block.parentInnerBorderStyle
    neighborParentStyle = neighborParentStyle or neighborBlock.parentInnerBorderStyle

    if block.id == neighborBlock.id then
        return blockInnerStyle, true
    end

    if block.parentBlockId and block.parentBlockId == neighborBlock.id then
        return blockParentStyle or neighborInnerStyle, true
    end

    if neighborBlock.parentBlockId and neighborBlock.parentBlockId == block.id then
        return neighborParentStyle or blockInnerStyle, true
    end

    if block.parentBlockId and neighborBlock.parentBlockId and block.parentBlockId == neighborBlock.parentBlockId then
        return blockParentStyle or neighborParentStyle, true
    end

    return nil, false
end

local function BlockWinsOver(existing, candidate)
    if not existing then
        return true
    end

    local existingLayerOrder = Layers.LayerRenderOrder(existing.layer)
    local candidateLayerOrder = Layers.LayerRenderOrder(candidate.layer)
    if candidateLayerOrder ~= existingLayerOrder then
        return candidateLayerOrder > existingLayerOrder
    end

    local existingPriority = existing.priority or 0
    local candidatePriority = candidate.priority or 0
    if candidatePriority ~= existingPriority then
        return candidatePriority > existingPriority
    end

    return (candidate.order or 0) >= (existing.order or 0)
end

local function EnsureColorBlock(parent, blockData, order)
    parent.colorBlocksById = parent.colorBlocksById or {}

    local id = blockData.id
    if not id then
        return nil
    end

    local existing = parent.colorBlocksById[id]
    if existing then
        if blockData.bg ~= nil then
            existing.bg = blockData.bg
        end
        if blockData.border ~= nil then
            existing.border = blockData.border
            existing.borderStyle = CopyBorderStyle(blockData.border, BorderPriority.block + (blockData.priority or 0), order or existing.order)
        end
        if blockData.innerBorder ~= nil then
            existing.innerBorder = blockData.innerBorder
            existing.innerBorderStyle = CopyBorderStyle(blockData.innerBorder, BorderPriority.block + (blockData.priority or 0), order or existing.order)
        end
        if blockData.innerRowBorder ~= nil then
            existing.innerRowBorder = blockData.innerRowBorder
            existing.innerRowBorderStyle = CopyBorderStyle(blockData.innerRowBorder, BorderPriority.block + (blockData.priority or 0), order or existing.order)
        end
        if blockData.innerColBorder ~= nil then
            existing.innerColBorder = blockData.innerColBorder
            existing.innerColBorderStyle = CopyBorderStyle(blockData.innerColBorder, BorderPriority.block + (blockData.priority or 0), order or existing.order)
        end
        if blockData.parentBlockId ~= nil then
            existing.parentBlockId = blockData.parentBlockId
        end
        if blockData.parentInnerBorder ~= nil then
            existing.parentInnerBorder = blockData.parentInnerBorder
            existing.parentInnerBorderStyle = CopyBorderStyle(blockData.parentInnerBorder, BorderPriority.block + (blockData.priority or 0), order or existing.order)
        end
        if blockData.parentInnerRowBorder ~= nil then
            existing.parentInnerRowBorder = blockData.parentInnerRowBorder
            existing.parentInnerRowBorderStyle = CopyBorderStyle(blockData.parentInnerRowBorder, BorderPriority.block + (blockData.priority or 0), order or existing.order)
        end
        if blockData.parentInnerColBorder ~= nil then
            existing.parentInnerColBorder = blockData.parentInnerColBorder
            existing.parentInnerColBorderStyle = CopyBorderStyle(blockData.parentInnerColBorder, BorderPriority.block + (blockData.priority or 0), order or existing.order)
        end
        if blockData.layer ~= nil then
            existing.layer = blockData.layer
        end
        return existing
    end

    local block = {
        id = id,
        parentBlockId = blockData.parentBlockId,
        layer = blockData.layer,
        bg = blockData.bg,
        border = blockData.border or "solid1",
        innerBorder = blockData.innerBorder,
        innerRowBorder = blockData.innerRowBorder,
        innerColBorder = blockData.innerColBorder,
        parentInnerBorder = blockData.parentInnerBorder,
        parentInnerRowBorder = blockData.parentInnerRowBorder,
        parentInnerColBorder = blockData.parentInnerColBorder,
        priority = blockData.priority or 0,
        order = order or 0,
    }
    block.borderStyle = CopyBorderStyle(block.border, BorderPriority.block + block.priority, block.order)
    block.innerBorderStyle = CopyBorderStyle(block.innerBorder, BorderPriority.block + block.priority, block.order)
    block.innerRowBorderStyle = CopyBorderStyle(block.innerRowBorder, BorderPriority.block + block.priority, block.order)
    block.innerColBorderStyle = CopyBorderStyle(block.innerColBorder, BorderPriority.block + block.priority, block.order)
    block.parentInnerBorderStyle = CopyBorderStyle(block.parentInnerBorder, BorderPriority.block + block.priority, block.order)
    block.parentInnerRowBorderStyle = CopyBorderStyle(block.parentInnerRowBorder, BorderPriority.block + block.priority, block.order)
    block.parentInnerColBorderStyle = CopyBorderStyle(block.parentInnerColBorder, BorderPriority.block + block.priority, block.order)
    parent.colorBlocksById[id] = block
    return block
end

local function GetCellByCoord(parent, tableKey, coord)
    local key = CoordKey(tableKey or "main", coord)
    return key and parent.cellsByCoord and parent.cellsByCoord[key] or nil
end

local function AssignCellToBlock(parent, cell, block)
    if not cell or not block or not cell.coordKey then
        return
    end

    if not Layers.IsLayerVisible(block.layer) then
        return
    end

    parent.blockByCoord = parent.blockByCoord or {}

    local existing = parent.blockByCoord[cell.coordKey]
    if existing and not BlockWinsOver(existing, block) then
        return
    end

    parent.blockByCoord[cell.coordKey] = block
    cell.cellData.block = block.id
    cell.cellData.layer = block.layer
    cell.cellData.layerName = Layers.LayerDisplayName(block.layer)

    if cell.cellData.styleLayers then
        cell.cellData.styleLayers.layer = nil
        cell.cellData.styleLayers.block = nil
    end

    if block.layer then
        CellStyles.SetCellStyleLayer(cell.cellData, "layer", StyleLayer.layer, {
            alpha = Layers.LayerVisualAlpha(block.layer),
        })
    end

    if block.bg then
        CellStyles.SetCellStyleLayer(cell.cellData, "block", StyleLayer.block, {
            bg = block.bg,
        })
    end

    CellStyles.ApplyCellResolvedStyle(cell)
end

local function ApplyColorBlocks(parent)
    if parent.blocksApplied then
        return
    end

    parent.blocksApplied = true
    parent.blockByCoord = {}

    local order = 0
    for _, blockData in ipairs(NS.Data.colorBlocks or {}) do
        order = order + 1
        local block = EnsureColorBlock(parent, blockData, order)
        if block and type(blockData.cells) == "table" then
            local tableKey = blockData.table or "main"
            for _, coord in ipairs(blockData.cells) do
                AssignCellToBlock(parent, GetCellByCoord(parent, tableKey, coord), block)
            end
        end
    end
end

local function BlockBorderStyle(block, style)
    if not style then
        return nil
    end

    local alpha = Layers.LayerVisualAlpha(block and block.layer)
    if alpha >= 1 then
        return style
    end

    local copy = Helpers.ShallowCopy(style) or {}
    copy.alpha = alpha
    return copy
end

local function RelatedBlockBorderStyle(block, neighborBlock, style)
    if not style then
        return nil
    end

    local alpha = math.min(Layers.LayerVisualAlpha(block and block.layer), Layers.LayerVisualAlpha(neighborBlock and neighborBlock.layer))
    if alpha >= 1 then
        return style
    end

    local copy = Helpers.ShallowCopy(style) or {}
    copy.alpha = alpha
    return copy
end

local function DrawColorBlockBorders(parent)
    for coordKey, block in pairs(parent.blockByCoord or {}) do
        local cell = parent.cellsByCoord and parent.cellsByCoord[coordKey]
        if cell and block.borderStyle then
            local edges = { "left", "right", "top", "bottom" }
            for _, edge in ipairs(edges) do
                local neighbor = GetNeighborCell(parent, cell, edge)
                local neighborBlock = neighbor and neighbor.coordKey and parent.blockByCoord[neighbor.coordKey]
                local innerBorderStyle, isRelatedBlock = GetRelatedBlockInnerBorderStyle(block, neighborBlock, edge)
                if isRelatedBlock then
                    if innerBorderStyle then
                        StoreGridLine(parent, GetCellEdgeLine(cell, edge), RelatedBlockBorderStyle(block, neighborBlock, innerBorderStyle))
                    else
                        StoreGridLine(parent, GetCellEdgeLine(cell, edge), {
                            style = "none",
                            priority = BorderPriority.block + MaxBlockPriority(block, neighborBlock),
                            order = block.order or 0,
                        })
                    end
                else
                    StoreGridLine(parent, GetCellEdgeLine(cell, edge), BlockBorderStyle(block, block.borderStyle))
                end
            end
        end
    end
end

local function StoreExplicitEdge(parent, cell, edge, rule, order)
    local style = CopyBorderStyle(rule.style, rule.priority or BorderPriority.explicit, order)
    StoreGridLine(parent, GetCellEdgeLine(cell, edge), style)
end

local function IsFullBorderStyle(value)
    return type(value) ~= "table" or value.style ~= nil or value.type ~= nil or value[1] ~= nil
end

local function CellBorderEdgeStyle(border, edge)
    if border == nil then
        return nil
    end

    if IsFullBorderStyle(border) then
        return border
    end

    return border[edge]
end

local function CellBorderEdgePriority(border, edgeStyle)
    if type(edgeStyle) == "table" and edgeStyle.priority ~= nil then
        return edgeStyle.priority
    end

    if type(border) == "table" and border.priority ~= nil then
        return border.priority
    end

    return BorderPriority.cell
end

local function DrawCellBorderOverrides(parent)
    local edges = { "left", "right", "top", "bottom" }
    local seenCells = {}
    for _, grid in pairs(parent.gridTables or {}) do
        for _, columns in pairs(grid.rows or {}) do
            for _, cell in pairs(columns or {}) do
                if cell and not seenCells[cell] then
                    seenCells[cell] = true
                    local border = cell.cellData and cell.cellData.border
                    if border ~= nil then
                        for _, edge in ipairs(edges) do
                            local edgeStyle = CellBorderEdgeStyle(border, edge)
                            if edgeStyle ~= nil then
                                StoreExplicitEdge(parent, cell, edge, {
                                    style = edgeStyle,
                                    priority = CellBorderEdgePriority(border, edgeStyle),
                                }, BorderPriority.cellOrder)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function ShouldApplyRuleToTable(rule, tableKey)
    if rule.table and rule.table ~= tableKey then
        return false
    end

    if type(rule.tables) == "table" then
        for _, allowedTable in ipairs(rule.tables) do
            if allowedTable == tableKey then
                return true
            end
        end
        return false
    end

    return true
end

local function GridRowBounds(grid)
    local minRow
    local maxRow
    for row in pairs(grid.rows or {}) do
        minRow = minRow and math.min(minRow, row) or row
        maxRow = maxRow and math.max(maxRow, row) or row
    end
    return minRow, maxRow
end

local function GridColumnBounds(columns)
    local minColumn
    local maxColumn
    for column in pairs(columns or {}) do
        minColumn = minColumn and math.min(minColumn, column) or column
        maxColumn = maxColumn and math.max(maxColumn, column) or column
    end
    return minColumn, maxColumn
end

local function StoreRowCellsEdge(parent, columns, edge, rule, order)
    for _, cell in pairs(columns or {}) do
        StoreExplicitEdge(parent, cell, edge, rule, order)
    end
end

local function ApplyTableBorderRule(parent, rule, order)
    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            local minRow, maxRow = GridRowBounds(grid)
            if minRow and maxRow then
                for row, columns in pairs(grid.rows or {}) do
                    for column, cell in pairs(columns or {}) do
                        if row == minRow then
                            StoreExplicitEdge(parent, cell, "top", rule, order)
                        end
                        if row == maxRow then
                            StoreExplicitEdge(parent, cell, "bottom", rule, order)
                        end
                        local minColumn, maxColumn = GridColumnBounds(columns)
                        if column == minColumn then
                            StoreExplicitEdge(parent, cell, "left", rule, order)
                        end
                        if column == maxColumn then
                            StoreExplicitEdge(parent, cell, "right", rule, order)
                        end
                    end
                end
            end
        end
    end
end

local function ApplyRowBordersRule(parent, rule, order)
    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            for row, columns in pairs(grid.rows or {}) do
                if rule.fromRow and rule.toRow then
                    if row >= rule.fromRow and row <= rule.toRow then
                        StoreRowCellsEdge(parent, columns, "bottom", rule, order)
                    end
                else
                    local below = grid.rows[row + 1]
                    if below then
                        StoreRowCellsEdge(parent, columns, "bottom", rule, order)
                    end
                end
            end
        end
    end
end

local function ApplyColumnBordersRule(parent, rule, order)
    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            for _, columns in pairs(grid.rows or {}) do
                for column, cell in pairs(columns or {}) do
                    if columns[column + 1] then
                        StoreExplicitEdge(parent, cell, "right", rule, order)
                    end
                end
            end
        end
    end
end

local function ApplyBetweenCellsBorderRule(parent, rule, order)
    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            local leftColumn, leftRow, leftCoord = ParseCoord(rule.fromCoord)
            local rightColumn, rightRow, rightCoord = ParseCoord(rule.toCoord)
            if leftColumn and rightColumn and leftRow and rightRow then
                local firstCell = GetCellByCoord(parent, tableKey, leftCoord)
                local secondCell = GetCellByCoord(parent, tableKey, rightCoord)
                if firstCell and secondCell then
                    if leftRow == rightRow and leftColumn + 1 == rightColumn then
                        StoreExplicitEdge(parent, firstCell, "right", rule, order)
                    elseif leftRow == rightRow and rightColumn + 1 == leftColumn then
                        StoreExplicitEdge(parent, secondCell, "right", rule, order)
                    elseif leftColumn == rightColumn and leftRow + 1 == rightRow then
                        StoreExplicitEdge(parent, firstCell, "bottom", rule, order)
                    elseif leftColumn == rightColumn and rightRow + 1 == leftRow then
                        StoreExplicitEdge(parent, secondCell, "bottom", rule, order)
                    end
                end
            end
        end
    end
end

local function ApplyColumnBorderRule(parent, rule, order)
    local column = ColumnIndex(rule.afterCol)
    local edge = "right"
    if rule.beforeCol then
        column = ColumnIndex(rule.beforeCol)
        edge = "left"
    end
    if not column then
        return
    end

    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            for row, columns in pairs(grid.rows or {}) do
                local applies = true
                if rule.fromRow and row < rule.fromRow then
                    applies = false
                end
                if rule.toRow and row > rule.toRow then
                    applies = false
                end
                if applies then
                    local cell = columns[column]
                    if not cell and edge == "left" then
                        cell = columns[column]
                    end
                    if cell then
                        StoreExplicitEdge(parent, cell, edge, rule, order)
                    end
                end
            end
        end
    end
end

local function ApplyRowBorderRule(parent, rule, order)
    if not rule.row then
        return
    end

    local fromColumn = ColumnIndex(rule.fromCol)
    local toColumn = ColumnIndex(rule.toCol or rule.fromCol)
    if fromColumn and toColumn and fromColumn > toColumn then
        fromColumn, toColumn = toColumn, fromColumn
    end

    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            local row = grid.rows[rule.row]
            if row then
                for column, cell in pairs(row) do
                    local applies = true
                    if fromColumn and column < fromColumn then
                        applies = false
                    end
                    if toColumn and column > toColumn then
                        applies = false
                    end
                    if applies then
                        StoreExplicitEdge(parent, cell, rule.edge == "top" and "top" or "bottom", rule, order)
                    end
                end
            end
        end
    end
end

local function DrawExplicitBorderRules(parent)
    for index, rule in ipairs(NS.Data.borderRules or {}) do
        if rule.kind == "rowBorders" then
            ApplyRowBordersRule(parent, rule, BorderPriority.explicit + index)
        elseif rule.kind == "columnBorders" then
            ApplyColumnBordersRule(parent, rule, BorderPriority.explicit + index)
        elseif rule.kind == "tableBorder" then
            ApplyTableBorderRule(parent, rule, BorderPriority.explicit + index)
        elseif rule.kind == "betweenCellsBorder" then
            ApplyBetweenCellsBorderRule(parent, rule, BorderPriority.explicit + index)
        elseif rule.kind == "columnBorder" then
            ApplyColumnBorderRule(parent, rule, BorderPriority.explicit + index)
        elseif rule.kind == "rowBorder" then
            ApplyRowBorderRule(parent, rule, BorderPriority.explicit + index)
        end
    end
end

local function BuildBorderGrid(parent)
    parent.gridLines = {}
    parent.gridLineBlocks = {}

    ApplyColorBlocks(parent)
    DrawColorBlockBorders(parent)
    DrawCellBorderOverrides(parent)
    DrawExplicitBorderRules(parent)
end

local function DrawTableBodyViewportBorder(scroll, tableDefinition, width, visibleRows)
    if not scroll or scroll.tableBorderOverlay or not tableDefinition or not tableDefinition.key then
        return
    end

    local height = math.max(1, visibleRows * Metrics.rowHeight)
    local holder = {}
    for index, rule in ipairs(NS.Data.borderRules or {}) do
        if rule.kind == "tableBorder" and ShouldApplyRuleToTable(rule, tableDefinition.key) then
            StoreGridLine(holder, {
                vertical = false,
                y = height,
                x1 = 0,
                x2 = width,
            }, CopyBorderStyle(rule.style, rule.priority or BorderPriority.explicit, BorderPriority.explicit + index))
        end
    end

    if not holder.gridLines then
        return
    end

    local overlay = CreateFrame("Frame", nil, scroll)
    overlay.deferScaleLayout = scroll.deferScaleLayout
    overlay:SetAllPoints(scroll)
    overlay:SetFrameLevel(scroll:GetFrameLevel() + 100)
    overlay:EnableMouse(false)
    overlay.lines = {}

    for _, line in pairs(holder.gridLines) do
        GridLines.RegisterStyled(overlay, line)
    end

    scroll.tableBorderOverlay = overlay
end

Borders.RegisterCellCoordinate = RegisterCellCoordinate
Borders.GetCellByCoord = GetCellByCoord
Borders.BuildBorderGrid = BuildBorderGrid
Borders.DrawTableBodyViewportBorder = DrawTableBodyViewportBorder
Borders.ShouldApplyRuleToTable = ShouldApplyRuleToTable
Borders.BlockWinsOver = BlockWinsOver
Borders.NormalizeBorderStyle = NormalizeBorderStyle
Borders.CopyBorderStyle = CopyBorderStyle
