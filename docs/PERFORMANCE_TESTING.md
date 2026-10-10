# ForeverPerformance 0.1 — live WoW acceptance (one command at a time)

**Status:** **PARTIAL LIVE GAME PASS**: the new pack has been observed working in the player’s WoW Forever client. Exact **client version `1.60.1`, build `70338`, build date Oct 9 2026, interface `16001`** was captured from `/run print("Forever client:",GetBuildInfo())` on October 10, 2026. Several diagnostic tests passed, but the *reload baseline reset*, full installed SHA, combat guard, and long-session stability remain unverified. Earlier pre-install observations used the older pack set.

**Rule:** Enter **each single WoW slash command in a separate chat submission**. Never paste multiple WoW commands at once. Color codes stripped below. `<FIELDS>` are expected dynamic values; values are never invented.

## Player-reported live acceptance evidence — 2026-10-10

**Recorded client:** `1.60.1`, build `70338`, build date `Oct 9 2026`, interface `16001`. The following are excerpts from **player-provided in-game screenshots** and clearly identified player-reported PASS claims, **not** GitHub CI fixtures. Screenshots contain guild chat and other player information and have **not** been uploaded into this public repository.

| Action | Evidence | Verdict |
| --- | --- | --- |
| `/fperf version` | `Forever Performance: Version 0.1.0 (on-demand only).` visible in screenshot | **IN-GAME PASS** |
| `/fperf memory` | Four loaded Forever packs, total `116.44 KB`; top Core `47.47 KB`, Performance `35.24 KB`, Warrior `22.42 KB` | **IN-GAME PASS** for bounded reporting |
| `/fperf baseline` then `/fperf delta` | `Since baseline: +2.89 KB (was 109.88 KB; now 112.77 KB).` and Performance `+2.89 KB`, Core `+0.00 KB`, Dashboard `+0.00 KB` | **IN-GAME PASS** for delta format; baseline invocation inferred from comparison, its output not photographed |
| `/fperf details` | Four packs `114.71 KB`: Core `47.34 KB`, Dashboard `11.32 KB`, Warrior `22.42 KB`, Performance `33.63 KB` | **IN-GAME PASS**, displayed total agrees with rows |
| `/fperf clear` then `/fperf delta` | Clear acknowledgment followed by `No baseline. Use /fperf baseline first.` | **IN-GAME PASS** |
| Disable pack, refuse reading, re-enable, discard baseline | User replied **PASS** for all 5 individually submitted commands; no screenshot of this test | **USER-REPORTED PASS** |
| `/forever memory` after reload instructions | `Forever Core: Memory diagnostics: use /fperf memory, details, baseline or delta.` screenshot | **IN-GAME PASS** |
| `/run print("Forever client:",GetBuildInfo())` | `Forever client: 1.60.1 70338 Oct 9 2026 16001` screenshot | **IN-GAME PASS** |
| `/reload` followed by `/fperf delta` | The most recent screenshot does **not** show either the reload or missing-baseline output | **NOT YET VERIFIED** |

Do **not** interpret the absence of an error in a screenshot as proof no errors ever occurred. The locally installed exact Git commit was not independently captured, and CI checks are a separate evidence type. A few KB of temporary memory is not itself a leak. Follow the command-by-command manual plan below to finish the remaining checks.

## Prerequisites

