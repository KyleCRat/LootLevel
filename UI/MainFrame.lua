local ADDON_NAME, NS = ...

local UI = NS.UI
local Metrics = UI.Metrics
local Layers = UI.Layers

local function BuildShellLayout()
    local tableLayout = UI.BuildTableLayout and UI.BuildTableLayout() or nil
    local bounds = tableLayout and tableLayout.bounds or {}
    local tableWidth = math.max(1, bounds.width or (Metrics.frameWidth - (Metrics.padding * 2)))
    local tableHeight = math.max(1, bounds.height or (Metrics.frameHeight - Metrics.titleHeight - (Metrics.padding * 3) - Metrics.footerHeight))

    return {
        tableLayout = tableLayout,
        frameWidth = tableWidth + (Metrics.padding * 2),
        frameHeight = Metrics.titleHeight + Metrics.padding + tableHeight + Metrics.padding + Metrics.footerHeight + Metrics.padding,
        contentX = Metrics.padding,
        contentY = Metrics.titleHeight + Metrics.padding,
        contentWidth = tableWidth,
        contentHeight = tableHeight,
    }
end

local function ApplyShellLayout(frame, shellLayout)
    frame.shellLayoutRecords = frame.shellLayoutRecords or {}

    if frame.shellLayoutRecords.frameSize then
        UI.UpdateLayoutRecord(frame.shellLayoutRecords.frameSize, {
            width = shellLayout.frameWidth,
            height = shellLayout.frameHeight,
        })
    else
        frame.shellLayoutRecords.frameSize = UI.SetLayoutSize(frame, shellLayout.frameWidth, shellLayout.frameHeight)
    end

    if frame.tableContent then
        if frame.shellLayoutRecords.contentBox then
            UI.UpdateLayoutRecord(frame.shellLayoutRecords.contentBox, {
                x = shellLayout.contentX,
                y = -shellLayout.contentY,
                width = shellLayout.contentWidth,
                height = shellLayout.contentHeight,
            })
        else
            frame.shellLayoutRecords.contentBox = UI.SetLayoutBox(
                frame.tableContent,
                "TOPLEFT",
                frame,
                "TOPLEFT",
                shellLayout.contentX,
                -shellLayout.contentY,
                shellLayout.contentWidth,
                shellLayout.contentHeight
            )
        end
    end

    frame.shellLayout = shellLayout
end

local function TableLayerCacheKey(state)
    state = state or Layers.CurrentLayerRenderState()
    return state and state.key or Layers.GetActiveLayerSetKey() or "__default"
end

local function HideTableLayers(frame)
    for _, tableLayer in pairs(frame.tableLayersByKey or {}) do
        tableLayer:Hide()
    end
end

local function BuildTableLayer(frame, shellLayout, state)
    if not frame or not frame.tableContent then
        return nil
    end

    local cacheKey = TableLayerCacheKey(state)
    frame.tableLayersByKey = frame.tableLayersByKey or {}

    local tableLayer = frame.tableLayersByKey[cacheKey]
    if not tableLayer then
        tableLayer = CreateFrame("Frame", nil, frame.tableContent)
        tableLayer.deferScaleLayout = true
        tableLayer:SetAllPoints(frame.tableContent)
        tableLayer:Hide()
        tableLayer.cells = {}
        frame.tableLayersByKey[cacheKey] = tableLayer

        local previousContext = Layers.SetRenderContext(state)
        local ok, err = pcall(function()
            UI.WithDeferredScaleLayout(function()
                UI.BuildRegisteredTables(tableLayer, shellLayout.tableLayout)
                UI.DrawGridLines(tableLayer)
            end)
        end)
        Layers.SetRenderContext(previousContext)
        if not ok then
            error(err, 0)
        end
    end

    return tableLayer
end

local function BuildActiveLayerSetTableLayers(frame, shellLayout)
    local activeLayerSet = Layers.GetActiveLayerSetKey()
    local activeKey = TableLayerCacheKey()
    local activeTableLayer

    if Layers.ForEachLayerSetRenderState then
        Layers.ForEachLayerSetRenderState(activeLayerSet, function(state)
            local tableLayer = BuildTableLayer(frame, shellLayout, state)
            if state and state.key == activeKey then
                activeTableLayer = tableLayer
            end
        end)
    end

    return activeTableLayer or BuildTableLayer(frame, shellLayout, Layers.CurrentLayerRenderState())
