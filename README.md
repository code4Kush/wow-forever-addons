# WoW Forever Addons

A readable, documented collection of World of Warcraft: Forever addons.

**Status:** Early development. Forever Journal **0.3.0 candidate** adds read-only per-quest historical completion flag queries and player identity. It is **not yet tested in-game**. Core 0.2.0 quest and zone features were user-verified on interface 16001.

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
  test_questlog.lua
  test_history.lua
.github/workflows/
  lua-tests.yml
AGENTS.md
CODING_STANDARDS.md
CONTRIBUTING.md
CHANGELOG.md
~~~

## First addon: Forever Journal

- `/fj` — help
- `/fj version` — show addon version
- `/fj progress 3 5` — calculate 60% completion from two manually supplied counts
- `/fj zone` — report current map/area
- `/fj quests [page]` — show six active quest-log entries per page
- `/fj quest <ID>` — show quest objectives and readiness to turn in
- `/fj status <ID>` — query a historical completion flag, then active status if needed
- `/fj character` — identify the current player in-game

This is **not** a comprehensive zone completion tracker. It reads the active log and checks historical completion for a specific quest ID on demand; it does not provide a full database of known quests. See `addons/ForeverJournal/README.md`.

## Get started

1. Read `docs/DEVELOPMENT.md` and `docs/API_NOTES.md`.
2. Copy **all files** under `addons/ForeverJournal` to the beta client's `Interface/AddOns/ForeverJournal` directory.
3. Log into the game, verify the addon is enabled, and type `/fj version`.
4. Run all tests locally: `lua5.1 tests/test_progress.lua`, `lua5.1 tests/test_questlog.lua`, and `lua5.1 tests/test_history.lua`.

The recorded beta interface number is 16001; verify client API behavior after updates. Avoid assuming that the current API matches Classic Era simply because the setting is vanilla-inspired.

## Source of truth

- `AGENTS.md`: requirements for Codex and other coding agents.
- `CODING_STANDARDS.md`: rules for readable, maintainable Lua.
- `docs/ARCHITECTURE.md`: dependency and module boundaries.
- `docs/API_NOTES.md`: evidence-based API and beta compatibility notes.
- `docs/TESTING.md`: tests and in-game verification.
- `CONTRIBUTING.md`: change and review workflow.

No license has been selected. Do not assume permission to redistribute this repository or third-party code.
