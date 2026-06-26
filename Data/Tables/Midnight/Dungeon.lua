local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawRowBorders = Data.RowBorders

local TABLE_KEY = "midnight.dungeon"

local function Block(definition)
    definition.table = definition.table or TABLE_KEY
    return RawBlock(definition)
end

local function RowBorders(definition)
    definition = definition or {}
    definition.table = definition.table or TABLE_KEY
    return RawRowBorders(definition)
end

Table({
    key = TABLE_KEY,
    name = "Dungeon table",
    layout = "midnight",
    rowCount = 15,
    columns = {
        { col = "a", width = 60, title = "Level", bg = "light", bold = true },
        { col = "b", width = 44, title = "Loot", bg = "blank" },
        { col = "c", width = 44, title = "Loot upgrade", bg = "blank" },
        { col = "d", width = 44, title = "Great Vault", bg = "blank" },
        { col = "e", width = 44, title = "Great Vault upgrade", bg = "blank" },
        { col = "f", width = 60, title = "Crest", bg = "blank" },
        { col = "g", width = 26, title = "Section", bg = "blank" },
    },
    headers = {
        { fromCol = "a", toCol = "a", text = "Level", coord = "a1" },
        { fromCol = "b", toCol = "c", text = "Loot", coord = "b1" },
        { fromCol = "d", toCol = "e", text = "GV", coord = "d1" },
        { fromCol = "f", toCol = "f", text = "Crest", coord = "f1" },
        { fromCol = "g", toCol = "g", text = "", coord = "g1" },
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

-- Block({
--     blockId = "left.questWorld.section",
--     tableKey = "dungeon",
--     backgroundColorKey = "light",
--     outerBorderStyleKey = "solid1",
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 2, tooltipTitle = "Quest / World" }),
--         Cell({ columnKey = "a", rowIndex = 3, tooltipTitle = "Quest / World" }),
--         Cell({ columnKey = "a", rowIndex = 4, tooltipTitle = "Quest / World" }),
--         Cell({ columnKey = "a", rowIndex = 5, tooltipTitle = "Quest / World" }),
--         Cell({ columnKey = "a", rowIndex = 6, tooltipTitle = "Quest / World" }),
--         MergedCell({ columnKey = "a", fromRowIndex = 2, toRowIndex = 6, displayText = "Quest / World", isTextVertical = true }),
--     },
-- })

-- Block({
--     blockId = "left.world.normal",
--     tableKey = "dungeon",
--     backgroundColorKey = "light",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "normal" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 7, displayText = "N", metadata = { valueType = "difficulty" } }),
--         Cell({ columnKey = "b", rowIndex = 7, displayText = "253", metadata = { valueType = "lootItemLevel" } }),
--         Cell({ columnKey = "c", rowIndex = 7, displayText = "-", metadata = { valueType = "lootUpgradeRank" } }),
--         Cell({ columnKey = "d", rowIndex = 7, metadata = { valueType = "vaultItemLevel" } }),
--         Cell({ columnKey = "e", rowIndex = 7, metadata = { valueType = "vaultUpgradeRank" } }),
--         Cell({ columnKey = "f", rowIndex = 7, backgroundColorKey = "blank", metadata = { valueType = "crest" } }),
--     },
-- })

-- Block({
--     blockId = "left.world.heroic",
--     tableKey = "dungeon",
--     backgroundColorKey = "blue",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "heroic" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 8, displayText = "H", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 8, displayText = "269" }),
--         Cell({ columnKey = "c", rowIndex = 8, displayText = "4/6" }),
--         Cell({ columnKey = "d", rowIndex = 8, displayText = "285" }),
--         Cell({ columnKey = "e", rowIndex = 8, displayText = "4/6" }),
--         Cell({ columnKey = "f", rowIndex = 8, displayText = "10 V" }),
--     },
-- })

-- Block({
--     blockId = "left.world.mythicLow",
--     tableKey = "dungeon",
--     backgroundColorKey = "yellow",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "mythicLow" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 9, displayText = "M", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 9, displayText = "285" }),
--         Cell({ columnKey = "c", rowIndex = 9, displayText = "1/6" }),
--         Cell({ columnKey = "d", rowIndex = 9, displayText = "295" }),
--         Cell({ columnKey = "e", rowIndex = 9, displayText = "4/6" }),
--         Cell({ columnKey = "f", rowIndex = 9, displayText = "10 C" }),
--         Cell({ columnKey = "a", rowIndex = 10, displayText = "+2", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 10, displayText = "289" }),
--         Cell({ columnKey = "c", rowIndex = 10, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 10, displayText = "298" }),
--         Cell({ columnKey = "e", rowIndex = 10, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 10, displayText = "12 C" }),
--         Cell({ columnKey = "a", rowIndex = 11, displayText = "+3", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 11, displayText = "289" }),
--         Cell({ columnKey = "c", rowIndex = 11, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 11, displayText = "298" }),
--         Cell({ columnKey = "e", rowIndex = 11, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 11, displayText = "14 C" }),
--     },
-- })

