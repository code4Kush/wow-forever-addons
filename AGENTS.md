# Repository instructions for coding agents

Read this document before any edits. Also read CODING_STANDARDS.md, docs/ARCHITECTURE.md, docs/API_NOTES.md, docs/BLIZZARD_POLICY.md, docs/RELEASE_CHECKLIST.md, and the relevant addon's README.

## Blizzard policy gate

- Distinguish an in-game Lua addon from a separate Blizzard web-API application; the rules and credential requirements differ.
- All publicly distributed addon code must be fully visible; no obfuscation, paid features, in-game advertising, or donation prompts.
- Keep the source private while developing if desired, but do not publicly distribute the addon until its full code is accessible to everyone.
- Avoid copyrighted Blizzard assets, botting, memory reading, client modification, combat automation, unauthorized data extraction, or attempts to bypass secret values.
- Use official Blizzard policy and legal links in docs/BLIZZARD_POLICY.md as normative rules. Treat community repositories and mirrors as secondary compatibility evidence, never official authority.
- Before release, complete docs/RELEASE_CHECKLIST.md and record game-client build, tests, and remaining uncertainties.

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
- When adding an API assumption, update docs/API_NOTES.md with source URL, build number, observation date, and confidence.
- Update the addon README and CHANGELOG.md when user-facing behavior changes.
- In the PR or completion report, state files changed, behavior added, test results, and unverified claims.
- Never say tests passed unless they actually ran successfully.

## Review checklist

Confirm: load order; Lua 5.1 compatibility; namespace use; test coverage; slash command behavior; addon manifest; documentation changes; and API provenance.
