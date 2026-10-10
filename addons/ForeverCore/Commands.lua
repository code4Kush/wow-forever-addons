--[[
    Forever Core: Commands

    Diagnostic controls for installed and registered feature packages.
    Enabling/disabling a module affects only the current game session.
    Persistent per-character module choices belong to a future milestone.
]]

local _, core = ...

local function PrintHelp()
    core.Print("Commands: /forever version | modules | status <id> | character")
    core.Print("/forever enable <id> | disable <id> | listeners <EVENT>")
    core.Print("/forever pref <id> on|off | profile | marker [test-id]")
    core.Print("Enable/disable is SESSION ONLY; pref/marker persistence is UNVERIFIED.")
end

local function PrintStatus(record)
    local extra = record.reason and " (" .. record.reason .. ")" or ""
    local capabilities = table.concat(record.capabilities, ", ")
    local suffix = capabilities ~= "" and " [" .. capabilities .. "]" or ""

    core.Print(string.format(
        "%s v%s: %s%s%s",
        record.id, record.version, record.state, extra, suffix
    ))
end

local function HandleSlashCommand(message)
    local command, argument = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "" or command == "help" then
        PrintHelp()
        return
    end

    if command == "version" then
        core.Print("Version " .. core.version)
        return
    end

    if command == "character" then
        if argument ~= "" then
            core.Print("Usage: /forever character")
            return
        end

        local character = core.GetCharacter()

        if not character then
            core.Print("Character data is unavailable before PLAYER_LOGIN.")
            return
        end

        local realm = character.realm and (" - " .. character.realm) or ""

        core.Print(string.format(
            "%s%s - %s %s - level %s",
            character.name,
            realm,
            character.raceName,
            character.className,
            character.level and tostring(character.level) or "?"
        ))
        return
    end

    if command == "profile" and argument == "" then
        local info = core.GetProfileInfo()
        local status = info.writable and "writable (restart unverified)"
            or ("unavailable: " .. tostring(info.reason))
        core.Print("Profile schema " .. info.schemaVersion .. ": " .. status
            .. "; " .. info.preferenceCount .. " preference(s).")
        return
    end

    if command == "marker" then
        if argument == "" then
            local info = core.GetProfileInfo()
            core.Print("Profile marker: "
                .. (type(info.marker) == "string" and info.marker or "<unset>")
                .. " (restart unverified).")
            return
        end

        local saved, reason = core.SetProfileMarker(argument)
        if not saved then
            core.Print("Marker not saved: " .. tostring(reason))
        else
            core.Print("Profile marker set: " .. argument
                .. " (verify after full restart).")
        end
        return
    end

    if command == "pref" then
        local id, choice = argument:match("^([a-z][a-z0-9%-]*)%s+([a-z]+)$")
        if not id or (choice ~= "on" and choice ~= "off") then
            core.Print("Usage: /forever pref <module-id> on|off")
            return
        end

        local saved, reason = core.SetPreferredModuleEnabled(id, choice == "on")
        if not saved then
            core.Print("Preference not saved: " .. tostring(reason))
        else
            core.Print(id .. ": preference " .. choice
                .. " (restart unverified).")
        end
        return
    end

    if command == "modules" then
        if argument ~= "" then
            core.Print("Usage: /forever modules")
            return
        end

        local records = core.ListModules()
        core.Print(string.format("%d registered module(s).", #records))

        for _, record in ipairs(records) do
            PrintStatus(record)
        end

        return
    end

    if command == "status" then
        local record = core.GetModuleStatus(argument)

        if not record then
            core.Print("Module is not registered (possibly not installed).")
            return
        end

        PrintStatus(record)
        return
    end

    if command == "enable" or command == "disable" then
        if not argument:match("^[a-z][a-z0-9%-]*$") then
            core.Print("Usage: /forever " .. command .. " <module-id>")
            return
        end

        local success, errorMessage = core.SetModuleEnabled(
            argument, command == "enable"
        )

        if not success then
            core.Print(errorMessage)
            return
        end

        core.Print(argument .. ": " .. (command == "enable"
            and "enable requested" or "disabled") .. " (session only).")
        return
    end

    if command == "listeners" then
        if not argument:match("^[A-Z][A-Z0-9_]*$") then
            core.Print("Usage: /forever listeners <EVENT>")
            return
        end

        core.Print(string.format(
            "%s: %d active listener(s).",
            argument, core.GetSubscriberCount(argument)
        ))
        return
    end

    core.Print("Unknown command: " .. command)
    PrintHelp()
end

SLASH_FOREVERCORE1 = "/forever"
SlashCmdList.FOREVERCORE = HandleSlashCommand
