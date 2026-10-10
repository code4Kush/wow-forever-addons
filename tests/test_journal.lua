--[[
    Forever Journal: curated starter journal tests (Lua 5.1).
    The game APIs below are mocked; this is NOT an in-game compatibility test.
    Run from the repository root: lua5.1 tests/test_journal.lua
]]

local originalPrint = print
local output = {}

print = function(message)
    output[#output + 1] = tostring(message)
end

local function ResetOutput()
    output = {}
end

local function ExpectOutput(fragment)
    assert(table.concat(output, "\n"):find(fragment, 1, true),
        "Expected text: " .. fragment)
end

local addon = {}
local function LoadModule(fileName)
    local chunk = assert(loadfile("addons/ForeverJournal/" .. fileName))
    chunk("ForeverJournal", addon)
end

local completed = { [747] = true, [752] = true }
local logRows = {
    { title = "The Hunt Continues", questID = 750, isHeader = false },
    { title = "Rites of the Earthmother", questID = 755, isHeader = false },
}

C_QuestLog = {
    GetNumQuestLogEntries = function() return #logRows end,
    GetInfo = function(index) return logRows[index] end,
    IsComplete = function(id) return id == 755 end,
    IsQuestFlaggedCompleted = function(id) return completed[id] == true end,
}
UnitName = function() return "Uddergrief" end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitRace = function() return "Tauren", "Tauren" end
UnitLevel = function() return 4 end
GetRealmName = function() return "ExampleRealm" end
SlashCmdList = {}

LoadModule("Core/Bootstrap.lua")
LoadModule("Modules/Progress.lua")
LoadModule("Modules/QuestLog.lua")
LoadModule("Modules/QuestHistory.lua")
LoadModule("Modules/Character.lua")
LoadModule("Data/MulgoreStarter.lua")
LoadModule("Modules/ZoneJournal.lua")
LoadModule("Core/Commands.lua")

local journal = assert(addon.ZoneJournal.GetMulgoreStarterSnapshot())
assert(journal.total == 12, "Warrior catalog must include 12 selected quests")
assert(journal.completed == 2, "Only submitted quest IDs should be complete")
assert(journal.active == 2, "Current log should have two matching active quests")
assert(journal.entries[1].id == 747 and journal.entries[1].status == "done",
    "First curated entry and completion status")
assert(journal.entries[4].id == 750 and journal.entries[4].status == "active",
    "Active quest should be classified independently of history")
assert(journal.entries[6].id == 755 and journal.entries[6].status == "ready",
    "Ready-to-turn-in quest should not be counted historically completed")

ResetOutput()
SlashCmdList.FOREVERJOURNAL("journal")
ExpectOutput("Mulgore starter catalog: 2/12 flagged complete, 2 active.")
ExpectOutput("Page 1/2 - curated sample, NOT all Mulgore quests.")
ExpectOutput("[done] The Hunt Begins (ID 747)")
ExpectOutput("[not flagged] A Humble Task (part 2) (ID 753)")
ExpectOutput("[ready] Rites of the Earthmother (early) (ID 755)")

ResetOutput()
SlashCmdList.FOREVERJOURNAL("journal 2")
ExpectOutput("Page 2/2")
ExpectOutput("A Task Unfinished (ID 1656)")

ResetOutput()
SlashCmdList.FOREVERJOURNAL("journal 0")
ExpectOutput("Usage: /fj journal [page number]")

ResetOutput()
SlashCmdList.FOREVERJOURNAL("journal 3")
ExpectOutput("Only 2 journal page(s) available.")

ResetOutput()
SlashCmdList.FOREVERJOURNAL("version")
ExpectOutput("Version 0.4.0")

UnitClass = function() return "Shaman", "SHAMAN" end
journal = assert(addon.ZoneJournal.GetMulgoreStarterSnapshot())
assert(journal.total == 11, "Non-Warriors must not see a Warrior-only quest")
for _, entry in ipairs(journal.entries) do
    assert(entry.id ~= 3091, "Simple Note must not appear for Shamans")
end

UnitRace = function() return "Orc", "Orc" end
local invalidJournal, raceError = addon.ZoneJournal.GetMulgoreStarterSnapshot()
assert(invalidJournal == nil and raceError:find("Tauren"),
    "Non-Tauren characters should not use a Tauren-only catalog")

UnitRace = function() return "Tauren", "Tauren" end
C_QuestLog.IsQuestFlaggedCompleted = nil
local missingJournal, historyError = addon.ZoneJournal.GetMulgoreStarterSnapshot()
assert(missingJournal == nil and historyError:find("unavailable"),
    "If the historical API is missing, never invent totals")

print = originalPrint
print("Forever Journal curated starter journal tests passed.")
