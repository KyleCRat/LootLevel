local ADDON_NAME, NS = ...

local UI = NS.UI
local LayerConfig = UI.LayerState
local Layers = {}
UI.Layers = Layers

local layerRenderContext

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

local function LayerSetDisplayName(layerSetKey)
    local layerSet = LayerSetData(layerSetKey)
    return layerSet and (layerSet.name or layerSet.key or layerSet.id) or layerSetKey
end

local function LayerSetLayoutKey(layerSetKey)
    local layerSet = LayerSetData(layerSetKey)
    local layoutKey = layerSet and (layerSet.layout or layerSet.layoutKey)
    if not layoutKey and NS.Data then
        layoutKey = NS.Data.defaultLayout
    end

    return layoutKey
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

local function GetActiveLayerSetKey()
    if layerRenderContext and layerRenderContext.activeLayerSet then
        return layerRenderContext.activeLayerSet
    end

    local configured = NormalizeLayerSetKey(NS.db and NS.db.activeLayerSet)
    if configured then
        return configured
    end

    local legacyLayer = NormalizeLayerKey(NS.db and NS.db.activeLayer)
    local legacyLayerSet = LayerSetKeyForLayer(legacyLayer)
    if legacyLayerSet then
        return legacyLayerSet
    end

    return DefaultLayerSetKey()
end

local function GetActiveLayerKey(layerSetKey)
    layerSetKey = NormalizeLayerSetKey(layerSetKey) or layerSetKey or GetActiveLayerSetKey()

    if layerRenderContext and layerRenderContext.activeLayers and layerSetKey then
        local contextualLayer = NormalizeLayerKey(layerRenderContext.activeLayers[layerSetKey])
        if contextualLayer and LayerBelongsToSet(contextualLayer, layerSetKey) then
            return contextualLayer
        end
    end

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

local function LayerSetSharesActiveLayout(layerSetKey)
    local activeLayout = LayerSetLayoutKey(GetActiveLayerSetKey())
    local layoutKey = LayerSetLayoutKey(layerSetKey)
    return activeLayout ~= nil and layoutKey == activeLayout
end

local function LayerRenderStateKey(state)
    state = state or {}
    return ("%s:%s"):format(tostring(state.activeLayerSet or ""), tostring(state.activeLayer or ""))
end

local function CurrentLayerRenderState()
    local activeLayerSet = GetActiveLayerSetKey()
    local activeLayer = GetActiveLayerKey(activeLayerSet)
    return {
        key = LayerRenderStateKey({
            activeLayerSet = activeLayerSet,
            activeLayer = activeLayer,
        }),
        activeLayerSet = activeLayerSet,
        activeLayer = activeLayer,
        activeLayers = {
            [activeLayerSet or ""] = activeLayer,
        },
    }
end

local function ForEachLayerRenderState(callback)
    if type(callback) ~= "function" then
        return
    end

    local seen = {}
    for _, layerSet in ipairs((NS.Data and NS.Data.layerSetOrder) or {}) do
        local layerSetKey = layerSet.key or layerSet.id
        for _, layer in ipairs(layerSet.layerOrder or {}) do
            local layerKey = layer.key or layer.id
            local state = {
                activeLayerSet = layerSetKey,
                activeLayer = layerKey,
                activeLayers = {
                    [layerSetKey or ""] = layerKey,
                },
            }
            state.key = LayerRenderStateKey(state)
            if not seen[state.key] then
                seen[state.key] = true
                callback(state)
            end
        end
    end

    local currentState = CurrentLayerRenderState()
    if currentState.key and not seen[currentState.key] then
        callback(currentState)
    end
end

local function IsLayerActive(layerKey)
    local activeLayerSet = GetActiveLayerSetKey()
    local layerSetKey = LayerSetKeyForLayer(layerKey)
    local activeLayer = GetActiveLayerKey(activeLayerSet)
    return activeLayerSet ~= nil and layerSetKey == activeLayerSet and activeLayer ~= nil and layerKey ~= nil and layerKey == activeLayer
end

local function LayerRenderOrder(layerKey)
    local layer = LayerData(layerKey)
    local order = tonumber(layer and layer.order) or 0
    if IsLayerActive(layerKey) then
        order = order + LayerConfig.activeOrderBonus
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

    local layerSetKey = LayerSetKeyForLayer(layerKey)
    if not layerSetKey or not LayerSetSharesActiveLayout(layerSetKey) then
        return 1
    end

    if IsLayerActive(layerKey) then
        return UI.Clamp(tonumber(layer and layer.activeAlpha) or 1, 0, 1)
    end

    return UI.Clamp(tonumber(layer and layer.inactiveAlpha) or LayerConfig.defaultInactiveAlpha, 0, 1)
end

