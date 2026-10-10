# WoW: Forever API and compatibility notes

Last documentary review: 2026-10-10. Third-party API references are **not an in-game test of 0.2.0**.

## Confirmed on the player's beta client

- 2026-10-10: `select(4, GetBuildInfo())` returned interface **16001**.
- 2026-10-10: Forever Journal **0.1.0** loaded and `/fj`, `/fj version`, `/fj progress 3 5` produced the expected output.
- Full numeric client build was **not recorded**.
- 2026-10-10: Version **0.2.0 is partially tested in-game** (player screenshot and confirmation). `/fj quest 747` displayed "The Hunt Begins", unready status and objectives "5/7 Plainstrider Meat" and "4/7 Plainstrider Feather"; `/fj quest 752` displayed "A Humble Task", ready-to-turn-in status, and handled zero objective rows. The user reports active quest data is shown.
- Screenshot aligns the quest objective numbers with the game's own objective tracker. This supports the live behavior of `C_QuestLog.GetInfo`, `C_QuestLog.IsComplete`, and `C_QuestLog.GetQuestObjectives` on the tested client. Exact full build is not yet recorded; reload and persistence behaviors remain unverified.
- 2026-10-10: Player tested `/fj zone` in Red Cloud Mesa; addon reported `Mulgore (map 1412)` and the explicit warning that area detection does not measure zone quest completion. This directly supports the `C_Map` name/ID lookup on the current client, while demonstrating that a map can identify a parent zone rather than a subzone.
- 2026-10-10: Later screenshot shows `/fj quest 747` reflected updated objective progress at `7/7 Plainstrider Meat` and `7/7 Plainstrider Feather`, both `[done]`; status changed to `Quest is ready to turn in`, consistent with the in-game objective tracker. This validates refresh-on-command after gameplay progress without a UI reload.
- 2026-10-10: Player subsequently reported successful turn-in of quest IDs 747 and 752; the entries were then absent from the active quest log. This verifies post-turn-in disappearance but does not establish an independent historical completion flag.

- 2026-10-10: The player reported that v0.3.0's `/fj character`, `/fj status 747`, and `/fj status 752` **all worked as intended** in-game. This is user-reported verification of runtime character identification and positive historical completion flags for quests 747 and 752. Exact level, realm, full build, response text and cold-restart persistence were not supplied; do not infer them.

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

## v0.3.0 candidate: historical completion and identity APIs (primary commands user-tested in-game)

| API | Purpose | Documentation |
| --- | --- | --- |
| `C_QuestLog.IsQuestFlaggedCompleted(questID)` | Historical completion flag for a specific quest ID; false may also mean an invalid ID | https://warcraft.wiki.gg/wiki/API_C_QuestLog.IsQuestFlaggedCompleted |
| `UnitName("player")` | Current player's name | https://warcraft.wiki.gg/wiki/API_UnitName |
| `UnitClass("player")` | Localized class label | https://warcraft.wiki.gg/wiki/API_UnitClass |
| `UnitRace("player")` | Localized race label | https://warcraft.wiki.gg/wiki/API_UnitRace |
| `UnitLevel("player")` | Current character level | https://warcraft.wiki.gg/wiki/API_UnitLevel |
| `GetRealmName()` | Optional realm display name | https://warcraft.wiki.gg/wiki/API_GetRealmName |

The completion query is documented for Forever 1.60.1. We do not infer historical completion from quests disappearing from the active log. Character identity is queried at runtime so the addon works for players other than Uddergrief. Source URLs require in-game validation on the player's current client.

## v0.4.0 candidate: curated Mulgore starter journal

No new WoW API calls. The journal uses already-documented `C_QuestLog.GetInfo`, `C_QuestLog.IsComplete`, and `C_QuestLog.IsQuestFlaggedCompleted` with `UnitRace` and `UnitClass`. Only **selected** quest IDs are catalogued. Every status is refreshed on request.

See `docs/QUEST_CATALOG.md` for the full 12-ID starter catalog and source URLs. Classic quest IDs are not proof that the quest is obtainable or unchanged in Forever. The journal's denominator is its curated catalog size, not the number of Mulgore quests.

Status: NOT YET TESTED IN GAME.

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
