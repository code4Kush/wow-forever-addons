--[[
    ForeverProfessions 0.3: manual, session-only profession targets.

    Targets belong to this addon, not Core and not the game client.
    At most five current profession names and chosen target ranks are
    retained. No SavedVariables, timers, game events, network or crafting.

    An unobservable skill is not treated as a zero level; it is unknown.
]]
local _, addon = ...
local MAX_GOALS = 5
local MAX_NAME_BYTES = 80
local entries = {}
local order = {}

local function FoldName(value)
    return string.lower(value)
end

--- Adds/replaces a manual target for a presently readable profession.
--- @param requestedName string Profession name entered by the player.
--- @param target number Requested rank, whole positive integer.
--- @return table|nil goal The new or updated goal.
--- @return string|nil reason Why the goal cannot be set.
function addon.SetGoal(requestedName, target)
    if type(requestedName) ~= "string" or #requestedName == 0
        or #requestedName > MAX_NAME_BYTES or type(target) ~= "number"
        or target ~= target or target == math.huge
        or target < 1 or target ~= math.floor(target) then
        return nil, "Usage: /fprof goal <profession name> <target-rank>"
    end

    local skills, reason = addon.ReadSkills()
    if not skills then
        return nil, reason
    end

    local match
    for _, skill in ipairs(skills) do
        if FoldName(skill.name) == FoldName(requestedName) then
            match = skill
            break
        end
    end

    if not match then
        return nil, "Profession not readable now: " .. requestedName .. "."
    end
    if target > match.maximum then
        return nil, string.format(
            "Goal exceeds %s maximum (%d).", match.name, match.maximum
        )
    end

    local key = FoldName(match.name)
    if not entries[key] and #order >= MAX_GOALS then
        return nil, "Goal limit reached (5). Remove a goal first."
    end
    if not entries[key] then
        order[#order + 1] = key
    end
    entries[key] = { name = match.name, target = target }

    return {
        name = match.name, target = target,
        rank = match.rank, remaining = math.max(0, target - match.rank),
    }
end

--- Removes one goal by case-insensitive profession name, no client read.
--- @param requestedName string Exact entered name in any case.
--- @return string|nil removed The removed display name, if any.
function addon.RemoveGoal(requestedName)
    if type(requestedName) ~= "string" or requestedName == ""
        or #requestedName > MAX_NAME_BYTES then
        return nil
    end
    local key = FoldName(requestedName)
    local old = entries[key]
    if not old then
        return nil
    end
    entries[key] = nil
    for i, existingKey in ipairs(order) do
        if existingKey == key then
            table.remove(order, i)
            break
        end
    end
    return old.name
end

--- Drops all goals on manual request or Core module disable.
function addon.ClearGoals()
    entries = {}
    order = {}
end

--- Gets the number of targets without reading game APIs.
--- @return number count Number of manually stored goals.
function addon.GoalCount()
    return #order
end

--- Shows on-demand current progress for at most five manual targets.
--- A missing skill is "unreadable" rather than zero or untrained.
function addon.RenderGoals()
    if #order == 0 then
        addon.Print("No goals. Use /fprof goal <profession> <rank>.")
        return
    end

    local skills, reason = addon.ReadSkills()
    if not skills then
        addon.Print(reason)
        return
    end

    local byName = {}
    for _, skill in ipairs(skills) do
        byName[FoldName(skill.name)] = skill
    end

    addon.Print(string.format(
        "Goals: %d target(s) (session only).", #order
    ))
    for _, key in ipairs(order) do
        local goal = entries[key]
        local skill = byName[key]
        if not skill then
            addon.Print(string.format(
                "%s: unreadable now; target %d; remaining unknown.",
                goal.name, goal.target
            ))
        else
            local remaining = math.max(0, goal.target - skill.rank)
            if remaining == 0 then
                addon.Print(string.format(
                    "%s: %d/%d; reached.",
                    skill.name, skill.rank, goal.target
                ))
            else
                addon.Print(string.format(
                    "%s: %d/%d; %d remaining.",
                    skill.name, skill.rank, goal.target, remaining
                ))
            end
        end
    end
end
