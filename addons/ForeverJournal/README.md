# Forever Journal

Version 0.2.0 candidate — read-only quest log inspection for WoW: Forever. **Not yet tested in-game.**

## Current features

| Command | Behavior |
| --- | --- |
| `/fj` | Show help |
| `/fj version` | Show version number |
| `/fj progress 3 5` | Calculate a manual completion percentage |
| `/fj zone` | Show current UI map/area name and map ID when available |
| `/fj quests` | List the first six readable active quests |
| `/fj quests 2` | List the next page, if available |
| `/fj quest 12345` | Display the named active quest's objective rows and turn-in readiness |

The addon reads only **quests currently in the player's quest log**. It does not discover unaccepted quests, compute zone-wide completion, claim quests were turned in, or save history. A "ready to turn in" quest is still an active quest, not a completed/turned-in quest.

## Modules

- `ForeverJournal_Camelot.toc` — interface version and load order
- `Core/Bootstrap.lua` — namespace and print helper
- `Modules/Progress.lua` — pure completion math
- `Modules/QuestLog.lua` — on-demand quest and area API adapter
- `Core/Events.lua` — login lifecycle
- `Core/Commands.lua` — parsing, pagination, and chat output

## Upgrade/install

1. Copy or synchronize the complete `addons/ForeverJournal/` directory into the game's `Interface/AddOns/ForeverJournal/` directory. **Ensure new files, including `Modules/QuestLog.lua`, are copied.**
2. Use `/reload` or restart the game.
3. Run `/fj version` and confirm 0.2.0.
4. Run `/fj zone`, `/fj quests`, and `/fj quest <an ID shown in the list>`.
5. Record the client build and results in the test checklist at `docs/TESTING.md`.

The known working baseline was 0.1.0 on interface 16001 as verified by the player on 2026-10-10. This candidate must be tested on that client.

## Known limitations

- Current area can be a micro-map, not a completionist zone.
- Objective details may not be cached the first time; retry.
- A quest ready to turn in is not a quest already turned in.
- Some quest log entries may be hidden or missing information; the addon does not invent them.
- No graphical window, database, persistence, quest-chain data, or zone-wide completion percentages yet.
