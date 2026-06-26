local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layer = Data.Layer
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell

local TABLE_RAID = "midnight.raid"
local TABLE_ACTIVITY = "midnight.activity"
local TABLE_DUNGEON = "midnight.dungeon"
local TABLE_DELVE = "midnight.delve"
local LAYER = NS.Data.LayerKeys.MIDNIGHT_S2

local function Block(definition)
    definition.table = definition.table or TABLE_RAID
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
    id = "midnight.s2.veteran",
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
    id = "midnight.s2.champion",
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

        MergedCell({ col = "g", row = 22, toRow = 27, text = "Champion", vertical = true }),

        Cell({ col = "b", row = 26, text = "GV", border = { right = "dashed", bottom = "dashed" }, tooltip = { title = "Normal Great Vault Reward" } }),
    },
})

Block({
    id = "midnight.s2.hero",
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "b", row = 27, toRow = 29, text = "Heroic", vertical = true, tooltip = { title = "Heroic Raid Drops from first 6 Bosses" } }),
        Cell({ col = "b", row = 31, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare Heroic raid drops" } }),
        Cell({ col = "b", row = 33, text = "VF", tooltip = { title = "Venomforged Heroic Item" } }),

        Cell({ col = "c", row = 26, text = "1/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 27, text = "2/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 28, text = "3/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 29, text = "4/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 30, text = "5/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 31, text = "6/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 33, text = "8/6", tooltip = { title = "Hero Upgrade Track" } }),

        MergedCell({ col = "d", row = 26, toRow = 31, text = "Hero", vertical = true }),

        Cell({ col = "e", row = 30, text = "GV", border = { right = "dashed", bottom = "dashed" }, tooltip = { title = "Heroic Great Vault Reward" } }),
    },
})

Block({
    id = "midnight.s2.mythic",
    layer = LAYER,
    bg = "purple",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "e", row = 31, toRow = 33, text = "Mythic", vertical = true, tooltip = { title = "Mythic Raid Drops from first 6 Bosses" } }),
        Cell({ col = "e", row = 37, text = "VF", tooltip = { title = "Venomforged Mythic reward" } }),
        Cell({ col = "e", row = 38, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare Mythic raid drops" } }),
        Cell({ col = "e", row = 35, text = "GV", border = { right = "dashed", bottom = "dashed" }, tooltip = { title = "Mythic Great Vault Reward" } }),

        Cell({ col = "f", row = 30, text = "1/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 31, text = "2/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 32, text = "3/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 33, text = "4/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 34, text = "5/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 35, text = "6/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 37, text = "8/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 38, text = "9/6", tooltip = { title = "Myth Upgrade Track" } }),

        MergedCell({ col = "g", row = 30, toRow = 38, text = "Myth", vertical = true }),
        MergedCell({ col = "c", toCol = "d", row = 38, text = "Last 2", vertical = false, tooltip = { title = "Last 2 Mythic raid drops" } }),
    },
})

--------------------------------------------------------------------------------
--- Crafting

Block({
    id = "midnight.s2.craft.adventurer",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "h", row = 14, text = "R1", tooltip = { title = "Adventurer Crest Crafted R1" } }),
        Cell({ col = "h", row = 15, text = "R2", tooltip = { title = "Adventurer Crest Crafted R2" } }),
        Cell({ col = "h", row = 16, text = "R3", tooltip = { title = "Adventurer Crest Crafted R3" } }),
        Cell({ col = "h", row = 17, text = "R4", tooltip = { title = "Adventurer Crest Crafted R4" } }),
        Cell({ col = "h", row = 18, text = "R5", tooltip = { title = "Adventurer Crest Crafted R5" } }),
        MergedCell({ col = "i", row = 14, toRow = 17, text = "30 Adv.", bg = "pink", vertical = true }),
    },
})

