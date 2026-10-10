# ForeverProfessions v0.2.0 — manual session skill progress

**State:** Proposed [draft PR #31](https://github.com/code4Kush/wow-forever-addons/pull/31); **not yet verified in the real Forever game client**. Target: player-observed **WoW Forever 1.60.1, build 70338, interface 16001** (October 2026). The client APIs `GetProfessions` and `GetProfessionInfo` are conventional references, not yet confirmed working on this exact beta build.

## What the pack does

`/fprof` displays the currently readable trained profession ranks. `/fprof snapshot` saves the current skill levels **only in your current session's Lua memory**, and `/fprof progress` reports how many points changed when you explicitly ask. `/fprof clear` forgets the snapshot.

This can include Mining, Blacksmithing, Fishing and Cooking **when the game exposes those skills**. It does not infer that an absent profession is unlearned. A newly readable profession after baseline is labelled **not comparable**, not falsely gained from zero.

## Installation

Install `ForeverCore` v0.2+ and the complete `addons/ForeverProfessions/` directory into `Interface/AddOns/ForeverProfessions/` on WoW beta, enable both packs in the AddOns menu, then reload. Other packs (Gold, Warrior, Dashboard, Fishing and Cooking) are independently optional; they need not be installed for this module.

See [PROFESSIONS_TESTING.md](../../docs/PROFESSIONS_TESTING.md) for Mac Terminal install steps and individually submitted WoW commands with exact expected output and PASS/FAIL.

## Commands — each must be submitted separately in WoW chat

**List skills:**

~~~text
/fprof
~~~

Expected format:

~~~text
Forever Professions: Known professions: <NAME1> <RANK>/<MAX>; <NAME2> <RANK>/<MAX>
~~~

The list length is variable (1–5). If unavailable, you will see a clear `Profession API unavailable`, `Profession details unavailable` or `No readable trained professions` line instead.

**Save current ranks:**

~~~text
/fprof snapshot
~~~

Expected:

~~~text
Forever Professions: Snapshot saved: <COUNT> readable profession(s) (session only).
~~~

**Compare current to initial skills:**

~~~text
/fprof progress
~~~

Expected header format:

~~~text
Forever Professions: Skill progress: <COUNT> comparable; <CHANGED> changed (session only).
~~~

Per-skill rows show `<NAME>: +<N> skill (was <BEFORE>; now <AFTER>).` or a negative sign for lower reported ranks. New/missing professions use explicit non-comparable messages. If you have not saved a baseline, the exact output is `Forever Professions: No snapshot. Use /fprof snapshot first.`

**Clear:**

~~~text
/fprof clear
~~~

Expected exact:

~~~text
Forever Professions: Snapshot cleared (session only).
~~~

**Version:**

~~~text
/fprof version
~~~

Expected exact:

~~~text
Forever Professions: Version 0.2.0
~~~

**Help:**

~~~text
/fprof help
~~~

Expected:

~~~text
Forever Professions: Commands: /fprof | snapshot | progress | clear | version | help
Forever Professions: Skill changes are session-only; missing skills are unknown.
~~~

## Privacy, memory and limitations

No saved profile, passive profession event tracking, networking, extra addons, auto-fishing, auto-cooking, crafting, sales, recipes or external analytics. At most five name/rank records are retained until `/fprof clear`, Core disables the `professions` module, or the interface reloads. Every profession query is explicitly user-requested and refused during combat if the game's `InCombatLockdown()` guard exists.

The game may return incomplete lists when profession APIs or windows behave differently; unknown does **not** mean untrained, learned, lost or completed. A changed language or API representation may make a name uncomparable. This is independent community source with licensing/public security review pending; no distribution approved.
