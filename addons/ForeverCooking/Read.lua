--[[ Forever Cooking: skill readout only, no recipe/crafting claims.
    Profession data may only be available with its trade skill UI open.
]]
local _, addon = ...
function addon.Render()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        addon.Print("Cooking skill unavailable during combat.")
        return
    end
    local result
    if type(C_TradeSkillUI) == "table"
        and type(C_TradeSkillUI.GetBaseProfessionInfo) == "function" then
        local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
        local cookingId = type(Enum) == "table" and type(Enum.Profession) == "table"
            and Enum.Profession.Cooking or nil
        if ok and type(info) == "table"
            and ((cookingId and info.profession == cookingId)
                or info.professionName == "Cooking") then
            if type(info.skillLevel) == "number"
                and type(info.maxSkillLevel) == "number" then
                result = string.format("%d/%d", info.skillLevel, info.maxSkillLevel)
            end
        end
    end
    if result then
        addon.Print("Cooking: " .. result .. " (open profession window).")
    else
        addon.Print("Cooking skill not readable; open Cooking UI and retry.")
    end
    addon.Print("Recipes and ingredient counts are NOT scanned.")
end
