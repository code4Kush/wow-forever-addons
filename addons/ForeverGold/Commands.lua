--[[
    Forever Gold: one-player-command-per-sample chat interface.

    No polling, automatic financial transactions or background memory use.
    Version/help remain available when Core disables the module.
]]
local _, addon = ...

local function Help()
    addon.Print("Commands: /fgold | baseline | delta | clear | version | help")
    addon.Print("Net wallet change is NOT profit; tracking is session only.")
end

--- Handles one individually entered WoW slash command.
--- @param message string|nil Text following /fgold.
local function Handle(message)
    local cmd = string.lower((message or ""):match("^%s*(.-)%s*$"))
    if cmd == "version" then
        addon.Print("Version " .. addon.version)
        return
    end
    if cmd == "help" then
        Help()
        return
    end
    if cmd ~= "" and cmd ~= "baseline" and cmd ~= "delta"
        and cmd ~= "clear" then
        addon.Print("Usage: /fgold [baseline|delta|clear|version|help]")
        return
    end

    local status = ForeverCore.GetModuleStatus("gold")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: "
            .. (status and status.state or "not registered") .. ".")
        return
    end

    if cmd == "" then
        addon.Render()
    elseif cmd == "baseline" then
        local copper, reason = addon.SaveBaseline()
        if copper == nil then
            addon.Print(reason)
        else
            addon.Print("Baseline saved: " .. addon.FormatCopper(copper)
                .. " (session only).")
        end
    elseif cmd == "delta" then
        local result, reason = addon.GetDelta()
        if not result then
            addon.Print(reason)
            return
        end
        addon.Print("Wallet change: " .. addon.FormatDelta(result.delta)
            .. " (was " .. addon.FormatCopper(result.before)
            .. "; now " .. addon.FormatCopper(result.now)
            .. "; net balance, NOT profit).")
    else
        addon.ClearBaseline()
        addon.Print("Baseline cleared (session only).")
    end
end

SLASH_FOREVERGOLD1 = "/fgold"
SlashCmdList.FOREVERGOLD = Handle
