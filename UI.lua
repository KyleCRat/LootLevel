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
local CELL_BORDER_PRIORITY = 120
local CELL_BORDER_ORDER = 0

local FRAME_WIDTH = 1180
local FRAME_HEIGHT = 760
local PADDING = 14
local TITLE_HEIGHT = 28
local HEADER_HEIGHT = 24
local ROW_HEIGHT = 24
local SCALE_MIN_PERCENT = 50
local SCALE_MAX_PERCENT = 200
local SCALE_STEP_PERCENT = 5
local SCALE_DEFAULT_PERCENT = 100

local MERGED_VERTICAL_LABEL_NUDGE_X = -6
local MERGED_VERTICAL_LABEL_NUDGE_Y = 7
local MERGED_VERTICAL_LABEL_WIDTH_PADDING = 12
local MERGED_VERTICAL_LABEL_HEIGHT_PADDING = 2

local STYLE_LAYER_DEFAULT = 10
local STYLE_LAYER_LAYER = 15
local STYLE_LAYER_BLOCK = 20
local STYLE_LAYER_CELL = 30
local ACTIVE_LAYER_ORDER_BONUS = 100000
local DEFAULT_INACTIVE_LAYER_ALPHA = 0.3

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
    fontString:SetFont(record.path, size, record.flags or "")
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

local VALID_FONT_FLAGS = {
    [""] = true,
    OUTLINE = true,
    THICKOUTLINE = true,
    OUTLINESLUG = true,
    MONOCHROMEOUTLINE = true,
    MONOCHROMETHICKOUTLINE = true,
}

local function NormalizeFontFlagString(value)
    local flags = tostring(value or ""):upper():gsub("[%s,]+", "")
    if VALID_FONT_FLAGS[flags] then
        return flags
    end

    return ""
end

local function NormalizeFontOutline(value)
    if value == true then
        return "OUTLINE"
    end
    if value == false or value == nil then
        return ""
    end

    local outline = tostring(value):lower()
    if outline == "normal" or outline == "outline" then
        return "OUTLINE"
    end
    if outline == "thick" or outline == "thickoutline" then
        return "THICKOUTLINE"
    end
    if outline == "slug" or outline == "outlineslug" then
        return "OUTLINESLUG"
    end
    if outline == "mono" or outline == "monochrome" or outline == "monochromeoutline" then
        return "MONOCHROMEOUTLINE"
    end
    if outline == "monothick" or outline == "monochromethick" or outline == "monochromethickoutline" then
        return "MONOCHROMETHICKOUTLINE"
    end

    return ""
end

local function FontFlags(font)
    if type(font) ~= "table" then
        return ""
    end

    if font.flags ~= nil then
        return NormalizeFontFlagString(font.flags)
    end

    local outlineValue = font.outline
    if outlineValue == nil then
        outlineValue = font.border
    end

    local outline = NormalizeFontOutline(outlineValue)
    local monochrome = font.monochrome == true
    local slug = font.slug == true

    if outline == "OUTLINESLUG" or outline == "MONOCHROMEOUTLINE" or outline == "MONOCHROMETHICKOUTLINE" then
        return outline
    end

    if monochrome then
        if outline == "THICKOUTLINE" then
            return "MONOCHROMETHICKOUTLINE"
        end
        if outline == "OUTLINE" then
            return "MONOCHROMEOUTLINE"
        end
        return ""
    end

    if outline == "THICKOUTLINE" then
        return "THICKOUTLINE"
    end
    if outline == "OUTLINE" then
        return slug and "OUTLINESLUG" or "OUTLINE"
    end

    return ""
end

local function FontSize(font, fallbackSize)
    if type(font) == "table" then
        return tonumber(font.size) or fallbackSize
    end

    return fallbackSize
end

local function FontWithFallbackSize(font, fallbackSize)
    if type(font) ~= "table" then
        return { size = fallbackSize }
    end

    local copy = {}
    for key, value in pairs(font) do
        copy[key] = value
    end
    if copy.size == nil then
        copy.size = fallbackSize
    end

    return copy
end

local function ResolveTextFont(font, fallbackSize, bold)
    local size = math.max(1, FontSize(font, fallbackSize or 12))
    local path = bold and NS.FONT_BOLD_PATH or NS.FONT_PATH
    if type(font) == "table" and type(font.path) == "string" then
        path = font.path
    end

    return {
        path = path,
        size = size,
        flags = FontFlags(font),
    }
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

    for _, scrollFrame in ipairs(NS.tableBodyScrolls or {}) do
        local range = scrollFrame:GetVerticalScrollRange() or 0
        local current = scrollFrame:GetVerticalScroll() or 0
        scrollFrame:SetVerticalScroll(Clamp(current, 0, range))
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
    texture:SetColorTexture(GRID_COLOR[1], GRID_COLOR[2], GRID_COLOR[3], line.alpha or GRID_COLOR[4])
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
                alpha = line.alpha,
            }
        else
            segmentLine = {
                vertical = false,
                y = line.y,
                x1 = line.x1 + offset,
                x2 = line.x1 + segmentEnd,
                thickness = line.thickness,
                alpha = line.alpha,
            }
        end

        RegisterGridLineTexture(overlay, segmentLine)
        offset = offset + segmentLength + segmentGap
    end
end

local function RegisterStyledGridLine(overlay, line)
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

