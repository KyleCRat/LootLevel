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
local LAYER = NS.Data.LayerKeys.MIDNIGHT_S1

local function Block(definition)
    definition.table = definition.table or TABLE_RAID
    return RawBlock(definition)
end

Layer({
    key = LAYER,
    layerSet = "midnight",
    name = "Midnight Season 1",
    buttonText = "S1",
    order = 10,
    inactiveAlpha = 0.2,
    bodyScroll = {
        ["midnight.raidActivity"] = { row = 2 },
    },
    footer = {
        left = "Midnight - Season 1 (12.0.0) - by Yvairel <Party Shark> <Suds with Buds>",
        right = "¹ Once a Week | VF: Voidforged | SF: Sporefall | GV: Great Vault",
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

Block({
    id = "midnight.s1.veteran",
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "b", row = 7, toRow = 9, text = "LFR", vertical = true, tooltip = { title = "LFR Raid Drops from first 6 Bosses" } }),
        Cell({ col = "b", row = 11, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare LFR raid drops" } }),

        Cell({ col = "c", row = 6, text = "1/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 7, text = "2/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 8, text = "3/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 9, text = "4/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 10, text = "5/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 11, text = "6/6", tooltip = { title = "Veteran Upgrade Track" } }),

        MergedCell({ col = "d", row = 6, toRow = 11, text = "Veteran", vertical = true }),

        Cell({ col = "e", row = 10, text = "SF", border = { right = "dashed", bottom = "dashed", left = "solid1" }, tooltip = { title = "LFR Sporefall Item Drop" } }),
    },
})

Block({
    id = "midnight.s1.champion",
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "e", row = 11, toRow = 13, text = "Normal", vertical = true, tooltip = { title = "Normal Raid Drops from first 6 Bosses" } }),
        Cell({ col = "e", row = 15, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare Normal raid drops" } }),

        Cell({ col = "f", row = 10, text = "1/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 11, text = "2/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 12, text = "3/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 13, text = "4/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 14, text = "5/6", tooltip = { title = "Champion Upgrade Track" } }),
        Cell({ col = "f", row = 15, text = "6/6", tooltip = { title = "Champion Upgrade Track" } }),

        MergedCell({ col = "g", row = 10, toRow = 15, text = "Champion", vertical = true }),

        Cell({ col = "b", row = 14, text = "SF", border = { right = "dashed", bottom = "dashed", left = "solid1" }, tooltip = { title = "Normal Sporefall Item Drop" } }),
    },
})

Block({
    id = "midnight.s1.hero",
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "b", row = 15, toRow = 17, text = "Heroic", vertical = true, tooltip = { title = "Heroic Raid Drops from first 6 Bosses" } }),
        Cell({ col = "b", row = 19, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare Heroic raid drops" } }),
        Cell({ col = "b", row = 22, text = "VF", tooltip = { title = "Heroic Voidforged Item" } }),

        Cell({ col = "c", row = 14, text = "1/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 15, text = "2/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 16, text = "3/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 17, text = "4/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 18, text = "5/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 19, text = "6/6", tooltip = { title = "Hero Upgrade Track" } }),
        Cell({ col = "c", row = 22, text = "8/6", tooltip = { title = "Hero Upgrade Track" } }),

        MergedCell({ col = "d", row = 14, toRow = 19, text = "Hero", vertical = true }),

        Cell({ col = "e", row = 18, text = "SF", border = { right = "dashed", bottom = "dashed", left = "solid1" }, tooltip = { title = "Heroic Sporefall Item Drop" } }),
    },
})

Block({
    id = "midnight.s1.mythic",
    layer = LAYER,
    bg = "purple",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "e", row = 19, toRow = 21, text = "Mythic", vertical = true, tooltip = { title = "Mythic Raid Drops" } }),
        Cell({ col = "e", row = 23, text = "Rare", font = { size = 10 }, tooltip = { title = "Very Rare Mythic Raid Drops" } }),
        Cell({ col = "e", row = 26, text = "SF", tooltip = { title = "Mythic Sporefall Item" } }),

        Cell({ col = "f", row = 18, text = "1/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 19, text = "2/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 20, text = "3/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 21, text = "4/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 22, text = "5/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 23, text = "6/6", tooltip = { title = "Myth Upgrade Track" } }),
        Cell({ col = "f", row = 26, text = "9/6", tooltip = { title = "Myth Upgrade Track" } }),

        MergedCell({ col = "g", row = 18, toRow = 23, text = "Myth", vertical = true }),
        Cell({ col = "g", row = 26, text = "VF", tooltip = { title = "Mythic Voidforged Item" } }),
    },
})

--------------------------------------------------------------------------------
--- Crafting

Block({
    id = "midnight.s1.craft.adventurer",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "h", row = 2, atlas = "Professions-Icon-Quality-Tier1", tooltip = { title = "Adventurer Crest Crafted R1" } }),
        Cell({ col = "h", row = 3, atlas = "Professions-Icon-Quality-Tier2", tooltip = { title = "Adventurer Crest Crafted R2" } }),
        Cell({ col = "h", row = 4, atlas = "Professions-Icon-Quality-Tier3", tooltip = { title = "Adventurer Crest Crafted R3" } }),
        Cell({ col = "h", row = 5, atlas = "Professions-Icon-Quality-Tier4", tooltip = { title = "Adventurer Crest Crafted R4" } }),
        Cell({ col = "h", row = 6, atlas = "Professions-Icon-Quality-Tier5", tooltip = { title = "Adventurer Crest Crafted R5" } }),
        MergedCell({ col = "i", row = 2, toRow = 5, text = "30 Adv.", bg = "pink", vertical = true }),
    },
})

