local ADDON_NAME, NS = ...

local UI = NS.UI
local Metrics = UI.Metrics
local Layers = UI.Layers
local BodyScroll = {}
UI.BodyScroll = BodyScroll

local function ScrollTableBodyByWheel(scroll, delta)
    if not scroll then
        return
    end

    local amount = UI.ScalePixel(Metrics.rowHeight * 3)
    local nextOffset = (scroll:GetVerticalScroll() or 0) - ((delta or 0) * amount)
    scroll:SetVerticalScroll(UI.Clamp(nextOffset, 0, scroll:GetVerticalScrollRange() or 0))
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

    local range = scroll:GetVerticalScrollRange() or 0
    local current = scroll:GetVerticalScroll() or 0
    scroll:SetVerticalScroll(UI.Clamp(current, 0, range))
end

local function ApplyScrollOffset(scroll, offset)
    if not scroll or offset == nil then
        return
    end

    scroll.syncingBodyScroll = true
    scroll:SetVerticalScroll(UI.Clamp(offset, 0, scroll:GetVerticalScrollRange() or 0))
    scroll.syncingBodyScroll = nil
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

    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if scroll and scroll:IsShown() then
                ApplySavedScrollOffset(scroll)
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
        AttachTableBodyWheel(scroll, scroll)
        AttachTableBodyWheel(child, scroll)
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

                offset = UI.Clamp(offset or self:GetVerticalScroll() or 0, 0, self:GetVerticalScrollRange() or 0)
                NS.tableBodyScrollOffsets = NS.tableBodyScrollOffsets or {}
                NS.tableBodyScrollOffsets[bodyScrollGroup] = offset

                for _, syncedScroll in ipairs(NS.tableBodyScrollGroups[bodyScrollGroup] or {}) do
                    if syncedScroll ~= self then
                        syncedScroll.syncingBodyScroll = true
                        syncedScroll:SetVerticalScroll(UI.Clamp(offset, 0, syncedScroll:GetVerticalScrollRange() or 0))
                        syncedScroll.syncingBodyScroll = nil
                    end
                end
            end)
            scroll:SetScript("OnShow", ApplySavedScrollOffsetWhenShown)

            local savedOffset = NS.tableBodyScrollOffsets and NS.tableBodyScrollOffsets[bodyScrollGroup]
            ApplyScrollOffset(scroll, savedOffset)
        end
    end

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
