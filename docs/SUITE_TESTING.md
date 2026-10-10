# Forever Suite v0.1 modules + Core 0.2 — one-command live test plan

**State:** NOT YET VERIFIED IN-GAME. These commands target interface 16001 based on earlier M1/Journaling tests. This document distinguishes expected output from real player observations. Record the exact full build and date, screenshot/pasted output, and PR head SHA for every PASS.

**IMPORTANT:** Submit every WoW slash command **individually**, one code block at a time. Do not paste a group of slash commands into a single chat entry.

## Installation

This suite branch is **stacked on the unmerged Warrior PR #22** and contains experimental Core 0.2 and independent addon directories. It does not automatically include the updated Journal v0.4 (separate draft PR #4). Preserve the currently installed Journal files until their release branch is reconciled.

From the repository root, install Core and only the specific feature packs you want to test. Example Terminal command for Core (shell commands may be batched, unlike WoW slash commands):

~~~sh
rsync -av addons/ForeverCore/ "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverCore/"
~~~

For a chosen feature pack, use the equivalent `rsync -av addons/ForeverGold/ ".../Interface/AddOns/ForeverGold/"` with the directory changed appropriately. This is a beta candidate, not a public release archive. Disable/remove old `test-addons/ForeverProbe*` from the AddOns menu to avoid extra diagnostics.

**PASS** only when the installed pack loads without Lua errors and matches its relevant expected output. **FAIL** if missing, wrong game data, an unexpected API error, spam, or protected/secret action violation.

## Core 0.2 and per-character preferences

**Command 1:**

~~~text
/forever version
~~~

Expected exact (chat colors ignored):

~~~text
Forever Core: Version 0.2.0
~~~

**Command 2:**

~~~text
/forever profile
~~~

Expected format (dynamic preference count `<COUNT>`):

~~~text
Forever Core: Profile schema 1: writable (restart unverified); <COUNT> preference(s).
~~~

If there is an unexpected/older schema, a clear **unavailable** diagnostic is acceptable and editing must be blocked. A writable value on this client **does not** prove cold-restart persistence.

**Command 3:**

~~~text
/forever marker test-ud-01
~~~

Expected exact:

~~~text
Forever Core: Profile marker set: test-ud-01 (verify after full restart).
~~~

**Command 4:**

~~~text
/forever marker
~~~

Expected exact:

~~~text
Forever Core: Profile marker: test-ud-01 (restart unverified).
~~~

**Command 5:**

~~~text
/forever pref gold off
~~~

Expected exact (ForeverGold must be installed):

~~~text
Forever Core: gold: preference off (restart unverified).
~~~

**Command 6:**

~~~text
/fgold
~~~

Expected exact while Gold is disabled:

~~~text
Forever Gold: Module not active: disabled.
~~~

**Command 7:**

~~~text
/forever pref gold on
~~~

Expected exact:

~~~text
Forever Core: gold: preference on (restart unverified).
~~~

**Cold restart test (mandatory):** Fully quit WoW and reopen. Repeat Command 4 and confirm the **same** marker survives; test a different character with a different marker and return. If the game loses values, mark profile persistence **FAIL** and don't advertise lifetime tracking or durable toggles. User must not treat a simple /reload as proof of cold-restart support.

## Dashboard

**Command:**

~~~text
/fdash
~~~

Expected exact chat line:

~~~text
Forever Dashboard: Dashboard shown.
~~~

Expected UI: movable, unprotected frame containing only currently active registered module names. Enter the same single command again to hide; expected exact chat `Forever Dashboard: Dashboard hidden.` Verify no combat taint. In combat an explicit unavailable message is acceptable.

## Inventory

**Command:**

~~~text
/finv
~~~

Expected when `C_Container` APIs return complete safe data:

~~~text
Forever Inventory: Bags 0-4: <OCCUPIED>/<SLOTS> occupied slots; <QUANTITY> total items (not AH prices).
~~~

Placeholder counts vary; compare to actual bags. If API unavailable: `Forever Inventory: Bag API unavailable on this build.` or `Forever Inventory: Bag counts unavailable; no totals were inferred.`. No bank, gear, market value or sold-item operations.

## Gold

**Command:**

~~~text
/fgold
~~~

Expected format:

~~~text
Forever Gold: Wallet: <G>g <S>s <C>c (current character; not earnings).
~~~

Must match your actual coin total. If `GetMoney` is missing, expected exact: `Forever Gold: Wallet API unavailable on this build.`

## Professions

**Command:**

~~~text
/fprof
~~~

Expected format when client supplies skills:

~~~text
Forever Professions: Known professions: <PROFESSION> <SKILL>/<MAX>; <OTHER_PROFESSION> <SKILL>/<MAX>
~~~

Number/order of entries varies; no source means `Forever Professions: Profession API unavailable on this build.` or `Forever Professions: No readable trained professions returned by the client.`. Not proof of crafting recipes.

## Fishing

**Command (with Fishing profession window open if learned):**

~~~text
/ffish
~~~

Expected format if returned by client:

~~~text
Forever Fishing: Fishing: <SKILL>/<MAX> (open profession window).
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

If Fishing skill cannot be read, first line is exactly `Forever Fishing: Fishing skill not readable; open Fishing UI and retry.`, second line unchanged. **Do not assume not learned** from an unavailable window.

## Cooking

**Command (with Cooking window open if learned):**

~~~text
/fcook
~~~

Expected format:

~~~text
Forever Cooking: Cooking: <SKILL>/<MAX> (open profession window).
Forever Cooking: Recipes and ingredient counts are NOT scanned.
~~~