Block({
    id = "midnight.s1.craft.veteran",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "i", row = 6, atlas = "Professions-Icon-Quality-Tier1", tooltip = { title = "Veteran Crest Crafted R1" } }),
        Cell({ col = "i", row = 7, atlas = "Professions-Icon-Quality-Tier2", tooltip = { title = "Veteran Crest Crafted R2" } }),
        Cell({ col = "i", row = 8, atlas = "Professions-Icon-Quality-Tier3", tooltip = { title = "Veteran Crest Crafted R3" } }),
        Cell({ col = "i", row = 9, atlas = "Professions-Icon-Quality-Tier4", tooltip = { title = "Veteran Crest Crafted R4" } }),
        Cell({ col = "i", row = 10, atlas = "Professions-Icon-Quality-Tier5", tooltip = { title = "Veteran Crest Crafted R5" } }),
        MergedCell({ col = "h", row = 7, toRow = 9, text = "30 Vet.", vertical = true }),
    },
})

Block({
    id = "midnight.s1.craft.champion",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "h", row = 10, atlas = "Professions-Icon-Quality-Tier1", tooltip = { title = "Spark Crest Crafted R1" } }),
        Cell({ col = "h", row = 11, atlas = "Professions-Icon-Quality-Tier2", tooltip = { title = "Spark Crest Crafted R2" } }),
        Cell({ col = "h", row = 12, atlas = "Professions-Icon-Quality-Tier3", tooltip = { title = "Spark Crest Crafted R3" } }),
        Cell({ col = "h", row = 13, atlas = "Professions-Icon-Quality-Tier4", tooltip = { title = "Spark Crest Crafted R4" } }),
        Cell({ col = "h", row = 14, atlas = "Professions-Icon-Quality-Tier5", tooltip = { title = "Spark Crest Crafted R5" } }),
        MergedCell({ col = "i", row = 11, toRow = 13, text = "Spark", vertical = true }),
    },
})

Block({
    id = "midnight.s1.craft.hero",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "i", row = 14, atlas = "Professions-Icon-Quality-Tier1", tooltip = { title = "Spark + Hero Crest Crafted R1" } }),
        Cell({ col = "i", row = 15, atlas = "Professions-Icon-Quality-Tier2", tooltip = { title = "Spark + Hero Crest Crafted R2" } }),
        Cell({ col = "i", row = 16, atlas = "Professions-Icon-Quality-Tier3", tooltip = { title = "Spark + Hero Crest Crafted R3" } }),
        Cell({ col = "i", row = 17, atlas = "Professions-Icon-Quality-Tier4", tooltip = { title = "Spark + Hero Crest Crafted R4" } }),
        Cell({ col = "i", row = 18, atlas = "Professions-Icon-Quality-Tier5", tooltip = { title = "Spark + Hero Crest Crafted R5" } }),
        MergedCell({ col = "h", row = 15, toRow = 17, text = "80 Hero", vertical = true }),
    },
})

