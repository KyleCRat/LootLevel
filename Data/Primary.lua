local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawBorderRule = Data.BorderRule

local TABLE_KEY = "primary"

local function Block(definition)
    definition.tableKey = definition.tableKey or TABLE_KEY
    return RawBlock(definition)
end

local function BorderRule(definition)
    definition.tableKey = definition.tableKey or TABLE_KEY
    return RawBorderRule(definition)
end

Table({
    tableKey = TABLE_KEY,
    displayName = "Primary item level table",
    positionX = 354,
    positionY = 0,
    columns = {
        { columnKey = "a", width = 46, columnTitle = "Item level", defaultColorKey = "light", isBold = true, defaultTextValueKey = "itemLevel", defaultTooltipTitleTemplate = "Item level %s" },
        { columnKey = "b", width = 40, columnTitle = "Raid Difficulty / Track", defaultTooltipTitleTemplate = "Raid / track at item level %s" },
        { columnKey = "c", width = 40, columnTitle = "Raid Difficulty / Track", defaultTooltipTitleTemplate = "Raid / track at item level %s" },
        { columnKey = "d", width = 40, columnTitle = "Raid Difficulty / Track", defaultTooltipTitleTemplate = "Raid / track at item level %s" },
        { columnKey = "e", width = 40, columnTitle = "Raid Difficulty / Track", defaultTooltipTitleTemplate = "Raid / track at item level %s" },
        { columnKey = "f", width = 40, columnTitle = "Raid Difficulty / Track", defaultTooltipTitleTemplate = "Raid / track at item level %s" },
        { columnKey = "g", width = 40, columnTitle = "Raid Difficulty / Track", defaultTooltipTitleTemplate = "Raid / track at item level %s" },
        { columnKey = "h", width = 43, columnTitle = "Craft", defaultTooltipTitleTemplate = "Crafting at item level %s" },
        { columnKey = "i", width = 43, columnTitle = "Craft", defaultTooltipTitleTemplate = "Crafting at item level %s" },
        { columnKey = "j", width = 62, columnTitle = "Prey", defaultTooltipTitleTemplate = "Prey at item level %s" },
        { columnKey = "k", width = 62, columnTitle = "Delve", defaultTooltipTitleTemplate = "Delve at item level %s" },
        { columnKey = "l", width = 62, columnTitle = "Map", defaultTooltipTitleTemplate = "Map at item level %s" },
        { columnKey = "m", width = 62, columnTitle = "Great Vault", defaultTooltipTitleTemplate = "Great Vault at item level %s" },
        { columnKey = "n", width = 62, columnTitle = "Dungeon", defaultTooltipTitleTemplate = "Dungeon at item level %s" },
        { columnKey = "o", width = 62, columnTitle = "Dungeon Great Vault", defaultTooltipTitleTemplate = "Dungeon Great Vault at item level %s" },
        { columnKey = "p", width = 46, columnTitle = "Item level", defaultColorKey = "light", isBold = true, defaultTextValueKey = "itemLevel", defaultTooltipTitleTemplate = "Item level %s" },
    },
    headers = {
        { startColumnKey = "a", endColumnKey = "a", displayText = "ilvl", cellCoordinate = "a1" },
        { startColumnKey = "b", endColumnKey = "g", displayText = "Raid Difficulty / Track", cellCoordinate = "b1" },
        { startColumnKey = "h", endColumnKey = "i", displayText = "Craft", cellCoordinate = "h1" },
        { startColumnKey = "j", endColumnKey = "j", displayText = "Prey", cellCoordinate = "j1" },
        { startColumnKey = "k", endColumnKey = "k", displayText = "Delve", cellCoordinate = "k1" },
        { startColumnKey = "l", endColumnKey = "l", displayText = "Map", cellCoordinate = "l1" },
        { startColumnKey = "m", endColumnKey = "m", displayText = "GV", cellCoordinate = "m1" },
        { startColumnKey = "n", endColumnKey = "n", displayText = "Dung.", cellCoordinate = "n1" },
        { startColumnKey = "o", endColumnKey = "o", displayText = "GV", cellCoordinate = "o1" },
        { startColumnKey = "p", endColumnKey = "p", displayText = "ilvl", cellCoordinate = "p1" },
    },
    bodyRows = {
        rowSource = "itemLevels",
        firstRowIndex = 2,
    },
})

