--[[
    Forever Warrior standalone Lua 5.1 test harness.

    Simulates a read-only ForeverCore API and game character level queries.
    Does NOT prove that the WoW Forever live client loads this package.
    From repository root: lua5.1 tests/test_warrior.lua
]]

local originalPrint = print
local output = {}

print = function(message)
    output[#output + 1] = tostring(message)
end

local function Expect(condition, description)
    assert(condition, description)
end

local function ClearOutput()
    output = {}
end

local function ExpectOutput(fragment)
    Expect(table.concat(output, "\n"):find(fragment, 1, true) ~= nil,
        "Expected output fragment: " .. fragment)
end

local player = {
    name = "Uddergrief",
    classToken = "WARRIOR",
    level = 4,
}
local liveLevel = 4
local moduleDefinition
local moduleState = "active"

UnitLevel = function(unit)
    Expect(unit == "player", "Only the player's level can be inspected")
    return liveLevel
end

SlashCmdList = {}

ForeverCore = {
    RegisterModule = function(descriptor)
        moduleDefinition = descriptor
        return true
    end,
    GetModuleStatus = function(id)
        Expect(id == "forever-warrior", "Correct module id is required")
        return { state = moduleState,
            reason = moduleState == "disabled" and "session only"
                or moduleState == "ineligible" and "Warrior only" or nil }
    end,
    GetCharacter = function()
        return player
    end,
}

local addon = {}
local function Load(fileName)
    local chunk = assert(loadfile("addons/ForeverWarrior/" .. fileName))
    chunk("ForeverWarrior", addon)
end

Load("Bootstrap.lua")
Load("Plans.lua")
Load("Module.lua")
Load("Commands.lua")

Expect(moduleDefinition.id == "forever-warrior",
    "Pack must register with the independent Core")
Expect(moduleDefinition.minCoreVersion == "0.1.0",
    "Pack must declare the required Core API version")
Expect(#moduleDefinition.events == 0,
    "Starter must not register game events or combat hooks")
Expect(moduleDefinition.IsEligible(moduleDefinition, player) == true,
    "A Warrior should be eligible")
Expect(moduleDefinition.IsEligible(moduleDefinition, { classToken = "PRIEST" }) == false,
    "A non-Warrior should not be eligible")
Expect(moduleDefinition.IsEligible(moduleDefinition, nil) == false,
    "Unavailable character must not be eligible")
Expect(addon.Plans.ForLevel(nil) == nil and addon.Plans.ForLevel(0) == nil,
    "Unknown or invalid character levels must not produce advice")
Expect(addon.Plans.ForLevel(4).minimum == 1,
    "Level 4 uses Mulgore starter plan")
Expect(addon.Plans.ForLevel(10).minimum == 10,
    "Level 10 receives new talent milestone")
Expect(addon.Plans.ForLevel(60).minimum == 60,
    "Level 60 receives raid progression guidance")
Expect(#addon.Plans.ManualReadiness() == 5,
    "Readiness contains exactly five manual reminders")

ClearOutput()
SlashCmdList.FOREVERWARRIOR("plan")
ExpectOutput("Uddergrief level 4: Mulgore foundations (1-9)")
ExpectOutput("Combat: Practice controlled pulls")
ExpectOutput("Dungeon: Plan your first Ragefire Chasm run")
ExpectOutput("Next: Reach level 10")

-- Live level is refreshed on demand rather than frozen at Core login time.
liveLevel = 10
ClearOutput()
SlashCmdList.FOREVERWARRIOR("plan")
ExpectOutput("Uddergrief level 10: Early Protection training (10-12)")

ClearOutput()
SlashCmdList.FOREVERWARRIOR("ready")
ExpectOutput("MANUAL; not checked by addon")
ExpectOutput("[ ] Equip a one-handed weapon and shield")
ExpectOutput("[ ] Check healer mana")
Expect(not table.concat(output, "\n"):find("[x]", 1, true),
    "Readiness items must not be marked completed automatically")

ClearOutput()
SlashCmdList.FOREVERWARRIOR("professions")
ExpectOutput("Primary: Mining + Blacksmithing")
ExpectOutput("Secondary: Fishing + Cooking + First Aid")
ExpectOutput("skills and bags are NOT scanned")

ClearOutput()
SlashCmdList.FOREVERWARRIOR("version")
ExpectOutput("Version 0.1.0 (advisory only)")

moduleState = "disabled"
ClearOutput()
SlashCmdList.FOREVERWARRIOR("plan")
ExpectOutput("Module disabled (session only)")
Expect(not table.concat(output, "\n"):find("Combat:", 1, true),
    "Disabled feature must not provide progression advice")

moduleState = "ineligible"
ClearOutput()
SlashCmdList.FOREVERWARRIOR("plan")
ExpectOutput("Module ineligible (Warrior only)")

moduleState = "active"
liveLevel = 4
ClearOutput()
SlashCmdList.FOREVERWARRIOR("help")
ExpectOutput("Commands: /fw plan")

ClearOutput()
SlashCmdList.FOREVERWARRIOR("plan extra")
ExpectOutput("Unexpected argument")

ClearOutput()
SlashCmdList.FOREVERWARRIOR("unknown")
ExpectOutput("Unknown command")

-- If no live level API exists, Core's login snapshot supplies fallback data.
UnitLevel = nil
ClearOutput()
SlashCmdList.FOREVERWARRIOR("plan")
ExpectOutput("Uddergrief level 4: Mulgore foundations (1-9)")

print = originalPrint
print("Forever Warrior class gating, level plans and slash-command tests passed.")
