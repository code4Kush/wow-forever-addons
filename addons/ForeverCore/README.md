# Forever Core 0.1.0 — M1 candidate

A separate, installable WoW: Forever addon with a documented cross-addon namespace. **Not yet verified on the player's Forever client.**

Core includes player identity, feature-pack registration, semantic version checks, class/race eligibility callbacks, active capability discovery, session-only logical toggles, and a shared event frame that unsubscribes disabled or failing modules.

**Not implemented:** durable SavedVariables, per-character profile selection, dashboard UI, automatic installation/discovery of unloaded addons, or gameplay automation. Those belong to later milestones. `ForeverJournal` currently works independently; it is NOT yet wired into this new registry.

## Install

Copy `addons/ForeverCore/` into the game client's `Interface/AddOns/ForeverCore/` folder. Run `/reload`.

For additional contract verification, optionally copy `test-addons/ForeverProbeGeneral/` and `test-addons/ForeverProbeWarrior/` into `Interface/AddOns/`. These are developer fixtures, not player-facing releases. Enable them in the game's AddOns menu. Their `## Dependencies: ForeverCore` metadata requests that Core load first.

See `docs/CORE_TESTING.md` for **exact expected outputs, dynamic fields, and PASS/FAIL requirements**.

## Commands

| Command | Purpose |
| --- | --- |
| `/forever` | Help and session-only warning |
| `/forever version` | Core version |
| `/forever character` | Live character name/realm/race/class/level |
| `/forever modules` | Registered/active/disabled/ineligible module states |
| `/forever status <id>` | A single registered module's state |
| `/forever disable <id>` | Stop module event work this session |
| `/forever enable <id>` | Request reactivation this session |
| `/forever listeners <EVENT>` | Count active module subscribers |

A feature pack's Lua can't be unloaded mid-session, and a module absent from the registry could be absent, disabled by the game's addon manager, or not successfully loaded.

## Design

Read `docs/CORE_CONTRACT.md`. This release exposes `_G.ForeverCore` as the single global API. Separate WoW addons register descriptor tables; Core calls `Initialize/Enable/Disable` and dispatches declared events when active. Optional provider labels are discovery metadata, not permission to invoke new game actions.

## Testing

Run `lua5.1 tests/test_core.lua` and all pre-existing tests. GitHub Actions verifies mocked Lua behavior, **not actual game loading**.
