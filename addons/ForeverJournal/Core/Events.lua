--[[
    Forever Journal: Events
    Records a minimal runtime-ready flag after the character logs in.
    No persistence, scanning, or gameplay automation happens here.
]]

local _, addon = ...

addon.isReady = false

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        addon.isReady = true
    end
end)