Block({
    id = "midnight.s1.craft.myth",
    table = TABLE_RAID,
    layer = LAYER,
    bg = "purple",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "h", row = 18, atlas = "Professions-Icon-Quality-Tier1", tooltip = { title = "Spark + Myth Crest Crafted R1" } }),
        Cell({ col = "h", row = 19, atlas = "Professions-Icon-Quality-Tier2", tooltip = { title = "Spark + Myth Crest Crafted R2" } }),
        Cell({ col = "h", row = 20, atlas = "Professions-Icon-Quality-Tier3", tooltip = { title = "Spark + Myth Crest Crafted R3" } }),
        Cell({ col = "h", row = 21, atlas = "Professions-Icon-Quality-Tier4", tooltip = { title = "Spark + Myth Crest Crafted R4" } }),
        Cell({ col = "h", row = 22, atlas = "Professions-Icon-Quality-Tier5", tooltip = { title = "Spark + Myth Crest Crafted R5" } }),
        MergedCell({ col = "i", row = 19, toRow = 22, text = "80 Myth", vertical = true }),
        Cell({ col = "h", row = 25, text = "+10", tooltip = { title = "Voidforged Crafted Item" } }),
        Cell({ col = "i", row = 25, text = "VF", tooltip = { title = "Voidforged Crafted Item" } }),
    },
})

--------------------------------------------------------------------------------
--- Activity

-- Block({
--     id = "midnight.s1.activity.muted",
--     table = TABLE_ACTIVITY,
--     layer = LAYER,
--     bg = "muted",
--     border = "solid1",
--     innerColBorder = "solid1",
--     innerRowBorder = "dashed",
--     cells = {
--         Cell({ col = "e", row = 224, text = "N" }),
--     },
-- })

Block({
    id = "midnight.s1.activity.pink",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "a", row = 4, text = "N" }),
        Cell({ col = "b", row = 5, text = "1-3" }),
        Cell({ col = "b", row = 6, text = "4" }),
        Cell({ col = "e", row = 5, text = "H" }),
    },
})

Block({
    id = "midnight.s1.activity.blue",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "d", row = 6, text = "1-2" }),
        Cell({ col = "b", row = 7, text = "5" }),
        Cell({ col = "c", row = 7, text = "4" }),
        Cell({ col = "d", row = 7, text = "3" }),
        Cell({ col = "a", row = 8, text = "H" }),
        Cell({ col = "b", row = 8, text = "6" }),
        Cell({ col = "b", row = 9, text = "7" }),
        Cell({ col = "c", row = 9, text = "5" }),
        Cell({ col = "f", row = 9, text = "H" }),
        Cell({ col = "b", row = 10, text = "8+" }),
    },
})

Block({
    id = "midnight.s1.activity.yellow",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "a", row = 10, text = "NM" }),
        Cell({ col = "d", row = 10, text = "4" }),
        Cell({ col = "e", row = 10, text = "M" }),
        Cell({ col = "c", row = 11, text = "6" }),
        Cell({ col = "e", row = 11, text = "2-3" }),
        Cell({ col = "d", row = 12, text = "5" }),
        Cell({ col = "e", row = 12, text = "4" }),
        Cell({ col = "c", row = 13, text = "7" }),
        Cell({ col = "d", row = 13, text = "6" }),
        Cell({ col = "e", row = 13, text = "5" }),
        Cell({ col = "f", row = 13, text = "M" }),
        Cell({ col = "d", row = 14, text = "7" }),
    },
})

