local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layout = Data.Layout

local MIDNIGHT_TABLES = {
    activity = "midnight.activity",
    raid = "midnight.raid",
    dungeon = "midnight.dungeon",
    delve = "midnight.delve",
}

Layout({
    key = "midnight",
    name = "Midnight tables",
    tables = MIDNIGHT_TABLES,
    apply = function(layouts, measure, metrics)
        local activity = measure(MIDNIGHT_TABLES.activity)
        local raid = measure(MIDNIGHT_TABLES.raid)
        local dungeon = measure(MIDNIGHT_TABLES.dungeon)
        local delve = measure(MIDNIGHT_TABLES.delve)
        local tableGap = metrics.rowHeight

        if dungeon then
            dungeon.x = 0
            dungeon.y = 0
            layouts[MIDNIGHT_TABLES.dungeon] = dungeon
        end

        if raid and dungeon then
            raid.x = dungeon.x + dungeon.width + tableGap
            raid.y = dungeon.y
            layouts[MIDNIGHT_TABLES.raid] = raid
        elseif raid then
            layouts[MIDNIGHT_TABLES.raid] = raid
        end

        if activity and raid then
            activity.x = raid.x + raid.width + (tableGap / 2)
            activity.y = raid.y
            layouts[MIDNIGHT_TABLES.activity] = activity
        elseif activity then
            layouts[MIDNIGHT_TABLES.activity] = activity
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
