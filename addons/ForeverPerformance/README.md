# ForeverPerformance 0.1.0 (development candidate)

**Status:** Code and Lua 5.1 mock tests in [draft PR #27](https://github.com/code4Kush/wow-forever-addons/pull/27). **NOT TESTED IN GAME AS THIS NEW PACK.** The user previously confirmed working memory functions in their Forever beta, but no full numeric client build was recorded.

## Purpose

An independently installable, **on-demand** memory diagnostic for known, registered Forever addons. It reports what WoW attributes to their loaded Lua code; it is **not total WoW RAM usage**, GPU memory, frame-time measurement, proof of a memory leak, or a general third-party addon profiler.

Requires: **ForeverCore 0.2.0+**. Interface `16001` and `ForeverPerformance_Camelot.toc` target the observed beta layout.

## Installation

Quit WoW, then copy `addons/ForeverPerformance/` as a whole directory to:

```text
/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverPerformance/
```

Keep `ForeverCore/` installed, enable both addons in the WoW AddOns menu, log in, and issue a separate `/reload` if needed. The install directory and TOC suffix are beta-specific and may change. Remove the `ForeverPerformance/` directory to uninstall. No settings file or persistent history belongs to this pack.

## Commands (submit **one** at a time in WoW chat)

Every example is **one individually submitted command**, never a pasted batch.

### Help

```text
/fperf
```

Expected:

```text
Forever Performance: Commands: /fperf memory | details | baseline | delta | clear
Forever Performance: /fperf version | help; samples are on demand, not continuous.
```

### Summary

```text
/fperf memory
```

Expected format (variables depend on which packs are loaded):

```text
Forever Performance: Memory: <COUNT> known loaded pack(s), <TOTAL> KB total (addon-attributed).
Forever Performance: Top 1: <FOLDER> <KB> KB.
Forever Performance: Top 2: <FOLDER> <KB> KB.
Forever Performance: Top 3: <FOLDER> <KB> KB.
```

For fewer than three available packs, fewer top lines appear. Numeric fields have two decimals.

### Detailed rows

```text
/fperf details
```

Expected format:

```text
Forever Performance: Details: <COUNT> known loaded pack(s), <TOTAL> KB total.
Forever Performance: ForeverCore: <KB> KB.
Forever Performance: ForeverPerformance: <KB> KB.
```

Other known loaded pack rows may appear between those two examples. Only **up to 12 known pack entries** are ever displayed; this command does not list third-party addons.

### Session comparison

```text
/fperf baseline
```

Expected: `Forever Performance: Baseline saved: <TOTAL> KB across <COUNT> pack(s) (session only).`

```text
/fperf delta
```

Expected: `Forever Performance: Since baseline: <SIGNED_DELTA> KB (was <BASELINE> KB; now <CURRENT> KB).` plus up to 3 lines `Change: <FOLDER> <SIGNED_DELTA> KB.` If the known loaded module set changed, a warning says totals aren't directly comparable.

```text
/fperf clear
```

Expected: `Forever Performance: Baseline cleared (session only).`

### Core shortcut

```text
/forever memory
```

Expected with an active module: `Forever Core: Memory diagnostics: use /fperf memory, details, baseline or delta.` Without this optional module: `Forever Core: Memory diagnostics unavailable: install and enable ForeverPerformance.` Core only provides navigation and never samples memory itself.

## Memory cost and safety

- **No periodic work:** no event subscriptions, no `OnUpdate`, no timers and no implicit profiling at login, startup or idle.
- **No automatic garbage collection:** avoid causing in-game pauses. You can separately choose to collect garbage in a controlled experiment, but that is not required for normal use.
- **Bounded transient memory:** only one optional baseline with up to 12 package readings, sorted temporary arrays, and short chat messages. No per-frame accumulation and no persistent saved history.
- **Accurate unknowns:** if `UpdateAddOnMemoryUsage` or `GetAddOnMemoryUsage` is absent or fails, memory commands show an unavailable message. No guessed zeros.
- **Loaded versus active:** a module disabled through Core may still use Lua memory until the UI reload/client exits; it appears in reports if registered. A pack disabled in the game's AddOns menu before loading does not register and is not measured.
- **Privacy:** locally prints only known folder names and attributed memory readings. It does not collect player names, GUIDs, account details, quest lists or guild information and never sends analytics.

## In-game acceptance

See [PERFORMANCE_TESTING.md](../../docs/PERFORMANCE_TESTING.md) for **every test command in its own fenced block**, expected and actual results, PASS/FAIL, and the recorded memory observations. Mocked tests in `tests/test_performance.lua` do not prove WoW beta compatibility.

## Public-release constraints

This is independent, free, human-readable addon source, not affiliated with Blizzard. A license is **not yet chosen**, and [public-repository security PR #20](https://github.com/code4Kush/wow-forever-addons/pull/20) plus release gates are still pending. No downloadable public release is approved.
