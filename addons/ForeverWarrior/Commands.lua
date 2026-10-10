--[[
    Forever Warrior: Player Commands

    Every output is advice or a manual checklist. No spell casts, item use,
    equipment swaps, scans or protected game operations happen here.
    A disabled or ineligible Core module does not serve character plans.
]]

local _, addon = ...

local MODULE_ID = "forever-warrior"

local function PrintHelp()
    addon.Print("Commands: /fw plan | ready [done|undo <1-5>|reset] | professions | status | version")
    addon.Print("All readiness checks are MANUAL; no equipment or skill scan.")
end

local function GetActiveCharacter()
    local moduleStatus = ForeverCore.GetModuleStatus(MODULE_ID)

    if not moduleStatus then
        addon.Print("Module not registered. Install ForeverCore and ForeverWarrior.")
        return nil
    end

    if moduleStatus.state ~= "active" then
        local reason = moduleStatus.reason
            and (" (" .. moduleStatus.reason .. ")") or ""
        addon.Print("Module " .. moduleStatus.state .. reason
            .. ". Use /forever status forever-warrior for details.")
        return nil
    end

    local character = ForeverCore.GetCharacter()

    if not character then
        addon.Print("Character information unavailable before login.")
        return nil
    end

    return character
end

local function GetCurrentLevel(character)
    -- Core's identity snapshot is made at login. Prefer a read-only live
    -- level query so /fw plan advances immediately after leveling.
    if type(UnitLevel) == "function" then
        local ok, current = pcall(UnitLevel, "player")
        if ok and type(current) == "number" and current == current
            and current >= 1 and current <= 1000
            and current % 1 == 0 then
            return current
        end
    end

    -- This fallback may be stale after a level-up; never claim it is live.
    return character.level
end

local function PrintPlan(character)
    local level = GetCurrentLevel(character)
    local plan = addon.Plans.ForLevel(level)

    if not plan then
        addon.Print("Level data unavailable; cannot select a progression plan.")
        return
    end

    addon.Print(string.format("%s level %d: %s.",
        character.name or "Warrior", level, plan.title))
    addon.Print("Combat: " .. plan.combat)
    addon.Print("Dungeon: " .. plan.dungeon)
    addon.Print("Professions: " .. plan.professions)
    addon.Print("Next: " .. plan.nextGoal)
end

local function HandleReadiness(argument)
    if argument == "" then
        addon.RenderReady()
        return
    end
    if argument == "reset" then
        addon.ClearReady()
        addon.Print("Manual readiness marks cleared (session only).")
        return
    end
    local action, number = argument:match("^(done)%s+([1-5])$")
    if not action then
        action, number = argument:match("^(undo)%s+([1-5])$")
    end
    if not action then
        addon.Print("Usage: /fw ready [done <1-5>|undo <1-5>|reset]")
        return
    end
    local index = tonumber(number)
    addon.MarkReady(index, action == "done")
    addon.Print(string.format("Readiness item %d manually %s (session only).",
        index, action == "done" and "checked" or "unchecked"))
end

local function PrintProfessionGoals()
    addon.Print("Profession ideas only; your trained skills and bags are NOT scanned.")
    addon.Print("Gathering: Mining + Herbalism can fund gear and repairs.")
    addon.Print("Crafting alternative: Mining + Blacksmithing only if you choose to train it.")
    addon.Print("Secondary: Fishing + Cooking + First Aid (food, income, survival).")
    addon.Print("Gold: Compare raw materials with finished goods before selling.")
end

--- Handles one player-entered slash command without performing game actions.
--- @param message string|nil Optional text after /fw.
local function HandleSlashCommand(message)
    local command, remainder = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "" or command == "help" then
        PrintHelp()
        return
    end

    if command == "version" and remainder == "" then
        addon.Print("Version " .. addon.version .. " (advisory only)")
        return
    end

    if command == "status" and remainder == "" then
        local status = ForeverCore.GetModuleStatus(MODULE_ID)
        if not status then
            addon.Print("Module not registered.")
            return
        end
        local reason = status.reason and (" (" .. status.reason .. ")") or ""
        addon.Print(MODULE_ID .. ": " .. status.state .. reason)
        return
    end

    if remainder ~= "" and command ~= "ready" then
        addon.Print("Unexpected argument; try /fw for available commands.")
        return
    end

    local character = GetActiveCharacter()
    if not character then
        return
    end

    if command == "plan" then
        PrintPlan(character)
    elseif command == "ready" then
        HandleReadiness(remainder)
    elseif command == "professions" then
        PrintProfessionGoals()
    else
        addon.Print("Unknown command: " .. command)
        PrintHelp()
    end
end

SLASH_FOREVERWARRIOR1 = "/fw"
SlashCmdList.FOREVERWARRIOR = HandleSlashCommand
