# LootLevel Collector

## Purpose and Evidence

Collect season data from the game without relying on external gearing guides or
owning an item at every upgrade rank. Keep these evidence classes separate:

- **Observed reward:** a real journal, inventory, upgrade-vendor, or Vault result.
- **Constructed probe:** the client's interpretation of a generated item link.
- **Inference:** a proposed pattern, season assignment, or reward mapping.

A successfully decoded link is not server certification that the variant can be
obtained. Loading item data also does not validate every bonus combination:
Blizzard's Item mixin registers load callbacks by base item ID. Do not promote
synthetic variants into obtainable rewards or overwrite the reference tables
automatically.

Preserve historical season track membership separately from current API state.
A later season can remove an item's track/ranks while retaining its ilvl; a
new nil/0/0 result must not erase a previously established seasonal mapping.

The observations below came from the user's Midnight Season 2 investigation.
The full runtime build was not included in the original dumps. Do not attach a
build to those observations by assuming it matches the local source export.
New captures record the actual client version, build, interface, project, locale,
time, and seed. A project ID identifies a client family, not a PTR/live channel.

API research uses the local Blizzard export:
`D:/World of Warcraft/_retail_/BlizzardInterfaceCode/Interface/AddOns/`.
The inspected snapshot was `03b6f28`, Retail `12.1.0.69497`. It describes API
contracts, not the build of the user's historical observations. Consult the
local export before external sources and explicitly record build mismatches.

## Implemented: Bonus Batch Runner

Open the native collector window with `/ll collector` or `/ll probe`.

- Default seed: item `271092`, level `90`, specialization `262`, context `6`,
  bonus `3524`, modifier `28:7362` (the verified Myth 9/6 journal preview).
- Default batch: 5,000 consecutive bonus IDs, beginning at zero. Batch sizes
  from 1 to 50,000 are supported, including a single 15,000-ID comparison run.
  Existing saved batch sizes are preserved. IDs are bounded to
  nonnegative signed 32-bit integers; this is an input bound, not a claim that
  every ID exists or that the client publishes a maximum allocated bonus ID.
- Each probe replaces the seed's **entire bonus list with one candidate** and
  retains its remaining fields. This is not a scan of combinations of bonuses.
- One ticker processes at most five IDs per 0.05 seconds, with a cooperative
  three-millisecond work budget per tick. A single native call cannot be
  preempted. Progress refreshes are throttled, and the visible log retains only
  the last 100 rows. All rows remain in the capture.
- Every ID is recorded, including nil/no-track, rank-zero, over-cap, missing-data,
  and error results. Errors are isolated per ID. Missing data is not treated as
  proof of an invalid bonus.
- Item data is loaded asynchronously before scanning. A failed load or timeout
  pauses the batch. Cache loss, combat, closing the window, and logout/reload
  also pause it. Nothing resumes or advances to another batch automatically.
- Resume keeps the same seed and next ID. A different client version, build,
  project, or locale requires a new batch rather than mixing results.
- Next Batch starts immediately after the selected completed range. Run Batch
  permits an explicitly entered range. Overlapping captures are allowed and
  preserved for comparison.
- `LootLevelCollectorDB` stores settings, progress, metadata, and up to 20
  captures independently from `LootLevelDB`. Full history requires explicitly
  exporting/deleting a batch; old data is never silently evicted. As with other
  SavedVariables, persistence to disk happens at normal logout/reload, not on
  every tick and not reliably after a client crash.
- Export opens a native selectable text window. The export is tab-separated,
  with `#` metadata lines, one column-header line, and one result line per probed
  ID (15,013 logical lines for a complete 15,000-ID batch). Select All and the
  normal copy shortcut copy the snapshot. The collector does not access the
  system clipboard itself.
- Export columns: `bonus_id`, `ilvl`, `track`, `rank`, `max_rank`, `track_id`,
  `status`, `error`. Blank fields represent unavailable values. Tabs/newlines in
  individual fields are normalized; error text is bounded to 512 characters.

The runner does not yet collect journal/Vault/vendor observations automatically,
classify a probe's season, or infer obtainable reward tables. It does not depend
on the temporary `/run` helpers used during this investigation.

## Captured Scan: 0-14999

The first capture, now saved as `export_271092.log`, originally consisted of
three complete batches: 0-4999, 5000-9999, and 10000-14999. The current file has
been consolidated; see the metadata caveat in the Sporeheart comparison below.
ID 15000 is not included; it is the next start ID.
All three used client **12.1.0.69933**, build date September 18, 2026, interface
120100, project 1, locale enUS, and the same default journal seed. Each recorded
the seed baseline as `344 Myth 9/6`, track string ID 978.

Validation of the captured rows:

- Exactly 15,000 rows, in ascending ID order, with no gaps or duplicates.
- All rows have status `ok`; no reported errors or missing ilvl data.
- 205 results have track names: 99 with positive ranks and 106 with rank 0.
- Another 44 results have positive ranks but no track name. Neither a name nor
  a rank alone is sufficient to identify a current season reward.
- 12 results exceed a positive reported cap: the ten known 7/6 and 8/6 results,
  plus the two Myth 9/6 results below.

### Myth 9/6 Found Outside the Contiguous Block

Both **3524** and **13848** return `344 Myth 9/6` with track string ID 978.
They are the only 9/6 results in this captured range. The new probe is:

```text
item:271092::::::::90:262::6:1:13848:1:28:7362:::::
```

This establishes a single candidate bonus, other than the journal's 3524,
that reproduces the observed result on this seed. The independent equipped-item
and stripped-link checks below also reproduce it without the journal context
or modifiers. These captures do not prove which internal bonuses 3524 resolves
to, or establish identical behavior on every item or build.

