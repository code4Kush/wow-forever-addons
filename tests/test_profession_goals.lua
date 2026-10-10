--[[
    ForeverProfessions 0.3 manual goals: Lua 5.1 mocked acceptance.

    All WoW APIs are stand-ins. A mock PASS never proves that Fishing
    or Cooking can be read from a particular WoW Forever beta build.
]]
local originalPrint = print
local out = {}
print = function(value) out[#out+1] = tostring(value) end
local function reset() out = {} end
local function has(fragment)
    return table.concat(out, "\n"):find(fragment, 1, true) ~= nil
end
local function expect(cond, why) assert(cond, why) end

SlashCmdList = {}
local descriptor
local active = true
ForeverCore = {
    RegisterModule = function(record) descriptor = record; return true end,
    GetModuleStatus = function(id)
        expect(id == "professions", "Correct target module ID")
        return {state = active and "active" or "disabled"}
    end,
}
local slotCalls = 0
local detailCalls = 0
local slots = {1,2,3,4}
local skills = {
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
    detailCalls = detailCalls + 1
    local value = skills[index]
    if value then return value[1],nil,value[2],value[3] end
end
InCombatLockdown = function() return false end

local ns = {}
for _, path in ipairs({
    "Bootstrap.lua","Module.lua","Read.lua","Tracker.lua","Goals.lua","Commands.lua"
}) do
    assert(loadfile("addons/ForeverProfessions/"..path))(
        "ForeverProfessions",ns)
end
expect(ns.version == "0.3.0", "New goals version")
expect(descriptor.id == "professions" and #descriptor.events == 0
    and #descriptor.capabilities == 3, "Goal capability, no events")
expect(slotCalls == 0 and detailCalls == 0, "No implicit API read at load")

reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("No goals. Use /fprof goal <profession> <rank>."),
    "No fabricated goals before a target is set")
expect(slotCalls == 0, "No API call for empty list")

reset(); SlashCmdList.FOREVERPROFESSIONS("goal")
expect(has("Usage: /fprof goal <profession name> <target-rank>"),
    "Missing argument help")
expect(slotCalls == 0, "Missing argument never reads API")
reset(); SlashCmdList.FOREVERPROFESSIONS("goal Fishing 0")
expect(has("Usage: /fprof goal"), "Zero not accepted")
reset(); SlashCmdList.FOREVERPROFESSIONS("goal Fishing 999")
expect(has("Goal exceeds Fishing maximum (75)."),
    "Cannot set beyond reported skill maximum")
reset(); SlashCmdList.FOREVERPROFESSIONS("goal Herbalism 75")
expect(has("Profession not readable now: Herbalism."),
    "No fake unlearned or guessed skill levels")

reset(); SlashCmdList.FOREVERPROFESSIONS("goal fishing 75")
expect(has("Goal set: Fishing 75 (currently 40; 35 remaining; session only)."),
    "Case-insensitive goal set using actual skill name")
reset(); SlashCmdList.FOREVERPROFESSIONS("goal Cooking 75")
expect(has("Goal set: Cooking 75 (currently 22; 53 remaining; session only)."),
    "Independent secondary profession goal")
expect(ns.GoalCount() == 2, "Tracks two independent goals")

reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("Goals: 2 target(s) (session only)."), "Goal count")
expect(has("Fishing: 40/75; 35 remaining.") and
    has("Cooking: 22/75; 53 remaining."),
    "On-demand rank and remaining points")

skills[3][2] = 42
skills[4][2] = 75
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("Fishing: 42/75; 33 remaining."), "New progress read")
expect(has("Cooking: 75/75; reached."), "Reached target detected")

reset(); SlashCmdList.FOREVERPROFESSIONS("goal FISHING 50")
expect(has("Goal set: Fishing 50 (currently 42; 8 remaining; session only)."),
    "Updates goal without duplicating profession")
expect(ns.GoalCount() == 2, "Still two targets")