end

local function EnsureActiveTableLayer(frame, shellLayout)
    if not frame.tableContent then
        return nil
    end

    local tableLayer = BuildActiveLayerSetTableLayers(frame, shellLayout)
    if UI.ApplyActiveLayerBodyScrollDefaults then
        UI.ApplyActiveLayerBodyScrollDefaults(false)
    end
    if not tableLayer then
        return nil
    end

    HideTableLayers(frame)
    tableLayer:Show()
    frame.cells = tableLayer.cells
    NS.tableLayer = tableLayer
    return tableLayer
end

local function RefreshPlaceholderLayer(frame, shellLayout)
    if not frame.tableContent then
        return nil
    end

    local placeholderLayer = NS.tablePlaceholderLayer
    if not placeholderLayer then
        placeholderLayer = CreateFrame("Frame", nil, frame.tableContent)
        placeholderLayer:SetAllPoints(frame.tableContent)
        placeholderLayer:Hide()
        NS.tablePlaceholderLayer = placeholderLayer
    end

    UI.BuildTablePlaceholders(placeholderLayer, shellLayout.tableLayout)
    return placeholderLayer
end

local function RefreshFrameShell(frame)
    local shellLayout = BuildShellLayout()
    ApplyShellLayout(frame, shellLayout)
    EnsureActiveTableLayer(frame, shellLayout)
    RefreshPlaceholderLayer(frame, shellLayout)
    return shellLayout
end

function NS:CreateMainFrame()
    if self.frame then
        return self.frame
    end

    if self.IsCombatLocked and self:IsCombatLocked() then
        if self.RunWhenOutOfCombat then
            self:RunWhenOutOfCombat("createMainFrame", function()
                NS:CreateMainFrame()
            end, true)
        end
        return nil
    end

    local frame = CreateFrame("Frame", "LootLevelFrame", UI.GetPixelRoot(), BackdropTemplateMixin and "BackdropTemplate")
    frame:SetScale(1)
    self.db.scalePercent = UI.NormalizeScalePercent(self.db.scalePercent)
    self.layoutRecords = {}
    self.layoutFonts = {}
    self.tableBodyScrolls = {}
    self.tableBodyScrollGroups = {}
    self.tableBodyScrollOffsets = {}
    self.appliedLayerBodyScrollDefaults = {}
    self.gridParents = {}
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
    frame.tableContent = content

    UI.BuildFooter(frame)
    RefreshFrameShell(frame)

    self.frame = frame
    table.insert(UISpecialFrames, "LootLevelFrame")

    return frame
end

function NS:RefreshMainFrameLayout()
    if not self.frame then
        return
    end

    if self.IsCombatLocked and self:IsCombatLocked() then
        if self.RunWhenOutOfCombat then
            self:RunWhenOutOfCombat("refreshMainFrameLayout", function()
                NS:RefreshMainFrameLayout()
            end, true)
        end
        return
    end

    RefreshFrameShell(self.frame)
    UI.SnapFramePosition(self.frame)
end

function NS:ShowMainFrame()
    if self.IsCombatLocked and self:IsCombatLocked() then
        if self.frame and self.frame:IsShown() then
            return true
        end

        if self.BlockCombatAction then
            self:BlockCombatAction("Opening LootLevel")
        end
        return false
    end

    if not self.frame then
        self:CreateMainFrame()
    end

    if not self.frame then
        return false
    end

    self.frame:Show()
    return true
end

function NS:HideMainFrame()
    if self.frame then
        self.frame:Hide()
    end
end

function NS:ToggleMainFrame()
    if self.frame and self.frame:IsShown() then
        self.frame:Hide()
    else
        self:ShowMainFrame()
    end
end

function NS:ResetMainFramePosition()
    if self.BlockCombatAction and self:BlockCombatAction("Resetting LootLevel position") then
        return false
    end

    if not self.frame then
        self:CreateMainFrame()
    end

    if not self.frame then
        return false
    end

    self.db.position = {
        point = "CENTER",
        relPoint = "CENTER",
        x = 0,
        y = 0,
    }
    self:RestoreFramePosition(self.frame)
    self:Print("Frame position reset.")
    return true
end