-- Block({
--     blockId = "left.world.mythicHigh",
--     tableKey = "dungeon",
--     backgroundColorKey = "red",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "mythicHigh" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 12, displayText = "+4", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 12, displayText = "292" }),
--         Cell({ columnKey = "c", rowIndex = 12, displayText = "3/6" }),
--         Cell({ columnKey = "d", rowIndex = 12, displayText = "302" }),
--         Cell({ columnKey = "e", rowIndex = 12, displayText = "2/6" }),
--         Cell({ columnKey = "f", rowIndex = 12, displayText = "10 H" }),
--         Cell({ columnKey = "a", rowIndex = 13, displayText = "+5", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 13, displayText = "295" }),
--         Cell({ columnKey = "c", rowIndex = 13, displayText = "4/6" }),
--         Cell({ columnKey = "d", rowIndex = 13, displayText = "302" }),
--         Cell({ columnKey = "e", rowIndex = 13, displayText = "2/6" }),
--         Cell({ columnKey = "f", rowIndex = 13, displayText = "12 H" }),
--         Cell({ columnKey = "a", rowIndex = 14, displayText = "+6", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 14, displayText = "298" }),
--         Cell({ columnKey = "c", rowIndex = 14, displayText = "1/6" }),
--         Cell({ columnKey = "d", rowIndex = 14, displayText = "305" }),
--         Cell({ columnKey = "e", rowIndex = 14, displayText = "3/6" }),
--         Cell({ columnKey = "f", rowIndex = 14, displayText = "14 H" }),
--         Cell({ columnKey = "a", rowIndex = 15, displayText = "+7", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 15, displayText = "298" }),
--         Cell({ columnKey = "c", rowIndex = 15, displayText = "1/6" }),
--         Cell({ columnKey = "d", rowIndex = 15, displayText = "308" }),
--         Cell({ columnKey = "e", rowIndex = 15, displayText = "4/6" }),
--         Cell({ columnKey = "f", rowIndex = 15, displayText = "16 H" }),
--         Cell({ columnKey = "a", rowIndex = 16, displayText = "+8", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 16, displayText = "302" }),
--         Cell({ columnKey = "c", rowIndex = 16, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 16, displayText = "308" }),
--         Cell({ columnKey = "e", rowIndex = 16, displayText = "4/6" }),
--         Cell({ columnKey = "f", rowIndex = 16, displayText = "18 H" }),
--     },
-- })

-- Block({
--     blockId = "left.world.mythicTop",
--     tableKey = "dungeon",
--     backgroundColorKey = "purple",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "world", difficulty = "mythicTop" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 17, displayText = "+9", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 17, displayText = "302" }),
--         Cell({ columnKey = "c", rowIndex = 17, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 17, displayText = "308" }),
--         Cell({ columnKey = "e", rowIndex = 17, displayText = "4/6" }),
--         Cell({ columnKey = "f", rowIndex = 17, displayText = "10 M" }),
--         Cell({ columnKey = "a", rowIndex = 18, displayText = "+10", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 18, displayText = "305" }),
--         Cell({ columnKey = "c", rowIndex = 18, displayText = "3/6" }),
--         Cell({ columnKey = "d", rowIndex = 18, displayText = "311" }),
--         Cell({ columnKey = "e", rowIndex = 18, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 18, displayText = "12 M" }),
--         Cell({ columnKey = "a", rowIndex = 19, displayText = "+11", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 19, displayText = "305" }),
--         Cell({ columnKey = "c", rowIndex = 19, displayText = "3/6" }),
--         Cell({ columnKey = "d", rowIndex = 19, displayText = "311" }),
--         Cell({ columnKey = "e", rowIndex = 19, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 19, displayText = "14 M" }),
--         Cell({ columnKey = "a", rowIndex = 20, displayText = "+12", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 20, displayText = "305" }),
--         Cell({ columnKey = "c", rowIndex = 20, displayText = "3/6" }),
--         Cell({ columnKey = "d", rowIndex = 20, displayText = "311" }),
--         Cell({ columnKey = "e", rowIndex = 20, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 20, displayText = "16 M" }),
--     },
-- })

-- Block({
--     blockId = "left.world.dungeonSection",
--     tableKey = "dungeon",
--     backgroundColorKey = "light",
--     outerBorderStyleKey = "solid1",
--     cells = {
--         Cell({ columnKey = "g", rowIndex = 7 }),
--         Cell({ columnKey = "g", rowIndex = 8 }),
--         Cell({ columnKey = "g", rowIndex = 9 }),
--         Cell({ columnKey = "g", rowIndex = 10 }),
--         Cell({ columnKey = "g", rowIndex = 11 }),
--         Cell({ columnKey = "g", rowIndex = 12 }),
--         Cell({ columnKey = "g", rowIndex = 13 }),
--         Cell({ columnKey = "g", rowIndex = 14 }),
--         Cell({ columnKey = "g", rowIndex = 15 }),
--         Cell({ columnKey = "g", rowIndex = 16 }),
--         Cell({ columnKey = "g", rowIndex = 17 }),
--         Cell({ columnKey = "g", rowIndex = 18 }),
--         Cell({ columnKey = "g", rowIndex = 19 }),
--         Cell({ columnKey = "g", rowIndex = 20 }),
--         MergedCell({ columnKey = "g", fromRowIndex = 7, toRowIndex = 20, displayText = "Dungeon", isTextVertical = true }),
--     },
-- })
