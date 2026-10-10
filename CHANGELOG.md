# Changelog

All notable user-facing changes are recorded here.

## [Unreleased]

### Fishing 0.3 / Cooking 0.2 — optional windowless skill candidate (unverified in game)

- Standalone on-demand skill readers try up to five sparse GetProfessions/GetProfessionInfo positions with strict rank validation, then the previous open-profession-window fallback. They do not depend on the optional Professions pack.
- Cooking adds manual ingredient needs, listing, one-entry removal and clear; capped at ten labels/9999 per label; state clears on Core disable or UI reload. No recipe scanning, bag claims or item operations.
- Fishing manual tally unchanged. No events, timers, background reading, SavedVariables or transmitted data; mock Lua 5.1 and all-pack CI tests. New window-closed game behavior still UNVERIFIED.


### Integrated full-load validation and single-subscriber efficiency

- New `tests/test_full_integration.lua` loads **all twelve actual addon TOCs** together with separate per-addon namespaces, mocks PLAYER_LOGIN, verifies all eleven optional Core registrations, local commands, paginated Dashboard, on-demand full-pack memory, module disable isolation and Guild consent OFF/no sending. Distinct from in-game testing on Forever build 70338.
- Core's shared event dispatcher avoids allocating and sorting an ID snapshot for the **one-subscriber** case; retains deterministic copied-ID ordering for two or more subscribers and unchanged error isolation. Lua mock test verifies no sort during single Guild CHAT_MSG_ADDON dispatch; real FPS/CPU savings unmeasured.
- Developer source ZIP validator rejects non-UTF-8 Lua/assets, Lua bytecode, NULs and terminal controls. Packaging tests verify these failures and accept readable UTF-8 comments; does not itself license code or authorize a release.


### Integrated modular DEV candidate — Dashboard v0.2, bundle builder (UNVERIFIED FULL CLIENT)

- Offline deterministic local test ZIP builder with Core-only, Tank, Professions and Full profiles and explicit include/exclude options. Validates interface-16001 manifests, Core dependencies, TOC Lua paths, file bounds and symlinks; never installs or releases automatically.
- ForeverDashboard v0.2 uses one lazily created window and font label, at most six module rows per page, and on-demand `/fdash next|prev|status`, while retaining v0.1 toggle behavior.
- Added Python standard-library packaging/security regression tests, standalone Lua 5.1 Dashboard tests, one-pass full-suite field test and evidence-based current market comparison. No CPU/FPS benchmark claims or new runtime dependencies.
- Individual packs remain independently installable/uninstallable with only Core as hard dependency. Public release/license and actual beta all-pack verification remain pending.



### ForeverFishing 0.2.0 — Sprint 4 manual catch notes (NOT GAME-TESTED)

- Preserves `/ffish` read-only Fishing skill view and v0.1 safe fallback.
- Adds `/ffish log <count> <fish name>`, `/ffish catches` and `/ffish clear` for **user-entered notes**, not verified catches or actual inventory.
- Local session-only bounded counts (10 species, 9999 per species); Core disable/reload cleans up. No Lua hooks, game loot APIs, fishing automation, transmissions or SavedVariables.
- Dedicated Lua 5.1 mocked tests and separate per-command live test plan. User acceptance on beta build 70338 is pending.



### ForeverProfessions 0.3.0 — Sprint 3 manual skill targets (NOT LIVE VERIFIED)

- Adds session-only manual profession goals: `/fprof goal <name> <rank>`, `/fprof goals`, `/fprof ungoal <name>`, `/fprof goals clear`.
- Allows up to five read-only goals for client-observable professions, including Fishing/Cooking when actually readable. Shows points remaining or reached without assuming unlearned skills or fixed caps.
- Preserves prior snapshot/progress and old `/fprof` output. Core disable/reload clears both independent session stores.
- No additional WoW APIs, timers, SaveVariables, crafting, farming automation, sharing or telemetry. New goal feature awaits real-beta testing; Lua 5.1 mock suite covers goal isolation and safety.



