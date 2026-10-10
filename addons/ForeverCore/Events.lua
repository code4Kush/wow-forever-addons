--[[
    Forever Core: Events

    Owns the single module event bridge. Login is always subscribed by Core;
    all optional subscriptions are managed by the Registry on activation.
]]

local _, core = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
core.AttachEventFrame(frame)

frame:SetScript("OnEvent", function(_, eventName, ...)
    if eventName == "PLAYER_LOGIN" then
        core.StartForCharacter(core.ReadCharacter())
        return
    end

    core.DispatchEvent(eventName, ...)
end)