If not readable, first line `Forever Cooking: Cooking skill not readable; open Cooking UI and retry.` (second unchanged). No automatic cooking or invented recipe counts.

## Explorer

**Command:**

~~~text
/fexplore
~~~

Expected format:

~~~text
Forever Explorer: Current UI map: <MAP_NAME> (ID <MAP_ID>); NOT exploration credit.
~~~

The map may be a subzone, not Mulgore's parent. If unknown `Forever Explorer: Current UI map unavailable.` is expected, and no zone completion percentage is claimed.

## Guild privacy and compatibility experiment

**Important:** Guild messages use real WoW servers. Only test with a consenting guildmate after agreeing to the experiment. No auto-join, auto-announcement, or quest/inventory sharing.

**Command 1:**

~~~text
/fguild status
~~~

Expected format on a compatible client:

~~~text
Forever Guild: Sharing: OFF; API registered; session only.
~~~

If messaging prefix registration is unavailable, substitute `API unavailable`; still OFF.

**Command 2:** attempt to transmit without consent:

~~~text
/fguild announce
~~~

Expected exact:

~~~text
Forever Guild: Opt in first: /fguild optin
~~~

PASS if zero messages sent.

**Command 3:** deliberate consent:

~~~text
/fguild optin
~~~

Expected exact:

~~~text
Forever Guild: Opted in for this session. Nothing sent; use /fguild announce.
~~~

**Command 4:** deliberate manual version-only announcement:

~~~text
/fguild announce
~~~

Expected exact if local API accepts the request:

~~~text
Forever Guild: Announcement requested; delivery not confirmed.
~~~

If not guilded or API unavailable, a clear failure diagnostic is correct; do not report peers until two users confirm. The guild version-only payload is fixed as `HELLO|0.1.0` without quest or player data. A repeated immediate announcement should return `Forever Guild: Rate limited: wait 30 seconds between announcements.`.

**Command 5:** display responding opt-in peers:

~~~text
/fguild peers
~~~

Expected format:

~~~text
Forever Guild: <N> recent compatible announcer(s).
~~~

Names are transport-supplied sender labels, **not a verified character identity or authorization**. Peer list is bounded/ephemeral.

**Command 6:** opt out:

~~~text
/fguild optout
~~~

Expected exact:

~~~text
Forever Guild: Opted out. Session peer list cleared.
~~~

PASS if no further peers or sends without renewed consent, including after /reload.

## Existing independent Journal/Warrior regression

`/fj` should keep working on the independently installed Journal v0.4 beta, though that PR is still unmerged and does not use Core's profile toggles. Existing optional Warrior PR #22 remains class-gated; do not force Warrior on other classes. Both remain separate acceptance tracks.

## Final acceptance gates

- [ ] Lua 5.1 CI PASS on exact PR SHA (mocks).
- [ ] Each addon loads alone beside Core, without unrelated feature packs installed.
- [ ] Real data verified for Inventory/Gold/Professions/Explorer; Fishing/Cooking may legitimately report not readable.
- [ ] Dashboard no combat taint and appropriate frame behavior.
- [ ] SavedPreferences cross-character and full quit/restart test.
- [ ] Guild consent OFF, validation/throttle/optout verified; two-player messaging is optional until explicitly arranged.
- [ ] No secret-value reads or data exfiltration, copied assets, memory access or automated gameplay.
- [ ] API evidence recorded with exact full beta build and screenshots. Do not label a mock-only feature as ready for public release.

## Journal Core bridge v0.5 (new separate branch, NOT IN-GAME VERIFIED)

Install Core 0.2 and the Journal directory from this branch. Existing `/fj` commands retain their read-only meanings and starter catalog page layout. Use each command separately.

**Command:**

~~~text
/fj version
~~~

Expected exact:

~~~text
Forever Journal: Version 0.5.0
~~~

**Command:**

~~~text
/forever pref journal off
~~~

Expected exact:

~~~text
Forever Core: journal: preference off (restart unverified).
~~~

**Command:**

~~~text
/fj journal
~~~

Expected exact while disabled:

~~~text
Forever Journal: Journal module not active: disabled.
~~~

**Command:**

~~~text
/forever pref journal on
~~~

Expected exact:

~~~text
Forever Core: journal: preference on (restart unverified).
~~~

**Command:**

~~~text
/fj journal 2
~~~

Expected beginning after re-enabling (progress numbers depend on character and may have changed):

~~~text
Forever Journal: Mulgore starter catalog: <DONE>/12 flagged complete, <ACTIVE> active.
Forever Journal: Page 2/2 - curated sample, NOT all Mulgore quests.
~~~

PASS if quests 747 and 752 remain historically flagged completed (when applicable), the catalog is explicitly *not* the entire Mulgore quest set, a disabled Journal doesn't read quest data, and no Lua errors occur. FAIL for false zone completion, incorrect player, incomplete Core class filter, or unexpected unavailable API. Client character/game build and actual outputs are needed; mock tests are not game verification.

## Integrated development candidate (2026-10-10)

This earlier suite plan covers initial Core 0.2 candidates and may include
older module versions. The newer stacked integration branch updates
Dashboard to v0.2, Gold v0.2, Professions v0.3 and Fishing v0.2.
For a **complete modular dev ZIP** and current one-command-at-a-time
acceptance steps, prefer [FULL_SUITE_TESTING.md](FULL_SUITE_TESTING.md).
Mocks and individual earlier user-reported passes do not establish
compatibility of all packs installed together on game build 70338.
