local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local LayerSet = Data.LayerSet

local LayerKeys = NS.Data.LayerKeys

LayerKeys.MIDNIGHT_S1 = "midnight.s1"
LayerKeys.MIDNIGHT_S2 = "midnight.s2"

LayerSet({
    key = "midnight",
    name = "Midnight",
    buttonText = "MID",
    layout = "midnight",
    active = true,
    defaultLayer = LayerKeys.MIDNIGHT_S2,
    layers = {
        {
            key = LayerKeys.MIDNIGHT_S1,
            name = "Midnight Season 1",
            buttonText = "S1",
            order = 10,
            inactiveAlpha = 0.3,
            footer = {
                right = "Midnight Season 1",
            },
        },
        {
            key = LayerKeys.MIDNIGHT_S2,
            name = "Midnight Season 2",
            buttonText = "S2",
            order = 20,
            active = true,
            inactiveAlpha = 0.3,
            footer = {
                right = "1 Once a Week | VF: Venomforged | GV: Great Vault",
            },
        },
    },
})
