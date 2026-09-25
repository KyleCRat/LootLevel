local ADDON_NAME, NS = ...

local WEEKLY = "\194\185"

NS.Progression.Season({
    key = NS.Data.LayerKeys.MIDNIGHT_DD_S1,
    layerSet = "midnightDD",
    name = "Midnight DD Season 1",
    buttonText = "Season 1",
    buttonWidth = 74,
    order = 10,
    inactiveAlpha = 0.2,
    scrollTo = 220,
    footer = {
        left = "Midnight DD - Season 1 (12.0.0) - by Yvairel <Party Shark> <Suds with Buds>",
        right = WEEKLY .. " Once a Week | VF: Voidforged | SF: Sporefall | GV: Great Vault",
    },

    -- Ordered item levels define ranks. Extra ranks do not extend the normal track label.
    tracks = {
        adventurer = { levels = { 220, 224, 227, 230, 233, 237 } },
        veteran = { levels = { 233, 237, 240, 243, 246, 250 } },
        champion = { levels = { 246, 250, 253, 256, 259, 263 } },
        hero = { levels = { 259, 263, 266, 269, 272, 276 }, extraRanks = { { ilvl = 285, rank = 8 } } },
        myth = {
            levels = { 272, 276, 279, 282, 285, 289 },
            extraRanks = { { ilvl = 298, rank = 9 } },
            markers = { { ilvl = 298, label = "VF", tooltip = { title = "Mythic Voidforged Item" } } },
        },
    },

    raids = {
        {
            difficulty = "LFR", track = "veteran", drops = { 237, 240, 243 },
            tooltip = { title = "LFR Raid Drops from first 6 Bosses" },
            rewards = {
                { kind = "rare", ilvl = 250, tooltip = { title = "Very Rare LFR raid drops" } },
                { kind = "sporefall", track = "champion", ilvl = 246, tooltip = { title = "LFR Sporefall Item Drop" } },
            },
        },
        {
            difficulty = "Normal", track = "champion", drops = { 250, 253, 256 },
            tooltip = { title = "Normal Raid Drops from first 6 Bosses" },
            rewards = {
                { kind = "rare", ilvl = 263, tooltip = { title = "Very Rare Normal raid drops" } },
                { kind = "sporefall", track = "hero", ilvl = 259, tooltip = { title = "Normal Sporefall Item Drop" } },
            },
        },
        {
            difficulty = "Heroic", track = "hero", drops = { 263, 266, 269 },
            tooltip = { title = "Heroic Raid Drops from first 6 Bosses" },
            rewards = {
                { kind = "rare", ilvl = 276, tooltip = { title = "Very Rare Heroic raid drops" } },
                { kind = "forged", ilvl = 285, tooltip = { title = "Heroic Voidforged Item" } },
                { kind = "sporefall", track = "myth", ilvl = 272, tooltip = { title = "Heroic Sporefall Item Drop" } },
            },
        },
        {
            difficulty = "Mythic", track = "myth", drops = { 276, 279, 282 },
            tooltip = { title = "Mythic Raid Drops" },
            rewards = {
                { kind = "rare", ilvl = 289, tooltip = { title = "Very Rare Mythic Raid Drops" } },
                { kind = "sporefall", track = "myth", ilvl = 298, tooltip = { title = "Mythic Sporefall Item" } },
            },
        },
    },

    -- Quality icons follow the order of levels. Reagents span item levels, not rows.
    crafting = {
        {
            track = "adventurer", levels = { 220, 224, 227, 230, 233 }, tooltip = "Adventurer Crest Crafted",
            reagent = { label = "30 Adv.", from = 220, to = 230 },
        },
        {
            track = "veteran", levels = { 233, 237, 240, 243, 246 }, tooltip = "Veteran Crest Crafted",
            reagent = { label = "30 Vet.", from = 237, to = 243 },
        },
        {
            track = "champion", levels = { 246, 250, 253, 256, 259 }, tooltip = "Spark Crest Crafted",
            reagent = { label = "Spark", from = 250, to = 256 },
        },
        {
            track = "hero", levels = { 259, 263, 266, 269, 272 }, tooltip = "Spark + Hero Crest Crafted",
            reagent = { label = "80 Hero", from = 263, to = 269 },
        },
        {
            track = "myth", levels = { 272, 276, 279, 282, 285 }, tooltip = "Spark + Myth Crest Crafted",
            reagent = { label = "80 Myth", from = 276, to = 285 },
            forged = { ilvl = 295, bonus = 10, tooltip = { title = "Voidforged Crafted Item" } },
        },
    },

    activities = {
        prey = {
            { ilvl = 227, track = "adventurer", label = "N" },
            { ilvl = 240, track = "veteran", label = "H" },
            { ilvl = 246, track = "champion", label = "NM" },
            { ilvl = 259, track = "hero", label = "NM" .. WEEKLY },
        },
        delve = {
            { ilvl = 230, track = "adventurer", label = "1-3" },
            { ilvl = 233, track = "adventurer", label = "4" },
            { ilvl = 237, track = "veteran", label = "5" },
            { ilvl = 240, track = "veteran", label = "6" },
            { ilvl = 243, track = "veteran", label = "7" },
            { ilvl = 246, track = "veteran", label = "8+" },
            { ilvl = 259, track = "hero", label = "8+" .. WEEKLY },
        },
        map = {
            { ilvl = 237, track = "veteran", label = "4" },
            { ilvl = 243, track = "veteran", label = "5" },
            { ilvl = 250, track = "champion", label = "6" },
            { ilvl = 256, track = "champion", label = "7" },
            { ilvl = 259, track = "hero", label = "8+" },
        },
        delveVault = {
            { ilvl = 233, track = "veteran", label = "1-2" },
            { ilvl = 237, track = "veteran", label = "3" },
            { ilvl = 246, track = "champion", label = "4" },
            { ilvl = 253, track = "champion", label = "5" },
            { ilvl = 256, track = "champion", label = "6" },
            { ilvl = 259, track = "champion", label = "7" },
            { ilvl = 266, track = "hero", label = "8+" },
        },
        dungeon = {
            { ilvl = 230, track = "adventurer", label = "H" },
            { ilvl = 246, track = "champion", label = "M" },
            { ilvl = 250, track = "champion", label = "2-3" },
            { ilvl = 253, track = "champion", label = "4" },
            { ilvl = 256, track = "champion", label = "5" },
            { ilvl = 259, track = "hero", label = "6-7" },
            { ilvl = 263, track = "hero", label = "8-9" },
            { ilvl = 266, track = "hero", label = "10+" },
        },
        dungeonVault = {
            { ilvl = 243, track = "veteran", label = "H" },
            { ilvl = 256, track = "champion", label = "M" },
            { ilvl = 259, track = "hero", label = "2-3" },
            { ilvl = 263, track = "hero", label = "4-5" },
            { ilvl = 266, track = "hero", label = "6" },
            { ilvl = 269, track = "hero", label = "7-9" },
            { ilvl = 272, track = "myth", label = "10+" },
        },
    },

    -- Ranks are inferred from track + ilvl. Explicit ranks preserve exceptions in the manual tables.
    dungeon = {
        { label = "N", loot = { ilvl = 214, track = "untracked" } },
        { label = "H", loot = { ilvl = 230, track = "adventurer" }, vault = { ilvl = 246, track = "veteran", rank = 4 }, crest = { track = "veteran", amount = 10 } },
        { label = "M", loot = { ilvl = 246, track = "champion" }, vault = { ilvl = 256, track = "champion" }, crest = { track = "champion", amount = 10 } },
        { label = "+2", loot = { ilvl = 250, track = "champion" }, vault = { ilvl = 259, track = "hero" }, crest = { track = "champion", amount = 12 } },
        { label = "+3", loot = { ilvl = 250, track = "champion" }, vault = { ilvl = 259, track = "hero" }, crest = { track = "champion", amount = 14 } },
        { label = "+4", loot = { ilvl = 253, track = "champion" }, vault = { ilvl = 263, track = "hero" }, crest = { track = "hero", amount = 10 } },
        { label = "+5", loot = { ilvl = 256, track = "champion" }, vault = { ilvl = 263, track = "hero" }, crest = { track = "hero", amount = 12 } },
        { label = "+6", loot = { ilvl = 259, track = "hero" }, vault = { ilvl = 266, track = "hero" }, crest = { track = "hero", amount = 14 } },
        { label = "+7", loot = { ilvl = 259, track = "hero" }, vault = { ilvl = 269, track = "hero" }, crest = { track = "hero", amount = 16 } },
        { label = "+8", loot = { ilvl = 263, track = "hero" }, vault = { ilvl = 269, track = "hero" }, crest = { track = "hero", amount = 18 } },
        { label = "+9", loot = { ilvl = 263, track = "hero" }, vault = { ilvl = 269, track = "hero" }, crest = { track = "myth", amount = 10 } },
        { label = "+10", loot = { ilvl = 266, track = "hero" }, vault = { ilvl = 272, track = "myth" }, crest = { track = "myth", amount = 12 } },
        { label = "+11", loot = { ilvl = 266, track = "hero" }, vault = { ilvl = 272, track = "myth" }, crest = { track = "myth", amount = 12 } },
        { label = "+12", loot = { ilvl = 266, track = "hero" }, vault = { ilvl = 272, track = "myth" }, crest = { track = "myth", amount = 12 } },
    },

    delve = {
        { level = 1, loot = { ilvl = 220, track = "adventurer" }, vault = { ilvl = 233, track = "veteran" } },
        { level = 2, loot = { ilvl = 224, track = "adventurer" }, vault = { ilvl = 237, track = "veteran" } },
        { level = 3, loot = { ilvl = 227, track = "adventurer" }, vault = { ilvl = 240, track = "veteran" } },
        { level = 4, loot = { ilvl = 230, track = "adventurer" }, vault = { ilvl = 243, track = "veteran" }, crest = { track = "adventurer" } },
        { level = 5, loot = { ilvl = 233, track = "veteran" }, vault = { ilvl = 246, track = "champion" }, crest = { track = "veteran" } },
        { level = 6, loot = { ilvl = 237, track = "veteran" }, vault = { ilvl = 253, track = "champion" }, crest = { track = "veteran" } },
        { level = 7, loot = { ilvl = 246, track = "champion", rank = 2 }, vault = { ilvl = 256, track = "champion" }, crest = { track = "champion" } },
        { level = 8, loot = { ilvl = 246, track = "champion", rank = 2 }, vault = { ilvl = 259, track = "hero" }, crest = { track = "champion" } },
        { level = 9, loot = { ilvl = 246, track = "champion", rank = 2 }, vault = { ilvl = 259, track = "hero" }, crest = { track = "champion" } },
        { level = 10, loot = { ilvl = 246, track = "champion", rank = 2 }, vault = { ilvl = 259, track = "hero" }, crest = { track = "champion" } },
        { level = 11, loot = { ilvl = 246, track = "champion", rank = 2 }, vault = { ilvl = 259, track = "hero" }, crest = { track = "hero" } },
    },
})
