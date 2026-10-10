# Fishing v0.3 / Cooking v0.2 — standalone on-demand professions and prep test

**Status: UNTESTED IN THE REAL CLIENT.** This proposal in [draft PR #39](https://github.com/code4Kush/wow-forever-addons/pull/39) is stacked on draft integration PR #37. Previous player evidence on Forever beta `1.60.1`, build `70338`, interface `16001` confirmed Fishing v0.2 and Cooking v0.1 needed their respective profession windows open. `/fprof` successfully used `GetProfessions` and `GetProfessionInfo`, but this does NOT establish that the new pack behavior works until retested.

**Do not switch to this development branch or install these files until finishing the user's CURRENT full-suite memory test.** They are separate commits and versions; mixing them would invalidate the measured baseline. The user chooses when to test. No merge/release authorization.

## Install later, not during current performance baseline

Mac **Terminal**, after quitting WoW:

~~~sh
cd ~/Developer/wow-forever-addons
git status --short
git fetch origin
git switch --track origin/feat/forever-fish-cook-independent-read
python3 tools/build_dev_bundle.py --check --profile full
python3 tools/build_dev_bundle.py --profile professions --output dist/ForeverProfessions-windowless-DEV.zip
~~~

If the branch exists already, `git switch feat/forever-fish-cook-independent-read`. Preserve uncommitted work before switching. If you want to test with all packs, generate `--profile full` instead; each module is an independent directory under the zip. Ensure you keep the exact checkout SHA for evidence.

**WoW only accepts ONE slash command per chat submission.** Type every fenced line separately.

## Skill reading with profession windows CLOSED — main new test

Close both Cooking and Fishing profession windows. Do not infer current skill levels from previous screenshots; compare to `/fprof` on your live character.

**Test 1 — Fishing version:**

~~~text
/ffish version
~~~

Expected exact:

~~~text
Forever Fishing: Version 0.3.0
~~~

**Test 2 — Fishing skill with its profession window closed:**

~~~text
/ffish
~~~

Expected if new client list path succeeds (skill amount dynamic):

~~~text
Forever Fishing: Fishing: <SKILL>/<MAX> (profession list).
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

If it instead returns `Fishing skill not readable; open Fishing UI and retry.`, record **windowless read FAIL/unknown**, then open Fishing UI and retry the SAME command separately. The UI fallback may still pass.

**Test 3 — Cooking version:**

~~~text
/fcook version
~~~

Expected exact:

~~~text
Forever Cooking: Version 0.2.0
~~~

**Test 4 — Cooking skill with its profession window closed:**

~~~text
/fcook
~~~

Expected if new list path succeeds:

~~~text
Forever Cooking: Cooking: <SKILL>/<MAX> (profession list).
Forever Cooking: Recipes and ingredient counts are NOT scanned.
~~~

If unavailable, report no-window result separately, open Cooking UI and retry to verify old fallback. Do not claim window-independent compatibility from open-UI results.

## Cooking manual ingredient notes — never verified inventory

**Test 5 — Empty note list:**

~~~text
/fcook needs
~~~

Expected exact:

~~~text
Forever Cooking: No manual ingredients planned. Use /fcook need <count> <ingredient>.
~~~

**Test 6 — Manually plan three fish:**

~~~text
/fcook need 3 Raw Brilliant Smallfish
~~~

Expected exact:

~~~text
Forever Cooking: Planned manually: Raw Brilliant Smallfish +3 (need 3).
~~~

This is only a note. The addon does NOT confirm those fish are in your bags or part of a trained recipe.

**Test 7 — Show planned ingredient:**

~~~text
/fcook needs
~~~

Expected:

~~~text
Forever Cooking: Ingredient plan: 3 units across 1 labels (manual; not bag contents).
Forever Cooking: Raw Brilliant Smallfish: need 3 (player-entered).
~~~

**Test 8 — Accumulate same ingredient regardless of case:**

~~~text
/fcook need 2 raw brilliant smallfish
~~~

Expected exact:

~~~text
Forever Cooking: Planned manually: Raw Brilliant Smallfish +2 (need 5).
~~~

**Test 9 — Verify accumulation:**

~~~text
/fcook needs
~~~

Expected 5 fish across 1 name, not new label or a bag count.

**Test 10 — Clear notes:**

~~~text
/fcook clear
~~~

Expected exact:

~~~text
Forever Cooking: Manual ingredient plan cleared (session only).
~~~

**Test 11 — Verify empty after clear:**

~~~text
/fcook needs
~~~

Expected exact same empty note line as Test 5.

## Isolation checks after optional-module disable

**Test 12 — Disable Cooking without uninstalling:**

~~~text
/forever disable cooking
~~~

Expected:

~~~text
Forever Core: cooking: disabled (session only).
~~~

**Test 13 — An inactive module must not read or mutate notes:**

~~~text
/fcook needs
~~~

Expected:

~~~text
Forever Cooking: Module not active: disabled.
~~~

**Test 14 — Re-enable Cooking:**

~~~text
/forever enable cooking
~~~

Expected:

~~~text
Forever Core: cooking: enable requested (session only).
~~~

**Test 15 — Verify manual state cleared:**

~~~text
/fcook needs
~~~

Expected empty list line. Fishing catch notes and unrelated modules should be unaffected.

## Acceptance status

- [ ] Real client build and exact installed Git SHA captured.
- [ ] Window-closed Fishing/Cooking rank reads match `/fprof` (independent list route).
- [ ] Cooking ingredient notes bounded, session-only, clear and Core-disable cleanup.
- [ ] Existing manual Fishing tally remains unchanged and usable.
- [ ] No crash/combat taint, networking, automatic item use, polling or profile changes.
- [ ] All mocked Lua 5.1 suites and safe bundle build validated on exact head.
- [ ] Reviewed license, IP, public policy and security approval, owner authorizes any merge/player release separately.

A mock PASS never substitutes for a real-beta PASS; actual result screenshots should be recorded per step.
