--[[
    Forever Gold: manual wallet comparison only.

    Only a single number is held in Lua memory until clear, disable or
    client reload. No SavedVariables, events, timers, transaction records,
    economic recommendations or external data sharing. Net wallet change
    includes spending and transfers and is NOT earned gold/profit.
]]
local _, addon = ...
local baselineCopper

--- Takes a baseline only when the player explicitly asks.
--- @return number|nil copper Starting balance.
--- @return string|nil reason Failure if wallet API unavailable.
function addon.SaveBaseline()
    local value, reason = addon.ReadCopper()
    if value == nil then
        return nil, reason
    end
    baselineCopper = value
    return value
end

--- Discards the session-only baseline without any game API calls.
function addon.ClearBaseline()
    baselineCopper = nil
end

--- Compares live wallet to baseline, without inferring income or expenses.
--- @return table|nil result With before, now and signed delta in copper.
--- @return string|nil reason If baseline or wallet unavailable.
function addon.GetDelta()
    if baselineCopper == nil then
        return nil, "No baseline. Use /fgold baseline first."
    end
    local current, reason = addon.ReadCopper()
    if current == nil then
        return nil, reason
    end
    return {
        before = baselineCopper,
        now = current,
        delta = current - baselineCopper,
    }
end

--- Signed change formatted separately from a nonnegative wallet amount.
--- @param copperDelta number Signed copper difference.
--- @return string formatted +Xg Ys Zc or -Xg Ys Zc.
function addon.FormatDelta(copperDelta)
    return (copperDelta < 0 and "-" or "+")
        .. addon.FormatCopper(math.abs(copperDelta))
end
