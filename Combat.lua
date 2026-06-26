local ADDON_NAME, NS = ...

local Combat = {}
NS.Combat = Combat

local pendingActions = {}
local pendingOrder = {}

local function IsLocked()
    return InCombatLockdown and InCombatLockdown()
end

local function AddPendingAction(key, callback)
    if pendingActions[key] == nil then
        pendingOrder[#pendingOrder + 1] = key
    end
    pendingActions[key] = callback
end

local function FlushPendingActions()
    if IsLocked() then
        return
    end

    local order = pendingOrder
    local actions = pendingActions
    pendingOrder = {}
    pendingActions = {}

    for _, key in ipairs(order) do
        local callback = actions[key]
        if type(callback) == "function" then
            callback()
        end
    end
end

local function RefreshCombatControls()
    if NS.UI and NS.UI.RefreshCombatLockoutControls then
        NS.UI.RefreshCombatLockoutControls()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        RefreshCombatControls()
    elseif event == "PLAYER_REGEN_ENABLED" then
        RefreshCombatControls()
        FlushPendingActions()
    end
end)

function NS:IsCombatLocked()
    return IsLocked()
end

function NS:BlockCombatAction(actionName, silent)
    if not IsLocked() then
        return false
    end

    if not silent then
        self:Print(("%s is disabled during combat. Try again after combat ends."):format(actionName or "This action"))
    end
    return true
end

function NS:RunWhenOutOfCombat(key, callback, silent)
    if type(callback) ~= "function" then
        return false
    end

    if not IsLocked() then
        callback()
        return true
    end

    AddPendingAction(key or tostring(callback), callback)
    if not silent then
        self:Print("LootLevel will finish that action after combat ends.")
    end
    return false
end

Combat.IsLocked = IsLocked
Combat.FlushPendingActions = FlushPendingActions
Combat.RefreshControls = RefreshCombatControls
