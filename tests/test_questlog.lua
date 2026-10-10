--[[
    Forever Journal: deterministic quest log and slash-command tests.
    Run from the repository root with: lua5.1 tests/test_questlog.lua
    The WoW API is mocked; passing tests do not confirm beta client support.
]]

local originalPrint = print
local printedMessages = {}

print = function(message)
    printedMessages[#printedMessages + 1] = tostring(message)
end

local function AssertContains(fragment, description)
    local combinedOutput = table.concat(printedMessages, "\n")

    assert(
        combinedOutput:find(fragment, 1, true),
        description .. " (missing: " .. fragment .. ")"
    )
end

local function ClearMessages()
    printedMessages = {}
end

local addon = {}
local function LoadAddonModule(path)
    local chunk = assert(loadfile("addons/ForeverJournal/" .. path))
    chunk("ForeverJournal", addon)
end

local activeQuestRows = {
    { title = "Westfall", isHeader = true },
    { title = "The Forgotten Patrol", questID = 101, level = 12 },
    { title = "Supply Run", questID = 102, level = 14 },
    { title = "Hidden Quest", questID = 103, isHidden = true },
}

C_QuestLog = {
    GetNumQuestLogEntries = function() return #activeQuestRows, 3 end,
    GetInfo = function(index) return activeQuestRows[index] end,
    IsComplete = function(id) return id == 102 end,
    GetQuestObjectives = function(id)
        if id == 101 then
            return {
                { text = "Find 2 maps: 1/2", finished = false },
                { text = "Speak to guard", finished = true },
            }
        end
        return {}
    end,
}

C_Map = {
    GetBestMapForUnit = function(unit)
        assert(unit == "player")
        return 52
    end,
    GetMapInfo = function(id)
        assert(id == 52)
        return { name = "Westfall", mapID = 52 }
    end,
}

GetZoneText = function()
    return "Fallback Zone"
end

SlashCmdList = {}

LoadAddonModule("Core/Bootstrap.lua")
LoadAddonModule("Modules/Progress.lua")
LoadAddonModule("Modules/QuestLog.lua")
LoadAddonModule("Core/Commands.lua")

local quests = assert(addon.QuestLog.GetActiveQuests())
assert(#quests == 2, "Quest headers and hidden entries must be filtered")
assert(quests[1].id == 101, "First active quest ID should match")
assert(quests[2].isComplete == true, "Ready quest should be marked")
assert(quests[1].isComplete == false, "Incomplete quest should not be marked ready")
assert(addon.QuestLog.FindActiveQuest(103) == nil, "Hidden quest should not appear")

local objectives = assert(addon.QuestLog.GetObjectives(101))
assert(#objectives == 2, "Objectives should be preserved")

local zoneName, mapID = addon.QuestLog.GetCurrentArea()
assert(zoneName == "Westfall" and mapID == 52, "Map lookup should return name and ID")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("quests")
AssertContains("Active quests: 2 listed (page 1/1)", "Quest listing")
AssertContains("The Forgotten Patrol (ID 101)", "Quest ID displayed")
AssertContains("[ready to turn in]", "Quest turn-in readiness")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("quest 101")
AssertContains("Find 2 maps: 1/2", "Objective text displayed")
AssertContains("[done] Speak to guard", "Completed objective displayed")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("zone")
AssertContains("Current area: Westfall (map 52)", "Area display")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("quests 2")
AssertContains("Only 1 quest page(s) available", "Invalid page message")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("quests 0")
AssertContains("Usage: /fj quests", "Invalid page rejected")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("quest invalid")
AssertContains("Usage: /fj quest", "Invalid quest ID rejected")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("progress 3 5")
AssertContains("Progress: 60.00%", "Legacy progress command")

-- Verify pagination with a longer quest log, including the second page.
activeQuestRows = {}
for questNumber = 1, 8 do
    activeQuestRows[questNumber] = {
        title = "Test Quest " .. questNumber,
        questID = 200 + questNumber,
        level = 10,
    }
end

ClearMessages()
SlashCmdList.FOREVERJOURNAL("quests 2")
AssertContains("page 2/2", "Second page navigation")
AssertContains("Test Quest 7 (ID 207)", "First quest on second page")
AssertContains("Test Quest 8 (ID 208)", "Last quest on second page")

-- A temporarily unavailable quest objective response must be nonfatal.
C_QuestLog.GetQuestObjectives = function() return nil end
local missingObjectives, objectivesError = addon.QuestLog.GetObjectives(201)
assert(
    missingObjectives == nil and type(objectivesError) == "string",
    "Uncached objective information should produce a helpful error"
)

C_Map = nil
zoneName, mapID = addon.QuestLog.GetCurrentArea()
assert(zoneName == "Fallback Zone" and mapID == nil, "Zone name fallback")

C_QuestLog = nil
local missingQuests, apiError = addon.QuestLog.GetActiveQuests()
assert(missingQuests == nil and type(apiError) == "string", "Missing API handled")

ClearMessages()
SlashCmdList.FOREVERJOURNAL("quests")
AssertContains("Quest log API unavailable", "Missing API message")

print = originalPrint
print("Forever Journal quest log mock tests passed.")
