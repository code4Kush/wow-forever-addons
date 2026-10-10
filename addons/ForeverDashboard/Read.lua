--[[ Forever Dashboard: on-demand, unprotected frame.
    Installed packs register with Core. Inactive/ineligible packs are hidden.
    No protected combat actions, saved window coordinates or polling.
]]
local _, addon = ...
local window
local label

--- Hides an already-open frame when Core deactivates this pack.
--- This does not attempt to unload Lua or manipulate protected UI.
function addon.Hide()
    if window and window.Hide then
        window:Hide()
    end
end

function addon.Render()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        addon.Print("Dashboard unavailable during combat; try afterward.")
        return
    end
    if type(CreateFrame) ~= "function" or UIParent == nil then
        addon.Print("Frame API unavailable on this client.")
        return
    end

    if not window then
        local success, errorMessage = pcall(function()
            window = CreateFrame("Frame", nil, UIParent)
            window:SetSize(390, 270)
            window:SetPoint("CENTER")
            window:EnableMouse(true)
            window:SetMovable(true)
            window:RegisterForDrag("LeftButton")
            window:SetScript("OnDragStart", function(self)
                if type(InCombatLockdown) ~= "function" or not InCombatLockdown() then
                    self:StartMoving()
                end
            end)
            window:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
            end)
            local background = window:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints(window)
            background:SetColorTexture(0.035, 0.055, 0.085, 0.94)
            label = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetPoint("TOPLEFT", window, "TOPLEFT", 12, -14)
            label:SetWidth(360)
            label:SetJustifyH("LEFT")
            label:SetJustifyV("TOP")
        end)
        if not success then
            window = nil
            addon.Print("Dashboard UI unavailable on this build.")
            return
        end
    elseif window:IsShown() then
        window:Hide()
        addon.Print("Dashboard hidden.")
        return
    end

    local lines = { "Forever Dashboard | character modules" }
    for _, module in ipairs(ForeverCore.ListModules()) do
        if module.active then
            lines[#lines + 1] = module.displayName .. " (" .. module.version .. ")"
        end
    end
    if #lines == 1 then
        lines[2] = "No active optional modules are registered."
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Drag to move; use /fdash again to hide."
    label:SetText(table.concat(lines, "\n"))
    window:Show()
    addon.Print("Dashboard shown.")
end