The five ordinary six-rank families occupy eight-ID blocks in 12817-12856.
Their first six entries reproduce the documented ranks 1-6; the final two
entries decode ranks 7/6 and 8/6 beyond ordinary upgrades; Hero/Myth 8/6 are
upcoming Venomforging rewards (see the over-cap notes below). Rank 9/6 is
not the next ID: 12857 begins the different Explorer family, while 13848 is
elsewhere. Nearby 13847 and 13849 do not return named upgrade tracks.

### Independent Equipped-Item Check

A subsequent user-provided single-ID capture tested **13848** on equipped item
**271486**, on the same client build 12.1.0.69933 and locale enUS. The original
item was `334 Myth 6/6`, context **95**, with modifier **64:271876**. The capture
started and finished at Unix time 1790301810, with zero errors or missing data.

```text
Seed:  item:271486:7987:::::::90:262::95:6:13334:6652:13846:13690:13698:12854:1:64:271876:::::
Probe: item:271486:7987:::::::90:262::95:1:13848:1:64:271876:::::
```

The runner replaced all six original bonuses, including 12854, with 13848.
It returned **344 Myth 9/6**, track string ID **978**, status `ok`.

| Item | Context | Retained Modifier | Result with 13848 |
| ---: | ---: | --- | --- |
| 271092 | 6 | 28:7362 | 344 Myth 9/6, track ID 978 |
| 271486 | 95 | 64:271876 | 344 Myth 9/6, track ID 978 |

Thus 13848 reproduces the same rank/ilvl on two distinct items and does not
require the journal's context 6 or modifier 28:7362. This is stronger evidence
for an explicit Myth 9/6 bonus than the original journal-only probe. It is
still a constructed variant: it does not make the equipped item obtainable at
that rank, establish a ninth vendor upgrade, or prove behavior on every item.
Both of these links retain a context and a modifier; the follow-up below removes
them from the second item.

### Context and Modifier Isolation Complete

A follow-up user-provided capture on build **12.1.0.69933**, locale enUS, tested
item **271486** with context **0**, zero original bonuses, and zero modifiers.
The enchant 7987, link level 90, and specialization 262 were retained. The
capture started and finished at Unix time 1790302161, with zero errors or
missing data.

```text
Seed:  item:271486:7987:::::::90:262::0:0:0:::::
Probe: item:271486:7987:::::::90:262::0:1:13848:0:::::
```

| Variant | ilvl | Track | Rank | Maximum | Track ID |
| --- | ---: | --- | ---: | ---: | ---: |
| Stripped seed, no bonuses | 219 | none | 0 | 0 | none |
| Same seed with only 13848 | 344 | Myth | 9 | 6 | 978 |

This confirms that **13848 alone is sufficient to produce 344 Myth 9/6 on this
item/build without a nonzero context or item modifiers**. The result is not
inherited from the seed's original Myth 6 bonus or from the journal preview's
context. Combined with the two-item comparison, this completes the planned
cross-item and context/modifier isolation checks. It remains a synthetic
variant, not proof that every item can drop at this rank or be upgraded to it.

### Other Patterns

- The entire higher-ilvl 12857-12904 family matches the earlier Training Rod
  probes on this second item. Its season and obtainability remain unassigned.
- Track string IDs recur across families: Explorer 970, Adventurer 971,
  Veteran 972, Champion 973, Hero 974, and Myth 978. They identify the returned
  track label, not a unique season or ilvl curve.
- Several lower-ilvl named families return rank/cap 0/0, including
  12265-12297, 12350-12361, and 12769-12808, with gaps and late additions.
  Do not reinterpret their zero ranks as confirmed active upgrade steps.
- 12534-12541 return a literal `Test` track (ID 1154), ranks 1-8/8. Seven
  retain this item's base ilvl 219; 12537 returns 170. Similarly, several
  other ranked results leave ilvl unchanged. Rank decoding and an obtainable
  reward curve must remain separate concepts.
- 1597 and 5970 also return ilvl 344, but no track and rank/cap 0/0. Matching
  ilvl alone does not identify the Myth 9/6 encoding.
- After 14048, the remaining captured IDs return base ilvl 219 with no track
  and rank/cap 0/0. This does not establish that they are unallocated: the
  collector does not inspect every possible effect of a bonus, and some
  bonuses may need other items or combinations.

## Sporeheart Comparison: 0-14999

Compared `export_268291.log` against `export_271092.log`, both on client
**12.1.0.69933**, interface 120100, project 1, and locale enUS. The Sporeheart
capture used `item:268291::::::::90:262::6:1:3524::::::`, with baseline
`298`, no track, and rank/cap 0/0. It ran from Unix time 1790304029 to
1790304189: **15,000 IDs in one batch, completing in 160 seconds**.

Both files contain exactly 15,000 consecutive rows, IDs 0-14999, with no gaps,
duplicates, or non-`ok` rows. Comparing ilvl, track, current/max ranks, track ID,
status, and error fields yielded **14,995 identical results and five changes**:

| Bonus | Item 271092 | Sporeheart 268291 | Changed Fields |
| ---: | --- | --- | --- |
| 3524 | 344 Myth 9/6, track ID 978 | 298, no track, 0/0 | ilvl, track, rank, cap, track ID |
| 12403 | 197, no track, 0/0 | 80, no track, 0/0 | ilvl only |
| 12405 | 197, no track, 0/0 | 133, no track, 0/0 | ilvl only |
| 12406 | 197, no track, 0/0 | 133, no track, 0/0 | ilvl only |
| 12407 | 197, no track, 0/0 | 165, no track, 0/0 | ilvl only |

Consequences for the investigation:

