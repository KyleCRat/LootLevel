local ADDON_NAME, NS = ...

local UI = NS.UI
local Helpers = NS.Helpers
local CellStyles = {}
UI.CellStyles = CellStyles

local function SetCellStyleLayer(cellData, layerKey, specificity, values)
    if not cellData or not layerKey or type(values) ~= "table" then
        return
    end

    cellData.styleLayers = cellData.styleLayers or {}
    local layer = cellData.styleLayers[layerKey] or {}
    layer.specificity = specificity or layer.specificity or 0

    Helpers.ShallowAssign(layer, values)

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

    return UI.Clamp(alpha, 0, 1)
end

local function ApplyCellVisualStyle(cell, bg, alpha)
    local cellData = cell and cell.cellData
    if not cellData then
        return
    end

    bg = bg or "blank"
    alpha = UI.Clamp(tonumber(alpha) or 1, 0, 1)
    cellData.resolvedBg = bg
    cellData.resolvedAlpha = alpha

    if cell.bg then
        cell.bg:SetColorTexture(UI.Color(bg))
    end
    if cell.text then
        cell.text:SetTextColor(UI.TextColorFor(bg))
    end
    if cell.SetAlpha then
        cell:SetAlpha(alpha)
    end
end

local function ApplyCellResolvedStyle(cell)
    local cellData = cell and cell.cellData
    if not cellData then
        return
    end

    ApplyCellVisualStyle(cell, ResolveCellBackgroundColor(cellData), ResolveCellVisualAlpha(cellData))
end

CellStyles.SetCellStyleLayer = SetCellStyleLayer
CellStyles.ResolveCellStyleValue = ResolveCellStyleValue
CellStyles.ResolveCellBackgroundColor = ResolveCellBackgroundColor
CellStyles.ResolveCellVisualAlpha = ResolveCellVisualAlpha
CellStyles.ApplyCellVisualStyle = ApplyCellVisualStyle
CellStyles.ApplyCellResolvedStyle = ApplyCellResolvedStyle