Block({
    id = "midnight.s1.activity.red",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "a", row = 14, text = "NM¹" }),
        Cell({ col = "b", row = 14, text = "8+¹" }),
        Cell({ col = "c", row = 14, text = "8+" }),
        Cell({ col = "d", row = 16, text = "8+" }),
        Cell({ col = "e", row = 14, text = "6-7" }),
        Cell({ col = "e", row = 15, text = "8-9" }),
        Cell({ col = "e", row = 16, text = "10+" }),
        Cell({ col = "f", row = 14, text = "2-3" }),
        Cell({ col = "f", row = 15, text = "4-5" }),
        Cell({ col = "f", row = 16, text = "6" }),
        Cell({ col = "f", row = 17, text = "7-9" }),
    },
})

Block({
    id = "midnight.s1.activity.purple",
    table = TABLE_ACTIVITY,
    layer = LAYER,
    bg = "purple",
    border = "solid1",
    innerColBorder = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "f", row = 18, text = "10+" }),
    },
})


--------------------------------------------------------------------------------
--- Dungeon

Block({
    id = "midnight.s1.dungeon.levels",
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
    id = "midnight.s1.dungeon.section",
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
    id = "midnight.s1.dungeon.normal",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "muted",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 2, text = "214" }),
        Cell({ col = "c", row = 2, text = "-" }),
    },
})

Block({
    id = "midnight.s1.dungeon.heroic",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "blue",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 3, text = "230", bg = "pink" }),
        Cell({ col = "c", row = 3, text = "4/6", bg = "pink" }),
        Cell({ col = "d", row = 3, text = "246"}),
        Cell({ col = "e", row = 3, text = "4/6"}),
        Cell({ col = "f", row = 3, text = "10 V"}),
    },
})

Block({
    id = "midnight.s1.dungeon.yellow",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "yellow",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 4, text = "246" }),
        Cell({ col = "b", row = 5, text = "250" }),
        Cell({ col = "b", row = 6, text = "250" }),
        Cell({ col = "b", row = 7, text = "253" }),
        Cell({ col = "b", row = 8, text = "256" }),

        Cell({ col = "c", row = 4, text = "1/6" }),
        Cell({ col = "c", row = 6, text = "2/6" }),
        Cell({ col = "c", row = 5, text = "2/6" }),
        Cell({ col = "c", row = 7, text = "3/6" }),
        Cell({ col = "c", row = 8, text = "4/6" }),

        Cell({ col = "d", row = 4, text = "256" }),

        Cell({ col = "e", row = 4, text = "4/6" }),

        Cell({ col = "f", row = 4, text = "10 C" }),
        Cell({ col = "f", row = 5, text = "12 C" }),
        Cell({ col = "f", row = 6, text = "14 C" }),

    },
})

Block({
    id = "midnight.s1.dungeon.red",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "red",
    border = "solid1",
    cells = {
        Cell({ col = "b", row = 9, text = "259" }),
        Cell({ col = "b", row = 10, text = "259" }),
        Cell({ col = "b", row = 11, text = "263" }),
        Cell({ col = "b", row = 12, text = "263" }),
        Cell({ col = "b", row = 13, text = "266" }),
        Cell({ col = "b", row = 14, text = "266" }),
        Cell({ col = "b", row = 15, text = "266" }),

        Cell({ col = "c", row = 9, text = "1/6" }),
        Cell({ col = "c", row = 10, text = "1/6" }),
        Cell({ col = "c", row = 11, text = "2/6" }),
        Cell({ col = "c", row = 12, text = "2/6" }),
        Cell({ col = "c", row = 13, text = "3/6" }),
        Cell({ col = "c", row = 14, text = "3/6" }),
        Cell({ col = "c", row = 15, text = "3/6" }),

        Cell({ col = "d", row = 5, text = "259" }),
        Cell({ col = "d", row = 6, text = "259" }),
        Cell({ col = "d", row = 7, text = "263" }),
        Cell({ col = "d", row = 8, text = "263" }),
        Cell({ col = "d", row = 9, text = "266" }),
        Cell({ col = "d", row = 10, text = "269" }),
        Cell({ col = "d", row = 11, text = "269" }),
        Cell({ col = "d", row = 12, text = "269" }),

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
    id = "midnight.s1.dungeon.purple",
    table = TABLE_DUNGEON,
    layer = LAYER,
    innerRowBorder = "dashed",
    bg = "purple",
    border = "solid1",
    cells = {
        Cell({ col = "d", row = 13, text = "272" }),
        Cell({ col = "d", row = 14, text = "272" }),
        Cell({ col = "d", row = 15, text = "272" }),

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
    id = "midnight.s1.delve.levels",
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
    id = "midnight.s1.delve.section",
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
    id = "midnight.s1.delve.pink",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "pink",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "b", row = 2, text = "220" }),
        Cell({ col = "c", row = 2, text = "1/6" }),
        Cell({ col = "b", row = 3, text = "224" }),
        Cell({ col = "c", row = 3, text = "2/6" }),
        Cell({ col = "b", row = 4, text = "227" }),
        Cell({ col = "c", row = 4, text = "3/6" }),
        Cell({ col = "b", row = 5, text = "230" }),
        Cell({ col = "c", row = 5, text = "4/6" }),
        Cell({ col = "f", row = 5, text = "A" }),
    },
})