- 3524 is the only ID whose reported track metadata changes between these
  captures. The four other differences have unknown bonus semantics; do not
  classify them from their ilvls alone.
- The 12817-12856 six-rank families and 12857-12904 higher-ilvl family are
  identical on both seeds. Using a Season 1 item does not select a Season 1
  interpretation of every explicit progression bonus.
- 13848 still returns **344 Myth 9/6** on Sporeheart. This is a third item
  reproducing that explicit bonus, not an obtainable Sporeheart reward.
- The older Myth family 12801-12808 still returns 272-295 with rank/cap 0/0.
  No additional Explorer family or restored 298 Myth 9/6 metadata appeared.
- Both seeds return 219 for bonus 0, and many identical rows have no visible
  effect in the fields collected. The high agreement rate is not proof that
  all these IDs are valid or that their behavior is universal on other items.
- These seeds differ in item ID and trailing modifiers: only 271092 retains
  28:7362. The comparison establishes full-seed differences, not which changed
  field causes each difference. Hotfix/build provenance must remain attached.

Metadata caveat: the consolidated `export_271092.log` now has a single header
whose range remains 0-4999, while its declared row count/next ID and actual rows
cover 0-14999. Its timestamps describe the original first batch, not the whole
combined scan. Comparison used verified row IDs rather than silently trusting
that range. The Sporeheart header correctly describes its single 15,000-ID
batch. Neither raw file was modified during analysis.

## Verified Ordinary Track Values

These are **client-returned constructed-probe values**, cross-checked against
the journal/vendor observations listed below. They are not guessed +3/+4 steps.

| Track | 1/6 | 2/6 | 3/6 | 4/6 | 5/6 | 6/6 | Bonus IDs for 1-6 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Adventurer | 266 | 269 | 272 | 276 | 279 | 282 | 12817-12822 |
| Veteran | 279 | 282 | 285 | 289 | 292 | 295 | 12825-12830 |
| Champion | 292 | 295 | 298 | 302 | 305 | 308 | 12833-12838 |
| Hero | 305 | 308 | 311 | 315 | 318 | 321 | 12841-12846 |
| Myth | 318 | 321 | 324 | 328 | 331 | 334 | 12849-12854 |

Observed checks:

- Normal dungeon journal: Polished Lightwood Channeler (273778) at 259, no
  track, rank/cap 0/0. This is a source-reward observation, not an Explorer rank.
- Heroic dungeon journal: Adventurer 4/6 at 276.
- Raid journal: Veteran 1-4 at 279/282/285/289; Champion 1-4 at
  292/295/298/302; Hero 1-4 at 305/308/311/315.
- Upgrade vendor: Hero 3-6 at 311/315/318/321.
- Mythic raid journal: Myth 1/6 at 318, 2/6 at 321, 3/6 at 324, and 9/6 at 344.
- Equipped weapon: Myth 6/6 at 334.
- All six Myth bonus probes produced identical rank/ilvl pairs on both item
  `271092` and Nibbles' Training Rod (`251123`). This cross-item verification
  applies to that family; it does not establish that every other bonus ID has
  item-independent effects.

### Season 2 Track Scope

The user's further research suggests Midnight Season 2 may not have an Explorer
upgrade track. This is consistent with our observations: the five ordinary
families above are confirmed, while the tested sub-Adventurer rewards are
untracked. Explorer-labeled bonuses elsewhere in the scan do not establish an
active Season 2 track.

Use Adventurer through Myth as the working Season 2 track scope. Their ordinary
rank curves are captured; do not treat an Explorer curve as a required missing
data set or a blocker. This is a working scope, not proof of exhaustive absence.
Revisit it if a current-season source returns Explorer metadata. Continue to
collect untracked reward ilvls without inventing track names or ranks.

### Myth 7-9/6 Reference

| Myth Rank | Midnight Season 1 ilvl | Midnight Season 2 ilvl | Season 2 Bonus ID |
| --- | --- | ---: | ---: |
| 7/6 | 292 (historical rank inferred) | 337 | 12855 |
| 8/6 | 295 (historical rank inferred) | 340 | 12856 |
| 9/6 | 298 (historical rank user-confirmed) | 344 | 13848 |

Season 2 ranks and ilvls are explicit probe results on build 12.1.0.69933,
matching in both full item exports. Per the user's clarification, crafted
**Venomforging (VF)** gear is 337, equivalent to Myth 7/6 and one upgrade rank
below obtained Myth 8/6 gear at 340. Both are upcoming VF rewards;
Myth 9/6 is independently journal-observed. None is an ordinary seventh,
eighth, or ninth upgrade-vendor step.

Season 1 ilvls 292 and 295 were directly returned by bonuses 12807 and 12808,
but the current API labels both `Myth 0/0`. Their historical 7/6 and 8/6 rank
assignments follow their positions in the older Myth family and are not
current API-confirmed ranks. Season 1's 298 Myth 9/6 is historically confirmed
by the user; Rotmire's Sporeheart now returns 298 with no track and rank/cap
0/0. Do not use the Season 2 bonus IDs as encodings for these Season 1 levels.

### Over-Cap Probes and the 9/6 Exception

Correction: the user clarified that Hero and Myth 8/6 become obtainable later
this season through **Venomforging (VF)**. Represent Hero 8/6 at 328 and Myth
8/6 at 340 as upcoming mechanic rewards, not ordinary vendor upgrade steps.
Crafted VF is 337 (Myth 7/6 equivalent), one rank below obtained Myth VF.
The other over-cap probes below remain excluded from obtainable upgrades.
Preserve all raw decoded values; successful probes alone do not establish
availability:

