# WoW Forever Addons

A readable, documented collection of World of Warcraft: Forever addons.

**Status:** Early development. The first addon, Forever Journal, is a minimal working foundation, **not yet a quest or exploration tracker**.

## Guiding principles

- Make the code easy to understand six months later.
- Keep each addon installable on its own.
- Favor small modules and explicit dependencies over abstractions.
- Verify Forever-specific API behavior on the actual client build.
- Never automate gameplay or bypass Blizzard addon restrictions.
- Keep source, documentation, tests, and changelog together.

## Repository layout

~~~text
addons/
  ForeverJournal/
    ForeverJournal_Camelot.toc
    Core/
    Modules/
    README.md
docs/
  ARCHITECTURE.md
  DEVELOPMENT.md
  TESTING.md
  API_NOTES.md
  BLIZZARD_POLICY.md
  RELEASE_CHECKLIST.md
tests/
  test_progress.lua
.github/workflows/
  lua-tests.yml
AGENTS.md
CODING_STANDARDS.md
CONTRIBUTING.md
CHANGELOG.md
~~~

## First addon: Forever Journal

Version 0.1.0 provides a slash command and a pure-Lua completion calculator.

- /fj — display help
- /fj version — show addon version
- /fj progress 3 5 — calculate 60% completion from two manually supplied counts

There is **no automatic quest reading, UI dashboard, or persistent completion tracking yet**.

## Get started

1. Read docs/DEVELOPMENT.md and docs/API_NOTES.md.
2. Copy the folder addons/ForeverJournal to the beta client's Interface/AddOns directory.
3. Log into the game and verify that Forever Journal is enabled in AddOns.
4. Type /fj in chat.
5. Run tests locally with: lua5.1 tests/test_progress.lua

The recorded beta interface number is 16001; verify it on your own client after patches. Avoid assuming the current API matches Classic Era simply because the setting is vanilla-inspired.

## Source of truth

- AGENTS.md: requirements for Codex and other coding agents.
- CODING_STANDARDS.md: rules for readable, maintainable Lua.
- docs/ARCHITECTURE.md: dependency and module boundaries.
- docs/API_NOTES.md: evidence-based API and beta compatibility notes.
- docs/BLIZZARD_POLICY.md: official Blizzard policy, source links, and the distinction between addons and external API applications.
- docs/RELEASE_CHECKLIST.md: pre-publication compliance and client test gate.
- docs/TESTING.md: tests and in-game verification.
- CONTRIBUTING.md: change and review workflow.

No license has been selected. Do not assume permission to redistribute this repository or third-party code. **Before public distribution**, Blizzard's addon policy requires the complete addon source to be publicly viewable; private development alone is not the same as public distribution.
