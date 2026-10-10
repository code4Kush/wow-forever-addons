--[[
    ForeverProfessions: one-command-at-a-time read-only public interface.

    All game API reads occur only for explicitly requested /fprof,
    /fprof snapshot and /fprof progress commands, never in Core events.
]]
local _, addon = ...

local function PrintHelp()
    addon.Print("Commands: /fprof | snapshot | progress | clear | version | help")
    addon.Print("Skill changes are session-only; missing skills are unknown.")
end

--- Handles one player-entered slash command.
--- @param message string|nil Text following /fprof.
local function Handle(message)
    local command = string.lower((message or ""):match("^%s*(.-)%s*$"))
    if command == "version" then
        addon.Print("Version " .. addon.version)
        return
    end
    if command == "help" then
        PrintHelp()
        return
    end
    if command ~= "" and command ~= "snapshot"
        and command ~= "progress" and command ~= "clear" then
        addon.Print("Usage: /fprof [snapshot|progress|clear|version|help]")
        return
    end

    local status = ForeverCore.GetModuleStatus("professions")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: "
            .. (status and status.state or "not registered") .. ".")
        return
    end

    if command == "" then
        addon.Render()
    elseif command == "snapshot" then
        local count, reason = addon.SaveSnapshot()
        if not count then
            addon.Print(reason)
        else
            addon.Print(string.format(
                "Snapshot saved: %d readable profession(s) (session only).",
                count
            ))
        end
    elseif command == "progress" then
        addon.RenderProgress()
    else
        addon.ClearSnapshot()
        addon.Print("Snapshot cleared (session only).")
    end
end

SLASH_FOREVERPROFESSIONS1 = "/fprof"
SlashCmdList.FOREVERPROFESSIONS = Handle