| Track | Bonus 7/6 | ilvl | Bonus 8/6 | ilvl |
| --- | ---: | ---: | ---: | ---: |
| Adventurer | 12823 | 285 | 12824 | 289 |
| Veteran | 12831 | 298 | 12832 | 302 |
| Champion | 12839 | 311 | 12840 | 315 |
| Hero | 12847 | 324 | 12848 | 328 |
| Myth | 12855 | 337 | 12856 | 340 |

Myth **9/6 at 344** is independently journal-observed. Do not clamp its rank to
6 or discard it just because the reported maximum is 6. Do not interpret it as
a ninth normal vendor upgrade, either.

The same item ID (`271092`) demonstrated both variants:

```text
Owned:   item:271092:8689:::::::90:262::95:3:6652:13334:12854::::::
Journal: item:271092::::::::90:262::6:1:3524:1:28:7362:::::
```

On the owned link, removing either `6652` or `13334` left `334 Myth 6/6`.
Removing `12854` yielded `219`, no track, and rank/cap `0/0`.

Holding the journal's item, context, and modifier fixed and changing only its
bonus produced:

| Bonus | ilvl | Track | Rank | Maximum |
| ---: | ---: | --- | ---: | ---: |
| 3524 | 344 | Myth | 9 | 6 |
| 12854 | 334 | Myth | 6 | 6 |
| 13848 | 344 | Myth | 9 | 6 |

Operationally, `3524` resolves the source preview for this item/context. The
explicit `12849-12856` family is not exhaustive of all Myth variants. The broad
scan found `13848` reproducing 9/6 on this seed; see the captured-scan section
for its provenance and completed context checks. The API still does not expose
the internal resolution of 3524. `12857` is not a consecutive Myth 9 bonus.

## Additional Unassigned Families

On the Training Rod probe, `12857-12904` exposed a different family. It is NOT
confirmed as a particular future season, released tier, or obtainable set:

| Name | Bonus IDs | Returned ilvls in ID order | Rank/cap |
| --- | --- | --- | --- |
| Explorer | 12857-12864 | 323, 326, 330, 333, 336, 339, 343, 346 | 0/0 |
| Adventurer | 12865-12872 | 336, 339, 343, 346, 349, 352, 356, 359 | 1-8/8 |
| Veteran | 12873-12880 | 349, 352, 356, 359, 362, 365, 369, 372 | 1-8/8 |
| Champion | 12881-12888 | 362, 365, 369, 372, 375, 378, 382, 385 | 1-8/8 |
| Hero | 12889-12896 | 375, 378, 382, 385, 388, 391, 395, 398 | 1-8/8 |
| Myth | 12897-12904 | 388, 391, 395, 398, 401, 404, 408, 411 | 1-8/8 |

Earlier probes also returned `12800 -> 282 Hero 0/0` and `12801-12808 -> Myth
0/0` at 272/276/279/282/285/289/292/295. `12809-12816` returned base ilvl 28
with no track and rank/cap 0/0. A track name alone is not evidence of an active
upgrade track. Keep these results for pattern analysis rather than silently
discarding them or assigning them a season.

Broad scans must be grouped by build and full seed/context. Matching adjacent
IDs, names, or apparently sensible ilvls is not enough to identify a season.
Contiguous gaps and an empty region do not prove that later IDs are unused.

## Item Links and API Findings

### Base Item Versus Variant

Nibbles' Training Rod's heroic journal link was:

```text
item:251123::::::::90:262::2:1:3524:1:28:3024:::::
```

It returned `276 Adventurer 4/6`. Removing its only bonus (`3524`) returned
`28`, no track, and rank/cap 0/0. `C_Item.GetItemInfo` did not expand that
journal link into explicit resolved bonuses.

Querying `C_Item.GetItemInfo(251123)` returned a base ilvl of 28 and a bare link.
The user reported the normal dungeon reward at 214. Neither value contradicts
the heroic variant at 276. The link's `90:262` means level 90 and specialization
ID 262 (Elemental Shaman), not ilvl. Item ID alone does not identify a variant.

### Normal Dungeon Baseline, Not an Explorer Rank

The user queried a Normal Midnight dungeon journal entry for **Polished
Lightwood Channeler**, item **273778**, and received:

```text
item:273778::::::::90:262::1:1:3524:1:28:3022:::::
259 nil 0 0
```

This is context 1, bonus 3524, and modifier 28:3022. The actual ilvl is **259**;
the upgrade API returned no track name and current/max ranks **0/0**. The chat
printout did not include a runtime build, so do not automatically assign it
the preceding collector capture's build metadata.

Compared with the recorded Adventurer 1/6 value of 266, this reward is seven
item levels lower. It is a useful observed Normal-dungeon reward, but does not
identify Explorer 1/6, prove Explorer has six upgrade ranks, or establish the
reward level for every Normal dungeon. Do not infer a complete Explorer curve
from this numerical proximity.

The earlier Normal reward report of 214 concerned Nibbles' Training Rod (251123),
not this item, and likewise lacked recorded runtime build metadata. Preserve
both observations rather than treating them as interchangeable source data or
assuming either is incorrect. A same-build, cross-dungeon comparison remains
useful for establishing source rewards, independent of whether an Explorer
track exists. Explorer is not a required Season 2 baseline under the working
track scope above.

### Season 1 Myth 9/6 After the Season Transition

The user queried **Rotmire's Sporeheart**, item **268291**, from Sporefall:

```text
item:268291::::::::90:262::6:1:3524::::::
298 nil 0 0
```

The user confirms that this item was **298 Myth 9/6 while Season 1 was current**,
and that its Myth track was removed with the release of Season 2. It now shows
only ilvl 298 in game, consistent with this query. This establishes a historical
Season 1 mapping and a distinct current API state, not a contradiction. The
historical runtime build was not supplied.