local function NormalizeCellSpan(anchorColumn, anchorRow, definition)
    local fromColumn = tonumber(definition and (definition.gridFromColumn or definition.fromColumn)) or anchorColumn
    local toColumn = tonumber(definition and (definition.gridToColumn or definition.toColumn)) or anchorColumn
    local fromRow = tonumber(definition and (definition.gridFromRow or definition.fromRow)) or anchorRow
    local toRow = tonumber(definition and (definition.gridToRow or definition.toRow)) or anchorRow

    if not fromColumn or not toColumn or not fromRow or not toRow then
        return nil
    end

    if fromColumn > toColumn then
        fromColumn, toColumn = toColumn, fromColumn
    end
    if fromRow > toRow then
        fromRow, toRow = toRow, fromRow
    end

    return {
        fromColumn = fromColumn,
        toColumn = toColumn,
        fromRow = fromRow,
        toRow = toRow,
    }
end

local function ForEachCellSpanCoord(span, callback)
    if not span or type(callback) ~= "function" then
        return
    end

    for row = span.fromRow, span.toRow do
        for column = span.fromColumn, span.toColumn do
            callback(column, row, CoordFromIndex(column, row))
        end
    end
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

    local tableKey = cellData.table or "main"
    local column, row = ParseCoord(coord)
    if not column or not row then
        return
    end

    parent.cellsByCoord = parent.cellsByCoord or {}

    local grid = EnsureGrid(parent, tableKey)
    local span = NormalizeCellSpan(column, row, cellData.span or cellData)
    if not span then
        return
    end

    ForEachCellSpanCoord(span, function(gridColumn, gridRow, spanCoord)
        local key = CoordKey(tableKey, spanCoord)
        if key then
            parent.cellsByCoord[key] = cell
        end
        grid.rows[gridRow] = grid.rows[gridRow] or {}
        grid.rows[gridRow][gridColumn] = cell
    end)

    cell.coordKey = CoordKey(tableKey, coord)
    cell.gridTable = tableKey
    cell.gridCoord = coord
    cell.gridColumn = column
    cell.gridFromColumn = span.fromColumn
    cell.gridToColumn = span.toColumn
    cell.gridRow = row
    cell.gridFromRow = span.fromRow
    cell.gridToRow = span.toRow
    cell.gridSpan = span
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
    line.alpha = borderStyle.alpha or GRID_COLOR[4]

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
        column = (cell.gridFromColumn or column) - 1
    elseif edge == "right" then
        column = (cell.gridToColumn or column) + 1
    elseif edge == "top" then
        row = (cell.gridFromRow or row) - 1
    elseif edge == "bottom" then
        row = (cell.gridToRow or row) + 1
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

local function LayerData(layerKey)
    return layerKey and NS.Data and NS.Data.layers and NS.Data.layers[layerKey] or nil
end

local function LayerSetData(layerSetKey)
    return layerSetKey and NS.Data and NS.Data.layerSets and NS.Data.layerSets[layerSetKey] or nil
end

local function NormalizeLayerSetKey(layerSetKey)
    if layerSetKey == nil then
        return nil
    end

    local requested = tostring(layerSetKey):lower()
    for _, layerSet in ipairs((NS.Data and NS.Data.layerSetOrder) or {}) do
        local key = layerSet.key or layerSet.id
        local name = layerSet.name
        if (key and tostring(key):lower() == requested)
            or (name and tostring(name):lower() == requested)
        then
            return key
        end
    end

    return nil
end

local function DefaultLayerSetKey()
    if NS.Data and NS.Data.defaultLayerSet then
        return NS.Data.defaultLayerSet
    end

    local layerSet = NS.Data and NS.Data.layerSetOrder and NS.Data.layerSetOrder[1]
    return layerSet and (layerSet.key or layerSet.id) or nil
end

local function LayerSetKeyForLayer(layerKey)
    local layer = LayerData(layerKey)
    if layer and layer.layerSet then
        return layer.layerSet
    end

    return layerKey and NS.Data and NS.Data.layerSetByLayerKey and NS.Data.layerSetByLayerKey[layerKey] or nil
end

local function NormalizeLayerKey(layerKey)
    if layerKey == nil then
        return nil
    end

    local requested = tostring(layerKey):lower()
    for _, layer in ipairs((NS.Data and NS.Data.layerOrder) or {}) do
        local key = layer.key or layer.id
        local name = layer.name
        if (key and tostring(key):lower() == requested)
            or (name and tostring(name):lower() == requested)
        then
            return key
        end
    end

    return nil
end

local function LayerDisplayName(layerKey)
    local layer = LayerData(layerKey)
    return layer and (layer.name or layer.key or layer.id) or layerKey
end

local function LayerBelongsToSet(layerKey, layerSetKey)
    if not layerSetKey then
        return true
    end

    return LayerSetKeyForLayer(layerKey) == layerSetKey
end

local function GetLayerSetDefaultLayer(layerSetKey)
    local layerSet = LayerSetData(layerSetKey)
    local defaultLayer = layerSet and layerSet.defaultLayer
    if not defaultLayer and NS.Data and NS.Data.defaultActiveLayers then
        defaultLayer = NS.Data.defaultActiveLayers[layerSetKey]
    end

    return NormalizeLayerKey(defaultLayer)
end

