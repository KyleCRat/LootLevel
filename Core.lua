local ADDON_NAME, NS = ...

NS.ADDON_NAME = ADDON_NAME
NS.DISPLAY_NAME = "LootLevel"
NS.COLOR_HEX = "ff39d98a"
NS.FONT_PATH = "Interface\\AddOns\\LootLevel\\Media\\Fonts\\Comfortaa-Regular.ttf"
NS.FONT_BOLD_PATH = "Interface\\AddOns\\LootLevel\\Media\\Fonts\\Comfortaa-Bold.ttf"

local DEFAULTS = {
    shown = true,
    locked = false,
    scalePercent = 100,
    activeLayers = {},
    position = {
        point = "CENTER",
        relPoint = "CENTER",
        x = 0,
        y = 0,
    },
}

local function CopyDefaults(defaults, target)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            CopyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local function GetVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
    end

    if GetAddOnMetadata then
        return GetAddOnMetadata(ADDON_NAME, "Version")
    end

    return "Dev"
end

local function SnapPixel(value)
    return math.floor((value or 0) + 0.5)
end

function NS:Print(message)
    print(("|c%s%s|r %s"):format(self.COLOR_HEX, self.DISPLAY_NAME, tostring(message)))
end

function NS:SaveFramePosition(frame)
    if not self.db or not frame then
        return
    end

    local point, _, relPoint, x, y = frame:GetPoint(1)
    local snap = self.Pixel or SnapPixel
    self.db.position = {
        point = point or "CENTER",
        relPoint = relPoint or "CENTER",
        x = snap(x),
        y = snap(y),
    }
end

function NS:RestoreFramePosition(frame)
    if not frame then
        return
    end

    local pos = self.db and self.db.position
    local relativeTo = self.pixelRoot or UIParent
    local snap = self.Pixel or SnapPixel

    frame:ClearAllPoints()
    if pos then
        frame:SetPoint(pos.point or "CENTER", relativeTo, pos.relPoint or "CENTER", snap(pos.x), snap(pos.y))
    else
        frame:SetPoint("CENTER", relativeTo, "CENTER", 0, 0)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= ADDON_NAME then
        return
    end

    self:UnregisterEvent("ADDON_LOADED")

    LootLevelDB = LootLevelDB or {}
    CopyDefaults(DEFAULTS, LootLevelDB)

    NS.db = LootLevelDB
    NS.version = GetVersion()
    NS.BonusScanner:Initialize()

    if NS.RegisterSlashCommands then
        NS:RegisterSlashCommands()
    end

    local function LoadUI()
        if NS.CreateMainFrame then
            NS:CreateMainFrame()
        end

        if NS.db.shown ~= false and NS.ShowMainFrame then
            NS:ShowMainFrame()
        end
    end

    if NS.RunWhenOutOfCombat then
        NS:RunWhenOutOfCombat("initialUI", LoadUI, true)
    else
        LoadUI()
    end
end)
