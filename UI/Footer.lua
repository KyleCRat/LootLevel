local ADDON_NAME, NS = ...

local UI = NS.UI

local function LayerData(layerKey)
    return layerKey and NS.Data and NS.Data.layers and NS.Data.layers[layerKey] or nil
end

local function LayerSetData(layerSetKey)
    return layerSetKey and NS.Data and NS.Data.layerSets and NS.Data.layerSets[layerSetKey] or nil
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
    local layerSetKey = NS.GetActiveLayerSetKey and NS:GetActiveLayerSetKey() or NS.Data.defaultLayerSet
    local layerSet = LayerSetData(layerSetKey)
    local activeLayerKey = NS.GetActiveLayerKey and NS:GetActiveLayerKey(layerSetKey) or nil
    local activeLayer = LayerData(activeLayerKey)
    return LayerFooterText(activeLayer, "right") or LayerFooterText(layerSet, "right") or NS.Data.footerRight or ""
end

function UI.RefreshFooterText()
    if NS.footerRightText then
        NS.footerRightText:SetText(ActiveFooterRightText())
    end
end

function UI.BuildFooter(parent)
    local footer = CreateFrame("Frame", nil, parent)
    UI.SetLayoutPoints(footer, {
        { point = "BOTTOMLEFT", relativeTo = parent, relativePoint = "BOTTOMLEFT", x = 14, y = 8 },
        { point = "BOTTOMRIGHT", relativeTo = parent, relativePoint = "BOTTOMRIGHT", x = -14, y = 8 },
    }, nil, 22)

    local left = UI.CreateText(footer, NS.Data.footerLeft, { size = 12 }, "white", "LEFT", "MIDDLE", false)
    UI.SetLayoutPoints(left, {
        { point = "LEFT", relativeTo = footer, relativePoint = "LEFT", x = 0, y = 0 },
        { point = "RIGHT", relativeTo = footer, relativePoint = "RIGHT", x = -420, y = 0 },
    }, nil, 20)

    local right = UI.CreateText(footer, ActiveFooterRightText(), { size = 12 }, "white", "RIGHT", "MIDDLE", false)
    UI.SetLayoutBox(right, "RIGHT", footer, "RIGHT", 0, 0, 410, 20)
    NS.footerRightText = right
    NS.footerFrame = footer
    return footer
end
