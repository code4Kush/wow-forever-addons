# WoW: Forever API and compatibility notes

Last documentary review: 2026-10-10. Third-party API references are **not an in-game test of 0.2.0**.

## Confirmed on the player's beta client

- 2026-10-10: `select(4, GetBuildInfo())` returned interface **16001**.
- 2026-10-10: Forever Journal **0.1.0** loaded and `/fj`, `/fj version`, `/fj progress 3 5` produced the expected output.
- Full numeric client build was **not recorded**.
- 2026-10-10: Version **0.2.0 is partially tested in-game** (player screenshot and confirmation). `/fj quest 747` displayed "The Hunt Begins", unready status and objectives "5/7 Plainstrider Meat" and "4/7 Plainstrider Feather"; `/fj quest 752` displayed "A Humble Task", ready-to-turn-in status, and handled zero objective rows. The user reports active quest data is shown.
- Screenshot aligns the quest objective numbers with the game's own objective tracker. This supports the live behavior of `C_QuestLog.GetInfo`, `C_QuestLog.IsComplete`, and `C_QuestLog.GetQuestObjectives` on the tested client. Exact full build is not yet recorded; reload and persistence behaviors remain unverified.
- 2026-10-10: Player tested `/fj zone` in Red Cloud Mesa; addon reported `Mulgore (map 1412)` and the explicit warning that area detection does not measure zone quest completion. This directly supports the `C_Map` name/ID lookup on the current client, while demonstrating that a map can identify a parent zone rather than a subzone.

## Community-observed beta baseline

- Forever uses a modern/Mainline-style UI API. Classic Era API examples can contain missing globals.
- Product folder is commonly `_classic_beta_`, and manifests use `_Camelot.toc`.
- Interface 16001 is a beta observation and matches the player's current result.

References:
- https://github.com/Thunderz96/forever-addon-kit
- https://github.com/Atraeau/WoW-Addons
- https://github.com/Atraeau/WoW-Addons/blob/main/docs/api/README.md

## v0.2.0 API use: quest and map inspection

Every entry below is documented for Forever 1.60.1 by Warcraft Wiki. **The project's own client test is pending.**

| API | Purpose | Documentation |
| --- | --- | --- |
| `C_QuestLog.GetNumQuestLogEntries()` | Iterate the currently loaded log, including headers | https://warcraft.wiki.gg/wiki/API:C_QuestLog.GetNumQuestLogEntries |
| `C_QuestLog.GetInfo(index)` | Read current quest IDs, titles, header status and levels | https://warcraft.wiki.gg/wiki/API:C_QuestLog.GetInfo |
| `C_QuestLog.IsComplete(questID)` | Check whether the quest is **ready**, not historically turned in | https://warcraft.wiki.gg/wiki/API:C_QuestLog.IsComplete |
| `C_QuestLog.GetQuestObjectives(questID)` | Read objectives of a quest **in the log**; may return nothing while uncached | https://warcraft.wiki.gg/wiki/API:C_QuestLog.GetQuestObjectives |
| `C_Map.GetBestMapForUnit("player")` | Read the player's current UI map | https://warcraft.wiki.gg/wiki/API:C_Map.GetBestMapForUnit |
| `C_Map.GetMapInfo(mapID)` | Read the map's human-readable name | https://warcraft.wiki.gg/wiki/API:C_Map.GetMapInfo |
| `GetZoneText()` | Fallback zone name if map API gives no usable result | https://warcraft.wiki.gg/wiki/API:GetZoneText |

## Risks and design safeguards

- No active quest-log function provides a complete zone-wide checklist. We cannot calculate total zone completion from `GetNumQuestLogEntries`.
- A quest ready to hand in is still in the log. `IsComplete` is **not** a "quest turned in historically" flag.
- Do not assume zone category headers map to the player's physical location.
- Quest information may be uncached. Do not report a missing objective as incomplete or failed.
- `QUEST_LOG_UPDATE` can fire frequently. We do **not** register for it in 0.2.0; reads happen only on command.
- The modern UI has protected/secret value restrictions. This addon does not act on combat or hidden data.
- Beta saved-variable behavior has varied; 0.2.0 deliberately does not persist quest history.

## Evidence convention

For each future API, capture source URL, observation date, game build, in-game test steps and result, and known limitations. Community documentation and a working in-game result are separate categories of evidence.
