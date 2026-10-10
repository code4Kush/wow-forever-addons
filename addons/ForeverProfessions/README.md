# ForeverProfessions v0.3.0 — manual skill snapshots and goals

**State:** v0.3 goals candidate built on [draft PR #31](https://github.com/code4Kush/wow-forever-addons/pull/31); **not yet verified in the real Forever game client**. Target: player-observed **WoW Forever 1.60.1, build 70338, interface 16001** (October 2026). User-reported in-game smoke tests 1–6 **passed** for v0.2's `GetProfessions`/`GetProfessionInfo` readout and snapshot, without captured skill numbers. The new goal feature has **NOT YET BEEN VERIFIED IN GAME**.

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

## Sprint 3 — Manual profession targets

Add up to **five current-profession targets** for the current game session. Goals are separate from the old skill snapshot. **No polling, saved history, recipe databases, gathering automation, crafting, or transactions.**

**Set Fishing target** (only works when the game reports Fishing with maximum rank ≥75):

```text
/fprof goal Fishing 75
```

Expected format:

```text
Forever Professions: Goal set: Fishing 75 (currently <RANK>; <REMAINING> remaining; session only).
```

If not readable, exact: `Forever Professions: Profession not readable now: Fishing.` If cap too low, exact format: `Forever Professions: Goal exceeds Fishing maximum (<MAX>).`

**Set Cooking target** (same actual skill/cap caveat):

```text
/fprof goal Cooking 75
```

Expected format:

```text
Forever Professions: Goal set: Cooking 75 (currently <RANK>; <REMAINING> remaining; session only).
```

**View all goals**:

```text
/fprof goals
```

Expected with two accepted goals:

```text
Forever Professions: Goals: 2 target(s) (session only).
Forever Professions: Fishing: <RANK>/75; <REMAINING> remaining.
Forever Professions: Cooking: <RANK>/75; <REMAINING> remaining.
```

A reached goal prints `reached.`; an unreadable one prints `unreadable now; target <N>; remaining unknown.`

**Remove Fishing without affecting other goals**:

```text
/fprof ungoal Fishing
```

Expected exact if set: `Forever Professions: Goal removed: Fishing.`

**Clear goals only**:

```text
/fprof goals clear
```

Expected exact: `Forever Professions: Goals cleared (session only).`

**Help/version** remain available when Core disables the module, and `/fprof clear` remains exclusively the **snapshot** clear command. Core disable clears both temporary stores; interface reload clears all goals.

Read the [new Sprint 3 in-game test guide](../../docs/PROFESSION_GOALS_TESTING.md) for a carefully controlled checklist with **each game slash command in its own code block and immediately adjacent expected output**. Neither Fishing nor Cooking is presumed to be learned or at a fixed skill cap; choose an actual readable profession and target if needed.
