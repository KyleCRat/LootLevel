local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawBorderRule = Data.BorderRule

local TABLE_KEY = "delve"

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
    displayName = "Delve table",
    positionX = 0,
    positionY = 426,
    columns = {
        { columnKey = "a", width = 62, columnTitle = "Level", defaultColorKey = "light", isBold = true },
        { columnKey = "b", width = 46, columnTitle = "Loot", defaultColorKey = "blank" },
        { columnKey = "c", width = 46, columnTitle = "Loot upgrade", defaultColorKey = "blank" },
        { columnKey = "d", width = 46, columnTitle = "Great Vault", defaultColorKey = "blank" },
        { columnKey = "e", width = 46, columnTitle = "Great Vault upgrade", defaultColorKey = "blank" },
        { columnKey = "f", width = 62, columnTitle = "Crest", defaultColorKey = "blank" },
        { columnKey = "g", width = 26, columnTitle = "Section", defaultColorKey = "blank" },
    },
    headers = {
        { startColumnKey = "a", endColumnKey = "a", displayText = "Level", cellCoordinate = "a1" },
        { startColumnKey = "b", endColumnKey = "c", displayText = "Loot", cellCoordinate = "b1" },
        { startColumnKey = "d", endColumnKey = "e", displayText = "GV", cellCoordinate = "d1" },
        { startColumnKey = "f", endColumnKey = "f", displayText = "Crest", cellCoordinate = "f1" },
        { startColumnKey = "g", endColumnKey = "g", displayText = "", cellCoordinate = "g1" },
    },
    bodyRows = {
        rowSource = "explicitRange",
        firstRowIndex = 24,
        lastRowIndex = 34,
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

Block({
    blockId = "left.delve.low",
    tableKey = "delve",
    backgroundColorKey = "pink",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "low" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 24, displayText = "1", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 24, displayText = "259" }),
        Cell({ columnKey = "c", rowIndex = 24, displayText = "1/6" }),
        Cell({ columnKey = "d", rowIndex = 24, displayText = "272" }),
        Cell({ columnKey = "e", rowIndex = 24, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 24, backgroundColorKey = "blank" }),
        Cell({ columnKey = "a", rowIndex = 25, displayText = "2", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 25, displayText = "263" }),
        Cell({ columnKey = "c", rowIndex = 25, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 25, displayText = "276" }),
        Cell({ columnKey = "e", rowIndex = 25, displayText = "2/6" }),
        Cell({ columnKey = "f", rowIndex = 25, backgroundColorKey = "blank" }),
        Cell({ columnKey = "a", rowIndex = 26, displayText = "3", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 26, displayText = "266" }),
        Cell({ columnKey = "c", rowIndex = 26, displayText = "3/6" }),
        Cell({ columnKey = "d", rowIndex = 26, displayText = "279" }),
        Cell({ columnKey = "e", rowIndex = 26, displayText = "3/6" }),
        Cell({ columnKey = "f", rowIndex = 26, backgroundColorKey = "blank" }),
        Cell({ columnKey = "a", rowIndex = 27, displayText = "4", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 27, displayText = "269" }),
        Cell({ columnKey = "c", rowIndex = 27, displayText = "4/6" }),
        Cell({ columnKey = "d", rowIndex = 27, displayText = "282" }),
        Cell({ columnKey = "e", rowIndex = 27, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 27, displayText = "A" }),
    },
})

Block({
    blockId = "left.delve.mid",
    tableKey = "delve",
    backgroundColorKey = "blue",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "mid" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 28, displayText = "5", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 28, displayText = "272" }),
        Cell({ columnKey = "c", rowIndex = 28, displayText = "1/6" }),
        Cell({ columnKey = "d", rowIndex = 28, displayText = "285" }),
        Cell({ columnKey = "e", rowIndex = 28, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 28, displayText = "V" }),
        Cell({ columnKey = "a", rowIndex = 29, displayText = "6", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 29, displayText = "276" }),
        Cell({ columnKey = "c", rowIndex = 29, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 29, displayText = "292" }),
        Cell({ columnKey = "e", rowIndex = 29, displayText = "3/6" }),
        Cell({ columnKey = "f", rowIndex = 29, displayText = "V" }),
    },
})

Block({
    blockId = "left.delve.high",
    tableKey = "delve",
    backgroundColorKey = "yellow",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "high" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 30, displayText = "7", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 30, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 30, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 30, displayText = "295" }),
        Cell({ columnKey = "e", rowIndex = 30, displayText = "4/6" }),
        Cell({ columnKey = "f", rowIndex = 30, displayText = "C" }),
        Cell({ columnKey = "a", rowIndex = 31, displayText = "8", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 31, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 31, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 31, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 31, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 31, displayText = "C" }),
        Cell({ columnKey = "a", rowIndex = 32, displayText = "9", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 32, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 32, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 32, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 32, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 32, displayText = "C" }),
        Cell({ columnKey = "a", rowIndex = 33, displayText = "10", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 33, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 33, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 33, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 33, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 33, displayText = "C" }),
    },
})

Block({
    blockId = "left.delve.top",
    tableKey = "delve",
    backgroundColorKey = "red",
    outerBorderStyleKey = "solid1",
    metadata = { contentType = "leftRewards", activityKey = "delve", tierBand = "top" },
    cells = {
        Cell({ columnKey = "a", rowIndex = 34, displayText = "11", backgroundColorKey = "light" }),
        Cell({ columnKey = "b", rowIndex = 34, displayText = "285" }),
        Cell({ columnKey = "c", rowIndex = 34, displayText = "2/6" }),
        Cell({ columnKey = "d", rowIndex = 34, displayText = "298" }),
        Cell({ columnKey = "e", rowIndex = 34, displayText = "1/6" }),
        Cell({ columnKey = "f", rowIndex = 34, displayText = "H" }),
    },
})

Block({
    blockId = "left.delve.section",
    tableKey = "delve",
    backgroundColorKey = "light",
    outerBorderStyleKey = "solid1",
    cells = {
        Cell({ columnKey = "g", rowIndex = 24 }),
        Cell({ columnKey = "g", rowIndex = 25 }),
        Cell({ columnKey = "g", rowIndex = 26 }),
        Cell({ columnKey = "g", rowIndex = 27 }),
        Cell({ columnKey = "g", rowIndex = 28 }),
        Cell({ columnKey = "g", rowIndex = 29 }),
        Cell({ columnKey = "g", rowIndex = 30 }),
        Cell({ columnKey = "g", rowIndex = 31 }),
        Cell({ columnKey = "g", rowIndex = 32 }),
        Cell({ columnKey = "g", rowIndex = 33 }),
        Cell({ columnKey = "g", rowIndex = 34 }),
        MergedCell({ columnKey = "g", fromRowIndex = 24, toRowIndex = 34, displayText = "Delve", isTextVertical = true }),
    },
})
