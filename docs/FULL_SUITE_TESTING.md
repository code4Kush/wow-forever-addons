# Full modular suite: one-session integrated field test

**Development build only; NOT an approved public release.** This guide tests the
complete set of separately installable Forever addons together, built from
[development PR #37](https://github.com/code4Kush/wow-forever-addons/pull/37).
Previous player-observed client: WoW Forever **1.60.1, build 70338, Oct 9,
2026, interface 16001**. Check if the beta has since updated. User-reported
live passes for individual Gold, Professions, and Fishing packs are **not**
proof that a new combined build works.

**Critical:** WoW executes **ONE slash command per chat submission**. Every
command below is in its own copyable block with immediately adjacent expected
output. Do not paste multiple WoW slash commands at once. Terminal commands
can be grouped.

## Step 1 — Select the modules and build offline

Nothing is automatically installed, merged, published or sent over the
network. The explicit **full** profile installs all twelve folders in one
local source ZIP. Each addon remains an independent folder; a player can
instead select `minimal`, `tank`, `professions` or custom `--include`
and `--exclude`. Only ForeverCore is mandatory. `ForeverGuild` is included
in the full profile but **never sends** without opt-in and a second explicit
manual announce command. It does register a minimal incoming event listener;
leave it out if you want a quieter installation.

Mac **Terminal**, not WoW chat:

~~~sh
cd ~/Developer/wow-forever-addons
git status --short
git fetch origin
git switch --track origin/feat/forever-modular-suite-integration
python3 tools/build_dev_bundle.py --list
python3 tools/build_dev_bundle.py --check --profile full
python3 tools/build_dev_bundle.py --profile full --output dist/ForeverSuite-full-DEV.zip
~~~

If you already have a local branch, switch without the `--track` flag.
Preserve uncommitted work before switching. Both validation and the ZIP
generator work offline; no third-party runtime dependencies are needed.

**Expected validation:** a line beginning `DEV candidate: full; 12 separately
installable addon folder(s)`, plus `Manifest and TOC validation: PASS
(not live client testing).`. Exact byte totals are dynamic. The build
prints a SHA256 and writes `dist/ForeverSuite-full-DEV.zip`. Do not claim the
SHA matches Git head; ZIP checksum and Git commit identify different objects.
The Git **current head SHA** must be recorded separately.

Alternatively, to omit the Guild module from a near-full, quiet developer
test build, run:

~~~sh
python3 tools/build_dev_bundle.py --profile full --exclude ForeverGuild --output dist/ForeverSuite-no-guild-DEV.zip
~~~

**Install only after you are ready.** Back up previously installed
`Forever*` addon folders first, because this is a stacked development
branch that may supersede earlier individual test folders. Fully quit WoW.
To install the **full** ZIP, in Terminal:

~~~sh
mkdir -p "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns"
unzip -oq dist/ForeverSuite-full-DEV.zip -d "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns"
~~~

The ZIP has `ForeverCore/`, `ForeverWarrior/` etc at its root, so each
directory extracts directly into `AddOns`, not into a monolithic
`ForeverSuite/` folder. Enable the desired independent packs from the
game's AddOns list. No public player release is approved.

**Important:** WoW does not delete old addon directories when extracting.
Previously installed optional modules remain present even when you build a
smaller profile; uninstall unwanted old folders separately while WoW is
closed. This is a practical limitation, not a packaging bug. Back up
and preserve non-Forever addons.

## Step 2 — Core, dashboard and modular lifecycle

**Test A1 — reload:**

~~~text
/reload
~~~

**Expected:** Normal UI reload, no Lua errors or unexpected addon spam.

**Test A2 — Core version:**

~~~text
/forever version
~~~

**Expected exact:**

~~~text
Forever Core: Version 0.2.0
~~~

**Test A3 — installed registry status:**

~~~text
/forever modules
~~~

**Expected format:** `Forever Core: <N> registered module(s).` followed by
one bounded module-status line per registered pack. Full profile has
11 **optional** modules (Core itself is not a registered optional pack).
Some modules may legitimately be disabled or ineligible (e.g. Warrior
on a non-Warrior character), so `N` is not necessarily 11.
If all eleven optional addon directories loaded correctly on Uddergrief,
`N` should equal **11**. No missing pack may be invented.

**Test A4 — Dashboard version:**

~~~text
/fdash version
~~~

**Expected exact:**

~~~text
Forever Dashboard: Version 0.2.0
~~~

**Test A5 — Dashboard text status, no frame allocation:**

~~~text
/fdash status
~~~

**Expected format:**

~~~text
Forever Dashboard: <N> registered module(s); <ACTIVE> active. (Core logical disabling does not unload Lua.)
~~~

**Test A6 — open dashboard:**

~~~text
/fdash
~~~

**Expected exact chat:**

~~~text
Forever Dashboard: Dashboard shown.
~~~

**Expected UI:** One movable 390x270 frame, first page with **at most six**
registered module rows and their current active/disabled/ineligible states.

**Test A7 — next Dashboard page:**

~~~text
/fdash next
~~~

**Expected format:**

~~~text
Forever Dashboard: Dashboard page 2/<PAGES>.
~~~

For 11 loaded packs, there are two pages, so expect **2/2**. Page number
clamps if fewer than seven packs are installed.

**Test A8 — previous Dashboard page:**

~~~text
/fdash prev
~~~

**Expected when two pages exist:**

~~~text
Forever Dashboard: Dashboard page 1/2.
~~~

**Test A9 — close dashboard:**

~~~text
/fdash
~~~

**Expected exact:**

~~~text
Forever Dashboard: Dashboard hidden.
~~~

A single frame should persist and be reused across many page changes and
open/close cycles; that is asserted in Lua mocked tests. A live screenshot
or current memory reading can confirm behavior, **not prove leak absence**.

## Step 3 — every gameplay pack works independently

These are smoke tests. Actual game data is variable; compare it to the
client rather than treating placeholders as real values. A failure in one
pack must not stop others.

**Test B1 — Warrior module:**

~~~text
/fw plan
~~~

**Expected:** If a Warrior and the module is active, five local Forever
Warrior advisory lines beginning `Forever Warrior: <CHARACTER> level <LEVEL>`.
Plans are **static advice**, not gear/talent/combat scanners. On a
non-Warrior character, an explicit ineligible diagnostic is correct.

**Test B2 — Journal module:**

~~~text
/fj version
~~~

**Expected exact:**

~~~text
Forever Journal: Version 0.5.0
~~~

**Test B3 — Inventory:**

~~~text
/finv
~~~

**Expected format when readable:**

~~~text
Forever Inventory: Bags 0-4: <OCCUPIED>/<SLOTS> occupied slots; <QUANTITY> total items (not AH prices).
~~~

An explicit unavailable message is acceptable **only** when the relevant
client API actually cannot read bags. Verify counts against the game.

**Test B4 — Gold:**

~~~text
/fgold
~~~

**Expected format:**

~~~text
Forever Gold: Wallet: <G>g <S>s <C>c (current character; not earnings).
~~~

**Test B5 — Professions:**

~~~text
/fprof
~~~

**Expected format:**

~~~text
Forever Professions: Known professions: <NAME> <RANK>/<MAX>; <NAME> <RANK>/<MAX>
~~~

The player's earlier readout listed five professions, apparently Herbalism,
Mining, First Aid, Fishing and Cooking, but the exact client spelling and
ranks can change; don't hardcode or assume continued training.

**Test B6 — Profession session goals:**

~~~text
/fprof goals
~~~

**Expected exact after fresh reload:**

~~~text
Forever Professions: No goals. Use /fprof goal <profession> <rank>.
~~~

No automatically restored goals or false account-wide history.

**Test B7 — Fishing readout:**

~~~text
/ffish
~~~

**Expected if Fishing trade window is open and API exposes it:**

~~~text
Forever Fishing: Fishing: <RANK>/<MAX> (open profession window).
Forever Fishing: Catches are manually logged only; no auto-fishing.
~~~

Otherwise the first line should read
`Forever Fishing: Fishing skill not readable; open Fishing UI and retry.`
and the second unchanged. This is a **different API** from /fprof;
missing data does not mean Fishing unlearned.

**Test B8 — Fishing manual log:**

~~~text
/ffish catches
~~~

**Expected exact after fresh reload:**

~~~text
Forever Fishing: No manual catches logged. Use /ffish log <count> <fish name>.
~~~

**Test B9 — Cooking:**

~~~text
/fcook
~~~

**Expected format when Cooking trade window API exposes it:**

~~~text
Forever Cooking: Cooking: <RANK>/<MAX> (open profession window).
Forever Cooking: Recipes and ingredient counts are NOT scanned.
~~~

Otherwise
`Forever Cooking: Cooking skill not readable; open Cooking UI and retry.`
plus the second caveat. No recipe completion claimed.

**Test B10 — Explorer:**

~~~text
/fexplore
~~~

**Expected format:**

~~~text
Forever Explorer: Current UI map: <MAP_NAME> (ID <MAP_ID>); NOT exploration credit.
~~~

Map ID is not evidence of exploration or zone completion.

**Test B11 — Guild privacy status only:**

~~~text
/fguild status
~~~

**Expected format:**

~~~text
Forever Guild: Sharing: OFF; API <registered|unavailable>; session only.
~~~

`<registered|unavailable>` reflects game API capability and is **not**
proof any data was sent. **Do not** run `/fguild optin` or
`/fguild announce` as part of this automatic test series. Sending
requires separate consent.

## Step 4 — matched memory and performance validation

**Test C1 — Performance version:**

~~~text
/fperf version
~~~

**Expected exact:**

~~~text
Forever Performance: Version 0.1.0 (on-demand only).
~~~

**Test C2 — On-demand known-pack memory:**

~~~text
/fperf memory
~~~

**Expected format:**

~~~text
Forever Performance: Memory: <N> known loaded pack(s), <TOTAL> KB total (addon-attributed).
~~~

Followed by top-three per-pack lines. The suite contains twelve known
cataloged folders including Core. The number should match **registered**
and loaded pack names, not automatically equal twelve if any failed to
load. Numbers vary by client/memory state and are **not total process RAM**.

**Test C3 — Detailed memory:**

~~~text
/fperf details
~~~

**Expected format:**

~~~text
Forever Performance: Details: <N> known loaded pack(s), <TOTAL> KB total.
~~~

Followed by one line per measured registered pack; no module is fabricated.

For a stability comparison, capture
`/fperf baseline`, play 15–30 minutes normally, and use `/fperf delta`
in **separate** chat entries, following
[PERFORMANCE_TESTING.md](PERFORMANCE_TESTING.md). Do not compare a
four-module snapshot with a new twelve-module install as proof of
optimization or a regression. Repeating after normal garbage collection is
a stronger signal than one temporary allocation spike.

## Acceptance / release boundaries

- [ ] Exact local Git SHA, bundle ZIP SHA256, selected profile, full client
  build and optional installed module list are recorded.
- [ ] Dashboard pages + all twelve folders integrated on the real client;
  one failed module does not crash Core or unrelated packs.
- [ ] No Lua errors, unwanted guild transmissions, automatic fishing,
  crafting, item selling, forbidden combat actions or background polling.
- [ ] User-provided memory before/after for a matched module set; no
  unsupported FPS or CPU figures.
- [ ] Verify module changes after in-game `/forever disable <id>`; those
  commands do **not** unload already resident Lua.
- [ ] Public source security, IP rights, license, beta-policy compliance,
  branch protections, signed-off release and user authorization. **DO NOT
  merge or distribute player releases without owner approval.**

This integrated test rounds out initial compatibility, not the complete
features of specialist addons such as Questie, ForeverArtisan, FishFry
or Auctionator. Their behavior and memory footprint must be measured on the
same client before performance comparisons can be claimed.

## CI evidence: what the integration test verifies (not live evidence)

The development branch includes `tests/test_full_integration.lua`. It loads
all twelve _Camelot.toc manifests in actual file order and executes mock
PLAYER_LOGIN, Core module registration, Dashboard paging, local command
routing, manual Memory details, and no-consent Guild behavior. The Core
single-subscriber event path is checked for zero per-message sorts in
this Lua 5.1 **mock**. The Python source validator additionally rejects
compiled Lua bytecode or unreadable/binary source and checks deterministic
bundle packaging. **None of these tests establish live FPS, live heap
memory, client API compatibility, actual cold restart profile persistence
or a safe public release.**

