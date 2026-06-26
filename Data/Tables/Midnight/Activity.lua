local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawRowBorders = Data.RowBorders
local RawColumnBorder = Data.ColumnBorder
local RawTableBorder = Data.TableBorder

local TABLE_KEY = "midnight.activity"

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
    displayedRows = 28,
    columns = {
        { col = "a", width = 48, title = "Prey" },
        { col = "b", width = 48, title = "Delve" },
        { col = "c", width = 48, title = "Map" },
        { col = "d", width = 48, title = "Great Vault" },
        { col = "e", width = 48, title = "Dungeon" },
        { col = "f", width = 48, title = "Dungeon Great Vault" },
        { col = "g", width = 40, title = "Item level" },
    },
    headers = {
        { fromCol = "a", toCol = "a", text = "Prey", coord = "a1" },
        { fromCol = "b", toCol = "b", text = "Delve", coord = "b1" },
        { fromCol = "c", toCol = "c", text = "Map", coord = "c1" },
        { fromCol = "d", toCol = "d", text = "GV", coord = "d1" },
        { fromCol = "e", toCol = "e", text = "Dung.", coord = "e1" },
        { fromCol = "f", toCol = "f", text = "GV", coord = "f1" },
        { fromCol = "g", toCol = "g", text = "ilvl", coord = "g1" },
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
    afterCol = "b",
    fromRow = 1,
    style = "solid1",
    priority = 70,
})

ColumnBorder({
    afterCol = "c",
    fromRow = 1,
    style = "solid1",
    priority = 70,
})

ColumnBorder({
    afterCol = "f",
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

PrimarySectionBorder("a")
PrimarySectionBorder("d")
PrimarySectionBorder("e")


Block({
    id = "primary.itemLevels.right",
    bg = "light",
    border = "solid1",
    innerBorder = "dashed",
    bold = true,
    cells = {
        Cell({ col = "g", row = 2, text = "220" }),
        Cell({ col = "g", row = 3, text = "224" }),
        Cell({ col = "g", row = 4, text = "227" }),
        Cell({ col = "g", row = 5, text = "230" }),
        Cell({ col = "g", row = 6, text = "233" }),
        Cell({ col = "g", row = 7, text = "237" }),
        Cell({ col = "g", row = 8, text = "240" }),
        Cell({ col = "g", row = 9, text = "243" }),
        Cell({ col = "g", row = 10, text = "246" }),
        Cell({ col = "g", row = 11, text = "250" }),
        Cell({ col = "g", row = 12, text = "253" }),
        Cell({ col = "g", row = 13, text = "256" }),
        Cell({ col = "g", row = 14, text = "259" }),
        Cell({ col = "g", row = 15, text = "263" }),
        Cell({ col = "g", row = 16, text = "266" }),
        Cell({ col = "g", row = 17, text = "269" }),
        Cell({ col = "g", row = 18, text = "272" }),
        Cell({ col = "g", row = 19, text = "276" }),
        Cell({ col = "g", row = 20, text = "279" }),
        Cell({ col = "g", row = 21, text = "282" }),
        Cell({ col = "g", row = 22, text = "285" }),
        Cell({ col = "g", row = 23, text = "289" }),
        Cell({ col = "g", row = 24, text = "292" }),
        Cell({ col = "g", row = 25, text = "295" }),
        Cell({ col = "g", row = 26, text = "298" }),
        Cell({ col = "g", row = 27, text = "302" }),
        Cell({ col = "g", row = 28, text = "305" }),
        Cell({ col = "g", row = 29, text = "308" }),
        Cell({ col = "g", row = 30, text = "311" }),
        Cell({ col = "g", row = 31, text = "315" }),
        Cell({ col = "g", row = 32, text = "318" }),
        Cell({ col = "g", row = 33, text = "321" }),
        Cell({ col = "g", row = 34, text = "324" }),
        Cell({ col = "g", row = 35, text = "328" }),
        Cell({ col = "g", row = 36, text = "331" }),
        Cell({ col = "g", row = 37, text = "334" }),
        Cell({ col = "g", row = 38, text = "337" }),
    },
})
