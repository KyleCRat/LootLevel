local ADDON_NAME, NS = ...

local COMMANDS = {
    {
        triggers = { "", "toggle", "t" },
        name = "Toggle",
        description = "Toggle the item level table",
        func = function()
            NS:ToggleMainFrame()
        end,
    },
    {
        triggers = { "show", "s" },
        name = "Show",
        description = "Show the item level table",
        func = function()
            NS:ShowMainFrame()
        end,
    },
    {
        triggers = { "hide", "h" },
        name = "Hide",
        description = "Hide the item level table",
        func = function()
            NS:HideMainFrame()
        end,
    },
    {
        triggers = { "reset", "r" },
        name = "Reset",
        description = "Reset the frame position",
        func = function()
            NS:ResetMainFramePosition()
        end,
    },
    {
        triggers = { "lock" },
        name = "Lock",
        description = "Lock the frame position",
        func = function()
            NS.db.locked = true
            NS:Print("Frame locked.")
        end,
    },
    {
        triggers = { "unlock" },
        name = "Unlock",
        description = "Unlock the frame position",
        func = function()
            NS.db.locked = false
            NS:Print("Frame unlocked.")
        end,
    },
}

local function Matches(command, message)
    for _, trigger in ipairs(command.triggers) do
        if message == trigger then
            return true
        end
    end

    return false
end

local function PrintHelp()
    for _, command in ipairs(COMMANDS) do
        local trigger = command.triggers[1]
        local suffix = trigger ~= "" and (" " .. trigger) or ""
        NS:Print(("/lootlevel%s - %s"):format(suffix, command.description))
    end
end

function NS:RegisterSlashCommands()
    SLASH_LOOTLEVEL1 = "/lootlevel"
    SLASH_LOOTLEVEL2 = "/ll"

    SlashCmdList.LOOTLEVEL = function(message)
        message = strtrim(message or ""):lower()

        for _, command in ipairs(COMMANDS) do
            if Matches(command, message) then
                command.func()
                return
            end
        end

        PrintHelp()
    end
end