local function GetActiveLayerKey(layerSetKey)
    layerSetKey = NormalizeLayerSetKey(layerSetKey) or layerSetKey

    local activeLayers = NS.db and NS.db.activeLayers
    if type(activeLayers) == "table" and layerSetKey then
        local normalized = NormalizeLayerKey(activeLayers[layerSetKey])
        if normalized and LayerBelongsToSet(normalized, layerSetKey) then
            return normalized
        end
    end

    local legacyLayer = NormalizeLayerKey(NS.db and NS.db.activeLayer)
    if legacyLayer and LayerBelongsToSet(legacyLayer, layerSetKey) then
        return legacyLayer
    end

    if layerSetKey then
        local defaultLayer = GetLayerSetDefaultLayer(layerSetKey)
        if defaultLayer then
            return defaultLayer
        end
    end

    local normalized = NormalizeLayerKey(NS.Data and NS.Data.defaultActiveLayer)
    if normalized then
        return normalized
    end

    return nil
end

local function IsLayerActive(layerKey)
    local activeLayer = GetActiveLayerKey(LayerSetKeyForLayer(layerKey))
    return activeLayer ~= nil and layerKey ~= nil and layerKey == activeLayer
end

local function LayerRenderOrder(layerKey)
    local layer = LayerData(layerKey)
    local order = tonumber(layer and layer.order) or 0
    if IsLayerActive(layerKey) then
        order = order + ACTIVE_LAYER_ORDER_BONUS
    end

    return order
end

local function LayerVisualAlpha(layerKey)
    if not layerKey then
        return 1
    end

    local layer = LayerData(layerKey)
    if not layer then
        return 1
    end

    local activeLayer = GetActiveLayerKey(LayerSetKeyForLayer(layerKey))
    if not activeLayer then
        return 1
    end

    if IsLayerActive(layerKey) then
        return Clamp(tonumber(layer and layer.activeAlpha) or 1, 0, 1)
    end

    return Clamp(tonumber(layer and layer.inactiveAlpha) or DEFAULT_INACTIVE_LAYER_ALPHA, 0, 1)
end

local function IsLayerVisible(layerKey)
    local layer = LayerData(layerKey)
    return not layer or layer.visible ~= false or IsLayerActive(layerKey)
end

local function BlockWinsOver(existing, candidate)
    if not existing then
        return true
    end

    local existingLayerOrder = LayerRenderOrder(existing.layer)
    local candidateLayerOrder = LayerRenderOrder(candidate.layer)
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

local function SetCellStyleLayer(cellData, layerKey, specificity, values)
    if not cellData or not layerKey or type(values) ~= "table" then
        return
    end

    cellData.styleLayers = cellData.styleLayers or {}
    local layer = cellData.styleLayers[layerKey] or {}
    layer.specificity = specificity or layer.specificity or 0

    for key, value in pairs(values) do
        if value ~= nil then
            layer[key] = value
        end
    end

    cellData.styleLayers[layerKey] = layer
end

local function ResolveCellStyleValue(cellData, valueKey)
    local bestValue
    local bestSpecificity = -1

    for _, layer in pairs((cellData and cellData.styleLayers) or {}) do
        local value = layer[valueKey]
        local specificity = layer.specificity or 0
        if value ~= nil and specificity >= bestSpecificity then
            bestValue = value
            bestSpecificity = specificity
        end
    end

    return bestValue
end

local function ResolveCellBackgroundColor(cellData)
    return ResolveCellStyleValue(cellData, "bg") or "blank"
end

local function ResolveCellVisualAlpha(cellData)
    local alpha = tonumber(ResolveCellStyleValue(cellData, "alpha"))
    if alpha == nil then
        return 1
    end

    return Clamp(alpha, 0, 1)
end

local function ApplyCellResolvedStyle(cell)
    local cellData = cell and cell.cellData
    if not cellData then
        return
    end

    local bg = ResolveCellBackgroundColor(cellData)
    local alpha = ResolveCellVisualAlpha(cellData)
    cellData.resolvedBg = bg
    cellData.resolvedAlpha = alpha

    if cell.bg then
        cell.bg:SetColorTexture(Color(bg))
    end
    if cell.text then
        cell.text:SetTextColor(TextColorFor(bg))
    end
    if cell.SetAlpha then
        cell:SetAlpha(alpha)
    end
end

local function AssignCellToBlock(parent, cell, block)
    if not cell or not block or not cell.coordKey then
        return
    end

    if not IsLayerVisible(block.layer) then
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
    cell.cellData.layerName = LayerDisplayName(block.layer)

    if cell.cellData.styleLayers then
        cell.cellData.styleLayers.layer = nil
        cell.cellData.styleLayers.block = nil
    end

    if block.layer then
        SetCellStyleLayer(cell.cellData, "layer", STYLE_LAYER_LAYER, {
            alpha = LayerVisualAlpha(block.layer),
        })
    end

    if block.bg then
        SetCellStyleLayer(cell.cellData, "block", STYLE_LAYER_BLOCK, {
            bg = block.bg,
        })
    end

    ApplyCellResolvedStyle(cell)
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

    local alpha = LayerVisualAlpha(block and block.layer)
    if alpha >= 1 then
        return style
    end

    local copy = {}
    for key, value in pairs(style) do
        copy[key] = value
    end
    copy.alpha = alpha
    return copy
end

