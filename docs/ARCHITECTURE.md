# Architecture

## Design objectives

A single repository contains independently installable addons. No cross-addon dependency is required for Forever Journal.

## Module boundaries

- `Core/Bootstrap.lua`: shared addon namespace, version and stable print helper.
- `Modules/Progress.lua`: pure completion arithmetic; no WoW dependencies.
- `Modules/QuestLog.lua`: read-only adapter for modern QuestLog and Map APIs.
- `Core/Events.lua`: minimal player login lifecycle.
- `Core/Commands.lua`: chat commands, pagination and delegation to other modules.

The manifest declares the explicit order: Bootstrap, Progress, QuestLog, Events, Commands.

## Data flow

- `/fj progress 3 5` -> Commands -> Progress -> Bootstrap output.
- `/fj zone` -> Commands -> QuestLog.GetCurrentArea -> Bootstrap output.
- `/fj quests [page]` -> Commands -> QuestLog.GetActiveQuests -> paginated chat output.
- `/fj quest <ID>` -> Commands -> QuestLog.FindActiveQuest -> QuestLog.GetObjectives -> chat output.

All queries are **on-demand**. There is no background polling, saving, external networking, automation, or persistent quest history.

## Correctness boundaries

"Active quests" means readable quest entries the game currently returns from the player's quest log. Quest headings are not quests. A quest may be ready to turn in without being historically completed. "Current area" is the current UI map, which may be a subzone, microdungeon, or continent. None of these constitute a comprehensive zone completion percentage.

## Future work

After verifying 0.2.0 on the user's client, consider: direct API evidence capture, quest completion history and storage testing, a versioned curated quest database, per-character progress, then a polished optional window. Add modules only as real behavior is implemented.
