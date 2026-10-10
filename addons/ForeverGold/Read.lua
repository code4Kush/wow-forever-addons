--[[ Forever Gold: live wallet only, zero storage and no inferred income.
    Values are copper units from the game's GetMoney API.
]]
local _, addon = ...

function addon.Render()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        addon.Print("Wallet unavailable during combat.")
        return
    end
    if type(GetMoney) ~= "function" then
        addon.Print("Wallet API unavailable on this build.")
        return
    end
    local success, copper = pcall(GetMoney)
    if not success or type(copper) ~= "number" or copper < 0 then
        addon.Print("Wallet value unavailable.")
        return
    end
    local gold = math.floor(copper / 10000)
    local silver = math.floor(copper / 100) % 100
    local remaining = copper % 100
    addon.Print(string.format(
        "Wallet: %dg %ds %dc (current character; not earnings).",
        gold, silver, remaining))
end
