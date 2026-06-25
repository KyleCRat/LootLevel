local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawBorderRule = Data.BorderRule

local TABLE_KEY = "delve"

local function Block(definition)
    definition.table = definition.table or TABLE_KEY
    return RawBlock(definition)
end

local function BorderRule(definition)
    definition.table = definition.table or TABLE_KEY
    return RawBorderRule(definition)
end

Table({
    key = TABLE_KEY,
    name = "Delve table",
    x = 0,
    y = 426,
    rowCount = 11,
    columns = {
        { col = "a", width = 62, title = "Level", bg = "light", bold = true },
        { col = "b", width = 46, title = "Loot", bg = "blank" },
        { col = "c", width = 46, title = "Loot upgrade", bg = "blank" },
        { col = "d", width = 46, title = "Great Vault", bg = "blank" },
        { col = "e", width = 46, title = "Great Vault upgrade", bg = "blank" },
        { col = "f", width = 62, title = "Crest", bg = "blank" },
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

BorderRule({
    axis = "horizontal",
    fromRow = 1,
    toRow = 1,
    each = true,
    style = "solid3",
    priority = 100,
})

BorderRule({
    axis = "horizontal",
    each = true,
    style = "dashed",
    priority = 1,
})

-- Block({
--     blockId = "left.delve.low",
--     tableKey = "delve",
--     backgroundColorKey = "pink",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "low" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 24, displayText = "1", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 24, displayText = "259" }),
--         Cell({ columnKey = "c", rowIndex = 24, displayText = "1/6" }),
--         Cell({ columnKey = "d", rowIndex = 24, displayText = "272" }),
--         Cell({ columnKey = "e", rowIndex = 24, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 24, backgroundColorKey = "blank" }),
--         Cell({ columnKey = "a", rowIndex = 25, displayText = "2", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 25, displayText = "263" }),
--         Cell({ columnKey = "c", rowIndex = 25, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 25, displayText = "276" }),
--         Cell({ columnKey = "e", rowIndex = 25, displayText = "2/6" }),
--         Cell({ columnKey = "f", rowIndex = 25, backgroundColorKey = "blank" }),
--         Cell({ columnKey = "a", rowIndex = 26, displayText = "3", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 26, displayText = "266" }),
--         Cell({ columnKey = "c", rowIndex = 26, displayText = "3/6" }),
--         Cell({ columnKey = "d", rowIndex = 26, displayText = "279" }),
--         Cell({ columnKey = "e", rowIndex = 26, displayText = "3/6" }),
--         Cell({ columnKey = "f", rowIndex = 26, backgroundColorKey = "blank" }),
--         Cell({ columnKey = "a", rowIndex = 27, displayText = "4", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 27, displayText = "269" }),
--         Cell({ columnKey = "c", rowIndex = 27, displayText = "4/6" }),
--         Cell({ columnKey = "d", rowIndex = 27, displayText = "282" }),
--         Cell({ columnKey = "e", rowIndex = 27, displayText = "4/6" }),
--         Cell({ columnKey = "f", rowIndex = 27, displayText = "A" }),
--     },
-- })

-- Block({
--     blockId = "left.delve.mid",
--     tableKey = "delve",
--     backgroundColorKey = "blue",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "mid" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 28, displayText = "5", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 28, displayText = "272" }),
--         Cell({ columnKey = "c", rowIndex = 28, displayText = "1/6" }),
--         Cell({ columnKey = "d", rowIndex = 28, displayText = "285" }),
--         Cell({ columnKey = "e", rowIndex = 28, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 28, displayText = "V" }),
--         Cell({ columnKey = "a", rowIndex = 29, displayText = "6", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 29, displayText = "276" }),
--         Cell({ columnKey = "c", rowIndex = 29, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 29, displayText = "292" }),
--         Cell({ columnKey = "e", rowIndex = 29, displayText = "3/6" }),
--         Cell({ columnKey = "f", rowIndex = 29, displayText = "V" }),
--     },
-- })

-- Block({
--     blockId = "left.delve.high",
--     tableKey = "delve",
--     backgroundColorKey = "yellow",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "high" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 30, displayText = "7", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 30, displayText = "285" }),
--         Cell({ columnKey = "c", rowIndex = 30, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 30, displayText = "295" }),
--         Cell({ columnKey = "e", rowIndex = 30, displayText = "4/6" }),
--         Cell({ columnKey = "f", rowIndex = 30, displayText = "C" }),
--         Cell({ columnKey = "a", rowIndex = 31, displayText = "8", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 31, displayText = "285" }),
--         Cell({ columnKey = "c", rowIndex = 31, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 31, displayText = "298" }),
--         Cell({ columnKey = "e", rowIndex = 31, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 31, displayText = "C" }),
--         Cell({ columnKey = "a", rowIndex = 32, displayText = "9", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 32, displayText = "285" }),
--         Cell({ columnKey = "c", rowIndex = 32, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 32, displayText = "298" }),
--         Cell({ columnKey = "e", rowIndex = 32, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 32, displayText = "C" }),
--         Cell({ columnKey = "a", rowIndex = 33, displayText = "10", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 33, displayText = "285" }),
--         Cell({ columnKey = "c", rowIndex = 33, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 33, displayText = "298" }),
--         Cell({ columnKey = "e", rowIndex = 33, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 33, displayText = "C" }),
--     },
-- })

-- Block({
--     blockId = "left.delve.top",
--     tableKey = "delve",
--     backgroundColorKey = "red",
--     outerBorderStyleKey = "solid1",
--     metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "top" },
--     cells = {
--         Cell({ columnKey = "a", rowIndex = 34, displayText = "11", backgroundColorKey = "light" }),
--         Cell({ columnKey = "b", rowIndex = 34, displayText = "285" }),
--         Cell({ columnKey = "c", rowIndex = 34, displayText = "2/6" }),
--         Cell({ columnKey = "d", rowIndex = 34, displayText = "298" }),
--         Cell({ columnKey = "e", rowIndex = 34, displayText = "1/6" }),
--         Cell({ columnKey = "f", rowIndex = 34, displayText = "H" }),
--     },
-- })

-- Block({
--     blockId = "left.delve.section",
--     tableKey = "delve",
--     backgroundColorKey = "light",
--     outerBorderStyleKey = "solid1",
--     cells = {
--         Cell({ columnKey = "g", rowIndex = 24 }),
--         Cell({ columnKey = "g", rowIndex = 25 }),
--         Cell({ columnKey = "g", rowIndex = 26 }),
--         Cell({ columnKey = "g", rowIndex = 27 }),
--         Cell({ columnKey = "g", rowIndex = 28 }),
--         Cell({ columnKey = "g", rowIndex = 29 }),
--         Cell({ columnKey = "g", rowIndex = 30 }),
--         Cell({ columnKey = "g", rowIndex = 31 }),
--         Cell({ columnKey = "g", rowIndex = 32 }),
--         Cell({ columnKey = "g", rowIndex = 33 }),
--         Cell({ columnKey = "g", rowIndex = 34 }),
--         MergedCell({ columnKey = "g", fromRowIndex = 24, toRowIndex = 34, displayText = "Delve", isTextVertical = true }),
--     },
-- })
