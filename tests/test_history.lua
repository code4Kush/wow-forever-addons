--[[
    Deterministic Lua 5.1 tests for historical quest status and identity.
    Run from repository root: lua5.1 tests/test_history.lua

    These mocks do not prove any API works in the live Forever client.
]]

local originalPrint = print
local messages = {}
print = function(message)
    messages[#messages + 1] = tostring(message)
end

local function ClearOutput()
    messages = {}
end

local function AssertOutput(fragment)
    local output = table.concat(messages, "\n")
    assert(output:find(fragment, 1, true), "Expected output: " .. fragment)
end

local addon = {}

local function LoadModule(name)
    local chunk = assert(loadfile("addons/ForeverJournal/" .. name))
    chunk("ForeverJournal", addon)
end

local quests = {
    { title = "An Active Quest", questID = 9001, level = 2 },
    { title = "A Ready Quest", questID = 9002, level = 2 },
}

C_QuestLog = {
    IsQuestFlaggedCompleted = function(questID)
        return questID == 747 or questID == 752
    end,
    GetNumQuestLogEntries = function() return #quests end,
    GetInfo = function(index) return quests[index] end,
    IsComplete = function(questID) return questID == 9002 end,
}

UnitName = function(unit)
    assert(unit == "player")
    return "Uddergrief"
end

UnitClass = function(unit)
    assert(unit == "player")
    return "Warrior", "WARRIOR"
end

UnitRace = function(unit)
    assert(unit == "player")
    return "Tauren", "Tauren"
end

UnitLevel = function(unit)
    assert(unit == "player")
    return 3
end

GetRealmName = function()
    return "TestRealm"
end

SlashCmdList = {}

LoadModule("Core/Bootstrap.lua")
LoadModule("Modules/Progress.lua")
LoadModule("Modules/QuestLog.lua")
LoadModule("Modules/QuestHistory.lua")
LoadModule("Modules/Character.lua")
LoadModule("Core/Commands.lua")

assert(addon.QuestHistory.IsFlaggedCompleted(747) == true, "Completed 747")
assert(addon.QuestHistory.IsFlaggedCompleted(752) == true, "Completed 752")
assert(addon.QuestHistory.IsFlaggedCompleted(9001) == false, "Active not completed")
assert(addon.QuestHistory.IsFlaggedCompleted(-1) == nil, "Reject invalid number")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("status 747")
AssertOutput("Quest 747: flagged completed for this character.")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("status 752")
AssertOutput("Quest 752: flagged completed for this character.")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("status 9001")
AssertOutput("An Active Quest (quest 9001): active, in progress")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("status 9002")
AssertOutput("A Ready Quest (quest 9002): active, ready to turn in")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("status 99999999")
AssertOutput("may be unaccepted, abandoned, or invalid")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("status bananas")
AssertOutput("Usage: /fj status <questID>")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("character")
AssertOutput("Uddergrief - Tauren Warrior - level 3 - realm TestRealm")

ClearOutput()
SlashCmdList.FOREVERJOURNAL("character extra")
AssertOutput("Usage: /fj character")

C_QuestLog.IsQuestFlaggedCompleted = nil
ClearOutput()
SlashCmdList.FOREVERJOURNAL("status 747")
AssertOutput("Historical quest completion API unavailable")

GetRealmName = nil
local identity = addon.Character.GetIdentity()
assert(identity.realm == nil and identity.name == "Uddergrief",
    "Character identity should work without realm API")

print = originalPrint
print("Forever Journal historical status tests passed.")