local function RelatedBlockBorderStyle(block, neighborBlock, style)
    if not style then
        return nil
    end

    local alpha = math.min(LayerVisualAlpha(block and block.layer), LayerVisualAlpha(neighborBlock and neighborBlock.layer))
    if alpha >= 1 then
        return style
    end

    local copy = {}
    for key, value in pairs(style) do
        copy[key] = value
    end
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
                local innerBorderStyle, isRelatedBlock = GetRelatedBlockInnerBorderStyle(block, neighborBlock)
                if isRelatedBlock then
                    if innerBorderStyle then
                        StoreGridLine(parent, GetCellEdgeLine(cell, edge), RelatedBlockBorderStyle(block, neighborBlock, innerBorderStyle))
                    else
                        StoreGridLine(parent, GetCellEdgeLine(cell, edge), {
                            style = "none",
                            priority = BLOCK_BORDER_PRIORITY + MaxBlockPriority(block, neighborBlock),
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
    local style = CopyBorderStyle(rule.style, rule.priority or EXPLICIT_BORDER_PRIORITY, order)
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

    return CELL_BORDER_PRIORITY
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
                                }, CELL_BORDER_ORDER)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function ShouldApplyRuleToTable(rule, tableKey)
    local requested = rule.tables or rule.table
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

local function GridRowBounds(grid)
    local firstRow
    local lastRow

    for row in pairs((grid and grid.rows) or {}) do
        if not firstRow or row < firstRow then
            firstRow = row
        end
        if not lastRow or row > lastRow then
            lastRow = row
        end
    end

    return firstRow, lastRow
end

local function GridColumnBounds(columns)
    local firstColumn
    local lastColumn

    for column in pairs(columns or {}) do
        if not firstColumn or column < firstColumn then
            firstColumn = column
        end
        if not lastColumn or column > lastColumn then
            lastColumn = column
        end
    end

    return firstColumn, lastColumn
end

local function StoreRowCellsEdge(parent, columns, edge, rule, order)
    for _, cell in pairs(columns or {}) do
        StoreExplicitEdge(parent, cell, edge, rule, order)
    end
end

local function ApplyTableBorderRule(parent, rule, order)
    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            local firstRow, lastRow = GridRowBounds(grid)
            if firstRow and lastRow then
                for _, columns in pairs(grid.rows or {}) do
                    local firstColumn, lastColumn = GridColumnBounds(columns)
                    if firstColumn and lastColumn then
                        StoreExplicitEdge(parent, columns[firstColumn], "left", rule, order)
                        StoreExplicitEdge(parent, columns[lastColumn], "right", rule, order)
                    end
                end

                if firstRow == 1 then
                    StoreRowCellsEdge(parent, grid.rows[firstRow], "top", rule, order)
                end
                if lastRow > 1 then
                    StoreRowCellsEdge(parent, grid.rows[lastRow], "bottom", rule, order)
                end
            end
        end
    end
end

local function ApplyRowBordersRule(parent, rule, order)
    for tableKey, grid in pairs(parent.gridTables or {}) do
        if ShouldApplyRuleToTable(rule, tableKey) then
            for row, columns in pairs(grid.rows or {}) do
                local fromRow = tonumber(rule.fromRow)
                local toRow = tonumber(rule.toRow or fromRow)
                if not fromRow or (row >= fromRow and row <= toRow) then
                    local isExplicitRowRule = fromRow and toRow
                    for column, cell in pairs(columns) do
                        local nextRow = grid.rows[row + 1]
                        if isExplicitRowRule or (nextRow and nextRow[column] and nextRow[column] ~= cell) then
                            StoreExplicitEdge(parent, cell, "bottom", rule, order)
                        end
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
                for column, cell in pairs(columns) do
                    local nextCell = columns[column + 1]
                    if nextCell and nextCell ~= cell then
                        StoreExplicitEdge(parent, cell, "right", rule, order)
                    end
                end
            end
        end
    end
end

local function ApplyBetweenCellsBorderRule(parent, rule, order)
    local tableKey = rule.table or "main"
    local leftColumn, leftRow, leftCoord = ParseCoord(rule.fromCoord)
    local rightColumn, rightRow, rightCoord = ParseCoord(rule.toCoord)
    if not leftColumn or not rightColumn or not leftRow or not rightRow then
        return
    end

    local firstCell = GetCellByCoord(parent, tableKey, leftCoord)
    local secondCell = GetCellByCoord(parent, tableKey, rightCoord)
    if not firstCell or not secondCell then
        return
    end
    if firstCell == secondCell then
        return
    end

    if leftRow == rightRow and math.abs(leftColumn - rightColumn) == 1 then
        StoreExplicitEdge(parent, firstCell, leftColumn < rightColumn and "right" or "left", rule, order)
    elseif leftColumn == rightColumn and math.abs(leftRow - rightRow) == 1 then
        StoreExplicitEdge(parent, firstCell, leftRow < rightRow and "bottom" or "top", rule, order)
    end
end

local function ApplyColumnBorderRule(parent, rule, order)
    local tableKey = rule.table or "main"
    local edge = "right"
    local column = ColumnIndex(rule.afterCol)
    if rule.beforeCol then
        edge = "left"
        column = ColumnIndex(rule.beforeCol)
    end
    if not column or column < 1 then
        return
    end

    local grid = parent.gridTables and parent.gridTables[tableKey]
    local fromRow = tonumber(rule.fromRow)
    local toRow = tonumber(rule.toRow)
    if not fromRow or not toRow then
        local firstGridRow, lastGridRow = GridRowBounds(grid)
        fromRow = fromRow or firstGridRow
        toRow = toRow or lastGridRow
    end

    if not fromRow or not toRow then
        return
    end

    if fromRow > toRow then
        fromRow, toRow = toRow, fromRow
    end

    for row = fromRow, toRow do
        local cell = grid and grid.rows[row] and grid.rows[row][column]
        StoreExplicitEdge(parent, cell, edge, rule, order)
    end
