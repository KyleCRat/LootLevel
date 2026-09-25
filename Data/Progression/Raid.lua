local ADDON_NAME, NS = ...

local Progression = NS.Progression
local Add = Progression.Add

-- These lanes belong to the Midnight table design, not to individual seasons.
local LANES = {
    adventurer = { rank = "f", name = "g", craft = "h", reagent = "i" },
    veteran = { rank = "c", name = "d", drop = "b", craft = "i", reagent = "h" },
    champion = { rank = "f", name = "g", drop = "e", craft = "h", reagent = "i" },
    hero = { rank = "c", name = "d", drop = "b", craft = "i", reagent = "h" },
    myth = { rank = "f", name = "g", drop = "e", craft = "h", reagent = "i" },
}

local REWARDS = {
    rare = { label = "Rare", font = { size = 10 } },
    vault = { label = "GV", split = true },
    sporefall = { label = "SF", split = true },
    forged = { label = "VF" },
}

local function BuildTrack(context, key, definition)
    local track = Progression.Track(key)
    local lane = LANES[key]
    local group = "track." .. key
    local tooltip = { title = track.name .. " Upgrade Track" }
    for rank, ilvl in ipairs(definition.levels) do
        Add(context, "raid", group, track.bg, {
            col = lane.rank, ilvl = ilvl, text = ("%d/%d"):format(rank, #definition.levels), tooltip = tooltip,
        })
    end
    for _, extra in ipairs(definition.extraRanks or {}) do
        Add(context, "raid", group, track.bg, {
            col = lane.rank, ilvl = extra.ilvl, text = ("%d/%d"):format(extra.rank, #definition.levels), tooltip = extra.tooltip or tooltip,
        })
    end
    Add(context, "raid", group, track.bg, {
        col = lane.name, ilvl = definition.levels[1],
        toIlvl = definition.labelThrough or definition.levels[#definition.levels],
        text = track.name, vertical = true,
    })
    for _, marker in ipairs(definition.markers or {}) do
        Add(context, "raid", group, track.bg, {
            col = lane.name, ilvl = marker.ilvl, text = marker.label, tooltip = marker.tooltip,
        })
    end
end

local function BuildRaidRewards(context, raid)
    local sourceTrack = Progression.Track(raid.track)
    local lane = assert(LANES[raid.track], "LootLevel progression: unknown raid track")
    local col = assert(lane.drop, "LootLevel progression: missing raid reward lane")
    for _, reward in ipairs(raid.rewards or {}) do
        local style = assert(REWARDS[reward.kind], "LootLevel progression: unknown raid reward " .. tostring(reward.kind))
        local bg
        if style.split then
            assert(reward.track, "LootLevel progression: raid " .. reward.kind .. " rewards must specify their reward track")
            Progression.Rank(context, reward)
            local rewardTrack = Progression.Track(reward.track)
            bg = { topLeft = sourceTrack.bg, bottomRight = rewardTrack.bg }
        end
        Add(context, "raid", "track." .. raid.track, sourceTrack.bg, {
            col = col, ilvl = reward.ilvl, bg = bg,
            text = reward.label or style.label, tooltip = reward.tooltip, font = style.font,
        })
    end
end

local function BuildRaidDrops(context, raid)
    local track = Progression.Track(raid.track)
    local lane = assert(LANES[raid.track], "LootLevel progression: unknown raid track")
    local group = "track." .. raid.track
    local first, last = math.huge, 0
    for _, ilvl in ipairs(raid.drops) do
        first = math.min(first, ilvl)
        last = math.max(last, ilvl)
    end
    assert(last > 0, "LootLevel progression: raid drops must list at least one item level")

    Add(context, "raid", group, track.bg, {
        col = lane.drop, ilvl = first, toIlvl = last,
        text = raid.difficulty, vertical = true, tooltip = raid.tooltip,
    })

    if raid.lastBosses then
        local reward = raid.lastBosses
        Add(context, "raid", group, track.bg, {
            col = "c", toCol = "d", ilvl = reward.ilvl, text = reward.label, tooltip = reward.tooltip,
        })
    end
end

local function BuildCraft(context, craft)
    local track = Progression.Track(craft.track)
    local lane = assert(LANES[craft.track], "LootLevel progression: unknown crafting track")
    local group = "craft." .. craft.track
    for quality, ilvl in ipairs(craft.levels) do
        Add(context, "raid", group, track.bg, {
            col = lane.craft, ilvl = ilvl, atlas = "Professions-Icon-Quality-Tier" .. quality,
            tooltip = { title = craft.tooltip .. " R" .. quality },
        })
    end
    if craft.reagent then
        local reagent = craft.reagent
        Add(context, "raid", group, track.bg, {
            col = lane.reagent, ilvl = reagent.from, toIlvl = reagent.to, text = reagent.label, vertical = true,
        })
    end
    if craft.forged then
        local forged = craft.forged
        if forged.bonus then
            Add(context, "raid", group, track.bg, {
                col = lane.craft, ilvl = forged.ilvl, text = "+" .. forged.bonus, tooltip = forged.tooltip,
            })
            Add(context, "raid", group, track.bg, {
                col = lane.reagent, ilvl = forged.ilvl, text = "VF", tooltip = forged.tooltip,
            })
        else
            Add(context, "raid", group, track.bg, {
                col = "h", toCol = "i", ilvl = forged.ilvl, text = "VF", tooltip = forged.tooltip,
            })
        end
    end
end

function Progression.BuildRaid(context)
    for _, key in ipairs(Progression.trackOrder) do
        local track = context.season.tracks[key]
        if track then BuildTrack(context, key, track) end
    end
    for _, raid in ipairs(context.season.raids or {}) do
        BuildRaidDrops(context, raid)
        BuildRaidRewards(context, raid)
    end
    for _, craft in ipairs(context.season.crafting or {}) do
        BuildCraft(context, craft)
    end
end
