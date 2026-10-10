# Forever Addons — ONE complete modular beta acceptance round

**Development beta only; not a public release.** This guide targets the
integrated stack in [draft PR #41](https://github.com/code4Kush/wow-forever-addons/pull/41)
based on PR #39 (Fishing/Cooking) and PR #37 (initial full-suite integration).
Every feature module is a separately installable addon directory whose **only
hard dependency is ForeverCore**. The comprehensive developer ZIP contains
**12 folders: Core + 11 optional modules**.

This is a **bounded feature-complete v0.x development scope**: character and
module settings, limited Warrior guidance and manual checklist, Journal's
read-only quests and curated Mulgore catalog, dashboard, bag counts, wallet
deltas, professions/goals, Fishing catch notes, Cooking ingredient plans,
current map, on-demand memory, opt-in Guild discovery. **It does not implement**
a full quest database, auction pricing, automatic tanking/threat, complete
recipes, auto-fishing, equipment scoring, or cross-character sync.

### Evidence and game-version boundary

Previous user tests on Uddergrief validated the original 11 optional packs,
Dashboard's paginated rendering (screenshots with 13 active modules including
two older probes), Fishing/Cooking open profession-window behavior, and a
player-reported full restart preserving a Core marker. An initial full-suite
Performance screenshot recorded 346.58 KB baseline, +27.05 KB delta, then
405.96 KB in a separate detailed reading. Those **do not verify new**
Fishing v0.3, Cooking v0.2, Warrior v0.2 or Performance v0.2 on the live
client. The last player-observed numeric client build is WoW Forever
**1.60.1, build 70338, interface 16001**; the beta may update.
Automated tests use **Lua 5.1 mocks**, not a running Forever client.
Never claim measured FPS gains or leak-free memory from source checks.

## 1 — Obtain the one-time complete DEV build

