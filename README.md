# WoW Forever Addons

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
