local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layer = Data.Layer
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell

local TABLE_PRIMARY = "midnight.raid"
local LAYER = NS.Data.LayerKeys.MIDNIGHT_S1

local function Block(definition)
    definition.table = definition.table or TABLE_PRIMARY
    return RawBlock(definition)
end

Layer({
    key = LAYER,
    layerSet = "midnight",
    name = "Midnight Season 1",
    buttonText = "S1",
    order = 10,
    inactiveAlpha = 0.3,
    bodyScroll = {
        ["midnight.raidActivity"] = { row = 2 },
    },
    footer = {
        right = "Midnight Season 1",
    },
})

Block({
    id = "midnight.s1.adventurer",
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "f", row = 2, text = "1/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 3, text = "2/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 4, text = "3/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 5, text = "4/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 6, text = "5/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 7, text = "6/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        MergedCell({ col = "g", row = 2, toRow = 7, text = "Adventurer", vertical = true }),
    },
})
