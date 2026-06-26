local ADDON_NAME, NS = ...

local UI = NS.UI
local Metrics = UI.Metrics

function NS:CreateMainFrame()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", "LootLevelFrame", UI.GetPixelRoot(), BackdropTemplateMixin and "BackdropTemplate")
    frame:SetScale(1)
    self.db.scalePercent = UI.NormalizeScalePercent(self.db.scalePercent)
    self.layoutRecords = {}
    self.layoutFonts = {}
    self.tableBodyScrolls = {}
    self.gridParents = {}
    UI.SetLayoutSize(frame, Metrics.frameWidth, Metrics.frameHeight)
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame.cells = {}

    if frame.SetBackdrop then
        frame:SetBackdrop(UI.FrameBackdrop)
        frame:SetBackdropColor(UI.Color("frame"))
        frame:SetBackdropBorderColor(0.02, 0.02, 0.02, 1)
    end

    self:RestoreFramePosition(frame)
    frame:Hide()

    frame:SetScript("OnDragStart", function(selfFrame)
        if not NS.db or not NS.db.locked then
            selfFrame:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        UI.SnapFramePosition(selfFrame)
        NS:SaveFramePosition(selfFrame)
    end)

    frame:SetScript("OnShow", function()
        if NS.db then
            NS.db.shown = true
        end
    end)

    frame:SetScript("OnHide", function()
        if NS.db then
            NS.db.shown = false
        end
    end)

    local title = UI.CreateText(frame, "LootLevel", { size = 15 }, "white", "LEFT", "MIDDLE", true)
    UI.SetLayoutBox(title, "TOPLEFT", frame, "TOPLEFT", Metrics.padding, -6, 240, Metrics.titleHeight - 4)

    local version = UI.CreateText(frame, self.version or "", { size = 11 }, "muted", "RIGHT", "MIDDLE", false)
    UI.SetLayoutBox(version, "TOPRIGHT", frame, "TOPRIGHT", -92, -6, 160, Metrics.titleHeight - 4)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    UI.SetLayoutBox(close, "TOPRIGHT", frame, "TOPRIGHT", -4, -4, 28, 28)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    UI.CreateScaleButton(frame)
    UI.LayerSelector.CreateButtons(frame)

    local content = CreateFrame("Frame", nil, frame)
    UI.SetLayoutBox(content, "TOPLEFT", frame, "TOPLEFT", Metrics.padding, -(Metrics.titleHeight + 8), Metrics.frameWidth - (Metrics.padding * 2), Metrics.frameHeight - Metrics.titleHeight - 42)
    content.cells = frame.cells

    UI.BuildRegisteredTables(content)
    UI.DrawGridLines(content)
    UI.PrewarmLayerRenderCaches()
    UI.BuildFooter(frame)

    self.frame = frame
    table.insert(UISpecialFrames, "LootLevelFrame")

    return frame
end

function NS:ShowMainFrame()
    if not self.frame then
        self:CreateMainFrame()
    end
    self.frame:Show()
end

function NS:HideMainFrame()
    if self.frame then
        self.frame:Hide()
    end
end

function NS:ToggleMainFrame()
    if not self.frame then
        self:CreateMainFrame()
    end

    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

function NS:ResetMainFramePosition()
    if not self.frame then
        self:CreateMainFrame()
    end

    self.db.position = {
        point = "CENTER",
        relPoint = "CENTER",
        x = 0,
        y = 0,
    }
    self:RestoreFramePosition(self.frame)
    self:Print("Frame position reset.")
end
