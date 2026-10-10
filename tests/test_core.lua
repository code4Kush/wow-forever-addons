--[[
    Deterministic Lua 5.1 test harness for ForeverCore.
    WoW API, event frame and optional addon loaders are mocked.
    Execute from repository root: lua5.1 tests/test_core.lua
    These results are not evidence of live Forever client compatibility.
]]

local originalPrint = print
local output = {}
print = function(message) output[#output + 1] = tostring(message) end

local function Expect(value, description)
    assert(value, description)
end

local function ExpectOutput(fragment)
    Expect(table.concat(output, "\n"):find(fragment, 1, true),
        "Missing output: " .. fragment)
end

local function ClearOutput()
    output = {}
end

local frame = { registeredEvents = {} }

function frame:RegisterEvent(event)
    if event == "INVALID_TEST_EVENT" then
        error("unsupported game event")
    end
    self.registeredEvents[event] = true
end

function frame:UnregisterEvent(event)
    self.registeredEvents[event] = nil
end

function frame:SetScript(script, callback)
    Expect(script == "OnEvent", "Core must install only OnEvent handler")
    self.onEvent = callback
end

function frame:Fire(event, ...)
    Expect(self.registeredEvents[event],
        "An event must not be delivered after final unsubscription: " .. event)
    self.onEvent(self, event, ...)
end

CreateFrame = function(frameType)
    Expect(frameType == "Frame", "Core must create a basic event Frame")
    return frame
end

UnitName = function(unit) Expect(unit == "player"); return "Uddergrief" end
UnitClass = function(unit) Expect(unit == "player"); return "Warrior", "WARRIOR" end
UnitRace = function(unit) Expect(unit == "player"); return "Tauren", "Tauren" end
UnitLevel = function(unit) Expect(unit == "player"); return 4 end
UnitGUID = function(unit) Expect(unit == "player"); return "Player-1-TEST" end
GetRealmName = function() return "ExampleRealm" end
SlashCmdList = {}

local core = {}

local function LoadLua(path, addonName, namespace)
    local chunk = assert(loadfile(path))
    chunk(addonName, namespace)
end

local function LoadCore(fileName)
    LoadLua("addons/ForeverCore/" .. fileName, "ForeverCore", core)
end

LoadCore("Bootstrap.lua")
LoadCore("Character.lua")
LoadCore("Registry.lua")
LoadCore("Events.lua")
LoadCore("Commands.lua")

Expect(_G.ForeverCore == core, "Core must export one shared namespace")
Expect(frame.registeredEvents.PLAYER_LOGIN,
    "The event bridge must register PLAYER_LOGIN")

ClearOutput()
SlashCmdList.FOREVERCORE("version")
ExpectOutput("Version 0.1.0")

ClearOutput()
SlashCmdList.FOREVERCORE("modules")
ExpectOutput("0 registered module(s).")

-- Two deliberately independent add-on packages. Each registers itself.
LoadLua("test-addons/ForeverProbeGeneral/Probe.lua", "ForeverProbeGeneral", {})
LoadLua("test-addons/ForeverProbeWarrior/Probe.lua", "ForeverProbeWarrior", {})

Expect(#core.ListModules() == 2, "Both fixture packages registered")
Expect(core.GetModuleStatus("probe-general").state == "registered",
    "Module must not start before PLAYER_LOGIN")
Expect(core.GetSubscriberCount("PLAYER_LEVEL_UP") == 0,
    "No module events should register before player identity is available")

frame:Fire("PLAYER_LOGIN")

local identity = core.GetCharacter()
Expect(identity.name == "Uddergrief" and identity.classToken == "WARRIOR",
    "Live class and name must populate after login")
identity.name = "Changed"
Expect(core.GetCharacter().name == "Uddergrief",
    "Character copy must not mutate stored identity")
Expect(core.GetModuleStatus("probe-general").state == "active",
    "General module must activate after login")
Expect(core.GetModuleStatus("probe-warrior").state == "active",
    "Warrior module must activate for a Warrior")
Expect(core.GetSubscriberCount("PLAYER_LEVEL_UP") == 2,
    "Two active modules must be subscribed")
Expect(frame.registeredEvents.PLAYER_LEVEL_UP,
    "The shared frame must register module events")
frame:Fire("PLAYER_LEVEL_UP", 5)

local copiedStatus = core.GetModuleStatus("probe-general")
copiedStatus.capabilities[1] = "modified"
Expect(core.GetModuleStatus("probe-general").capabilities[1] == "probe.general",
    "Capability metadata returned to consumers must be copied")

ClearOutput()
SlashCmdList.FOREVERCORE("modules")
ExpectOutput("2 registered module(s).")
ExpectOutput("probe-general v0.1.0: active [probe.general]")
ExpectOutput("probe-warrior v0.1.0: active [probe.warrior]")

ClearOutput()
SlashCmdList.FOREVERCORE("character")
ExpectOutput("Uddergrief - ExampleRealm - Tauren Warrior - level 4")

ClearOutput()
SlashCmdList.FOREVERCORE("listeners PLAYER_LEVEL_UP")
ExpectOutput("PLAYER_LEVEL_UP: 2 active listener(s).")

ClearOutput()
SlashCmdList.FOREVERCORE("disable probe-warrior")
ExpectOutput("probe-warrior: disabled (session only).")
Expect(core.GetModuleStatus("probe-warrior").state == "disabled",
    "Warrior probe must be disabled")
Expect(core.GetSubscriberCount("PLAYER_LEVEL_UP") == 1,
    "Disabling one pack must retain other subscribers")
frame:Fire("PLAYER_LEVEL_UP", 6)

ClearOutput()
SlashCmdList.FOREVERCORE("disable probe-general")
ExpectOutput("probe-general: disabled (session only).")
Expect(core.GetSubscriberCount("PLAYER_LEVEL_UP") == 0,
    "Disabling last pack must remove event subscribers")
Expect(not frame.registeredEvents.PLAYER_LEVEL_UP,
    "The shared frame must unregister when no listeners remain")

ClearOutput()
SlashCmdList.FOREVERCORE("enable probe-general")
ExpectOutput("probe-general: enable requested (session only).")
Expect(core.GetModuleStatus("probe-general").state == "active",
    "Session re-enable must reactivate the module")
Expect(core.GetSubscriberCount("PLAYER_LEVEL_UP") == 1,
    "Re-enabled module receives its subscriptions")

local providers = core.FindCapabilityProviders("probe.general")
Expect(#providers == 1 and providers[1] == "probe-general",
    "Only active providers should be returned")
Expect(#core.FindCapabilityProviders("probe.warrior") == 0,
    "Disabled providers must not be advertised as active")

local function FakeDescriptor(id, overrides)
    local descriptor = {
        id = id,
        displayName = "Test " .. id,
        version = "1.0.0",
        minCoreVersion = "0.1.0",
        capabilities = {},
        events = {},
        Initialize = function() end,
        Enable = function() end,
        Disable = function() end,
    }

    for key, value in pairs(overrides or {}) do
        descriptor[key] = value
    end
    return descriptor
end

local accepted, errorMessage = core.RegisterModule(FakeDescriptor("probe-general"))
Expect(not accepted and errorMessage:find("already"),
    "Duplicate module IDs must be rejected")
accepted, errorMessage = core.RegisterModule(FakeDescriptor("Invalid ID"))
Expect(not accepted and errorMessage:find("lowercase"),
    "Invalid IDs must be rejected")
accepted, errorMessage = core.RegisterModule(
    FakeDescriptor("malformed", { version = "not-semver" })
)
Expect(not accepted and errorMessage:find("major.minor.patch"),
    "Non-numeric semantic versions must be rejected")

accepted, errorMessage = core.RegisterModule(FakeDescriptor("reserved", {
    events = { "PLAYER_LOGIN" },
    OnEvent = function() end,
}))
Expect(not accepted and errorMessage:find("reserved"),
    "Module must not subscribe to Core's own PLAYER_LOGIN lifecycle event")

accepted = core.RegisterModule(FakeDescriptor("too-new", {
    minCoreVersion = "2.0.0",
}))
Expect(accepted, "Incompatible packs must be registered for diagnostics")
local incompatible = core.GetModuleStatus("too-new")
Expect(incompatible.state == "incompatible" and not incompatible.active,
    "Incompatible packs must not be started")

accepted = core.RegisterModule(FakeDescriptor("mage-only", {
    IsEligible = function(self, character)
        return character.classToken == "MAGE", "Mage only"
    end,
}))
Expect(accepted, "Ineligible pack can register")
Expect(core.GetModuleStatus("mage-only").state == "ineligible",
    "Class eligibility must be checked using runtime class token")

-- Changes to the caller's metadata arrays must not silently change
-- subscriptions after the module has registered.
local callerEvents = { "PLAYER_LEVEL_UP" }
local snapshotDescriptor = FakeDescriptor("snapshot", {
    events = callerEvents,
    OnEvent = function() end,
})
accepted = core.RegisterModule(snapshotDescriptor)
Expect(accepted, "Snapshot test module registers")
callerEvents[1] = "SOME_OTHER_EVENT"
core.SetModuleEnabled("snapshot", false)
Expect(core.GetSubscriberCount("SOME_OTHER_EVENT") == 0,
    "Registry must not use externally mutated event arrays")

local spy = { handled = 0, disabled = 0 }
accepted = core.RegisterModule(FakeDescriptor("spy", {
    events = { "PLAYER_LEVEL_UP" },
    OnEvent = function() spy.handled = spy.handled + 1 end,
    Disable = function() spy.disabled = spy.disabled + 1 end,
}))
Expect(accepted, "Late-loaded module should register")
Expect(core.GetModuleStatus("spy").state == "active",
    "Modules registering after login should activate immediately")
frame:Fire("PLAYER_LEVEL_UP", 7)
Expect(spy.handled == 1, "Active module must receive actual game events")
core.SetModuleEnabled("spy", false)
Expect(spy.disabled == 1, "Disable callback must run exactly once")
frame:Fire("PLAYER_LEVEL_UP", 8)
Expect(spy.handled == 1, "Disabled module must not receive events")

local broken = FakeDescriptor("broken", {
    events = { "PLAYER_LEVEL_UP" },
    OnEvent = function() error("controlled test error") end,
})
accepted = core.RegisterModule(broken)
Expect(accepted, "Broken module should register for error isolation")
frame:Fire("PLAYER_LEVEL_UP", 9)
Expect(core.GetModuleStatus("broken").state == "error",
    "Event callback exception must mark module as errored")
Expect(not core.GetModuleStatus("broken").active,
    "Errored module should be removed from event delivery")

-- An invalid WoW event must not crash the shared Core event bridge.
-- The earlier PLAYER_LEVEL_UP subscription is rolled back for this module.
local listenerCountBefore = core.GetSubscriberCount("PLAYER_LEVEL_UP")
accepted = core.RegisterModule(FakeDescriptor("bad-event", {
    events = { "PLAYER_LEVEL_UP", "INVALID_TEST_EVENT" },
    OnEvent = function() end,
}))
Expect(accepted, "Invalid-event module registers for diagnostics")
Expect(core.GetModuleStatus("bad-event").state == "error",
    "Invalid WoW event registration should mark only that module as errored")
Expect(core.GetSubscriberCount("PLAYER_LEVEL_UP") == listenerCountBefore,
    "Failed event registration must not leave an orphan subscription")
Expect(core.GetModuleStatus("probe-general").state == "active",
    "A healthy pack must remain active despite another pack's bad event")

ClearOutput()
SlashCmdList.FOREVERCORE("status absent-pack")
ExpectOutput("Module is not registered (possibly not installed).")
ClearOutput()
SlashCmdList.FOREVERCORE("listeners invalid")
ExpectOutput("Usage: /forever listeners <EVENT>")

print = originalPrint
print("Forever Core registry, lifecycle, character and module tests passed.")
