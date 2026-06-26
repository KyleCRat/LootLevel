local ADDON_NAME, NS = ...

local UI = NS.UI or {}
NS.UI = UI
local Helpers = NS.Helpers

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

local function RefreshScaledLayout(includeDeferred)
    for _, record in ipairs(NS.layoutRecords or {}) do
        if includeDeferred or not record.deferScaleLayout then
            ApplyLayoutRecord(record)
        end
    end

    if UI.RefreshScaledFonts then
        UI.RefreshScaledFonts(includeDeferred)
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

local FinishDeferredScaleRefresh
FinishDeferredScaleRefresh = function()
    if NS.IsCombatLocked and NS:IsCombatLocked() then
        if NS.RunWhenOutOfCombat then
            NS:RunWhenOutOfCombat("deferredScaleRefresh", FinishDeferredScaleRefresh, true)
        end
        return
    end

    RefreshScaledLayout(true)
    ScaleLayout.EndPreview()
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
        FinishDeferredScaleRefresh()
        return
    end

    C_Timer.After(ScaleLayout.debounceSeconds, function()
        if serial == ScaleLayout.serial then
            FinishDeferredScaleRefresh()
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

    Helpers.ShallowAssign(record, values)
    ApplyLayoutRecord(record)
    return record
end
UI.ApplyTexturePixelSnapping = ApplyTexturePixelSnapping
UI.ScaleLayout = ScaleLayout
UI.RefreshScaledLayout = RefreshScaledLayout
UI.WithDeferredScaleLayout = function(callback)
    ScaleLayout.WithDeferred(callback)
end
