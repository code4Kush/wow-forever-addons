# Architecture

## Design objectives

A single repository contains independently installable addons. No cross-addon dependency is required for Forever Journal.

## Module boundaries

- `Core/Bootstrap.lua`: shared addon namespace, version and stable print helper.
- `Modules/Progress.lua`: pure completion arithmetic; no WoW dependencies.
- `Modules/QuestLog.lua`: read-only adapter for modern QuestLog and Map APIs.
- `Modules/QuestHistory.lua`: read-only wrapper for a historical quest flag (one ID per request).
- `Modules/Character.lua`: on-demand character display information.
- `Data/MulgoreStarter.lua`: static, sourced starter quest IDs; no quest text or game status.
- `Modules/ZoneJournal.lua`: combines curated IDs with live active and historical quest data.
- `Core/Events.lua`: minimal player login lifecycle.
- `Core/Commands.lua`: chat commands, pagination and delegation to other modules.

The manifest declares the explicit order: Bootstrap, Progress, QuestLog, QuestHistory, Character, MulgoreStarter, ZoneJournal, Events, Commands.

## Data flow

- `/fj progress 3 5` -> Commands -> Progress -> Bootstrap output.
- `/fj zone` -> Commands -> QuestLog.GetCurrentArea -> Bootstrap output.
- `/fj quests [page]` -> Commands -> QuestLog.GetActiveQuests -> paginated chat output.
- `/fj quest <ID>` -> Commands -> QuestLog.FindActiveQuest -> QuestLog.GetObjectives -> chat output.
- `/fj status <ID>` -> Commands -> QuestHistory.IsFlaggedCompleted -> optional QuestLog lookup -> chat output.
- `/fj character` -> Commands -> Character.GetIdentity -> chat output.
- `/fj journal [page]` -> Commands -> ZoneJournal -> curated IDs + current game completion/active APIs -> paginated chat output.

All queries are **on-demand**. Historical completion is read directly from the game's quest flag each time; there is no background polling, saving, external networking, automation, or local persistent quest history.

## Correctness boundaries

"Active quests" means readable quest entries the game currently returns from the player's quest log. Quest headings are not quests. A quest may be ready to turn in without being historically completed. "Current area" is the current UI map, which may be a subzone, microdungeon, or continent. A false quest completion flag can also mean an invalid quest ID. None of these constitute a comprehensive zone completion percentage.

## Catalog truth boundary

The Mulgore data is a **curated sample** of early Tauren quests. Summaries use a catalog numerator and denominator, never a total zone completion percentage. Every request reads live statuses; nothing is persisted. Updates must include source links and actual game validation evidence where possible.

## Future work

After verifying 0.2.0 on the user's client, consider: direct API evidence capture, quest completion history and storage testing, a versioned curated quest database, per-character progress, then a polished optional window. Add modules only as real behavior is implemented.
