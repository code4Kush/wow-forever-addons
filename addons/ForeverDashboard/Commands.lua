--[[
    ForeverDashboard 0.2: one user command per refresh, no polling.
    Legacy /fdash retains show/hide messages and direct Core control.
]]
local _, addon = ...

--- Handle one chat message after /fdash.
--- @param message string|nil Slash arguments from the player.
local function Handle(message)
    local cmd = string.lower((message or ""):match("^%s*(.-)%s*$"))
    if cmd == "version" then
        addon.Print("Version " .. addon.version)
        return
    end
    if cmd == "help" then
        addon.Print("Commands: /fdash | next | prev | status | version | help")
        addon.Print("On-demand, six module rows per page; never polls.")
        return
    end
    if cmd ~= "" and cmd ~= "next" and cmd ~= "prev"
        and cmd ~= "status" then
        addon.Print("Usage: /fdash [next|prev|status|version|help]")
        return
    end

    local status = ForeverCore.GetModuleStatus("dashboard")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: "
            .. (status and status.state or "not registered") .. ".")
        return
    end

    if cmd == "" then
        addon.Render()
    elseif cmd == "status" then
        addon.RenderStatus()
    else
        local direction = cmd == "next" and 1 or -1
        local current, total = addon.ShowPage(direction)
        if current then
            addon.Print(string.format("Dashboard page %d/%d.", current, total))
        end
    end
end

SLASH_FOREVERDASHBOARD1 = "/fdash"
SlashCmdList.FOREVERDASHBOARD = Handle
