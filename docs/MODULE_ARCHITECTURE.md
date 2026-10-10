# Modular addon architecture (proposal; not yet implemented)

Version 1 design proposal — 2026-10-10. This document specifies an implementation target, not a claim that the current repository has these features.

## Physical packaging

~~~text
addons/
  ForeverCore/         # Required by all feature packs. No feature tabs.
  ForeverDashboard/    # Optional: renders tabs from the registry.
  ForeverJournal/      # Optional: active/history/curated checklists.
  ForeverInventory/    # Optional: bag + gear presentation.
  ForeverGold/         # Optional: wallet/session ledger.
  ForeverProfessions/  # Optional: skill and recipes.
  ForeverFishing/      # Optional: fish/catch journal.
  ForeverCooking/      # Optional: recipe/ingredient plans.
  ForeverWarrior/      # Optional: out-of-combat tank preparation.
  ForeverExplorer/     # Optional: discoveries and user checklists.
~~~

One Git repository; **separate TOC and Lua files for every installed addon**; TOC dependencies resolved by supported WoW addon loader behavior (verify flavor and dependency declaration on Forever's actual build). Shared source belongs in Core. Do not rely on ordinary Lua 'require' or the OS file/network APIs inside the game. Do not copy the entire core into every pack.

Existing ForeverJournal v0.1–v0.4 is a single-addon architecture. Do not remove its working slash commands or relocate saved data until an explicit compatibility migration has been tested.

## Two distinct enablement layers

1. **Installed / game enabled:** WoW discovers a pack folder and decides whether its Lua files load (game addon manager; per-character behavior subject to current beta verification). An absent or game-disabled package cannot be activated from our settings without following supported loader semantics.
2. **Profile enabled:** If the Lua pack is loaded, the Core registry may mark it active/inactive for the current character. Turning it off *must stop its event registrations, updates and views*. Lua bytecode already loaded cannot be "unloaded" at runtime. Addon-manager changes may need a reload.

All displayed statuses should be distinguishable: not installed; game disabled/unavailable; incompatible; class-ineligible; profile disabled; running; degraded because an API is missing. If Core cannot discover an unloaded pack via supported APIs, report that accurately rather than inventing an installed status.

## Module contract

**This is a proposed API, not implemented Lua code.** Every optional package registers a descriptor using the addon namespace and a small versioned Core API:

~~~text
moduleId          stable machine key (e.g., "warrior")
displayName       player-facing name
moduleVersion     semantic version
minCoreVersion    minimum compatible core version
capabilities      provided read-only capabilities (e.g. "inventory.snapshot")
optionalRequires  absent providers must not crash the module
IsEligible(ctx)   use verified class/race/profession requirements
Initialize(ctx)   allocate only non-active state
Enable(ctx)       register active events/render controls
Disable()         unregister active events/render controls and cancel timers
GetStatus()       healthy / unavailable / degraded, with reason
~~~

Rules:
- Initialize only after PLAYER_LOGIN or another verified safe lifecycle; do not assume character identity exists at file evaluation time.
- Capability calls have explicit typed return values with unavailable/error states.
- No global name collisions, hidden cross-pack require dependencies or circular imports.
- When the player disables a module, Core calls Disable even if the game still has the source loaded.
- Core owns the single event subscription registry (or documented per-pack handles), with unsubscribe logic and bounded update costs. Favor event-driven refresh while visible; throttle bursts; no per-frame quest scanning.
- No module should perform prohibited gameplay automation, protected actions, secret-value analysis or unsanctioned external communication.

## Character identity and settings

**Target separation:**
- Account-level defaults: explicitly chosen global preferences; never silently aggregate character activity.
- Character profile: enabled pack IDs, UI settings, favorites and per-character notes.
- Transient session state: current open panes, session gold delta or a per-session catch tally.
- Historical game state: read from game APIs when available, *not* invented from active-log disappearance.

Proposed TOC declarations to validate before relying on them:
~~~text
## SavedVariables: ForeverAccountDB
## SavedVariablesPerCharacter: ForeverCharacterDB
~~~

Preference schema uses a version number and migration functions. Prefer per-character saved variable scope when the client honors it rather than keying all characters by display name. If a shared account structure needs an identity key, use a stable client-provided ID only after testing its availability; do not assume names are globally unique. Character swaps and a test character with the same displayed name on a different realm must not share preferences.

A preset is editable configuration, not gameplay class automation. Core may **suggest** a Warrior profile for characters with class token WARRIOR; it must not force settings onto the player. All class-specific feature eligibility must be checked at run time, not by matching "Uddergrief".

**Critical beta gate:** If SavedVariables fail to persist after a full client exit/restart, report 'session-only' and avoid lifetime histories or false promises. Test both reload and *full restart* with a unique sentinel value; document client build and actual outcomes before enabling migrations.

## Pack dependency and eligibility matrix

| Pack | Hard dependency | Optional provider | Special eligibility |
| --- | --- | --- | --- |
| Dashboard | Core | Any registered pack | None |
| Journal | Core | Dashboard for UI | Catalog may be race/class restricted; journal itself generic |
| Inventory | Core | Dashboard | None |
| Gold | Core | Inventory read-only snapshot | None |
| Professions | Core | Inventory | Learned skill requirements data may be unavailable |
| Fishing | Core | Inventory, Professions, Cooking | Fishing skill/event support verified per build |
| Cooking | Core | Inventory, Professions, Fishing | Cooking skill/recipes verified per build |
| Warrior | Core | Inventory | Verified WARRIOR class token |
| Explorer | Core | Journal, Dashboard | Map/exploration APIs vary |

**UI rule:** a pack must still expose its slash/read-only functionality without Dashboard installed, whenever meaningful.

## Example profile intent — not shipped configuration

~~~text
character: Uddergrief (name from UnitName; race/class validated at runtime)
presetChoice: tank-completionist
enabled:
  journal: true
  inventory: true
  gold: true
  warrior: true
  dashboard: true
  professions: false
  fishing: false
  cooking: false
  explorer: false
~~~

The actual stored format may differ once we have a verified migration-safe settings schema.

## Migration in layers

1. Build Core in a separate folder and test Core-only game load.
2. Build two tiny mock packs to prove version contracts, independent installation, class eligibility and disable semantics.
3. Introduce read-only character profiles, test persistence, then optional dashboard.
4. Wrap existing Journal behavior behind the contract without changing /fj outputs; preserve old command compatibility.
5. Bring in other feature packs one at a time, independently.
6. Keep release packaging and implementation small. No empty modules or premature generic framework beyond demonstrated needs.
