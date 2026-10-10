# WoW: Forever API and compatibility notes

Last documentary review: 2026-10-10. Unless explicitly labeled **player-observed**, references below are external reports and **not** evidence that an API works in the actual Forever beta client. Live test evidence is source-scoped; verification of one function does not establish every feature.

## M1 Core candidate — conventional APIs still requiring live Forever verification

- `PLAYER_LOGIN`, `CreateFrame`, `Frame:RegisterEvent`, `Frame:UnregisterEvent`, `Frame:SetScript` for a single Core event bridge.
- `UnitName`, `UnitClass`, `UnitRace`, `UnitLevel`, `UnitGUID`, `GetRealmName` for runtime character identity (some can be unavailable).
- `SlashCmdList` registration for `/forever` diagnostic commands.
- `## Dependencies: ForeverCore` manifest load-order behavior with `_Camelot.toc` must be proven on the target 16001 client.

Reference: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API ; https://warcraft.wiki.gg/wiki/TOC_format

These APIs and loading conditions are **NOT YET GAME-TESTED in the new Core**. No Core-only session, cross-character or persistence pass has been recorded. Tests are documented in `docs/CORE_TESTING.md`.

## M9 ForeverWarrior starter — new use of character APIs

- `ForeverCore.GetCharacter()` and `ForeverCore.GetModuleStatus()` are the draft M1 integration contract, not built-in Blizzard functions. M1 has partial player-reported live acceptance; M9 integration remains **NOT TESTED IN GAME**.
- `UnitLevel("player")` is invoked only when the player deliberately requests `/fw plan` to refresh the level after login, with the Core identity snapshot as a fallback. No scanning/recording occurs. Conventional read-only API: https://warcraft.wiki.gg/wiki/API_UnitLevel . Target: Forever beta interface 16001; actual current build has not been captured for M9; evidence type: source/reference only.
- `SlashCmdList.FOREVERWARRIOR` and `SLASH_FOREVERWARRIOR1` register read-only chat commands; their M9 integration is **NOT TESTED IN GAME**. Reference: https://warcraft.wiki.gg/wiki/Creating_a_slash_command .
- **Not used:** talent tree/trait APIs, gear/skill/loot APIs, combat-log events, automatic purchases, casting or protected operations. Community reports on beta interface 16001 indicate combat-log access may be unavailable: https://wowforeverguides.com/addons/api-cheatsheet . Treat this as an external beta report, not a blanket permanent guarantee.
- October 1, 2026 beta reports describe changed Warrior talent positions: https://us.forums.blizzard.com/en/wow/t/bug-warrior-talent-tree-has-been-completely-messed-up-in-oct-1sts-patch/2369273 . Avoid encoding an unverified fixed talent path into player guidance.

## Recorded beta baseline

- WoW: Forever 1.60.1 beta uses TOC Interface 16001 in community-verified builds.
- The beta product folder has been reported as _classic_beta_.
- A modern/Mainline-style WoW UI API is used despite Forever's classic game design.
- Addon manifests named with _Camelot.toc have been used by Forever addon developers.

References:
- https://github.com/Thunderz96/forever-addon-kit
- https://github.com/Atraeau/WoW-Addons
- https://github.com/Atraeau/WoW-Addons/blob/main/docs/api/README.md
- https://www.curseforge.com/wow/addons/quest-master

## Known risks

- Existing Classic Era API examples may call removed globals; inspect the modern C_* namespaces first.
- Modern WoW includes restrictions around protected actions and secret values. This project will not attempt to bypass them.
- A 2026-09 beta report identified saved-variable loading problems. Persistent completion data must be verified across **cold game restarts** before relying on it.

## APIs used by initial scaffold

- CreateFrame("Frame") and PLAYER_LOGIN to mark readiness: conventional WoW event use, **not individually validated in Forever by this project**.
- SlashCmdList and SLASH_FOREVERJOURNAL1 to register /fj: conventional WoW slash-command use, **not individually validated in Forever by this project**.
- No quest, map, collection, combat, or persistence APIs are currently invoked.

## Evidence convention

Each future API entry should include function/event name, source URL, client build, date, whether tested in-game, expected behavior, and limitations. Never translate reported beta behavior into an unconditional guarantee.

## Suite candidate APIs (2026-10-10; **NOT YET LIVE VERIFIED**)

