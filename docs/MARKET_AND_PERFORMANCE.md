# Forever Addons — competitive review and performance architecture

**Review date: 2026-10-10.** This document compares public descriptions of
current WoW Forever addons and the **code actually implemented** in the
Forever Addons development branch. Claims are scoped by source and date;
no third-party source, game data, graphics, licenses or proprietary guides
were imported. **A listing is not a firsthand benchmark.** Testing for
our suite uses player-observed Forever 1.60.1 build 70338 when available;
the integrated developer bundle itself still requires a separate field test.

## What players already have

| Area | Existing option and evidence | What we do (and don't) offer |
| --- | --- | --- |
| Quests/map | Questie has a Forever build; Leatrix Maps/Plus also support Forever: https://www.wofwforever.com/en/hubs/addons/ | ForeverJournal shows actual quest-log/history candidates and a deliberately incomplete curated Mulgore starter list; Explorer only labels current UI map. **Not** full quest objective routing or 100% completion. |
| Bags/economy | Bagnon, Auctionator have Forever builds, per https://www.wofwforever.com/en/hubs/addons/ | Inventory counts bags 0–4 on request, Gold checks current wallet and manually compared net change. No AH prices, price database, automatic selling or profit inference. |
| Fishing/cooking | FishFry offers on-screen fishing/cooking utilities, guides, sessions and more: https://www.curseforge.com/wow/addons/fishfry-forever | Fishing 0.2 offers read-only Fishing UI skill and **player-entered** session catch notes. Cooking 0.1 reads the open Cooking UI skill. **No** automatic catch detection, cooking recipes, bait mapping or auto-fishing. |
| Tradeskills | ForeverArtisan 1.60.1 lists per-profession modules, recipe/cost planning, gathering and Camping helpers: https://www.curseforge.com/wow/addons/foreverartisan | Professions 0.3 reads exposed skill ranks, compares session snapshots and supports up to five manual targets. No recipe database, AH optimization or automated trainer actions. |
| Tank tools | Game has built-in damage/Cooldown tools; Forever uses the modern restricted API: https://github.com/Thunderz96/forever-addon-kit | ForeverWarrior gives manually reviewed leveling/dungeon readiness guidance and no combat-log/threat inference. Does not attempt prohibited/secret-value analysis or pretend to automate threat generation. |
| Dev compatibility | Community Forever API snapshot and development environment: https://github.com/Thunderz96/forever-addon-kit and https://github.com/Atraeau/WoW-Addons | We validate `16001` manifests, register modules in Core, use documented Retail-derived APIs defensively and retain build-scoped evidence. |

The important distinction: competitors are often **far more feature-rich**.
We aim for independent installation, predictable memory, a shared optional
status hub and honest API/failure semantics—not unsupported claims of being
more capable or faster than them.

## What's improved in this integrated development branch

1. **Composable files, not an always-on monolith.** Every gameplay module
   is a separate `Forever<Name>/` directory with its own `_Camelot.toc`
   and only a Core hard dependency. One zip can install them together, but
   `--profile minimal` keeps *only Core*, `tank` selects the modules for
   Uddergrief, and `professions` omits Warrior/Guild/Journal entirely.
   Custom include/exclude is explicit, not magic detection.
2. **Safe reproducible offline dev ZIP.** Python 3 standard library,
   sorted contents, constant ZIP timestamps, stable bytes, SHA256 output.
   The builder validates declared TOC Lua files, Core dependencies,
   expected interface, size and filetype bounds, traversal/symlinks, and
   rejects any surprise module/source. It makes no automatic changes
   to the player's game installation and performs no HTTP requests.
3. **Lazy bounded UI.** Dashboard v0.2 creates one frame and one label
   only when first opened; uses the same objects for every page, with up
   to six status rows visible. No `OnUpdate`, timers, scheduled refresh
   or registered events. Status-only `/fdash status` does not allocate a
   frame. This is **a design property confirmed by mocked tests**, not a
   measured in-game improvement over the v0.1 memory trace.
4. **Opt-in data and explicit uncertainty.** Gold baseline, skill goals,
   Fishing notes and memory snapshots are session-only. Guild messages
   require explicit opt-in and separate announce. A Core-disabled module
   can still occupy Lua memory until UI reload; Dashboard/Performance
   do not hide that fact. Fishing manual entries **are not verified
   catches**. Missing game data is unknown, not zero.
5. **Independent test gates.** Lua 5.1 mocks cover per-pack behavior,
   Python tests cover deterministic/safe dev packaging, and manual live
   verification covers Forever-specific API semantics. One test layer
   does not substitute for another.

## What we actually know about memory

The user previously shared in-game ForeverPerformance screenshots with
**four** known loaded packs: Core 47.34 KB, Dashboard 11.32 KB,
Warrior 22.42 KB and Performance 33.63 KB, total **114.71 KB** for that
specific sample. Later, after saving a separate four-pack session
baseline of 111.89 KB, they reported total 105.73 KB: net **−6.16 KB**.
ForeverPerformance itself changed −4.94 KB, Dashboard +0.00 KB, and the
Core −1.22 KB change was **inferred** from the total because the pasted
Core line lacked a readable sign. Duration and exact installed SHA were
not independently recorded. These do not prove no leaks, do not measure
CPU/FPS and do not apply to a full twelve-pack installation.

**No comparable measurements exist for ForeverArtisan, FishFry, Questie,
Bagnon or Leatrix on the same client.** We therefore claim **no**
benchmark speed, memory or FPS superiority over any competitor.

## Repeatable optimization method

- Test the same set of addon folders on the same Forever build, ideally
  same character and similar conditions. Compare `/fperf baseline`
  with later `/fperf delta` entered individually; record exactly which
  optional packs were installed at each reading.
- For per-pack memory, `/fperf details` lists currently registered,
  loaded Forever folders. It is **addon-attributed Lua KB**, not process
  RAM, texture memory, GPU VRAM or measurable FPS.
- Use a controlled after-garbage-collection comparison across multiple
  open/close cycles if pursuing a suspected leak. The performance module
  itself **never** triggers garbage collection, and users should not
  be asked to run manual GC repeatedly during ordinary play.
- Observe FPS and CPU with real WoW/client measurement tools only when
  supported and reproducible. Do **not** estimate numbers from Lua file
  size, source line count, ZIP size or timing mocks.
- Early ergonomic target: Core+Tank profile should be more selective
  than Full. That means fewer installed Lua files by construction,
  **not yet demonstrated** lower real-world time/RAM versus other suites.
- Explicit performance limitation: Full includes Guild, which registers
  its one `CHAT_MSG_ADDON` Core event callback when loaded, even while
  session sharing consent is OFF. It **never sends** without opt-in,
  but is not literally zero background event dispatch. Omit Guild
  from a quiet profile if no network discovery is wanted.
- Explicit compatibility limitation: Forever's restricted Retail-style
  APIs prohibit many Classic-style threat/combat log analyses. Do not
  work around secrets or present guesswork as tank telemetry.

## Modular workflow and release gates

To build without installing:
`python3 tools/build_dev_bundle.py --check --profile full`.

To create a local developer ZIP:
`python3 tools/build_dev_bundle.py --profile full --output
dist/ForeverSuite-full-DEV.zip`.

Each selected folder remains independent. No public downloadable release
is authorized simply because a ZIP exists locally. The repository has
not selected a code license, and final security/IP/Blizzard policy review,
exact-head CI, game testing and explicit owner merge/release permission
remain required.

Full one-chat-command-at-a-time field test:
[FULL_SUITE_TESTING.md](FULL_SUITE_TESTING.md).

## Further full-load and low-allocation checks (integration PR #37)

A dedicated Lua 5.1 integration test now loads **all twelve actual `_Camelot.toc` manifests** in their declared file order with independent addon namespaces and one shared ForeverCore registration contract. It verifies eleven optional modules register and activate for the mock Tauren Warrior, that Dashboard page 2/2 is accessible with eleven packs, and that Guild starts without consent or outgoing messages. These are simulated game APIs; a **real combined installation on build 70338 is still unverified**.

The shared Core event bridge now uses a fast path when there is **only one event subscriber**: it invokes that module without building and sorting a temporary ID array. This is relevant to the Guild-only `CHAT_MSG_ADDON` subscription in a full installation. The multi-subscriber case keeps the stable sorted snapshot and error isolation. The new mock test confirms **zero table sorts** on the single-subscriber event path; it does **not** prove any quantifiable reduction in FPS time or addon RAM.

The offline ZIP builder now rejects binary Lua bytecode and non-UTF-8 or control-byte source files as part of its strict source-readability policy. A green validator is still **not** a code-license, copyright, security, or Blizzard policy approval.


## Post-comparison beta integration: performance v0.2

User screenshots from a clean, earlier all-twelve-folder ForeverPerformance **0.1** session showed a 346.58 KB baseline, +27.05 KB to 373.62 KB, and a **different** later detailed sample of 405.96 KB. On-screen values included ForeverPerformance 122.88 KB and ForeverCore 108.15 KB in that later sample. These attributed LUA values fluctuate with garbage collection and the measurement itself; **no leak was demonstrated and no independent competing addon benchmark exists**. Performance 0.2 removes whole-list sorting and retains at most the three user-visible memory/delta ranking rows per report, with mocked comparison-order tests; a measured client gain still requires matched baseline and follow-up under the new build. The full twelve-pack developer artifact intentionally excludes old `probe-general` and `probe-warrior` addons. See [FULL_BETA_ACCEPTANCE.md](FULL_BETA_ACCEPTANCE.md).

