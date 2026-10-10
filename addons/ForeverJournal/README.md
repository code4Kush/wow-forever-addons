# Forever Journal

Version 0.3.0 candidate — read-only active quests and **historical quest flags** for WoW: Forever. **Not yet tested in-game.** The version 0.2.0 quest and area commands were user-verified on interface 16001.

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
| `/fj status 747` | Check whether a quest ID is flagged completed for this character; distinguish active quests |
| `/fj character` | Show the current character's name, race, class, level and realm where available |

The addon reads **currently active quests** and can also query a **historical completion flag for a specific quest ID**. It does not enumerate every quest in a zone, compute zone-wide completion, or store historical data. A "ready to turn in" quest is still active; a false historical completion flag may mean unaccepted, abandoned, or an invalid ID.

## Modules

- `ForeverJournal_Camelot.toc` — interface version and load order
- `Core/Bootstrap.lua` — namespace and print helper
- `Modules/Progress.lua` — pure completion math
- `Modules/QuestLog.lua` — on-demand quest and area API adapter
- `Modules/QuestHistory.lua` — historical quest completion flag adapter
- `Modules/Character.lua` — current character identity adapter
- `Core/Events.lua` — login lifecycle
- `Core/Commands.lua` — parsing, pagination, and chat output

## Upgrade/install

1. Copy or synchronize the complete `addons/ForeverJournal/` directory into the game's `Interface/AddOns/ForeverJournal/` directory. **Ensure new files, including `Modules/QuestLog.lua`, are copied.**
2. Use `/reload` or restart the game.
3. Run `/fj version` and confirm 0.3.0.
4. Run `/fj character` and verify your character information.
5. Run `/fj status 747` and `/fj status 752` after handing in those quests; check historical completion flags.
6. Run `/fj zone`, `/fj quests`, and `/fj quest <a current quest ID>`.
7. Record the client build and results in the test checklist at `docs/TESTING.md`.

Version 0.1.0 and the main quest-reading behavior in 0.2.0 were verified on interface 16001 by the player on 2026-10-10. Version 0.3.0 is not yet verified in-game.

## Known limitations

- Current area can be a micro-map, not a completionist zone.
- Objective details may not be cached the first time; retry.
- A quest ready to turn in is not a quest already turned in.
- Some quest log entries may be hidden or missing information; the addon does not invent them.
- Historical status is queried per quest ID; the addon does **not** enumerate all completed quests.
- No graphical window, complete quest database, saved variables, quest-chain data, or zone-wide completion percentages yet.
