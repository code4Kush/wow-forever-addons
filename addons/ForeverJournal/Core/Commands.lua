--[[
    Forever Journal: Commands
    Presents small, read-only quest-log snapshots on request. Outputs are
    paginated to avoid spamming chat or impacting other players' experience.
]]

local _, addon = ...

local QUESTS_PER_PAGE = 6
local MAX_QUEST_ID = 100000000
local JOURNAL_PAGE_SIZE = 6

local function PrintHelp()
    addon.Print("Commands: /fj, /fj version, /fj progress <completed> <total>")
    addon.Print("/fj zone | /fj quests [page] | /fj quest <questID>")
    addon.Print("/fj status <questID> | /fj character")
    addon.Print("/fj journal [page] - curated Mulgore starter quests")
end

--- Parses a positive decimal integer without accepting signs or fractions.
---
--- @param argument string Text representing a positive integer.
--- @param maximum number Highest supported value.
--- @return number|nil value Validated integer, or nil.
local function ParsePositiveInteger(argument, maximum)
    if type(argument) ~= "string" or not argument:match("^%d+$") then
        return nil
    end

    local value = tonumber(argument)

    if not value or value < 1 or value > maximum then
        return nil
    end

    return value
end

local function PrintCurrentArea()
    local areaName, mapID = addon.QuestLog.GetCurrentArea()

    if mapID then
        addon.Print(string.format("Current area: %s (map %d)", areaName, mapID))
    else
        addon.Print("Current area: " .. areaName)
    end

    addon.Print("Area detection does not measure zone quest completion.")
end