From your local repository, check out `feat/forever-performance-m12` (stacked on the unmerged Journal bridge PR #25) and install at least `addons/ForeverCore/` and `addons/ForeverPerformance/` into the WoW beta's `Interface/AddOns/` directory. Dashboard and Journal are optional for memory comparison. Confirm both Core and Performance enabled in WoW's AddOns menu. **Do not install developer probe addons to release packages**.

Mac Terminal example (shell is **not** WoW chat, so this loop is allowed):

```sh
cd ~/Developer/wow-forever-addons
git fetch origin
git switch --track origin/feat/forever-performance-m12
for addon in ForeverCore ForeverPerformance; do
  rsync -av "addons/$addon/" "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/$addon/"
done
```

If the branch already exists locally, switch normally. Preserve uncommitted work before switching. Record the game flavor, numeric client build, character/class, observed timestamps and exact local test commit. This is not a player-distribution archive.

## A. Startup, API and Core navigation

**A1 — One command:**

```text
/reload
```

Expected: interface reloads without Lua errors or chat spam.

**A2 — One command:**

```text
/forever version
```

Expected exact:

```text
Forever Core: Version 0.2.0
```

**A3 — One command:**

```text
/fperf version
```

Expected exact:

```text
Forever Performance: Version 0.1.0 (on-demand only).
```

**A4 — One command:**

```text
/forever memory
```

Expected exact with Performance active:

```text
Forever Core: Memory diagnostics: use /fperf memory, details, baseline or delta.
```

**A5 — One command:**

```text
/run print("Memory API:",type(UpdateAddOnMemoryUsage),type(GetAddOnMemoryUsage))
```

Expected exact when supported:

```text
Memory API: function function
```

If one of the types is `nil`, feature-memory measurements **cannot pass** on that build, but safe fallback handling remains expected.

## B. Bounded memory and baseline

**B1 — One command:**

```text
/fperf memory
```

Expected format:

```text
Forever Performance: Memory: <COUNT> known loaded pack(s), <TOTAL_KB> KB total (addon-attributed).
Forever Performance: Top 1: <FOLDER> <KB> KB.
Forever Performance: Top 2: <FOLDER> <KB> KB.
Forever Performance: Top 3: <FOLDER> <KB> KB.
```

`<COUNT>` includes Core and Performance and any other Core-registered optional pack (even logically disabled packs); when fewer than 3 tracked packs exist, fewer Top rows appear. The order is by descending memory, alphabetically on ties. `<TOTAL_KB>` and `<KB>` have two decimals. Some measurements are attributed differently by WoW; compare values with a manual memory API reading. **PASS** if counts and nonnegative figures reflect the actually registered packs. **FAIL** for nil/math errors, invented values, unbounded lines or unexpected background output.

**B2 — One command:**

```text
/fperf details
```

Expected format (additional rows may appear):

```text
Forever Performance: Details: <COUNT> known loaded pack(s), <TOTAL_KB> KB total.
Forever Performance: ForeverCore: <KB> KB.
Forever Performance: ForeverPerformance: <KB> KB.
```

Other known registered packs appear in static documented catalog order, up to 12 rows. **PASS** if only known/loaded Forever packs are present and disabled-but-loaded packs remain counted.

**B3 — One command (before any baseline):**

```text
/fperf delta
```

Expected exact:

```text
Forever Performance: No baseline. Use /fperf baseline first.
```

**B4 — One command:**

```text
/fperf baseline
```

Expected exact format:

```text
Forever Performance: Baseline saved: <TOTAL_KB> KB across <COUNT> pack(s) (session only).
```

**B5 — Open Dashboard if installed (one command):**

```text
/fdash
```

Expected: `Forever Dashboard: Dashboard shown.`. If Dashboard isn't installed, skip B5/B6 and compare idle sample readings instead.

**B6 — Close Dashboard (one command):**

```text
/fdash
```

Expected: `Forever Dashboard: Dashboard hidden.`. You may repeat B5 and B6 several times, submitting **each command individually**.

**B7 — One command:**

```text
/fperf delta
```

Expected format:

```text
Forever Performance: Since baseline: <SIGNED_DELTA> KB (was <BASELINE_KB> KB; now <CURRENT_KB> KB).
Forever Performance: Change: <FOLDER> <SIGNED_DELTA> KB.
```

Up to 3 `Change` rows appear; format uses a leading `+` or `-`. A large positive delta after opening UI is not by itself proof of a leak. **PASS** if numbers are plausible and no API errors occur; don't require a particular sign or exact KB value.

**B8 — Optional controlled garbage collection (one command only, player-directed):**

```text
/run collectgarbage("collect")
```

Expected: typically no chat output; this can briefly hitch the game. The diagnostic addon never invokes this command itself.

**B9 — One command:**

```text
/fperf delta
```

Expected: same format as B7, with updated client memory attribution. If reclaimed memory lowers the total, the delta may be negative. This observation **does not certify leak-free code**.

**B10 — One command:**

```text
/fperf clear
```

Expected exact:

```text
Forever Performance: Baseline cleared (session only).
```

## Optional combat guard

If safely in combat during a separate player-controlled test, `/fperf memory` should respond with the exact local error `Forever Performance: Memory sampling unavailable during combat.` and no subsequent memory totals. **Do not deliberately enter danger merely to test this**. The guard uses `InCombatLockdown` when available and starts no delayed timer.

## C. Disable behavior and restart

**C1 — One command:**

```text
/forever disable performance
```

Expected exact:

```text
Forever Core: performance: disabled (session only).
```

**C2 — One command:**

```text
/fperf memory
```

Expected exact:

```text
Forever Performance: Module not active: disabled.
```

**C3 — One command:**

```text
/forever enable performance
```

Expected exact:

```text
Forever Core: performance: enable requested (session only).
```

**C4 — One command:**

```text
/fperf delta
```

Expected exact (baseline cleared on disable):

```text
Forever Performance: No baseline. Use /fperf baseline first.
```

**C5 — One command:**

```text
/reload
```

Expected: no Lua errors, remembered baseline absent because this pack has **no SavedVariables**. Session-only Core toggles reset unless the *separate* experimental Core per-character preference is set.

**C6 — One command:**

```text
/fperf delta
```

Expected exact:

```text
Forever Performance: No baseline. Use /fperf baseline first.
```

Also confirm the addon stops emitting output while idle for a few minutes. **No timer, no event subscriptions, no continuous CPU work are implemented**; real-client validation remains useful.

## D. Previous player-measured Dashboard reference (NOT new addon results)

These numbers came from prior player-directed commands; the build ID was not captured, and the new Performance module was not yet installed:

| Observation | ForeverDashboard attributed memory |
| --- | ---: |
| Before repeated opening | ~11.32 KB |
| After first ~10 open/close cycles | 140.982421875 KB |
| After ~20 open/close cycles | 150.068359375 KB |
| After manual Lua GC | 31.8955078125 KB |
| Reclaimed by GC from last pre-GC reading | ~118.17 KB |

The last reading is consistent with temporary objects being collectable. It **does not** establish steady-state stability, worst-case memory, addon-process RAM or the absence of leaks. Compare repeated after-GC measurements across longer sessions if needed.

## Completion gate

- [x] Real WoW beta version/build captured in game: `1.60.1` / `70338` / `Oct 9 2026` / `16001`.
- [ ] Exact locally installed Git SHA captured (not established from screenshots).
- [ ] Every command above entered **individually**; actual outputs or screenshots and PASS/FAIL recorded.
- [ ] No unexpected polling, memory sampling, forced GC, protected actions or chatter while idle.
- [ ] Missing/invalid memory API behavior verified on an affected build if possible; mock tests are not enough.
- [ ] Public release gates: branch ruleset, code license, security/policy review and source rights. No merge without owner approval.
