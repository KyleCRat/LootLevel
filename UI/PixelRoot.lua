local ADDON_NAME, NS = ...

local UI = NS.UI
local PixelRoot = {}
UI.PixelRoot = PixelRoot

local function GetPixelToUIUnitFactor()
    if PixelUtil and PixelUtil.GetPixelToUIUnitFactor then
        return PixelUtil.GetPixelToUIUnitFactor()
    end

    local _, physicalHeight = GetPhysicalScreenSize()
    if physicalHeight and physicalHeight > 0 then
        return 768 / physicalHeight
    end

    return UIParent:GetEffectiveScale()
end

local function GetPhysicalSize()
    local width, height
    if GetPhysicalScreenSize then
        width, height = GetPhysicalScreenSize()
    end

    if not width or width <= 0 or not height or height <= 0 then
        local scale = UIParent:GetEffectiveScale()
        local factor = GetPixelToUIUnitFactor()
        width = UIParent:GetWidth() * scale / factor
        height = UIParent:GetHeight() * scale / factor
    end

    return UI.Pixel(width), UI.Pixel(height)
end

local function ApplyPixelRootScale(root)
    local pixelScale = GetPixelToUIUnitFactor()

    if root.SetIgnoreParentScale then
        root:SetIgnoreParentScale(true)
        root:SetScale(pixelScale)
    else
        root:SetScale(pixelScale / UIParent:GetEffectiveScale())
    end
end

local function UpdatePixelRoot(root)
    local width, height = GetPhysicalSize()
    ApplyPixelRootScale(root)
    root:SetSize(width, height)
    root:ClearAllPoints()
    root:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function GetPixelRoot()
    if NS.pixelRoot then
        return NS.pixelRoot
    end

    local root = CreateFrame("Frame", "LootLevelPixelRoot", UIParent)
    root:SetFrameStrata("HIGH")
    root:SetFrameLevel(1)
    UpdatePixelRoot(root)

    root:RegisterEvent("DISPLAY_SIZE_CHANGED")
    root:RegisterEvent("UI_SCALE_CHANGED")
    root:RegisterEvent("PLAYER_ENTERING_WORLD")
    root:SetScript("OnEvent", function(self)
        UpdatePixelRoot(self)
        if NS.frame then
            NS:RestoreFramePosition(NS.frame)
        end
    end)

    NS.pixelRoot = root
    return root
end

local function SnapFramePosition(frame)
    local point, relativeTo, relativePoint, x, y = frame:GetPoint(1)
    frame:ClearAllPoints()
    frame:SetPoint(
        point or "CENTER",
        relativeTo or NS.pixelRoot or UIParent,
        relativePoint or "CENTER",
        UI.Pixel(x),
        UI.Pixel(y)
    )
end

PixelRoot.GetPixelToUIUnitFactor = GetPixelToUIUnitFactor
PixelRoot.GetPhysicalSize = GetPhysicalSize
PixelRoot.ApplyScale = ApplyPixelRootScale
PixelRoot.Update = UpdatePixelRoot
PixelRoot.Get = GetPixelRoot
PixelRoot.SnapFramePosition = SnapFramePosition

UI.GetPixelRoot = GetPixelRoot
UI.SnapFramePosition = SnapFramePosition
