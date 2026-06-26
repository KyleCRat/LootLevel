local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local LayerSet = Data.LayerSet
local LayerKeys = NS.Data.LayerKeys

LayerSet({
    key = "midnight",
    name = "Midnight",
    buttonText = "MID",
    layout = "midnight",
    active = true,
    defaultLayer = LayerKeys.MIDNIGHT_S2,
})