local function IsLayerVisible(layerKey)
    local layer = LayerData(layerKey)
    local layerSetKey = LayerSetKeyForLayer(layerKey)
    if layer and layerSetKey and not LayerSetSharesActiveLayout(layerSetKey) then
        return false
    end

    return not layer or layer.visible ~= false or IsLayerActive(layerKey)
end

local function SetRenderContext(state)
    local previous = layerRenderContext
    layerRenderContext = state
    return previous
end

function NS:GetActiveLayerKey(layerSetKey)
    return GetActiveLayerKey(layerSetKey)
end

function NS:GetActiveLayerSetKey()
    return GetActiveLayerSetKey()
end

function NS:RefreshLayerRendering()
    if self.IsCombatLocked and self:IsCombatLocked() then
        return
    end

    if UI.RenderCache and UI.RenderCache.RefreshParent then
        for _, parent in ipairs(self.gridParents or {}) do
            UI.RenderCache.RefreshParent(parent)
        end
    end
    if UI.RefreshFooterText then
        UI.RefreshFooterText()
    end
    if UI.LayerSelector and UI.LayerSelector.Refresh then
        UI.LayerSelector.Refresh()
    end
end

function NS:SetActiveLayerSet(layerSetKey, silent)
    local normalized = NormalizeLayerSetKey(layerSetKey)
    if not normalized then
        self:Print(("Unknown layer set: %s"):format(tostring(layerSetKey or "")))
        return false
    end

    if self.BlockCombatAction and self:BlockCombatAction("Changing layer sets", silent) then
        return false
    end

    if not self.db then
        return false
    end

    local previousLayerSet = GetActiveLayerSetKey()
    self.db.activeLayerSet = normalized
    if type(self.db.activeLayers) ~= "table" then
        self.db.activeLayers = {}
    end

    local activeLayer = GetActiveLayerKey(normalized)
    if activeLayer then
        self.db.activeLayers[normalized] = activeLayer
        self.db.activeLayer = activeLayer
    end

    if self.RefreshMainFrameLayout and previousLayerSet ~= normalized then
        self:RefreshMainFrameLayout()
    end
    if UI.ApplyActiveLayerBodyScrollDefaults then
        UI.ApplyActiveLayerBodyScrollDefaults(true)
    end
    self:RefreshLayerRendering()
    if not silent then
        self:Print(("Active layer set: %s"):format(LayerSetDisplayName(normalized)))
    end
    return true
end

function NS:SetActiveLayer(layerKey, silent)
    local normalized = NormalizeLayerKey(layerKey)
    if not normalized then
        self:Print(("Unknown layer: %s"):format(tostring(layerKey or "")))
        return false
    end

    if self.BlockCombatAction and self:BlockCombatAction("Changing layers", silent) then
        return false
    end

    if not self.db then
        return false
    end

    local previousLayerSet = GetActiveLayerSetKey()
    local layerSetKey = LayerSetKeyForLayer(normalized)
    if type(self.db.activeLayers) ~= "table" then
        self.db.activeLayers = {}
    end
    if layerSetKey then
        self.db.activeLayerSet = layerSetKey
        self.db.activeLayers[layerSetKey] = normalized
    end
    self.db.activeLayer = normalized
    if self.RefreshMainFrameLayout and layerSetKey then
        self:RefreshMainFrameLayout()
    end
    if UI.ApplyActiveLayerBodyScrollDefaults then
        UI.ApplyActiveLayerBodyScrollDefaults(true)
    end
    self:RefreshLayerRendering()
    if not silent then
        self:Print(("Active layer: %s"):format(LayerDisplayName(normalized)))
    end
    return true
end

Layers.LayerData = LayerData
Layers.LayerSetData = LayerSetData
Layers.NormalizeLayerSetKey = NormalizeLayerSetKey
Layers.NormalizeLayerKey = NormalizeLayerKey
Layers.LayerSetKeyForLayer = LayerSetKeyForLayer
Layers.LayerDisplayName = LayerDisplayName
Layers.LayerSetDisplayName = LayerSetDisplayName
Layers.LayerSetLayoutKey = LayerSetLayoutKey
Layers.LayerSetSharesActiveLayout = LayerSetSharesActiveLayout
Layers.LayerRenderStateKey = LayerRenderStateKey
Layers.CurrentLayerRenderState = CurrentLayerRenderState
Layers.ForEachLayerRenderState = ForEachLayerRenderState
Layers.IsLayerActive = IsLayerActive
Layers.LayerRenderOrder = LayerRenderOrder
Layers.LayerVisualAlpha = LayerVisualAlpha
Layers.IsLayerVisible = IsLayerVisible
Layers.GetActiveLayerSetKey = GetActiveLayerSetKey
Layers.GetActiveLayerKey = GetActiveLayerKey
Layers.SetRenderContext = SetRenderContext

UI.LayerDisplayName = LayerDisplayName
UI.LayerSetDisplayName = LayerSetDisplayName
