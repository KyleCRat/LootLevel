local ADDON_NAME, NS = ...

local FRAME_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

local GRID_COLOR = { 0, 0, 0, 1 }
local DOTTED_GRID_DOT = 1
local DOTTED_GRID_GAP = 3
local DASHED_GRID_DASH = 2
local DASHED_GRID_GAP = 2
local BLOCK_BORDER_PRIORITY = 20
local EXPLICIT_NONE_PRIORITY = 80
local EXPLICIT_BORDER_PRIORITY = 100
local EXPLICIT_THICK_BORDER_PRIORITY = 110

local FRAME_WIDTH = 1180
local FRAME_HEIGHT = 760
local PADDING = 14
local TITLE_HEIGHT = 28
local HEADER_HEIGHT = 26
local ROW_HEIGHT = 20
local LEFT_WIDTH = 334
local GAP = 20
local MAIN_WIDTH = 790
local RAID_SUB_WIDTH = 40
local CRAFT_SUB_WIDTH = 43
local SCALE_MIN_PERCENT = 50
local SCALE_MAX_PERCENT = 200
local SCALE_STEP_PERCENT = 5
local SCALE_DEFAULT_PERCENT = 100

local Color
local TextColorFor

local function Pixel(value)
    value = value or 0
    if value >= 0 then
        return math.floor(value + 0.5)
    end

    return math.ceil(value - 0.5)
end

NS.Pixel = Pixel

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function NormalizeScalePercent(value)
    value = tonumber(value) or SCALE_DEFAULT_PERCENT
    value = Pixel(value / SCALE_STEP_PERCENT) * SCALE_STEP_PERCENT
    return Clamp(value, SCALE_MIN_PERCENT, SCALE_MAX_PERCENT)
end

local function GetScalePercent()
    local percent = NS.db and NS.db.scalePercent or SCALE_DEFAULT_PERCENT
    return NormalizeScalePercent(percent)
end

local function GetLayoutScale()
    return GetScalePercent() / 100
end

local function ScalePixel(value)
    return Pixel((value or 0) * GetLayoutScale())
end

local function GetScaledBounds(x, y, width, height)
    local scale = GetLayoutScale()
    local left = Pixel((x or 0) * scale)
    local top = Pixel((y or 0) * scale)
    local right = Pixel(((x or 0) + (width or 0)) * scale)
    local bottom = Pixel(((y or 0) + (height or 0)) * scale)

    return left, top, math.max(1, right - left), math.max(1, bottom - top)
end

local function FormatScalePercent(value)
    return ("%d%%"):format(NormalizeScalePercent(value))
end

local function GetPixelToUIUnitFactor()
    if PixelUtil and PixelUtil.GetPixelToUIUnitFactor then
        return PixelUtil.GetPixelToUIUnitFactor()
    end

    local _, physicalHeight = GetPhysicalScreenSize()
    if physicalHeight and physicalHeight > 0 then
        return 768 / physicalHeight
    end

    return UIParent:GetEffectiveScale()
end

local function SetPixelPoint(frame, point, relativeTo, relativePoint, x, y)
    frame:SetPoint(point, relativeTo, relativePoint, Pixel(x), Pixel(y))
end

local function SetPixelSize(frame, width, height)
    frame:SetSize(Pixel(width), Pixel(height))
end

local function ApplyLayoutRecord(record)
    local region = record.region
    if not region then
        return
    end

    if record.kind == "bounds" then
        local x, y, width, height = GetScaledBounds(record.x, record.y, record.width, record.height)
        region:ClearAllPoints()
        SetPixelPoint(region, "TOPLEFT", record.relativeTo, "TOPLEFT", x, -y)
        SetPixelSize(region, width, height)
    elseif record.kind == "box" then
        region:ClearAllPoints()
        SetPixelPoint(region, record.point, record.relativeTo, record.relativePoint, ScalePixel(record.x), ScalePixel(record.y))
        SetPixelSize(region, ScalePixel(record.width), ScalePixel(record.height))
    elseif record.kind == "size" then
        SetPixelSize(region, ScalePixel(record.width), ScalePixel(record.height))
    elseif record.kind == "points" then
        region:ClearAllPoints()
        for _, point in ipairs(record.points) do
            SetPixelPoint(region, point.point, point.relativeTo, point.relativePoint, ScalePixel(point.x), ScalePixel(point.y))
        end
        if record.height then
            region:SetHeight(ScalePixel(record.height))
        end
        if record.width then
            region:SetWidth(ScalePixel(record.width))
        end
    elseif record.kind == "gridline" then
        local scale = GetLayoutScale()
        local line = record.line
        local thickness = math.max(1, Pixel(line.thickness or 1))
        local thicknessOffset = math.floor(thickness / 2)

        region:ClearAllPoints()
        if line.vertical then
            local x = Pixel(line.x * scale)
            local y1 = Pixel(line.y1 * scale)
            local y2 = Pixel(line.y2 * scale)
            SetPixelPoint(region, "TOPLEFT", record.relativeTo, "TOPLEFT", x - thicknessOffset, -y1)
            SetPixelSize(region, thickness, math.max(1, y2 - y1))
        else
            local y = Pixel(line.y * scale)
            local x1 = Pixel(line.x1 * scale)
            local x2 = Pixel(line.x2 * scale)
            SetPixelPoint(region, "TOPLEFT", record.relativeTo, "TOPLEFT", x1, -(y - thicknessOffset))
            SetPixelSize(region, math.max(1, x2 - x1), thickness)
        end
    end
end

local function ApplyFontRecord(record)
    local fontString = record.fontString
    if not fontString then
        return
    end

    local size = math.max(1, ScalePixel(record.size))
    fontString:SetFont(record.path, size, record.flags)
end

