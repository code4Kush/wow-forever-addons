# Testing strategy

## Verified baseline (reported by the player)

On 2026-10-10, the player reported that Forever Journal **0.1.0** loaded in-game with `/fj`, `/fj version`, and `/fj progress 3 5` producing their expected outputs. The interface value read from the client was `16001`. Full build number was not recorded.

This is a user-reported manual smoke test, **not a CI run or proof about version 0.2.0**.

## Fast standalone tests

From repository root:

~~~sh
lua5.1 tests/test_progress.lua
lua5.1 tests/test_questlog.lua
lua5.1 tests/test_history.lua
~~~

The second script mocks the WoW C_QuestLog and C_Map namespaces and exercises filtering, objective access, area fallback, pagination, command validation and error handling.

GitHub Actions runs all three tests on pull requests. These mock tests cannot validate live game API compatibility.

## 0.2.0 in-game checklist — partial manual pass (2026-10-10)

A user-provided game screenshot shows live Forever Journal chat output in Red Cloud Mesa. User also confirmed the addon displays quest status and ready-to-turn-in state.

**Confirmed by screenshot + user report:**

- `/fj quest 747`: "The Hunt Begins" appears as not ready to turn in, with objective text "5/7 Plainstrider Meat" and "4/7 Plainstrider Feather".
- `/fj quest 752`: "A Humble Task" appears as ready to turn in. Addon prints "No objective rows were returned for this quest" rather than crashing.
- The objective tracker in the game screenshot independently displays the same current meat and feather counts.
- The command help shown in chat includes the new `/fj quest <ID>` functionality, supporting that the updated addon is loaded.
- The user reports the addon lists current quest information. The screenshot itself does not show the entire output of `/fj quests`.

**Further confirmed by the player:** `/fj zone` returned `Mulgore (map 1412)` while the character was standing in Red Cloud Mesa, followed by `Area detection does not measure zone quest completion.` This verifies the command and map lookup on the observed interface 16001 client. The broader parent-zone name is expected; subzone identification is not implemented.

**Additional live pass (player screenshot, 2026-10-10):** After further looting, `/fj quest 747` displayed two `[done]` rows for `7/7 Plainstrider Meat` and `7/7 Plainstrider Feather`, plus `Quest is ready to turn in.` The game's objective tracker independently displayed `Ready for turn-in`. Earlier screenshot showed partial progress, so on-demand objective-refresh and readiness transition are verified. The player then turned in both quests and confirmed that the active-log commands no longer showed quest IDs 747 and 752. This is evidence of active-log removal following turn-in, **not** proof that the addon can query a historical completion flag.

**Not yet confirmed:** version command explicitly showing 0.2.0, pagination with >6 quests, invalid-argument handling, cold restart, and full numeric client build. Do not mark the overall checklist complete yet.

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

## 0.3.0 candidate — partial manual pass (reported 2026-10-10)

The player reported that **all three requested commands worked as intended**: `/fj character`, `/fj status 747`, and `/fj status 752`. This confirms that character identity and historical completion flags for the two handed-in quests functioned on the player's live client. We do **not** have the exact level/realm text, full client build, cold-restart result, or invalid-ID test output. Do not mark the remaining checks as passed.

### Mandatory manual test format

Every future in-game test instruction must show the **exact command**, **expected output** (with placeholders for dynamic details), **what it verifies**, and **PASS/FAIL criteria**. Ask the player to confirm a match or paste the actual output if different.

### Expected v0.3.0 outputs (examples)

`/fj version`

~~~text
Forever Journal: Version 0.3.0
~~~

`/fj character`

~~~text
Forever Journal: Uddergrief - Tauren Warrior - level <current level> - realm <realm name>
~~~

Realm may be omitted if unavailable. Level and realm are not known from the reported test.

`/fj status 747`

~~~text
Forever Journal: Quest 747: flagged completed for this character.
~~~

`/fj status 752`

~~~text
Forever Journal: Quest 752: flagged completed for this character.
~~~

**PASS:** Commands display the expected version, current player identity and positive completion flags without errors. **FAIL:** Missing output, wrong character/class, false completion flags, or Lua/API errors. The player reported these primary tests passed, but the exact output was not pasted.

### Remaining manual tests (not yet verified)

1. Update all addon files (including `Modules/QuestHistory.lua` and `Modules/Character.lua`) and run `/reload`.
2. Run `/fj version`; expect `0.3.0`. Check `/fj` for `status` and `character` commands.
3. Run `/fj character` as Uddergrief; verify Tauren Warrior name/race/class, current level, and reported realm.
4. Run `/fj status 747`; since "The Hunt Begins" was handed in, expect `flagged completed`.
5. Run `/fj status 752`; since "A Humble Task" was handed in, expect `flagged completed`.
6. Run `/fj status 99999999` and note it may report "not flagged completed" because the ID is invalid. This must NOT be displayed as proof of an uncompleted quest.
7. Run `/fj status bananas`; verify friendly usage text and no Lua error.
8. Run `/fj status <ID for a current accepted quest>`; verify it displays active state rather than a historical completion.
9. Verify existing `/fj quests`, `/fj quest <ID>`, `/fj zone`, and `/fj progress 3 5` still work.
10. Cold-restart game and verify the same quest flags. No saved variables are involved in this candidate.

Record the actual game build and screenshots. Successful unit tests alone do not satisfy this checklist.

## Release policy

Version 0.2.0 is a **candidate** until verified on a current WoW: Forever client. Update docs/API_NOTES.md with the actual build and findings after the player reports test outcomes.
