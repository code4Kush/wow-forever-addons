--[[
    ForeverProfessions v0.2: Lua 5.1 mocks for on-demand skill snapshots.
    All client functions are simulated; CI is NOT live beta verification.
]]
local originalPrint = print
local lines = {}
print = function(text) lines[#lines + 1] = tostring(text) end
local function reset() lines = {} end
local function has(s) return table.concat(lines,"\n"):find(s,1,true) ~= nil end
local function check(value,reason) assert(value,reason) end

SlashCmdList = {}
local descriptor
local active = true
ForeverCore = {
    RegisterModule = function(value) descriptor = value; return true end,
    GetModuleStatus = function(id)
        check(id == "professions", "Expected module ID")
        return {state = active and "active" or "disabled"}
    end,
}

local slotCalls = 0
local infoCalls = 0
local slots = {1,2,3,4}
local values = {
    [1] = {"Mining",30,75},
    [2] = {"Blacksmithing",20,75},
    [3] = {"Fishing",40,75},
    [4] = {"Cooking",22,75},
}
GetProfessions = function()
    slotCalls = slotCalls + 1
    return unpack(slots,1,5)
end
GetProfessionInfo = function(index)
    infoCalls = infoCalls + 1
    local data = values[index]
    if data then return data[1],nil,data[2],data[3] end
end
InCombatLockdown = function() return false end

local addon = {}
for _, filename in ipairs({
    "Bootstrap.lua","Module.lua","Read.lua","Tracker.lua","Commands.lua"
}) do
    assert(loadfile("addons/ForeverProfessions/"..filename))(
        "ForeverProfessions",addon)
end
check(descriptor.id == "professions", "Registered module")
check(descriptor.minCoreVersion == "0.2.0", "Minimum Core")
check(#descriptor.events == 0 and #descriptor.capabilities == 2,
    "No automatic listeners and explicit new capability")
check(slotCalls == 0 and infoCalls == 0, "Never sample on load")

reset(); SlashCmdList.FOREVERPROFESSIONS("version")
check(has("Version 0.2.0"), "Version")
reset(); SlashCmdList.FOREVERPROFESSIONS("help")
check(has("snapshot | progress | clear"), "Help")
check(slotCalls == 0, "No reads on help/version")

reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("No snapshot. Use /fprof snapshot first."), "Missing baseline")
check(slotCalls == 0, "No API calls when baseline absent")

reset(); SlashCmdList.FOREVERPROFESSIONS("")
check(has("Known professions: Mining 30/75; Blacksmithing 20/75; Fishing 40/75; Cooking 22/75"),
    "Legacy readout unchanged")
check(slotCalls == 1 and infoCalls == 4, "Only bounded manual read")

reset(); SlashCmdList.FOREVERPROFESSIONS("snapshot")
check(has("Snapshot saved: 4 readable profession(s) (session only)."),
    "Manual snapshot")
check(slotCalls == 2 and infoCalls == 8, "Snapshot calls APIs once")

reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("Skill progress: 4 comparable; 0 changed (session only)."),
    "Unchanged skills")
check(has("Fishing: +0 skill (was 40; now 40)."), "Signed zero")
check(slotCalls == 3 and infoCalls == 12, "Only one progress sample")

values[1][2], values[2][2], values[3][2] = 34,18,43
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("Skill progress: 4 comparable; 3 changed"), "Change count")
check(has("Mining: +4 skill (was 30; now 34)."), "Increase")
check(has("Blacksmithing: -2 skill (was 20; now 18)."), "Decrease")
check(has("Fishing: +3 skill (was 40; now 43)."), "Fishing skill")

slots = {nil,nil,3,4}
reset(); SlashCmdList.FOREVERPROFESSIONS("")
check(has("Fishing 43/75; Cooking 22/75"), "Sparse primary slots")
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("Mining: not readable now; change unknown.")
    and has("Blacksmithing: not readable now; change unknown."),
    "Missing skills must not be falsely marked untrained")

slots = {1,2,3,5}
values[5] = {"Skinning",15,75}
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("Skinning: newly readable at 15; no starting comparison."),
    "Newly readable is not gained from zero")
check(has("Cooking: not readable now; change unknown."),
    "Missing Cooking does not imply loss")
check(#lines <= 11, "Bounded output: 5 new and 5 missing plus summary")

for _, invalid in ipairs({-1,0/0,math.huge,10.5,"bad"}) do
    values[1][2] = invalid
    reset(); SlashCmdList.FOREVERPROFESSIONS("snapshot")
    check(has("Profession details unavailable."), "Unsafe skills rejected")
end
values[1][2] = 34

GetProfessions = nil
reset(); SlashCmdList.FOREVERPROFESSIONS("")
check(has("Profession API unavailable on this build."), "Missing client API")
GetProfessions = function()
    slotCalls = slotCalls + 1
    return unpack(slots,1,5)
end
GetProfessionInfo = function() error("unsupported API") end
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("Profession details unavailable."), "Error returned safely")
GetProfessionInfo = function(index)
    infoCalls = infoCalls + 1
    local data = values[index]
    if data then return data[1],nil,data[2],data[3] end
end
slots = {1,2,3,4}

reset(); SlashCmdList.FOREVERPROFESSIONS("snapshot")
check(has("Snapshot saved: 4 readable profession(s)"), "Valid resnapshot")
active = false
descriptor.Disable(descriptor)
local before = slotCalls
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("Module not active: disabled."), "Core disabled read blocked")
check(slotCalls == before, "Disabled module never samples")
active = true
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("No snapshot."), "Disable cleared snapshot")

reset(); SlashCmdList.FOREVERPROFESSIONS("snapshot")
before = slotCalls
reset(); SlashCmdList.FOREVERPROFESSIONS("clear")
check(has("Snapshot cleared (session only)."), "Explicit clear")
check(slotCalls == before, "Clear does not sample")
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
check(has("No snapshot."), "Clear removes snapshot")

InCombatLockdown = function() return true end
before = slotCalls
reset(); SlashCmdList.FOREVERPROFESSIONS("snapshot")
check(has("Profession readout unavailable during combat."),
    "Avoid protected calls in combat")
check(slotCalls == before, "Never read game data in combat")
InCombatLockdown = function() return false end

reset(); SlashCmdList.FOREVERPROFESSIONS("invalid")
check(has("Usage: /fprof"), "Unrecognized argument")
print = originalPrint
print("ForeverProfessions session snapshot/progress mock tests passed.")
