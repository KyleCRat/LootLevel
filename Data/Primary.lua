local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawRowBorders = Data.RowBorders
local RawColumnBorder = Data.ColumnBorder

local TABLE_KEY = "primary"

local function Block(definition)
    definition.table = definition.table or TABLE_KEY
    return RawBlock(definition)
end

local function RowBorders(definition)
    definition = definition or {}
    definition.table = definition.table or TABLE_KEY
    return RawRowBorders(definition)
end

local function ColumnBorder(definition)
    definition = definition or {}
    definition.table = definition.table or TABLE_KEY
    return RawColumnBorder(definition)
end

Table({
    key = TABLE_KEY,
    name = "Primary item level table",
    x = 354,
    y = 0,
    displayedRows = 28,
    columns = {
        { col = "a", width = 46, title = "Item level" },
        { col = "b", width = 40, title = "Raid Difficulty / Track" },
        { col = "c", width = 40, title = "Raid Difficulty / Track" },
        { col = "d", width = 40, title = "Raid Difficulty / Track" },
        { col = "e", width = 40, title = "Raid Difficulty / Track" },
        { col = "f", width = 40, title = "Raid Difficulty / Track" },
        { col = "g", width = 40, title = "Raid Difficulty / Track" },
        { col = "h", width = 43, title = "Craft" },
        { col = "i", width = 43, title = "Craft" },
        { col = "j", width = 62, title = "Prey" },
        { col = "k", width = 62, title = "Delve" },
        { col = "l", width = 62, title = "Map" },
        { col = "m", width = 62, title = "Great Vault" },
        { col = "n", width = 62, title = "Dungeon" },
        { col = "o", width = 62, title = "Dungeon Great Vault" },
        { col = "p", width = 46, title = "Item level" },
    },
    headers = {
        { fromCol = "a", toCol = "a", text = "ilvl", coord = "a1" },
        { fromCol = "b", toCol = "g", text = "Raid Difficulty / Track", coord = "b1" },
        { fromCol = "h", toCol = "i", text = "Craft", coord = "h1" },
        { fromCol = "j", toCol = "j", text = "Prey", coord = "j1" },
        { fromCol = "k", toCol = "k", text = "Delve", coord = "k1" },
        { fromCol = "l", toCol = "l", text = "Map", coord = "l1" },
        { fromCol = "m", toCol = "m", text = "GV", coord = "m1" },
        { fromCol = "n", toCol = "n", text = "Dung.", coord = "n1" },
        { fromCol = "o", toCol = "o", text = "GV", coord = "o1" },
        { fromCol = "p", toCol = "p", text = "ilvl", coord = "p1" },
    },
})

RowBorders({
    fromRow = 1,
    toRow = 1,
    style = "solid3",
    priority = 100,
})

RowBorders({
    style = "dashed",
    priority = 1,
})

local function PrimarySectionBorder(afterCol)
    ColumnBorder({
        afterCol = afterCol,
        fromRow = 1,
        style = "solid3",
        priority = 70,
    })
end

PrimarySectionBorder("a")
PrimarySectionBorder("g")
PrimarySectionBorder("i")
PrimarySectionBorder("j")
PrimarySectionBorder("m")
PrimarySectionBorder("o")

Block({
    id = "primary.itemLevels.left",
    bg = "light",
    border = "solid1",
    innerBorder = "dashed",
    bold = true,
    cells = {
        Cell({ col = "a", row = 1, text = "220" }),
        Cell({ col = "a", row = 2, text = "224" }),
        Cell({ col = "a", row = 3, text = "227" }),
        Cell({ col = "a", row = 4, text = "230" }),
        Cell({ col = "a", row = 5, text = "233" }),
        Cell({ col = "a", row = 6, text = "237" }),
        Cell({ col = "a", row = 7, text = "240" }),
        Cell({ col = "a", row = 8, text = "243" }),
        Cell({ col = "a", row = 9, text = "246" }),
        Cell({ col = "a", row = 10, text = "250" }),
        Cell({ col = "a", row = 11, text = "253" }),
        Cell({ col = "a", row = 12, text = "256" }),
        Cell({ col = "a", row = 13, text = "259" }),
        Cell({ col = "a", row = 14, text = "263" }),
        Cell({ col = "a", row = 15, text = "266" }),
        Cell({ col = "a", row = 16, text = "269" }),
        Cell({ col = "a", row = 17, text = "272" }),
        Cell({ col = "a", row = 18, text = "276" }),
        Cell({ col = "a", row = 19, text = "279" }),
        Cell({ col = "a", row = 20, text = "282" }),
        Cell({ col = "a", row = 21, text = "285" }),
        Cell({ col = "a", row = 22, text = "289" }),
        Cell({ col = "a", row = 23, text = "292" }),
        Cell({ col = "a", row = 24, text = "295" }),
        Cell({ col = "a", row = 25, text = "298" }),
        Cell({ col = "a", row = 26, text = "302" }),
        Cell({ col = "a", row = 27, text = "305" }),
        Cell({ col = "a", row = 28, text = "308" }),
        Cell({ col = "a", row = 29, text = "311" }),
        Cell({ col = "a", row = 30, text = "315" }),
        Cell({ col = "a", row = 31, text = "318" }),
        Cell({ col = "a", row = 32, text = "321" }),
        Cell({ col = "a", row = 33, text = "324" }),
        Cell({ col = "a", row = 34, text = "328" }),
        Cell({ col = "a", row = 35, text = "331" }),
        Cell({ col = "a", row = 36, text = "334" }),
        Cell({ col = "a", row = 37, text = "337" }),
    },
})

