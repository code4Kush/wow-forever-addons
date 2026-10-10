# Changelog

All notable user-facing changes are recorded here.

## [Unreleased]

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
