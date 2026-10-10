# ForeverFishing 0.2 — real-client manual catch tally test

**Status:** New v0.2 feature is **NOT YET LIVE VERIFIED**. The player's previous game build was WoW Forever `1.60.1`, full build `70338`, build date Oct 9 2026, interface `16001`. Record any changes to the client build. Real Fishing skill API `C_TradeSkillUI.GetBaseProfessionInfo()` remains unverified for this module; manual catch notes deliberately work without that API.

**Critical rule:** Type **ONE WoW slash command in ONE chat submission**; each fenced block is separate. No multi-command pastes.

## Install

This PR is stacked on Professions Goals #33 and the other unmerged development branches. This **optional** feature only requires ForeverCore 0.2+, not ForeverProfessions, Gold, or other packs.

Mac **Terminal**, not the game:

~~~sh
cd ~/Developer/wow-forever-addons
git status --short
git fetch origin
git switch --track origin/feat/forever-fishing-manual-catches
rsync -av addons/ForeverFishing/ "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverFishing/"
~~~

Preserve uncommitted changes before switching. If you already have the branch locally, use `git switch feat/forever-fishing-manual-catches`. Enable ForeverFishing in the game's AddOns menu.

## A — Installation and isolation

**A1 — Enter individually:**

~~~text
/reload
~~~

Expected: game UI reloads normally, without Lua errors, and no automatic catch logging.

**A2 — Enter:**

~~~text
/ffish version
~~~

Expected exact:

~~~text
Forever Fishing: Version 0.2.0
~~~

**A3 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: No manual catches logged. Use /ffish log <count> <fish name>.
~~~

**A4 — Enter:**

~~~text
/ffish
~~~

Expected when Fishing UI is open and client returns Fishing details:

~~~text
Forever Fishing: Fishing: <RANK>/<MAX> (open profession window).
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

The actual rank/cap must match the client. Without exposed Fishing UI data, expected safe fallback:

~~~text
Forever Fishing: Fishing skill not readable; open Fishing UI and retry.
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

A safe fallback **does not prove** the skill readout is functional. Do not misinterpret `/fprof` passing on this client as proof that `C_TradeSkillUI.GetBaseProfessionInfo` works when the profession UI is closed.

## B — Manual catch entries (not actual loot verification)

You can enter a **test note**, even if you have never caught this fish. It remains a manually entered note and is never asserted as loot, inventory, or actual item holdings. Replace the example species with the name of a fish you actually catch later.

**B1 — Enter:**

~~~text
/ffish log 3 Raw Brilliant Smallfish
~~~

Expected exact:

~~~text
Forever Fishing: Logged manually: Raw Brilliant Smallfish +3 (session total: 3).
~~~

**B2 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: Manual catches: 3 fish across 1 species (session only; not verified).
Forever Fishing: Raw Brilliant Smallfish: 3 manually entered.
~~~

**B3 — Enter:**

~~~text
/ffish log 2 raw brilliant smallfish
~~~

Expected exact (case-insensitive same species):

~~~text
Forever Fishing: Logged manually: Raw Brilliant Smallfish +2 (session total: 5).
~~~

**B4 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: Manual catches: 5 fish across 1 species (session only; not verified).
Forever Fishing: Raw Brilliant Smallfish: 5 manually entered.
~~~

**B5 — Enter:**

~~~text
/ffish log 1 Raw Longjaw Mud Snapper
~~~

Expected exact:

~~~text
Forever Fishing: Logged manually: Raw Longjaw Mud Snapper +1 (session total: 1).
~~~

**B6 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: Manual catches: 6 fish across 2 species (session only; not verified).
Forever Fishing: Raw Brilliant Smallfish: 5 manually entered.
Forever Fishing: Raw Longjaw Mud Snapper: 1 manually entered.
~~~

PASS when outputs and counts match the manually entered numbers. This does NOT prove those fish existed in the bags, were caught automatically, or can be cooked.

## C — Explicit clear and Core disable cleanup

**C1 — Enter:**

~~~text
/ffish clear
~~~

Expected exact:

~~~text
Forever Fishing: Manual catch log cleared (session only).
~~~

**C2 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: No manual catches logged. Use /ffish log <count> <fish name>.
~~~

**C3 — Enter:**

~~~text
/ffish log 1 Test Fish
~~~

Expected exact:

~~~text
Forever Fishing: Logged manually: Test Fish +1 (session total: 1).
~~~

**C4 — Enter:**

~~~text
/forever disable fishing
~~~

Expected exact:

~~~text
Forever Core: fishing: disabled (session only).
~~~

**C5 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: Module not active: disabled.
~~~

**C6 — Enter:**

~~~text
/forever enable fishing
~~~

Expected exact:

~~~text
Forever Core: fishing: enable requested (session only).
~~~

**C7 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: No manual catches logged. Use /ffish log <count> <fish name>.
~~~

## D — Reload reset

**D1 — Enter:**

~~~text
/ffish log 1 Test Fish
~~~

Expected exact:

~~~text
Forever Fishing: Logged manually: Test Fish +1 (session total: 1).
~~~

**D2 — Enter:**

~~~text
/reload
~~~

Expected: reload succeeds without Lua errors. Do not enter a new catch note in between.

**D3 — Enter:**

~~~text
/ffish catches
~~~

Expected exact:

~~~text
Forever Fishing: No manual catches logged. Use /ffish log <count> <fish name>.
~~~

## E — Defensive input tests (optional)

**E1 — Enter:**

~~~text
/ffish log 0 Raw Brilliant Smallfish
~~~

Expected exact:

~~~text
Forever Fishing: Usage: /ffish log <1-999> <fish name>
~~~

**E2 — Enter:**

~~~text
/ffish log 1000 Raw Brilliant Smallfish
~~~

Expected exact:

~~~text
Forever Fishing: Usage: /ffish log <1-999> <fish name>
~~~

Invalid input must not mutate notes. Mock tests exercise length limits, per-species cap of 9999, ten-species cap, pipe/control-code injection and missing game API.

## Scope and remaining release gates

- Only **user-entered counts** are stored, maximum ten species and 9999 per species; nothing collected automatically.
- No SaveVariables, fishing automation, loot events, prices, sharing or telemetry.
- User-facing game help/readout never claims true catches or inventories.
- New functionality needs user-reported manual PASS on this actual game build before acceptance. Mocked Lua 5.1 CI is distinct.
- Full source license, policy, public security PR #20, branch rules and owner-approved merges/releases remain pending.
