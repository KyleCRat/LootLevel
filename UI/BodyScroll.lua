local ADDON_NAME, NS = ...

local UI = NS.UI
local Metrics = UI.Metrics
local Layers = UI.Layers
local BodyScroll = {}
UI.BodyScroll = BodyScroll

local SHADOW_BANDS = 4
local SHADOW_BAND_HEIGHT = 2
local SHADOW_ALPHA = 0.24
local SCROLL_EDGE_EPSILON = 1

local UpdateScrollShadows

local function GetScrollRange(scroll)
    local child = scroll:GetScrollChild()
    -- Native scroll bounds can include oversized masks and text. Only the
    -- explicitly sized table body should determine how far its rows scroll.
    return math.max(0, child:GetHeight() - scroll:GetHeight())
end

local function SetShown(region, shown)
    if not region then
        return
    end

    if shown then
        region:Show()
    else
        region:Hide()
    end
end

local function CreateShadowBand(parent, anchor, index)
    local texture = parent:CreateTexture(nil, "OVERLAY")
    UI.ApplyTexturePixelSnapping(texture)

    local alpha = SHADOW_ALPHA * ((SHADOW_BANDS - index) + 1) / SHADOW_BANDS
    texture:SetColorTexture(0, 0, 0, alpha)

    local offset = (index - 1) * SHADOW_BAND_HEIGHT
    if anchor == "TOP" then
        UI.SetLayoutPoints(texture, {
            { point = "TOPLEFT", relativeTo = parent, relativePoint = "TOPLEFT", x = 0, y = -offset },
            { point = "TOPRIGHT", relativeTo = parent, relativePoint = "TOPRIGHT", x = 0, y = -offset },
        }, nil, SHADOW_BAND_HEIGHT)
    else
        UI.SetLayoutPoints(texture, {
            { point = "BOTTOMLEFT", relativeTo = parent, relativePoint = "BOTTOMLEFT", x = 0, y = offset },
            { point = "BOTTOMRIGHT", relativeTo = parent, relativePoint = "BOTTOMRIGHT", x = 0, y = offset },
        }, nil, SHADOW_BAND_HEIGHT)
    end

    texture:Hide()
    return texture
end

local function EnsureScrollShadows(scroll)
    if not scroll or scroll.scrollShadowOverlay then
        return
    end

    local overlay = CreateFrame("Frame", nil, scroll)
    overlay.deferScaleLayout = scroll.deferScaleLayout
    overlay:SetAllPoints(scroll)
    overlay:SetFrameLevel(scroll:GetFrameLevel() + 25)
    overlay:EnableMouse(false)

    overlay.top = {}
    overlay.bottom = {}
    for index = 1, SHADOW_BANDS do
        overlay.top[index] = CreateShadowBand(overlay, "TOP", index)
        overlay.bottom[index] = CreateShadowBand(overlay, "BOTTOM", index)
    end

    scroll.scrollShadowOverlay = overlay
end

UpdateScrollShadows = function(scroll)
    local overlay = scroll and scroll.scrollShadowOverlay
    if not overlay then
        return
    end

    local range = GetScrollRange(scroll)
    local offset = UI.Clamp(scroll:GetVerticalScroll() or 0, 0, range)
    local canScrollUp = range > 0 and offset > SCROLL_EDGE_EPSILON
    local canScrollDown = range > 0 and (range - offset) > SCROLL_EDGE_EPSILON

    for index = 1, SHADOW_BANDS do
        SetShown(overlay.top[index], canScrollUp)
        SetShown(overlay.bottom[index], canScrollDown)
    end
end

local function ScrollTableBodyByWheel(scroll, delta)
    if not scroll then
        return
    end

    local amount = UI.ScalePixel(Metrics.rowHeight * 3)
    local nextOffset = (scroll:GetVerticalScroll() or 0) - ((delta or 0) * amount)
    scroll:SetVerticalScroll(UI.Clamp(nextOffset, 0, GetScrollRange(scroll)))
    UpdateScrollShadows(scroll)
    if scroll.bodyScrollGroup and not scroll.syncingBodyScroll then
        local onVerticalScroll = scroll:GetScript("OnVerticalScroll")
        if onVerticalScroll then
            onVerticalScroll(scroll, scroll:GetVerticalScroll() or 0)
        end
    end
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

local function ClampScrollFrame(scroll)
    if not scroll then
        return
    end

    local range = GetScrollRange(scroll)
    local current = scroll:GetVerticalScroll() or 0
    scroll:SetVerticalScroll(UI.Clamp(current, 0, range))
    UpdateScrollShadows(scroll)
end

local function ApplyScrollOffset(scroll, offset)
    if not scroll or offset == nil then
        return
    end

    offset = UI.Clamp(offset, 0, GetScrollRange(scroll))
    if scroll:GetVerticalScroll() ~= offset then
        scroll.syncingBodyScroll = true
        scroll:SetVerticalScroll(offset)
        scroll.syncingBodyScroll = nil
    end
    UpdateScrollShadows(scroll)
end

local function ApplySavedScrollOffset(scroll)
    local bodyScrollGroup = scroll and scroll.bodyScrollGroup
    if not bodyScrollGroup then
        return
    end

    local savedOffset = NS.tableBodyScrollOffsets and NS.tableBodyScrollOffsets[bodyScrollGroup]
    ApplyScrollOffset(scroll, savedOffset)
end

local function ApplySavedScrollOffsetWhenShown(scroll)
    ApplySavedScrollOffset(scroll)
    UpdateScrollShadows(scroll)

    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if scroll and scroll:IsShown() then
                ApplySavedScrollOffset(scroll)
                UpdateScrollShadows(scroll)
            end
        end)
    end
