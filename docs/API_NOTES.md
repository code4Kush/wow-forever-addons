# WoW: Forever API and compatibility notes

Last documentary review: 2026-10-10. These are external reports, **not a record of testing the owner's own client**.

## M1 Core candidate — conventional APIs still requiring live Forever verification

- `PLAYER_LOGIN`, `CreateFrame`, `Frame:RegisterEvent`, `Frame:UnregisterEvent`, `Frame:SetScript` for a single Core event bridge.
- `UnitName`, `UnitClass`, `UnitRace`, `UnitLevel`, `UnitGUID`, `GetRealmName` for runtime character identity (some can be unavailable).
- `SlashCmdList` registration for `/forever` diagnostic commands.
- `## Dependencies: ForeverCore` manifest load-order behavior with `_Camelot.toc` must be proven on the target 16001 client.

Reference: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API ; https://warcraft.wiki.gg/wiki/TOC_format

These APIs and loading conditions are **NOT YET GAME-TESTED in the new Core**. No Core-only session, cross-character or persistence pass has been recorded. Tests are documented in `docs/CORE_TESTING.md`.

## Recorded beta baseline

- WoW: Forever 1.60.1 beta uses TOC Interface 16001 in community-verified builds.
- The beta product folder has been reported as _classic_beta_.
- A modern/Mainline-style WoW UI API is used despite Forever's classic game design.
- Addon manifests named with _Camelot.toc have been used by Forever addon developers.

References:
- https://github.com/Thunderz96/forever-addon-kit
- https://github.com/Atraeau/WoW-Addons
- https://github.com/Atraeau/WoW-Addons/blob/main/docs/api/README.md
- https://www.curseforge.com/wow/addons/quest-master

## Known risks

- Existing Classic Era API examples may call removed globals; inspect the modern C_* namespaces first.
- Modern WoW includes restrictions around protected actions and secret values. This project will not attempt to bypass them.
- A 2026-09 beta report identified saved-variable loading problems. Persistent completion data must be verified across **cold game restarts** before relying on it.

## APIs used by initial scaffold

- CreateFrame("Frame") and PLAYER_LOGIN to mark readiness: conventional WoW event use, **not individually validated in Forever by this project**.
- SlashCmdList and SLASH_FOREVERJOURNAL1 to register /fj: conventional WoW slash-command use, **not individually validated in Forever by this project**.
- No quest, map, collection, combat, or persistence APIs are currently invoked.

## Evidence convention

Each future API entry should include function/event name, source URL, client build, date, whether tested in-game, expected behavior, and limitations. Never translate reported beta behavior into an unconditional guarantee.
