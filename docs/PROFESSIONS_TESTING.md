# ForeverProfessions 0.2 — Sprint 2 in-game skill tests

**State:** Developer candidate; **NOT YET VERIFIED IN REAL GAME**. Target: WoW Forever **version 1.60.1 / build 70338 / build date Oct 9 2026 / interface 16001**, as previously captured from the player's client on October 10, 2026. A client update may change APIs. The player must submit **EACH WoW command individually**; WoW chat does not execute copied batches.

## Install

Only `ForeverCore` and `ForeverProfessions` are necessary for this test; other independent feature packs may remain enabled. Work from branch `feat/forever-professions-skill-progress`, stacked as draft PR #31 on unmerged Gold PR #29.

Mac Terminal (shell commands only, NOT WoW chat):

~~~sh
cd ~/Developer/wow-forever-addons
git status --short
git fetch origin
git switch --track origin/feat/forever-professions-skill-progress
rsync -av addons/ForeverProfessions/ "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverProfessions/"
~~~

If the branch already exists, use `git switch feat/forever-professions-skill-progress`. Preserve local modifications before switching branches. `ForeverCore` 0.2 must already be installed. Verify ForeverProfessions is enabled in WoW's AddOns screen.

## A — Exact version and readout

**A1 — one command:**

~~~text
/reload
~~~

Expected: normal client reload, no Lua errors or unsolicited profession messages.

**A2 — one command:**

~~~text
/fprof version
~~~

Expected exact:

~~~text
Forever Professions: Version 0.2.0
~~~

**A3 — one command:**

~~~text
/fprof
~~~

Expected format when the client exposes trained professions:

~~~text
Forever Professions: Known professions: <SKILL1> <RANK>/<MAX>; <SKILL2> <RANK>/<MAX>
~~~

The list can have **one to five** entries. Fishing and Cooking may be included even when primary professions have empty slots. Rank and max must match the actual in-game profession panel. **PASS**: accurate readout with no errors. An empty/unavailable result is a safe fallback, **not proof of no trained skills**:

~~~text
Forever Professions: Profession API unavailable on this build.
~~~

or

~~~text
Forever Professions: No readable trained professions returned by the client.
~~~

or

~~~text
Forever Professions: Profession details unavailable.
~~~

If an unavailable message is shown despite the game's UI displaying trained skills, record the exact output and mark skill tracking **BLOCKED**, not feature PASS.

## B — Manual session snapshot and progress

**B1 — one command before taking any snapshot:**

~~~text
/fprof progress
~~~

Expected exact:

~~~text
Forever Professions: No snapshot. Use /fprof snapshot first.
~~~

**B2 — one command:**

~~~text
/fprof snapshot
~~~

Expected format:

~~~text
Forever Professions: Snapshot saved: <COUNT> readable profession(s) (session only).
~~~

`<COUNT>` is the number of genuinely readable skills, **1–5**; a failed/empty read reports its unavailable reason instead.

**B3 — one command before gaining ranks:**

~~~text
/fprof progress
~~~

Expected format:

~~~text
Forever Professions: Skill progress: <COUNT> comparable; 0 changed (session only).
Forever Professions: <SKILL>: +0 skill (was <RANK>; now <RANK>).
~~~

Up to five per-skill rows follow. All matched, unchanged skills should report +0. **PASS** if the baseline and current ranks agree; no fabricated points.

**B4 — optional normal-play change:** Train Fishing, Cooking or a gathering profession naturally, if currently available. Do not acquire a profession, craft, gather or spend money only to satisfy testing; you can skip a nonzero test until ordinary play produces a change.

**B5 — one command after naturally changing rank:**

~~~text
/fprof progress
~~~

Expected format:

~~~text
Forever Professions: Skill progress: <COUNT> comparable; <CHANGED> changed (session only).
Forever Professions: <SKILL>: +<DELTA> skill (was <BEFORE>; now <AFTER>).
~~~

Each changed skill should show the actual point difference. A negative delta appears as `-<DELTA>` if a returned rank becomes lower. A skill appearing after the snapshot displays `newly readable at <RANK>; no starting comparison.` A missing one displays `not readable now; change unknown.` **Never claim a missing skill was unlearned.**

## C — Clear and Core lifecycle

**C1 — one command:**

~~~text
/fprof clear
~~~

Expected exact:

~~~text
Forever Professions: Snapshot cleared (session only).
~~~

**C2 — one command:**

~~~text
/fprof progress
~~~

Expected exact:

~~~text
Forever Professions: No snapshot. Use /fprof snapshot first.
~~~

**C3 — one command:**

~~~text
/fprof snapshot
~~~

Expected format:

~~~text
Forever Professions: Snapshot saved: <COUNT> readable profession(s) (session only).
~~~

**C4 — one command:**

~~~text
/forever disable professions
~~~

Expected exact:

~~~text
Forever Core: professions: disabled (session only).
~~~

**C5 — one command:**

~~~text
/fprof progress
~~~

Expected exact:

~~~text
Forever Professions: Module not active: disabled.
~~~

**C6 — one command:**

~~~text
/forever enable professions
~~~

Expected exact:

~~~text
Forever Core: professions: enable requested (session only).
~~~

**C7 — one command:**

~~~text
/fprof progress
~~~

Expected exact:

~~~text
Forever Professions: No snapshot. Use /fprof snapshot first.
~~~

## D — Reload clears the session snapshot

**D1 — one command:**

~~~text
/fprof snapshot
~~~

Expected format:

~~~text
Forever Professions: Snapshot saved: <COUNT> readable profession(s) (session only).
~~~

**D2 — one command:**

~~~text
/reload
~~~

Expected: normal reload without Lua errors.

**D3 — one command, with no intervening snapshot:**

~~~text
/fprof progress
~~~

Expected exact:

~~~text
Forever Professions: No snapshot. Use /fprof snapshot first.
~~~

If an experimental saved Core preference is disabling the addon, diagnose with `/forever status professions`; do not misinterpret it as a snapshot retention issue.

## Boundaries and evidence

- This addon polls **zero times while idle**, registers no game events, keeps a maximum of five entries for one session-only snapshot, and never calls crafting or gameplay actions.
- Rank data comes from `GetProfessions` + `GetProfessionInfo`. Source: https://warcraft.wiki.gg/wiki/API_GetProfessions and https://warcraft.wiki.gg/wiki/API_GetProfessionInfo . Supported status on Forever build 70338 is **unknown until A3 passes live**.
- API absence, nil/invalid data and combat guard are checked by Lua 5.1 mocks; a mock PASS does **not** establish client compatibility.
- Record full build, optional skill names/ranks (no private identifiers), command outputs, actual PASS/FAIL and ideally exact local Git SHA. Do not publish screenshots of guild chat or unrelated private information.
- Missing/changed skills are **not** proof of being trained/untrained; game API may simply not expose them.
- Do not merge/release until full code/security/license/public-source and official policy reviews are completed and explicitly approved.
