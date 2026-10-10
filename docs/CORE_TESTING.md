# ForeverCore M1 — one-at-a-time in-game testing

**Status (2026-10-10):** Player confirmed live PASS for Core-only loading on Uddergrief (Tauren Warrior), and separately confirmed live PASS for two independently installed developer probe packs and the initial `PLAYER_LEVEL_UP` listener count of 2. **Not yet verified:** disable/re-enable cleanup, non-Warrior eligibility, full client build, cold restart.

**IMPORTANT: World of Warcraft's chat is not a command batch processor.** Every in-game slash command in this guide appears in its **own single-command code block** and must be entered/submitted **individually**, in order. Do not paste multiple commands in one chat submission. Each expected output follows the command that produces it. Chat color formatting is omitted.

## Installation and version

From `~/Developer/wow-forever-addons` on branch `feat/forever-core-m1`, install just Core:

~~~sh
rsync -av addons/ForeverCore/ \
  "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverCore/"
~~~

For the independent-module acceptance test, install both **developer-only** probe packages:

~~~sh
rsync -av test-addons/ForeverProbeGeneral/ \
  "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverProbeGeneral/"

rsync -av test-addons/ForeverProbeWarrior/ \
  "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverProbeWarrior/"
~~~

Confirm the developer packs and ForeverCore are enabled in WoW's AddOns menu.

## M1-01 — Core-only (player-reported PASS)

**Command 1 (enter and submit):**

~~~text
/reload
~~~

Expected behavior: interface reloads without an error.

**Command 2:**

~~~text
/forever version
~~~

Expected exact output:

~~~text
Forever Core: Version 0.1.0
~~~

**Command 3** (without the two probes loaded):

~~~text
/forever modules
~~~

Expected exact output:

~~~text
Forever Core: 0 registered module(s).
~~~

**Command 4:**

~~~text
/forever character
~~~

Expected example on Uddergrief:

~~~text
Forever Core: Uddergrief - <REALM> - Tauren Warrior - level <CURRENT_LEVEL>
~~~

`<REALM>` and `<CURRENT_LEVEL>` vary; if the realm API is unavailable, the realm segment is omitted. **PASS** if the outputs match, identity is accurate, and no Lua errors occur. The player confirmed this group as PASS but did not paste a full client build.

## M1-02 — Two independent modules (initial activation player-reported PASS)

**Command 1** (after both probe packs are installed and enabled in the game):

~~~text
/reload
~~~

Expected behavior: no game Lua errors.

**Command 2:**

~~~text
/forever modules
~~~

Expected exact output on a Warrior:

~~~text
Forever Core: 2 registered module(s).
Forever Core: probe-general v0.1.0: active [probe.general]
Forever Core: probe-warrior v0.1.0: active [probe.warrior]
~~~

**Command 3:**

~~~text
/forever listeners PLAYER_LEVEL_UP
~~~

Expected exact output:

~~~text
Forever Core: PLAYER_LEVEL_UP: 2 active listener(s).
~~~

**PASS:** Both packs registered independently and share the Core event bridge. **FAIL:** Either is absent/ineligible, count not 2, or Lua errors. Player explicitly confirmed **PASS** for this phase on 2026-10-10.

### M1-02B — Disable and re-enable independently (NOT YET VERIFIED)

Perform commands sequentially. **Submit each individually** and compare its output before continuing. Do not reload until all six commands are complete.

**Command 1 — Disable Warrior probe:**

~~~text
/forever disable probe-warrior
~~~

Expected exact output:

~~~text
Forever Core: probe-warrior: disabled (session only).
~~~

**Command 2 — Count remaining listeners:**

~~~text
/forever listeners PLAYER_LEVEL_UP
~~~

Expected exact output:

~~~text
Forever Core: PLAYER_LEVEL_UP: 1 active listener(s).
~~~

**Command 3 — Check Warrior state:**

~~~text
/forever status probe-warrior
~~~

Expected exact output:

~~~text
Forever Core: probe-warrior v0.1.0: disabled (session only) [probe.warrior]
~~~

**Command 4 — Disable General probe:**

~~~text
/forever disable probe-general
~~~

Expected exact output:

~~~text
Forever Core: probe-general: disabled (session only).
~~~

**Command 5 — Check zero listeners:**

~~~text
/forever listeners PLAYER_LEVEL_UP
~~~

Expected exact output:

~~~text
Forever Core: PLAYER_LEVEL_UP: 0 active listener(s).
~~~

**Command 6 — Re-enable only Warrior:**

~~~text
/forever enable probe-warrior
~~~

Expected exact output:

~~~text
Forever Core: probe-warrior: enable requested (session only).
~~~

**Command 7 — Check exactly one listener:**

~~~text
/forever listeners PLAYER_LEVEL_UP
~~~

Expected exact output:

~~~text
Forever Core: PLAYER_LEVEL_UP: 1 active listener(s).
~~~

**PASS** if counts move **2 → 1 → 0 → 1** and the module status shows **disabled**, with no Lua errors. **FAIL** if a disabled pack retains listeners, the remaining pack disappears prematurely, or re-enabling fails. Record actual text/screenshot if any mismatch occurs.

**Command 8 — Reset the session (only after completing the prior checks):**

~~~text
/reload
~~~

Expected: reload succeeds; Core settings intentionally reset to defaults because M1 has **no SavedVariables**.

**Command 9 — Verify reset:**

~~~text
/forever modules
~~~

Expected same three lines as M1-02's two-module activation example. **PASS** if both probes become active again; **FAIL** if session toggles incorrectly persisted or module loading fails.

## M1-03 — Warrior eligibility on another character (NOT YET VERIFIED)

On any non-Warrior character with both developer packs enabled, run **one** command:

~~~text
/forever modules
~~~

Expected exact output:

~~~text
Forever Core: 2 registered module(s).
Forever Core: probe-general v0.1.0: active [probe.general]
Forever Core: probe-warrior v0.1.0: ineligible (Warrior only) [probe.warrior]
~~~

**PASS:** General remains active and Warrior becomes ineligible based on class token, not name. **FAIL:** Warrior starts for a non-Warrior or Lua error.

## M1-04 — Additional regression and edge checks

**Missing module:**

~~~text
/forever status not-installed
~~~

Expected exact output:

~~~text
Forever Core: Module is not registered (possibly not installed).
~~~

**Invalid listener name:**

~~~text
/forever listeners bad-event
~~~

Expected exact output:

~~~text
Forever Core: Usage: /forever listeners <EVENT>
~~~

**Journal regression:**

~~~text
/fj
~~~

Expected: the previously working Forever Journal help for the installed Journal version, without interference from ForeverCore. The exact Journal help can differ by its installed version.

**Cold restart:** Fully quit the client and relaunch. Re-run the Core version and module commands **individually**; M1 intentionally does not save module preferences.

**Client build capture:**

~~~text
/run print(GetBuildInfo())
~~~

Expected: the game displays its actual version/build/interface values; do not invent a numeric build. Record the output.

For all tests note **PASS/FAIL**, the character, client build/interface, actual chat outputs or screenshots, date, and exact tested addon version. The milestone issue remains open until the outstanding live checks are recorded.