A subsequent single-ID capture confirmed **3524 -> 298, no track, 0/0** on this
exact Sporeheart seed, with client **12.1.0.69933**, locale enUS, at Unix time
1790303606. Both the unchanged seed baseline and the probe gave this result;
the capture completed with zero errors and missing data.

The same bonus 3524 on the original item 271092/context-6/modifier-28:7362 seed
returned **344 Myth 9/6 on the same build**. Results therefore belong to the full
seed and build, not a universal bonus-ID lookup, and not item ID alone. Compare
bonus IDs across the two exports without discarding their distinct context and
modifier fields. The completed Sporeheart run covers 0-14999 in one 15,000-ID
batch using `item:268291::::::::90:262::6:1:3524::::::`; see the comparison above
for all five differences from the original seed.

The original 0-14999 scan, on item 271092 and build 69933, does contain ilvl 298
with no track and rank/cap 0/0 at bonuses **1551, 5924, 13654, 13703, and 13786**.
It also contains 298 on the newer Veteran 7/6 and Champion 3/6 probes. None of
these results is labeled Myth 9/6. Matching ilvl does not prove which bonus
produces the Sporeheart variant or which internal bonus 3524 resolves to.

Collector implications:

- Keep the observed reward ilvl even when upgrade metadata disappears. The
  existing runner retains these untracked rows; this is not a filtered-out row.
- Capture season/build-specific track and rank information while it is active.
  The live API cannot be relied on to reconstruct all historical season data.
- Preserve the Season 1 298 Myth 9/6 mapping with its historical provenance;
  record the newer nil/0/0 observation alongside it instead of overwriting it.
- Do not assign a former track to every untracked item from its ilvl alone.
  Historical evidence is required for that association.

### Item and Vendor APIs

- `C_Item.GetItemUpgradeInfo(link)` supplies the track, current/max ranks, and
  track string ID. `maxItemLevel` can be zero; do not depend on it for a curve.
- Use the **first** result of `C_Item.GetDetailedItemLevelInfo(link)` for the
  actual ilvl. The observed Myth 6 weapon returned `334, false, 219`; the sparse
  level 219 is not its actual ilvl.
- `C_ItemUpgrade.GetItemUpgradeItemInfo()` describes the item currently selected
  at the upgrade vendor, not an arbitrary supplied link. It returned nothing
  before an item was selected.
- The vendor's `upgradeLevelInfos` starts at the current rank. Its increments
  are relative to the current ilvl, not cumulative differences between rows.
  Hero 3/6 at 311 gave increments 0/4/7/10 for ranks 3/4/5/6.
- The vendor reported min/max ilvls 305/321 for that Hero item. Currency 3445
  costs were discounted to zero; those are NOT ordinary undiscounted costs.
- Journal loot rows are the current filtered list, not stable item identifiers.
  Trophies/cosmetics can return nil track, 0/0, and ilvl 1. Retain item identity,
  context, encounter, rarity flags, difficulty, optional displaySeasonID, and
  exact link in a future journal collector. Wait for item data asynchronously.

### Dungeon and Vault APIs

`C_MythicPlus.GetRewardLevelForDifficultyLevel` was inconsistent in this session:

- +2/+3 -> 305; +4/+5 -> 308; +6 -> 311; +7 -> 315; +8 -> 305;
  +10/+12 -> 318; +1 -> 279; +0 -> 0.
- Its second return was zero throughout. Do not treat those zeros as verified
  end-of-run reward levels or the +8 anomaly as a real progression rule.
- The internal reason for that discrepancy was not established.

The current Vault UI uses
`C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)` and reads ilvl
from the resulting link. These are actual current-character activity previews,
not a complete universal reward table. Its upgrade preview is not the selected
item's next upgrade-vendor rank.

For the observed dungeon `activityTierID=256`,
`C_WeeklyRewards.GetNextActivitiesIncrease(256, level)` returned these next
thresholds:

| Input levels | Next level | Reward ilvl |
| --- | ---: | ---: |
| 2, 3 | 4 | 308 |
| 4, 5 | 6 | 311 |
| 6 | 7 | 315 |
| 7, 8, 9 | 10 | 318 |
| 10, 11, 12 | no result | not supplied |

Together with the current +12 Vault link at 318, this supports observed brackets
+4-5 = 308, +6 = 311, +7-9 = 315, and +10-12 = 318. The low-end baseline was
not established by that path. An input of 1 also returned false. False therefore
does not universally mean the reward cap; it can also be unavailable data.

For world activities, every tested input from 0 through 12 returned false from
the next-increase query. However, loading the example item for observed activity
ID 207 resolved **Preyhunter's Signet at 305**, confirming the displayed world
Tier 8 reward. Later tests below also confirmed a difficulty-1 world preview
at 279; intermediate Delve rewards have not been verified by actual previews.

The character's raid Vault previews showed two Mythic slots at 344 and a Heroic
slot at 318. These are observations of that character's preview, not a complete
raid Vault mapping. Do not hardcode activity ID 207 or tier ID 256 as universal
collector constants; acquire them from the activity records.

### Zero-Progress Vault Investigation

The follow-up runtime captures explicitly reported **12.1.0 build 69933**, build
date September 18, 2026, interface 120100, on a level-90 character. These are
separate from the original dumps whose build was not recorded. The local code
export is older (69497); the inspected local enum index reports build 69587.
The raid/dungeon context names below were subsequently printed from the user's
actual runtime enum rather than assumed from those older references.

On the character with no Vault progress:

- `HasAvailableRewards()`, `HasGeneratedRewards()`, and
  `AreRewardsForCurrentRewardPeriod()` were all false.
