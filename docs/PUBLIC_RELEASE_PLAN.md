# Public distribution plan and release gate

**State:** PRE-RELEASE. This file is a release readiness specification; it does not authorize changing the repository's visibility or shipping any download.  
**Owner decision pending:** explicit source-code license and public distribution timing.  
**Last checked:** 2026-10-10.

## What "public" means here

This is a future **free, community-maintained WoW: Forever addon suite** with a small optional-pack architecture. The client is experimental and may change its APIs. Each user-facing package should say which game flavor and interface/client build are *verified*, *claimed*, or *untested*.

WoW's published [UI Add-On Development Policy](https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534) requires the full distributed addon code to be visible and publicly accessible (no obfuscation), prohibits charging for addon features and forbids in-game advertising and donation solicitations. Review the official Blizzard EULA and other current rules before distribution. A private development GitHub repository can remain private before release, but a public distribution must have a publicly accessible full source.

**No claim of Blizzard affiliation or endorsement.** WoW, World of Warcraft and Blizzard belong to their respective rights holders.

## Publication model

- **Source:** host complete, human-readable code, TOC, any bundled data files and all necessary local dependencies in a publicly accessible repository/location *no later than the first public package release*. Public GitHub is an option, not yet approved.
- **Release package:** each addon directory is independently installable where valid; include mandatory Core and any chosen optional feature packs. Test fixtures (`test-addons/`) and internal debugging files must not ship in an ordinary player release.
- **Downloads:** no paywall, timed unlocks, payment requirements, embedded promotions or premium feature licensing. Community contributions may be discussed outside the game only under the applicable policy.
- **User privacy:** do not collect or transmit player GUID, realm, screenshots, chat, inventory or account data externally without separate consent and design review. In-game Lua does not get arbitrary external networking.
- **Compatibility:** clearly declare beta build/interface and limitations. Do not claim support for retail or Classic unless tested.
- **Support:** use public bug/feature/API issue templates for regular questions and crash reports. Do not post authentication tokens or private character details in public issues.

## License: deliberate project-owner choice required

**Current state: NO LICENSE chosen.** Blizzard's *source visibility* rule does not itself dictate MIT/GPL/Apache or waive a third party's copyright. Before sharing the addon publicly, choose a license for original code and record it in a root `LICENSE` file (and, where helpful, file headers and distribution pages). Review code contributions and permissions before licensing.

Decision guidance (not a recommendation made on the owner's behalf):
- **MIT / BSD-2-Clause:** permissive reuse with attribution and license retention.
- **Apache-2.0:** permissive with additional patent-license conditions and NOTICE rules where applicable.
- **GPL-3.0-only:** redistribution of derivative covered code must satisfy GPL obligations, including sharing corresponding source.
- **Viewable but all rights reserved:** source may be public, but reuse permissions remain restrictive; check that this meets intended contributor and distribution workflows.

Choose based on intended contributor rights and dependencies. Never silently declare a license or copy incompatible source.

## Per-release checklist

Create a tracked release issue/PR, then complete:

- [ ] License selected and approved by the owner; complete contributor/IP inventory recorded.
- [ ] Source is accessible to all and matches the exact download/release commit; code is readable/unobfuscated.
- [ ] Target game flavor, TOC suffix, interface/build, addon dependencies and installation directory documented.
- [ ] Code, documentation, changelog, expected outputs, issue tracker and release notes updated.
- [ ] Exact-SHA automated tests pass; code review checks Lua 5.1, imports/globals, event lifecycle, performance and protected-value compliance.
- [ ] Game smoke test passes on a real client, with actual character/build, commands, expected vs actual output and regression coverage.
- [ ] Optional-pack install/remove behavior tested: Core-alone, Core+one module, missing-pack error and class-ineligible paths.
- [ ] `/reload` and **full quit/restart** behavior verified; SavedVariables reliably restored before claiming permanent character settings.
- [ ] No in-game donations, promotions, paid unlocks, botting, combat automation, memory readers, secret-value bypass or unauthorized network behavior.
- [ ] No redistribution of copyrighted WoW assets, quest descriptions or third-party sources without rights.
- [ ] Test/dev fixtures, credentials, personal notes and private data excluded from distributed archive.
- [ ] Installation, upgrade, rollback and uninstall instructions work on the supported client.
- [ ] Maintainer/owner approves the release, public source location and publication date explicitly.

**Evidence:** issue/PR links, exact commit SHA, CI URL, screenshots as appropriate, known limitations and new release notes. No passing check may be inferred from "looks good" without the matching test.

## Distribution options to decide later

Possible distribution surfaces include GitHub Releases and established WoW addon sites; choose after the first supported public client builds and packaging compatibility are tested. Do not claim such publication has already happened.

## Current project gates (2026-10-10)

- Existing gameplay work: Journal 0.2–0.4 still in unmerged PRs #2/#3/#4; Core M1 in draft PR #18.
- Official Blizzard policy documentation is under PR #1.
- Core has passed initial smoke/integration tests. Event listener cleanup is **partially** verified (2→1); remaining checks not yet done.
- WoW beta full numeric build unknown; `16001` is an observed interface value.
- Per-character SavedVariables reliability not yet tested.
- Code license unselected; repo visibility/public distribution decision not approved.

**Release status: BLOCKED pending these gates.** This is a quality control state, not a claim that the project has failed.
