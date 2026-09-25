local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local sourceTables = NS.Data.layouts.midnight.tables
local targetTables = NS.Data.layouts.midnightDD.tables
local targetBySource = {}

-- Share presentation definitions, but keep all seasonal cells and scroll state separate.
for _, role in ipairs({ "dungeon", "delve", "raid", "activity" }) do
    local sourceKey = sourceTables[role]
    local targetKey = targetTables[role]
    local definition = CopyTable(NS.Data.tables[sourceKey])
    definition.key = targetKey
    definition.layout = "midnightDD"
    if definition.bodyScrollGroup then
        definition.bodyScrollGroup = "midnightDD.raidActivity"
    end
    Data.Table(definition)
    targetBySource[sourceKey] = targetKey
end

local borderConstructors = {
    rowBorders = Data.RowBorders,
    columnBorders = Data.ColumnBorders,
    tableBorder = Data.TableBorder,
    rowBorder = Data.RowBorder,
    columnBorder = Data.ColumnBorder,
    betweenCellsBorder = Data.BetweenCellsBorder,
}

local borderCount = #NS.Data.borderRules
for index = 1, borderCount do
    local rule = NS.Data.borderRules[index]
    local targetKey = targetBySource[rule.table]
    if targetKey then
        local definition = CopyTable(rule)
        definition.table = targetKey
        borderConstructors[definition.kind](definition)
    end
end