In GitHub, open [draft PR #41](https://github.com/code4Kush/wow-forever-addons/pull/41)
and select its latest successful **Lua 5.1** check. In that GitHub Actions
run's **Artifacts** area, obtain
`ForeverSuite-12packs-BETA-DEV-UNVERIFIED` (retained only **3 days**).
The downloaded GitHub artifact is a ZIP *containing*
`ForeverSuite-full-BETA-DEV.zip` and `SHA256SUMS.txt`. **Unzip the outer
artifact first.** The inner ZIP contains the twelve distinct addon folders
at its top level. Verify its SHA256 against the checksum file:

~~~sh
cd ~/Downloads/ForeverSuite-12packs-BETA-DEV-UNVERIFIED
shasum -a 256 ForeverSuite-full-BETA-DEV.zip
cat SHA256SUMS.txt
unzip -t ForeverSuite-full-BETA-DEV.zip
~~~

Paths depend on how your browser extracts the outer ZIP. Verify the hash
matches exactly before installing. Record the exact SHA from the PR
and latest **SUCCESS** Actions run; don't use an older snapshot.

Alternative developer workflow on Mac, *without* relying on expiring Actions
artifacts:

~~~sh
cd ~/Developer/wow-forever-addons
git status --short
git fetch origin
git switch --detach origin/feat/forever-full-modular-beta
git rev-parse HEAD
python3 tools/build_dev_bundle.py --check --profile full
python3 tools/build_dev_bundle.py --profile full --output dist/ForeverSuite-full-BETA-DEV.zip
shasum -a 256 dist/ForeverSuite-full-BETA-DEV.zip
~~~

**Preserve uncommitted changes before switching.** These commands don't touch
WoW's installed addons. The developer ZIP is deterministic for exactly the
same source commit. Core-only, Tank and Professions subsets remain selectable
with `--profile minimal|tank|professions`; a full suite requires
`--profile full`. You may also exclude Guild explicitly if you prefer to
avoid registering any addon-message receive listener.

## 2 — Safe installation or rollback

1. **Completely quit WoW** before changing addon files. Do not run this
   while playing. Existing client may cache addon Lua until a fresh start.
2. In Finder, back up your existing
   `/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/Forever*`
   folders somewhere safe. Do not remove unrelated addons.
3. Remove or disable `General Probe` and `Warrior Probe` if still present,
   and check that no leftover test probes are enabled for Uddergrief.
4. Extract the **inner** `ForeverSuite-full-BETA-DEV.zip` into
   `/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/`.
   Each `Forever<Name>` folder must directly contain its
   `Forever<Name>_Camelot.toc` file; there must be **no** extra enclosing
   `ForeverSuite` directory. Archive extraction overwrites but **does not
   remove old files**: for clean tests move old `Forever*` folders to
   backup first while the game is closed.
5. In the game's AddOns selection, enable Core and all eleven optional
   packs. Open Uddergrief. Guild sends **nothing** without opt-in followed
   by an independent manual announce command. We do not request either.
6. To roll back, fully quit the game, remove the new `Forever*` folders
   and copy your backup folders back. This branch adds no new persistent
   SavedVariables schema; Cooking/Warrior notes are session-only.

**Caution:** Any fresh or stale `ForeverCharacterDB` per-character Core
preferences can logically disable an otherwise installed feature. If a
module shows `disabled`, inspect `/forever status <module-id>` instead of
assuming it failed to load.

## 3 — One combined in-game acceptance sequence

**Critical rule: ONE WoW slash command per chat submission.** Never paste
two commands into one chat submission. Each fenced command below is
independent, and its expected result immediately follows.

### A — Build identification and Core registry

**A1** Version:

~~~text
/run print("Forever client:",GetBuildInfo())
~~~

Expected format: `Forever client: <VERSION> <BUILD> <DATE> <INTERFACE>`.
Record actual values; don't assume unchanged build.

**A2** Core:

~~~text
/forever version
~~~

Expected: `Forever Core: Version 0.2.0`.

**A3** Module statuses:

~~~text
/forever modules
~~~

Expected: `Forever Core: 11 registered module(s).`, followed by eleven
separately registered modules. All should report `active` for Uddergrief
unless a profile preference explicitly disabled one. Core itself is a
foundation, not counted as a registered optional module.

**A4** Dashboard:

~~~text
/fdash
~~~

Expected: `Forever Dashboard: Dashboard shown.` and the first six modules
in one draggable frame.

**A5** Next page:

~~~text
/fdash next
~~~

Expected: `Forever Dashboard: Dashboard page 2/2.` and five more modules.

**A6** Hide:

~~~text
/fdash
~~~

Expected: `Forever Dashboard: Dashboard hidden.`

### B — Warrior, Journal and existing data readers

**B1** Warrior advisory:

~~~text
/fw plan
~~~

Expected: current level-banded Warrior advice; it must not claim actual
gear/spell/talent inspection.

**B2** Warrior readiness now manually editable (new v0.2):

~~~text
/fw ready
~~~

Expected: `Forever Warrior: Readiness: 0/5 manually checked (session only).`
and five numbered `[ ]` reminders. Never automatically checked.

**B3** Manually mark first reminder:

~~~text
/fw ready done 1
~~~

Expected: `Forever Warrior: Readiness item 1 manually checked (session only).`

**B4** Observe progress:

~~~text
/fw ready
~~~

Expected `Readiness: 1/5 manually checked`, item 1 marked `[x]`, other
items unchecked. This is a **manual declaration**, not verified gear.

**B5** Reset session checklist:

~~~text
/fw ready reset
~~~

Expected: `Forever Warrior: Manual readiness marks cleared (session only).`

**B6** Profession advice (shouldn't imply Blacksmithing is trained):

~~~text
/fw professions
~~~

Expected: gathering Mining + Herbalism *suggested*, alternative
Blacksmithing *only if chosen*, and Fishing/Cooking/First Aid advice.
No skill/inventory scanning.

**B7** Journal:

~~~text
/fj quests
~~~

Expected: current read-only, six-per-page actual quests, or an explicit
unavailable/empty state. No claims of complete zone history.

**B8** Inventory:

~~~text
/finv
~~~

Expected `Bags 0-4: <OCCUPIED>/<SLOTS> occupied slots; <QUANTITY> total items`
and correct in-game counts, or an explicit API unavailable message.

**B9** Gold:

~~~text
/fgold
~~~

Expected current character wallet `<G>g <S>s <C>c`, not earnings.

**B10** Professions:

~~~text
/fprof
~~~

Expected trained skill names and rank/caps (current player values may
have progressed).

**B11** Current map:

~~~text
/fexplore
~~~

Expected current UI map name/ID, explicitly not exploration completion.

### C — New Fishing and Cooking capabilities (still unverified in game)

**Close both profession windows first.** This is the main new test.

**C1** Fishing v0.3 version:

~~~text
/ffish version
~~~

Expected: `Forever Fishing: Version 0.3.0`.

**C2** Fishing with no profession window open:

~~~text
/ffish
~~~

Expected if the new client profession list exposes Fishing:
`Forever Fishing: Fishing: <RANK>/<MAX> (profession list).`
If it reports unavailable, mark the *new no-window route* FAIL/unknown,
open the Fishing window, and separately retry the same command to verify
legacy fallback. Do not infer rank 0.

**C3** Cooking v0.2 version:

~~~text
/fcook version
~~~

Expected: `Forever Cooking: Version 0.2.0`.

**C4** Cooking with no profession window open:

~~~text
/fcook
~~~

Expected `Forever Cooking: Cooking: <RANK>/<MAX> (profession list).`
with rank matching `/fprof`. If it reports unavailable, open Cooking UI
and retry separately, reporting the fallback as distinct.

**C5** Empty manual Cooking ingredient list:

~~~text
/fcook needs
~~~

Expected: `Forever Cooking: No manual ingredients planned. Use /fcook need <count> <ingredient>.`

**C6** Manual ingredient entry (not actual bag contents):

~~~text
/fcook need 3 Raw Brilliant Smallfish
~~~

Expected: `Forever Cooking: Planned manually: Raw Brilliant Smallfish +3 (need 3).`

**C7** View plan:

~~~text
/fcook needs
~~~

Expected: `Ingredient plan: 3 units across 1 label (manual; not bag contents).`
and `Raw Brilliant Smallfish: need 3 (player-entered).`

**C8** Remove a manually planned item:

~~~text
/fcook done Raw Brilliant Smallfish
~~~

Expected: `Forever Cooking: Removed manual ingredient: Raw Brilliant Smallfish (3 planned).`
This **does not claim** the character gathered or ate the fish.

**C9** Prior Fishing tally should remain separately available:

~~~text
/ffish catches
~~~

Expected empty manual log or the user's **current-session manually entered**
notes. Never actual auto-detected fish inventory; never shared with Cooking.

### D — Guild privacy and new Performance v0.2

**D1** Guild OFF:

~~~text
/fguild status
~~~

Expected `Forever Guild: Sharing: OFF; API <registered|unavailable>; session only.`
Do **not** run `/fguild optin` or `/fguild announce`.

**D2** Performance version:

~~~text
/fperf version
~~~

Expected: `Forever Performance: Version 0.2.0 (on-demand only).`

**D3** Complete memory listing:

~~~text
/fperf details
~~~

Expected header `Details: 12 known loaded pack(s), <KB> KB total.`,
followed by per-folder KB readings. This is **attributed addon Lua memory**,
not CPU, FPS, process RAM, VRAM, and not a leak diagnosis.

**D4** Start a fresh matched baseline:

~~~text
/fperf baseline
~~~

Expected: `Baseline saved: <KB> KB across 12 pack(s) (session only).`
Play for 15–20 minutes, no reload and no forced collection. The user
initiates any memory reports; there is no background sampling.

**D5** Compare the same module set:

~~~text
/fperf delta
~~~

Expected signed change and top-three contributors. Current version's
ranking code deliberately avoids full-table sorting on each requested
report, but **has no measured real-client performance gain yet**.
Do not compare the new module versions' total to old PR #37's 346.58 KB
baseline as if that proved an optimization or regression.

## 4 — Acceptance and rollback gate

Report the actual client build, addon versions and installed Git SHA,
all eleven module active states, the closed-window Fishing/Cooking results,
Warrior checklist commands, privacy status, Lua errors if any, and the
measured same-session Performance baseline/delta.

Do **not** call the new modules client-compatible from CI alone.
A beta PASS is for the observed client build only. Public licensing,
security/policy review, source-ownership review, branch protections,
owner-authorized merge and release remain separate gates, and **none is
automatically satisfied by successful tests or by the short-lived Actions
developer artifact**.