BorderRule({
    borderAxis = "horizontal",
    fromRow = 1,
    toRow = 1,
    appliesToEachCell = true,
    borderStyleKey = "solid3",
    priority = 100,
})

BorderRule({
    borderAxis = "horizontal",
    appliesToEachCell = true,
    borderStyleKey = "dashed",
    priority = 1,
})

local function PrimarySectionBorder(definition)
    BorderRule({
        borderAxis = "vertical",
        afterColumnKey = definition.afterColumnKey,
        fromRow = 1,
        toRow = #NS.Data.levels + 1,
        borderStyleKey = "solid3",
        priority = 70,
    })
end

PrimarySectionBorder({ afterColumnKey = "a" })
PrimarySectionBorder({ afterColumnKey = "g" })
PrimarySectionBorder({ afterColumnKey = "i" })
PrimarySectionBorder({ afterColumnKey = "j" })
PrimarySectionBorder({ afterColumnKey = "m" })
PrimarySectionBorder({ afterColumnKey = "o" })

Block({
    blockId = "raid.lfr",
    backgroundColorKey = "blue",
    outerBorderStyleKey = "solid1",
    innerBorderStyleKey = "dashed",
    metadata = { contentType = "raid", difficulty = "lfr" },
    cells = {
        Cell({ columnKey = "b", itemLevel = 272, displayText = "GV", tooltipTitle = "Champion Great Vault Reward", backgroundColorKey = "yellow", metadata = { valueType = "dropItemLevel" } }),
        MergedCell({ columnKey = "b", fromItemLevel = 276, toItemLevel = 282, displayText = "LFR", isTextVertical = true }),
        Cell({ columnKey = "b", itemLevel = 276, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 279, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 282, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "b", itemLevel = 289, tooltipTitle = "LFR raid drops", metadata = { valueType = "dropItemLevel" } }),
        Cell({ columnKey = "c", itemLevel = 272, displayText = "1/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 276, displayText = "2/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 279, displayText = "3/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 282, displayText = "4/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 285, displayText = "5/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        Cell({ columnKey = "c", itemLevel = 289, displayText = "6/6", tooltipTitle = "LFR upgrade rank", metadata = { valueType = "upgradeRank" } }),
        MergedCell({ columnKey = "d", fromItemLevel = 272, toItemLevel = 289, displayText = "Veteran", isTextVertical = true }),
    },
})

-- Block({
--     blockId = "raid.veteran",
--     backgroundColorKey = "blue",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "veteran" },
--     cells = {
--         Cell({ columnKey = "d", itemLevel = 272, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 276, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 279, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 282, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 285, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 289, tooltipTitle = "Veteran track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "e", itemLevel = 272, displayText = "1/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 276, displayText = "2/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 279, displayText = "3/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 282, displayText = "4/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 285, displayText = "5/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 289, displayText = "6/6", tooltipTitle = "Veteran upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "d", fromItemLevel = 272, toItemLevel = 289, displayText = "Veteran", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.adventurer",
--     backgroundColorKey = "pink",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "adventurer" },
--     cells = {
--         Cell({ columnKey = "f", itemLevel = 259, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 263, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 266, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 269, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 272, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 276, tooltipTitle = "Adventurer track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "g", itemLevel = 259, displayText = "1/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 263, displayText = "2/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 266, displayText = "3/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 269, displayText = "4/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 272, displayText = "5/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 276, displayText = "6/6", tooltipTitle = "Adventurer upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "f", fromItemLevel = 259, toItemLevel = 276, displayText = "Adventurer", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.normal",
--     backgroundColorKey = "yellow",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "raid", difficulty = "normal" },
--     cells = {
--         Cell({ columnKey = "b", itemLevel = 285, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 289, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 292, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 295, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 298, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 302, tooltipTitle = "Normal raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "c", itemLevel = 285, displayText = "1/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 289, displayText = "2/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 292, displayText = "3/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 295, displayText = "4/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 298, displayText = "5/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 302, displayText = "6/6", tooltipTitle = "Normal upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "b", fromItemLevel = 285, toItemLevel = 302, displayText = "Normal", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.champion",
--     backgroundColorKey = "yellow",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "champion" },
--     cells = {
--         Cell({ columnKey = "f", itemLevel = 285, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 289, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 292, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 295, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 298, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 302, tooltipTitle = "Champion track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "g", itemLevel = 285, displayText = "1/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 289, displayText = "2/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 292, displayText = "3/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 295, displayText = "4/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 298, displayText = "5/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 302, displayText = "6/6", tooltipTitle = "Champion upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "f", fromItemLevel = 285, toItemLevel = 302, displayText = "Champion", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.heroic",
--     backgroundColorKey = "red",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "raid", difficulty = "heroic" },
--     cells = {
--         Cell({ columnKey = "b", itemLevel = 298, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 302, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 305, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 308, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 311, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 315, tooltipTitle = "Heroic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "c", itemLevel = 298, displayText = "1/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 302, displayText = "2/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 305, displayText = "3/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 308, displayText = "4/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 311, displayText = "5/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 315, displayText = "6/6", tooltipTitle = "Heroic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "b", fromItemLevel = 298, toItemLevel = 315, displayText = "Heroic", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.hero",
--     backgroundColorKey = "red",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "hero" },
--     cells = {
--         Cell({ columnKey = "d", itemLevel = 298, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 302, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 305, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 308, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 311, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "d", itemLevel = 315, tooltipTitle = "Hero track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "e", itemLevel = 298, displayText = "1/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 302, displayText = "2/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 305, displayText = "3/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 308, displayText = "4/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 311, displayText = "5/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "e", itemLevel = 315, displayText = "6/6", tooltipTitle = "Hero upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "d", fromItemLevel = 298, toItemLevel = 315, displayText = "Hero", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.mythic",
--     backgroundColorKey = "purple",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "raid", difficulty = "mythic" },
--     cells = {
--         Cell({ columnKey = "b", itemLevel = 311, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 315, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 318, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 321, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 324, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 328, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 334, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "b", itemLevel = 337, tooltipTitle = "Mythic raid drops", metadata = { valueType = "dropItemLevel" } }),
--         Cell({ columnKey = "c", itemLevel = 311, displayText = "1/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 315, displayText = "2/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 318, displayText = "3/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 321, displayText = "4/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 324, displayText = "5/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 328, displayText = "6/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 334, displayText = "8/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "c", itemLevel = 337, displayText = "9/6", tooltipTitle = "Mythic upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "b", fromItemLevel = 311, toItemLevel = 337, displayText = "Mythic", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "raid.myth",
--     backgroundColorKey = "purple",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "upgradeTrack", track = "myth" },
--     cells = {
--         Cell({ columnKey = "f", itemLevel = 311, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 315, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 318, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 321, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 324, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 328, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 334, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "f", itemLevel = 337, tooltipTitle = "Myth track", metadata = { valueType = "itemLevel" } }),
--         Cell({ columnKey = "g", itemLevel = 311, displayText = "1/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 315, displayText = "2/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 318, displayText = "3/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 321, displayText = "4/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 324, displayText = "5/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 328, displayText = "6/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 334, displayText = "8/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         Cell({ columnKey = "g", itemLevel = 337, displayText = "9/6", tooltipTitle = "Myth upgrade rank", metadata = { valueType = "upgradeRank" } }),
--         MergedCell({ columnKey = "f", fromItemLevel = 311, toItemLevel = 337, displayText = "Myth", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "craft.adventurer",
--     backgroundColorKey = "pink",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "crafting", track = "adventurer" },
--     cells = {
--         Cell({ columnKey = "h", itemLevel = 259, displayText = "W", tooltipTitle = "Weathered crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 263, displayText = "C", tooltipTitle = "Carved crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 266, displayText = "R", tooltipTitle = "Runed crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 269, displayText = "G", tooltipTitle = "Gilded crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 272, displayText = "S", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "i", itemLevel = 259, tooltipTitle = "Weathered crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 263, tooltipTitle = "Carved crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 266, tooltipTitle = "Runed crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 269, tooltipTitle = "Gilded crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 272, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
--         MergedCell({ columnKey = "i", fromItemLevel = 259, toItemLevel = 272, displayText = "30 Adv.", isTextVertical = true, fontSize = 12 }),
--     },
-- })

-- Block({
--     blockId = "craft.veteran",
--     backgroundColorKey = "blue",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "crafting", track = "veteran" },
--     cells = {
--         Cell({ columnKey = "h", itemLevel = 276, displayText = "W", tooltipTitle = "Weathered crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 279, displayText = "C", tooltipTitle = "Carved crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 282, displayText = "R", tooltipTitle = "Runed crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 285, displayText = "S", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "i", itemLevel = 276, tooltipTitle = "Weathered crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 279, tooltipTitle = "Carved crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 282, tooltipTitle = "Runed crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 285, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
--         MergedCell({ columnKey = "i", fromItemLevel = 276, toItemLevel = 285, displayText = "30 Vet.", isTextVertical = true, fontSize = 12 }),
--     },
-- })

-- Block({
--     blockId = "craft.champion",
--     backgroundColorKey = "yellow",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "crafting", track = "champion" },
--     cells = {
--         Cell({ columnKey = "h", itemLevel = 289, displayText = "C", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 292, displayText = "R", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 295, displayText = "G", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 298, displayText = "S", tooltipTitle = "Spark craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "i", itemLevel = 289, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 292, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 295, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 298, tooltipTitle = "Spark craft", metadata = { valueType = "craftingTier" } }),
--         MergedCell({ columnKey = "i", fromItemLevel = 289, toItemLevel = 298, displayText = "Spark", isTextVertical = true, fontSize = 12 }),
--     },
-- })

-- Block({
--     blockId = "craft.hero",
--     backgroundColorKey = "red",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "crafting", track = "hero" },
--     cells = {
--         Cell({ columnKey = "h", itemLevel = 302, displayText = "W", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 305, displayText = "C", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 308, displayText = "R", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 311, displayText = "S", tooltipTitle = "Hero crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "i", itemLevel = 302, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 305, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 308, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 311, tooltipTitle = "Hero crest craft", metadata = { valueType = "craftingTier" } }),
--         MergedCell({ columnKey = "i", fromItemLevel = 302, toItemLevel = 311, displayText = "80 Hero", isTextVertical = true, fontSize = 12 }),
--     },
-- })

-- Block({
--     blockId = "craft.myth",
--     backgroundColorKey = "purple",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "crafting", track = "myth" },
--     cells = {
--         Cell({ columnKey = "h", itemLevel = 315, displayText = "C", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 318, displayText = "R", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 321, displayText = "G", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "h", itemLevel = 324, displayText = "S", tooltipTitle = "Myth crest craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "i", itemLevel = 315, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 318, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 321, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
--         Cell({ columnKey = "i", itemLevel = 324, tooltipTitle = "Myth crest craft", metadata = { valueType = "craftingTier" } }),
--         MergedCell({ columnKey = "i", fromItemLevel = 315, toItemLevel = 324, displayText = "80 Myth", isTextVertical = true, fontSize = 12 }),
--     },
-- })

-- Block({
--     blockId = "craft.veryrare",
--     backgroundColorKey = "purple",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "crafting", track = "veryRare" },
--     cells = {
--         Cell({ columnKey = "h", itemLevel = 334, displayText = "VF", tooltipTitle = "Very rare craft", metadata = { valueType = "crestOrSpark" } }),
--         Cell({ columnKey = "i", itemLevel = 334, tooltipTitle = "Very rare craft", metadata = { valueType = "craftingTier" } }),
--         MergedCell({ columnKey = "i", fromItemLevel = 334, toItemLevel = 334, displayText = "VF", isTextVertical = true, fontSize = 12 }),
--     },
-- })

-- Block({ blockId = "activity.prey.normal", backgroundColorKey = "pink", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
--     Cell({ columnKey = "j", itemLevel = 266, displayText = "N", tooltipTitle = "Prey: Normal", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.prey.heroic", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
--     Cell({ columnKey = "j", itemLevel = 279, displayText = "H", tooltipTitle = "Prey: Heroic", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.prey.mixed", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
--     Cell({ columnKey = "j", itemLevel = 285, displayText = "NM", tooltipTitle = "Prey: Normal/Mythic", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.prey.weekly", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "prey" }, cells = {
--     Cell({ columnKey = "j", itemLevel = 298, displayText = "NM1", tooltipTitle = "Prey: weekly cache", metadata = { valueType = "itemLevel" } }),
-- } })

-- Block({ blockId = "activity.delve.low", backgroundColorKey = "pink", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "delve" }, cells = {
--     Cell({ columnKey = "k", itemLevel = 269, displayText = "1-3", tooltipTitle = "Delve tiers 1-3", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "k", itemLevel = 272, displayText = "4", tooltipTitle = "Delve tier 4", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.delve.mid", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "delve" }, cells = {
--     Cell({ columnKey = "k", itemLevel = 276, displayText = "5", tooltipTitle = "Delve tier 5", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "k", itemLevel = 279, displayText = "6", tooltipTitle = "Delve tier 6", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "k", itemLevel = 282, displayText = "7", tooltipTitle = "Delve tier 7", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "k", itemLevel = 285, displayText = "8+", tooltipTitle = "Delve tier 8+", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.delve.weekly", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "delve" }, cells = {
--     Cell({ columnKey = "k", itemLevel = 298, displayText = "8+1", tooltipTitle = "Delve weekly tier 8+", metadata = { valueType = "itemLevel" } }),
-- } })

-- Block({ blockId = "activity.map.mid", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "map" }, cells = {
--     Cell({ columnKey = "l", itemLevel = 276, displayText = "4", tooltipTitle = "Bountiful map tier 4", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "l", itemLevel = 282, displayText = "5", tooltipTitle = "Bountiful map tier 5", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.map.high", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "map" }, cells = {
--     Cell({ columnKey = "l", itemLevel = 289, displayText = "6", tooltipTitle = "Bountiful map tier 6", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "l", itemLevel = 295, displayText = "7", tooltipTitle = "Bountiful map tier 7", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.map.top", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "map" }, cells = {
--     Cell({ columnKey = "l", itemLevel = 298, displayText = "8+", tooltipTitle = "Bountiful map tier 8+", metadata = { valueType = "itemLevel" } }),
-- } })

-- Block({ blockId = "activity.outdoorVault.mid", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "outdoorVault" }, cells = {
--     Cell({ columnKey = "m", itemLevel = 272, displayText = "1-2", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "m", itemLevel = 276, displayText = "3", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.outdoorVault.high", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "outdoorVault" }, cells = {
--     Cell({ columnKey = "m", itemLevel = 285, displayText = "4", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "m", itemLevel = 292, displayText = "5", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "m", itemLevel = 295, displayText = "6", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "m", itemLevel = 298, displayText = "7", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.outdoorVault.top", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "outdoorVault" }, cells = {
--     Cell({ columnKey = "m", itemLevel = 305, displayText = "8+", tooltipTitle = "Outdoor Great Vault", metadata = { valueType = "itemLevel" } }),
-- } })

-- Block({ blockId = "activity.dungeon.normal", backgroundColorKey = "light", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
--     Cell({ columnKey = "n", itemLevel = 253, displayText = "N", tooltipTitle = "Dungeon: Normal", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.dungeon.heroic", backgroundColorKey = "pink", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
--     Cell({ columnKey = "n", itemLevel = 269, displayText = "H", tooltipTitle = "Dungeon: Heroic", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.dungeon.mythic", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
--     Cell({ columnKey = "n", itemLevel = 285, displayText = "M", tooltipTitle = "Dungeon: Mythic", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "n", itemLevel = 289, displayText = "2-3", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "n", itemLevel = 292, displayText = "4", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "n", itemLevel = 295, displayText = "5", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.dungeon.mythicPlus", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeon" }, cells = {
--     Cell({ columnKey = "n", itemLevel = 298, displayText = "6-7", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "n", itemLevel = 302, displayText = "8-9", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "n", itemLevel = 305, displayText = "10+", tooltipTitle = "Dungeon: Mythic+", metadata = { valueType = "itemLevel" } }),
-- } })

-- Block({ blockId = "activity.dungeonVault.heroic", backgroundColorKey = "blue", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
--     Cell({ columnKey = "o", itemLevel = 282, displayText = "H", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.dungeonVault.mythic", backgroundColorKey = "yellow", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
--     Cell({ columnKey = "o", itemLevel = 295, displayText = "M", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.dungeonVault.mythicPlus", backgroundColorKey = "red", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
--     Cell({ columnKey = "o", itemLevel = 298, displayText = "2-3", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "o", itemLevel = 302, displayText = "4-5", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "o", itemLevel = 305, displayText = "6", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
--     Cell({ columnKey = "o", itemLevel = 308, displayText = "7-9", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
-- } })
-- Block({ blockId = "activity.dungeonVault.top", backgroundColorKey = "purple", outerBorderStyleKey = "solid1", metadata = { contentType = "activity", activityKey = "dungeonVault" }, cells = {
--     Cell({ columnKey = "o", itemLevel = 311, displayText = "10+", tooltipTitle = "Dungeon Great Vault", metadata = { valueType = "itemLevel" } }),
-- } })
