--[[
    Forever Warrior: Optional ForeverCore Registration

    The pack is eligible for all Warrior characters, not just Uddergrief.
    No game events are registered and no gear, talents or bags are scanned.
    Core handles enable/disable as an intentionally session-only setting.
]]

local _, addon = ...

local descriptor = {
    id = "forever-warrior",
    displayName = "Forever Warrior",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "warrior.level-plan", "warrior.manual-readiness" },
    events = {},

    --- Check eligibility by class token, never by a character's name.
    --- @param self table Module descriptor.
    --- @param character table Read-only ForeverCore character snapshot.
    --- @return boolean eligible
    --- @return string|nil reason
    IsEligible = function(self, character)
        return character ~= nil and character.classToken == "WARRIOR",
            "Warrior only"
    end,

    --- Required Core lifecycle hook; this pack has no state to initialize.
    Initialize = function(self, character) end,

    --- Core activates this session-only read-only advice provider.
    Enable = function(self, character) end,

    --- No event subscriptions or persistent state require cleanup.
    Disable = function(self)
        if addon.ClearReady then addon.ClearReady() end
    end,
}

local accepted, errorMessage = ForeverCore.RegisterModule(descriptor)

if not accepted then
    addon.Print("Registration failed: " .. tostring(errorMessage))
end
