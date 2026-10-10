# ForeverGold 0.2 Sprint 1 — real-client field test

**Status:** CODED / mock CI candidate; **NOT YET VERIFIED IN THE LIVE FOREVER CLIENT**. Target observed beta: WoW Forever `1.60.1`, full build `70338` (dated October 9, 2026), interface `16001`. Enter **every WoW slash command individually**; do not paste batches. Copy the exact actual output or screenshot and mark PASS/FAIL per command. Mocked tests in GitHub do not prove game API compatibility.

**Installed version:** The proposed addon from `feat/forever-gold-wallet-sprint1` on PR #29, stacked on Performance #27 → Journal #25 → Suite #24 → Warrior #22 → Core #18. Only `ForeverCore/` and `ForeverGold/` are required for this focused test. Your previously installed Performance, Dashboard, Warrior and Journal may remain separately enabled.

Install the whole addon directories while WoW is closed. Example Mac Terminal (not in-game WoW chat):

~~~sh
cd ~/Developer/wow-forever-addons
git fetch origin
git switch --track origin/feat/forever-gold-wallet-sprint1
for addon in ForeverCore ForeverGold; do
  rsync -av "addons/$addon/" "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/$addon/"
done
~~~

If that branch already exists locally, use `git switch feat/forever-gold-wallet-sprint1`. Preserve uncommitted changes first. Do **not** re-copy old Gold 0.1 over the new folder.

## A — First login and backwards compatibility

**A1 — command**:

~~~text
/reload
~~~

**Expected:** Normal UI reload; no Lua error or unsolicited Gold chat.

**A2 — command**:

~~~text
/fgold version
~~~

**Expected**:

~~~text
Forever Gold: Version 0.2.0
~~~

**A3 — command**:

~~~text
/fgold
~~~

**Expected format**:

~~~text
Forever Gold: Wallet: <G>g <S>s <C>c (current character; not earnings).
~~~

**PASS:** displayed amount equals the player's actual in-game wallet. If the client lacks `GetMoney`, expected exact `Forever Gold: Wallet API unavailable on this build.` — safe fallback PASS, but gold tracking **unavailable** and must not be marked functional.

## B — Manual baseline and positive/negative delta

**B1 — command before saving any baseline**:

~~~text
/fgold delta
~~~

**Expected exact**:

~~~text
Forever Gold: No baseline. Use /fgold baseline first.
~~~

**B2 — command**:

~~~text
/fgold baseline
~~~

**Expected format**:

~~~text
Forever Gold: Baseline saved: <G>g <S>s <C>c (session only).
~~~

**B3 — command immediately after setting the baseline**:

~~~text
/fgold delta
~~~

**Expected exact if no gold has moved** (`<START>` is your B2 starting wallet, so this part varies):

~~~text
Forever Gold: Wallet change: +0g 0s 0c (was <START>; now <START>; net balance, NOT profit).
~~~

**B4 — OPTIONAL:** Resume normal game play and acquire or spend some money naturally. No purchase, trade or gold transfer is required merely to complete the test. Do not automate gold making. After a change, submit this as its own command:

~~~text
/fgold delta
~~~

**Expected format** (sign can be positive or negative):

~~~text
Forever Gold: Wallet change: <SIGN><G>g <S>s <C>c (was <START>; now <CURRENT>; net balance, NOT profit).
~~~

**PASS:** signed change equals the actual wallet difference in copper. **FAIL:** false sign, unexpected reset, Lua error, or confusing net wallet change with earnings.

## C — Explicit cleanup and Core lifecycle

**C1 — command**:

~~~text
/fgold clear
~~~

**Expected exact**:

~~~text
Forever Gold: Baseline cleared (session only).
~~~

**C2 — command**:

~~~text
/fgold delta
~~~

**Expected exact**:

~~~text
Forever Gold: No baseline. Use /fgold baseline first.
~~~

**C3 — command**:

~~~text
/fgold baseline
~~~

**Expected format**:

~~~text
Forever Gold: Baseline saved: <G>g <S>s <C>c (session only).
~~~

**C4 — command**:

~~~text
/forever disable gold
~~~

**Expected exact**:

~~~text
Forever Core: gold: disabled (session only).
~~~

**C5 — command**:

~~~text
/fgold delta
~~~

**Expected exact**:

~~~text
Forever Gold: Module not active: disabled.
~~~

**C6 — command**:

~~~text
/forever enable gold
~~~

**Expected exact**:

~~~text
Forever Core: gold: enable requested (session only).
~~~

**C7 — command**:

~~~text
/fgold delta
~~~

**Expected exact**:

~~~text
Forever Gold: No baseline. Use /fgold baseline first.
~~~

## D — Reload discards unsaved baseline

**D1 — command**:

~~~text
/fgold baseline
~~~

**Expected format**:

~~~text
Forever Gold: Baseline saved: <G>g <S>s <C>c (session only).
~~~

**D2 — command**:

~~~text
/reload
~~~

**Expected:** UI reloads normally and without Lua errors.

**D3 — command** (do not set a new baseline first):

~~~text
/fgold delta
~~~

**Expected exact**:

~~~text
Forever Gold: No baseline. Use /fgold baseline first.
~~~

If Gold has separately been disabled in the game AddOns manager or through experimental persisted Core preferences, availability may differ; first confirm `/forever status gold` and don't mislabel missing/disabled modules as a tracker leak.

## Final acceptance

- [ ] Actual full build recorded. Expected `1.60.1 / 70338 / 16001`; verify if client updated.
- [ ] Real wallet amount matches Blizzard UI; no invented zero.
- [ ] B1, B2, B3, C1–C7, D1–D3 individually PASS; B4 only if naturally possible.
- [ ] Gold module independent of other optional packs; no timer/event work and no Lua errors.
- [ ] Invalid/wrong types and missing APIs verified under Lua 5.1 mocks; a live missing API test may not be possible on a supported build.
- [ ] No public release until license, security, branch protection and official-addon policy reviewed.
