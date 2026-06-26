local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layer = Data.Layer
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell

local TABLE_PRIMARY = "midnight.raid"
local LAYER = NS.Data.LayerKeys.MIDNIGHT_S2

local function Block(definition)
    definition.table = definition.table or TABLE_PRIMARY
    return RawBlock(definition)
end

Layer({
    key = LAYER,
    layerSet = "midnight",
    name = "Midnight Season 2",
    buttonText = "S2",
    order = 20,
    active = true,
    inactiveAlpha = 0.3,
    footer = {
        right = "1 Once a Week | VF: Venomforged | GV: Great Vault",
    },
})

Block({
    id = "midnight.s2.adventurer",
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "f", row = 14, text = "1/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 15, text = "2/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 16, text = "3/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 17, text = "4/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 18, text = "5/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 19, text = "6/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        MergedCell({ col = "g", row = 14, toRow = 19, text = "Adventurer", vertical = true }),
    },
})

Block({
    id = "veteran",
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "b", row = 19, toRow = 21, text = "LFR", vertical = true, tooltip = { title = "LFR Raid Drops from first 6 Bosses" } }),
        Cell({ col = "b", row = 23, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare LFR raid drops" } }),

        Cell({ col = "c", row = 18, text = "1/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 19, text = "2/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 20, text = "3/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 21, text = "4/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 22, text = "5/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 23, text = "6/6", tooltip = { title = "Veteran Upgrade Track" } }),

        MergedCell({ col = "d", row = 18, toRow = 23, text = "Veteran", vertical = true }),

        Cell({ col = "e", row = 22, text = "GV", border = { right = "dashed", bottom = "dashed" }, tooltip = { title = "LFR Great Vault Reward" } }),
    },
})

Block({
    id = "champion",
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "e", row = 23, toRow = 25, text = "Normal", vertical = true, tooltip = { title = "Normal Raid Drops from first 6 Bosses" } }),
        Cell({ col = "e", row = 27, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare Normal raid drops" } }),

        Cell({ col = "f", row = 22, text = "1/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 23, text = "2/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 24, text = "3/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 25, text = "4/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 26, text = "5/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 27, text = "6/6", tooltip = { title = "Champion Upgrade Track" } }),

        MergedCell({ col = "g", row = 22, toRow = 27, text = "Veteran", vertical = true }),

        Cell({ col = "b", row = 26, text = "GV", border = { right = "dashed", bottom = "dashed" }, tooltip = { title = "Normal Great Vault Reward" } }),
    },
})
