--[[
    Full WoW Forever modular-suite boot test, on Lua 5.1 mocks.

    Loads all 12 actual _Camelot.toc manifests in declared order, exactly
    as separate addons (one namespace per folder). This catches file-order
    mistakes, cross-module namespace collisions, Core contract mistakes,
    unsolicited network sends, and baseline command integration errors.

    NOT a live beta API test, FPS metric, or public release authorization.
]]
local originalPrint = print
local logs = {}
print = function(line) logs[#logs + 1] = tostring(line) end
local function clear() logs = {} end
local function has(part)
    return table.concat(logs, "\n"):find(part, 1, true) ~= nil
end
local function expect(value, reason) assert(value, reason) end

-- Every WoW frame is independent: Core handles shared subscribed events,
-- Journal retains its own one-shot login flag and Dashboard creates a
-- separate frame on the first /fdash command.
local frames, fontStrings = {}, 0
local function NewFrame()
    local f = { events = {}, callbacks = {}, shown = false }
    function f:RegisterEvent(event) self.events[event] = true end
    function f:UnregisterEvent(event) self.events[event] = nil end
    function f:SetScript(event, callback)
        expect(event ~= "OnUpdate", "No per-frame background callbacks")
        self.callbacks[event] = callback
    end
    function f:Fire(event, ...)
        if self.events[event] and self.callbacks.OnEvent then
            self.callbacks.OnEvent(self, event, ...)
        end
    end
    function f:SetSize(...) end
    function f:SetPoint(...) end
    function f:EnableMouse(...) end
    function f:SetMovable(...) end
    function f:RegisterForDrag(...) end
    function f:StartMoving(...) end
    function f:StopMovingOrSizing(...) end
    function f:IsShown() return self.shown end
    function f:Show() self.shown = true end
    function f:Hide() self.shown = false end
    function f:CreateTexture()
        return {
            SetAllPoints = function() end,
            SetColorTexture = function() end,
        }
    end
    function f:CreateFontString()
        fontStrings = fontStrings + 1
        return {
            SetPoint = function() end,
            SetWidth = function() end,
            SetJustifyH = function() end,
            SetJustifyV = function() end,
            SetText = function(self, text) self.text = text end,
        }
    end
    frames[#frames + 1] = f
    return f
end
CreateFrame = function() return NewFrame() end
UIParent = {}

UnitName = function() return "Uddergrief" end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitRace = function() return "Tauren", "Tauren" end
UnitLevel = function() return 7 end
UnitGUID = function() return "Player-Test-1" end
GetRealmName = function() return "MockRealm" end
GetTime = function() return 100 end
InCombatLockdown = function() return false end
IsInGuild = function() return true end

local calls = {money=0, skills=0, bags=0, refresh=0, memory=0, sent=0}
GetMoney = function()
    calls.money = calls.money + 1
    return 20234
end
GetProfessions = function()
    calls.skills = calls.skills + 1
    return 1, 2, 3, 4, 5
end
local skills = {
    {"Herbalism",2,75}, {"Mining",19,75}, {"First Aid",1,75},
    {"Fishing",2,75}, {"Cooking",1,75},
}
GetProfessionInfo = function(slot)
    local row = skills[slot]
    if row then return row[1],nil,row[2],row[3] end
end
C_TradeSkillUI = {
    GetBaseProfessionInfo = function()
        return {professionName="Fishing",skillLevel=2,maxSkillLevel=75}
    end,
}
C_Container = {
    GetContainerNumSlots = function(bag)
        calls.bags = calls.bags + 1
        return bag == 0 and 2 or 0
    end,
    GetContainerItemInfo = function(bag, slot)
        if bag == 0 and slot == 1 then return {stackCount=2} end
    end,
}
C_Map = {
    GetBestMapForUnit = function() return 1412 end,
    GetMapInfo = function() return {name="Mulgore"} end,
}
C_ChatInfo = {
    RegisterAddonMessagePrefix = function(prefix)
        expect(prefix == "FVRGUILD1", "Only bounded guild prefix")
        return 0
    end,
    SendAddonMessage = function()
        calls.sent = calls.sent + 1
        return 0
    end,
}
UpdateAddOnMemoryUsage = function()
    calls.refresh = calls.refresh + 1
end
GetAddOnMemoryUsage = function(name)
    expect(name:match("^Forever%w+$"), "Known addon memory names only")
    calls.memory = calls.memory + 1
    return 1
end

ForeverCharacterDB = nil
SlashCmdList = {}
local namespaces = {}
local modules = {
    "ForeverCore",
    "ForeverCooking",
    "ForeverDashboard",
    "ForeverExplorer",
    "ForeverFishing",
    "ForeverGold",
    "ForeverGuild",
    "ForeverInventory",
    "ForeverJournal",
    "ForeverPerformance",
    "ForeverProfessions",
    "ForeverWarrior",
}
local sourceFiles = 0
for _, name in ipairs(modules) do
    local dir = "addons/" .. name
    local toc = dir .. "/" .. name .. "_Camelot.toc"
    local ns = {}
    namespaces[name] = ns
    local names = {}
    for line in io.lines(toc) do
        if line:match("%.lua%s*$") and not line:match("^%s*#") then
            local relative = line:match("^%s*(.-)%s*$")
            names[#names + 1] = relative
        end
    end
    expect(#names >= 4, name .. " TOC unexpectedly empty")
    for _, file in ipairs(names) do
        assert(loadfile(dir .. "/" .. file))(name, ns)
        sourceFiles = sourceFiles + 1
    end
end
local core = namespaces.ForeverCore
expect(ForeverCore == core, "Only Core exports shared global")
expect(#core.ListModules() == 11,
    "Every one of 11 optional addons registers with Core")
expect(#frames == 2, "Core and Journal event frames only at load")
expect(fontStrings == 0, "Dashboard must not allocate UI on load")
expect(#logs == 0, "No unsolicited chat during initial load")
expect(calls.money == 0 and calls.skills == 0 and calls.bags == 0
    and calls.refresh == 0 and calls.memory == 0 and calls.sent == 0,
    "No implicit gameplay/memory reads or network send at load")

for _, frame in ipairs(frames) do
    frame:Fire("PLAYER_LOGIN")
end
expect(#core.ListModules() == 11, "Core retains all registered packs")
for _, module in ipairs(core.ListModules()) do
    expect(module.state == "active" and module.active,
        "Expected active module after Tauren Warrior login: " .. module.id)
end
expect(core.GetSubscriberCount("CHAT_MSG_ADDON") == 1,
    "Only Guild uses Core's addon chat event on full profile")
expect(calls.sent == 0 and calls.money == 0,
    "Login must not send messages or read player wallet")

for _, value in ipairs({
    "FOREVERCORE", "FOREVERCOOKING", "FOREVERDASHBOARD",
    "FOREVEREXPLORER", "FOREVERFISHING", "FOREVERGOLD",
    "FOREVERGUILD", "FOREVERINVENTORY", "FOREVERJOURNAL",
    "FOREVERPERFORMANCE", "FOREVERPROFESSIONS", "FOREVERWARRIOR",
}) do
    expect(type(SlashCmdList[value]) == "function",
        "Expected command registration: " .. value)
end

clear(); SlashCmdList.FOREVERCORE("modules")
expect(has("11 registered module(s)."), "Full profile Core registry")

clear(); SlashCmdList.FOREVERDASHBOARD("status")
expect(has("11 registered module(s); 11 active."),
    "Dashboard reports full independently loaded pack set")
expect(#frames == 2, "Dashboard status creates no window")

clear(); SlashCmdList.FOREVERDASHBOARD("")
expect(has("Dashboard shown.") and #frames == 3,
    "Lazy Dashboard creates one frame only when opened")
expect(fontStrings == 1, "Exactly one Dashboard label")
clear(); SlashCmdList.FOREVERDASHBOARD("next")
expect(has("Dashboard page 2/2."), "11 independent packs paginate")
clear(); SlashCmdList.FOREVERDASHBOARD("")
expect(has("Dashboard hidden.") and not frames[3].shown,
    "Toggle hides Dashboard")
SlashCmdList.FOREVERDASHBOARD("")
expect(#frames == 3 and fontStrings == 1,
    "Repeated Dashboard open reuses its original UI")

clear(); SlashCmdList.FOREVERWARRIOR("plan")
expect(has("Mulgore foundations"), "Warrior plan from independent module")
clear(); SlashCmdList.FOREVERJOURNAL("version")
expect(has("Version 0.5.0"), "Journal bridge loads with Core")
clear(); SlashCmdList.FOREVERGOLD("")
expect(has("Wallet: 2g 2s 34c"), "Gold reads correctly on request")
clear(); SlashCmdList.FOREVERINVENTORY("")
expect(has("Bags 0-4: 1/2 occupied slots; 2 total items"),
    "Inventory reads mock bags on request")
clear(); SlashCmdList.FOREVERPROFESSIONS("")
expect(has("Herbalism 2/75") and has("Fishing 2/75")
    and has("Cooking 1/75"), "Five bounded professions displayed")
clear(); SlashCmdList.FOREVERFISHING("catches")
expect(has("No manual catches logged."), "Fishing manual log starts empty")
clear(); SlashCmdList.FOREVERFISHING("")
expect(has("Fishing: 2/75 (profession list)."),
    "Fishing reads profession list without profession UI dependency")
clear(); SlashCmdList.FOREVERCOOKING("version")
expect(has("Version 0.2.0"), "Cooking works independently")
clear(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking: 1/75 (profession list)."),
    "Cooking reads profession list independent of other optional packs")
clear(); SlashCmdList.FOREVERCOOKING("need 2 Raw Brilliant Smallfish")
expect(has("Planned manually: Raw Brilliant Smallfish +2"),
    "Cooking accepts human-entered ingredient note")
clear(); SlashCmdList.FOREVERCOOKING("needs")
expect(has("Raw Brilliant Smallfish: need 2 (player-entered)."),
    "Cooking list never claims actual bag contents")
clear(); SlashCmdList.FOREVEREXPLORER("")
expect(has("Mulgore"), "Explorer respects local map API")
clear(); SlashCmdList.FOREVERPERFORMANCE("details")
expect(has("12 known loaded pack(s), 12.00 KB total"),
    "Performance counts Core plus all 11 independent packs")
expect(calls.refresh == 1 and calls.memory == 12,
    "Exactly one on-demand memory refresh and one read per pack")

-- Guild has no outbound activity without an explicit opt-in + announce.
clear(); SlashCmdList.FOREVERGUILD("status")
expect(has("Sharing: OFF"), "Full profile starts with no sharing consent")
-- One-subscriber events must avoid allocating/sorting an ID list for
-- every incoming addon message while default Guild consent is OFF.
local previousSort, sortCalls = table.sort, 0
table.sort = function(...)
    sortCalls = sortCalls + 1
    return previousSort(...)
end
frames[1]:Fire("CHAT_MSG_ADDON", "FVRGUILD1",
    "HELLO|0.1.0", "GUILD", "AnotherPlayer")
table.sort = previousSort
expect(sortCalls == 0, "Single subscriber event never needs sorting")
expect(#namespaces.ForeverGuild.GetPeers() == 0,
    "Incoming Guild event cannot record unconsented player data")
clear(); SlashCmdList.FOREVERGUILD("announce")
expect(has("Opt in first") and calls.sent == 0,
    "Guild message cannot be sent without player consent")

-- Logical disable blocks optional commands, keeps all other modules.
core.SetModuleEnabled("fishing", false)
clear(); SlashCmdList.FOREVERFISHING("catches")
expect(has("Module not active: disabled."),
    "Core disable isolates Fishing without affecting Dashboard")
expect(core.GetModuleStatus("gold").state == "active",
    "Other optional packs unaffected by logical disable")
core.SetModuleEnabled("fishing", true)
expect(core.GetModuleStatus("fishing").state == "active",
    "Independently re-enabled pack restores correctly")

print = originalPrint
print("Full modular-suite TOC load/registry/consent integration mocks passed ("
    .. sourceFiles .. " Lua sources; " .. #modules .. " folders).")