- All nine dungeon/raid/world slots had zero progress, level, and activity tier
  ID. Slot IDs and unlock thresholds were still available.
- `GetExampleRewardItemHyperlinks` returned blank links, not usable previews.
- `GetSortedProgressForActivity(type, false)` returned no rows for dungeon,
  raid, and world activity types (1, 3, and 6).
- Reward-threshold queries still returned data when supplied usable tier IDs.
  Character progress is therefore not a prerequisite for those successful
  queries. This does not establish a complete reward-table enumeration API.

A bounded probe of tier IDs 1-512 at input level 0 found these transitions:

| Queried Tier | Difficulty ID | Next Tier | Next Level | Reward ilvl |
| ---: | ---: | ---: | ---: | ---: |
| 248 | 0 | 248 | 2 | 282 |
| 249 | 0 | 249 | 2 | 282 |
| 254 | 2 (Heroic dungeon) | 255 | 0 | 302 |
| 255 | 23 (Mythic dungeon) | 256 | 2 | 305 |
| 256 | 8 (M+) | 256 | 4 | 308 |
| 257 | 0 | 257 | 2 | 282 |

The returned ilvl belongs to the **next** tier/level. In particular, querying
254 reports Mythic 0 at 302, not Heroic at 302. Inputs -1, 1, and 2 for tiers
254/255 gave no result; input -1 for tier 256 also failed. Negative inputs did
not expose a starting reward. Tier 256 still produced the previously recorded
308/311/315/318 thresholds without progress; input 1 remained false.

`GetNextMythicPlusIncrease` also worked without progress, but its results differ
from the tier-based query. Inputs 0/1 reported next key 2 at 305, then inputs
2-9 reported successive keys 3-10 at 305/308/308/311/315/**305**/315/318.
Thus the anomalous +8 = 305 recurred on the empty character. Input 10 returned
`true, nil, nil`; inputs 11/12 returned false. A true flag alone is not a reward
value, and these conflicting paths must not be silently merged or corrected.

#### World Tiers and Populated-Character Controls

Further calls at input levels 0-12 exposed these next-level results:

| Reported Next Level | Tier 248 | Tier 249 | Tier 257 |
| ---: | ---: | ---: | ---: |
| 2 | 282 | 282 | 282 |
| 3 | no result | 285 | 285 |
| 4 | no result | 289 | 289 |
| 5 | no result | 292 | 292 |
| 6 | no result | 295 | 295 |
| 7 | no result | 298 | no result |
| 8 | no result | 305 | no result |

For each listed curve, inputs 0 and 1 returned level 2; subsequent successful
inputs returned the next integer level. Other tested inputs returned false.
These are API-reported candidate curves, not confirmed Delve reward mappings.
In particular, do not replace the inherited Delve 6/7 values with 295/298 just
because tier 249 reports those numbers.

On Main with existing progress, the uncombined world breakdown returned
`252, 8, 3` and `249, 1, 1` (tier ID, difficulty, points). Its actual slots were:

| Slot | Tier ID | Difficulty | Progress | Threshold | Preview ilvl |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 252 | 8 | 3 | 2 | 305 |
| 2 | 249 | 1 | 4 | 4 | 279 |
| 3 | 0 | 0 | 4 | 8 | no link |

Tier 252 is therefore present in actual world progress, despite returning false
from `GetNextActivitiesIncrease(252, level)` for every tested input 0-12, even
on Main. False does not prove an invalid tier, missing character progress, or a
reward cap. Tier 249 participates in a real difficulty-1 world reward; its
other levels are not thereby assigned to the difficulty-8 activity using 252.
Do not label 248 or 257 as specific activity sources from their curves alone.

The same Main character had two Mythic raid slots and one Heroic raid slot:
all three had tier ID 0, difficulties 16/16/15, progress 7, and thresholds
2/4/6. The next-tier query failed for all three. A bounded probe of IDs 1-512
with raid difficulty inputs 14-17 also found no results. In the inspected Lua,
raid previews use example links; the generic next-tier query is used by the
dungeon/world branches. There is no demonstrated generic raid-tier lookup.

#### Context-Based Item Previews Without Progress

`C_Item.GetDelvePreviewItemLink(itemID, context)` successfully constructed links
outside an earned Vault slot, including non-Delve contexts. Load the base item
asynchronously first (`Item:CreateFromItemID(...):ContinueOnItemLoad(...)`), then
retain the returned link and read its first `GetDetailedItemLevelInfo` result.
Despite its name, the tested helper is not limited to the two world examples.
Do not assume it supports every context or item without validation.

The actual Vault controls supplied these links on Main:

```text
World difficulty 8:
item:275527::::::::90:262::55:2:12841:13668::::::
World difficulty 1, current and higher preview:
item:275528::::::::90:262::108:2:13668:12825::::::
item:275528::::::::90:262::108:2:13668:12826::::::
Mythic raid:
item:270175::::::::90:262::96:3:6652:13335:13848::::::
Heroic raid:
item:270175::::::::90:262::95:3:6652:13334:12849::::::
Dungeon +12:
item:273775::::::::90:262::35:4:12849:13440:13662:12699::::::
```

These contain the known rank bonuses 12841, 12825/12826, 13848, and 12849.
The current/higher world previews share the same item ID and context but have
different rank bonuses; this helper has no explicit difficulty/rank argument.

On Main the helper reproduced 305 for item 275527/context 55 and 279 for item
275528/context 108. On the zero-progress character, both items independently
returned 100 with context 0, 305 with context 55, and 279 with context 108.
The swapped-context results demonstrate context-dependent resolution across
these two seeds, not just each item returning its default level. Swapped
variants are still probes, not evidence that those variants are obtainable.

