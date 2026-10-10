--[[
    Forever Core: Registry

    Registers independently loaded feature packages, validates their public
    contract and manages their lifecycle. Logical enablement is session-only.
    Saved settings, account profiles and a GUI belong to later milestones.

    Only active modules receive subscribed game events. Core, not feature
    packages, owns the event frame and removes subscriptions on disable.
]]

local _, core = ...

local registered = {}
local orderedIds = {}
local subscribers = {}
local eventFrame
local playerContext
local playerReady = false

local function CopyArray(values)
    local result = {}

    for _, value in ipairs(values or {}) do
        result[#result + 1] = value
    end

    return result
end

--- Compares strictly numeric three-part versions without lexical errors.
--- @param left string Semantic version such as 0.1.0.
--- @param right string Semantic version such as 0.2.0.
--- @return number comparison Negative, zero, or positive.
local function CompareVersions(left, right)
    local function Parts(version)
        local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")
        if not major then
            return nil
        end
        return { tonumber(major), tonumber(minor), tonumber(patch) }
    end

    local a, b = Parts(left), Parts(right)

    if not a or not b then
        return nil
    end

    for index = 1, 3 do
        if a[index] ~= b[index] then
            return a[index] < b[index] and -1 or 1
        end
    end

    return 0
end

local function ValidateDescriptor(definition)
    if type(definition) ~= "table" then
        return "Module descriptor must be a table."
    end

    if type(definition.id) ~= "string"
        or not definition.id:match("^[a-z][a-z0-9%-]*$") then
        return "Module ID must use lowercase letters, numbers and hyphens."
    end

    if type(definition.displayName) ~= "string"
        or definition.displayName == "" then
        return "Module displayName is required."
    end

    if type(definition.version) ~= "string"
        or CompareVersions(definition.version, definition.version) == nil then
        return "Module version must be major.minor.patch."
    end

    if type(definition.minCoreVersion) ~= "string"
        or CompareVersions(definition.minCoreVersion, definition.minCoreVersion) == nil then
        return "minCoreVersion must be major.minor.patch."
    end

    for _, callback in ipairs({ "Initialize", "Enable", "Disable" }) do
        if type(definition[callback]) ~= "function" then
            return callback .. " callback is required."
        end
    end

    for _, callback in ipairs({ "IsEligible", "OnEvent", "GetStatus" }) do
        if definition[callback] ~= nil and type(definition[callback]) ~= "function" then
            return callback .. " must be a function if supplied."
        end
    end

    for _, field in ipairs({ "events", "capabilities", "optionalRequires" }) do
        local list = definition[field]
        if list ~= nil and type(list) ~= "table" then
            return field .. " must be an array."
        end

        local seen = {}
        if list then
            for index, entry in ipairs(list) do
                if type(entry) ~= "string" or entry == "" or seen[entry] then
                    return field .. " contains an invalid or duplicate entry."
                end
                seen[entry] = true
            end
        end
    end

    if definition.events and #definition.events > 0
        and type(definition.OnEvent) ~= "function" then
        return "OnEvent is required when events are declared."
    end

    return nil
end

local function SafeCall(record, method, ...)
    local callback = record.definition[method]

    if not callback then
        return true
    end

    local success, result, detail = pcall(callback, record.definition, ...)

    if not success then
        return false, tostring(result)
    end

    return true, result, detail
end

local function Subscribe(record)
    for _, eventName in ipairs(record.definition.events or {}) do
        local group = subscribers[eventName]

        if not group then
            group = {}
            subscribers[eventName] = group
            eventFrame:RegisterEvent(eventName)
        end

        group[record.definition.id] = true
    end
end

local function Unsubscribe(record)
    for _, eventName in ipairs(record.definition.events or {}) do
        local group = subscribers[eventName]

        if group then
            group[record.definition.id] = nil

            if not next(group) then
                subscribers[eventName] = nil
                eventFrame:UnregisterEvent(eventName)
            end
        end
    end
end

local function Stop(record)
    if not record.active then
        return true
    end

    -- Unsubscribe before running Disable so callbacks cannot receive events
    -- after deactivation, even if Disable encounters an error.
    Unsubscribe(record)
    record.active = false

    local success, detail = SafeCall(record, "Disable")

    if not success then
        record.error = "Disable failed: " .. detail
    end

    return success, detail
end

local function Start(record)
    if not playerReady or record.active or not record.requestedEnabled then
        return
    end

    if CompareVersions(record.definition.minCoreVersion, core.version) > 0 then
        record.blocked = "incompatible"
        record.reason = "requires Core " .. record.definition.minCoreVersion
        return
    end

    local eligibilityOK, eligible, reason = SafeCall(
        record, "IsEligible", playerContext
    )

    if not eligibilityOK then
        record.error = "Eligibility failed: " .. tostring(eligible)
        return
    end

    if eligible == false then
        record.blocked = "ineligible"
        record.reason = type(reason) == "string" and reason
            or "not eligible for this character"
        return
    end

    record.blocked = nil
    record.reason = nil

    if not record.initialized then
        local initialized, initError = SafeCall(
            record, "Initialize", playerContext
        )

        if not initialized then
            record.error = "Initialize failed: " .. initError
            return
        end

        record.initialized = true
    end

    local enabled, enableError = SafeCall(record, "Enable", playerContext)

    if not enabled then
        record.error = "Enable failed: " .. enableError
        SafeCall(record, "Disable")
        return
    end

    record.error = nil
    record.active = true
    Subscribe(record)
end

--- Called by the event bridge after the client has loaded a character.
--- @param context table Runtime snapshot from ReadCharacter.
function core.StartForCharacter(context)
    if playerReady then
        return
    end

    playerContext = context
    playerReady = true

    for _, moduleId in ipairs(orderedIds) do
        Start(registered[moduleId])
    end
end

--- Associates Core's single event frame with the module registry.
--- @param frame table WoW frame created during Core's event initialization.
function core.AttachEventFrame(frame)
    eventFrame = frame
end

--- Delivers a game event to active modules only.
--- @param eventName string Name of the fired WoW event.
function core.DispatchEvent(eventName, ...)
    local group = subscribers[eventName]
    if not group then
        return
    end

    -- Build a stable ID snapshot in case an event handler disables a module.
    local ids = {}
    for moduleId in pairs(group) do
        ids[#ids + 1] = moduleId
    end
    table.sort(ids)

    for _, moduleId in ipairs(ids) do
        local record = registered[moduleId]

        if record and record.active and subscribers[eventName]
            and subscribers[eventName][moduleId] then
            local success, errorMessage = SafeCall(
                record, "OnEvent", eventName, ...
            )

            if not success then
                record.error = "OnEvent failed: " .. errorMessage
                Stop(record)
                core.Print(moduleId .. ": disabled after an event error.")
            end
        end
    end
end

--- Registers a feature descriptor exactly once.
--- @param definition table Descriptor following docs/CORE_CONTRACT.md.
--- @return boolean success Whether the registration was accepted.
--- @return string|nil errorMessage Reason for rejection.
function core.RegisterModule(definition)
    local validationError = ValidateDescriptor(definition)

    if validationError then
        return false, validationError
    end

    if registered[definition.id] then
        return false, "Module ID is already registered."
    end

    local record = {
        definition = definition,
        requestedEnabled = true,
        initialized = false,
        active = false,
    }

    registered[definition.id] = record
    orderedIds[#orderedIds + 1] = definition.id
    table.sort(orderedIds)

    if playerReady then
        Start(record)
    end

    return true
end

--- Enables or disables a registered feature for this game session.
--- This does not modify WoW's AddOns checkbox or save profile settings.
--- @param moduleId string Registered module ID.
--- @param enabled boolean Session toggle.
--- @return boolean success
--- @return string|nil errorMessage
function core.SetModuleEnabled(moduleId, enabled)
    local record = registered[moduleId]

    if not record then
        return false, "Module is not registered (possibly not installed)."
    end

    if type(enabled) ~= "boolean" then
        return false, "Enabled must be true or false."
    end

    record.requestedEnabled = enabled

    if enabled then
        Start(record)
    else
        Stop(record)
    end

    return true
end

--- Returns the current readonly-by-convention character context copy.
--- @return table|nil character The current player if login is complete.
function core.GetCharacter()
    if not playerContext then
        return nil
    end

    local result = {}
    for key, value in pairs(playerContext) do
        result[key] = value
    end
    return result
end

--- Returns the status of a known registered module.
--- @param moduleId string Registered module identifier.
--- @return table|nil status Snapshot, or nil if not registered.
function core.GetModuleStatus(moduleId)
    local record = registered[moduleId]
    if not record then
        return nil
    end

    local state = "registered"
    local reason = "waiting for PLAYER_LOGIN"

    if not record.requestedEnabled then
        state = "disabled"
        reason = "session only"
    elseif record.error then
        state = "error"
        reason = record.error
    elseif record.blocked then
        state = record.blocked
        reason = record.reason
    elseif record.active then
        state = "active"
        reason = nil
    end

    if record.active and record.definition.GetStatus then
        local success, health, detail = SafeCall(record, "GetStatus")
        if not success then
            state, reason = "degraded", "GetStatus failed: " .. health
        elseif health == "degraded" or health == "unavailable" then
            state, reason = health, detail
        end
    end

    return {
        id = moduleId,
        displayName = record.definition.displayName,
        version = record.definition.version,
        minCoreVersion = record.definition.minCoreVersion,
        capabilities = CopyArray(record.definition.capabilities),
        optionalRequires = CopyArray(record.definition.optionalRequires),
        enabled = record.requestedEnabled,
        active = record.active,
        state = state,
        reason = reason,
    }
end

--- Lists only modules whose Lua actually registered successfully.
--- Unloaded or uninstalled addons cannot be inferred from this registry.
--- @return table statuses Alphabetically sorted snapshots.
function core.ListModules()
    local result = {}

    for _, moduleId in ipairs(orderedIds) do
        result[#result + 1] = core.GetModuleStatus(moduleId)
    end

    return result
end

--- Looks up active modules that advertise a named capability.
--- @param capability string Capability identifier, e.g., inventory.snapshot.
--- @return table providers Sorted module IDs.
function core.FindCapabilityProviders(capability)
    local providers = {}

    for _, moduleId in ipairs(orderedIds) do
        local record = registered[moduleId]
        if record.active then
            for _, value in ipairs(record.definition.capabilities or {}) do
                if value == capability then
                    providers[#providers + 1] = moduleId
                end
            end
        end
    end

    return providers
end

--- Diagnostic count of active module subscriptions to a named event.
--- @param eventName string WoW event name.
--- @return number count Active module listeners.
function core.GetSubscriberCount(eventName)
    local group = subscribers[eventName]
    local count = 0

    for _ in pairs(group or {}) do
        count = count + 1
    end

    return count
end