Block({
    id = "midnight.s2.craft.veteran",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "i", row = 18, text = "R1", tooltip = { title = "Veteran Crest Crafted R1" } }),
        Cell({ col = "i", row = 19, text = "R2", tooltip = { title = "Veteran Crest Crafted R2" } }),
        Cell({ col = "i", row = 20, text = "R3", tooltip = { title = "Veteran Crest Crafted R3" } }),
        Cell({ col = "i", row = 21, text = "R4", tooltip = { title = "Veteran Crest Crafted R4" } }),
        Cell({ col = "i", row = 22, text = "R5", tooltip = { title = "Veteran Crest Crafted R5" } }),
        MergedCell({ col = "h", row = 19, toRow = 21, text = "30 Vet.", vertical = true }),
    },
})

Block({
    id = "midnight.s2.craft.champion",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "h", row = 22, text = "R1", tooltip = { title = "Spark Crest Crafted R1" } }),
        Cell({ col = "h", row = 23, text = "R2", tooltip = { title = "Spark Crest Crafted R2" } }),
        Cell({ col = "h", row = 24, text = "R3", tooltip = { title = "Spark Crest Crafted R3" } }),
        Cell({ col = "h", row = 25, text = "R4", tooltip = { title = "Spark Crest Crafted R4" } }),
        Cell({ col = "h", row = 26, text = "R5", tooltip = { title = "Spark Crest Crafted R5" } }),
        MergedCell({ col = "i", row = 23, toRow = 25, text = "Spark", vertical = true }),
    },
})

Block({
    id = "midnight.s2.craft.hero",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "i", row = 26, text = "R1", tooltip = { title = "Spark + Hero Crest Crafted R1" } }),
        Cell({ col = "i", row = 27, text = "R2", tooltip = { title = "Spark + Hero Crest Crafted R2" } }),
        Cell({ col = "i", row = 28, text = "R3", tooltip = { title = "Spark + Hero Crest Crafted R3" } }),
        Cell({ col = "i", row = 29, text = "R4", tooltip = { title = "Spark + Hero Crest Crafted R4" } }),
        Cell({ col = "i", row = 30, text = "R5", tooltip = { title = "Spark + Hero Crest Crafted R5" } }),
        MergedCell({ col = "h", row = 27, toRow = 29, text = "80 Hero", vertical = true }),
    },
})

Block({
    id = "midnight.s2.craft.myth",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "purple",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "h", row = 30, text = "R1", tooltip = { title = "Spark + Myth Crest Crafted R1" } }),
        Cell({ col = "h", row = 31, text = "R2", tooltip = { title = "Spark + Myth Crest Crafted R2" } }),
        Cell({ col = "h", row = 32, text = "R3", tooltip = { title = "Spark + Myth Crest Crafted R3" } }),
        Cell({ col = "h", row = 33, text = "R4", tooltip = { title = "Spark + Myth Crest Crafted R4" } }),
        Cell({ col = "h", row = 34, text = "R5", tooltip = { title = "Spark + Myth Crest Crafted R5" } }),
        MergedCell({ col = "i", row = 31, toRow = 34, text = "80 Myth", vertical = true }),
        MergedCell({ col = "h", toCol = "i", row = 37, text = "VF", vertical = false, tooltip = { title = "Venomforged craft" } }),
    },
})

--------------------------------------------------------------------------------
--- Activity

Block({
    id = "midnight.s2.activity.muted",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "muted",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "e", row = 12, text = "N" }),
    },
})

Block({
    id = "midnight.s2.activity.pink",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "a", row = 16, text = "N" }),
        Cell({ col = "b", row = 17, text = "1-3" }),
        Cell({ col = "b", row = 18, text = "4" }),
        Cell({ col = "e", row = 17, text = "H" }),
    },
})

Block({
    id = "midnight.s2.activity.blue",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "a", row = 21, text = "H" }),
        Cell({ col = "b", row = 19, text = "5" }),
        Cell({ col = "b", row = 20, text = "6" }),
        Cell({ col = "b", row = 21, text = "7" }),
        Cell({ col = "b", row = 22, text = "8+" }),
        Cell({ col = "c", row = 19, text = "4" }),
        Cell({ col = "c", row = 21, text = "5" }),
        Cell({ col = "d", row = 18, text = "1-2" }),
        Cell({ col = "d", row = 19, text = "3" }),
        Cell({ col = "f", row = 21, text = "H" }),
    },
})

