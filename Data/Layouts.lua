local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layout = Data.Layout

local MIDNIGHT_TABLES = {
    primary = "midnight.primary",
    dungeon = "midnight.dungeon",
    delve = "midnight.delve",
}

Layout({
    key = "midnight",
    name = "Midnight tables",
    tables = MIDNIGHT_TABLES,
    apply = function(layouts, measure, metrics)
        local dungeon = measure(MIDNIGHT_TABLES.dungeon)
        local primary = measure(MIDNIGHT_TABLES.primary)
        local delve = measure(MIDNIGHT_TABLES.delve)
        local tableGap = metrics.rowHeight

        if dungeon then
            dungeon.x = 0
            dungeon.y = 0
            layouts[MIDNIGHT_TABLES.dungeon] = dungeon
        end

        if primary and dungeon then
            primary.x = dungeon.x + dungeon.width + tableGap
            primary.y = dungeon.y
            layouts[MIDNIGHT_TABLES.primary] = primary
        elseif primary then
            layouts[MIDNIGHT_TABLES.primary] = primary
        end

        if delve and dungeon then
            delve.x = dungeon.x
            delve.y = dungeon.y + dungeon.height + tableGap
            layouts[MIDNIGHT_TABLES.delve] = delve
        elseif delve then
            layouts[MIDNIGHT_TABLES.delve] = delve
        end
    end,
})
