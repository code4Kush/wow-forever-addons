# Forever Addons module directory — integrated beta candidate

**Status:** Buildable development candidate, not yet game-verified or released.  
**Last review:** 2026-10-10.  
**Source:** PRs #18 → #22 → #24 → #25, plus the original quest-history/catalog data from PRs #2 → #3 → #4. These are **unmerged and stacked**.

## Principle: choose only what each character needs

`ForeverCore` is the only hard dependency of the packs. Install an optional pack directory only if the player wants its features. Each pack has an individual `_Camelot.toc` and a feature descriptor registered with Core. Legacy test probes under `test-addons/` are developer-only and must not ship in public packages.

Core 0.2 adds an experimental `## SavedVariablesPerCharacter: ForeverCharacterDB` table. `/forever pref <id> on|off` requests that this character's choice persist; **Forever beta restart retention is unverified**. `/forever enable|disable <id>` remains session-only. The game AddOns manager independently controls whether Lua loads at all. Logical disabling must stop a pack's active events and prevent its read commands, but Lua loaded by WoW cannot be unloaded dynamically.

| Addon directory | Core registry ID | Slash command | v0.x functional scope | Explicitly **not** implemented |
| --- | --- | --- | --- | --- |
| ForeverCore | Foundation, not a pack | `/forever` | Character identity, registry, settings, version, error and event management | Proven durable settings, automation |
| ForeverDashboard | `dashboard` | `/fdash` | Movable module list, on-demand open/close | Full tabbed interactive UI, saved layout |
| ForeverJournal | `journal` | `/fj` | Active/history/quest objectives, 12-item curated starter list | All Mulgore quests, zone-wide completion, guild sharing |
| ForeverInventory | `inventory` | `/finv` | Counts current backpack and equipped bags | Bank, equipment rankings, selling, AH pricing |
| ForeverGold | `gold` | `/fgold` | Current wallet + manual baseline and signed net delta (v0.2 candidate) | Transaction categories, actual income/profit, AH prices, saved history |
| ForeverProfessions | `professions` | `/fprof` | Read-only current skills, session snapshots/progress and up to 5 manually set goals (v0.3 candidate) | Automatic training/crafting, persistently saved skills, recipes |
| ForeverFishing | `fishing` | `/ffish` | Fishing skill readout plus manual, session-only player-entered catch notes (v0.2 candidate) | Verified loot detection, auto-fishing, pricing, saved catch history |
| ForeverCooking | `cooking` | `/fcook` | Reads Cooking profession skill when its UI exposes data | Ingredient planner, recipe history |
| ForeverWarrior | `forever-warrior` | `/fw` | Leveling advice, manual dungeon preparation checklist | Tank threat automation, protected combat analysis |
| ForeverExplorer | `explorer` | `/fexplore` | Current lowest UI map name/ID | Confirmed map discovery or zone-exploration completion |
| ForeverGuild | `guild` | `/fguild` | Consent-gated manual version-only guild announcements, bounded local peer list | Automatic guild chat, roster sync, quest sharing, raid planner |
| ForeverPerformance | `performance` | `/fperf` | On-demand known-pack KB, top-3/details and session baseline/delta | Total game RAM, CPU profiling, telemetry, automatic GC, guaranteed leak detection |

## Safe API constraints and privacy

