# Changelog

All notable user-facing changes are recorded here.

## [Unreleased] — 0.2.0 candidate

- Added on-demand read-only listing of accepted quests: `/fj quests [page]`.
- Added quest objective inspection: `/fj quest <ID>`.
- Added current area identification: `/fj zone`.
- Kept legacy help/version/progress commands.
- Added quest API documentation and mock-based Lua 5.1 tests.
- **Not yet verified inside WoW: Forever.** No full quest database, completion history, settings persistence, or graphical window.

## [0.1.0] - 2026-10-10

- Added an early Forever Journal addon skeleton.
- Added /fj, /fj version, and /fj progress <completed> <total>.
- Added a pure-Lua completion calculator and standalone tests.
- No automatic tracking, persistent saved data, or UI window yet.
- The player confirmed 0.1.0 loads and its three commands function on interface 16001.
