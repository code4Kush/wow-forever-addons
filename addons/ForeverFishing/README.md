# ForeverFishing 0.3 — skill readout and manual catch notes

**Draft development candidate** in [PR #39](https://github.com/code4Kush/wow-forever-addons/pull/39). The original v0.2 manual catch ledger has player-reported live PASS, and user confirmed `/ffish` skill read needs the Fishing profession window open on last observed Forever beta 1.60.1 build 70338. **This new profession-list fallback is NOT YET LIVE VERIFIED**.

## What's new (and isn't)

The `/ffish` skill command first attempts `GetProfessions()` and `GetProfessionInfo(slot)`, which the separate Professions module has already used successfully on the same client. This Fishing addon uses those APIs **directly**, without requiring ForeverProfessions. Sparse profession slots, nonfinite ranks, impossible values, missing functions and client errors are all guarded. If Fishing cannot be read from the list, the previous read from an **open Fishing profession window** remains available. Names match English `Fishing` only; unavailable/localized results cannot prove unlearned skills.

The existing `/ffish log <count> <fish name>`, `/ffish catches` and `/ffish clear` remain manual, session-only notes, **not automatic catch detection**. Max 10 fish labels, 9999 manually entered fish per label. No reading bags, recipes, auction data, actual loot, or sales.

## Independent install

Only `ForeverCore` 0.2+ is required. Install `ForeverFishing` as its own optional folder with its `ForeverFishing_Camelot.toc` interface 16001. Nothing here depends on or modifies Cooking, Inventory or other packs.

## Commands (ONE entry per WoW chat)

**Skill:**

~~~text
/ffish
~~~

Expected if the independent list read works:

~~~text
Forever Fishing: Fishing: <RANK>/<MAX> (profession list).
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

If only the Fishing UI returns a valid skill:

~~~text
Forever Fishing: Fishing: <RANK>/<MAX> (open profession window).
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

If neither path works:

~~~text
Forever Fishing: Fishing skill not readable; open Fishing UI and retry.
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

**Manually record a test note:**

~~~text
/ffish log 3 Raw Brilliant Smallfish
~~~

Expected for an empty tally:

~~~text
Forever Fishing: Logged manually: Raw Brilliant Smallfish +3 (session total: 3).
~~~

**Show manual notes:**

~~~text
/ffish catches
~~~

Expected for one label above:

~~~text
Forever Fishing: Manual catches: 3 fish across 1 species (session only; not verified).
Forever Fishing: Raw Brilliant Smallfish: 3 manually entered.
~~~

**Clear manual notes:**

~~~text
/ffish clear
~~~

Expected exact:

~~~text
Forever Fishing: Manual catch log cleared (session only).
~~~

**Version:**

~~~text
/ffish version
~~~

Expected exact:

~~~text
Forever Fishing: Version 0.3.0
~~~

Full v0.3 test steps in [FISHING_COOKING_TESTING.md](../../docs/FISHING_COOKING_TESTING.md). Existing v0.2 detailed manual catch checks in [FISHING_TESTING.md](../../docs/FISHING_TESTING.md) apply to the unchanged tally; note that version expectations differ.

## Restrictions

Purely local, read-only skills and human-entered counts. No background processing, WoW loot events, automatic fishing, combat scanning, SavedVariables, network messaging or timer. Disable via Core to clear manual notes; /reload also clears them. No code license or owner-approved public release yet.
