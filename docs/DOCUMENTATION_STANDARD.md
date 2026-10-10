# Public WoW addon documentation standard

**Status:** Required project convention for future development and public release preparation.  
**Scope:** Every addon package, Lua module, public API, issue, pull request, release note and in-game test.  
**Last review:** 2026-10-10.

Readable source is a product requirement. Comments are not a substitute for clear structure or tests; they should document intent, contracts, decisions, and the behavior a developer cannot easily infer from reading one line.

## 1. Source code and Lua contract documentation

For **every** shipped Lua file:

- Start with a brief purpose/ownership comment: what belongs here, what it does **not** do, expected TOC load order and required addons where non-obvious.
- Prefer small modules, descriptive identifiers, Lua 5.1 syntax and four-space indentation. Explain *why* and edge cases, not every assignment.
- Annotate **exported** public functions and shared namespace methods with LuaLS-style `@param`, `@return`, supported nil/error results and version/availability notes for game APIs. Include examples only when they prevent misuse.
- Name the scope of stored state: account-level, character-level, current session or game-provided history. State migration/version rules if saved variables exist.
- For event handlers: document event names, trigger timing, cleanup/unsubscription, throttling, and what happens if the feature is disabled or a game API is absent.
- Keep game-dependent adapter code separate from pure logic; show fallback behavior for unknown/uncached data and don't treat nil as a real zero.
- Comment protected/secret-value limitations at the boundary. Do not implement combat automation, item automation, memory reading or unsupported game API access.
- Keep TOC fields/optional hard dependencies clear; `## Dependencies` is a loader relationship, while a Core registry preference is a *runtime/session* setting.
- Document license/copyright provenance for each third-party library or data catalog. Do not copy Blizzard quest descriptions, sound or artwork without permission.

For every addon **README**, include: who it helps, supported client/known interface build, dependencies and optional capabilities, installation/uninstallation, commands (each separately copyable), expected outputs, known limitations, privacy/persistence, troubleshooting, tested vs untested features, source and license status.

For every API assumption, add to `docs/API_NOTES.md` (or module-specific compatibility notes): function name, evidence URL, last reviewed date, game build, positive/negative test result, fallback and remaining uncertainty. Separate *community reference*, *automated mock* and *observed game output*.

For every behavior change: update appropriate tests, architecture docs, changelog and support documentation **in the same PR**, or explicitly explain why not applicable.

## 2. GitHub issue definition of quality

An issue should be independently actionable by a future contributor. It must contain:

1. **Title and outcome:** concise scope and actual player benefit.
2. **Current state:** PLANNED, IN PROGRESS, CODED/CI PASS, PARTIAL GAME PASS, GAME VERIFIED, or RELEASED. Never imply mocked tests equal a game pass.
3. **Scope/exclusions:** pack(s) affected, what will not be built, and whether optional packs are required.
4. **Dependencies:** upstream issues/PRs and client/API evidence.
5. **Implementation checklist:** source modules, tests, docs, error handling and performance.
6. **Acceptance criteria:** exact single-command game tests, expected output with variable placeholders and unambiguous PASS/FAIL. UI tests specify expected screen state.
7. **Risks:** class/race restrictions, Protected UI/secret values, save data/persistence, catalog provenance, regression and rollback.
8. **Completion evidence:** actual game output or screenshot, character/class, date, full client build if available, exact commit SHA and CI run URL.

Update checkboxes only when supported by evidence. Mark individual passes separately; if the player says "pass" to a subset, record only that subset. Never close a public issue just because implementation compiles.

Issue templates: [bug](../.github/ISSUE_TEMPLATE/01_bug_report.yml), [feature](../.github/ISSUE_TEMPLATE/02_feature_request.yml), [API compatibility](../.github/ISSUE_TEMPLATE/03_compatibility.yml).

## 3. Pull request definition of quality

Every PR should contain:

- Player-visible change summary and issue/milestone link.
- Changed-file inventory and public API/manifest/TOC changes.
- **Explicit dependency/stack information** when base is another feature branch, including merge order; no silent merges.
- Scoped exclusions, privacy/licensing impact, optional pack behavior and backwards compatibility.
- API references and actual build evidence, event and SavedVariables notes.
- Automated test commands, outcomes and **exact head SHA** plus CI URL.
- Game verification: each WoW slash command in its own fenced block; **immediately following** expected output in a separate block; dynamic fields explained; actual result and PASS/FAIL. Don't batch WoW slash commands. CLI/shell commands have different rules.
- Regression cases, class/character variants, missing-API fallback, `/reload` and cold restart when relevant.
- Risk, rollback and release impact.
- Documentation, changelog and public source/license checklist.

A **draft PR** means the implementation and/or verification is incomplete. A green CI check means only the tests defined in CI passed. Merging/releasing requires review of exact code and the applicable game test gates. Preserve failures and remaining unknowns prominently.

## 4. Publication requirements

Public distribution of a WoW addon must follow Blizzard's [official UI Add-On Development Policy](https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534) and the EULA. In particular, addon code must be completely visible, unobfuscated and publicly accessible when distributed; the addon itself must be free without premium features, advertisements or in-game donation solicitation.

Source visibility **is not** a substitute for an explicit license grant. The owner must approve the license for their original code and confirm rights to all reused assets/code before public distribution. No license is chosen by this standard.

**Not Blizzard endorsed:** Be transparent that this is an independent community project. Review policy again immediately before release; game APIs and policies can change.

See [PUBLIC_RELEASE_PLAN.md](PUBLIC_RELEASE_PLAN.md) and the official-policy docs proposed in [PR #1](https://github.com/code4Kush/wow-forever-addons/pull/1).

## 5. Evidence quality example

**Claim:** `/forever disable probe-warrior` was observed by the player to disable the Warrior fixture, leaving 1 listener.

- Evidence: user-reported match to expected output on WoW Forever beta interface 16001; project record in Core M1 issue.
- Confirmed: one module disabled and subscriptions dropped from 2 to 1.
- Not confirmed: dropping last listener to 0, re-enabling to 1, a second class character, full client build and cold restart.
- Future changes should continue from this partial record, not report the whole M1 test as complete.

This distinction is essential when the project becomes publicly maintained.