local function RegisterLayoutRecord(record)
    NS.layoutRecords = NS.layoutRecords or {}
    NS.layoutRecords[#NS.layoutRecords + 1] = record
    ApplyLayoutRecord(record)
end

local function RegisterFontRecord(record)
    NS.layoutFonts = NS.layoutFonts or {}
    NS.layoutFonts[#NS.layoutFonts + 1] = record
    ApplyFontRecord(record)
end

local function SetLayoutBounds(region, relativeTo, x, y, width, height)
    RegisterLayoutRecord({
        kind = "bounds",
        region = region,
        relativeTo = relativeTo,
        x = x,
        y = y,
        width = width,
        height = height,
    })
end

local function SetLayoutBox(region, point, relativeTo, relativePoint, x, y, width, height)
    RegisterLayoutRecord({
        kind = "box",
        region = region,
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        x = x,
        y = y,
        width = width,
        height = height,
    })
end

local function SetLayoutSize(region, width, height)
    RegisterLayoutRecord({
        kind = "size",
        region = region,
        width = width,
        height = height,
    })
end

local function SetLayoutPoints(region, points, width, height)
    RegisterLayoutRecord({
        kind = "points",
        region = region,
        points = points,
        width = width,
        height = height,
    })
end

local function RefreshScaledLayout()
    for _, record in ipairs(NS.layoutRecords or {}) do
        ApplyLayoutRecord(record)
    end

    for _, record in ipairs(NS.layoutFonts or {}) do
        ApplyFontRecord(record)
    end

    if NS.scaleButtonText then
        NS.scaleButtonText:SetText(FormatScalePercent(GetScalePercent()))
    end
end

local function ApplyTexturePixelSnapping(texture)
    if texture.SetSnapToPixelGrid then
        texture:SetSnapToPixelGrid(false)
    end
    if texture.SetTexelSnappingBias then
        texture:SetTexelSnappingBias(0)
    end
end

local function RegisterGridLineTexture(overlay, line)
    local texture = overlay:CreateTexture(nil, "ARTWORK")
    ApplyTexturePixelSnapping(texture)
    texture:SetColorTexture(GRID_COLOR[1], GRID_COLOR[2], GRID_COLOR[3], GRID_COLOR[4])
    RegisterLayoutRecord({
        kind = "gridline",
        region = texture,
        relativeTo = overlay,
        line = line,
    })
    overlay.lines[#overlay.lines + 1] = texture
end

local function RegisterPatternedGridLine(overlay, line, segmentLength, segmentGap)
    local length
    if line.vertical then
        length = line.y2 - line.y1
    else
        length = line.x2 - line.x1
    end

    local offset = 0
    while offset < length do
        local segmentEnd = math.min(offset + segmentLength, length)
        local segmentLine

        if line.vertical then
            segmentLine = {
                vertical = true,
                x = line.x,
                y1 = line.y1 + offset,
                y2 = line.y1 + segmentEnd,
                thickness = line.thickness,
            }
        else
            segmentLine = {
                vertical = false,
                y = line.y,
                x1 = line.x1 + offset,
                x2 = line.x1 + segmentEnd,
                thickness = line.thickness,
            }
        end

        RegisterGridLineTexture(overlay, segmentLine)
        offset = offset + segmentLength + segmentGap
    end
end

local function ColumnName(index)
    index = tonumber(index)
    if not index or index < 1 then
        return nil
    end

    local name = ""
    while index > 0 do
        local remainder = (index - 1) % 26
        name = string.char(97 + remainder) .. name
        index = math.floor((index - 1) / 26)
    end

    return name
end

local function ColumnIndex(column)
    if type(column) == "number" then
        return column
    end

    column = tostring(column or ""):lower()
    local index = 0
    for position = 1, #column do
        local byte = string.byte(column, position)
        if byte < 97 or byte > 122 then
            return nil
        end
        index = (index * 26) + (byte - 96)
    end

    return index > 0 and index or nil
end

local function CoordFromIndex(column, row)
    local columnName = ColumnName(column)
    row = tonumber(row)
    if not columnName or not row then
        return nil
    end

    return ("%s%d"):format(columnName, row)
end

local function NormalizeCoord(coord)
    if type(coord) == "table" then
        if coord.coord then
            return NormalizeCoord(coord.coord)
        end
        if coord.col and coord.row then
            return CoordFromIndex(coord.col, coord.row)
        end
        if coord[1] and coord[2] then
            return CoordFromIndex(coord[1], coord[2])
        end
    end

    local text = tostring(coord or ""):lower()
    local column, row = text:match("^%s*([a-z]+)(%d+)%s*$")
    if not column or not row then
        return nil
    end

    return ("%s%d"):format(column, tonumber(row))
end

local function ParseCoord(coord)
    coord = NormalizeCoord(coord)
    if not coord then
        return nil, nil, nil
    end

    local column, row = coord:match("^([a-z]+)(%d+)$")
    return ColumnIndex(column), tonumber(row), coord
end

local function CoordKey(tableKey, coord)
    coord = NormalizeCoord(coord)
    if not coord then
        return nil
    end

    return ("%s:%s"):format(tableKey or "main", coord)
end

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

    local styleName
    local thickness
    local valuePriority
    local priority = EXPLICIT_BORDER_PRIORITY

    if type(value) == "table" then
        styleName = value.style or value.type or value[1]
        thickness = value.thickness or value.size or value.width
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
            priority = EXPLICIT_NONE_PRIORITY,
        }
    end

    if styleName == "solid" or styleName == "solid1" or styleName == "1px" or styleName == "1px solid" then
        styleName = "solid"
        thickness = thickness or 1
    elseif styleName == "solid3" or styleName == "3px" or styleName == "3px solid" then
        styleName = "solid"
        thickness = thickness or 3
    elseif styleName == "dotted" or styleName == "dot" then
        styleName = "dotted"
        thickness = thickness or 1
    elseif styleName == "dashed" or styleName == "dash" then
        styleName = "dashed"
        thickness = thickness or 1
    else
        return nil
    end

    thickness = math.max(1, Pixel(tonumber(thickness) or 1))
    if thickness >= 3 then
        priority = EXPLICIT_THICK_BORDER_PRIORITY
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

    return {
        style = style.style,
        thickness = style.thickness,
        priority = priority or style.priority,
        order = order or style.order or 0,
    }
end

local function EnsureGrid(parent, tableKey)
    parent.gridTables = parent.gridTables or {}
    tableKey = tableKey or "main"
    if not parent.gridTables[tableKey] then
        parent.gridTables[tableKey] = {
            rows = {},
        }
    end

    return parent.gridTables[tableKey]
end

local function RegisterCellCoordinate(parent, cell, cellData, x, y, width, height)
    local coord = NormalizeCoord(cellData.coord)
    if not coord then
        return
    end

    local tableKey = cellData.tableKey or cellData.gridTable or cellData.table or "main"
    local column, row = ParseCoord(coord)
    if not column or not row then
        return
    end

    parent.cellsByCoord = parent.cellsByCoord or {}

    local key = CoordKey(tableKey, coord)
    parent.cellsByCoord[key] = cell

    local grid = EnsureGrid(parent, tableKey)
    grid.rows[row] = grid.rows[row] or {}
    grid.rows[row][column] = cell

    cell.coordKey = key
    cell.gridTable = tableKey
    cell.gridCoord = coord
    cell.gridColumn = column
    cell.gridRow = row
    cell.gridBounds = {
        x = Pixel(x),
        y = Pixel(y),
        width = Pixel(width),
        height = Pixel(height),
    }
end

local function BorderLineKey(line)
    if line.vertical then
        return ("v:%d:%d:%d"):format(Pixel(line.x), Pixel(math.min(line.y1, line.y2)), Pixel(math.max(line.y1, line.y2)))
    end

    return ("h:%d:%d:%d"):format(Pixel(line.y), Pixel(math.min(line.x1, line.x2)), Pixel(math.max(line.x1, line.x2)))
end

local function BlockGridLine(parent, key, priority)
    parent.gridLineBlocks = parent.gridLineBlocks or {}
    parent.gridLineBlocks[key] = math.max(parent.gridLineBlocks[key] or 0, priority or 0)

    local existing = parent.gridLines and parent.gridLines[key]
    if existing and (existing.priority or 0) <= parent.gridLineBlocks[key] then
        parent.gridLines[key] = nil
    end
end

local function StoreGridLine(parent, line, borderStyle)
    if not line or not borderStyle then
        return
    end

    parent.gridLines = parent.gridLines or {}
    local key = BorderLineKey(line)

    if borderStyle.style == "none" then
        BlockGridLine(parent, key, borderStyle.priority)
        return
    end

    line.style = borderStyle.style
    line.thickness = borderStyle.thickness or 1
    line.priority = borderStyle.priority or EXPLICIT_BORDER_PRIORITY
    line.order = borderStyle.order or 0

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
    if not cell or not cell.gridTable or not cell.gridRow or not cell.gridColumn then
        return nil
    end

    local row = cell.gridRow
    local column = cell.gridColumn
    if edge == "left" then
        column = column - 1
    elseif edge == "right" then
        column = column + 1
    elseif edge == "top" then
        row = row - 1
    elseif edge == "bottom" then
        row = row + 1
    end

    local grid = parent.gridTables and parent.gridTables[cell.gridTable]
    return grid and grid.rows[row] and grid.rows[row][column] or nil
end

local function MaxBlockPriority(block, neighborBlock)
    return math.max(block and block.priority or 0, neighborBlock and neighborBlock.priority or 0)
end

local function GetRelatedBlockInnerBorderStyle(block, neighborBlock)
    if not block or not neighborBlock then
        return nil, false
    end

    if block.id == neighborBlock.id then
        return block.innerBorderStyle, true
    end

    if block.parentBlockId and block.parentBlockId == neighborBlock.id then
        return block.parentInnerBorderStyle or neighborBlock.innerBorderStyle, true
    end

    if neighborBlock.parentBlockId and neighborBlock.parentBlockId == block.id then
        return neighborBlock.parentInnerBorderStyle or block.innerBorderStyle, true
    end

    if block.parentBlockId and neighborBlock.parentBlockId and block.parentBlockId == neighborBlock.parentBlockId then
        return block.parentInnerBorderStyle or neighborBlock.parentInnerBorderStyle, true
    end

    return nil, false
end

local function EnsureColorBlock(parent, blockData, order)
    parent.colorBlocksById = parent.colorBlocksById or {}

    local id = blockData.id or blockData.block or blockData[1]
    if not id then
        return nil
    end

    local existing = parent.colorBlocksById[id]
    if existing then
        if blockData.color ~= nil then
            existing.color = blockData.color
        end
        if blockData.border ~= nil then
            existing.border = blockData.border
            existing.borderStyle = CopyBorderStyle(blockData.border, BLOCK_BORDER_PRIORITY + (blockData.priority or 0), order or existing.order)
        end
        if blockData.innerBorder ~= nil then
            existing.innerBorder = blockData.innerBorder
            existing.innerBorderStyle = CopyBorderStyle(blockData.innerBorder, BLOCK_BORDER_PRIORITY + (blockData.priority or 0), order or existing.order)
        end
        if blockData.parentBlockId ~= nil then
            existing.parentBlockId = blockData.parentBlockId
        end
        if blockData.parentInnerBorder ~= nil then
            existing.parentInnerBorder = blockData.parentInnerBorder
            existing.parentInnerBorderStyle = CopyBorderStyle(blockData.parentInnerBorder, BLOCK_BORDER_PRIORITY + (blockData.priority or 0), order or existing.order)
        end
        return existing
    end

    local block = {
        id = id,
        parentBlockId = blockData.parentBlockId,
        color = blockData.color,
        border = blockData.border or "solid1",
        innerBorder = blockData.innerBorder,
        parentInnerBorder = blockData.parentInnerBorder,
        priority = blockData.priority or 0,
        order = order or 0,
    }
    block.borderStyle = CopyBorderStyle(block.border, BLOCK_BORDER_PRIORITY + block.priority, block.order)
    block.innerBorderStyle = CopyBorderStyle(block.innerBorder, BLOCK_BORDER_PRIORITY + block.priority, block.order)
    block.parentInnerBorderStyle = CopyBorderStyle(block.parentInnerBorder, BLOCK_BORDER_PRIORITY + block.priority, block.order)
    parent.colorBlocksById[id] = block
    return block
end

local function AssignCellToBlock(parent, cell, block)
    if not cell or not block or not cell.coordKey then
        return
    end

    parent.blockByCoord = parent.blockByCoord or {}

    local existing = parent.blockByCoord[cell.coordKey]
    if existing
        and (
            (existing.priority or 0) > (block.priority or 0)
            or ((existing.priority or 0) == (block.priority or 0) and (existing.order or 0) > (block.order or 0))
        )
    then
        return
    end

    parent.blockByCoord[cell.coordKey] = block
    cell.cellData.blockId = block.id

    if block.color and cell.cellData.usesBlockBackgroundColor ~= false then
        cell.bg:SetColorTexture(Color(block.color))
        if cell.text then
            cell.text:SetTextColor(TextColorFor(block.color))
        end
    end
end

local function GetCellByCoord(parent, tableKey, coord)
    local key = CoordKey(tableKey or "main", coord)
    return key and parent.cellsByCoord and parent.cellsByCoord[key] or nil
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
            local tableKey = blockData.tableKey or blockData.gridTable or blockData.table or "main"
            for _, coord in ipairs(blockData.cells) do
                AssignCellToBlock(parent, GetCellByCoord(parent, tableKey, coord), block)
            end
        end
    end
end

local function DrawColorBlockBorders(parent)
    for coordKey, block in pairs(parent.blockByCoord or {}) do
        local cell = parent.cellsByCoord and parent.cellsByCoord[coordKey]
        if cell and block.borderStyle then
            local edges = { "left", "right", "top", "bottom" }
            for _, edge in ipairs(edges) do
                local neighbor = GetNeighborCell(parent, cell, edge)
                local neighborBlock = neighbor and neighbor.coordKey and parent.blockByCoord[neighbor.coordKey]
                local innerBorderStyle, isRelatedBlock = GetRelatedBlockInnerBorderStyle(block, neighborBlock)
                if isRelatedBlock then
                    if innerBorderStyle then
                        StoreGridLine(parent, GetCellEdgeLine(cell, edge), innerBorderStyle)
                    else
                        StoreGridLine(parent, GetCellEdgeLine(cell, edge), {
                            style = "none",
                            priority = BLOCK_BORDER_PRIORITY + MaxBlockPriority(block, neighborBlock),
                            order = block.order or 0,
                        })
                    end
                else
                    StoreGridLine(parent, GetCellEdgeLine(cell, edge), block.borderStyle)
                end
            end
        end
    end
end

local function StoreExplicitEdge(parent, cell, edge, rule, order)
    local style = CopyBorderStyle(rule.style or rule.border or rule[3], rule.priority or EXPLICIT_BORDER_PRIORITY, order)
    StoreGridLine(parent, GetCellEdgeLine(cell, edge), style)
end

local function ShouldApplyRuleToTable(rule, tableKey)
    local requested = rule.tables or rule.tableKey or rule.gridTable or rule.table
    if type(requested) == "table" then
        for _, requestedTable in ipairs(requested) do
            if requestedTable == "all" or requestedTable == tableKey then
                return true
            end
        end

        return false
    end

    return requested == nil or requested == "all" or requested == tableKey
end

local function ApplyEveryBorderRule(parent, rule, order)
    local axis = rule.axis or (rule.horizontal and "h") or (rule.vertical and "v")
    if axis ~= "h" and axis ~= "v" then
        return
    end

    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            for row, columns in pairs(grid.rows or {}) do
                if axis == "h" then
                    local fromRow = tonumber(rule.from or rule.rowStart or rule.start)
                    local toRow = tonumber(rule.to or rule.rowEnd or rule.stop or fromRow)
                    if not fromRow or (row >= fromRow and row <= toRow) then
                        for column, cell in pairs(columns) do
                            local nextRow = grid.rows[row + 1]
                            if nextRow and nextRow[column] then
                                StoreExplicitEdge(parent, cell, "bottom", rule, order)
                            end
                        end
                    end
                else
                    for column, cell in pairs(columns) do
                        local nextCell = columns[column + 1]
                        if nextCell then
                            StoreExplicitEdge(parent, cell, "right", rule, order)
                        end
                    end
                end
            end
        end
    end
end

local function ApplyBetweenBorderRule(parent, rule, order)
    local tableKey = rule.tableKey or rule.gridTable or rule.table or "main"
    local pair = rule.between or rule.cells or rule
    if type(pair) ~= "table" then
        return
    end

    local leftColumn, leftRow, leftCoord = ParseCoord(pair[1])
    local rightColumn, rightRow, rightCoord = ParseCoord(pair[2])
    if not leftColumn or not rightColumn or not leftRow or not rightRow then
        return
    end

    local firstCell = GetCellByCoord(parent, tableKey, leftCoord)
    local secondCell = GetCellByCoord(parent, tableKey, rightCoord)
    if not firstCell or not secondCell then
        return
    end

    if leftRow == rightRow and math.abs(leftColumn - rightColumn) == 1 then
        StoreExplicitEdge(parent, firstCell, leftColumn < rightColumn and "right" or "left", rule, order)
    elseif leftColumn == rightColumn and math.abs(leftRow - rightRow) == 1 then
        StoreExplicitEdge(parent, firstCell, leftRow < rightRow and "bottom" or "top", rule, order)
    end
end

local function ApplyVerticalBorderRule(parent, rule, order)
    local tableKey = rule.tableKey or rule.gridTable or rule.table or "main"
    local column = ColumnIndex(rule.after or rule.column or rule.col)
    if rule.before then
        column = (ColumnIndex(rule.before) or 1) - 1
    end
    if not column or column < 1 then
        return
    end

    local fromRow = tonumber(rule.from or rule.rowStart or rule.start)
    local toRow = tonumber(rule.to or rule.rowEnd or rule.stop or fromRow)
    if not fromRow or not toRow then
        return
    end

    if fromRow > toRow then
        fromRow, toRow = toRow, fromRow
    end

    local grid = parent.gridTables and parent.gridTables[tableKey]
    for row = fromRow, toRow do
        local cell = grid and grid.rows[row] and grid.rows[row][column]
        StoreExplicitEdge(parent, cell, "right", rule, order)
    end
end

local function ApplyHorizontalBorderRule(parent, rule, order)
    local tableKey = rule.tableKey or rule.gridTable or rule.table or "main"
    local row = tonumber(rule.below or rule.row)
    local edge = "bottom"
    if rule.above then
        row = tonumber(rule.above)
        edge = "top"
    end
    if not row then
        return
    end

    local fromColumn = ColumnIndex(rule.from or rule.columnStart or rule.start)
    local toColumn = ColumnIndex(rule.to or rule.columnEnd or rule.stop or fromColumn)
    if not fromColumn or not toColumn then
        return
    end

    if fromColumn > toColumn then
        fromColumn, toColumn = toColumn, fromColumn
    end

    local grid = parent.gridTables and parent.gridTables[tableKey]
    for column = fromColumn, toColumn do
        local cell = grid and grid.rows[row] and grid.rows[row][column]
        StoreExplicitEdge(parent, cell, edge, rule, order)
    end
end

local function DrawExplicitBorderRules(parent)
    for index, rule in ipairs(NS.Data.borderRules or {}) do
        if rule.each or rule.all then
            ApplyEveryBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.between or rule.cells or (type(rule[1]) == "string" and type(rule[2]) == "string") then
            ApplyBetweenBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.axis == "v" or rule.vertical then
            ApplyVerticalBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.axis == "h" or rule.horizontal then
            ApplyHorizontalBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        end
    end
end

local function BuildBorderGrid(parent)
    parent.gridLines = {}
    parent.gridLineBlocks = {}

    ApplyColorBlocks(parent)
    DrawColorBlockBorders(parent)
    DrawExplicitBorderRules(parent)
end

local function DrawGridLines(parent)
    if parent.gridOverlay then
        return
    end

    BuildBorderGrid(parent)

    local overlay = CreateFrame("Frame", nil, parent)
    overlay:SetAllPoints(parent)
    overlay:SetFrameLevel(parent:GetFrameLevel() + 100)
    overlay:EnableMouse(false)
    overlay.lines = {}

    for _, line in pairs(parent.gridLines) do
        if line.style == "dotted" then
            RegisterPatternedGridLine(overlay, line, DOTTED_GRID_DOT, DOTTED_GRID_GAP)
        elseif line.style == "dashed" then
            RegisterPatternedGridLine(overlay, line, DASHED_GRID_DASH, DASHED_GRID_GAP)
        elseif line.style == "solid" then
            RegisterGridLineTexture(overlay, line)
        else
            RegisterGridLineTexture(overlay, line)
        end
    end

    parent.gridOverlay = overlay
end

local function GetPhysicalSize()
    local width, height
    if GetPhysicalScreenSize then
        width, height = GetPhysicalScreenSize()
    end

    if not width or width <= 0 or not height or height <= 0 then
        local scale = UIParent:GetEffectiveScale()
        local factor = GetPixelToUIUnitFactor()
        width = UIParent:GetWidth() * scale / factor
        height = UIParent:GetHeight() * scale / factor
    end

    return Pixel(width), Pixel(height)
end

local function ApplyPixelRootScale(root)
    local pixelScale = GetPixelToUIUnitFactor()

    if root.SetIgnoreParentScale then
        root:SetIgnoreParentScale(true)
        root:SetScale(pixelScale)
    else
        root:SetScale(pixelScale / UIParent:GetEffectiveScale())
    end
end

local function UpdatePixelRoot(root)
    local width, height = GetPhysicalSize()
    ApplyPixelRootScale(root)
    SetPixelSize(root, width, height)
    root:ClearAllPoints()
    root:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function GetPixelRoot()
    if NS.pixelRoot then
        return NS.pixelRoot
    end

    local root = CreateFrame("Frame", "LootLevelPixelRoot", UIParent)
    root:SetFrameStrata("HIGH")
    root:SetFrameLevel(1)
    UpdatePixelRoot(root)

    root:RegisterEvent("DISPLAY_SIZE_CHANGED")
    root:RegisterEvent("UI_SCALE_CHANGED")
    root:RegisterEvent("PLAYER_ENTERING_WORLD")
    root:SetScript("OnEvent", function(self)
        UpdatePixelRoot(self)
        if NS.frame then
            NS:RestoreFramePosition(NS.frame)
        end
    end)

    NS.pixelRoot = root
    return root
end

local function SnapFramePosition(frame)
    local point, relativeTo, relativePoint, x, y = frame:GetPoint(1)
    frame:ClearAllPoints()
    frame:SetPoint(
        point or "CENTER",
        relativeTo or NS.pixelRoot or UIParent,
        relativePoint or "CENTER",
        Pixel(x),
        Pixel(y)
    )
end

Color = function(name)
    local color = type(name) == "table" and name or NS.Colors[name or "blank"] or NS.Colors.blank
    return color[1], color[2], color[3], color[4] or 1
end

TextColorFor = function(colorName)
    if colorName == "blank" or colorName == "panel" or colorName == "frame" then
        return 1, 1, 1, 1
    end

    return 0, 0, 0, 1
end

local function CreateText(parent, text, size, colorName, justifyH, justifyV, bold)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    RegisterFontRecord({
        fontString = fs,
        path = bold and NS.FONT_BOLD_PATH or NS.FONT_PATH,
        size = size or 12,
        flags = "",
    })
    fs:SetText(text or "")
    fs:SetJustifyH(justifyH or "CENTER")
    fs:SetJustifyV(justifyV or "MIDDLE")
    fs:SetTextColor(Color(colorName or "black"))
    if fs.SetWordWrap then
        fs:SetWordWrap(false)
    end
    return fs
end

local function BuildTooltipLines(cellData, fallbackLabel)
    local lines = cellData.lines
    if lines then
        return lines
    end

    lines = {}
    if cellData.level then
        lines[#lines + 1] = ("Item level: %s"):format(cellData.level)
    end
    if cellData.columnTitle then
        lines[#lines + 1] = ("Column: %s"):format(cellData.columnTitle)
    end
    if cellData.text and cellData.text ~= "" then
        lines[#lines + 1] = ("Value: %s"):format(cellData.text)
    elseif fallbackLabel then
        lines[#lines + 1] = fallbackLabel
    end
    return lines
end

local function FormatGridTooltipLine(cell)
    if cell and cell.gridLabel then
        return cell.gridLabel
    end

    if not cell or not cell.gridCoord or not cell.gridColumn or not cell.gridRow then
        return nil
    end

    local column = string.upper(ColumnName(cell.gridColumn) or "")
    local coord = string.upper(cell.gridCoord)
    local tablePrefix = cell.gridTable and cell.gridTable ~= "main" and (cell.gridTable .. " ") or ""
    return ("Cell: %s%s  Column: %s  Row: %d"):format(tablePrefix, coord, column, cell.gridRow)
end

local function MergeCellData(defaults, source)
    local cellData = {}
    for key, value in pairs(defaults or {}) do
        cellData[key] = value
    end

    if type(source) == "table" then
        for key, value in pairs(source) do
            cellData[key] = value
        end
    end

    return cellData
end

local function GetConfiguredCellData(tableKey, coord)
    local tableCells = NS.Data.cells and NS.Data.cells[tableKey or "main"]
    return tableCells and tableCells[coord] or nil
end

local function ShowCellTooltip(cell)
    local data = cell.cellData or {}
    GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
    GameTooltip:SetText(data.title or data.columnTitle or "LootLevel cell", 1, 1, 1)

    local gridLine = FormatGridTooltipLine(cell)
    if gridLine then
        GameTooltip:AddLine(gridLine, 0.55, 0.75, 1, true)
    end

    local lines = BuildTooltipLines(data)
    for _, line in ipairs(lines) do
        GameTooltip:AddLine(line, 0.85, 0.85, 0.85, true)
    end

    GameTooltip:AddLine("Left-click to select this cell.", 0.45, 0.9, 0.65, true)
    GameTooltip:Show()
end

local function CreateCell(parent, x, y, width, height, cellData)
    cellData = cellData or {}

    local cell = CreateFrame("Button", nil, parent)
    SetLayoutBounds(cell, parent, x, y, width, height)
    cell:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    cell.cellData = cellData

    local bg = cell:CreateTexture(nil, "BACKGROUND")
    ApplyTexturePixelSnapping(bg)
    bg:SetAllPoints(cell)
    bg:SetColorTexture(Color(cellData.color or "blank"))
    cell.bg = bg

    local highlight = cell:CreateTexture(nil, "HIGHLIGHT")
    ApplyTexturePixelSnapping(highlight)
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.22)

    local text = CreateText(cell, cellData.text or "", cellData.fontSize or 12, "black", "CENTER", "MIDDLE", cellData.bold)
    text:SetPoint("CENTER", cell, "CENTER", 0, 0)
    SetLayoutSize(text, math.max(1, width - 4), math.max(1, height - 4))
    text:SetTextColor(TextColorFor(cellData.color))
    cell.text = text

    cell:SetScript("OnEnter", function(self)
        ShowCellTooltip(self)
    end)

    cell:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    cell:SetScript("OnClick", function(self, button)
        local onClick = self.cellData and self.cellData.onClick
        if type(onClick) == "function" then
            onClick(self, button, self.cellData)
            return
        end

        if NS.HandleCellClick then
            NS:HandleCellClick(self.cellData, button)
        end
    end)

    parent.cells[#parent.cells + 1] = cell
    RegisterCellCoordinate(parent, cell, cellData, x, y, width, height)
    return cell
end

local function CreateHeader(parent, x, y, width, height, text, cellData)
    return CreateCell(parent, x, y, width, height, MergeCellData({
        text = text,
        color = "header",
        bold = true,
        fontSize = 13,
        title = text,
        columnTitle = text,
    }, cellData))
end

local function CreateOverlayLabel(parent, x, y, width, height, text, fontSize)
    local fs = CreateText(parent, text, fontSize or 13, "black", "CENTER", "MIDDLE", false)
    SetLayoutBounds(fs, parent, x, y, width, height)

    if fs.SetRotation then
        fs:SetRotation(math.pi / 2)
    else
        fs:SetText((text or ""):gsub("(.)", "%1\n"))
    end

    return fs
end

local function FormatMergedCellRange(mergedCell)
    local startCoord = mergedCell.startCellCoordinate and string.upper(mergedCell.startCellCoordinate)
    local endCoord = mergedCell.endCellCoordinate and string.upper(mergedCell.endCellCoordinate)
    if not startCoord then
        return nil
    end

    if endCoord and endCoord ~= startCoord then
        return ("Merged cell: %s-%s"):format(startCoord, endCoord)
    end

    return ("Merged cell: %s"):format(startCoord)
end

local function GetMergedCellOverlay(parent)
    if parent.mergedCellOverlay then
        return parent.mergedCellOverlay
    end

    local overlay = CreateFrame("Frame", nil, parent)
    overlay:SetAllPoints(parent)
    overlay:SetFrameLevel(parent:GetFrameLevel() + 90)
    overlay:EnableMouse(false)
    parent.mergedCellOverlay = overlay
    return overlay
end

local function CreateMergedCellHitTarget(parent, overlay, x, y, width, height, mergedCell)
    local hitTarget = CreateFrame("Button", nil, overlay)
    SetLayoutBounds(hitTarget, overlay, x, y, width, height)
    hitTarget:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    hitTarget:EnableMouse(true)
    hitTarget:SetFrameLevel(overlay:GetFrameLevel() + 10)

    hitTarget.cellData = {
        text = mergedCell.displayText or "",
        color = mergedCell.backgroundColorKey,
        title = mergedCell.tooltipTitle or mergedCell.displayText or "Merged cell",
        columnTitle = mergedCell.columnTitle or "Merged cell",
        lines = mergedCell.tooltipLines,
        metadata = mergedCell.metadata,
        onClick = mergedCell.onClick,
    }
    hitTarget.gridLabel = FormatMergedCellRange(mergedCell)

    local highlight = hitTarget:CreateTexture(nil, "HIGHLIGHT")
    ApplyTexturePixelSnapping(highlight)
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.22)

    hitTarget:SetScript("OnEnter", function(self)
        ShowCellTooltip(self)
    end)

    hitTarget:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    hitTarget:SetScript("OnClick", function(self, button)
        local onClick = self.cellData and self.cellData.onClick
        if type(onClick) == "function" then
            onClick(self, button, self.cellData)
            return
        end

        if NS.HandleCellClick then
            NS:HandleCellClick(self.cellData, button)
        end
    end)

    return hitTarget
end

local function CreateMergedCellLabel(parent, mergedCell)
    local tableKey = mergedCell.tableKey or "main"
    local startCell = GetCellByCoord(parent, tableKey, mergedCell.startCellCoordinate)
    local endCell = GetCellByCoord(parent, tableKey, mergedCell.endCellCoordinate or mergedCell.startCellCoordinate)
    if not startCell or not endCell or not startCell.gridBounds or not endCell.gridBounds then
        return
    end

    local startBounds = startCell.gridBounds
    local endBounds = endCell.gridBounds
    local x1 = math.min(startBounds.x, endBounds.x)
    local y1 = math.min(startBounds.y, endBounds.y)
    local x2 = math.max(startBounds.x + startBounds.width, endBounds.x + endBounds.width)
    local y2 = math.max(startBounds.y + startBounds.height, endBounds.y + endBounds.height)
    local overlay = GetMergedCellOverlay(parent)

    if mergedCell.backgroundColorKey then
        local background = overlay:CreateTexture(nil, "BACKGROUND")
        ApplyTexturePixelSnapping(background)
        background:SetColorTexture(Color(mergedCell.backgroundColorKey))
        SetLayoutBounds(background, overlay, x1, y1, x2 - x1, y2 - y1)
    end

    if mergedCell.isTextVertical ~= false then
        CreateOverlayLabel(overlay, x1, y1, x2 - x1, y2 - y1, mergedCell.displayText, mergedCell.fontSize or 13)
    else
        local fs = CreateText(overlay, mergedCell.displayText, mergedCell.fontSize or 13, "black", "CENTER", "MIDDLE", false)
        SetLayoutBounds(fs, overlay, x1, y1, x2 - x1, y2 - y1)
    end

    CreateMergedCellHitTarget(parent, overlay, x1, y1, x2 - x1, y2 - y1, mergedCell)
end

local function DrawMergedCells(parent)
    for _, mergedCell in ipairs(NS.Data.mergedCells or {}) do
        CreateMergedCellLabel(parent, mergedCell)
    end
end

local LEFT_TABLE_COLUMNS = {
    { columnIndex = 1, width = 62, title = "Level", defaultColor = "light", bold = true },
    { columnIndex = 2, width = 46, title = "Loot", defaultColor = "blank" },
    { columnIndex = 3, width = 46, title = "Loot upgrade", defaultColor = "blank" },
    { columnIndex = 4, width = 46, title = "Great Vault", defaultColor = "blank" },
    { columnIndex = 5, width = 46, title = "Great Vault upgrade", defaultColor = "blank" },
    { columnIndex = 6, width = 62, title = "Crest", defaultColor = "blank" },
    { columnIndex = 7, width = 26, title = "Section", defaultColor = "blank" },
}

local function CreateLeftGridRow(parent, x, y, gridRow)
    local colX = x
    for _, column in ipairs(LEFT_TABLE_COLUMNS) do
        local coord = CoordFromIndex(column.columnIndex, gridRow)
        local data = GetConfiguredCellData("left", coord) or {}
        CreateCell(parent, colX, y, column.width, ROW_HEIGHT, MergeCellData({
            tableKey = "left",
            coord = coord,
            text = data.text or "",
            color = data.color or column.defaultColor,
            bold = column.bold,
            title = data.title or ("Left table row %d - %s"):format(gridRow, column.title),
            columnTitle = column.title,
        }, data))
        colX = colX + column.width
    end
end

local function BuildLeftTable(parent, x, y)
    local worldBodyY = y + HEADER_HEIGHT
    local leftLayout = NS.Data.leftLayout or {}
    local worldRows = leftLayout.worldRowCount or 19
    local worldHeight = worldRows * ROW_HEIGHT
    local delveBodyY = worldBodyY + worldHeight + (ROW_HEIGHT * 2)
    local delveRows = leftLayout.delveRowCount or 11
    local delveStartRow = leftLayout.delveStartRow or (worldRows + 5)

    CreateHeader(parent, x, y, 62, HEADER_HEIGHT, "Level", { tableKey = "left", coord = "a1" })
    CreateHeader(parent, x + 62, y, 92, HEADER_HEIGHT, "Loot", { tableKey = "left", coord = "b1" })
    CreateHeader(parent, x + 154, y, 92, HEADER_HEIGHT, "GV", { tableKey = "left", coord = "d1" })
    CreateHeader(parent, x + 246, y, 62, HEADER_HEIGHT, "Crest", { tableKey = "left", coord = "f1" })
    CreateHeader(parent, x + 308, y, 26, HEADER_HEIGHT, "", { tableKey = "left", coord = "g1" })

    local rowY = worldBodyY
    for index = 1, worldRows do
        CreateLeftGridRow(parent, x, rowY + ((index - 1) * ROW_HEIGHT), index + 1)
    end

    rowY = delveBodyY
    for index = 1, delveRows do
        CreateLeftGridRow(parent, x, rowY + ((index - 1) * ROW_HEIGHT), delveStartRow + index - 1)
    end
end

local function BuildMainTable(parent, x, y)
    local bodyY = y + HEADER_HEIGHT

    local headerX = x
    CreateHeader(parent, headerX, y, 46, HEADER_HEIGHT, "ilvl", { coord = "a1" })
    headerX = headerX + 46
    CreateHeader(parent, headerX, y, RAID_SUB_WIDTH * 6, HEADER_HEIGHT, "Raid Difficulty / Track", { coord = "b1" })
    headerX = headerX + (RAID_SUB_WIDTH * 6)
    CreateHeader(parent, headerX, y, CRAFT_SUB_WIDTH * 2, HEADER_HEIGHT, "Craft", { coord = "h1" })
    headerX = headerX + (CRAFT_SUB_WIDTH * 2)
    CreateHeader(parent, headerX, y, 62, HEADER_HEIGHT, "Prey", { coord = "j1" })
    headerX = headerX + 62
    CreateHeader(parent, headerX, y, 62, HEADER_HEIGHT, "Delve", { coord = "k1" })
    headerX = headerX + 62
    CreateHeader(parent, headerX, y, 62, HEADER_HEIGHT, "Map", { coord = "l1" })
    headerX = headerX + 62
    CreateHeader(parent, headerX, y, 62, HEADER_HEIGHT, "GV", { coord = "m1" })
    headerX = headerX + 62
    CreateHeader(parent, headerX, y, 62, HEADER_HEIGHT, "Dung.", { coord = "n1" })
    headerX = headerX + 62
    CreateHeader(parent, headerX, y, 62, HEADER_HEIGHT, "GV", { coord = "o1" })
    headerX = headerX + 62
    CreateHeader(parent, headerX, y, 46, HEADER_HEIGHT, "ilvl", { coord = "p1" })

    for rowIndex, level in ipairs(NS.Data.levels) do
        local rowY = bodyY + ((rowIndex - 1) * ROW_HEIGHT)
        local gridRow = rowIndex + 1
        local colX = x

        CreateCell(parent, colX, rowY, 46, ROW_HEIGHT, {
            coord = CoordFromIndex(1, gridRow),
            text = tostring(level),
            color = "light",
            bold = true,
            level = level,
            title = ("Item level %s"):format(level),
            columnTitle = "Item level",
        })
        colX = colX + 46

        for column = 1, 6 do
            local coord = CoordFromIndex(column + 1, gridRow)
            local data = GetConfiguredCellData("main", coord) or {}
            CreateCell(parent, colX, rowY, RAID_SUB_WIDTH, ROW_HEIGHT, MergeCellData({
                coord = coord,
                text = data.text or "",
                color = data.color or "blank",
                level = level,
                title = data.title or ("Raid / track at item level %s"):format(level),
                columnTitle = "Raid Difficulty / Track",
                lines = data.lines,
            }, data))
            colX = colX + RAID_SUB_WIDTH
        end

        for column = 1, 2 do
            local coord = CoordFromIndex(column + 7, gridRow)
            local data = GetConfiguredCellData("main", coord) or {}
            CreateCell(parent, colX, rowY, CRAFT_SUB_WIDTH, ROW_HEIGHT, MergeCellData({
                coord = coord,
                text = data.text or "",
                color = data.color or "blank",
                level = level,
                title = data.title or ("Crafting at item level %s"):format(level),
                columnTitle = "Craft",
            }, data))
            colX = colX + CRAFT_SUB_WIDTH
        end

        local activityOrder = {
            { key = "prey", title = "Prey" },
            { key = "delve", title = "Delve" },
            { key = "map", title = "Map" },
            { key = "outdoorVault", title = "Great Vault" },
            { key = "dungeon", title = "Dungeon" },
            { key = "dungeonVault", title = "Dungeon Great Vault" },
        }

        for activityIndex, column in ipairs(activityOrder) do
            local coord = CoordFromIndex(activityIndex + 9, gridRow)
            local data = GetConfiguredCellData("main", coord) or {}
            CreateCell(parent, colX, rowY, 62, ROW_HEIGHT, MergeCellData({
                coord = coord,
                text = data.text or "",
                color = data.color or "blank",
                level = level,
                title = data.title or ("%s at item level %s"):format(column.title, level),
                columnTitle = column.title,
            }, data))
            colX = colX + 62
        end

        CreateCell(parent, colX, rowY, 46, ROW_HEIGHT, {
            coord = CoordFromIndex(16, gridRow),
            text = tostring(level),
            color = "light",
            bold = true,
            level = level,
            title = ("Item level %s"):format(level),
            columnTitle = "Item level",
        })
    end

end

local function BuildFooter(parent)
    local footer = CreateFrame("Frame", nil, parent)
    SetLayoutPoints(footer, {
        { point = "BOTTOMLEFT", relativeTo = parent, relativePoint = "BOTTOMLEFT", x = PADDING, y = 8 },
        { point = "BOTTOMRIGHT", relativeTo = parent, relativePoint = "BOTTOMRIGHT", x = -PADDING, y = 8 },
    }, nil, 22)

    local left = CreateText(footer, NS.Data.footerLeft, 12, "white", "LEFT", "MIDDLE", false)
    SetLayoutBox(left, "LEFT", footer, "LEFT", 0, 0, 720, 20)

    local right = CreateText(footer, NS.Data.footerRight, 12, "white", "RIGHT", "MIDDLE", false)
    SetLayoutBox(right, "RIGHT", footer, "RIGHT", 0, 0, 410, 20)
end

local function CreateScaleButton(parent)
    local button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    SetLayoutBox(button, "TOPRIGHT", parent, "TOPRIGHT", -38, -7, 46, 20)

    if button.SetBackdrop then
        button:SetBackdrop(FRAME_BACKDROP)
        button:SetBackdropColor(0.18, 0.18, 0.18, 0.95)
        button:SetBackdropBorderColor(0, 0, 0, 1)
    end

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    ApplyTexturePixelSnapping(highlight)
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.18)

    local label = CreateText(button, FormatScalePercent(GetScalePercent()), 10, "white", "CENTER", "MIDDLE", true)
    SetLayoutBox(label, "CENTER", button, "CENTER", 0, 0, 42, 16)
    NS.scaleButtonText = label
    NS.scaleButton = button

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Scale", 1, 1, 1)
        GameTooltip:AddLine("Drag to resize the table in pixel-snapped steps.", 0.85, 0.85, 0.85, true)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local slider = LibStub and LibStub("LibPopupSlider-1.0", true)
    if slider then
        local popup = slider:Create(button, {
            minValue = SCALE_MIN_PERCENT,
            maxValue = SCALE_MAX_PERCENT,
            step = SCALE_STEP_PERCENT,
            label = "Scale",
            formatValue = FormatScalePercent,
            sliderHeight = 130,
            popupWidth = 48,
            thumbSize = 18,
            markerSize = 6,
            font = NS.FONT_BOLD_PATH,
            fontFlags = "",
            fontSize = 10,
            valueFitText = "200%",
            onValueChanged = function(value)
                NS:SetFrameScalePercent(value)
            end,
        })
        popup:SetValue(GetScalePercent(), true)
        NS.scalePopup = popup
    else
        button:SetScript("OnMouseDown", function()
            NS:Print("LibPopupSlider-1.0 is not loaded.")
        end)
    end

    return button
end

function NS:HandleCellClick(cellData, button)
    local label = cellData.title or cellData.columnTitle or "cell"
    if button == "RightButton" then
        self:Print(("Right-clicked %s."):format(label))
    else
        self:Print(("Selected %s."):format(label))
    end
end

function NS:SetFrameScalePercent(value, silent)
    if not self.db then
        return
    end

    local percent = NormalizeScalePercent(value)
    self.db.scalePercent = percent

    RefreshScaledLayout()

    if self.scalePopup then
        self.scalePopup:SetValue(percent, true)
    end

    if self.frame then
        SnapFramePosition(self.frame)
        if not silent then
            self:SaveFramePosition(self.frame)
        end
    end
end

function NS:CreateMainFrame()
    if self.frame then
        return self.frame
    end

    local pixelRoot = GetPixelRoot()
    local frame = CreateFrame("Frame", "LootLevelFrame", pixelRoot, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetScale(1)
    self.db.scalePercent = NormalizeScalePercent(self.db.scalePercent)
    self.layoutRecords = {}
    self.layoutFonts = {}
    SetLayoutSize(frame, FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame.cells = {}

    if frame.SetBackdrop then
        frame:SetBackdrop(FRAME_BACKDROP)
        frame:SetBackdropColor(Color("frame"))
        frame:SetBackdropBorderColor(0.02, 0.02, 0.02, 1)
    end

    self:RestoreFramePosition(frame)
    frame:Hide()

    frame:SetScript("OnDragStart", function(selfFrame)
        if not NS.db or not NS.db.locked then
            selfFrame:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        SnapFramePosition(selfFrame)
        NS:SaveFramePosition(selfFrame)
    end)

    frame:SetScript("OnShow", function()
        if NS.db then
            NS.db.shown = true
        end
    end)

    frame:SetScript("OnHide", function()
        if NS.db then
            NS.db.shown = false
        end
    end)

    local title = CreateText(frame, "LootLevel", 15, "white", "LEFT", "MIDDLE", true)
    SetLayoutBox(title, "TOPLEFT", frame, "TOPLEFT", PADDING, -6, 240, TITLE_HEIGHT - 4)

    local version = CreateText(frame, self.version or "", 11, "muted", "RIGHT", "MIDDLE", false)
    SetLayoutBox(version, "TOPRIGHT", frame, "TOPRIGHT", -92, -6, 160, TITLE_HEIGHT - 4)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    SetLayoutBox(close, "TOPRIGHT", frame, "TOPRIGHT", -4, -4, 28, 28)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    CreateScaleButton(frame)

    local content = CreateFrame("Frame", nil, frame)
    SetLayoutBox(content, "TOPLEFT", frame, "TOPLEFT", PADDING, -(TITLE_HEIGHT + 8), FRAME_WIDTH - (PADDING * 2), FRAME_HEIGHT - TITLE_HEIGHT - 42)
    content.cells = frame.cells

    BuildLeftTable(content, 0, 0)
    BuildMainTable(content, LEFT_WIDTH + GAP, 0)
    DrawMergedCells(content)
    DrawGridLines(content)
    BuildFooter(frame)

    self.frame = frame
    table.insert(UISpecialFrames, "LootLevelFrame")

    return frame
end

function NS:ShowMainFrame()
    if not self.frame then
        self:CreateMainFrame()
    end
    self.frame:Show()
end

function NS:HideMainFrame()
    if self.frame then
        self.frame:Hide()
    end
end

function NS:ToggleMainFrame()
    if not self.frame then
        self:CreateMainFrame()
    end

    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

function NS:ResetMainFramePosition()
    if not self.frame then
        self:CreateMainFrame()
    end

    self.db.position = {
        point = "CENTER",
        relPoint = "CENTER",
        x = 0,
        y = 0,
    }
    self:RestoreFramePosition(self.frame)
    self:Print("Frame position reset.")
end
