--[[
    Deterministic standalone Lua 5.1 suite integration tests.
    All game APIs are mocks. These checks DO NOT prove client compatibility.
]]
local savedPrint = print
local output = {}
print = function(v) output[#output + 1] = tostring(v) end
local function expect(value, reason) assert(value, reason) end
local function has(value) return table.concat(output, "\n"):find(value, 1, true) ~= nil end
local function reset() output = {} end
local function load(path, name, space) assert(loadfile(path))(name, space) end

local frame = { events = {} }
function frame:RegisterEvent(event) self.events[event] = true end
function frame:UnregisterEvent(event) self.events[event] = nil end
function frame:SetScript(_, cb) self.handler = cb end
function frame:Fire(event, ...)
    expect(self.events[event], "unexpected game event " .. event)
    self.handler(self, event, ...)
end
local visual = {}
for _, key in ipairs({ "SetSize", "SetPoint", "EnableMouse", "SetMovable",
    "RegisterForDrag", "SetScript", "StartMoving", "StopMovingOrSizing" }) do
    visual[key] = function() end
end
visual.CreateTexture = function()
    return { SetAllPoints = function() end, SetColorTexture = function() end }
end
visual.CreateFontString = function()
    return { SetPoint = function() end, SetWidth = function() end,
        SetJustifyH = function() end, SetJustifyV = function() end,
        SetText = function(self, value) self.text = value end }
end
visual.IsShown = function(self) return self.shown end
visual.Show = function(self) self.shown = true end
visual.Hide = function(self) self.shown = false end
UIParent = {}
CreateFrame = function()
    if not frame.initialized then frame.initialized = true; return frame end
    return visual
end
UnitName = function() return "Uddergrief" end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitRace = function() return "Tauren", "Tauren" end
UnitLevel = function() return 6 end
UnitGUID = function() return "Player-1-Test" end
GetRealmName = function() return "TestRealm" end
GetMoney = function() return 123456 end
GetTime = function() return 100 end
InCombatLockdown = function() return false end
IsInGuild = function() return true end
GetProfessions = function() return 1,2,3,4 end
GetProfessionInfo = function(slot)
    local items = {{"Mining",30,75},{"Blacksmithing",20,75},
                   {"Fishing",40,75},{"Cooking",22,75}}
    local r = items[slot]
    if r then return r[1], nil, r[2], r[3] end
end
C_TradeSkillUI = { GetBaseProfessionInfo = function()
    return { professionName = "Fishing", skillLevel = 40, maxSkillLevel = 75 }
end }
C_Container = {
    GetContainerNumSlots = function(bag) return bag == 0 and 2 or 0 end,
    GetContainerItemInfo = function(bag, slot)
        if bag == 0 and slot == 1 then return { stackCount = 4 } end
    end,
}
C_Map = { GetBestMapForUnit = function() return 1412 end,
    GetMapInfo = function() return { name = "Mulgore" } end }
local sent = {}
C_ChatInfo = {
    RegisterAddonMessagePrefix = function(p)
        expect(p == "FVRGUILD1", "wrong guild prefix")
        return 0
    end,
    SendAddonMessage = function(prefix, message, channel)
        sent[#sent+1] = {prefix, message, channel}
        return 0
    end,
}
SlashCmdList = {}
ForeverCharacterDB = nil
local core = {}
for _, file in ipairs({"Bootstrap.lua","Character.lua","Profile.lua",
    "Registry.lua","Events.lua","Commands.lua"}) do
    load("addons/ForeverCore/" .. file, "ForeverCore", core)
end
local packs = {"ForeverDashboard","ForeverInventory","ForeverGold",
    "ForeverProfessions","ForeverFishing","ForeverCooking",
    "ForeverExplorer","ForeverGuild"}
for _, name in ipairs(packs) do
    local files = {"Bootstrap.lua","Module.lua","Read.lua","Commands.lua"}
    if name == "ForeverGuild" then
        files = {"Bootstrap.lua","Protocol.lua","Module.lua","Commands.lua"}
    end
    local ns = {}
    for _, file in ipairs(files) do
        load("addons/" .. name .. "/" .. file, name, ns)
    end
end
expect(#core.ListModules() == 8, "8 independent modules register")
frame:Fire("PLAYER_LOGIN")
expect(core.GetModuleStatus("guild").active, "guild pack registers")
reset(); SlashCmdList.FOREVERCORE("version")
expect(has("Version 0.2.0"), "core version")
reset(); SlashCmdList.FOREVERCORE("profile")
expect(has("schema 1: writable (restart unverified)"), "profile caveat")
reset(); SlashCmdList.FOREVERCORE("marker test123")
expect(ForeverCharacterDB.testMarker == "test123", "profile marker")
reset(); SlashCmdList.FOREVERCORE("pref gold off")
expect(ForeverCharacterDB.modules.gold == false, "per-char preference")
expect(core.GetModuleStatus("gold").state == "disabled", "saved preference applied")
reset(); SlashCmdList.FOREVERGOLD("")
expect(has("Module not active: disabled"), "disabled feature does not run")
SlashCmdList.FOREVERCORE("pref gold on")
reset(); SlashCmdList.FOREVERGOLD("")
expect(has("Wallet: 12g 34s 56c"), "wallet conversion")
reset(); SlashCmdList.FOREVERINVENTORY("")
expect(has("Bags 0-4: 1/2 occupied slots; 4 total items"), "bag totals")
reset(); SlashCmdList.FOREVERPROFESSIONS("")
expect(has("Mining 30/75") and has("Cooking 22/75"), "profession skills")
reset(); SlashCmdList.FOREVERFISHING("")
expect(has("Fishing: 40/75"), "fishing skill from profession window")
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking skill not readable"), "no false cooking from fishing window")
C_TradeSkillUI.GetBaseProfessionInfo = function()
    return {professionName="Cooking",skillLevel=22,maxSkillLevel=75}
end
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking: 22/75"), "cooking skill from profession window")
reset(); SlashCmdList.FOREVEREXPLORER("")
expect(has("Mulgore (ID 1412); NOT exploration credit."), "no fake map completion")
reset(); SlashCmdList.FOREVERDASHBOARD("")
expect(has("Dashboard shown.") and visual.shown, "dashboard shown")
reset(); SlashCmdList.FOREVERDASHBOARD("")
expect(has("Dashboard hidden.") and not visual.shown, "dashboard hidden")
reset(); SlashCmdList.FOREVERGUILD("status")
expect(has("Sharing: OFF"), "guild default no consent")
reset(); SlashCmdList.FOREVERGUILD("announce")
expect(has("Opt in first") and #sent == 0, "no messages without consent")
reset(); SlashCmdList.FOREVERGUILD("optin")
expect(has("Nothing sent") and #sent == 0, "optin does not broadcast")
reset(); SlashCmdList.FOREVERGUILD("announce")
expect(has("delivery not confirmed") and #sent == 1, "manual announce")
expect(sent[1][2] == "HELLO|0.1.0" and sent[1][3] == "GUILD", "version-only payload")
reset(); SlashCmdList.FOREVERGUILD("announce")
expect(has("Rate limited") and #sent == 1, "anti-spam throttle")
frame:Fire("CHAT_MSG_ADDON","FVRGUILD1","HELLO|0.1.0","GUILD","Tankmate-Realm")
frame:Fire("CHAT_MSG_ADDON","FVRGUILD1","GARBAGE","GUILD","Badmate-Realm")
frame:Fire("CHAT_MSG_ADDON","FVRGUILD1","HELLO|0.1.0","PARTY","Othermate-Realm")
reset(); SlashCmdList.FOREVERGUILD("peers")
expect(has("1 recent compatible announcer(s).") and has("Tankmate-Realm"),
    "only valid guild message counted")
core.SetModuleEnabled("guild",false)
reset(); SlashCmdList.FOREVERGUILD("status")
expect(has("Module not active: disabled"),"disabled guild cannot reply")
core.SetModuleEnabled("guild",true)
reset(); SlashCmdList.FOREVERGUILD("status")
expect(has("Sharing: OFF"), "no consent survives disable/enable")
GetMoney = nil
reset(); SlashCmdList.FOREVERGOLD("")
expect(has("Wallet API unavailable"), "nil API handled safely")
C_Map = nil
reset(); SlashCmdList.FOREVEREXPLORER("")
expect(has("Map API unavailable"), "nil C_Map handled safely")
print = savedPrint
print("Forever suite: eight packs, profiles and consent mock tests passed.")