Block({
    id = "midnight.s2.activity.yellow",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "a", row = 22, text = "NM" }),
        Cell({ col = "c", row = 23, text = "6" }),
        Cell({ col = "c", row = 25, text = "7" }),
        Cell({ col = "d", row = 22, text = "4" }),
        Cell({ col = "d", row = 24, text = "5" }),
        Cell({ col = "d", row = 25, text = "6" }),
        Cell({ col = "d", row = 26, text = "7" }),
        Cell({ col = "e", row = 22, text = "M" }),
        Cell({ col = "e", row = 23, text = "2-3" }),
        Cell({ col = "e", row = 24, text = "4" }),
        Cell({ col = "e", row = 25, text = "5" }),
        Cell({ col = "f", row = 25, text = "M" }),
    },
})

Block({
    id = "midnight.s2.activity.red",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "a", row = 26, text = "NM1" }),
        Cell({ col = "b", row = 26, text = "8+1" }),
        Cell({ col = "c", row = 26, text = "8+" }),
        Cell({ col = "d", row = 28, text = "8+" }),
        Cell({ col = "e", row = 26, text = "6-7" }),
        Cell({ col = "e", row = 27, text = "8-9" }),
        Cell({ col = "e", row = 28, text = "10+" }),
        Cell({ col = "f", row = 26, text = "2-3" }),
        Cell({ col = "f", row = 27, text = "4-5" }),
        Cell({ col = "f", row = 28, text = "6" }),
        Cell({ col = "f", row = 29, text = "7-9" }),
    },
})

Block({
    id = "midnight.s2.activity.purple",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "purple",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "f", row = 30, text = "10+" }),
    },
})


--------------------------------------------------------------------------------
--- Dungeon

Block({
    id = "midnight.s2.dungeon.levels",
    table = TABLE_DUNGEON,
    layer = LAYER,
    bg = "light",
    border = "solid1",
    innerRowBorder = "dashed",
    bold = true,
    cells = {
        Cell({ col = "a", row = 2, text = "N" }),
        Cell({ col = "a", row = 3, text = "H" }),
        Cell({ col = "a", row = 4, text = "M" }),
        Cell({ col = "a", row = 5, text = "+2" }),
        Cell({ col = "a", row = 6, text = "+3" }),
        Cell({ col = "a", row = 7, text = "+4" }),
        Cell({ col = "a", row = 8, text = "+5" }),
        Cell({ col = "a", row = 9, text = "+6" }),
        Cell({ col = "a", row = 10, text = "+7" }),
        Cell({ col = "a", row = 11, text = "+8" }),
        Cell({ col = "a", row = 12, text = "+9" }),
        Cell({ col = "a", row = 13, text = "+10" }),
        Cell({ col = "a", row = 14, text = "+11" }),
        Cell({ col = "a", row = 15, text = "+12" }),
    },
})

Block({
    id = "midnight.s2.dungeon.section",
    table = TABLE_DUNGEON,
    layer = LAYER,
    bg = "light",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        MergedCell({ col = "g", row = 2, toRow = 15, text = "Dungeon", vertical = true }),
    },
})

Block({
    id = "midnight.s2.dungeon.normal",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "muted",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 2, text = "253" }),
        Cell({ col = "c", row = 2, text = "-" }),
    },
})

Block({
    id = "midnight.s2.dungeon.heroic",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "blue",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 3, text = "269", bg = "pink" }),
        Cell({ col = "c", row = 3, text = "4/6", bg = "pink" }),
        Cell({ col = "d", row = 3, text = "285"}),
        Cell({ col = "e", row = 3, text = "4/6"}),
        Cell({ col = "f", row = 3, text = "10 V"}),
    },
})

