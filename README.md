# WoW Forever Addons

> **Integrated modular DEV candidate (draft PR #37; no public release):** Twelve independent addon directories now support a reproducible **offline** developer ZIP: Core-only, Tank, Professions, Full, or custom subsets. Dashboard v0.2 paginates Core module statuses without background polling. [Build instructions](docs/FULL_SUITE_TESTING.md) · [Market/architecture comparison](docs/MARKET_AND_PERFORMANCE.md) · [Integration PR #37](https://github.com/code4Kush/wow-forever-addons/pull/37). Initial component in-game passes apply only to earlier versions on Forever build 70338; the **full integrated candidate remains NOT LIVE VERIFIED**. Full source license, public security and release approval remain outstanding.


A readable, documented collection of World of Warcraft: Forever addons.

**Status:** ForeverCore M1 is in a draft PR with partial player-reported in-game PASS; other acceptance steps remain. The optional ForeverWarrior 0.1.0 starter exists on a stacked feature branch and is NOT yet game-tested. The existing Journal 0.1.0 on main remains unchanged; Journal 0.2–0.4 features are in separate review branches.

## Guiding principles

- Make the code easy to understand six months later.
- Keep each addon installable on its own.
- Favor small modules and explicit dependencies over abstractions.
- Verify Forever-specific API behavior on the actual client build.
- Never automate gameplay or bypass Blizzard addon restrictions.
- Keep source, documentation, tests, and changelog together.

## Repository layout

~~~text
addons/
  ForeverCore/
    ForeverCore_Camelot.toc
    Bootstrap.lua
    Character.lua
    Registry.lua
    Events.lua
    Commands.lua
  ForeverWarrior/
    ForeverWarrior_Camelot.toc
    Bootstrap.lua
    Plans.lua
    Module.lua
    Commands.lua
    README.md
  ForeverJournal/
    ForeverJournal_Camelot.toc
    Core/
    Modules/
    README.md
docs/
  ARCHITECTURE.md
  DEVELOPMENT.md
  TESTING.md
  API_NOTES.md
tests/
  test_progress.lua
  test_core.lua
  test_warrior.lua
test-addons/
  ForeverProbeGeneral/
  ForeverProbeWarrior/
.github/workflows/
  lua-tests.yml
AGENTS.md
CODING_STANDARDS.md
CONTRIBUTING.md
CHANGELOG.md
~~~

## M1 candidate: Forever Core

A separate Core addon provides runtime character identity, a versioned module registry, class eligibility, safe event subscription cleanup, and session-only module toggles. This foundation has **no UI and no SavedVariables**. It currently coexists alongside the existing ForeverJournal but does not yet integrate it. Install and run exact tests from [docs/CORE_TESTING.md](docs/CORE_TESTING.md), then read [docs/CORE_CONTRACT.md](docs/CORE_CONTRACT.md).

## M9 candidate: Forever Warrior

A separate **Warrior-only** addon, stacked on the unmerged ForeverCore M1 PR, offers `/fw plan`, `/fw ready`, and `/fw professions` with level-banded guidance and explicitly **manual** dungeon preparation. It does not inspect talents, professions, gear or combat logs. It is not yet verified in game. See [ForeverWarrior README](addons/ForeverWarrior/README.md) and [WARRIOR_TESTING.md](docs/WARRIOR_TESTING.md) for commands with expected output.

## First addon: Forever Journal

Version 0.1.0 provides a slash command and a pure-Lua completion calculator.

- /fj — display help
- /fj version — show addon version
- /fj progress 3 5 — calculate 60% completion from two manually supplied counts

There is **no automatic quest reading, UI dashboard, or persistent completion tracking yet**.

## Get started

1. Read docs/DEVELOPMENT.md and docs/API_NOTES.md.
2. Copy the folder addons/ForeverJournal to the beta client's Interface/AddOns directory.
3. Log into the game and verify that Forever Journal is enabled in AddOns.
4. Type /fj in chat.
5. Run tests locally with: lua5.1 tests/test_progress.lua

The recorded beta interface number is 16001; verify it on your own client after patches. Avoid assuming the current API matches Classic Era simply because the setting is vanilla-inspired.

## Source of truth

- AGENTS.md: requirements for Codex and other coding agents.
- CODING_STANDARDS.md: rules for readable, maintainable Lua.
- docs/ARCHITECTURE.md: dependency and module boundaries.
- docs/API_NOTES.md: evidence-based API and beta compatibility notes.
- docs/TESTING.md: tests and in-game verification.
- CONTRIBUTING.md: change and review workflow.

No license has been selected. Do not assume permission to redistribute this repository or third-party code.

## Modular suite candidate (PR #24; NOT GAME-VERIFIED)

A new stacked development branch provides Core 0.2 experimental per-character preferences plus individually installable Dashboard, Inventory, Gold, Professions, Fishing, Cooking, Explorer and Guild packs. They do not replace ForeverJournal v0.4 (separate PR #4) or ForeverWarrior (PR #22).

Every pack has its own `_Camelot.toc` and `## Dependencies: ForeverCore`. You may install **only the optional packs you want**. The session-only Guild module does not transmit anything unless the player explicitly opts in and manually announces the minimal version handshake. No quest, inventory or combat information is shared.

See [SUITE_TESTING.md](docs/SUITE_TESTING.md) for separate copyable WoW commands and exact expected output. The API contracts are experimental and do NOT imply a public supported release. Complete licensing, security, full-build client tests and data privacy checks before distribution.

## Journal integration experiment (v0.5)

The Journal Core-bridge branch imports the existing v0.4 read-only quest and starter catalog implementation without changing quest validity semantics. It adds the optional `journal` Core descriptor and respects character preference disabling, while preserving /fj help and version diagnostics. Journal PRs #2/#3/#4 are not automatically merged by this branch; reconcile and retest before shipping.

## Optional ForeverPerformance (M12, development PR #27)

The proposed `ForeverPerformance/` standalone pack adds on-demand `/fperf memory`, `details`, `baseline`, `delta` and `clear` commands. Its small Core shortcut `/forever memory` only points to that package when installed and enabled. Measurements are restricted to a bounded set of known loaded Forever packs, not your computer's entire RAM or every WoW addon.

No background polling, garbage collection, CPU tracing, persisted logs or telemetry. See [ForeverPerformance README](addons/ForeverPerformance/README.md) and the [individual-command in-game test guide](docs/PERFORMANCE_TESTING.md). Previous user-reported Dashboard memory is documented as a benchmark observation, **not** a leak-free certification. This new pack has **NOT yet been verified in the game**.

## ForeverGold Sprint 1 (draft PR #29 — manual wallet net change)

The optional `ForeverGold` pack now has a proposed read-only **session baseline and delta**: `/fgold` retains the current wallet view; `/fgold baseline`, `/fgold delta`, and `/fgold clear` help track net wallet movement while questing. **Net wallet movement is NOT earned gold or profit.** No automatic scanning, purchases, telemetry or persistent history. **Not yet verified on WoW Forever 1.60.1 / 70338**; see [Gold Testing](docs/GOLD_TESTING.md), [ForeverGold README](addons/ForeverGold/README.md), and [PR #29](https://github.com/code4Kush/wow-forever-addons/pull/29). Public release remains gated.

## Professions Sprint 2 (draft PR #31 — skill progress)

The independent ForeverProfessions pack now has a proposed **manual session snapshot and progress** view: `/fprof` shows readable professions, `/fprof snapshot` saves ranks locally, `/fprof progress` shows signed differences, and `/fprof clear` forgets the baseline. If Fishing/Cooking appear among the exposed profession APIs, their skill ranks are included. Missing or newly readable professions remain uncomparable rather than being called untrained or gained from zero.

No automatic harvesting/crafting, event tracking, persistence or telemetry. **Not yet live-verified on Forever 1.60.1 build 70338**. See [professions live test guide](docs/PROFESSIONS_TESTING.md), [ForeverProfessions README](addons/ForeverProfessions/README.md), and [draft PR #31](https://github.com/code4Kush/wow-forever-addons/pull/31). Public release/security/license gates remain pending.

## Professions Sprint 3 — Manual Fishing/Cooking skill goals (draft PR #33)

`ForeverProfessions` v0.3 adds explicitly user-entered, **session-only skill targets**: `/fprof goal Fishing 75`, `/fprof goal Cooking 75`, `/fprof goals`, `/fprof ungoal Fishing`, and `/fprof goals clear`. These names/caps are **examples**, not assertions that a beta character learned those skills. The pack reads ranks only when the user requests a result, with up to five targets and no SavedVariables/polling. The separate `/fprof snapshot|progress` continues working unchanged. New goals have **NOT YET BEEN TESTED IN GAME**. Full guide: [PROFESSION_GOALS_TESTING.md](docs/PROFESSION_GOALS_TESTING.md). No merge or public release approved.

## Fishing Sprint 4 — manual session catch notes (draft PR #35)

Independent `ForeverFishing` v0.2 can record a **user-entered** catch tally while leveling Fishing/Cooking: `/ffish log 3 Raw Brilliant Smallfish`, `/ffish catches`, `/ffish clear`. The example is **not** proof of an actual catch or item ownership. Maximum 10 species, on-demand only, no loot hooks, persistent data, market prices or automated fishing. New pack version **has not yet been tested in game**; [single-command field test](docs/FISHING_TESTING.md), [module README](addons/ForeverFishing/README.md) and [draft PR #35](https://github.com/code4Kush/wow-forever-addons/pull/35). No public player release approved.

## Build and test the complete modular developer suite

Only `ForeverCore` is required. Other packs remain physically independent addon folders with their own `_Camelot.toc`. A bundled ZIP is just a **convenient set of independent folders**, not a monolithic runtime.

Offline source/manifests validation in Terminal:

~~~sh
python3 tools/build_dev_bundle.py --check --profile full
~~~

Create a local dev-only installable ZIP (not a public release):

~~~sh
python3 tools/build_dev_bundle.py --profile full --output dist/ForeverSuite-full-DEV.zip
~~~

Profiles: `minimal` (Core only), `tank`, `professions`, `full` (all twelve directories). Custom selections with `--include ForeverCooking` or `--exclude ForeverGuild`. The builder validates complete Lua TOC ordering/dependencies, excludes probes, enforces safe files and writes a deterministic ZIP with SHA256; **it never touches the game folder**.

One integrated game-testing pass after user installation: [FULL_SUITE_TESTING.md](docs/FULL_SUITE_TESTING.md). For market context, source links and honest performance limitations see [MARKET_AND_PERFORMANCE.md](docs/MARKET_AND_PERFORMANCE.md). No FPS/CPU comparison or complete quest/profession database is claimed. Do not distribute DEV ZIPs as public player releases without license, policy/security review and owner approval.

## New separate Cooking/Fishing test candidate (PR #39)

After the player's integrated game test revealed that Fishing v0.2 and Cooking v0.1 required open profession windows, draft [PR #39](https://github.com/code4Kush/wow-forever-addons/pull/39) adds **standalone, guarded profession-list fallback readers** using the same API family as the live-tested Professions pack. Both addons still need only ForeverCore, not each other or ForeverProfessions. Cooking v0.2 also adds bounded, manual-only ingredient planning with /fcook need, needs, done, clear. Fishing v0.3 retains manual catch notes. This candidate is **NOT verified on the live client yet**, remains separate from the player's active memory benchmark, and is not approved for release.

Test instructions: [Fishing and Cooking windowless candidate](docs/FISHING_COOKING_TESTING.md).
