local ADDON_NAME, NS = ...

local UI = NS.UI
local Helpers = NS.Helpers
local Grid = UI.Grid
local GridLines = {}
UI.GridLines = GridLines

local function AcquireGridLineTexture(overlay)
    overlay.lines = overlay.lines or {}
    overlay.linePool = overlay.linePool or {}

    local texture = overlay.linePool[#overlay.linePool]
    if texture then
        overlay.linePool[#overlay.linePool] = nil
    else
        texture = overlay:CreateTexture(nil, "ARTWORK")
        UI.ApplyTexturePixelSnapping(texture)
    end

    texture:Show()
    overlay.lines[#overlay.lines + 1] = texture
    return texture
end

local function ReleaseGridOverlayLines(overlay)
    if not overlay then
        return
    end

    overlay.linePool = overlay.linePool or {}

    for _, texture in ipairs(overlay.lines or {}) do
        texture:Hide()
        texture:ClearAllPoints()
        overlay.linePool[#overlay.linePool + 1] = texture
    end

    overlay.lines = {}
end

local function RegisterGridLineTexture(overlay, line)
    local texture = AcquireGridLineTexture(overlay)
    texture:SetColorTexture(Grid.color[1], Grid.color[2], Grid.color[3], line.alpha or Grid.color[4])
    if texture.layoutRecord then
        texture.layoutRecord.relativeTo = overlay
        texture.layoutRecord.line = line
        UI.ApplyLayoutRecord(texture.layoutRecord)
    else
        texture.layoutRecord = {
            kind = "gridline",
            region = texture,
            owner = overlay,
            relativeTo = overlay,
            line = line,
        }
        UI.RegisterLayoutRecord(texture.layoutRecord)
    end
end

local function AddPatternedGridLineSegments(lines, line, segmentLength, segmentGap)
    local length
    if line.vertical then
        length = line.y2 - line.y1
    else
        length = line.x2 - line.x1
    end

    local offset = 0
    while offset < length do
        local segmentEnd = math.min(offset + segmentLength, length)
        local segmentLine = Helpers.ShallowCopy(line)

        if line.vertical then
            segmentLine.y1 = line.y1 + offset
            segmentLine.y2 = line.y1 + segmentEnd
        else
            segmentLine.x1 = line.x1 + offset
            segmentLine.x2 = line.x1 + segmentEnd
        end

        segmentLine.style = "solid"
        lines[#lines + 1] = segmentLine
        offset = offset + segmentLength + segmentGap
    end
end

local function AddGridLineRenderSegments(lines, line)
    if line.style == "dotted" then
        AddPatternedGridLineSegments(lines, line, Grid.dottedDot, Grid.dottedGap)
    elseif line.style == "dashed" then
        AddPatternedGridLineSegments(lines, line, Grid.dashedDash, Grid.dashedGap)
    else
        lines[#lines + 1] = Helpers.ShallowCopy(line)
    end
end

local function BuildGridLineRenderSegments(gridLines)
    local lines = {}
    for _, line in pairs(gridLines or {}) do
        AddGridLineRenderSegments(lines, line)
    end

    return lines
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
        RegisterPatternedGridLine(overlay, line, Grid.dottedDot, Grid.dottedGap)
    elseif line.style == "dashed" then
        RegisterPatternedGridLine(overlay, line, Grid.dashedDash, Grid.dashedGap)
    elseif line.style == "solid" then
        RegisterGridLineTexture(overlay, line)
    else
        RegisterGridLineTexture(overlay, line)
    end
end

GridLines.ReleaseOverlayLines = ReleaseGridOverlayLines
GridLines.RegisterTexture = RegisterGridLineTexture
GridLines.RegisterStyled = RegisterStyledGridLine
GridLines.BuildRenderSegments = BuildGridLineRenderSegments