Block({
    id = "midnight.s2.dungeon.yellow",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "yellow",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 4, text = "285" }),
        Cell({ col = "b", row = 5, text = "289" }),
        Cell({ col = "b", row = 6, text = "289" }),
        Cell({ col = "b", row = 7, text = "292" }),
        Cell({ col = "b", row = 8, text = "295" }),

        Cell({ col = "c", row = 4, text = "1/6" }),
        Cell({ col = "c", row = 6, text = "2/6" }),
        Cell({ col = "c", row = 5, text = "2/6" }),
        Cell({ col = "c", row = 7, text = "3/6" }),
        Cell({ col = "c", row = 8, text = "4/6" }),

        Cell({ col = "d", row = 4, text = "295" }),

        Cell({ col = "e", row = 4, text = "4/6" }),

        Cell({ col = "f", row = 4, text = "10 C" }),
        Cell({ col = "f", row = 5, text = "12 C" }),
        Cell({ col = "f", row = 6, text = "14 C" }),

    },
})

Block({
    id = "midnight.s2.dungeon.red",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "red",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 9, text = "298" }),
        Cell({ col = "b", row = 10, text = "298" }),
        Cell({ col = "b", row = 11, text = "302" }),
        Cell({ col = "b", row = 12, text = "302" }),
        Cell({ col = "b", row = 13, text = "305" }),
        Cell({ col = "b", row = 14, text = "305" }),
        Cell({ col = "b", row = 15, text = "305" }),

        Cell({ col = "c", row = 9, text = "1/6" }),
        Cell({ col = "c", row = 10, text = "1/6" }),
        Cell({ col = "c", row = 11, text = "2/6" }),
        Cell({ col = "c", row = 12, text = "2/6" }),
        Cell({ col = "c", row = 13, text = "3/6" }),
        Cell({ col = "c", row = 14, text = "3/6" }),
        Cell({ col = "c", row = 15, text = "3/6" }),

        Cell({ col = "d", row = 5, text = "298" }),
        Cell({ col = "d", row = 6, text = "298" }),
        Cell({ col = "d", row = 7, text = "302" }),
        Cell({ col = "d", row = 8, text = "302" }),
        Cell({ col = "d", row = 9, text = "305" }),
        Cell({ col = "d", row = 10, text = "308" }),
        Cell({ col = "d", row = 11, text = "308" }),
        Cell({ col = "d", row = 12, text = "308" }),

        Cell({ col = "e", row = 5, text = "1/6" }),
        Cell({ col = "e", row = 6, text = "1/6" }),
        Cell({ col = "e", row = 7, text = "2/6" }),
        Cell({ col = "e", row = 8, text = "2/6" }),
        Cell({ col = "e", row = 9, text = "3/6" }),
        Cell({ col = "e", row = 10, text = "4/6" }),
        Cell({ col = "e", row = 11, text = "4/6" }),
        Cell({ col = "e", row = 12, text = "4/6" }),

        Cell({ col = "f", row = 7, text = "10 H" }),
        Cell({ col = "f", row = 8, text = "12 H" }),
        Cell({ col = "f", row = 9, text = "14 H" }),
        Cell({ col = "f", row = 10, text = "16 H" }),
        Cell({ col = "f", row = 11, text = "18 H" }),
    },
})

Block({
    id = "midnight.s2.dungeon.purple",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "purple",
    border = "solid1",
    cells = {
        Cell({ col = "d", row = 13, text = "311" }),
        Cell({ col = "d", row = 14, text = "311" }),
        Cell({ col = "d", row = 15, text = "311" }),

        Cell({ col = "e", row = 13, text = "1/6" }),
        Cell({ col = "e", row = 14, text = "1/6" }),
        Cell({ col = "e", row = 15, text = "1/6" }),

        Cell({ col = "f", row = 12, text = "10 M" }),
        Cell({ col = "f", row = 13, text = "12 M" }),
        Cell({ col = "f", row = 14, text = "14 M" }),
        Cell({ col = "f", row = 15, text = "16 M" }),
    },
})

--------------------------------------------------------------------------------
--- Delve