-- The skill can go missing without being labelled untrained / zero.
slots = {1,2,nil,4}
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("Fishing: unreadable now; target 50; remaining unknown."),
    "Missing skill not misreported as unlearned")
expect(has("Cooking: 75/75; reached."),
    "Other readable skills remain usable")
slots = {1,2,3,4}

local prior = slotCalls
reset(); SlashCmdList.FOREVERPROFESSIONS("ungoal fishing")
expect(has("Goal removed: Fishing."), "Case-insensitive removal")
expect(ns.GoalCount() == 1, "Only matching goal deleted")
expect(slotCalls == prior, "Removing goal does not sample API")
reset(); SlashCmdList.FOREVERPROFESSIONS("ungoal Fishing")
expect(has("No goal for: Fishing."), "No invented goal deleted")

reset(); SlashCmdList.FOREVERPROFESSIONS("goals clear")
expect(has("Goals cleared (session only)."), "Clear all confirmation")
expect(slotCalls == prior, "Clearing all does not query skills")
expect(ns.GoalCount() == 0, "No goals remain")
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("No goals."), "Clear empty list")
expect(slotCalls == prior, "Empty goals do not query API")

-- Snapshot-clear is independent from goals-clear, by design.
reset(); SlashCmdList.FOREVERPROFESSIONS("goal Cooking 75")
reset(); SlashCmdList.FOREVERPROFESSIONS("snapshot")
reset(); SlashCmdList.FOREVERPROFESSIONS("clear")
expect(has("Snapshot cleared (session only)."),
    "Snapshot clear remains independently supported")
expect(ns.GoalCount() == 1, "Snapshot clear does not delete skill targets")

-- Absent or unsafe APIs reject goals, never invent skill ranks.
GetProfessions = nil
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("Profession API unavailable on this build."),
    "Missing API blocks reading goals")
GetProfessions = function()
    slotCalls = slotCalls + 1
    return unpack(slots,1,5)
end
InCombatLockdown = function() return true end
prior = slotCalls
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("Profession readout unavailable during combat."),
    "Combat guard blocks new reads")
expect(slotCalls == prior, "No client API read in combat")
InCombatLockdown = function() return false end

active = false
descriptor.Disable(descriptor)
prior = slotCalls
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("Module not active: disabled."), "Core logical disable gates goals")
expect(slotCalls == prior, "Disabled module never samples skills")
active = true
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("No goals."), "Disable clears all session targets")
reset(); SlashCmdList.FOREVERPROFESSIONS("progress")
expect(has("No snapshot."), "Disable also clears prior snapshot")

-- Maximum of five goals, update is still legal at capacity.
skills[5] = {"Skinning",5,75}
slots = {1,2,3,4,5}
for _, goal in ipairs({
    {"Mining",75},{"Blacksmithing",75},{"Fishing",75},
    {"Cooking",75},{"Skinning",75}
}) do
    reset(); SlashCmdList.FOREVERPROFESSIONS(
        "goal "..goal[1].." "..goal[2])
    expect(has("Goal set:"), "Each of five goals accepted")
end
expect(ns.GoalCount() == 5, "Five goals stored, hard bound")
reset(); SlashCmdList.FOREVERPROFESSIONS("goal Mining 60")
expect(has("Goal set: Mining 60"), "Existing goal can change at bound")
expect(ns.GoalCount() == 5, "No sixth goal created")
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(#out == 6, "Exactly one header and five goal rows")

-- Defense against invalid rank from the game.
skills[1][2] = 0/0
reset(); SlashCmdList.FOREVERPROFESSIONS("goals")
expect(has("Profession details unavailable."), "Invalid API values handled")
skills[1][2] = 30

reset(); SlashCmdList.FOREVERPROFESSIONS("goal Cooking not-a-number")
expect(has("Usage: /fprof goal"), "Invalid target syntax rejected")
reset(); SlashCmdList.FOREVERPROFESSIONS("nonsense")
expect(has("Usage: /fprof"), "Unknown command rejected")

print = originalPrint
print("ForeverProfessions manual skill goals mock tests passed.")
