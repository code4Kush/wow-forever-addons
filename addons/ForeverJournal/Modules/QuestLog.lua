--[[
    Forever Journal: QuestLog
    Reads the player's current quest log and location using documented,
    modern WoW API functions. No saved data, gameplay actions, or background
    scanning are performed. APIs are accessed only when requested by a user.
]]

local _, addon = ...

addon.QuestLog = {}
local QuestLog = addon.QuestLog

--- Returns a snapshot of visible active quest-log entries.
---
--- Header rows are excluded. This list is NOT a database of all quests
--- available in the game, nor a history of previously turned-in quests.
---
--- @return table|nil quests Array of { id, title, level, isComplete }.
--- @return string|nil errorMessage Explains unavailable APIs or results.
function QuestLog.GetActiveQuests()
    if type(C_QuestLog) ~= "table"
        or type(C_QuestLog.GetNumQuestLogEntries) ~= "function"
        or type(C_QuestLog.GetInfo) ~= "function" then
        return nil, "Quest log API unavailable on this client."
    end

    local entryCount = C_QuestLog.GetNumQuestLogEntries()
    if type(entryCount) ~= "number" then
        return nil, "The quest log did not return an entry count."
    end

    local quests = {}

    for entryIndex = 1, entryCount do
        local info = C_QuestLog.GetInfo(entryIndex)

        if type(info) == "table"
            and not info.isHeader
            and not info.isHidden
            and type(info.questID) == "number" then
            local questReady = nil

            if type(C_QuestLog.IsComplete) == "function" then
                questReady = C_QuestLog.IsComplete(info.questID) == true
            end

            quests[#quests + 1] = {
                id = info.questID,
                title = type(info.title) == "string" and info.title or "Unnamed quest",
                level = info.level,
                isComplete = questReady,
            }
        end
    end

    return quests
end

--- Finds an active quest by its quest ID.
---
--- @param questID number Positive quest identifier.
--- @return table|nil quest A record from GetActiveQuests.
--- @return string|nil errorMessage Error when the quest API is unavailable.
function QuestLog.FindActiveQuest(questID)
    local quests, errorMessage = QuestLog.GetActiveQuests()

    if not quests then
        return nil, errorMessage
    end

    for _, quest in ipairs(quests) do
        if quest.id == questID then
            return quest
        end
    end

    return nil
end

--- Reads the currently listed objectives for an active quest.
---
--- A nil result can mean the quest's data has not been cached yet.
---
--- @param questID number The ID of a quest currently in the quest log.
--- @return table|nil objectives Objective entries provided by the game.
--- @return string|nil errorMessage Reason objectives were unavailable.
function QuestLog.GetObjectives(questID)
    if type(C_QuestLog) ~= "table"
        or type(C_QuestLog.GetQuestObjectives) ~= "function" then
        return nil, "Quest objective API unavailable on this client."
    end

    local objectives = C_QuestLog.GetQuestObjectives(questID)

    if type(objectives) ~= "table" then
        return nil, "Objectives are unavailable or still loading; try again."
    end

    return objectives
end

--- Returns the player's current map or zone name.
---
--- The returned map can represent a subzone or microdungeon, not
--- necessarily the zone used for a future completionist checklist.
---
--- @return string name Friendly name of the detected location.
--- @return number|nil mapID ID from the map UI, if available.
function QuestLog.GetCurrentArea()
    if type(C_Map) == "table"
        and type(C_Map.GetBestMapForUnit) == "function"
        and type(C_Map.GetMapInfo) == "function" then
        local mapID = C_Map.GetBestMapForUnit("player")

        if type(mapID) == "number" then
            local mapInfo = C_Map.GetMapInfo(mapID)

            if type(mapInfo) == "table"
                and type(mapInfo.name) == "string"
                and mapInfo.name ~= "" then
                return mapInfo.name, mapID
            end
        end
    end

    if type(GetZoneText) == "function" then
        local zoneName = GetZoneText()

        if type(zoneName) == "string" and zoneName ~= "" then
            return zoneName
        end
    end

    return "Unknown area"
end