Block({
    id = "midnight.s1.delve.blue",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "blue",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "d", row = 2, text = "233" }),
        Cell({ col = "e", row = 2, text = "1/6" }),
        Cell({ col = "d", row = 3, text = "237" }),
        Cell({ col = "e", row = 3, text = "2/6" }),
        Cell({ col = "d", row = 4, text = "240" }),
        Cell({ col = "e", row = 4, text = "3/6" }),
        Cell({ col = "d", row = 5, text = "243" }),
        Cell({ col = "e", row = 5, text = "4/6" }),
        Cell({ col = "b", row = 6, text = "233" }),
        Cell({ col = "c", row = 6, text = "1/6" }),
        Cell({ col = "f", row = 6, text = "V" }),
        Cell({ col = "b", row = 7, text = "237" }),
        Cell({ col = "c", row = 7, text = "2/6" }),
        Cell({ col = "f", row = 7, text = "V" }),
    },
})

Block({
    id = "midnight.s1.delve.yellow",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "yellow",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "d", row = 6, text = "246" }),
        Cell({ col = "e", row = 6, text = "1/6" }),
        Cell({ col = "d", row = 7, text = "253" }),
        Cell({ col = "e", row = 7, text = "3/6" }),
        Cell({ col = "b", row = 8, text = "246" }),
        Cell({ col = "c", row = 8, text = "2/6" }),
        Cell({ col = "d", row = 8, text = "256" }),
        Cell({ col = "e", row = 8, text = "4/6" }),
        Cell({ col = "f", row = 8, text = "C" }),
        Cell({ col = "b", row = 9, text = "246" }),
        Cell({ col = "c", row = 9, text = "2/6" }),
        Cell({ col = "f", row = 9, text = "C" }),
        Cell({ col = "b", row = 10, text = "246" }),
        Cell({ col = "c", row = 10, text = "2/6" }),
        Cell({ col = "f", row = 10, text = "C" }),
        Cell({ col = "b", row = 11, text = "246" }),
        Cell({ col = "c", row = 11, text = "2/6" }),
        Cell({ col = "f", row = 11, text = "C" }),
        Cell({ col = "b", row = 12, text = "246" }),
        Cell({ col = "c", row = 12, text = "2/6" }),
    },
})

Block({
    id = "midnight.s1.delve.red",
    table = TABLE_DELVE,
    layer = LAYER,
    bg = "red",
    border = "solid1",
    innerRowBorder = "dashed",
    cells = {
        Cell({ col = "d", row = 9, text = "259" }),
        Cell({ col = "e", row = 9, text = "1/6" }),
        Cell({ col = "d", row = 10, text = "259" }),
        Cell({ col = "e", row = 10, text = "1/6" }),
        Cell({ col = "d", row = 11, text = "259" }),
        Cell({ col = "e", row = 11, text = "1/6" }),
        Cell({ col = "d", row = 12, text = "259" }),
        Cell({ col = "e", row = 12, text = "1/6" }),
        Cell({ col = "f", row = 12, text = "H" }),
    },
})
