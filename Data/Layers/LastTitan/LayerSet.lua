local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local LayerSet = Data.LayerSet
local LayerKeys = NS.Data.LayerKeys

LayerSet({
    key = "lastTitan",
    name = "The Last Titan",
    buttonText = "TLT",
    layout = "midnight",
    defaultLayer = LayerKeys.LAST_TITAN_S1,
})
