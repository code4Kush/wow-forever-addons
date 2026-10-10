# ForeverProfessions v0.3 manual goal tests — WoW Forever beta

**Status: MOCK TESTS ONLY until the user runs this on the actual game.** Target last-confirmed client is **Forever 1.60.1 / build 70338 / Oct 9 2026 / interface 16001**. An automatic game update may change the build or APIs. Record exact user output, PASS/FAIL and (if known) local Git commit.

**IMPORTANT:** Every WoW slash command below must be submitted **individually**. Do not paste several chat commands at once.

## Install from draft PR #33 (or linked active goals PR)

The package remains independent; only ForeverCore 0.2+ and the ForeverProfessions directory are needed. This branch is stacked on unmerged Professions v0.2 PR #31, Gold #29, Performance #27 and earlier drafts.

In **Mac Terminal**, not WoW chat:

~~~sh
cd ~/Developer/wow-forever-addons
git status --short
git fetch origin
git switch --track origin/feat/forever-professions-skill-targets
rsync -av addons/ForeverProfessions/ "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverProfessions/"
~~~

Preserve uncommitted changes before switching. If the branch already exists locally, use `git switch feat/forever-professions-skill-targets`. Enable ForeverProfessions in the AddOns menu.

## A. Safe initial verification

**A1 — Submit:**

~~~text
/reload
~~~

Expected: normal interface reload without Lua errors or unsolicited addon chat.

**A2 — Submit:**

~~~text
/fprof version
~~~

Expected exact:

~~~text
Forever Professions: Version 0.3.0
~~~

**A3 — Submit:**

~~~text
/fprof
~~~

Expected format (variable number of skills; values must match the game UI):

~~~text
Forever Professions: Known professions: <SKILL> <RANK>/<MAX>; <SKILL> <RANK>/<MAX>
~~~

If unavailable, `Profession API unavailable on this build.`, `Profession details unavailable.`, or `No readable trained professions returned by the client.` is a safe fallback, **not** proof the character is untrained. Record the result and stop feature validation.

**A4 — Submit before adding a goal:**

~~~text
/fprof goals
~~~

Expected exact:

~~~text
Forever Professions: No goals. Use /fprof goal <profession> <rank>.
~~~

## B. Set and view a goal

**B1 — Submit a goal for a currently readable profession:**

~~~text
/fprof goal Fishing 75
~~~

Expected format **only if Fishing is readable and its current cap is 75 or higher**:

~~~text
Forever Professions: Goal set: Fishing 75 (currently <RANK>; <REMAINING> remaining; session only).
~~~

If Fishing is not readable, the expected exact diagnostic is:

~~~text
Forever Professions: Profession not readable now: Fishing.
~~~

If Fishing's actual reported maximum is less than 75, expected format:

~~~text
Forever Professions: Goal exceeds Fishing maximum (<MAX>).
~~~

This is a legitimate **safe fallback PASS**, but it does not confirm the goal was created. Use another actually readable profession and an appropriate rank if necessary. Never silently assume Fishing exists or has a particular cap.

**B2 — Submit a second goal when Cooking is readable:**

~~~text
/fprof goal Cooking 75
~~~

Expected when current cap allows 75:

~~~text
Forever Professions: Goal set: Cooking 75 (currently <RANK>; <REMAINING> remaining; session only).
~~~

If Cooking is absent or capped below 75, the diagnostic is the same pattern as Fishing. If neither is available, use a currently readable profession from A3 (such as Mining) and a legal target. That is sufficient to verify goal functionality.

**B3 — Submit:**

~~~text
/fprof goals
~~~

Expected format with two goals:

~~~text
Forever Professions: Goals: 2 target(s) (session only).
Forever Professions: Fishing: <RANK>/75; <REMAINING> remaining.
Forever Professions: Cooking: <RANK>/75; <REMAINING> remaining.
~~~

With one goal, expect `1 target(s)` and one row. The last part is `reached.` when a skill is at or beyond target. If a previously readable skill is missing, expect `<SKILL>: unreadable now; target <TARGET>; remaining unknown.` — **not** an invented zero.