- All addon modules use the documented ForeverCore 0.2 descriptor interface. Optional modules may be absent without breaking others.
- Slash commands are submitted **one at a time**, never pasted as multiple lines into WoW. See `docs/SUITE_TESTING.md` for each literal expected result, dynamic placeholders and PASS/FAIL.
- Game information is read only on demand and reported as unavailable when an API is missing. No missing value may be silently interpreted as zero, complete, learned or sold.
- The Guild module registers a fixed 9-byte message prefix and must never send until explicit **opt in + separate manual announce**. Payload is only `HELLO|0.1.0`; no quest IDs, roles, inventory, character profile or arbitrary text. Transport sender labels are NOT authenticated identities.
- No combat automation, protected secret-value analysis, automatic item interactions, unsanctioned memory access, advertisements, paid features, or external telemetry.
- This project remains an independent community addon, not Blizzard-affiliated. Before releasing, choose a source license, verify complete readable source, activate public GitHub security controls, review [PR #20](https://github.com/code4Kush/wow-forever-addons/pull/20), test the exact game build and record real-player results.

## Acceptance coverage: completed vs unverified

**Automated:** The original eight CI mock suites (Core, progress, Warrior, modular suite, Journal quest log, Journal history, Journal curated catalog and Journal/Core bridge) passed on the initial PR #25 commit. Any new commit requires new exact-SHA CI confirmation.

**In-game:** The earlier Core M1 commands and portions of Journal v0.4 were user-confirmed. **None of the Core 0.2 preference changes, the seven new information packs, Guild networking, or Journal Core bridge have yet been tested in the real client.** Do not publish these as supported features until the relevant manual tests pass. Journal v0.4 screenshot was a PARTIAL pass; it was not a full zone-completion test.

## Recommended test sequence

1. Verify Core 0.2 alone (version, character, profile). Cold restart after marker test.
2. Test Dashboard and each read-only pack **alone with Core**, not everything installed at once. Verify accurate counts and nil/unavailable paths.
3. Reinstall multiple packs; test each character preference and a non-Warrior character. Check Warrior remains gated.
4. Verify Journal v0.5 historical flags and module on/off regression.
5. Only with a consenting second guild member, validate version-only message reception and rate limits. Make sure Guild remains OFF after reload.
6. Open separate bugs for every real-client mismatch, with exact build, expected/actual text, screenshot and commit SHA.
7. Keep **all** feature PRs draft until game compatibility, licensing, public-source, settings protection and release reviews are finished.

Feature completeness should be tracked in individual [milestone issues #5–#16](https://github.com/code4Kush/wow-forever-addons/issues), not inferred from the presence of a folder.

## Optional performance measurement (M12, PR #27)

`ForeverPerformance` is another independently installable, character-selectable optional pack depending on Core 0.2. It reports **only** the 12 explicitly cataloged Forever addon folders when actually registered with Core; a pack logically disabled by Core remains resident and is still measured. `/forever memory` in Core only directs you to `/fperf` and never causes memory-refresh calls itself.

On-demand tests, example one-command-per-block outputs, user-reported historical Dashboard observations, and missing-API fallbacks are in [PERFORMANCE_TESTING.md](PERFORMANCE_TESTING.md). **This pack's live beta compatibility is not yet established**, and its current module list must be expanded explicitly when future shipped folders are added. `test-addons/` probes and third-party addons are deliberately out of scope.

## Gold Sprint 1: feedback loop (draft PR #29)

`ForeverGold` 0.2 adds **only a manual, session-only wallet baseline and signed net change**. The current coin balance and its positive/negative movement are not evidence of *income* or *profit*. This pack remains independently installable with Core. See [GOLD_TESTING.md](GOLD_TESTING.md) for every separately submitted command, expected output, and PASS/FAIL. **No live Gold v0.2 behavior has been established yet**; user feedback on build 70338 will guide Sprint 2.

## Professions Sprint 2 (PR #31)

`ForeverProfessions` 0.2, independently installed with Core 0.2+, adds `/fprof snapshot`, `/fprof progress`, and `/fprof clear`. It reads `GetProfessions`/`GetProfessionInfo` **only on request**, stores at most five name/rank pairs for the session and does not equate an absent skill to an untrained one. Secondary Fishing/Cooking skills are reported **only if the client exposes them**. Live API compatibility on build 70338 remains unverified; see [PROFESSIONS_TESTING.md](PROFESSIONS_TESTING.md).

## Professions Sprint 3 (draft PR #33)

`ForeverProfessions` v0.3 adds the **independent manual skill-goal** feature: `/fprof goal <name> <rank>`, `/fprof goals`, `/fprof ungoal <name>`, `/fprof goals clear`. Goal rank must be within the current client-reported cap. At most five session-only targets are stored; no additional game APIs, continuous timers, or SavedVariables. Snapshot/progress works separately and is not erased by goal updates. **New goal feature NOT YET LIVE TESTED** on build 70338; see [PROFESSION_GOALS_TESTING.md](PROFESSION_GOALS_TESTING.md).

## Fishing Sprint 4 (draft PR #35)

`ForeverFishing` v0.2 adds **only explicit manual** `/ffish log <count> <fish name>`, `/ffish catches`, and `/ffish clear`. This does **not** inspect bags, loot or inventory or prove any fish was caught. Ten species max, local session memory only, no new APIs or background events, no guild/network sends. The older `/ffish` requires a separate `C_TradeSkillUI` path, not established by the user's `/fprof` live success. See [FISHING_TESTING.md](FISHING_TESTING.md). Live v0.2 test PENDING on build 70338.