end

local function ApplyRowBorderRule(parent, rule, order)
    local tableKey = rule.table or "main"
    local row = tonumber(rule.row)
    local edge = "bottom"
    if rule.edge == "top" then
        edge = "top"
    end
    if not row then
        return
    end

    local fromColumn = ColumnIndex(rule.fromCol)
    local toColumn = ColumnIndex(rule.toCol or rule.fromCol)
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
        if rule.kind == "rowBorders" then
            ApplyRowBordersRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.kind == "columnBorders" then
            ApplyColumnBordersRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.kind == "tableBorder" then
            ApplyTableBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.kind == "betweenCellsBorder" then
            ApplyBetweenCellsBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.kind == "columnBorder" then
            ApplyColumnBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
        elseif rule.kind == "rowBorder" then
            ApplyRowBorderRule(parent, rule, EXPLICIT_BORDER_PRIORITY + index)
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

local function RegisterGridParent(parent)
    if not parent or parent.gridParentRegistered then
        return
    end

    parent.gridParentRegistered = true
    NS.gridParents = NS.gridParents or {}
    NS.gridParents[#NS.gridParents + 1] = parent
end

local function ForEachRegisteredGridCell(parent, callback)
    if not parent or type(callback) ~= "function" then
        return
    end

    local seenCells = {}
    for _, grid in pairs(parent.gridTables or {}) do
        for _, columns in pairs(grid.rows or {}) do
            for _, cell in pairs(columns or {}) do
                if cell and not seenCells[cell] then
                    seenCells[cell] = true
                    callback(cell)
                end
            end
        end
    end
end

local function ResetGridParentRendering(parent)
    if not parent then
        return
    end

    parent.blocksApplied = false
    parent.blockByCoord = {}
    parent.colorBlocksById = {}
    parent.gridLines = {}
    parent.gridLineBlocks = {}

    if parent.gridOverlay then
        parent.gridOverlay:Hide()
        parent.gridOverlay = nil
    end

    ForEachRegisteredGridCell(parent, function(cell)
        local cellData = cell.cellData
        if cellData then
            cellData.block = nil
            cellData.layer = nil
            cellData.layerName = nil
            if cellData.styleLayers then
                cellData.styleLayers.layer = nil
                cellData.styleLayers.block = nil
            end
        end
        ApplyCellResolvedStyle(cell)
    end)
end

local function DrawGridLines(parent)
    if parent.gridOverlay then
        return
    end

    RegisterGridParent(parent)
    BuildBorderGrid(parent)

    local overlay = CreateFrame("Frame", nil, parent)
    overlay:SetAllPoints(parent)
    overlay:SetFrameLevel(parent:GetFrameLevel() + 100)
    overlay:EnableMouse(false)
    overlay.lines = {}

    for _, line in pairs(parent.gridLines) do
        RegisterStyledGridLine(overlay, line)
    end

    parent.gridOverlay = overlay
end

local function DrawTableBodyViewportBorder(scroll, tableDefinition, width, visibleRows)
    if not scroll or scroll.tableBorderOverlay or not tableDefinition or not tableDefinition.key then
        return
    end

    local height = math.max(1, visibleRows * ROW_HEIGHT)
    local holder = {}
    for index, rule in ipairs(NS.Data.borderRules or {}) do
        if rule.kind == "tableBorder" and ShouldApplyRuleToTable(rule, tableDefinition.key) then
            StoreGridLine(holder, {
                vertical = false,
                y = height,
                x1 = 0,
                x2 = width,
            }, CopyBorderStyle(rule.style, rule.priority or EXPLICIT_BORDER_PRIORITY, EXPLICIT_BORDER_PRIORITY + index))
        end
    end

    if not holder.gridLines then
        return
    end

    local overlay = CreateFrame("Frame", nil, scroll)
    overlay:SetAllPoints(scroll)
    overlay:SetFrameLevel(scroll:GetFrameLevel() + 100)
    overlay:EnableMouse(false)
    overlay.lines = {}

    for _, line in pairs(holder.gridLines) do
        RegisterStyledGridLine(overlay, line)
    end

    scroll.tableBorderOverlay = overlay
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

local function CreateText(parent, text, font, colorName, justifyH, justifyV, bold)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    local resolvedFont = ResolveTextFont(font, 12, bold)
    RegisterFontRecord({
        fontString = fs,
        path = resolvedFont.path,
        size = resolvedFont.size,
        flags = resolvedFont.flags,
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
    local tooltip = cellData.tooltip
    local lines = {}

    if type(tooltip) == "table" then
        for _, key in ipairs({ "a", "b", "c", "d", "e" }) do
            if tooltip[key] then
                lines[#lines + 1] = tooltip[key]
            end
        end

        if #lines > 0 then
            return lines
        end
    end

    if cellData.colTitle then
        lines[#lines + 1] = ("Column: %s"):format(cellData.colTitle)
    end
    if cellData.layerName then
        lines[#lines + 1] = ("Layer: %s"):format(cellData.layerName)
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

    local tablePrefix = cell.gridTable and cell.gridTable ~= "main" and (cell.gridTable .. " ") or ""
    local span = cell.gridSpan
    if span and (span.fromColumn ~= span.toColumn or span.fromRow ~= span.toRow) then
        local startCoord = CoordFromIndex(span.fromColumn, span.fromRow)
        local endCoord = CoordFromIndex(span.toColumn, span.toRow)
        if startCoord and endCoord and startCoord ~= endCoord then
            return ("Merged cell: %s%s-%s"):format(tablePrefix, string.upper(startCoord), string.upper(endCoord))
        end
    end

    local column = string.upper(ColumnName(cell.gridColumn) or "")
    local coord = string.upper(cell.gridCoord)
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

local function TooltipTitle(cellData)
    local tooltip = cellData and cellData.tooltip
    if type(tooltip) == "table" then
        return tooltip.title
    end

    return nil
end

local function GetConfiguredCellData(tableKey, coord)
    local tableCells = NS.Data.cells and NS.Data.cells[tableKey or "main"]
    return tableCells and tableCells[coord] or nil
end

local function ShowCellTooltip(cell)
    local data = cell.cellData or {}
    GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
    GameTooltip:SetText(TooltipTitle(data) or data.colTitle or "LootLevel cell", 1, 1, 1)

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

local function ScrollTableBodyByWheel(scroll, delta)
    if not scroll then
        return
    end

    local amount = ScalePixel(ROW_HEIGHT * 3)
    local nextOffset = (scroll:GetVerticalScroll() or 0) - ((delta or 0) * amount)
    scroll:SetVerticalScroll(Clamp(nextOffset, 0, scroll:GetVerticalScrollRange() or 0))
end

local function AttachTableBodyWheel(frame, scroll)
    if not frame or not scroll then
        return
    end

    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(_, delta)
        ScrollTableBodyByWheel(scroll, delta)
    end)
end

local function GetUnscaledFontMeasurement(fontString, methodName)
    local method = fontString and fontString[methodName]
    if not method then
        return nil
    end

    local value = method(fontString)
    if value and value > 0 then
        return value / GetLayoutScale()
    end

    return nil
end

local function CreateVerticalText(parent, x, y, width, height, text, font, bold)
    local resolvedFontSize = FontSize(font, 13)
    local fs = CreateText(parent, text, FontWithFallbackSize(font, 13), "black", "CENTER", "MIDDLE", bold)

    if fs.SetRotation then
        local maxTextWidth = math.max(1, height)
        local maxTextHeight = math.max(1, width - 4)
        local stringWidth = GetUnscaledFontMeasurement(fs, "GetStringWidth")
        local stringHeight = GetUnscaledFontMeasurement(fs, "GetStringHeight")
            or GetUnscaledFontMeasurement(fs, "GetLineHeight")
        local labelWidth = math.min(maxTextWidth, math.max(1, (stringWidth or maxTextWidth) + MERGED_VERTICAL_LABEL_WIDTH_PADDING))
        local labelHeight = math.min(maxTextHeight, math.max(1, (stringHeight or resolvedFontSize) + MERGED_VERTICAL_LABEL_HEIGHT_PADDING))
        local centerX = x + (width / 2) + MERGED_VERTICAL_LABEL_NUDGE_X
        local centerY = y + (height / 2) + MERGED_VERTICAL_LABEL_NUDGE_Y

        SetLayoutBox(
            fs,
            "CENTER",
            parent,
            "TOPLEFT",
            centerX,
            -centerY,
            labelWidth,
            labelHeight
        )
        fs:SetRotation(math.pi / 2)
    else
        SetLayoutBounds(fs, parent, x, y, width, height)
        fs:SetText((text or ""):gsub("(.)", "%1\n"))
    end

    return fs
end

local function CreateCell(parent, x, y, width, height, cellData)
    cellData = cellData or {}
    SetCellStyleLayer(cellData, "default", STYLE_LAYER_DEFAULT, {
        bg = cellData.defaultBg or "blank",
    })
    SetCellStyleLayer(cellData, "cell", STYLE_LAYER_CELL, {
        bg = cellData.bg,
    })

    local cell = CreateFrame("Button", nil, parent)
    SetLayoutBounds(cell, parent, x, y, width, height)
    cell:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    cell.cellData = cellData

    local bg = cell:CreateTexture(nil, "BACKGROUND")
    ApplyTexturePixelSnapping(bg)
    bg:SetAllPoints(cell)
    cell.bg = bg

    local highlight = cell:CreateTexture(nil, "HIGHLIGHT")
    ApplyTexturePixelSnapping(highlight)
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.22)

    local text
    if cellData.vertical then
        text = CreateVerticalText(cell, 0, 0, width, height, cellData.text or "", cellData.font, cellData.bold)
    else
        text = CreateText(cell, cellData.text or "", FontWithFallbackSize(cellData.font, 12), "black", "CENTER", "MIDDLE", cellData.bold)
        text:SetPoint("CENTER", cell, "CENTER", 0, 0)
        SetLayoutSize(text, math.max(1, width - 4), math.max(1, height - 4))
    end
    cell.text = text
    ApplyCellResolvedStyle(cell)

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

    if parent.bodyScrollFrame then
        AttachTableBodyWheel(cell, parent.bodyScrollFrame)
    end

    parent.cells[#parent.cells + 1] = cell
    RegisterCellCoordinate(parent, cell, cellData, x, y, width, height)
    return cell
end

local function CreateHeader(parent, x, y, width, height, text, cellData)
    return CreateCell(parent, x, y, width, height, MergeCellData({
        text = text,
        bg = "header",
        bold = true,
        font = { size = 13 },
        tooltip = { title = text },
        colTitle = text,
    }, cellData))
end

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
        return ROW_HEIGHT
    end

    local byRow = rowLayout and rowLayout.byRow
    local startRow = byRow and byRow[span.fromRow]
    local endRow = byRow and byRow[span.toRow]
    if not startRow or not endRow then
        return ROW_HEIGHT
    end

    return math.max(1, ((endRow.visualIndex - startRow.visualIndex) + 1) * ROW_HEIGHT)
end

local function BuildTableSpanMap(tableDefinition, rowLayout)
    local tableKey = tableDefinition.key
    local spanMap = {}

    for _, mergedCell in ipairs(NS.Data.mergedCells or {}) do
        if mergedCell.table == tableKey then
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
                    spanMap[coord] = record
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

local function BuildDataTableHeader(parent, tableDefinition, x, y)
    local tableKey = tableDefinition.key
    for _, headerDefinition in ipairs(tableDefinition.headers or {}) do
        local fromColumnIndex = TableColumnIndex(tableDefinition, headerDefinition.fromCol or headerDefinition.col)
        local toColumnIndex = TableColumnIndex(tableDefinition, headerDefinition.toCol or headerDefinition.fromCol or headerDefinition.col)
        if fromColumnIndex and toColumnIndex then
            if fromColumnIndex > toColumnIndex then
                fromColumnIndex, toColumnIndex = toColumnIndex, fromColumnIndex
            end

            local headerX = TableColumnX(tableDefinition, x, fromColumnIndex)
            local width = TableColumnWidth(tableDefinition, fromColumnIndex, toColumnIndex)
            local coord = headerDefinition.coord or ColumnCoord(tableDefinition.columns[fromColumnIndex], fromColumnIndex, 1)
            local fromGridColumn = ColumnIndex(ColumnKey(tableDefinition.columns[fromColumnIndex], fromColumnIndex))
            local toGridColumn = ColumnIndex(ColumnKey(tableDefinition.columns[toColumnIndex], toColumnIndex))
            CreateHeader(parent, headerX, y, width, HEADER_HEIGHT, headerDefinition.text or "", {
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

local function BuildDataTableRow(parent, tableDefinition, rowDefinition, x, y, rowLayout, spanMap)
    local tableKey = tableDefinition.key
    local colX = x
    for columnIndex, columnDefinition in ipairs(tableDefinition.columns or {}) do
        local coord = ColumnCoord(columnDefinition, columnIndex, rowDefinition.row)
        local spanRecord = spanMap and spanMap[coord]
        if not spanRecord or spanRecord.anchorCoord == coord then
            local data = spanRecord and spanRecord.cellData or GetConfiguredCellData(tableKey, coord) or {}
            local columnTitle = columnDefinition.title or ColumnKey(columnDefinition, columnIndex)
            local width = columnDefinition.width
            local height = ROW_HEIGHT

            if spanRecord then
                width = TableColumnWidth(tableDefinition, spanRecord.fromColumnIndex, spanRecord.toColumnIndex)
                height = spanRecord.height or SpanVisualHeight(spanRecord.span, rowLayout)
            end

            CreateCell(parent, colX, y, width, height, MergeCellData({
                table = tableKey,
                coord = coord,
                text = data.text or "",
                defaultBg = columnDefinition.bg or "blank",
                bold = columnDefinition.bold,
                tooltip = data.tooltip or { title = FormatDefaultCellTitle(tableDefinition, columnDefinition, rowDefinition) },
                colTitle = columnTitle,
            }, data))
        end
        colX = colX + columnDefinition.width
    end
end

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
                    y = visualRowIndex * ROW_HEIGHT,
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

local function ClampScrollFrame(scroll)
    if not scroll then
        return
    end

    local range = scroll:GetVerticalScrollRange() or 0
    local current = scroll:GetVerticalScroll() or 0
    scroll:SetVerticalScroll(Clamp(current, 0, range))
end

local function CreateTableBodyScroll(parent, x, y, width, visibleRows, totalRows)
    local visibleHeight = math.max(1, visibleRows * ROW_HEIGHT)
    local contentHeight = math.max(visibleHeight, totalRows * ROW_HEIGHT)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    local child = CreateFrame("Frame", nil, scroll)
    local canScroll = totalRows > visibleRows

    SetLayoutBounds(scroll, parent, x, y, width, visibleHeight)
    SetLayoutSize(child, width, contentHeight)
    child:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    child.cells = parent.cells
    child.bodyScrollFrame = canScroll and scroll or nil
    scroll:SetScrollChild(child)

    scroll:EnableMouse(canScroll)
    scroll:EnableMouseWheel(canScroll)
    if canScroll then
        AttachTableBodyWheel(scroll, scroll)
        AttachTableBodyWheel(child, scroll)
    end

    NS.tableBodyScrolls = NS.tableBodyScrolls or {}
    NS.tableBodyScrolls[#NS.tableBodyScrolls + 1] = scroll

    return scroll, child
end

local function BuildDataTableRows(parent, tableDefinition, rows, x, y, rowLayout, spanMap)
    local visualRowIndex = 0
    for _, rowDefinition in ipairs(rows or {}) do
        if rowDefinition.marginRows then
            visualRowIndex = visualRowIndex + (tonumber(rowDefinition.marginRows) or 0)
        else
            BuildDataTableRow(parent, tableDefinition, rowDefinition, x, y + (visualRowIndex * ROW_HEIGHT), rowLayout, spanMap)
            visualRowIndex = visualRowIndex + 1
        end
    end
end

local function BuildDataTable(parent, tableDefinition)
    if not tableDefinition or not tableDefinition.key then
        return
    end

    local x = tableDefinition.x or 0
    local y = tableDefinition.y or 0
    local rows = CollectTableBodyRows(tableDefinition)
    local rowLayout = BuildBodyRowLayout(rows)
    local totalRows = rowLayout.totalRows or CountVisualRows(rows)
    if totalRows <= 0 then
        BuildDataTableHeader(parent, tableDefinition, x, y)
        return
    end

    BuildDataTableHeader(parent, tableDefinition, x, y)

    local visibleRows = DisplayedBodyRows(tableDefinition, totalRows)
    local spanMap = BuildTableSpanMap(tableDefinition, rowLayout)
    local bodyScroll, bodyContent = CreateTableBodyScroll(parent, x, y + HEADER_HEIGHT, TableWidth(tableDefinition), visibleRows, totalRows)
    BuildDataTableRows(bodyContent, tableDefinition, rows, 0, 0, rowLayout, spanMap)
    DrawGridLines(bodyContent)
    DrawTableBodyViewportBorder(bodyScroll, tableDefinition, TableWidth(tableDefinition), visibleRows)
    ClampScrollFrame(bodyScroll)
end

local function BuildRegisteredTables(parent)
    for _, tableDefinition in ipairs(NS.Data.tableOrder or {}) do
        BuildDataTable(parent, tableDefinition)
    end
end

local function LayerFooterText(layer, side)
    if not layer then
        return nil
    end

    if type(layer.footer) == "table" and layer.footer[side] ~= nil then
        return layer.footer[side]
    end

    if side == "right" then
        return layer.footerRight
    end

    if side == "left" then
        return layer.footerLeft
    end

    return nil
end

local function ActiveFooterRightText()
    local layerSetKey = DefaultLayerSetKey()
    local activeLayer = LayerData(GetActiveLayerKey(layerSetKey))
    return LayerFooterText(activeLayer, "right") or NS.Data.footerRight or ""
end

local function RefreshFooterText()
    if NS.footerRightText then
        NS.footerRightText:SetText(ActiveFooterRightText())
    end
end

local function BuildFooter(parent)
    local footer = CreateFrame("Frame", nil, parent)
    SetLayoutPoints(footer, {
        { point = "BOTTOMLEFT", relativeTo = parent, relativePoint = "BOTTOMLEFT", x = PADDING, y = 8 },
        { point = "BOTTOMRIGHT", relativeTo = parent, relativePoint = "BOTTOMRIGHT", x = -PADDING, y = 8 },
    }, nil, 22)

    local left = CreateText(footer, NS.Data.footerLeft, { size = 12 }, "white", "LEFT", "MIDDLE", false)
    SetLayoutBox(left, "LEFT", footer, "LEFT", 0, 0, 720, 20)

    local right = CreateText(footer, ActiveFooterRightText(), { size = 12 }, "white", "RIGHT", "MIDDLE", false)
    SetLayoutBox(right, "RIGHT", footer, "RIGHT", 0, 0, 410, 20)
    NS.footerRightText = right
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

    local label = CreateText(button, FormatScalePercent(GetScalePercent()), { size = 10 }, "white", "CENTER", "MIDDLE", true)
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
    local label = TooltipTitle(cellData) or cellData.colTitle or "cell"
    if button == "RightButton" then
        self:Print(("Right-clicked %s."):format(label))
    else
        self:Print(("Selected %s."):format(label))
    end
end

function NS:GetActiveLayerKey(layerSetKey)
    return GetActiveLayerKey(layerSetKey)
end

function NS:RefreshLayerRendering()
    for _, parent in ipairs(self.gridParents or {}) do
        ResetGridParentRendering(parent)
        DrawGridLines(parent)
    end
    RefreshFooterText()
end

function NS:SetActiveLayer(layerKey)
    local normalized = NormalizeLayerKey(layerKey)
    if not normalized then
        self:Print(("Unknown layer: %s"):format(tostring(layerKey or "")))
        return false
    end

    if not self.db then
        return false
    end

    local layerSetKey = LayerSetKeyForLayer(normalized)
    if type(self.db.activeLayers) ~= "table" then
        self.db.activeLayers = {}
    end
    if layerSetKey then
        self.db.activeLayers[layerSetKey] = normalized
    end
    self.db.activeLayer = normalized
    self:RefreshLayerRendering()
    self:Print(("Active layer: %s"):format(LayerDisplayName(normalized)))
    return true
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
    self.tableBodyScrolls = {}
    self.gridParents = {}
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

    local title = CreateText(frame, "LootLevel", { size = 15 }, "white", "LEFT", "MIDDLE", true)
    SetLayoutBox(title, "TOPLEFT", frame, "TOPLEFT", PADDING, -6, 240, TITLE_HEIGHT - 4)

    local version = CreateText(frame, self.version or "", { size = 11 }, "muted", "RIGHT", "MIDDLE", false)
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

    BuildRegisteredTables(content)
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
