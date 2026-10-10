--[[
    Forever Journal: Commands
    Parses user chat commands and delegates calculations to the Progress
    module. This file is loaded after the module in the TOC.
]]

local _, addon = ...

local function PrintHelp()
    addon.Print("Commands: /fj, /fj version, /fj progress <completed> <total>")
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

    addon.Print("Unknown command: " .. command)
    PrintHelp()
end

SLASH_FOREVERJOURNAL1 = "/fj"
SlashCmdList.FOREVERJOURNAL = HandleSlashCommand