| Pack | API | Source / specific limits |
| --- | --- | --- |
| Dashboard | CreateFrame, UIParent, CreateFontString, CreateTexture | Conventional WoW UI frame APIs; on-demand only, no protected actions |
| Inventory | C_Container.GetContainerNumSlots, C_Container.GetContainerItemInfo | https://warcraft.wiki.gg/wiki/API:C_Container.GetContainerItemInfo ; only bags 0–4, nil is unknown |
| Gold | GetMoney | Read-only current player copper; no claim of profit/market price |
| Professions | GetProfessions, GetProfessionInfo | Conventional UI profession functions, must be game-tested for Forever beta |
| Fishing/Cooking | C_TradeSkillUI.GetBaseProfessionInfo | https://warcraft.wiki.gg/wiki/API:C_TradeSkillUI.GetBaseProfessionInfo ; available when the corresponding skill UI is displayed; absence not proof of unlearned |
| Explorer | C_Map.GetBestMapForUnit, C_Map.GetMapInfo | https://warcraft.wiki.gg/wiki/API:C_Map.GetBestMapForUnit ; returns lowest UI map, not zone completion |
| Guild | C_ChatInfo.RegisterAddonMessagePrefix, C_ChatInfo.SendAddonMessage, CHAT_MSG_ADDON | https://warcraft.wiki.gg/wiki/API_C_ChatInfo.RegisterAddonMessagePrefix and https://warcraft.wiki.gg/wiki/API:C_ChatInfo.SendAddonMessage ; prefix <=16 bytes, payload <=255 bytes; messages throttled, sending accepted doesn't prove delivery |
| Core Profiles | SavedVariablesPerCharacter | Experimental Forever beta retention; user cold-restart test required |

These are source-reviewed API candidates, not assertions that a particular WoW beta build safely supports them. Any real-client failures must be documented against the exact full build before advertising features to others.

## ForeverPerformance 0.1.0: memory attribution APIs (2026-10-10)

- `UpdateAddOnMemoryUsage()`: manually requests a refresh of WoW's per-addon memory attribution, used exactly once per on-demand `/fperf` reading. Reference: https://warcraft.wiki.gg/wiki/API_UpdateAddOnMemoryUsage .
- `GetAddOnMemoryUsage(addonName)`: returns attributed addon memory in **kilobytes**; code uses named addon folders, as observed working in the player's earlier direct `/run` test. Reference: https://warcraft.wiki.gg/wiki/API_GetAddOnMemoryUsage .
- **Observed player evidence:** WoW Forever beta interface `16001`, October 10 2026, with `type()` confirming both functions; three named addon readings, plus Dashboard measurements 11.32 → 140.982421875 → 150.068359375 → 31.8955078125 KB following user-initiated `collectgarbage("collect")`. Full numeric build **not recorded** and no new ForeverPerformance code running at that time.
- **Safety:** Both API calls are checked with `type()`/`pcall()`. Missing/negative/nonfinite readings are errors, not values to quietly total as zero. The pack never triggers `collectgarbage` or runs polling. It only includes known Core-registered Forever addons, including logically disabled packages that are still loaded; it does not claim to enumerate every WoW addon or system RAM.
- **Player-observed new pack evidence on `1.60.1` / `70338` / `Oct 9 2026` / `16001`:** `/fperf version` and `/fperf memory` produced valid game-chat output. Four loaded packs totaled 116.44 KB in the initial screenshot. A later `/fperf delta` showed +2.89 KB versus a 109.88 KB baseline, `/fperf details` showed a four-pack total of 114.71 KB, and clearing the baseline correctly prevented a later delta. The Core `/forever memory` navigation command worked as expected. See `docs/PERFORMANCE_TESTING.md` and issue #26 for exact evidence levels.
- **Still NOT VERIFIED:** New pack's idle CPU/performance over long play sessions, exact installed code SHA, post-`/reload` baseline reset (output not captured), actual combat guard operation, all missing-API scenarios, and public release readiness. CPU profiling API support is **not established**, so do not report fabricated CPU metrics.

## ForeverGold 0.2 — manual net wallet comparison (2026-10-10)

- **Candidate client API:** `GetMoney()` returns a current-character copper amount on conventional WoW clients. Reference: https://warcraft.wiki.gg/wiki/API_GetMoney . It is only invoked following explicit user `/fgold`, `/fgold baseline` or `/fgold delta` commands. No transaction classification is assumed.
- **Observed client baseline:** The user has identified WoW Forever `1.60.1`, full build `70338`, date Oct 9 2026, interface `16001`. This **does not itself verify `GetMoney`**; the new Gold v0.2 feature is still **NOT TESTED IN-GAME**. Exact game-client verification is tracked in `docs/GOLD_TESTING.md`.
- **Robustness:** `ReadCopper` checks API existence and validates a finite, nonnegative integer value under `pcall`; missing/secret/malformed values produce an unavailable diagnostic, never zero. Avoids sampling during combat where `InCombatLockdown` is supported.
- **State:** One session-only number in `Tracker.lua`; clearing and Core disable release it. Reload resets it. No SavedVariables, polling, external requests, combat automation, gold transaction ingestion, AH valuation or inventory queries.
- **Semantics:** signed delta is `current wallet copper - manually captured starting wallet copper`, **not gold earned, farm efficiency or profit**. Any player expenditure or transfer changes the delta.

## ForeverProfessions 0.2 — optional manual skill snapshots (2026-10-10)

