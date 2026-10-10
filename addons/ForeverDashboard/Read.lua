--[[
    ForeverDashboard v0.2: one lazy unprotected frame/label, paginated
    Core registry snapshots. No timers, OnUpdate, game events or polling.

    Core-disable does not unload already executed Lua; inactive modules
    therefore remain visible by state rather than being hidden as absent.
]]
local _, addon = ...
local PAGE_SIZE = 6
local window, label
local page = 1

--- Hides the existing frame without allocating or reading game data.
function addon.Hide()
    if window and window.Hide then
        window:Hide()
    end
end

local function Allowed()
    if type(InCombatLockdown) == "function" then
        local ok, combat = pcall(InCombatLockdown)
        if not ok or combat then
            addon.Print("Dashboard unavailable during combat; try afterward.")
            return false
        end
    end
    return true
end

local function ReadModules()
    local ok, modules = pcall(ForeverCore.ListModules)
    if not ok or type(modules) ~= "table" then
        addon.Print("Module registry unavailable on this build.")
        return nil
    end
    return modules
end

local function EnsureWindow()
    if window then return true end
    if type(CreateFrame) ~= "function" or UIParent == nil then
        addon.Print("Frame API unavailable on this client.")
        return false
    end
    local ok = pcall(function()
        window = CreateFrame("Frame", nil, UIParent)
        window:SetSize(390, 270)
        window:SetPoint("CENTER")
        window:EnableMouse(true)
        window:SetMovable(true)
        window:RegisterForDrag("LeftButton")
        -- Event handlers are allocated once, on initial UI creation only.
        window:SetScript("OnDragStart", function(self)
            if type(InCombatLockdown) ~= "function" then
                self:StartMoving()
            else
                local passed, combat = pcall(InCombatLockdown)
                if passed and not combat then self:StartMoving() end
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
    if not ok then
        window, label = nil, nil
        addon.Print("Dashboard UI unavailable on this build.")
        return false
    end
    return true
end

--- Show at most six module rows and reuse one existing font string.
--- @param direction number Move page by -1, 0, or 1, clamped to bounds.
--- @return number|nil pageNumber Valid page on success, nil on failure.
--- @return number|nil pageCount Total pages on success.
function addon.ShowPage(direction)
    if not Allowed() then return nil end
    local modules = ReadModules()
    if not modules or not EnsureWindow() then return nil end

    local pages = math.max(1, math.ceil(#modules / PAGE_SIZE))
    page = math.max(1, math.min(pages, page + direction))
    local lines = {
        string.format("Forever Dashboard | Modules %d/%d", page, pages), "",
    }
    local last = math.min(#modules, page * PAGE_SIZE)
    for index = (page - 1) * PAGE_SIZE + 1, last do
        local module = modules[index]
        lines[#lines + 1] = string.format("%s v%s [%s]",
            tostring(module.displayName or module.id or "?"):sub(1, 32),
            tostring(module.version or "?"),
            tostring(module.state or "unknown"))
    end
    if #modules == 0 then
        lines[#lines + 1] = "No registered optional modules."
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Use /fdash next | prev | status"
    lines[#lines + 1] = "Manage with /forever modules | enable/disable <id>"
    label:SetText(table.concat(lines, "\n"))
    window:Show()
    return page, pages
end

--- Preserves original /fdash show/hide behavior and exact chat outputs.
function addon.Render()
    if not Allowed() then return end
    if window and window.IsShown and window:IsShown() then
        addon.Hide()
        addon.Print("Dashboard hidden.")
        return
    end
    if addon.ShowPage(0) then
        addon.Print("Dashboard shown.")
    end
end

--- Summarizes only the Core registry; never instantiates a GUI frame.
function addon.RenderStatus()
    if not Allowed() then return end
    local modules = ReadModules()
    if not modules then return end
    local active = 0
    for _, module in ipairs(modules) do
        if module.state == "active" then active = active + 1 end
    end
    addon.Print(string.format(
        "%d registered module(s); %d active. (Core logical disabling does not unload Lua.)",
        #modules, active))
end
