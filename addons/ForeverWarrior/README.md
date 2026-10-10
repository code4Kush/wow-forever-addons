# Forever Warrior — manual dungeon readiness (0.2.0 beta candidate)

Optional, independently installable Warrior progression companion for **WoW: Forever**.
Originally designed for Uddergrief (Tauren Warrior) but never tied to one name,
realm or race. This pack implements a limited slice of [M9 / issue #14](https://github.com/code4Kush/wow-forever-addons/issues/14).

**Status:** v0.1 Warrior guidance received a player-reported live PASS during full-suite testing. The new v0.2 manual readiness marks remain game-untested.
It requires ForeverCore 0.2+; all development branches remain unmerged.
ForeverWarrior is a draft stacked PR and must not be treated as shipped.

## Installation

Install the separate `addons/ForeverCore/` folder from the M1 integration branch,
then install `addons/ForeverWarrior/` into the client's `Interface/AddOns/`
directory. Both folders must be named as shown. Enable both in the AddOns menu.
A reported beta location on macOS is:

`/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/`

The `ForeverWarrior_Camelot.toc` manifest declares `## Dependencies: ForeverCore`,
so this package will not function without the matching Core version. Verify
`/run print(GetBuildInfo())` and the interface version on your installed client;
16001 is the documented beta target, not a universal guarantee.

## Commands

Each command must be entered individually. Exact expected chat output for a
level-4 Warrior and testing instructions live in [docs/WARRIOR_TESTING.md](../../docs/WARRIOR_TESTING.md).

| Command | Meaning |
| --- | --- |
| `/fw` | Available commands and manual-data warning |
| `/fw version` | Pack version |
| `/fw status` | Core registration and activation status |
| `/fw plan` | Level-banded combat, dungeon, profession and next-goal advice |
| `/fw ready` | Five manual dungeon-prep reminders and session progress |
| `/fw ready done <1-5>` | Mark a reminder as checked by the player |
| `/fw ready undo <1-5>` | Uncheck a reminder |
| `/fw ready reset` | Clear all session readiness marks |
| `/fw professions` | Gathering and optional crafting tradeoffs without claiming trained skills |
| `/forever disable forever-warrior` | Stop character guidance for this session |
| `/forever enable forever-warrior` | Reactivate guidance for this session |

## Boundaries and guarantees

- Does not read actual talents, skill points, gear, inventory, quests or Auction House data.
- Does not record kills, loot, fishing catches, gold income, dungeon runs or raid performance.
- Does not use combat logs; community beta reports say combat-log API access is absent.
- Doesn't cast spells, automate pulls/gear changes, interact with protected APIs or transmit data.
- Advice is informational, not a talent simulator or equipment recommendation engine.
- Reads Core's logged-in character snapshot plus the player's current level via
  `UnitLevel("player")` when available. If unavailable, it uses Core's login snapshot
  (which may be stale after leveling). No persistence is implemented.
- ForeverCore logical toggles remain session-only until M2 is completed.
- Warrior eligibility uses the game's `WARRIOR` class token, not the displayed name.

## Design

- `Bootstrap.lua`: private pack namespace, chat output.
- `Plans.lua`: pure-Lua curated level bands and manual readiness checklist.
- `Readiness.lua`: user-controlled session-only checkmarks, no API reads.
- `Module.lua`: ForeverCore registration and Warrior-class restriction.
- `Commands.lua`: safe on-demand read-only commands.

Plans are easy to update as new Forever patches change talents/dungeon balance.
No permanent talent point sequences are hardcoded because the October beta moved
Protection talent positions.

## Development verification

`lua5.1 tests/test_warrior.lua` tests the pure plan data, module eligibility,
slash command behavior and session disable gate with mocked WoW/Core APIs.
The repository CI is intended to run it for pull requests. Mocked CI **does not
certify game-client compatibility**. Never mark an in-game test PASS without
the player's actual confirmation.