local function PrintActiveQuests(pageArgument)
    local page = 1

    if pageArgument ~= "" then
        page = ParsePositiveInteger(pageArgument, 999)

        if not page then
            addon.Print("Usage: /fj quests [page number]")
            return
        end
    end

    local quests, errorMessage = addon.QuestLog.GetActiveQuests()

    if not quests then
        addon.Print(errorMessage)
        return
    end

    if #quests == 0 then
        addon.Print("Your quest log has no readable active quests.")
        return
    end

    local totalPages = math.ceil(#quests / QUESTS_PER_PAGE)

    if page > totalPages then
        addon.Print(string.format("Only %d quest page(s) available.", totalPages))
        return
    end

    addon.Print(string.format(
        "Active quests: %d listed (page %d/%d)",
        #quests,
        page,
        totalPages
    ))

    local firstIndex = (page - 1) * QUESTS_PER_PAGE + 1
    local lastIndex = math.min(firstIndex + QUESTS_PER_PAGE - 1, #quests)

    for questIndex = firstIndex, lastIndex do
        local quest = quests[questIndex]
        local readiness = quest.isComplete == true and " [ready to turn in]" or ""

        addon.Print(string.format(
            "%d. %s (ID %d)%s",
            questIndex,
            quest.title,
            quest.id,
            readiness
        ))
    end

    addon.Print("Use /fj quest <ID> for objectives; /fj quests <page> for more.")
end

local function PrintQuestDetails(argument)
    local questID = ParsePositiveInteger(argument, MAX_QUEST_ID)

    if not questID then
        addon.Print("Usage: /fj quest <questID> (use /fj quests to find IDs)")
        return
    end

    local quest, errorMessage = addon.QuestLog.FindActiveQuest(questID)

    if not quest then
        addon.Print(errorMessage or "Quest not found in your current quest log.")
        return
    end

    addon.Print(string.format("%s (quest ID %d)", quest.title, quest.id))

    if quest.isComplete == true then
        addon.Print("Quest is ready to turn in.")
    elseif quest.isComplete == false then
        addon.Print("Quest is not yet ready to turn in.")
    else
        addon.Print("Quest completion status unavailable.")
    end

    local objectives, objectivesError = addon.QuestLog.GetObjectives(quest.id)

    if not objectives then
        addon.Print(objectivesError)
        return
    end

    if #objectives == 0 then
        addon.Print("No objective rows were returned for this quest.")
        return
    end

    for objectiveIndex, objective in ipairs(objectives) do
        if type(objective) == "table" then
            local status = objective.finished == true and "[done]" or "[ ]"
            local description = type(objective.text) == "string"
                and objective.text or "Objective text unavailable"

            addon.Print(string.format(
                "%d. %s %s",
                objectiveIndex,
                status,
                description
            ))
        end
    end
end


--- Reports a quest's historical completion flag and, where relevant,
--- whether the quest remains in the character's active quest log.
---
--- @param argument string Quest identifier entered by the player.
local function PrintHistoricalQuestStatus(argument)
    local questID = ParsePositiveInteger(argument, MAX_QUEST_ID)

    if not questID then
        addon.Print("Usage: /fj status <questID>")
        return
    end

    local flaggedCompleted, completionError = addon.QuestHistory.IsFlaggedCompleted(questID)

    if flaggedCompleted == nil then
        addon.Print(completionError)
        return
    end

    if flaggedCompleted then
        addon.Print(string.format(
            "Quest %d: flagged completed for this character.",
            questID
        ))
        return
    end

    local activeQuest, activeError = addon.QuestLog.FindActiveQuest(questID)

    if activeError then
        addon.Print(string.format(
            "Quest %d: not flagged completed; active status unavailable.",
            questID
        ))
        return
    end

    if activeQuest then
        local readiness = activeQuest.isComplete == true
            and "ready to turn in" or "in progress"

        addon.Print(string.format(
            "%s (quest %d): active, %s; not flagged completed.",
            activeQuest.title,
            questID,
            readiness
        ))
        return
    end

    addon.Print(string.format(
        "Quest %d: not flagged completed; it may be unaccepted, abandoned, or invalid.",
        questID
    ))
end

--- Prints the current player identity as reported by the game.
---
--- The identity is detected at runtime and is not hardcoded to any player.
local function PrintCharacter()
    local identity = addon.Character.GetIdentity()

    if identity.realm then
        addon.Print(string.format(
            "%s - %s %s - level %s - realm %s",
            identity.name, identity.race, identity.class, identity.level, identity.realm
        ))
    else
        addon.Print(string.format(
            "%s - %s %s - level %s",
            identity.name, identity.race, identity.class, identity.level
        ))
    end
end


--- Displays a curated Mulgore starting-area checklist.
---
--- The catalog is not exhaustive and is never described as zone-wide
--- completion. All statuses are read directly from the game on demand.
---
--- @param argument string Optional decimal page number.
local function PrintMulgoreJournal(argument)
    local page = 1

    if argument ~= "" then
        page = ParsePositiveInteger(argument, 999)

        if not page then
            addon.Print("Usage: /fj journal [page number]")
            return
        end
    end

    local snapshot, errorMessage = addon.ZoneJournal.GetMulgoreStarterSnapshot()

    if not snapshot then
        addon.Print(errorMessage)
        return
    end

    local pageCount = math.ceil(#snapshot.entries / JOURNAL_PAGE_SIZE)

    if page > pageCount then
        addon.Print(string.format("Only %d journal page(s) available.", pageCount))
        return
    end

    addon.Print(string.format(
        "Mulgore starter catalog: %d/%d flagged complete, %d active.",
        snapshot.completed,
        snapshot.total,
        snapshot.active
    ))
    addon.Print(string.format(
        "Page %d/%d - curated sample, NOT all Mulgore quests.",
        page,
        pageCount
    ))

    local firstIndex = (page - 1) * JOURNAL_PAGE_SIZE + 1
    local lastIndex = math.min(firstIndex + JOURNAL_PAGE_SIZE - 1, #snapshot.entries)

    for entryIndex = firstIndex, lastIndex do
        local quest = snapshot.entries[entryIndex]
        local status = "[" .. quest.status .. "]"

        addon.Print(string.format(
            "%s %s (ID %d)",
            status,
            quest.label,
            quest.id
        ))
    end

    addon.Print("Not flagged does not mean available; use /fj journal <page>.")
end

--- Handles a player-entered /fj command.
---
--- @param message string|nil Arguments entered after /fj.
local function HandleSlashCommand(message)
    local commandLine = message or ""
    local command, arguments = commandLine:match("^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "" or command == "help" then
        PrintHelp()
        return
    end

    if command == "version" then
        addon.Print("Version " .. addon.version)
        return
    end

    if command == "progress" then
        local completedText, totalText = arguments:match("^(%d+)%s+(%d+)$")

        if not completedText then
            addon.Print("Usage: /fj progress <completed> <total>")
            return
        end

        local percentage = addon.Progress.CalculatePercentage(
            tonumber(completedText),
            tonumber(totalText)
        )
        addon.Print(string.format("Progress: %.2f%%", percentage))
        return
    end

    if command == "zone" then
        if arguments ~= "" then
            addon.Print("Usage: /fj zone")
            return
        end

        PrintCurrentArea()
        return
    end

    if command == "quests" then
        PrintActiveQuests(arguments)
        return
    end

    if command == "quest" then
        PrintQuestDetails(arguments)
        return
    end

    if command == "status" then
        PrintHistoricalQuestStatus(arguments)
        return
    end

    if command == "character" then
        if arguments ~= "" then
            addon.Print("Usage: /fj character")
            return
        end

        PrintCharacter()
        return
    end

    if command == "journal" then
        PrintMulgoreJournal(arguments)
        return
    end

    addon.Print("Unknown command: " .. command)
    PrintHelp()
end

-- Core profile-aware wrapper: allow help/version diagnostics when
-- disabled; block all quest and journal views until re-enabled. Keeping the
-- fallback for standalone Lua mocks does not relax the in-game TOC dependency.
local function HandleCoreAwareCommand(message)
    local command = (message or ""):match("^%s*(%S*)") or ""

    if command == "" or command == "help" or command == "version" then
        HandleSlashCommand(message)
        return
    end

    if type(ForeverCore) == "table"
        and type(ForeverCore.GetModuleStatus) == "function" then
        local status = ForeverCore.GetModuleStatus("journal")
        if not status or status.state ~= "active" then
            addon.Print("Journal module not active: "
                .. (status and status.state or "not registered") .. ".")
            return
        end
    end

    HandleSlashCommand(message)
end

SLASH_FOREVERJOURNAL1 = "/fj"
SlashCmdList.FOREVERJOURNAL = HandleCoreAwareCommand
