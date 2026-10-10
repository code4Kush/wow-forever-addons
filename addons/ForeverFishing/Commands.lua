--[[
    ForeverFishing v0.2: on-demand client reads and manual catch notes.

    /ffish skill (alias /ffish) reads profession data only on request;
    all catch commands operate strictly on explicitly entered notes.
]]
local _, addon = ...

local function PrintHelp()
    addon.Print("Commands: /ffish | version | help | log <count> <fish name> | catches | clear")
    addon.Print("Catch counts are manual notes, NOT verified loot or inventory.")
end

--- Handles one separately submitted in-game chat command.
--- @param message string|nil Text following /ffish.
local function Handle(message)
    local cmd = (message or ""):match("^%s*(.-)%s*$")
    local lower = string.lower(cmd)

    if lower == "version" then
        addon.Print("Version " .. addon.version)
        return
    end
    if lower == "help" then
        PrintHelp()
        return
    end

    local mode, count, name
    if lower == "" or lower == "skill" then
        mode = "skill"
    elseif lower == "catches" then
        mode = "catches"
    elseif lower == "clear" then
        mode = "clear"
    elseif lower:sub(1,4) == "log " then
        mode = "log"
        local args = cmd:sub(5)
        local digits, label = args:match("^(%d+)%s+(.+)$")
        if digits and #digits <= 3 then
            count = tonumber(digits)
            name = label
        end
        if not count or not name then
            addon.Print("Usage: /ffish log <1-999> <fish name>")
            return
        end
    else
        addon.Print("Usage: /ffish [skill|version|help|log <count> <fish name>|catches|clear]")
        return
    end

    local status = ForeverCore.GetModuleStatus("fishing")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: "
            .. (status and status.state or "not registered") .. ".")
        return
    end

    if mode == "skill" then
        addon.Render()
    elseif mode == "log" then
        local result, reason = addon.LogCatch(count, name)
        if not result then
            addon.Print(reason)
        else
            addon.Print(string.format(
                "Logged manually: %s +%d (session total: %d).",
                result.name, result.added, result.count
            ))
        end
    elseif mode == "catches" then
        addon.RenderCatches()
    else
        addon.ClearCatches()
        addon.Print("Manual catch log cleared (session only).")
    end
end

SLASH_FOREVERFISHING1 = "/ffish"
SlashCmdList.FOREVERFISHING = Handle
