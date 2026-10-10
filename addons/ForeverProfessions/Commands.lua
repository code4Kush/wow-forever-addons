--[[ ForeverProfessions: on-demand, independent slash command.
    Output is generated only for an active Core module.
]]
local _, addon = ...

--- Handles a single player-entered command; does not automate gameplay.
--- @param message string|nil Chat text after /fprof.
local function Handle(message)
    local cmd = (message or ""):match("^%s*(.-)%s*$")
    if cmd == "version" then
        addon.Print("Version " .. addon.version)
        return
    end
    if cmd == "help" then
        addon.Print("Commands: /fprof | /fprof version | /fprof help")
        return
    end
    if cmd ~= "" then
        addon.Print("Usage: /fprof [version|help]")
        return
    end

    local status = ForeverCore.GetModuleStatus("professions")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: " .. (status and status.state or "not registered") .. ".")
        return
    end
    addon.Render()
end
SLASH_FOREVERPROFESSIONS1 = "/fprof"
SlashCmdList.FOREVERPROFESSIONS = Handle
