# ForeverPerformance 0.1 — live WoW acceptance (one command at a time)

**Status:** New diagnostic module **NOT YET LIVE TESTED**. Player previously confirmed `UpdateAddOnMemoryUsage` and `GetAddOnMemoryUsage` were present and reported addon KB for Core, Dashboard and Journal; *the new ForeverPerformance pack was not installed when those results were recorded*. Source: user-reported WoW Forever beta, October 10, 2026; full numeric build not provided.

**Rule:** Enter **each single WoW slash command in a separate chat submission**. Never paste multiple WoW commands at once. Color codes stripped below. `<FIELDS>` are expected dynamic values; values are never invented.

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

- [ ] Real WoW beta version/build recorded via its client build info; exact SHA and installed addon versions captured.
- [ ] Every command above entered **individually**; actual outputs or screenshots and PASS/FAIL recorded.
- [ ] No unexpected polling, memory sampling, forced GC, protected actions or chatter while idle.
- [ ] Missing/invalid memory API behavior verified on an affected build if possible; mock tests are not enough.
- [ ] Public release gates: branch ruleset, code license, security/policy review and source rights. No merge without owner approval.
