# Forever Warrior M9 starter — in-game acceptance

**Status:** Not tested in a live WoW Forever client. Stacked on draft Core M1
[PR #18](https://github.com/code4Kush/wow-forever-addons/pull/18).
Current intended test character: Uddergrief, Tauren Warrior, level 4.
Replace the level in expected text when you have leveled.

**One command per chat submission.** WoW is not a batch command processor.
Enter each command separately, read its result, then move to the next.

## Install and build verification

Install both `addons/ForeverCore` and `addons/ForeverWarrior` from the feature
branch into the client's `Interface/AddOns` folder, with both AddOns enabled.
The packs are separate directories. Do not install from default `main` yet.

**Command 1:**

~~~text
/reload
~~~

**Expected:** the interface reloads without a Lua error; both AddOns enabled.
**PASS** only with no blocked/incompatible add-on or Lua errors.

**Command 2:**

~~~text
/run print(GetBuildInfo())
~~~

**Expected:** the current game version, build/date/interface appear (dynamic).
Record the exact output. Interface 16001 is the documentary target, not a
substitute for this actual client check.

## M9-W01 — Core registration and Warrior eligibility

**Command 3:**

~~~text
/forever status forever-warrior
~~~

**Expected exact output:**

~~~text
Forever Core: forever-warrior v0.1.0: active [warrior.level-plan, warrior.manual-readiness]
~~~

**PASS:** module is active on a Warrior, and neither addon reports errors.

**Command 4:**

~~~text
/fw status
~~~

**Expected exact output:**

~~~text
Forever Warrior: forever-warrior: active
~~~

## M9-W02 — Level 4 plan (read only)

**Command 5:**

~~~text
/fw plan
~~~

**Expected text on level-4 Uddergrief (chat color omitted):**

~~~text
Forever Warrior: Uddergrief level 4: Mulgore foundations (1-9).
Forever Warrior: Combat: Practice controlled pulls, rage use and safe positioning.
Forever Warrior: Dungeon: Plan your first Ragefire Chasm run in your teens.
Forever Warrior: Professions: Start Fishing and Cooking; collect cloth for First Aid.
Forever Warrior: Next: Reach level 10; inspect the current Protection talents.
~~~

**PASS:** current character name and level are correct and the five lines above
match, without any automatic spells, bag inspections or equipment changes.
If Uddergrief has leveled beyond 9, expect the corresponding higher level band;
record what was observed rather than claiming an exact level-4 match.

## M9-W03 — Manual dungeon and profession preparation

**Command 6:**

~~~text
/fw ready
~~~

**Expected exact output:**

~~~text
Forever Warrior: Dungeon readiness checklist (MANUAL; not checked by addon):
Forever Warrior: [ ] Equip a one-handed weapon and shield for dungeon tanking.
Forever Warrior: [ ] Repair equipment and train available Warrior abilities.
Forever Warrior: [ ] Bring food, bandages and appropriate consumables.
Forever Warrior: [ ] Collect dungeon quests and review the route.
Forever Warrior: [ ] Check healer mana and party readiness before pulling.
~~~

**PASS:** list is visibly unchecked and does not claim that gear or supplies
have been verified.

**Command 7:**

~~~text
/fw professions
~~~

**Expected exact output:**

~~~text
Forever Warrior: Profession goals only; your skills and bags are NOT scanned.
Forever Warrior: Primary: Mining + Blacksmithing (ore, gear, useful crafts).
Forever Warrior: Secondary: Fishing + Cooking + First Aid (food, income, survival).
Forever Warrior: Gold: Compare raw materials with finished goods before selling.
~~~

**PASS:** guidance appears and no nonexistent fishing catches, skill levels
or earnings are asserted.

## M9-W04 — Session disable and recovery

**Command 8:**

~~~text
/forever disable forever-warrior
~~~

**Expected exact output:**

~~~text
Forever Core: forever-warrior: disabled (session only).
~~~

**Command 9:**

~~~text
/fw plan
~~~

**Expected exact output:**

~~~text
Forever Warrior: Module disabled (session only). Use /forever status forever-warrior for details.
~~~

**Command 10:**

~~~text
/forever enable forever-warrior
~~~

**Expected exact output:**

~~~text
Forever Core: forever-warrior: enable requested (session only).
~~~

**Command 11:**

~~~text
/fw plan
~~~

**Expected:** the level-appropriate five-line plan from M9-W02 appears again.
**PASS:** disabling blocks advice; re-enabling restores it without duplicating
modules or altering other packs.

## M9-W05 — Character changes and regression

On a **non-Warrior** character with both addons enabled, enter individually:

~~~text
/forever status forever-warrior
~~~

**Expected exact output:**

~~~text
Forever Core: forever-warrior v0.1.0: ineligible (Warrior only) [warrior.level-plan, warrior.manual-readiness]
~~~

Then enter individually:

~~~text
/fw plan
~~~

**Expected exact output:**

~~~text
Forever Warrior: Module ineligible (Warrior only). Use /forever status forever-warrior for details.
~~~

**PASS:** non-Warriors get no Warrior plan and no Lua errors.

On Uddergrief, confirm the pre-existing Journal still responds (if installed):

~~~text
/fj
~~~

**Expected:** installed Forever Journal help, not overwritten by /fw.

Fully quit and restart the client. All M1 logical toggles are **session-only**
and should reset; there are no saved variables in the new Warrior pack.
No new permanent character state is expected.

## Report template

- Character, class and level:
- Game client full version/build/interface:
- Installed addon branches/SHA:
- M9-W01: PASS/FAIL, observed output:
- M9-W02: PASS/FAIL, observed output:
- M9-W03: PASS/FAIL, observed output:
- M9-W04: PASS/FAIL, observed output:
- M9-W05: PASS/FAIL, observed output:
- Lua errors or unexpected actions:
- Screenshot or copied actual chat output for any mismatch:

Mocked GitHub Actions is not a live client PASS. Keep M9 open until appropriate
game testing, code review and supporting dependencies have been accepted.
