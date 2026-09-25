# Data-driven Midnight seasons

Edit `Data/Layers/MidnightDD/Season1.lua` or `Season2.lua`, then reload the UI.
Season 1 retains the manual Midnight loot values. Season 2 incorporates the reviewed
collector findings in `COLLECTOR_PLAN.md`, with the evidence limits below. The
`Midnight DD` tab defaults to Season 2 and contains its own comparison layers.

Season definitions contain item levels, tracks, and activity labels. They never
need row/column coordinates, colors, `Cell`, `MergedCell`, or `Block` calls.

## Inputs

- `tracks`: ordered `levels` generate upgrade ranks and the vertical track label.
  `extraRanks = { { ilvl = 344, rank = 9 } }` adds exceptional rewards without
  changing the denominator. It does not imply a vendor upgrade beyond rank 6.
  An extra rank can supply a `tooltip` to distinguish crafted equivalents.
  `labelThrough` extends the label to an item level;
  `markers` adds labels next to exceptional ranks.
- `raids`: `difficulty`, `track`, and `drops` generate a difficulty span. `rewards`
  accept `kind = "rare"`, `"vault"`, `"sporefall"`, or `"forged"` with an `ilvl`
  and optional `tooltip`/`label`. Raid rewards belong to their source content's
  block and difficulty column: Normal/Champion GV and SF stay in the Champion
  block. Vault and Sporefall rewards must specify their actual reward `track`,
  usually the next track up; this controls rank validation and the bottom-right
  background color, not placement. The top-left background color is the source
  track's color. Same-track rewards remain a solid color.
  Coincident rewards can share a record with a combined label and tooltip.
  `lastBosses` provides a separate final-boss label.
- `crafting`: ordered `levels` generate quality icons. `reagent` contains a
  `label`, `from`, and `to` item level. `forged` specifies its item level and
  tooltip, with an optional numeric item-level `bonus`.
- `activities`: source keys (`prey`, `delve`, `map`, `delveVault`, `dungeon`,
  `dungeonVault`) select columns. Each entry provides `ilvl`, `track`, and `label`.
- `dungeon`: each `label` (`N`, `H`, `M`, `+2`, etc.) owns its `loot`, `vault`,
  and `crest`. Rows sort by difficulty/key level, regardless of declaration order.
- `delve`: each numeric `level` owns its `loot`, `vault`, and `crest`.
- `scrollTo`: the item level to show when activating the season.

Tooltip bodies use `tooltip = { title = "...", description = "..." }`.
Use `\n` within `description` for additional lines. Lettered body fields are
no longer supported; title-only tooltips retain the existing cell-detail fallback.

For example, a dungeon record is:

```lua
{
    label = "+4",
    loot = { ilvl = 298, track = "champion" },
    vault = { ilvl = 308, track = "hero" },
    crest = { track = "hero", amount = 10 },
},
```

The builder derives both displayed ranks from the season's track levels. Reward
objects can supply an explicit `rank` for exceptions. Season 1 retains the manual
tables' inconsistent rank overrides for comparison. Season 2 no longer needs
them: its heroic dungeon Vault is Veteran 4/6 at 289, and level 7+ delve loot
is Champion 2/6 at 295. These are inherited source-to-rank mappings, not new
collector observations. Season 2's corresponding activity summaries agree with
the detailed tables.

Track keys are `adventurer`, `veteran`, `champion`, `hero`, `myth`, or `untracked`.
An untracked reward displays `-` for its rank. Crests use a track and optional
`amount`; do not use `untracked` for crests.

## Season 2 Evidence

The five ordinary six-rank curves match the recorded 12817-12854 bonus probes,
cross-checked against the journal/vendor observations in `COLLECTOR_PLAN.md`.
The Myth 9/6 exception is 344. Hero 8/6 at 328 and Myth 8/6 at 340 are upcoming
Venomforging (`VF`) rewards, per the user's season-mechanic correction. Their
item levels match the 12848 and 12856 probes; those probes alone do not prove
availability. Crafted VF is 337, equivalent to Myth 7/6 and one upgrade rank
below obtained Myth VF. This uses the 12855 rank/ilvl mapping, with its crafting
availability supplied by the user. The 7/6 comparison marker is labeled as a
crafted equivalent. None of these is an ordinary upgrade beyond rank 6. Other
over-cap probes are not imported as obtainable upgrades. The raw collector
results remain unchanged.

Applied source observations include Normal dungeon 259 (untracked), Heroic
dungeon 276 (Adventurer 4/6), raid drop ranges, Heroic raid Vault 318, Mythic raid
Vault 344, and world Vault Tier 8 at 305. Dungeon Vault brackets use the
next-increase observations: +4-5 = 308, +6 = 311, +7-9 = 315, +10-12 = 318.
The anomalous +8 result from the older reward-level API is not used.

These observations do not certify every item, raid Vault slot, or activity tier.
The low-end dungeon Vault baseline, most end-of-run/world rewards, crafting
quality/reagent mappings, crest counts, and raid rarity/boss-count labels retain
their previous assumptions. Their rank-based item levels follow the corrected
curves. Activity summaries have been aligned with the detailed reward tables;
no fresh loot-source mapping is inferred from a successful synthetic item link.
The normal dungeon observation does not establish an Explorer curve, and the
unassigned 12857-12904 family is not imported as Season 2 data.

## Ownership

`Model.lua` owns track colors, rank lookup, the shared item-level axis, validation,
and registration through the existing data API. `Raid.lua` owns Midnight's raid
and crafting column arrangement. `Activities.lua` owns summary columns and the
two difficulty-based reward tables. Other table designs can have their own
builders without adding domain-specific behavior to the renderer.

`Data/Tables/MidnightDD.lua` copies only table presentation and border rules from
Midnight into separate table IDs. `Data/Layouts.lua` registers both concrete
layouts with the same arrangement. Separate layout IDs prevent the manual and
data-driven seasons from rendering together or sharing scroll state.

`Data/Layers/MidnightDD/Build.lua` compiles the two seasons once, out of combat,
before initial UI creation. Its axis estimates missing progression steps using
`220 + ceil(step * 3.25)`, retaining unpopulated steps. Declared item levels own
their nearest progression step and remain exact: Myth 8/6 at 340 replaces the
estimated 341 row instead of displaying both. Raid and activity share this
sorted axis; dungeon and delve rows come from their own labels.
Generated data uses the existing span, border, layer, and render-cache paths.

## Split Cell Backgrounds

The renderer also accepts `bg = { topLeft = "blue", bottomRight = "yellow" }`
on ordinary or merged cells and blocks. This remains one background style, so
the most-specific definition wins as before. `UI/CellBackgrounds.lua` owns the
two native clipping masks and recalculates their geometry from the cell's actual
size after scaling. Both halves inherit the cell's inactive-layer opacity.
Equal resolved corner colors use one ordinary texture instead, with no masks
or diagonal seam. Table scrolling uses the body's explicit size, so oversized
mask regions cannot extend the scroll range beyond the last row.
The progression builder derives these colors from the source and reward tracks;
season definitions do not supply rendering colors.
