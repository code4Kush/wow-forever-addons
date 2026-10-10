# ForeverCore M1 — test commands, exact outputs, and acceptance gates

**Status:** NOT TESTED IN GAME. Tests are proposed for the 16001 client. Record full build via `/run print(GetBuildInfo())` if available, not only interface number. This is independent of the existing Journal PRs and should not alter their output.

## Install Core on Mac

From `~/Developer/wow-forever-addons` on branch `feat/forever-core-m1`:

~~~sh
rsync -av addons/ForeverCore/ \
  "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverCore/"
~~~

Restart the game or run `/reload`. **First test Core by itself**: do not copy the probe packs until the Core-only smoke test passes.

## M1-01: Core-only

**Action:** Enter `/reload` then:

~~~text
/forever version
~~~

**Expected exact chat line** (game chat color is irrelevant):

~~~text
Forever Core: Version 0.1.0
~~~

**PASS:** Correct line, no Lua errors. **FAIL:** Unrecognized slash command, wrong version or Lua error.

**Action:**

~~~text
/forever modules
~~~

**Expected exact:**

~~~text
Forever Core: 0 registered module(s).
~~~

**PASS:** Zero when only ForeverCore is installed. **FAIL:** Missing command or an unrelated module is reported (unless you knowingly installed another pack).

**Action:**

~~~text
/forever character
~~~

**Expected example as Uddergrief:**

~~~text
Forever Core: Uddergrief - <REALM> - Tauren Warrior - level <CURRENT_LEVEL>
~~~

`<REALM>` and `<CURRENT_LEVEL>` are dynamic. If GetRealmName is unavailable, Core omits ` - <REALM>`. **PASS:** Name/race/class match current player, level and realm if available, and no Lua error. **FAIL:** Wrong character or incompatible API error.

## M1-02: Independent test modules

Copy the two *development fixtures* into the AddOns directory:

~~~sh
rsync -av test-addons/ForeverProbeGeneral/ \
  "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverProbeGeneral/"
rsync -av test-addons/ForeverProbeWarrior/ \
  "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverProbeWarrior/"
~~~

Confirm the two packs are enabled in the game's AddOns list, then `/reload`.

**Action:**

~~~text
/forever modules
~~~

**Expected exact on a Warrior:**

~~~text
Forever Core: 2 registered module(s).
Forever Core: probe-general v0.1.0: active [probe.general]
Forever Core: probe-warrior v0.1.0: active [probe.warrior]
~~~

**PASS:** Both independently loaded packages register and activate, regardless of character name. **FAIL:** Missing pack, core dependency error, ineligible for actual Warrior, or Lua error.

**Action:**

~~~text
/forever listeners PLAYER_LEVEL_UP
~~~

**Expected exact:**

~~~text
Forever Core: PLAYER_LEVEL_UP: 2 active listener(s).
~~~

**PASS:** Both register through the shared event bridge.

**Action:**

~~~text
/forever disable probe-warrior
/forever listeners PLAYER_LEVEL_UP
/forever status probe-warrior
~~~

**Expected exact lines:**

~~~text
Forever Core: probe-warrior: disabled (session only).
Forever Core: PLAYER_LEVEL_UP: 1 active listener(s).
Forever Core: probe-warrior v0.1.0: disabled (session only) [probe.warrior]
~~~

**PASS:** Warrior event subscriber removed, general subscriber remains; no Lua error. **FAIL:** Listener count stays 2 or drops to 0.

**Action:**

~~~text
/forever disable probe-general
/forever listeners PLAYER_LEVEL_UP
~~~

**Expected exact lines:**

~~~text
Forever Core: probe-general: disabled (session only).
Forever Core: PLAYER_LEVEL_UP: 0 active listener(s).
~~~

**PASS:** No module subscriptions remain, and Core continues to respond. **FAIL:** Event stays subscribed by a disabled module.

**Action:**

~~~text
/forever enable probe-warrior
/forever listeners PLAYER_LEVEL_UP
~~~

**Expected exact lines:**

~~~text
Forever Core: probe-warrior: enable requested (session only).
Forever Core: PLAYER_LEVEL_UP: 1 active listener(s).
~~~

**PASS:** Eligibility is rechecked and the Warrior subscriber returns; general remains disabled. **FAIL:** Re-enable doesn't work or both reappear.

**Action:** `/reload`, then `/forever modules`.

**Expected:** two modules active again (as in M1-02), because M1 toggles are deliberately **SESSION ONLY**, not saved. **PASS:** Fresh login/activation resets them. **FAIL:** Addon fails to load or error.

## M1-03: Class eligibility

**Action:** On a non-Warrior character with both developer fixtures game-enabled, run `/forever modules`.

**Expected example:**

~~~text
Forever Core: 2 registered module(s).
Forever Core: probe-general v0.1.0: active [probe.general]
Forever Core: probe-warrior v0.1.0: ineligible (Warrior only) [probe.warrior]
~~~

**PASS:** Eligibility follows class, not Uddergrief's name. **FAIL:** Warrior probe activates for non-Warrior or general probe disappears.

## M1-04: Regression and edge checks

- `/fj` and `/fj journal` remain unchanged when ForeverJournal is separately installed. Their expected outputs depend on which Journal PR branch is installed, **not** Core.
- `/forever status not-installed` prints exactly: `Forever Core: Module is not registered (possibly not installed).`
- `/forever listeners bad-event` prints exactly: `Forever Core: Usage: /forever listeners <EVENT>`.
- Disabling game-level probe packs in the AddOns menu requires a reload; after the next login Core lists only packs that loaded and registered.
- Full quit/restart: commands and packages load again; M1 does **not** claim any settings persistence.

For every test record PASS or FAIL, character/class, interface + full game build, screenshot/output, date and commit SHA. The M1 issue cannot be closed as live-verified without this evidence.
