# Changelog

All notable user-facing changes are recorded here.

## [Unreleased] — 0.3.0 candidate

- Added `/fj status <questID>` to query historical completion flags and distinguish active quest log status.
- Added `/fj character` to display the current character's identity without hardcoding it.
- Added separate documented QuestHistory and Character modules and Lua 5.1 mock tests.
- No quest database, saved variables, zone completion totals, or gameplay automation.
- Not yet verified in the live WoW: Forever client.

## [0.2.0] — user-verified core behavior, release pending

- Added on-demand read-only listing of accepted quests: `/fj quests [page]`.
- Added quest objective inspection: `/fj quest <ID>`.
- Added current area identification: `/fj zone`.
- Kept legacy help/version/progress commands.
- Added quest API documentation and mock-based Lua 5.1 tests.
- Verified in the client's interface 16001: active quests, objective counts, readiness, zone, refreshed objectives and post-turn-in quest removal. Some edge cases and full client build remain unverified.
- No full quest database, historical completion flag query, settings persistence, or graphical window in 0.2.0.

## [0.1.0] - 2026-10-10

- Added an early Forever Journal addon skeleton.
- Added /fj, /fj version, and /fj progress <completed> <total>.
- Added a pure-Lua completion calculator and standalone tests.
- No automatic tracking, persistent saved data, or UI window yet.
- The player confirmed 0.1.0 loads and its three commands function on interface 16001.