Block({
    id = "primary.itemLevels.right",
    bg = "light",
    border = "solid1",
    innerBorder = "dashed",
    bold = true,
    cells = {
        Cell({ col = "p", row = 1, text = "220" }),
        Cell({ col = "p", row = 2, text = "224" }),
        Cell({ col = "p", row = 3, text = "227" }),
        Cell({ col = "p", row = 4, text = "230" }),
        Cell({ col = "p", row = 5, text = "233" }),
        Cell({ col = "p", row = 6, text = "237" }),
        Cell({ col = "p", row = 7, text = "240" }),
        Cell({ col = "p", row = 8, text = "243" }),
        Cell({ col = "p", row = 9, text = "246" }),
        Cell({ col = "p", row = 10, text = "250" }),
        Cell({ col = "p", row = 11, text = "253" }),
        Cell({ col = "p", row = 12, text = "256" }),
        Cell({ col = "p", row = 13, text = "259" }),
        Cell({ col = "p", row = 14, text = "263" }),
        Cell({ col = "p", row = 15, text = "266" }),
        Cell({ col = "p", row = 16, text = "269" }),
        Cell({ col = "p", row = 17, text = "272" }),
        Cell({ col = "p", row = 18, text = "276" }),
        Cell({ col = "p", row = 19, text = "279" }),
        Cell({ col = "p", row = 20, text = "282" }),
        Cell({ col = "p", row = 21, text = "285" }),
        Cell({ col = "p", row = 22, text = "289" }),
        Cell({ col = "p", row = 23, text = "292" }),
        Cell({ col = "p", row = 24, text = "295" }),
        Cell({ col = "p", row = 25, text = "298" }),
        Cell({ col = "p", row = 26, text = "302" }),
        Cell({ col = "p", row = 27, text = "305" }),
        Cell({ col = "p", row = 28, text = "308" }),
        Cell({ col = "p", row = 29, text = "311" }),
        Cell({ col = "p", row = 30, text = "315" }),
        Cell({ col = "p", row = 31, text = "318" }),
        Cell({ col = "p", row = 32, text = "321" }),
        Cell({ col = "p", row = 33, text = "324" }),
        Cell({ col = "p", row = 34, text = "328" }),
        Cell({ col = "p", row = 35, text = "331" }),
        Cell({ col = "p", row = 36, text = "334" }),
        Cell({ col = "p", row = 37, text = "337" }),
    },
})

Block({
    id = "adventurer",
    bg = "pink",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        Cell({ col = "f", row = 12, text = "1/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 13, text = "2/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 14, text = "3/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 15, text = "4/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 16, text = "5/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        Cell({ col = "f", row = 17, text = "6/6", tooltip = { title = "Adventurer Upgrade Track" } }),
        MergedCell({ col = "g", row = 12, toRow = 17, text = "Adventurer", vertical = true }),
        Cell({ col = "b", row = 17, text = "GV", bg = "pink", border = { right = "dashed", bottom = "dashed" }, tooltip = { title = "Adventurer Great Vault Reward" } }),
    },
})

Block({
    id = "veteran",
    bg = "blue",
    border = "solid1",
    innerBorder = "dashed",
    cells = {
        MergedCell({ col = "b", row = 18, toRow = 20, text = "LFR", vertical = true, tooltip = { title = "Standard Raid Drops" } }),
        Cell({ col = "b", row = 20, text = "Rare", font = { size = 10 }, tooltip = { title = "LFR raid drops" } }),
        Cell({ col = "c", row = 17, text = "1/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 18, text = "2/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 19, text = "3/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 20, text = "4/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 21, text = "5/6", tooltip = { title = "Veteran Upgrade Track" } }),
        Cell({ col = "c", row = 22, text = "6/6", tooltip = { title = "Veteran Upgrade Track" } }),
        MergedCell({ col = "d", row = 17, toRow = 22, text = "Veteran", vertical = true }),
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