The helper generated links with only bonus **3524**, without us injecting a
known rank bonus. For example:

```text
item:275528::::::::90:262::108:1:3524::::::
item:270175::::::::90:262::95:1:3524::::::
```

Further zero-progress results, with enum names printed from the client:

| Item ID | Context | Runtime Context Name | ilvl | Independent Reward Control |
| ---: | ---: | --- | ---: | --- |
| 270175 | 94 | RaidFinderExtended_3 | 292 | No actual LFR Vault preview captured |
| 270175 | 93 | RaidNormalExtended_3 | 305 | No actual Normal Vault preview captured |
| 270175 | 95 | RaidHeroicExtended_3 | 318 | Matches Main's Heroic raid Vault preview |
| 270175 | 96 | RaidMythicExtended_3 | 344 | Matches Main's Mythic raid Vault previews |
| 273775 | 102 | DungeonHeroicJackpot | 289 | No actual Heroic dungeon Vault preview captured |
| 273775 | 103 | DungeonMythicJackpot | 302 | Agrees with next-tier query 254 -> 255/0 |
| 273775 | 35 | ChallengeModeJackpot | 305 | Agrees with 255 -> 256/2; does NOT reproduce the +12 preview at 318 |

Direct `GetItemUpgradeInfo` queries of the generated links subsequently
confirmed context 94 as **292 Champion 1/6** and context 93 as **305 Hero 1/6**.
These match the user's expected LFR and Normal Vault rewards and the ordinary
track curves. They remain context probes, not new actual-slot preview captures.

Thus some source-context reward levels can be read without character Vault
progress or claimable rewards. This is not yet a complete progress-free Vault
collector: intermediate world/Delve mappings, key-specific M+ rewards, and
independent checks for the newly probed baselines remain. Context 35 alone does
not specify the key level, and 3524 is not a universal fixed-rank bonus.

Keep observed Vault links, threshold-query results, context probes, and inferred
source mappings as distinct evidence. These results apply to the tested build,
level, and seeds; they do not establish every item's behavior or future-season
values. Preserve exact returned links and item-loading failures. Do not assign
the same ilvl or track to every item/context, infer obtainability from a decoded
link, or update the season files automatically. None of these new queries has
been added to the addon runner yet.

#### Named World Context Scan

On the same zero-progress character and build, item **275528** was queried for
each runtime `Enum.ItemCreationContext` name matching `Delve`, `WorldQuest`, or
`Prey`. The 48 reported results included no name matching `Prey`; this does not
prove that Prey rewards lack a context under another name. The scan queried ilvl,
not upgrade-track metadata, and did not establish source-to-difficulty mappings.

| Runtime Context Name | Context ID | ilvl |
| --- | ---: | ---: |
| WorldQuest_1 | 25 | 266 |
| WorldQuest_2 | 26 | 269 |
| WorldQuest_3 | 27 | 272 |
| WorldQuest_4 | 28 | 276 |
| WorldQuest_5 | 29 | 279 |
| WorldQuest_6 | 30 | 282 |
| WorldQuest_7 | 36 | 285 |
| WorldQuest_8 | 37 | 289 |
| WorldQuest_9 | 42 | 292 |
| WorldQuest_10 | 43 | 295 |
| WorldQuest_11 | 53 | 298 |
| WorldQuest_12 | 54 | 302 |
| WorldQuest_13 | 55 | 305 |
| WorldQuestJackpot | 74 | 262 |
| DelvesJackpot | 108 | 279 |

The remaining results, with IDs and ilvls in the stated name order:

| Context Names | Context IDs | ilvls |
| --- | --- | --- |
| Delves_1, Delves_2, Delves_3 | 104, 106, 107 | 100, 100, 100 |
| DelvesKey_1 | 109 | 266 |
| DelvesKey_2 through DelvesKey_8 | 110-116 | All 100 |
| DelvesBounty_1 through DelvesBounty_4 | 117-120 | 266, 269, 272, 276 |
| DelvesBounty_5 through DelvesBounty_8 | 121-124 | All 100 |
| DelvesLevelUp_1 through DelvesLevelUp_4 | 125-128 | 256, 266, 262, 100 |
| DelvesBonus_1 through DelvesBonus_4 | 129-132 | All 100 |
| DelvesBonus_5 through DelvesBonus_10 | 133-138 | 253, 260, 266, 272, 292, 305 |

Ilvl **100** matches this seed's context-0 result. Keep these as default-like
probe results, not established reward levels or proof that a context is invalid.
An item from the corresponding reward source may behave differently. Do not
discard these rows from a future collector.

The WorldQuest sequence supplies useful context-resolved item levels, but its
ordinal is not a Vault difficulty: the observed difficulty-8 preview uses
`WorldQuest_13`/55, while difficulty 1 uses `DelvesJackpot`/108. Likewise,
`DelvesLevelUp_2` returned a higher ilvl than `DelvesLevelUp_3`; numeric suffixes
alone do not establish a progression curve. Do not import these contexts as
Delve tiers, map rewards, Prey difficulties, or Vault tiers without source data.

A follow-up `GetItemUpgradeInfo` query of the generated links for item 275528
returned:

| Context ID | Runtime Context Name | ilvl | Track | Rank / Max Rank |
| ---: | --- | ---: | --- | --- |
| 74 | WorldQuestJackpot | 262 | nil | 0 / 0 |
| 125 | DelvesLevelUp_1 | 256 | nil | 0 / 0 |
| 126 | DelvesLevelUp_2 | 266 | Adventurer | 1 / 6 |
| 127 | DelvesLevelUp_3 | 262 | nil | 0 / 0 |
| 133 | DelvesBonus_5 | 253 | nil | 0 / 0 |
| 134 | DelvesBonus_6 | 260 | nil | 0 / 0 |
| 108 | DelvesJackpot | 279 | Veteran | 1 / 6 |
| 55 | WorldQuest_13 | 305 | Hero | 1 / 6 |

