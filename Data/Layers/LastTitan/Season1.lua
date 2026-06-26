local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layer = Data.Layer
local LayerKeys = NS.Data.LayerKeys

Layer({
    key = LayerKeys.LAST_TITAN_S1,
    layerSet = "lastTitan",
    name = "The Last Titan Season 1",
    buttonText = "S1",
    order = 30,
    inactiveAlpha = 0.3,
    footer = {
        right = "The Last Titan Season 1 test layer",
    },
})
