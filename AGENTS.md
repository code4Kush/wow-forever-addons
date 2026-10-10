# Repository instructions for coding agents

Read this document before any edits. Also read CODING_STANDARDS.md, docs/ARCHITECTURE.md, docs/API_NOTES.md, and the relevant addon's README.

## Scope and priorities

1. Write understandable, intentionally structured code.
2. Keep addons separate and individually installable.
3. Do not claim a WoW: Forever API works unless supported by a cited reference or a recorded in-game test on a named build.
4. Preserve the known working behavior of /fj and the Lua 5.1 tests.
5. Keep each change as small and testable as practicable.
6. Do not modify unrelated files or introduce unnecessary dependencies.

## Code requirements

- Write Lua 5.1-compatible syntax. Do not use require, dofile, filesystem calls, or networking in shipped addon code.
- Use the TOC to establish explicit file load order and pass shared state via the addon's namespace (the second value of ...).
- Use four-space indentation and descriptive identifiers.
- Give modules a short purpose comment and public functions LuaLS-style @param / @return documentation.
- Document decisions, edge cases, and limitations; do not narrate obvious statements.
- Keep game API calls out of pure calculation modules.
- Check nil results and evolving event/API availability where applicable.
- Avoid insecure combat automation, protected actions, or secret-value branching.
- Do not copy third-party source without licensing review and attribution.

## Verification and delivery

- Run lua5.1 tests/test_progress.lua whenever calculation behavior changes.
- Run luacheck addons if installed.
- For game-facing changes, document an actual in-game test or mark clearly as NOT TESTED IN GAME.
- WoW's chat accepts slash commands one submission at a time. Present EACH command in its own copyable code block; NEVER put multiple WoW slash commands in one block or suggest that WoW will run a pasted batch. Follow each command with its expected output and explain any variable fields, PASS and FAIL conditions. Shell/Terminal commands are a separate context and may be batched appropriately.
- When adding an API assumption, update docs/API_NOTES.md with source URL, build number, observation date, and confidence.
- Update the addon README and CHANGELOG.md when user-facing behavior changes.
- In the PR or completion report, state files changed, behavior added, test results, and unverified claims.
- This is a future **publicly distributed** WoW addon suite. Treat maintainability, clear source visibility, policy compliance, and accessible documentation as release blockers, not optional niceties.
- Every new/modified module, public API, exported global, TOC dependency, and important lifecycle or failure path must be documented. Explain non-obvious state ownership, optional dependencies, and behavior when game APIs are unavailable. Use readable LuaLS-style doc comments without redundant line-by-line narration.
- Every issue must contain purpose, player value, scope and exclusions, dependencies, implementation tasks, acceptance checks, exact expected test results (when testable), and known risks.
- Every PR must include linked issue, change summary and file inventory, user-visible behavior and compatibility/API evidence, automated test SHA/results, manual commands **separately** with expected output and actual PASS/FAIL observations, risks, and release impact. Do not conflate mocked CI with live client verification.
- Public distribution is gated on current Blizzard policy review, complete readable/unobfuscated source accessible to all, free access, no in-game ads/donation requests, third-party IP/license review, an explicit code-license decision, and release notes. Do not make the repository public or distribute builds without the owner's explicit release decision.

- Never say tests passed unless they actually ran successfully.

## Review checklist

Confirm: load order; Lua 5.1 compatibility; namespace use; test coverage; slash command behavior; addon manifest; documentation changes; and API provenance.
