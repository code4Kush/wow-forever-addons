--[[
    ForeverProfessions 0.3: explicitly invoked read-only skill commands.
    Session snapshots and manual goals have separate clearing controls.
    No timers, events, crafting actions, or automated game API sampling.
]]
local _, addon = ...

local function PrintHelp()
    addon.Print("Commands: /fprof | snapshot | progress | clear | version | help")
    addon.Print("Goals: /fprof goal <name> <rank> | goals | ungoal <name> | goals clear")
    addon.Print("Snapshots and goals are separate, session-only; unknown skills stay unknown.")
end

local function GoalCommand(argument)
    local name, digits = argument:match("^(.+)%s+(%d+)$")
    if not name then
        addon.Print("Usage: /fprof goal <profession name> <target-rank>")
        return
    end
    -- tonumber only for a bounded digit string. No whitespace or symbols
    -- can silently alter the requested target rank.
    if #digits > 6 then
        addon.Print("Usage: /fprof goal <profession name> <target-rank>")
        return
    end
    local value, reason = addon.SetGoal(name, tonumber(digits))
    if not value then
        addon.Print(reason)
        return
    end
    addon.Print(string.format(
        "Goal set: %s %d (currently %d; %d remaining; session only).",
        value.name, value.target, value.rank, value.remaining
    ))
end

--- Handles one player-entered slash command.
--- @param message string|nil Text following /fprof.
local function Handle(message)
    local trimmed = (message or ""):match("^%s*(.-)%s*$")
    local lowered = string.lower(trimmed)

    if lowered == "version" then
        addon.Print("Version " .. addon.version)
        return
    end
    if lowered == "help" then
        PrintHelp()
        return
    end

    local mode, argument
    if lowered:sub(1, 5) == "goal " then
        mode, argument = "set-goal", trimmed:sub(6)
    elseif lowered:sub(1, 7) == "ungoal " then
        mode, argument = "remove-goal", trimmed:sub(8)
    elseif lowered == "goals" then
        mode = "list-goals"
    elseif lowered == "goals clear" then
        mode = "clear-goals"
    elseif lowered == "goal" or lowered == "ungoal" then
        addon.Print(lowered == "goal"
            and "Usage: /fprof goal <profession name> <target-rank>"
            or "Usage: /fprof ungoal <profession name>")
        return
    elseif lowered == "" or lowered == "snapshot"
        or lowered == "progress" or lowered == "clear" then
        mode = lowered
    else
        addon.Print("Usage: /fprof [snapshot|progress|clear|goal <name> <rank>|goals|ungoal <name>|goals clear|version|help]")
        return
    end

    local status = ForeverCore.GetModuleStatus("professions")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: "
            .. (status and status.state or "not registered") .. ".")
        return
    end

    if mode == "" then
        addon.Render()
    elseif mode == "snapshot" then
        local count, reason = addon.SaveSnapshot()
        if not count then
            addon.Print(reason)
        else
            addon.Print(string.format(
                "Snapshot saved: %d readable profession(s) (session only).",
                count
            ))
        end
    elseif mode == "progress" then
        addon.RenderProgress()
    elseif mode == "clear" then
        addon.ClearSnapshot()
        addon.Print("Snapshot cleared (session only).")
    elseif mode == "set-goal" then
        GoalCommand(argument)
    elseif mode == "list-goals" then
        addon.RenderGoals()
    elseif mode == "remove-goal" then
        local removed = addon.RemoveGoal(argument)
        if removed then
            addon.Print("Goal removed: " .. removed .. ".")
        else
            addon.Print("No goal for: " .. argument .. ".")
        end
    else
        addon.ClearGoals()
        addon.Print("Goals cleared (session only).")
    end
end

SLASH_FOREVERPROFESSIONS1 = "/fprof"
SlashCmdList.FOREVERPROFESSIONS = Handle