end

local function CreateTableBodyScroll(parent, tableDefinition, x, y, width, visibleRows, totalRows)
    local visibleHeight = math.max(1, visibleRows * Metrics.rowHeight)
    local contentHeight = math.max(visibleHeight, totalRows * Metrics.rowHeight)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    local child = CreateFrame("Frame", nil, scroll)
    local canScroll = totalRows > visibleRows
    scroll.deferScaleLayout = parent.deferScaleLayout
    child.deferScaleLayout = parent.deferScaleLayout

    UI.SetLayoutBounds(scroll, parent, x, y, width, visibleHeight)
    UI.SetLayoutSize(child, width, contentHeight)
    child:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    parent.cells = parent.cells or {}
    child.cells = parent.cells
    child.bodyScrollFrame = canScroll and scroll or nil
    scroll:SetScrollChild(child)

    scroll:EnableMouse(canScroll)
    scroll:EnableMouseWheel(canScroll)
    if canScroll then
        EnsureScrollShadows(scroll)
        AttachTableBodyWheel(scroll, scroll)
        AttachTableBodyWheel(child, scroll)
        scroll:SetScript("OnShow", ApplySavedScrollOffsetWhenShown)
    end

    NS.tableBodyScrolls = NS.tableBodyScrolls or {}
    NS.tableBodyScrolls[#NS.tableBodyScrolls + 1] = scroll
    if canScroll and tableDefinition then
        local bodyScrollGroup = tableDefinition.bodyScrollGroup or tableDefinition.scrollGroup
        if bodyScrollGroup then
            scroll.bodyScrollGroup = bodyScrollGroup
            NS.tableBodyScrollGroups = NS.tableBodyScrollGroups or {}
            NS.tableBodyScrollGroups[bodyScrollGroup] = NS.tableBodyScrollGroups[bodyScrollGroup] or {}
            local groupScrolls = NS.tableBodyScrollGroups[bodyScrollGroup]
            groupScrolls[#groupScrolls + 1] = scroll

            scroll:SetScript("OnVerticalScroll", function(self, offset)
                if self.syncingBodyScroll then
                    return
                end

                offset = UI.Clamp(offset or self:GetVerticalScroll() or 0, 0, GetScrollRange(self))
                ApplyScrollOffset(self, offset)
                NS.tableBodyScrollOffsets = NS.tableBodyScrollOffsets or {}
                NS.tableBodyScrollOffsets[bodyScrollGroup] = offset

                for _, syncedScroll in ipairs(NS.tableBodyScrollGroups[bodyScrollGroup] or {}) do
                    if syncedScroll ~= self then
                        ApplyScrollOffset(syncedScroll, offset)
                    end
                end
            end)

            local savedOffset = NS.tableBodyScrollOffsets and NS.tableBodyScrollOffsets[bodyScrollGroup]
            ApplyScrollOffset(scroll, savedOffset)
        end
    end

    UpdateScrollShadows(scroll)
    return scroll, child
end

local function ApplyActiveLayerBodyScrollDefaults(force)
    local activeLayerSet = Layers.GetActiveLayerSetKey()
    local activeLayer = Layers.GetActiveLayerKey(activeLayerSet)
    local layer = Layers.LayerData(activeLayer)
    local scrollDefaults = layer and layer.bodyScroll
    if type(scrollDefaults) ~= "table" then
        return
    end

    NS.tableBodyScrollOffsets = NS.tableBodyScrollOffsets or {}
    NS.appliedLayerBodyScrollDefaults = NS.appliedLayerBodyScrollDefaults or {}

    local function ResolveScrollOffset(definition, scroll)
        if type(definition) == "number" then
            return UI.ScalePixel(math.max(0, definition - 2) * Metrics.rowHeight)
        end
        if type(definition) ~= "table" then
            return nil
        end

        local offset = tonumber(definition.offset)
        if offset then
            return UI.ScalePixel(math.max(0, offset))
        end

        local row = tonumber(definition.row)
        if row then
            local rowLayout = scroll and scroll.bodyRowLayout
            local bodyRow = rowLayout and rowLayout.byRow and rowLayout.byRow[row]
            if bodyRow then
                return UI.ScalePixel(bodyRow.y or 0)
            end

            return UI.ScalePixel(math.max(0, row - 2) * Metrics.rowHeight)
        end

        return nil
    end

    for bodyScrollGroup, definition in pairs(scrollDefaults) do
        local appliedKey = ("%s:%s"):format(tostring(activeLayer or ""), tostring(bodyScrollGroup or ""))
        if force or not NS.appliedLayerBodyScrollDefaults[appliedKey] then
            local groupScrolls = NS.tableBodyScrollGroups and NS.tableBodyScrollGroups[bodyScrollGroup] or nil
            local referenceScroll = groupScrolls and groupScrolls[1] or nil
            local offset = ResolveScrollOffset(definition, referenceScroll)
            if offset then
                NS.tableBodyScrollOffsets[bodyScrollGroup] = offset

                for _, scroll in ipairs(groupScrolls or {}) do
                    ApplyScrollOffset(scroll, offset)
                end

                NS.appliedLayerBodyScrollDefaults[appliedKey] = true
            end
        end
    end
end

BodyScroll.ScrollByWheel = ScrollTableBodyByWheel
BodyScroll.AttachWheel = AttachTableBodyWheel
BodyScroll.Clamp = ClampScrollFrame
BodyScroll.Create = CreateTableBodyScroll
BodyScroll.ApplyActiveLayerDefaults = ApplyActiveLayerBodyScrollDefaults
UI.ApplyActiveLayerBodyScrollDefaults = ApplyActiveLayerBodyScrollDefaults
