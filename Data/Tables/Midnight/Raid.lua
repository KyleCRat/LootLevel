local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawRowBorders = Data.RowBorders
local RawColumnBorder = Data.ColumnBorder
local RawTableBorder = Data.TableBorder

local TABLE_KEY = "midnight.raid"

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

local function TableBorder(definition)
    definition = definition or {}
    definition.table = definition.table or TABLE_KEY
    return RawTableBorder(definition)
end

Table({
    key = TABLE_KEY,
    name = "Primary item level table",
    layout = "midnight",
    displayedRows = 27,
    columns = {
        { col = "a", width = 40, title = "Item level" },
        { col = "b", width = 36, title = "Raid Difficulty / Track" },
        { col = "c", width = 36, title = "Raid Difficulty / Track" },
        { col = "d", width = 36, title = "Raid Difficulty / Track" },
        { col = "e", width = 36, title = "Raid Difficulty / Track" },
        { col = "f", width = 36, title = "Raid Difficulty / Track" },
        { col = "g", width = 36, title = "Raid Difficulty / Track" },
        { col = "h", width = 36, title = "Craft" },
        { col = "i", width = 36, title = "Craft" },
    },
    headers = {
        { fromCol = "a", toCol = "a", text = "ilvl", coord = "a1" },
        { fromCol = "b", toCol = "g", text = "Raid Difficulty / Track", coord = "b1" },
        { fromCol = "h", toCol = "i", text = "Craft", coord = "h1" },
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

TableBorder({
    style = "solid1",
})

ColumnBorder({
    afterCol = "a",
    fromRow = 1,
    style = "solid1",
    priority = 70,
})

local function PrimarySectionBorder(afterCol)
    ColumnBorder({
        afterCol = afterCol,
        fromRow = 1,
        style = "solid3",
        priority = 70,
    })
end

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
        Cell({ col = "a", row = 2, text = "220" }),
        Cell({ col = "a", row = 3, text = "224" }),
        Cell({ col = "a", row = 4, text = "227" }),
        Cell({ col = "a", row = 5, text = "230" }),
        Cell({ col = "a", row = 6, text = "233" }),
        Cell({ col = "a", row = 7, text = "237" }),
        Cell({ col = "a", row = 8, text = "240" }),
        Cell({ col = "a", row = 9, text = "243" }),
        Cell({ col = "a", row = 10, text = "246" }),
        Cell({ col = "a", row = 11, text = "250" }),
        Cell({ col = "a", row = 12, text = "253" }),
        Cell({ col = "a", row = 13, text = "256" }),
        Cell({ col = "a", row = 14, text = "259" }),
        Cell({ col = "a", row = 15, text = "263" }),
        Cell({ col = "a", row = 16, text = "266" }),
        Cell({ col = "a", row = 17, text = "269" }),
        Cell({ col = "a", row = 18, text = "272" }),
        Cell({ col = "a", row = 19, text = "276" }),
        Cell({ col = "a", row = 20, text = "279" }),
        Cell({ col = "a", row = 21, text = "282" }),
        Cell({ col = "a", row = 22, text = "285" }),
        Cell({ col = "a", row = 23, text = "289" }),
        Cell({ col = "a", row = 24, text = "292" }),
        Cell({ col = "a", row = 25, text = "295" }),
        Cell({ col = "a", row = 26, text = "298" }),
        Cell({ col = "a", row = 27, text = "302" }),
        Cell({ col = "a", row = 28, text = "305" }),
        Cell({ col = "a", row = 29, text = "308" }),
        Cell({ col = "a", row = 30, text = "311" }),
        Cell({ col = "a", row = 31, text = "315" }),
        Cell({ col = "a", row = 32, text = "318" }),
        Cell({ col = "a", row = 33, text = "321" }),
        Cell({ col = "a", row = 34, text = "324" }),
        Cell({ col = "a", row = 35, text = "328" }),
        Cell({ col = "a", row = 36, text = "331" }),
        Cell({ col = "a", row = 37, text = "334" }),
        Cell({ col = "a", row = 38, text = "337" }),
    },
})
