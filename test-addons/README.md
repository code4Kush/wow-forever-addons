# Developer-only Core fixture packs

`ForeverProbeGeneral` and `ForeverProbeWarrior` are tiny standalone WoW addon packages for testing ForeverCore M1 on the actual client.

- **General:** registers `probe-general` (capability `probe.general`), subscribes to `PLAYER_LEVEL_UP`.
- **Warrior:** registers `probe-warrior` (capability `probe.warrior`), eligible only when the current player's verified class token is `WARRIOR`. Uddergrief is not hardcoded.
- Neither package performs combat actions, draws UI or sends unsolicited chat.
- These packages are **not** production modules, and should not be included in public release bundles.

Copy each whole folder from `test-addons/` to the game client's `Interface/AddOns/`, enable them in the AddOns menu and use the documented commands in `docs/CORE_TESTING.md`. To remove fixtures later, quit the client and delete those two fixture directories (leave `addons/ForeverCore` and `ForeverJournal` untouched).