The sub-Adventurer results 253, 256, 260, and 262 are untracked for this seed
and these contexts; they do not establish Explorer's starting level or cap.
Preserve the reported 260 rather than adjusting it to the known Normal-dungeon
259 observation. Context 126 provides an Adventurer 1/6 preview at 266 without
supplying a rank bonus or owning an Adventurer item, but does not establish a
particular activity's reward mapping.

The first attempt at this follow-up returned nil for ilvl and all upgrade
fields for every world context, including the previously successful controls
108 and 55. The user reported that the Vault was not open for that attempt;
the rerun produced the table above. Do not record the initial nils as absent
reward definitions.

The user then reloaded with the Vault kept closed and reproduced nil results
for all eight contexts. Explicitly loading item 275528 with
`Item:CreateFromItemID(275528):ContinueOnItemLoad(...)`, then querying context
108 inside the callback, returned:

```text
loaded 275528 link [Preyhunter's Ring] ilvl 279
```

Explicit item loading therefore suffices for this control after reload without
reopening the Vault. Together with the zero-progress observations, this gives
a demonstrated path that does not require an earned reward or an open Vault
for this item/context pair. This is not a new fresh-client-login test or proof
that every context behaves identically. The remaining seven contexts still
need a post-load rerun with the Vault closed.

The future collector must wait for item data before requesting context links,
and retain unresolved loads separately from successful untracked results
(`nil` track with rank/max rank `0/0`). In the local 12.1.0.69497 export,
Blizzard's Delves tooltip likewise waits for `ContinueWithCancelOnItemLoad`
before calling `GetDelvePreviewItemLink`; the runtime test above is from build
69933. Keep Vault visibility, initialization, and earned progress separate.

## Follow-Up Work

The cross-item and context/modifier isolation checks for 13848 are complete on
build 69933. Further checks on other builds or item types extend that evidence
rather than being required to finish this particular isolation test.

1. Check another Normal Midnight dungeon item against the observed 259 reward
   and retain its build/source metadata. Preserve untracked rewards as such;
   do not require an Explorer baseline unless current-season source evidence
   establishes that track.
2. Continue sequential scanning at 15000-19999 with the original fixed seed.
   Preserve 0/0, over-cap, missing-data, and error regions. Repeat promising
   candidates on independent seeds and builds rather than assigning seasons
   from adjacency or assuming every useful encoding is a single bonus.
3. Add a journal observation collector with filter/difficulty/encounter/source
   metadata and asynchronous loading. Keep original rewards separate from probes.
4. Before automating Vault/context capture, finish activity-source mapping and
   context calibration. Cross-check the LFR/Normal raid and Heroic dungeon
   context results against real previews when available, repeat on additional
   current-season seeds, and test future builds rather than hardcoding these
   IDs as universal. Keep the M+ +8 discrepancy and intermediate world tiers
   unresolved until independently checked. Add explicit vendor capture too;
   upgrade costs/discounts, item ranks, end-of-run rewards, and Vault rewards
   are different data sets.
5. Compare observed anchors with candidate families before assigning a season.
   Preserve conflicting PTR/hotfix/build results rather than overwriting them.
   Snapshot active seasonal track metadata and distinguish historical labels
   from later untracked states, as demonstrated by the Season 1 Sporeheart.
6. Design an explicit review/import step for Season1.lua and Season2.lua. No
   automatic season-table updates from arbitrary generated links.

## In-Game Validation Checklist

- Open `/ll collector` after reload; confirm native fields, history, progress,
  scrolling, export selection, close controls, and readable layout at UI scales.
- Run a small batch around 12849-12854: expect Myth 1-6 at
  318/321/324/328/331/334. Probe 3524 with the default seed: expect 344 Myth 9/6
  for the same investigated data/build, subject to later game tuning changes.
- Run 0-4999: confirm exactly 5,000 unique rows and no automatic next batch.
  Next Batch must begin at 5000 and finish at 9999.
- The Sporeheart capture verified 0-14999 as one batch with all 15,000 result
  rows exported, not truncated at 5,000. Still verify pause/resume preserves the
  larger range. Sizes above 50,000 must be rejected; the default remains 5,000.
- Pause/resume mid-batch and reload mid-batch. Confirm no duplicated/skipped IDs,
  no automatic restart, preserved original build/seed, and no overwrites.
- Exercise cold item data, invalid seeds, failed loads, timeouts, combat entry,
  and closing the panel. Delayed results must not restart a paused job.
- Export full/partial/history batches. Confirm complete text, metadata, blank
  values, rank-zero/over-cap rows, bounded error lines, and no 255-character
  macro dependency. Editing the export view must not alter stored rows.
- Confirm a build/locale mismatch blocks resume, history stops at its limit,
  and deletion requires confirmation. Existing tables must be unchanged.

Validation includes code review, Lua syntax checking, the original three in-game
batches covering 0-14999, the independent and stripped-link single-ID probes on
item 271486, and the complete 15,000-ID Sporeheart capture. Those captures verify
sequential collection, single-batch export beyond 5,000 rows, and the targeted
cross-item/context isolation results on build 69933, not every UI or lifecycle
path.
The separate manual zero-progress investigation also validated the specific
threshold and context queries documented above; it did not validate an automated
Vault/context collector or prove a complete future-season discovery workflow.
Pause/resume, reload recovery, combat, failed loads, history limits, and layout
at different scales still need the manual checks above. No game client is
available to the coding agent for direct runtime validation.
