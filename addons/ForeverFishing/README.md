# ForeverFishing v0.2 — manually logged catch notes

**Development candidate, not yet game-tested as this version.** [Draft PR #35](https://github.com/code4Kush/wow-forever-addons/pull/35) adds a lightweight, player-entered catch tally for Fishing/Cooking self-sufficiency. It targets WoW Forever beta interface `16001`; last player-observed full client build: **1.60.1 / 70338 / Oct 9 2026**.

## What it does

The familiar `/ffish` attempts to read Fishing skill from the open Fishing profession window using `C_TradeSkillUI.GetBaseProfessionInfo`. This conventional WoW API is **not yet independently confirmed for this optional pack on build 70338**. A fallback politely reports the skill as not readable.

New `/ffish log <count> <fish name>` records a **manual note**, `/ffish catches` displays the current session's manually entered fish tallies, and `/ffish clear` clears that session's log. **The addon does not detect actual catches**, read bags, verify the fish name, track sale prices or categorize cooking usefulness. These notes are **not proof of loot, inventory, historical catches or gold earned**.

## Install independently

Copy `addons/ForeverFishing/` into your WoW beta's `Interface/AddOns/ForeverFishing/` directory with `ForeverCore` 0.2+ installed. Enable both in the AddOns menu and reload. No other optional pack is required, and removing this folder leaves other packs unaffected.

Full installation and [individual in-game acceptance steps](../../docs/FISHING_TESTING.md) live in `docs/FISHING_TESTING.md`.

## Commands — exactly one per WoW chat submission

**Version:**

```text
/ffish version
```

Expected exact:

```text
Forever Fishing: Version 0.2.0
```

**Fishing skill:**

```text
/ffish
```

Expected when the actual Fishing UI exposes a valid profession:

```text
Forever Fishing: Fishing: <RANK>/<MAX> (open profession window).
Forever Fishing: Catches are manually logged only; no auto-fishing.
```

Without readable client API data:

```text
Forever Fishing: Fishing skill not readable; open Fishing UI and retry.
Forever Fishing: Catches are manually logged only; no auto-fishing.
```

**Log a user-entered example note:**

```text
/ffish log 3 Raw Brilliant Smallfish
```

Expected exact for an empty log:

```text
Forever Fishing: Logged manually: Raw Brilliant Smallfish +3 (session total: 3).
```

**View notes:**

```text
/ffish catches
```

Expected with only the preceding note:

```text
Forever Fishing: Manual catches: 3 fish across 1 species (session only; not verified).
Forever Fishing: Raw Brilliant Smallfish: 3 manually entered.
```

**Clear notes:**

```text
/ffish clear
```

Expected exact:

```text
Forever Fishing: Manual catch log cleared (session only).
```

**Help:**

```text
/ffish help
```

Expected exact:

```text
Forever Fishing: Commands: /ffish | version | help | log <count> <fish name> | catches | clear
Forever Fishing: Catch counts are manual notes, NOT verified loot or inventory.
```

## Bounds and privacy

Manual amounts must be positive whole numbers from 1 to 999 per command. Store no more than 10 labels, 9999 fish per label and 99999 overall. Names are limited to 60 bytes and reject control characters and WoW color/link control pipes. Matching ignores letter case within the session.

No timers, OnUpdate, SavedVariables, periodic APIs, loot events, external services or addon network messages. Core logical disable or interface reload drops every manual note. Manual `log`, `catches` and `clear` never inspect actual game data.

The repository is public source but does **not** yet provide an owner-approved player release, chosen code license, verified branch protections or final public security/policy review.
