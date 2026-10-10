# Acceptance checklist and expected-output testing protocol

This is the **required structure for future in-game testing instructions and PR acceptance**. Feature-specific future commands in this file are proposals, **not commands already implemented**.

## Evidence levels

1. **Designed:** specs and proposed commands only.
2. **Automated tested:** pure Lua tests and mocks pass on an exact SHA; this does NOT certify the game client.
3. **Client tested:** actual game output compared to expected on a named client build and character; screenshots or pasted text archived.
4. **Verified persistence:** reload and full client quit/restart both passed with a unique sentinel, when persistence is relevant.
5. **Released:** review, compatibility, accessibility/performance and Blizzard policy gate passed; code is publicly viewable if distributed.

Never promote designed or mock-tested work to live-verified without a real observed result. Allow partial/manual tests to remain partially accepted.

## Required format for *every* player-facing test

**Test ID / milestone and build:** e.g. M2-PROFILE-01; WoW Forever build <full build>, interface 16001 (if still current).

**Setup:** Character and addon packages/versions. Do not hardcode Uddergrief as production identity.

**Command or action:** Exact text to type or UI steps.

**Expected output:** Show literal matching output in a text code block. Mark nondeterministic fields with angle-bracket placeholders and describe allowed changes. Do not guess actual level/realm/session money or claim test commands exist before implementation.

**Feature verified:** The exact property/API/behavior.

**PASS if:** Precise criteria, including no Lua errors or unintended action.

**FAIL if:** What deviation means the feature cannot be marked complete.

**Actual observed:** User text/screenshot, date, character and full build; where applicable, commit SHA. Do not silently correct mismatches.

**Retest triggers:** New game build, migrations, changed save format, changes to modules/contracts.

## Current milestone M0: v0.4 real command checks

The only commands below are **already implemented in the v0.4 development branch**, not necessarily main.

**M0-01 / page one:** type:

~~~text
/fj journal
~~~

Expected *format* if the player has progressed since the screenshot:

~~~text
Forever Journal: Mulgore starter catalog: <COMPLETED>/12 flagged complete, <ACTIVE> active.
Forever Journal: Page 1/2 - curated sample, NOT all Mulgore quests.
Forever Journal: [done] The Hunt Begins (ID 747)
Forever Journal: [done] A Humble Task (part 1) (ID 752)
Forever Journal: [<STATUS>] Simple Note (Warrior) (ID 3091)
Forever Journal: [<STATUS>] The Hunt Continues (ID 750)
Forever Journal: [<STATUS>] A Humble Task (part 2) (ID 753)
Forever Journal: [<STATUS>] Rites of the Earthmother (early) (ID 755)
Forever Journal: Not flagged does not mean available; use /fj journal <page>.
~~~

Placeholder values may legitimately change as Uddergrief plays. STATUS ∈ done, ready, active, not flagged. PASS if source-completed IDs 747 and 752 remain done, header and catalog qualifier are correct and no Lua error. FAIL if missing, false completion flags or claims to represent all Mulgore quests.

**M0-02 / invalid page:** type:

~~~text
/fj journal 0
~~~

Expected exact:

~~~text
Forever Journal: Usage: /fj journal [page number]
~~~

PASS if usage output appears and no Lua error. FAIL otherwise.

**M0-03 / page two:** type:

~~~text
/fj journal 2
~~~

Expected header exact:

~~~text
Forever Journal: Page 2/2 - curated sample, NOT all Mulgore quests.
~~~

The user-provided 2026-10-10 screenshot already shows this header and a catalog summary of 3/12 complete, 2 active with several second-page rows. One screenshot alone does not prove all rows or cold-restart behavior. PASS for pagination header and nonempty list; additional complete-list checks remain.

## Proposed future tests — NOT YET IMPLEMENTED

These commands/output formats are **design targets only**. When their milestone PR is implemented, replace the example with the actual exact output copied from code and verify against that.

**M1-01 / installed pack discovery** — proposed command: /forever modules

~~~text
Forever Core: module journal - installed, eligible, enabled
Forever Core: module warrior - installed, eligible, enabled
Forever Core: module cooking - not installed
~~~

The exact message layout is **not specified yet**. PASS condition: installed vs absent vs incompatible vs per-character-disabled are distinguishable without inventing a running module, and two packs register independently. A test showing only Core also passes if no optional packs appear.

**M2-01 / character isolation** — proposed command: /forever profile

~~~text
Forever Core: character <NAME> - <REALM>; profile <PROFILE_NAME>
~~~

Switch to another character, change only that character's module toggle, and switch back. PASS if each retains its own selection; FAIL for leakage or a name-based collision.

**M2-02 / persistence** — proposed command/UI: set a unique sentinel in settings such as 'test-2026-10-10-ud-01', use /reload, verify, fully quit WoW, reopen, verify *the same* sentinel.

~~~text
After /reload: <SENTINEL> retained
After full restart: <SENTINEL> retained
~~~

Those are **test-report templates, not game output**. FAIL if restart loses the value; show session-only warning and block claims of durable lifetime data.

**M3-01 / optional dashboard** — proposed action: open the dashboard via the agreed slash command, close it, disable Warrior and reopen.

Expected **UI state**, not literal chat text: only installed/eligible/enabled module tabs appear; no disabled pack continues event updates; Journal works without Dashboard. PASS on actual UI observation; fail for stale hidden data or runtime errors.

**M4–M10 / optional pack contract** — run a pack alone with Core, run it with another optional pack absent, disable it for the current character, switch characters and inspect its UI. PASS if data is accurate on the real API, unavailable values are explicit, and no unrelated pack breaks.

## General release gate (applies to every PR)

- [ ] Source is clear, Lua 5.1-compatible, appropriately documented with module and public function comments.
- [ ] API evidence references and exact client build recorded in docs/API_NOTES.md.
- [ ] CI succeeded on the exact candidate SHA; test output recorded, no invented results.
- [ ] Relevant game test steps, expected output and actual output recorded with pass/fail notes.
- [ ] Feature can be switched off without unintended event work; optional dependency absence handled.
- [ ] Separate characters do not share preferences or histories accidentally.
- [ ] Restart retention tested when relying on SavedVariables.
- [ ] No false zone completion, no fake auction data, no class/combat automation or secret-value bypass.
- [ ] Documentation and changelog updated; installation and rollback verified.
- [ ] Blizzard UI Add-On Development Policy and source visibility checked before public distribution.

This checklist describes *release readiness*. It does not claim every checked milestone has been implemented.
