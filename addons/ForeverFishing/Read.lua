--[[ Forever Fishing: skill readout only, no automatic catching.
    Locale-aware checks prefer Enum.Profession.Fishing if exposed; otherwise
    English profession name is a best-effort fallback, not proof of absence.
]]
local _, addon = ...
function addon.Render()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        addon.Print("Fishing skill unavailable during combat.")
        return
    end
    local result
    if type(C_TradeSkillUI) == "table"
        and type(C_TradeSkillUI.GetBaseProfessionInfo) == "function" then
        local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
        local fishingId = type(Enum) == "table" and type(Enum.Profession) == "table"
            and Enum.Profession.Fishing or nil
        if ok and type(info) == "table"
            and ((fishingId and info.profession == fishingId)
                or info.professionName == "Fishing") then
            if type(info.skillLevel) == "number"
                and type(info.maxSkillLevel) == "number" then
                result = string.format("%d/%d", info.skillLevel, info.maxSkillLevel)
            end
        end
    end
    if result then
        addon.Print("Fishing: " .. result .. " (open profession window).")
    else
        addon.Print("Fishing skill not readable; open Fishing UI and retry.")
    end
    addon.Print("Catches are NOT tracked; no auto-fishing.")
end
