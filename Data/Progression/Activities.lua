local ADDON_NAME, NS = ...

local Progression = NS.Progression
local Add = Progression.Add

local SOURCES = {
    { key = "prey", col = "a" },
    { key = "delve", col = "b" },
    { key = "map", col = "c" },
    { key = "delveVault", col = "d" },
    { key = "dungeon", col = "e" },
    { key = "dungeonVault", col = "f" },
}

local DUNGEON_DIFFICULTIES = { N = 1, H = 2, M = 3 }

local function BuildSummary(context)
    local activities = context.season.activities or {}
    for _, source in ipairs(SOURCES) do
        for _, reward in ipairs(activities[source.key] or {}) do
            local track = Progression.Track(reward.track)
            Add(context, "activity", reward.track, track.bg, {
                col = source.col, ilvl = reward.ilvl, text = reward.label, tooltip = reward.tooltip,
            })
        end
    end
end

local function AddReward(context, role, row, reward, col, rankCol)
    if not reward then return end
    local track = Progression.Track(reward.track)
    Add(context, role, reward.track, track.bg, {
        col = col, row = row, text = tostring(reward.ilvl), tooltip = reward.tooltip,
    })
    Add(context, role, reward.track, track.bg, {
        col = rankCol, row = row, text = Progression.Rank(context, reward),
    })
end

local function DungeonOrder(label)
    if DUNGEON_DIFFICULTIES[label] then return DUNGEON_DIFFICULTIES[label] end
    local level = tonumber(label:match("^%+(%d+)$"))
    assert(level and level >= 2, "LootLevel progression: unknown dungeon level " .. label)
    return level + 2
end

local function BuildRewards(context, role, title, definitions)
    if not definitions or #definitions == 0 then return end

    local entries = {}
    local seen = {}
    for _, definition in ipairs(definitions) do
        local label = role == "dungeon" and definition.label or tostring(definition.level)
        local order = role == "dungeon" and DungeonOrder(label) or definition.level
        assert(type(order) == "number" and order > 0, "LootLevel progression: invalid activity level")
        assert(not seen[order], "LootLevel progression: duplicate " .. role .. " level " .. label)
        seen[order] = true
        entries[#entries + 1] = { definition = definition, label = label, order = order }
    end
    table.sort(entries, function(a, b) return a.order < b.order end)

    for index, entry in ipairs(entries) do
        local row = index + 1
        local definition = entry.definition
        Add(context, role, "levels", "light", { col = "a", row = row, text = entry.label }, true)
        AddReward(context, role, row, definition.loot, "b", "c")
        AddReward(context, role, row, definition.vault, "d", "e")
        if definition.crest then
            local crest = definition.crest
            local track = Progression.Track(crest.track)
            local text = crest.amount and (crest.amount .. " " .. track.crest) or track.crest
            Add(context, role, crest.track, track.bg, { col = "f", row = row, text = text })
        end
    end
    Add(context, role, "section", "light", {
        col = "g", row = 2, toRow = #entries + 1, text = title, vertical = true,
    })
end

function Progression.BuildActivities(context)
    BuildSummary(context)
    BuildRewards(context, "dungeon", "Dungeon", context.season.dungeon)
    BuildRewards(context, "delve", "Delve", context.season.delve)
end
