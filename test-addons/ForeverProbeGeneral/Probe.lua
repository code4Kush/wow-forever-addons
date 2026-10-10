--[[
    Developer fixture: all-class module registering through ForeverCore.
    Intentionally has no gameplay effects or chat messages during events.
    Install only for the Core M1 verification steps.
]]

local descriptor = {
    id = "probe-general",
    displayName = "General Probe",
    version = "0.1.0",
    minCoreVersion = "0.1.0",
    capabilities = { "probe.general" },
    events = { "PLAYER_LEVEL_UP" },
    Initialize = function(self, context)
        self.characterName = context.name
        self.levelEvents = 0
    end,
    Enable = function(self, context)
        self.characterName = context.name
    end,
    Disable = function(self)
        -- Core owns the active event subscription and removes it first.
    end,
    OnEvent = function(self, eventName)
        if eventName == "PLAYER_LEVEL_UP" then
            self.levelEvents = self.levelEvents + 1
        end
    end,
}

local ok, errorMessage = ForeverCore.RegisterModule(descriptor)

if not ok then
    ForeverCore.Print("General probe failed: " .. errorMessage)
end
