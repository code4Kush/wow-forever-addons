--[[
    Forever Gold 0.2: read-only player wallet adapter.

    GetMoney() is a conventional WoW API returning copper. Some Forever
    beta builds may return nil or protected values. Never infer unknown=0,
    treat any invalid input as unavailable, and never mutate game money.
]]
local _, addon = ...
local MAX_EXACT_COPPER = 9007199254740991

--- Returns one valid whole copper reading, or an unavailable diagnostic.
--- @return number|nil copper Nonnegative integer, or nil on failure.
--- @return string|nil reason Safe player-visible reason for failure.
function addon.ReadCopper()
    if type(InCombatLockdown) == "function" then
        local ok, inCombat = pcall(InCombatLockdown)
        if not ok or inCombat then
            return nil, "Wallet unavailable during combat."
        end
    end
    if type(GetMoney) ~= "function" then
        return nil, "Wallet API unavailable on this build."
    end
    local ok, value = pcall(function()
        local amount = GetMoney()
        if type(amount) ~= "number" or amount < 0
            or amount > MAX_EXACT_COPPER or amount ~= amount
            or amount == math.huge or math.floor(amount) ~= amount then
            return nil
        end
        return amount
    end)
    if not ok or value == nil then
        return nil, "Wallet value unavailable."
    end
    return value
end

--- Formats nonnegative whole copper as gold/silver/copper.
--- @param copper number Nonnegative integer returned by ReadCopper.
--- @return string formatted Xg Ys Zc.
function addon.FormatCopper(copper)
    return string.format("%dg %ds %dc", math.floor(copper / 10000),
        math.floor(copper / 100) % 100, copper % 100)
end

--- Preserves the original /fgold wallet display.
function addon.Render()
    local copper, reason = addon.ReadCopper()
    if copper == nil then
        addon.Print(reason)
        return
    end
    addon.Print("Wallet: " .. addon.FormatCopper(copper)
        .. " (current character; not earnings).")
end
