# WoW: Forever API and compatibility notes

Last documentary review: 2026-10-10. These are external reports, **not a record of testing the owner's own client**.

## M1 Core candidate — conventional APIs still requiring live Forever verification

- `PLAYER_LOGIN`, `CreateFrame`, `Frame:RegisterEvent`, `Frame:UnregisterEvent`, `Frame:SetScript` for a single Core event bridge.
- `UnitName`, `UnitClass`, `UnitRace`, `UnitLevel`, `UnitGUID`, `GetRealmName` for runtime character identity (some can be unavailable).
- `SlashCmdList` registration for `/forever` diagnostic commands.
- `## Dependencies: ForeverCore` manifest load-order behavior with `_Camelot.toc` must be proven on the target 16001 client.

Reference: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API ; https://warcraft.wiki.gg/wiki/TOC_format

These APIs and loading conditions are **NOT YET GAME-TESTED in the new Core**. No Core-only session, cross-character or persistence pass has been recorded. Tests are documented in `docs/CORE_TESTING.md`.

## M9 ForeverWarrior starter — new use of character APIs

- `ForeverCore.GetCharacter()` and `ForeverCore.GetModuleStatus()` are the draft M1 integration contract, not built-in Blizzard functions. M1 has partial player-reported live acceptance; M9 integration remains **NOT TESTED IN GAME**.
- `UnitLevel("player")` is invoked only when the player deliberately requests `/fw plan` to refresh the level after login, with the Core identity snapshot as a fallback. No scanning/recording occurs. Conventional read-only API: https://warcraft.wiki.gg/wiki/API_UnitLevel . Target: Forever beta interface 16001; actual current build has not been captured for M9; evidence type: source/reference only.
- `SlashCmdList.FOREVERWARRIOR` and `SLASH_FOREVERWARRIOR1` register read-only chat commands; their M9 integration is **NOT TESTED IN GAME**. Reference: https://warcraft.wiki.gg/wiki/Creating_a_slash_command .
- **Not used:** talent tree/trait APIs, gear/skill/loot APIs, combat-log events, automatic purchases, casting or protected operations. Community reports on beta interface 16001 indicate combat-log access may be unavailable: https://wowforeverguides.com/addons/api-cheatsheet . Treat this as an external beta report, not a blanket permanent guarantee.
- October 1, 2026 beta reports describe changed Warrior talent positions: https://us.forums.blizzard.com/en/wow/t/bug-warrior-talent-tree-has-been-completely-messed-up-in-oct-1sts-patch/2369273 . Avoid encoding an unverified fixed talent path into player guidance.

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

## Suite candidate APIs (2026-10-10; **NOT YET LIVE VERIFIED**)

| Pack | API | Source / specific limits |
| --- | --- | --- |
| Dashboard | CreateFrame, UIParent, CreateFontString, CreateTexture | Conventional WoW UI frame APIs; on-demand only, no protected actions |
| Inventory | C_Container.GetContainerNumSlots, C_Container.GetContainerItemInfo | https://warcraft.wiki.gg/wiki/API:C_Container.GetContainerItemInfo ; only bags 0–4, nil is unknown |
| Gold | GetMoney | Read-only current player copper; no claim of profit/market price |
| Professions | GetProfessions, GetProfessionInfo | Conventional UI profession functions, must be game-tested for Forever beta |
| Fishing/Cooking | C_TradeSkillUI.GetBaseProfessionInfo | https://warcraft.wiki.gg/wiki/API:C_TradeSkillUI.GetBaseProfessionInfo ; available when the corresponding skill UI is displayed; absence not proof of unlearned |
| Explorer | C_Map.GetBestMapForUnit, C_Map.GetMapInfo | https://warcraft.wiki.gg/wiki/API:C_Map.GetBestMapForUnit ; returns lowest UI map, not zone completion |
| Guild | C_ChatInfo.RegisterAddonMessagePrefix, C_ChatInfo.SendAddonMessage, CHAT_MSG_ADDON | https://warcraft.wiki.gg/wiki/API_C_ChatInfo.RegisterAddonMessagePrefix and https://warcraft.wiki.gg/wiki/API:C_ChatInfo.SendAddonMessage ; prefix <=16 bytes, payload <=255 bytes; messages throttled, sending accepted doesn't prove delivery |
| Core Profiles | SavedVariablesPerCharacter | Experimental Forever beta retention; user cold-restart test required |

These are source-reviewed API candidates, not assertions that a particular WoW beta build safely supports them. Any real-client failures must be documented against the exact full build before advertising features to others.

## ForeverPerformance 0.1.0: memory attribution APIs (2026-10-10)

- `UpdateAddOnMemoryUsage()`: manually requests a refresh of WoW's per-addon memory attribution, used exactly once per on-demand `/fperf` reading. Reference: https://warcraft.wiki.gg/wiki/API_UpdateAddOnMemoryUsage .
- `GetAddOnMemoryUsage(addonName)`: returns attributed addon memory in **kilobytes**; code uses named addon folders, as observed working in the player's earlier direct `/run` test. Reference: https://warcraft.wiki.gg/wiki/API_GetAddOnMemoryUsage .
- **Observed player evidence:** WoW Forever beta interface `16001`, October 10 2026, with `type()` confirming both functions; three named addon readings, plus Dashboard measurements 11.32 → 140.982421875 → 150.068359375 → 31.8955078125 KB following user-initiated `collectgarbage("collect")`. Full numeric build **not recorded** and no new ForeverPerformance code running at that time.
- **Safety:** Both API calls are checked with `type()`/`pcall()`. Missing/negative/nonfinite readings are errors, not values to quietly total as zero. The pack never triggers `collectgarbage` or runs polling. It only includes known Core-registered Forever addons, including logically disabled packages that are still loaded; it does not claim to enumerate every WoW addon or system RAM.
- **NOT YET VERIFIED:** New module's actual beta load, timing impact, addon memory attribution against installed packs, repeated runs, session baseline and delta. Run `docs/PERFORMANCE_TESTING.md`, recording client build and observed outputs. CPU profiling API support **not established**, so no fabricated CPU metrics.
