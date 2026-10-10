--[[ ForeverCooking: on-demand, independent slash command.
    Output is generated only for an active Core module.
]]
local _, addon = ...

--- Handles a single player-entered command; does not automate gameplay.
--- @param message string|nil Chat text after /fcook.
local function Handle(message)
    local cmd = (message or ""):match("^%s*(.-)%s*$")
    if cmd == "version" then
        addon.Print("Version " .. addon.version)
        return
    end
    if cmd == "help" then
        addon.Print("Commands: /fcook | /fcook version | /fcook help")
        return
    end
    if cmd ~= "" then
        addon.Print("Usage: /fcook [version|help]")
        return
    end

    local status = ForeverCore.GetModuleStatus("cooking")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: " .. (status and status.state or "not registered") .. ".")
        return
    end
    addon.Render()
end
SLASH_FOREVERCOOKING1 = "/fcook"
SlashCmdList.FOREVERCOOKING = Handle
