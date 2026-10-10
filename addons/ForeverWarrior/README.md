# Forever Warrior — advisory MVP (0.1.0 candidate)

Optional, independently installable Warrior progression companion for **WoW: Forever**.
Originally designed for Uddergrief (Tauren Warrior) but never tied to one name,
realm or race. This pack implements a limited slice of [M9 / issue #14](https://github.com/code4Kush/wow-forever-addons/issues/14).

**Status: code candidate, not yet tested in the actual Forever client.**
It is built against ForeverCore 0.1.0 from PR #18; **Core M1 is not yet merged**.
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
| `/fw ready` | Five unchecked, manually verified dungeon-prep reminders |
| `/fw professions` | Your optional Mining/Blacksmithing/Fishing/Cooking/First Aid plan |
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