## C. Verify progress during ordinary play

Continue playing normally, training one of your goal professions if possible. The addon does **not** gather, fish, cook or train automatically. Do not purchase, craft, or spend gold only for a test.

**C1 — Submit again:**

~~~text
/fprof goals
~~~

Expected format:

~~~text
Forever Professions: <SKILL>: <NEW_RANK>/<TARGET>; <NEW_REMAINING> remaining.
~~~

The new remaining number should decrease by the actual gained points; if no skill changed, it may remain identical. The skill must never be fabricated.

**C2 — Verify the prior manual snapshot was not reset by setting goals:**

~~~text
/fprof progress
~~~

Expected format if a v0.2 snapshot exists:

~~~text
Forever Professions: Skill progress: <COMPARABLE> comparable; <CHANGED> changed (session only).
~~~

If no snapshot exists, expected exact:

~~~text
Forever Professions: No snapshot. Use /fprof snapshot first.
~~~

Setting goals must not silently create a snapshot.

## D. Independent clearing and Core lifecycle

**D1 — Remove only the Fishing goal:**

~~~text
/fprof ungoal Fishing
~~~

Expected exact if the goal exists:

~~~text
Forever Professions: Goal removed: Fishing.
~~~

If not set, expected exact: `Forever Professions: No goal for: Fishing.`

**D2 — Submit:**

~~~text
/fprof goals
~~~

Expected: all other previously set goals remain, Fishing is no longer listed. The number is reduced by one.

**D3 — Submit:**

~~~text
/fprof goals clear
~~~

Expected exact:

~~~text
Forever Professions: Goals cleared (session only).
~~~

**D4 — Submit:**

~~~text
/fprof goals
~~~

Expected exact:

~~~text
Forever Professions: No goals. Use /fprof goal <profession> <rank>.
~~~

**D5 — Set a goal again** (choose a currently readable profession, example only):

~~~text
/fprof goal Fishing 75
~~~

Expected: same as B1; use actual cap. If unavailable, choose a readable profession and valid target.

**D6 — Submit:**

~~~text
/forever disable professions
~~~

Expected exact:

~~~text
Forever Core: professions: disabled (session only).
~~~

**D7 — Submit:**

~~~text
/fprof goals
~~~

Expected exact:

~~~text
Forever Professions: Module not active: disabled.
~~~

**D8 — Submit:**

~~~text
/forever enable professions
~~~

Expected exact:

~~~text
Forever Core: professions: enable requested (session only).
~~~

**D9 — Submit:**

~~~text
/fprof goals
~~~

Expected exact:

~~~text
Forever Professions: No goals. Use /fprof goal <profession> <rank>.
~~~

## E. Reload reset

**E1 — Set one goal** (example Fishing, if readable and cap allows):

~~~text
/fprof goal Fishing 75
~~~

Expected: the B1 goal acknowledgement. If not possible, choose an actual readable profession.

**E2 — Submit:**

~~~text
/reload
~~~

Expected: reload completes without Lua errors.

**E3 — Submit without adding any goal:**

~~~text
/fprof goals
~~~

Expected exact:

~~~text
Forever Professions: No goals. Use /fprof goal <profession> <rank>.
~~~

## Acceptance and known constraints

- [ ] Version 0.3.0 plus old `/fprof` works correctly.
- [ ] Goals are allowed only for genuinely readable skills, at/below their exposed maximum; Fishing and Cooking are **not presumed** present.
- [ ] Two goals can coexist, be revised and read accurately without periodic scanning.
- [ ] Clear, remove, disable/re-enable, and reload clean up session goals. Snapshot progress remains independently usable.
- [ ] Actual build and outputs documented; no Lua errors, unsolicited chat, automation or telemetry.
- [ ] This does not prove long-term profession completeness, market prices, source rights or live API edge cases. License/security/public release review and merge permission remain necessary.

Mock CI and player-confirmed live results are distinct evidence; do not close this issue or publish an addon release without both appropriate tests and explicit owner approval.
