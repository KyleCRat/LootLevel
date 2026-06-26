local ADDON_NAME, NS = ...

local UI = NS.UI or {}
NS.UI = UI

local FRAME_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

local FRAME_WIDTH = 1180
local FRAME_HEIGHT = 760
local PADDING = 14
local TITLE_HEIGHT = 28
local FOOTER_HEIGHT = 22
local HEADER_HEIGHT = 24
local ROW_HEIGHT = 24
local SCALE_MIN_PERCENT = 50
local SCALE_MAX_PERCENT = 200
local SCALE_STEP_PERCENT = 5
local SCALE_DEFAULT_PERCENT = 100

local VALID_FONT_FLAGS = {
    [""] = true,
    OUTLINE = true,
    THICKOUTLINE = true,
    OUTLINESLUG = true,
    MONOCHROMEOUTLINE = true,
    MONOCHROMETHICKOUTLINE = true,
}

local ScaleLayout = {
    debounceSeconds = 0.12,
    deferredDepth = 0,
    serial = 0,
}

local function Pixel(value)
    value = value or 0
    if value >= 0 then
        return math.floor(value + 0.5)
    end

    return math.ceil(value - 0.5)
end

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
    if ScaleLayout.deferredDepth > 0
        or (record.region and record.region.deferScaleLayout)
        or (record.relativeTo and record.relativeTo.deferScaleLayout)
    then
        record.deferScaleLayout = true
    end

    NS.layoutRecords = NS.layoutRecords or {}
    NS.layoutRecords[#NS.layoutRecords + 1] = record
    ApplyLayoutRecord(record)
    return record
end

local function RegisterFontRecord(record)
    if ScaleLayout.deferredDepth > 0
        or (record.fontString and record.fontString.deferScaleLayout)
    then
        record.deferScaleLayout = true
    end

    NS.layoutFonts = NS.layoutFonts or {}
    NS.layoutFonts[#NS.layoutFonts + 1] = record
    ApplyFontRecord(record)
    return record
end

local function SetLayoutBounds(region, relativeTo, x, y, width, height)
    return RegisterLayoutRecord({
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
    return RegisterLayoutRecord({
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
    return RegisterLayoutRecord({
        kind = "size",
        region = region,
        width = width,
        height = height,
    })
end

local function SetLayoutPoints(region, points, width, height)
    return RegisterLayoutRecord({
        kind = "points",
        region = region,
        points = points,
        width = width,
        height = height,
    })
end

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

local function RefreshScaledLayout(includeDeferred)
    for _, record in ipairs(NS.layoutRecords or {}) do
        if includeDeferred or not record.deferScaleLayout then
            ApplyLayoutRecord(record)
        end
    end

    for _, record in ipairs(NS.layoutFonts or {}) do
        if includeDeferred or not record.deferScaleLayout then
            ApplyFontRecord(record)
        end
    end

    if NS.scaleButtonText then
        NS.scaleButtonText:SetText(FormatScalePercent(GetScalePercent()))
    end

    if includeDeferred then
        for _, scrollFrame in ipairs(NS.tableBodyScrolls or {}) do
            local range = scrollFrame:GetVerticalScrollRange() or 0
            local current = scrollFrame:GetVerticalScroll() or 0
            scrollFrame:SetVerticalScroll(Clamp(current, 0, range))
        end
    end
end

function ScaleLayout.WithDeferred(callback)
    if type(callback) ~= "function" then
        return
    end

    ScaleLayout.deferredDepth = ScaleLayout.deferredDepth + 1
    local ok, err = pcall(callback)
    ScaleLayout.deferredDepth = math.max(0, ScaleLayout.deferredDepth - 1)
    if not ok then
        error(err, 0)
    end
end

function ScaleLayout.ScheduleDeferredRefresh()
    ScaleLayout.serial = ScaleLayout.serial + 1
    local serial = ScaleLayout.serial

    if not C_Timer or not C_Timer.After then
        RefreshScaledLayout(true)
        ScaleLayout.EndPreview()
        return
    end

    C_Timer.After(ScaleLayout.debounceSeconds, function()
        if serial == ScaleLayout.serial then
            RefreshScaledLayout(true)
            ScaleLayout.EndPreview()
        end
    end)
end

function ScaleLayout.BeginPreview()
    if not NS.tableLayer or not NS.tablePlaceholderLayer then
        return
    end

    if ScaleLayout.previewActive then
        return
    end

    ScaleLayout.previewActive = true
    NS.tableLayer:Hide()
    NS.tablePlaceholderLayer:Show()
end

function ScaleLayout.EndPreview()
    if not ScaleLayout.previewActive then
        return
    end

    ScaleLayout.previewActive = false
    if NS.tablePlaceholderLayer then
        NS.tablePlaceholderLayer:Hide()
    end
    if NS.tableLayer then
        NS.tableLayer:Show()
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

local function Color(name)
    local color = type(name) == "table" and name or NS.Colors[name or "blank"] or NS.Colors.blank
    return color[1], color[2], color[3], color[4] or 1
end

local function TextColorFor(colorName)
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

UI.FrameBackdrop = FRAME_BACKDROP
UI.Grid = {
    color = { 0, 0, 0, 1 },
    dottedDot = 1,
    dottedGap = 3,
    dashedDash = 2,
    dashedGap = 2,
}
UI.BorderPriority = {
    block = 20,
    explicitNone = 80,
    explicit = 100,
    explicitThick = 110,
    cell = 120,
    cellOrder = 0,
}
UI.Metrics = {
    frameWidth = FRAME_WIDTH,
    frameHeight = FRAME_HEIGHT,
    padding = PADDING,
    titleHeight = TITLE_HEIGHT,
    footerHeight = FOOTER_HEIGHT,
    headerHeight = HEADER_HEIGHT,
    rowHeight = ROW_HEIGHT,
}
UI.Scale = {
    minPercent = SCALE_MIN_PERCENT,
    maxPercent = SCALE_MAX_PERCENT,
    stepPercent = SCALE_STEP_PERCENT,
    defaultPercent = SCALE_DEFAULT_PERCENT,
}
UI.MergedVerticalLabel = {
    nudgeX = -6,
    nudgeY = 7,
    widthPadding = 12,
    heightPadding = 2,
}
UI.StyleLayer = {
    default = 10,
    layer = 15,
    block = 20,
    cell = 30,
}
UI.LayerState = {
    activeOrderBonus = 100000,
    defaultInactiveAlpha = 0.3,
}

NS.Pixel = Pixel
UI.Pixel = Pixel
UI.Clamp = Clamp
UI.NormalizeScalePercent = NormalizeScalePercent
UI.GetScalePercent = GetScalePercent
UI.GetLayoutScale = GetLayoutScale
UI.ScalePixel = ScalePixel
UI.FormatScalePercent = FormatScalePercent
UI.SetLayoutBounds = SetLayoutBounds
UI.SetLayoutBox = SetLayoutBox
UI.SetLayoutSize = SetLayoutSize
UI.SetLayoutPoints = SetLayoutPoints
UI.ApplyLayoutRecord = ApplyLayoutRecord
UI.RegisterLayoutRecord = RegisterLayoutRecord
UI.UpdateLayoutRecord = function(record, values)
    if not record or type(values) ~= "table" then
        return record
    end

    for key, value in pairs(values) do
        record[key] = value
    end
    ApplyLayoutRecord(record)
    return record
end
UI.FontSize = FontSize
UI.FontWithFallbackSize = FontWithFallbackSize
UI.ResolveTextFont = ResolveTextFont
UI.ApplyTexturePixelSnapping = ApplyTexturePixelSnapping
UI.GetPixelRoot = GetPixelRoot
UI.SnapFramePosition = SnapFramePosition
UI.Color = Color
UI.TextColorFor = TextColorFor
UI.CreateText = CreateText
UI.ScaleLayout = ScaleLayout
UI.RefreshScaledLayout = RefreshScaledLayout
UI.WithDeferredScaleLayout = function(callback)
    ScaleLayout.WithDeferred(callback)
end
