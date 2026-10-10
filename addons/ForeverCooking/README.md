# ForeverCooking — 0.1.0 candidate

**State:** NEW AND NOT YET TESTED IN THE REAL FOREVER CLIENT. This is a free, independent, unendorsed community WoW addon candidate.

## What it does

open Cooking profession skill readout; not recipe or ingredient scans. The code runs only after the player invokes a command, except the small Core-managed event registration lifecycle. It never casts spells, equips items, crafts, sells, plays the game, or transmits data externally.

**Depends on:** ForeverCore **0.2.0 or later**. No other optional packs required. Only an installed and active pack responds.

## Install or uninstall

Copy the entire `addons/ForeverCooking/` folder to WoW Forever's `Interface/AddOns/ForeverCooking/` directory while the client is closed, along with the required `addons/ForeverCore/` package. Enable the addon in WoW's AddOns interface, then reload. To uninstall, quit WoW and remove only this addon directory. The Core should remain installed for other packs.

The `## Interface: 16001` and `_Camelot.toc` suffix are based on previously observed beta behavior; **full current game-build verification remains pending**.

## Command (one chat submission)

```text
/fcook
```

Expected exact/dynamic output and explicit PASS/FAIL rules are in [SUITE_TESTING.md](../../docs/SUITE_TESTING.md). Enter each WoW command independently.

To change this pack's per-character preference (example only, replace `<module-id>` with the identifier documented in the Core module list), use `/forever pref <module-id> off` or `on`. **SavedVariables reliability is not established** until testing after a complete game quit and restart.

## Game API and limitations

C_TradeSkillUI.GetBaseProfessionInfo; often needs profession window open. Calls are guarded and return an explicit unavailable message if needed. Mock tests do not demonstrate real-client compatibility. See [API_NOTES.md](../../docs/API_NOTES.md).

## Privacy and licensing

No third-party SDKs or telemetry included. No separate license has yet been chosen for the public repository, and no packaged player release has been approved. See the project root [README](../../README.md) and security policy PR #20.