### ForeverProfessions 0.2.0 — Sprint 2, skill snapshots (NOT YET LIVE VERIFIED)

- Preserved `/fprof` read-only profession names and ranks.
- Added `/fprof snapshot`, `/fprof progress` and `/fprof clear` for bounded, manually requested session skill comparisons.
- Reports +/−/0 changes against matching skill names without inferring a gain/loss from missing game API data. Fishing/Cooking may appear when exposed by the client.
- No background events, timers, SavedVariables, gameplay actions or external sharing; disabling via Core discards state. Lua 5.1 mocks cover sparse profession slots and defensive API behavior.



### ForeverGold 0.2.0 — Sprint 1 manual wallet change (NOT LIVE VERIFIED)

- Keeps the original on-demand `/fgold` wallet display.
- Adds `/fgold baseline`, `/fgold delta` and `/fgold clear` for **net wallet change only**, never earnings or profit.
- One Lua-memory value per session; no SavedVariables, polling, event handlers, transactions or automatic actions.
- Core Gold disable clears the baseline; malformed/unavailable API results fail visibly; mock tests added.



### ForeverPerformance 0.1.0 (M12, optional development candidate, NOT YET LIVE TESTED)

- New independent performance diagnostics pack measures *known Core-registered Forever addon* attributed KB on demand.
- Displays bounded total/top-3 summary, optional per-addon details, manually captured session baseline and signed differences. Core `/forever memory` only points to the optional pack.
- No background events, timers, automatic garbage collection, SavedVariables, CPU profiling or external telemetry. Missing/invalid memory APIs report unavailable instead of inventing zeroes.
- Earlier user-measured Dashboard usage fell from 150.07 KB to 31.90 KB after manual GC; this is an observation, not proof of absence of memory leaks.



### Journal 0.5.0 Core integration candidate (MOCK TESTS ONLY)
- Imported existing 0.4.0 quest log/history/curated Tauren Mulgore data into modular suite development branch.
- Journal now depends on Core 0.2.0 and follows character-level module enablement for data-reading commands.
- No gameplay automation, new quest-catalog completion assertions or historical progress persistence added.


### Modular suite candidates (UNVERIFIED IN FOREVER GAME)
- Core 0.2.0 adds character-scoped experimental profile preferences and cold-restart marker testing.
- Dashboard, Inventory, Gold, Professions, Fishing, Cooking, Explorer and Guild independently register with Core.
- Guild sharing is OFF by default, manually announced with consent, rate-limited and session-only.
- None of these modules does combat automation, unsolicited marketing or external telemetry; data availability is explicitly reported.
- Journal v0.4 remains separate in PR #4; Warrior is inherited from PR #22. Public player release is not yet approved.


### ForeverWarrior 0.1.0 (M9 starter, stacked PR; NOT LIVE TESTED)
- Added optional Warrior-only level-banded advice for dungeon progression, solo leveling and professions.
- Added `/fw plan`, `/fw ready`, `/fw professions`, `/fw status` and `/fw version`.
- All readiness items are explicitly manual; no gameplay automation, character history, equipment scanning or talent inference.
- Added Lua 5.1 mocked tests and individual in-game acceptance commands with expected outputs.


### ForeverCore 0.1.0 (M1 candidate, NOT YET IN-GAME TESTED)
- Added separately installable ForeverCore with a versioned feature registry and runtime character context.
- Added eligibility and minimum-version checks, active capability discovery, session-only toggles and shared event subscriber cleanup.
- Added two optional developer-only probe addon fixtures, exact expected-output test instructions and mocked Lua tests.
- No per-character persistent preferences, GUI, or integration with ForeverJournal yet.

- Repository engineering standards, agent instructions, tests, and API notes established.

## [0.1.0] - 2026-10-10

- Added an early Forever Journal addon skeleton.
- Added /fj, /fj version, and /fj progress <completed> <total>.
- Added a pure-Lua completion calculator and standalone tests.
- No automatic tracking, persistent saved data, or UI window yet.
