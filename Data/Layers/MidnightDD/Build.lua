local ADDON_NAME, NS = ...

-- Run after both seasons and their table definitions, before the initial UI build.
NS:RunWhenOutOfCombat("midnightDDData", function()
    NS.Progression.Build("midnightDD", { base = 220, step = 3.25 })
end, true)