- **Game API candidates:** `GetProfessions()` returns up to five positions, including possible nil primary slots before populated secondary skill positions. `GetProfessionInfo(position)` may return trained display name, rank and maximum. References: https://warcraft.wiki.gg/wiki/API_GetProfessions ; https://warcraft.wiki.gg/wiki/API_GetProfessionInfo . These remain **UNVERIFIED in the player's Forever 1.60.1 build 70338**; the player's prior proven client build does not automatically verify these profession APIs.
- **Player-data semantics:** `/fprof` reads a bounded, on-demand set of validated returned positions. Neither missing slots nor zero readable records prove a skill was untrained. Name/rank matching within a session is a convenience, not a stable cross-locale or persisted profession ID.
- **New behaviors:** `/fprof snapshot` stores at most five names and ranks in session Lua memory; `/fprof progress` rereads manually and shows signed rank delta for matching names. Newly readable and no-longer-readable skills are explicitly incomparable (not a false increase/loss). `/fprof clear`, Core disable and interface reload drop the snapshot.
- **Safety:** nil/protected/unavailable/malformed APIs fail explicitly, no estimated ranks. Queries are guarded during combat when `InCombatLockdown` is available; none are run on timers or background events. No protected crafting/gameplay calls.
- **Live acceptance:** `docs/PROFESSIONS_TESTING.md` provides each WoW slash command in an independent code block and dynamic output format. No live PASS should be recorded until actual results on numeric build 70338 are received.

## ForeverProfessions v0.3 manual skill goals (2026-10-10)

- **APIs remain:** `GetProfessions` and `GetProfessionInfo`; see their source links in the v0.2 section above. This sprint adds **no new WoW API**. The user reported PASS for the v0.2 in-game read/snapshot tests on previously confirmed Forever 1.60.1 build 70338, **without sharing exact profession names/ranks**. v0.3 targets themselves are **NOT YET GAME-TESTED**.
- `/fprof goal <name> <rank>` validates a player-entered positive whole-number target against a **currently readable**, client-reported skill maximum. No fixed Fishing/Cooking cap is assumed. Names are compared case-insensitively within a session; changed locale/name can make a skill unreadable.
- `/fprof goals` reads existing visible ranks on demand (never in a timer, frame update, or game event), lists up to 5 goals, and treats missing/unreadable skills as **remaining unknown**, not rank zero.
- `/fprof ungoal <name>` and `/fprof goals clear` make no game API calls; Core disable and interface reload clear session goals. `/fprof clear` continues clearing only the unrelated v0.2 session snapshot. The two stores never persist across reloads.
- **No crafting, auto-fishing, vendor actions, telemetry, or saved account/game data.** Manual test: [PROFESSION_GOALS_TESTING.md](PROFESSION_GOALS_TESTING.md).

## ForeverFishing v0.2 — manual catch tally (2026-10-10)

- **No new game API.** The original `/ffish` invokes `C_TradeSkillUI.GetBaseProfessionInfo()` only when explicitly requested, requires the Fishing trade skill view to expose the correct profession and retains an unavailable fallback. This particular API path is **not yet game-tested** for ForeverFishing on the player's client build 70338. The player's `/fprof` output relied on distinct `GetProfessions`/`GetProfessionInfo` APIs, so don't transfer that PASS as evidence to `C_TradeSkillUI`.
- **New commands:** `/ffish log <1-999> <fish name>`, `/ffish catches`, `/ffish clear` operate only on local, **explicitly player-entered notes** and make **zero game API calls**. Counts are not validated catches, inventory, market sales, cooking ingredients or gold income.
- **Bounds:** maximum 10 species, 9999 per species, 99999 total; 60-byte name bound; reject WoW color/link escape pipe and control characters; preserve first entered display spelling and group case-insensitively. Output is bounded to at most 11 lines per request. No SavedVariables or events; Core disable and interface reload clear all notes.
- **Evidence:** Lua 5.1 mocks are a separate test layer; new client feature is **NOT YET VERIFIED on Forever 1.60.1 build 70338**. Exact single-command manual acceptance plan at [FISHING_TESTING.md](FISHING_TESTING.md).

## On-demand Fishing/Cooking profession-list trial — PR #39, 2026-10-10

- Observed in prior user-reported game testing: Fishing v0.2 and Cooking v0.1 only displayed their rank when their respective profession windows were open. Last independently captured beta build 1.60.1 / 70338, interface 16001; current installed SHA not captured.
- Separately live-tested ForeverProfessions used the conventional GetProfessions and GetProfessionInfo API to show Fishing/Cooking ranks. Sources: https://warcraft.wiki.gg/wiki/API_GetProfessions and https://warcraft.wiki.gg/wiki/API_GetProfessionInfo .
- This NEW candidate lets each independently installed Fishing v0.3 / Cooking v0.2 reader request those APIs directly, on demand, with pcall, combat guard, no holes assumed in up to five slots, strict finite rank bounds and exact English-name matching. Unknown API data falls back to the prior C_TradeSkillUI.GetBaseProfessionInfo for the corresponding open window.
- The new code is mocked-only so far: window-independent behavior and non-English locale matching are NOT confirmed on the live beta. Missing data is never presented as unlearned/zero.
- Manual Cooking ingredient planning never inspects the bags, spells, recipes, learned skills, network or gameplay events. No optional-pack dependency introduced.
