# Testing strategy

## Verified baseline (reported by the player)

On 2026-10-10, the player reported that Forever Journal **0.1.0** loaded in-game with `/fj`, `/fj version`, and `/fj progress 3 5` producing their expected outputs. The interface value read from the client was `16001`. Full build number was not recorded.

This is a user-reported manual smoke test, **not a CI run or proof about version 0.2.0**.

## Fast standalone tests

From repository root:

~~~sh
lua5.1 tests/test_progress.lua
lua5.1 tests/test_questlog.lua
~~~

The second script mocks the WoW C_QuestLog and C_Map namespaces and exercises filtering, objective access, area fallback, pagination, command validation and error handling.

GitHub Actions runs both tests on pull requests. These mock tests cannot validate live game API compatibility.

## 0.2.0 in-game checklist — partial manual pass (2026-10-10)

A user-provided game screenshot shows live Forever Journal chat output in Red Cloud Mesa. User also confirmed the addon displays quest status and ready-to-turn-in state.

**Confirmed by screenshot + user report:**

- `/fj quest 747`: "The Hunt Begins" appears as not ready to turn in, with objective text "5/7 Plainstrider Meat" and "4/7 Plainstrider Feather".
- `/fj quest 752`: "A Humble Task" appears as ready to turn in. Addon prints "No objective rows were returned for this quest" rather than crashing.
- The objective tracker in the game screenshot independently displays the same current meat and feather counts.
- The command help shown in chat includes the new `/fj quest <ID>` functionality, supporting that the updated addon is loaded.
- The user reports the addon lists current quest information. The screenshot itself does not show the entire output of `/fj quests`.

**Not yet confirmed:** `/fj zone` response, version command explicitly showing 0.2.0, pagination with >6 quests, invalid-argument handling, live objective refresh after progress, cold restart, and full numeric client build. Do not mark the overall checklist complete yet.

### Remaining manual checklist

Record the full `/run print(GetBuildInfo())` output or equivalent client build information, OS and addon install path.

1. Confirm `/fj version` prints 0.2.0 after updating **all addon files** and running `/reload`.
2. Confirm `/fj` shows the new commands and `/fj progress 3 5` still prints 60.00%.
3. Run `/fj zone`; verify it names your actual current location and optionally prints a map ID.
4. With at least one accepted quest, run `/fj quests`; check names and numeric quest IDs.
5. With more than six accepted quests, try `/fj quests 2`; check page boundaries.
6. Run `/fj quest <ID>` using an ID from the quest listing; compare objective text with the game's quest log.
7. Progress an objective in the game, rerun the same command, and verify refreshed text/status.
8. If a quest becomes ready for turn-in, verify the addon says **ready**, not **turned in**.
9. Run `/fj quest bananas` and `/fj quests 0`; check friendly usage guidance.
10. Try `/reload` and a cold restart. Confirm commands still work and no Lua errors appear.

If a command fails, note the exact output, build, class/zone where relevant, and which API may be missing. Do not claim game compatibility until this checklist is completed.

## Release policy

Version 0.2.0 is a **candidate** until verified on a current WoW: Forever client. Update docs/API_NOTES.md with the actual build and findings after the player reports test outcomes.
