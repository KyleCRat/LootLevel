local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Table = Data.Table
local RawBlock = Data.Block
local Cell = Data.Cell
local MergedCell = Data.MergedCell
local RawColumnBorder = Data.ColumnBorder
local RawRowBorders = Data.RowBorders

local TABLE_KEY = "midnight.delve"

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
    name = "Delve table",
    layout = "midnight",
    rowCount = 11,
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

PrimarySectionBorder("c")
PrimarySectionBorder("e")
