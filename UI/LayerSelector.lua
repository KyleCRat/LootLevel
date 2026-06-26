local ADDON_NAME, NS = ...

local UI = NS.UI

local LayerSelector = {
    topOffset = -42,
    x = -1,
    subX = 8,
    width = 42,
    height = 28,
    subWidth = 34,
    subHeight = 24,
    gap = 3,
    groupGap = 7,
}

UI.LayerSelector = LayerSelector

function LayerSelector.Abbreviate(text)
    text = tostring(text or ""):gsub("%s+", "")
    if text == "" then
        return "?"
    end

    return string.upper(text:sub(1, 3))
end

function LayerSelector.LayerSetButtonText(layerSet)
    return layerSet and (layerSet.buttonText or layerSet.shortName or LayerSelector.Abbreviate(layerSet.name or layerSet.key))
        or "?"
end

function LayerSelector.LayerButtonText(layer)
    if not layer then
        return "?"
    end

    if layer.buttonText or layer.shortName then
        return layer.buttonText or layer.shortName
    end

    local season = tostring(layer.name or ""):match("[Ss]eason%s*(%d+)")
    if season then
        return "S" .. season
    end

    return LayerSelector.Abbreviate(layer.name or layer.key)
end

function LayerSelector.ApplyButtonState(button, selected, enabled)
    if not button then
        return
    end

    enabled = enabled ~= false
    button:SetAlpha(enabled and 1 or 0.55)

    if button.SetBackdrop then
        if selected then
            button:SetBackdropColor(0.10, 0.42, 0.32, 0.98)
            button:SetBackdropBorderColor(0.26, 0.86, 0.60, 1)
        else
            button:SetBackdropColor(0.13, 0.13, 0.13, 0.96)
            button:SetBackdropBorderColor(0, 0, 0, 1)
        end
    end

    if button.label then
        if selected or enabled then
            button.label:SetTextColor(UI.Color("white"))
        else
            button.label:SetTextColor(UI.Color("muted"))
        end
    end
end

function LayerSelector.Refresh()
    local activeLayerSet = NS:GetActiveLayerSetKey()

    for _, record in ipairs(NS.layerSetButtons or {}) do
        LayerSelector.ApplyButtonState(record.button, record.layerSetKey == activeLayerSet, true)
    end

    for _, record in ipairs(NS.layerButtons or {}) do
        local layerSetActive = record.layerSetKey == activeLayerSet
        local activeLayer = NS:GetActiveLayerKey(record.layerSetKey)
        LayerSelector.ApplyButtonState(record.button, layerSetActive and record.layerKey == activeLayer, layerSetActive)
    end
end

function LayerSelector.ShowTooltip(owner, title, line)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(title or "", 1, 1, 1)
    if line then
        GameTooltip:AddLine(line, 0.85, 0.85, 0.85, true)
    end
    GameTooltip:Show()
end

function LayerSelector.CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    UI.SetLayoutSize(button, width, height)

    if button.SetBackdrop then
        button:SetBackdrop(UI.FrameBackdrop)
        button:SetBackdropColor(0.13, 0.13, 0.13, 0.96)
        button:SetBackdropBorderColor(0, 0, 0, 1)
    end

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    UI.ApplyTexturePixelSnapping(highlight)
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.16)

    local label = UI.CreateText(button, text, { size = 10 }, "white", "CENTER", "MIDDLE", true)
    UI.SetLayoutBox(label, "CENTER", button, "CENTER", 0, 0, width - 4, height - 4)
    button.label = label

    return button
end

function LayerSelector.CreateButtons(parent)
    NS.layerSetButtons = {}
    NS.layerButtons = {}

    local y = LayerSelector.topOffset
    for _, layerSet in ipairs((NS.Data and NS.Data.layerSetOrder) or {}) do
        local layerSetKey = layerSet.key or layerSet.id
        local setButton = LayerSelector.CreateButton(parent, LayerSelector.LayerSetButtonText(layerSet), LayerSelector.width, LayerSelector.height)
        local buttonLayerSetKey = layerSetKey
        UI.SetLayoutBox(setButton, "TOPLEFT", parent, "TOPRIGHT", LayerSelector.x, y, LayerSelector.width, LayerSelector.height)
        setButton:SetScript("OnClick", function()
            NS:SetActiveLayerSet(buttonLayerSetKey, true)
        end)
        setButton:SetScript("OnEnter", function(self)
            LayerSelector.ShowTooltip(self, UI.LayerSetDisplayName(buttonLayerSetKey), "Select expansion.")
        end)
        setButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        NS.layerSetButtons[#NS.layerSetButtons + 1] = {
            button = setButton,
            layerSetKey = layerSetKey,
        }

        y = y - LayerSelector.height - LayerSelector.gap
        for _, layer in ipairs(layerSet.layerOrder or {}) do
            local layerKey = layer.key or layer.id
            local layerButton = LayerSelector.CreateButton(parent, LayerSelector.LayerButtonText(layer), LayerSelector.subWidth, LayerSelector.subHeight)
            local buttonLayerKey = layerKey
            local buttonLayerSetKey = layerSetKey
            UI.SetLayoutBox(layerButton, "TOPLEFT", parent, "TOPRIGHT", LayerSelector.subX, y, LayerSelector.subWidth, LayerSelector.subHeight)
            layerButton:SetScript("OnClick", function()
                NS:SetActiveLayer(buttonLayerKey, true)
            end)
            layerButton:SetScript("OnEnter", function(self)
                LayerSelector.ShowTooltip(self, UI.LayerDisplayName(buttonLayerKey), UI.LayerSetDisplayName(buttonLayerSetKey))
            end)
            layerButton:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            NS.layerButtons[#NS.layerButtons + 1] = {
                button = layerButton,
                layerSetKey = layerSetKey,
                layerKey = layerKey,
            }

            y = y - LayerSelector.subHeight - LayerSelector.gap
        end

        y = y - LayerSelector.groupGap
    end

    LayerSelector.Refresh()
end
