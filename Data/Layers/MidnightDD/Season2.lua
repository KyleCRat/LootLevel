local ADDON_NAME, NS = ...

local WEEKLY = "\194\185"

-- Track curves and observed rewards come from COLLECTOR_PLAN.md / export_271092.log.
-- Other source-to-rank mappings remain inherited assumptions, not collector observations.
NS.Progression.Season({
    key = NS.Data.LayerKeys.MIDNIGHT_DD_S2,
    layerSet = "midnightDD",
    name = "Midnight DD Season 2",
    buttonText = "Season 2",
    buttonWidth = 74,
    order = 20,
    inactiveAlpha = 0.2,
    scrollTo = 266,
    footer = {
        left = "Midnight DD - Season 2 (12.1.0) - by Yvairel <Party Shark> <Suds with Buds>",
        right = WEEKLY .. " Once a Week | VF: Venomforged | GV: Great Vault",
    },

    tracks = {
        adventurer = { levels = { 266, 269, 272, 276, 279, 282 } },
        veteran = { levels = { 279, 282, 285, 289, 292, 295 } },
        champion = { levels = { 292, 295, 298, 302, 305, 308 } },
        hero = {
            levels = { 305, 308, 311, 315, 318, 321 },
            -- Venomforging unlocks 8/6 later in the season, outside ordinary upgrades.
            extraRanks = { { ilvl = 328, rank = 8 } },
        },
        myth = {
            levels = { 318, 321, 324, 328, 331, 334 },
            -- 9/6 is a journal-observed reward, not another ordinary vendor upgrade.
            extraRanks = {
                { ilvl = 337, rank = 7, tooltip = { title = "Myth 7/6 Crafted Equivalent", description = "Venomforged crafted gear: one upgrade rank below obtained Myth 8/6 gear, not a vendor upgrade." } },
                { ilvl = 340, rank = 8 },
                { ilvl = 344, rank = 9 },
            },
            labelThrough = 344,
        },
    },

    raids = {
        {
            difficulty = "LFR", track = "veteran", drops = { 279, 282, 285, 289 },
            tooltip = { title = "LFR Raid Drops", description = "Journal-observed Veteran ranks 1-4/6." },
            rewards = {
                -- { kind = "rare", ilvl = 295, tooltip = { title = "Very Rare LFR raid drops" } },
                { kind = "vault", track = "champion", ilvl = 292, tooltip = { title = "LFR Great Vault Reward", description = "Champion 1/6. Normal raid drops also begin at this item level." } },
            },
        },
        {
            difficulty = "Normal", track = "champion", drops = { 292, 295, 298, 302 },
            tooltip = { title = "Normal Raid Drops", description = "Journal-observed Champion ranks 1-4/6." },
            rewards = {
                -- { kind = "rare", ilvl = 308, tooltip = { title = "Very Rare Normal raid drops" } },
                { kind = "vault", track = "hero", ilvl = 305, tooltip = { title = "Normal Great Vault Reward", description = "Hero 1/6. Heroic raid drops also begin at this item level." } },
            },
        },
        {
            difficulty = "Heroic", track = "hero", drops = { 305, 308, 311, 315 },
            tooltip = { title = "Heroic Raid Drops", description = "Journal-observed Hero ranks 1-4/6." },
            rewards = {
                -- { kind = "rare", ilvl = 321, tooltip = { title = "Very Rare Heroic raid drops" } },
                { kind = "vault", track = "myth", ilvl = 318, tooltip = { title = "Heroic Great Vault Reward", description = "Observed in a current-character raid Vault preview.\nMyth 1/6. Mythic raid drops also begin at this item level." } },
                { kind = "forged", ilvl = 328, tooltip = { title = "Heroic Venomforged Item", description = "Hero 8/6, available later this season via Venomforging." } },
            },
        },
        {
            difficulty = "Mythic", track = "myth", drops = { 318, 321, 324 },
            tooltip = { title = "Mythic Raid Drops", description = "Journal-observed Myth ranks 1-3/6." },
            rewards = {
                { kind = "forged", ilvl = 340, tooltip = { title = "Mythic Venomforged Item", description = "Myth 8/6, available later this season via Venomforging." } },
                -- Myth has no higher track; raid and Vault rewards share this cell.
                { kind = "vault", track = "myth", ilvl = 344, label = "GV", tooltip = { title = "Great Vault Reward", description = "344 Myth 9/6 observed in the raid journal and current-character Vault previews." } },
            },
            lastBosses = { ilvl = 344, label = "Last 2", tooltip = { title = "Last 2 Mythic raid drops" } },
        },
    },

    -- Quality/reagent mappings are retained from the manual data; crafting is not collector-verified.
    crafting = {
        {
            track = "adventurer", levels = { 266, 269, 272, 276, 279 }, tooltip = "Adventurer Crest Crafted",
            reagent = { label = "30 Adv.", from = 266, to = 276 },
        },
        {
            track = "veteran", levels = { 279, 282, 285, 289, 292 }, tooltip = "Veteran Crest Crafted",
            reagent = { label = "30 Vet.", from = 282, to = 289 },
        },
        {
            track = "champion", levels = { 292, 295, 298, 302, 305 }, tooltip = "Spark Crest Crafted",
            reagent = { label = "Spark", from = 295, to = 302 },
        },
        {
            track = "hero", levels = { 305, 308, 311, 315, 318 }, tooltip = "Spark + Hero Crest Crafted",
            reagent = { label = "80 Hero", from = 308, to = 315 },
        },
        {
            track = "myth", levels = { 318, 321, 324, 328, 331 }, tooltip = "Spark + Myth Crest Crafted",
            reagent = { label = "80 Myth", from = 321, to = 331 },
            forged = { ilvl = 337, tooltip = { title = "Venomforged Crafted Item", description = "Myth 7/6 equivalent, one upgrade rank below obtained Myth 8/6 gear.\nAvailable later this season via Venomforging." } },
        },
    },

    activities = {
        prey = {
            { ilvl = 272, track = "adventurer", label = "N" },
            { ilvl = 289, track = "veteran", label = "H" },
            { ilvl = 292, track = "champion", label = "NM" },
            { ilvl = 305, track = "hero", label = "NM" .. WEEKLY },
        },
        delve = {
            { ilvl = 266, track = "adventurer", label = "1" },
            { ilvl = 269, track = "adventurer", label = "2" },
            { ilvl = 272, track = "adventurer", label = "3" },
            { ilvl = 276, track = "adventurer", label = "4" },
            { ilvl = 279, track = "veteran", label = "5" },
            { ilvl = 282, track = "veteran", label = "6" },
            { ilvl = 295, track = "champion", label = "7+" },
            { ilvl = 305, track = "hero", label = "8+" .. WEEKLY },
        },
        map = {
            { ilvl = 282, track = "veteran", label = "4" },
            { ilvl = 289, track = "veteran", label = "5" },
            { ilvl = 295, track = "champion", label = "6" },
            { ilvl = 302, track = "champion", label = "7" },
            { ilvl = 305, track = "hero", label = "8+" },
        },
        delveVault = {
            { ilvl = 279, track = "veteran", label = "1" },
            { ilvl = 282, track = "veteran", label = "2" },
            { ilvl = 285, track = "veteran", label = "3" },
            { ilvl = 289, track = "veteran", label = "4" },
            { ilvl = 292, track = "champion", label = "5" },
            { ilvl = 298, track = "champion", label = "6" },
            { ilvl = 302, track = "champion", label = "7" },
            { ilvl = 305, track = "hero", label = "8+", tooltip = { title = "World Great Vault Tier 8", description = "Preyhunter's Signet observed at item level 305." } },
        },
        dungeon = {
            { ilvl = 259, track = "untracked", label = "N" },
            { ilvl = 276, track = "adventurer", label = "H" },
            { ilvl = 292, track = "champion", label = "M" },
            { ilvl = 295, track = "champion", label = "2-3" },
            { ilvl = 298, track = "champion", label = "4" },
            { ilvl = 302, track = "champion", label = "5" },
            { ilvl = 305, track = "hero", label = "6-7" },
            { ilvl = 308, track = "hero", label = "8-9" },
            { ilvl = 311, track = "hero", label = "10+" },
        },
        dungeonVault = {
            { ilvl = 289, track = "veteran", label = "H" },
            { ilvl = 302, track = "champion", label = "M" },
            { ilvl = 305, track = "hero", label = "2-3" },
            { ilvl = 308, track = "hero", label = "4-5" },
            { ilvl = 311, track = "hero", label = "6" },
            { ilvl = 315, track = "hero", label = "7-9" },
            { ilvl = 318, track = "myth", label = "10+" },
        },
    },

    -- Normal/Heroic loot and +4 through +12 Vault values have observed anchors.
    -- Other reward ranks and crest amounts retain the existing source mappings.
    dungeon = {
        { label = "N", loot = { ilvl = 259, track = "untracked", tooltip = { title = "Normal Dungeon Loot", description = "Polished Lightwood Channeler observed at 259 with no upgrade track." } } },
        { label = "H", loot = { ilvl = 276, track = "adventurer" }, vault = { ilvl = 289, track = "veteran" }, crest = { track = "veteran", amount = 10 } },
        { label = "M", loot = { ilvl = 292, track = "champion" }, vault = { ilvl = 302, track = "champion" }, crest = { track = "champion", amount = 10 } },
        { label = "+2", loot = { ilvl = 295, track = "champion" }, vault = { ilvl = 305, track = "hero" }, crest = { track = "champion", amount = 12 } },
        { label = "+3", loot = { ilvl = 295, track = "champion" }, vault = { ilvl = 305, track = "hero" }, crest = { track = "champion", amount = 14 } },
        { label = "+4", loot = { ilvl = 298, track = "champion" }, vault = { ilvl = 308, track = "hero" }, crest = { track = "hero", amount = 10 } },
        { label = "+5", loot = { ilvl = 302, track = "champion" }, vault = { ilvl = 308, track = "hero" }, crest = { track = "hero", amount = 12 } },
        { label = "+6", loot = { ilvl = 305, track = "hero" }, vault = { ilvl = 311, track = "hero" }, crest = { track = "hero", amount = 14 } },
        { label = "+7", loot = { ilvl = 305, track = "hero" }, vault = { ilvl = 315, track = "hero" }, crest = { track = "hero", amount = 16 } },
        { label = "+8", loot = { ilvl = 308, track = "hero" }, vault = { ilvl = 315, track = "hero" }, crest = { track = "hero", amount = 18 } },
        { label = "+9", loot = { ilvl = 308, track = "hero" }, vault = { ilvl = 315, track = "hero" }, crest = { track = "myth", amount = 10 } },
        { label = "+10", loot = { ilvl = 311, track = "hero" }, vault = { ilvl = 318, track = "myth" }, crest = { track = "myth", amount = 12 } },
        { label = "+11", loot = { ilvl = 311, track = "hero" }, vault = { ilvl = 318, track = "myth" }, crest = { track = "myth", amount = 12 } },
        { label = "+12", loot = { ilvl = 311, track = "hero" }, vault = { ilvl = 318, track = "myth" }, crest = { track = "myth", amount = 12 } },
    },

    -- Tier 8 world Vault ilvl 305 is observed. Remaining tiers retain inherited ranks.
    delve = {
        { level = 1, loot = { ilvl = 266, track = "adventurer" }, vault = { ilvl = 279, track = "veteran" } },
        { level = 2, loot = { ilvl = 269, track = "adventurer" }, vault = { ilvl = 282, track = "veteran" } },
        { level = 3, loot = { ilvl = 272, track = "adventurer" }, vault = { ilvl = 285, track = "veteran" } },
        { level = 4, loot = { ilvl = 276, track = "adventurer" }, vault = { ilvl = 289, track = "veteran" }, crest = { track = "adventurer" } },
        { level = 5, loot = { ilvl = 279, track = "veteran" }, vault = { ilvl = 292, track = "champion" }, crest = { track = "veteran" } },
        { level = 6, loot = { ilvl = 282, track = "veteran" }, vault = { ilvl = 298, track = "champion" }, crest = { track = "veteran" } },
        { level = 7, loot = { ilvl = 295, track = "champion" }, vault = { ilvl = 302, track = "champion" }, crest = { track = "champion" } },
        { level = 8, loot = { ilvl = 295, track = "champion" }, vault = { ilvl = 305, track = "hero" }, crest = { track = "champion" } },
        { level = 9, loot = { ilvl = 295, track = "champion" }, vault = { ilvl = 305, track = "hero" }, crest = { track = "champion" } },
        { level = 10, loot = { ilvl = 295, track = "champion" }, vault = { ilvl = 305, track = "hero" }, crest = { track = "champion" } },
        { level = 11, loot = { ilvl = 295, track = "champion" }, vault = { ilvl = 305, track = "hero" }, crest = { track = "hero" } },
    },
})
