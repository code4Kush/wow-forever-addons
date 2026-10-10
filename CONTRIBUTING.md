# Contributing

Changes begin with a single clear purpose and a short description of expected game behavior.

1. Read AGENTS.md and CODING_STANDARDS.md.
2. Create a focused branch; avoid mixing unrelated addons or features.
3. Add or update tests for pure-Lua logic.
4. Record which live client build was used for any in-game testing.
5. Update documentation and CHANGELOG.md for behavior changes.
6. Open a pull request with a summary, risk/compatibility notes, verification evidence, and known limitations.

All public contributions must follow [docs/DOCUMENTATION_STANDARD.md](docs/DOCUMENTATION_STANDARD.md). Use the GitHub issue templates and PR template; an issue/PR without clear acceptance evidence and limits is incomplete. Write **one WoW slash command per code block**, followed immediately by literal expected output, PASS/FAIL and actual game observation (or NOT TESTED IN GAME). GitHub Actions passing mocked Lua tests is not live API compatibility.

Treat source readability, API provenance, optional-pack boundaries, release integrity and public copyright/license decisions as part of the feature. Explain which parts are character-specific and what happens if an API is unavailable. Do not ship bundled developer test addons.

Use descriptive commit messages, for example: feat(journal): add progress command.

This project is being prepared for public distribution, but the repository remains a development space until the owner approves a public release. See [docs/PUBLIC_RELEASE_PLAN.md](docs/PUBLIC_RELEASE_PLAN.md); no code license has yet been selected.

Do not submit code that automates gameplay, circumvents combat restrictions, or reproduces third-party work without compatible rights.
