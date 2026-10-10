# WoW: Forever addon suite — modular delivery roadmap

**Roadmap revision:** 2026-10-10  
**Owner:** code4Kush  
**Repository:** https://github.com/code4Kush/wow-forever-addons  
**Source of truth:** this plan + linked GitHub issues; completion evidence is in PR reviews, CI, and real game tests.  
**Scheduling:** milestone/dependency-driven, **no invented release dates**.

## Product goal

Build readable, well-documented, independently installable in-game addon packs for players who want completionist quest/exploration tracking, self-sufficient professions (including fishing and cooking), inventory/gold insights and class-specific preparation. Start with Uddergrief, a Tauren Warrior, but do not hardcode that identity or make Warrior functionality mandatory.

**Model:** ForeverCore (required) + optional ForeverDashboard + independently installable optional packs. Installing a pack and enabling its features for an individual character are different actions. A character's profile must be independent from the profile of another character. See docs/MODULE_ARCHITECTURE.md.

## Current evidence and honest status

- **Working on user's WoW: Forever beta interface 16001:** v0.1 slash commands; v0.2 active quest, objective counts, readiness, updated objective counts and Mulgore map 1412; v0.3 character identity and historical flags for quest IDs 747/752 were user-confirmed.
- **v0.4 partial acceptance:** player screenshot of `/fj journal 2` in Red Cloud Mesa displays *Mulgore starter catalog: 3/12 flagged complete, 2 active*, *Page 2/2*, and several `[not flagged]` entries without visible Lua errors. Player replied "pass i believe". Page 1, all edge cases, cold restart and numeric client build remain **unverified**.
- **Open PRs:** [#1 policy docs](https://github.com/code4Kush/wow-forever-addons/pull/1), [#2 quest reader](https://github.com/code4Kush/wow-forever-addons/pull/2), [#3 historical/character](https://github.com/code4Kush/wow-forever-addons/pull/3), [#4 curated Mulgore](https://github.com/code4Kush/wow-forever-addons/pull/4). #3 is stacked onto #2, #4 onto #3. **All open and not merged as of this review.** Keep reviews exact-SHA based and merge in correct dependency order only after remaining checks.
- Existing architecture on main is still the smaller v0.1 single addon, not the proposed modular suite.
- **No in-game module manager, dashboard, per-character preferences or saved-variable persistence yet.**

## Milestone map

| Milestone | Delivery / measurable outcome | Depends on | Current status | Issue |
| --- | --- | --- | --- | --- |
| **M0** | Stabilize and review tested v0.1–v0.4 journal work and official policy documentation | Existing PRs | **PARTIAL IN-GAME PASS**; merge checks remain | [#5](https://github.com/code4Kush/wow-forever-addons/issues/5) |
| **M1** | ForeverCore, documented versioned pack contract, lifecycle and registry | M0/API audit | Planned | [#6](https://github.com/code4Kush/wow-forever-addons/issues/6) |
| **M2** | Independent character profiles, module toggles and **cold-restart** SavedVariables probe | M1 | Planned | [#7](https://github.com/code4Kush/wow-forever-addons/issues/7) |
| **M3** | Optional ForeverDashboard shell with only installed/eligible/active feature tabs | M1; settings integration M2 | Planned | [#8](https://github.com/code4Kush/wow-forever-addons/issues/8) |
| **M4** | Journal refactor into pack; proven quest semantics and sourced zone catalogs | M0, M1; UI via M3 | Planned | [#9](https://github.com/code4Kush/wow-forever-addons/issues/9) |
| **M5** | Optional ForeverInventory pack, gear/material views | M1; UI via M3 | Planned | [#10](https://github.com/code4Kush/wow-forever-addons/issues/10) |
| **M6** | Optional ForeverGold session wallet and value insight | M1; M2 for saved baselines | Planned | [#11](https://github.com/code4Kush/wow-forever-addons/issues/11) |
| **M7** | Optional ForeverProfessions recipe and skill planner | M1; profession API verification | Planned | [#12](https://github.com/code4Kush/wow-forever-addons/issues/12) |
| **M8** | Independent Fishing and Cooking packs with opt-in cross-pack enrichment | M1; M2 for lifetime stats; M5/M7 optional | Planned | [#13](https://github.com/code4Kush/wow-forever-addons/issues/13) |
| **M9** | Optional Warrior tank preparation and gear reference; NO combat automation | M1; class API validation | Planned | [#14](https://github.com/code4Kush/wow-forever-addons/issues/14) |
| **M10** | Optional Explorer, distinguish true explored flag from manual checklist | M1; map API and provenance | Planned | [#15](https://github.com/code4Kush/wow-forever-addons/issues/15) |
| **M11** | Public source-visible, free packaging and compatibility gates for any release | M1–M3 + at least one accepted pack | Planned | [#16](https://github.com/code4Kush/wow-forever-addons/issues/16) |

These are **roadmap milestone identifiers**, implemented as GitHub issues, *not* claims that GitHub's built-in Milestones have been created. Checkboxes in the issues are the item-level backlog. A milestone is not DONE until code, automated checks, live-game checks and docs agree.

## Delivery increments: avoid a monolith

### Phase A — Trust the existing product (M0)

- [ ] Record full client build and interface with the player.
- [ ] Confirm v0.4 page 1 and pagination edge cases. Do not infer global Mulgore completion from the curated 12 quest IDs.
- [ ] Finish official-policy review PR and game behavior review on each exact commit.
- [ ] Run CI for exact final PR SHAs.
- [ ] Merge stacked PRs in dependency order, retargeting/rebasing safely if required.
- **Exit:** a reproducible working journal baseline; no unverified "complete" labels.

### Phase B — Foundations and selectable character modules (M1–M3)

- [ ] Introduce a separate small ForeverCore without breaking existing /fj behavior.
- [ ] Create feature registry, capability contracts, lifecycle and event-subscription cleanup; prove a feature pack can be absent.
- [ ] Add runtime character context and per-character on/off/profile choices.
- [ ] Run a **cold game restart** persistence experiment; no reliable storage claim before it passes.
- [ ] Introduce optional dashboard shell, showing only installed, compatible, eligible and enabled feature tabs.
- **Exit:** with two characters, changing one profile does not alter the other; disabling a pack removes UI and active listeners; standalone Core loads.

### Phase C — Useful gameplay packs (M4–M8, parallel after Core is stable)

Deliver Journal as the first pack, then Inventory and Gold for self-sufficiency, then Professions and independent Fishing/Cooking tools. Any pack can ship without other planned packs. Show unavailable provider data as unavailable, not zero; no auto-sale, auto-craft or auto-fishing.

- **Exit per pack:** standalone pack + Core game load; at least one verified live character use; off switch stops event work; commands/status matched expected output; diagnostics and documentation maintained.

### Phase D — Character-class and explorer tools (M9–M10)

Make the Warrior pack eligible only for verified Warriors, not because a character name matches "Uddergrief". This is a pre-combat readiness and reference tool; secret-value combat analysis and automation are out of scope. Explorer distinguishes curated points from actual explored data.

### Phase E — Ship when ready (M11)

The first public release does **not** require all packs. Publish Core + one proven optional pack with the whole distributed source publicly viewable and no premium addon features, ads or in-game donation solicitation. Include install/rollback instructions, real build compatibility, license and attribution checks, and documented performance limits.

## Proposed per-character presets (future UI, not implemented)

| Character archetype | Starting suggestion (user can override) | Not automatically forced |
| --- | --- | --- |
| **Uddergrief — Tauren Warrior** | Journal, Dashboard, Inventory, Gold, Warrior | Enable Professions, Fishing, Cooking or Explorer when desired; character name only for display |
| **Leveling Mage** | Journal, Dashboard, Inventory, Gold, Professions | Warrior is ineligible |
| **Healer/Priest** | Journal, Dashboard, Inventory, Professions | Warrior is ineligible |
| **Crafter/Fisher** | Professions, Fishing, Cooking, Inventory, Gold | Journal, Explorer and class features optional |
| **Minimalist** | Core + one installed eligible pack | Dashboard optional |

A preset is a *starting selection*, never a race/class access restriction except for modules that specifically require a verified class. Preferences must be editable per character, with clear account-vs-character scope.

## Work scheduling and safety gates

1. No due dates are committed until baseline milestones and build estimates are known; GitHub issues carry task state.
2. One feature/concern per PR; exact-SHA review and successful CI before game verification.
3. Record *proposed* API, evidence and target client; implementation must degrade safely if missing.
4. For every change, write its exact test command/action and expected output, with dynamic placeholders and PASS/FAIL (docs/MILESTONE_TEST_PROTOCOL.md).
5. Never use botting, combat automation, secret-value branching, client memory reading, external network calls from Lua, or unlawful asset redistribution.
6. Addendum after changing client build: rerun smoke tests and update the supported interface list.
7. Source quality is governed by CODING_STANDARDS.md and AGENTS.md. No empty scaffolding or unnecessary dependencies.

## Immediate next steps

1. Complete [M0 / issue #5](https://github.com/code4Kush/wow-forever-addons/issues/5) with v0.4 page-one + restart evidence.
2. Review and merge [PR #1](https://github.com/code4Kush/wow-forever-addons/pull/1) and [#2](https://github.com/code4Kush/wow-forever-addons/pull/2), [#3](https://github.com/code4Kush/wow-forever-addons/pull/3), [#4](https://github.com/code4Kush/wow-forever-addons/pull/4) in a safe order after acceptance.
3. Implement **M1** pack registry with two mock addons, then **M2** isolated character profiles + persistence probe.
4. Build the optional dashboard in **M3**; keep existing /fj commands available while migrating.
