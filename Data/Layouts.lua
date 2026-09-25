local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layout = Data.Layout

local function MidnightLayout(key, name, tables)
    Layout({
        key = key,
        name = name,
        tables = tables,
        apply = function(layouts, measure, metrics)
            local activity = measure(tables.activity)
            local raid = measure(tables.raid)
            local dungeon = measure(tables.dungeon)
            local delve = measure(tables.delve)
            local tableGap = metrics.rowHeight

            if dungeon then
                dungeon.x = 0
                dungeon.y = 0
                layouts[tables.dungeon] = dungeon
            end

            if raid and dungeon then
                raid.x = dungeon.x + dungeon.width + (tableGap / 2)
                raid.y = dungeon.y
                layouts[tables.raid] = raid
            elseif raid then
                layouts[tables.raid] = raid
            end

            if activity and raid then
                activity.x = raid.x + raid.width + (tableGap / 2)
                activity.y = raid.y
                layouts[tables.activity] = activity
            elseif activity then
                layouts[tables.activity] = activity
            end

            if delve and dungeon then
                delve.x = dungeon.x
                delve.y = dungeon.y + dungeon.height + tableGap
                layouts[tables.delve] = delve
            elseif delve then
                layouts[tables.delve] = delve
            end
        end,
    })
end

MidnightLayout("midnight", "Midnight tables", {
    activity = "midnight.activity",
    raid = "midnight.raid",
    dungeon = "midnight.dungeon",
    delve = "midnight.delve",
})

MidnightLayout("midnightDD", "Midnight data-driven tables", {
    activity = "midnightDD.activity",
    raid = "midnightDD.raid",
    dungeon = "midnightDD.dungeon",
    delve = "midnightDD.delve",
})
