--[[
    Developer fixture: class-restricted module registering through Core.
    Uses class token, never the character's name, to test eligibility.
]]

local descriptor = {
    id = "probe-warrior",
    displayName = "Warrior Probe",
    version = "0.1.0",
    minCoreVersion = "0.1.0",
    capabilities = { "probe.warrior" },
    events = { "PLAYER_LEVEL_UP" },
    Initialize = function(self, context)
        self.levelEvents = 0
    end,
    IsEligible = function(self, context)
        return context.classToken == "WARRIOR", "Warrior only"
    end,
    Enable = function(self, context)
        -- No game action: probes validate registration and event handling.
    end,
    Disable = function(self)
        -- Core removes event subscriptions before this callback runs.
    end,
    OnEvent = function(self, eventName)
        if eventName == "PLAYER_LEVEL_UP" then
            self.levelEvents = self.levelEvents + 1
        end
    end,
}

local ok, errorMessage = ForeverCore.RegisterModule(descriptor)

if not ok then
    ForeverCore.Print("Warrior probe failed: " .. errorMessage)
end
