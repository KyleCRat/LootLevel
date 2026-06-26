local ADDON_NAME, NS = ...

local Data = NS.DataAPI
local Layout = Data.Layout

Layout({
    key = "midnight",
    name = "Midnight tables",
    apply = function(layouts, measure, metrics)
        local dungeon = measure("dungeon")
        local primary = measure("primary")
        local delve = measure("delve")
        local tableGap = metrics.rowHeight

        if dungeon then
            dungeon.x = 0
            dungeon.y = 0
            layouts.dungeon = dungeon
        end

        if primary and dungeon then
            primary.x = dungeon.x + dungeon.width + tableGap
            primary.y = dungeon.y
            layouts.primary = primary
        elseif primary then
            layouts.primary = primary
        end

        if delve and dungeon then
            delve.x = dungeon.x
            delve.y = dungeon.y + dungeon.height + tableGap
            layouts.delve = delve
        elseif delve then
            layouts.delve = delve
        end
    end,
})
