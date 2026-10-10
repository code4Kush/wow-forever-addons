# ForeverCore 0.1.0 public module contract

**Scope:** implementation candidate for M1 ([issue #6](https://github.com/code4Kush/wow-forever-addons/issues/6)). The client must confirm this code loads and behaves correctly before it is labeled game-verified. The M2 profile and SavedVariables work is **not** part of this contract.

## Core as an independent WoW addon

Directory: `addons/ForeverCore/`, manifest `ForeverCore_Camelot.toc`, interface 16001. Every feature pack has its own TOC folder and uses `## Dependencies: ForeverCore` (behavior must be validated on the installed Forever client). A single public global `ForeverCore` is exported by Core; no `require`, HTTP, OS filesystem or game-memory access.

**Important migration fact:** Existing `ForeverJournal` has NOT yet been converted to use Core; both can co-exist. The separate test packages are only for M1 validation. No existing `/fj` commands are changed.

## Stable registration descriptor

Each pack registers one descriptor **after Core has loaded**:

~~~lua
local definition = {
    id = "my-pack",
    displayName = "My Pack",
    version = "1.0.0",
    minCoreVersion = "0.1.0",
    capabilities = { "my-pack.read" },
    optionalRequires = { "inventory.snapshot" },
    events = { "PLAYER_LEVEL_UP" },

    -- Called only after PLAYER_LOGIN and only once per game session.
    Initialize = function(self, character) end,

    -- Called once when logical session activation occurs.
    Enable = function(self, character) end,

    -- Called after Core unsubscribes this module from events.
    Disable = function(self) end,

    -- Optional; if false, module is registered but marked ineligible.
    IsEligible = function(self, character)
        return character.classToken == "WARRIOR", "Warrior only"
    end,

    -- Required when the events array is not empty.
    OnEvent = function(self, eventName, ...) end,

    -- Optional: return "degraded" or "unavailable", reason.
    GetStatus = function(self) return "healthy" end,
}

local accepted, errorMessage = ForeverCore.RegisterModule(definition)
~~~

- `id` is lowercase letters, numbers and hyphens; unique within the active session.
- `version` and `minCoreVersion` require numeric `major.minor.patch` components.
- Modules requiring a future Core are registered for diagnostics but not started.
- Core snapshots descriptor metadata arrays when registering. Feature packs must not change declared events after registration; re-register with a versioned change instead.
- `PLAYER_LOGIN` is a reserved Core lifecycle event and cannot be listed by feature packs.
- Capabilities and optional requirements are descriptive metadata; missing optional providers do not stop a module from starting. `FindCapabilityProviders(name)` lists only active providers.
- Callback errors are isolated. A failed event handler deactivates the affected module and unsubscribes its events rather than allowing repeated errors.
- `GetStatus` can report an active module as degraded/unavailable without unloading it. A module must not attempt to treat this as permission to bypass game APIs.
- The live `character` context contains `name`, `realm`, `className`, `classToken`, `raceName`, `raceToken`, `level` and `guid` when exposed. Missing fields are nil or clearly labeled unknown.
- `GetCharacter()` and `GetModuleStatus(id)` return snapshots. Don't mutate module descriptors from other packs.

## Core API

| Function | Meaning |
| --- | --- |
| `RegisterModule(descriptor)` | Validate and register, returning `true` or `false, reason` |
| `GetCharacter()` | Character identity snapshot or nil before login |
| `ListModules()` | Sorted snapshot of successfully registered descriptors |
| `GetModuleStatus(id)` | One module snapshot or nil if it wasn't registered |
| `SetModuleEnabled(id, boolean)` | Logical session-only enable/disable, not a WoW addon-manager action |
| `FindCapabilityProviders(name)` | Active provider module IDs for a capability |
| `GetSubscriberCount(event)` | Diagnostic count for active subscribers (Core's PLAYER_LOGIN isn't counted) |

`AttachEventFrame`, `DispatchEvent`, `StartForCharacter`, `ReadCharacter` are internal integration methods for Core's own files; optional packs should not call them.

## Lifecycle and event safety

1. WoW loads Core, then packages declaring its dependency.
2. Modules register but do not initialize before PLAYER_LOGIN.
3. On PLAYER_LOGIN Core creates a runtime character snapshot, evaluates Core version and `IsEligible`, and calls `Initialize` once, `Enable` once; it registers declared events using one shared frame.
4. `SetModuleEnabled(id,false)`: unsubscribes before calling `Disable`; other modules remain active.
5. `SetModuleEnabled(id,true)`: rechecks eligibility and reactivates without repeating `Initialize`.
6. A module registering after PLAYER_LOGIN is started immediately if eligible.
7. If the game's addon-manager disables a package, its Lua never registers and the Core registry cannot reliably distinguish why; it will not claim the package exists.

Callbacks should not register their own high-frequency frame events. When a feature needs events, list them in `events` and process via Core's `OnEvent`.

### Session state and future migration

The initial requestedEnabled flag defaults to true **for each newly registered pack**. Future M2 settings will be account/character-scoped and schema-versioned after a full client quit/restart test. M1 does not persist anything, including toggles. Never promise lifetime catch/inventory histories based on this version.

### Security scope

No automated combat, item selling, quest acceptance, mail, protected actions, scanning secret values, external network transmission or unauthorized client interaction. All in-game behavior is on-demand diagnostics or bounded event dispatch.

### Known limitations

The API is version 0.1.0 and not yet proven on this WoW: Forever build. No support for dependency cycles, dynamic Lua unloading or automatic discovery of installed-but-disabled addons. The optional `GetStatus` health hook is informational; it doesn't stop update callbacks itself. If a module requests an event that the client rejects, Core reports an event registration error for that module and reverts its partial subscriptions. Feature authors must still use documented real events and verify them on the target client.
