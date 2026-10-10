--[[ Forever Inventory: live, on-demand bag counts only.
    The API can be unavailable or return nil; empty slots are not items.
    Does not persist inventory, vendor anything or infer market prices.
]]
local _, addon = ...

function addon.Render()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        addon.Print("Inventory unavailable during combat.")
        return
    end
    if type(C_Container) ~= "table"
        or type(C_Container.GetContainerNumSlots) ~= "function"
        or type(C_Container.GetContainerItemInfo) ~= "function" then
        addon.Print("Bag API unavailable on this build.")
        return
    end
    local ok, slots, occupied, quantity = pcall(function()
        local all, filled, count = 0, 0, 0
        -- Backpack=0, up to four equipped bags. No bank/reagent bag scan.
        for bag = 0, 4 do
            local size = C_Container.GetContainerNumSlots(bag)
            if type(size) ~= "number" or size < 0 or size > 200 then
                error("invalid bag capacity")
            end
            all = all + size
            for slot = 1, size do
                local item = C_Container.GetContainerItemInfo(bag, slot)
                if item then
                    filled = filled + 1
                    if type(item.stackCount) ~= "number" then
                        error("unavailable item stack count")
                    end
                    count = count + item.stackCount
                end
            end
        end
        return all, filled, count
    end)
    if not ok then
        addon.Print("Bag counts unavailable; no totals were inferred.")
        return
    end
    addon.Print(string.format(
        "Bags 0-4: %d/%d occupied slots; %d total items (not AH prices).",
        occupied, slots, quantity))
end
