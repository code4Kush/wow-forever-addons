--[[
    ForeverCooking v0.2: user-invoked readout and manual ingredient plan.
    No game actions are performed; only /fcook requests can read skills.
]]
local _, addon = ...

local function PrintHelp()
    addon.Print("Commands: /fcook | skill | need <count> <ingredient> | needs | clear | version | help")
    addon.Print("Ingredient plan is manual, NOT confirmed bags or recipes.")
end

--- Handle one slash command; inactive Core module blocks data access.
--- @param message string|nil Text after /fcook.
local function Handle(message)
    local cmd = (message or ""):match("^%s*(.-)%s*$")
    local lower = string.lower(cmd)
    if lower == "version" then
        addon.Print("Version " .. addon.version)
        return
    elseif lower == "help" then
        PrintHelp()
        return
    end

    local mode = lower
    local count, name
    if lower:sub(1,5) == "need " then
        mode = "need"
        local digits, label = cmd:sub(6):match("^(%d+)%s+(.+)$")
        if digits and #digits <= 3 then
            count, name = tonumber(digits), label
        end
        if not count or not name then
            addon.Print("Usage: /fcook need <1-999> <ingredient name>")
            return
        end
    elseif lower ~= "" and lower ~= "skill" and lower ~= "needs"
        and lower ~= "clear" then
        addon.Print("Usage: /fcook [skill|need <count> <ingredient>|needs|clear|version|help]")
        return
    end

    local status = ForeverCore.GetModuleStatus("cooking")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: "
            .. (status and status.state or "not registered") .. ".")
        return
    end
    if mode == "" or mode == "skill" then
        addon.Render()
    elseif mode == "need" then
        local entry, reason = addon.AddNeed(count, name)
        if not entry then
            addon.Print(reason)
        else
            addon.Print(string.format(
                "Planned manually: %s +%d (need %d).",
                entry.name, entry.added, entry.count))
        end
    elseif mode == "needs" then
        addon.RenderNeeds()
    else
        addon.ClearNeeds()
        addon.Print("Manual ingredient plan cleared (session only).")
    end
end

SLASH_FOREVERCOOKING1 = "/fcook"
SlashCmdList.FOREVERCOOKING = Handle