Block({
    id = "midnight.s2.delve.levels",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "light",
    border = "solid1",
    innerRowBorder = "dashed",
    bold = true,
    cells = {
        Cell({ col = "a", row = 2, text = "1" }),
        Cell({ col = "a", row = 3, text = "2" }),
        Cell({ col = "a", row = 4, text = "3" }),
        Cell({ col = "a", row = 5, text = "4" }),
        Cell({ col = "a", row = 6, text = "5" }),
        Cell({ col = "a", row = 7, text = "6" }),
        Cell({ col = "a", row = 8, text = "7" }),
        Cell({ col = "a", row = 9, text = "8" }),
        Cell({ col = "a", row = 10, text = "9" }),
        Cell({ col = "a", row = 11, text = "10" }),
        Cell({ col = "a", row = 12, text = "11" }),
    },
})

Block({
    id = "midnight.s2.delve.section",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "light",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        MergedCell({ col = "g", row = 2, toRow = 12, text = "Delve", vertical = true }),
    },
})

Block({
    id = "midnight.s2.delve.pink",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "b", row = 2, text = "259" }),
        Cell({ col = "c", row = 2, text = "1/6" }),
        Cell({ col = "b", row = 3, text = "263" }),
        Cell({ col = "c", row = 3, text = "2/6" }),
        Cell({ col = "b", row = 4, text = "266" }),
        Cell({ col = "c", row = 4, text = "3/6" }),
        Cell({ col = "b", row = 5, text = "269" }),
        Cell({ col = "c", row = 5, text = "4/6" }),
        Cell({ col = "f", row = 5, text = "A" }),
    },
})

Block({
    id = "midnight.s2.delve.blue",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "d", row = 2, text = "272" }),
        Cell({ col = "e", row = 2, text = "1/6" }),
        Cell({ col = "d", row = 3, text = "276" }),
        Cell({ col = "e", row = 3, text = "2/6" }),
        Cell({ col = "d", row = 4, text = "279" }),
        Cell({ col = "e", row = 4, text = "3/6" }),
        Cell({ col = "d", row = 5, text = "282" }),
        Cell({ col = "e", row = 5, text = "4/6" }),
        Cell({ col = "b", row = 6, text = "272" }),
        Cell({ col = "c", row = 6, text = "1/6" }),
        Cell({ col = "f", row = 6, text = "V" }),
        Cell({ col = "b", row = 7, text = "276" }),
        Cell({ col = "c", row = 7, text = "2/6" }),
        Cell({ col = "f", row = 7, text = "V" }),
    },
})

Block({
    id = "midnight.s2.delve.yellow",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "d", row = 6, text = "285" }),
        Cell({ col = "e", row = 6, text = "1/6" }),
        Cell({ col = "d", row = 7, text = "292" }),
        Cell({ col = "e", row = 7, text = "3/6" }),
        Cell({ col = "b", row = 8, text = "285" }),
        Cell({ col = "c", row = 8, text = "2/6" }),
        Cell({ col = "d", row = 8, text = "295" }),
        Cell({ col = "e", row = 8, text = "4/6" }),
        Cell({ col = "f", row = 8, text = "C" }),
        Cell({ col = "b", row = 9, text = "285" }),
        Cell({ col = "c", row = 9, text = "2/6" }),
        Cell({ col = "f", row = 9, text = "C" }),
        Cell({ col = "b", row = 10, text = "285" }),
        Cell({ col = "c", row = 10, text = "2/6" }),
        Cell({ col = "f", row = 10, text = "C" }),
        Cell({ col = "b", row = 11, text = "285" }),
        Cell({ col = "c", row = 11, text = "2/6" }),
        Cell({ col = "f", row = 11, text = "C" }),
        Cell({ col = "b", row = 12, text = "285" }),
        Cell({ col = "c", row = 12, text = "2/6" }),
    },
})

Block({
    id = "midnight.s2.delve.red",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "d", row = 9, text = "298" }),
        Cell({ col = "e", row = 9, text = "1/6" }),
        Cell({ col = "d", row = 10, text = "298" }),
        Cell({ col = "e", row = 10, text = "1/6" }),
        Cell({ col = "d", row = 11, text = "298" }),
        Cell({ col = "e", row = 11, text = "1/6" }),
        Cell({ col = "d", row = 12, text = "298" }),
        Cell({ col = "e", row = 12, text = "1/6" }),
        Cell({ col = "f", row = 12, text = "H" }),
    },
})
