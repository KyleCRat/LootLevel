local ADDON_NAME, NS = ...

local UI = NS.UI
local Helpers = NS.Helpers
local Metrics = UI.Metrics
local StyleLayer = UI.StyleLayer
local MergedVerticalLabel = UI.MergedVerticalLabel
local CellStyles = UI.CellStyles
local Borders = UI.Borders
local BodyScroll = UI.BodyScroll
local Tooltips = UI.Tooltips
local Layers = UI.Layers
local LayerResolver = UI.LayerResolver
local Cells = {}
UI.Cells = Cells

local function MergeCellData(defaults, source)
    return Helpers.ShallowMerge(defaults, source)
end

local function GetConfiguredCellData(tableKey, coord, ownership)
    if LayerResolver then
        ownership = ownership or LayerResolver.BuildTableOwnership(tableKey or "main")
        local owner = LayerResolver.OwnerAt(ownership, coord)
        if owner and owner.kind == "cell" then
            return owner
        end
        return nil
    end

    local tableCellRecords = NS.Data.cellRecords and NS.Data.cellRecords[tableKey or "main"]
    local records = tableCellRecords and tableCellRecords[coord]
    if records then
        local selected
        for _, record in ipairs(records) do
            if Layers.IsLayerVisible(record.layer) and Borders.BlockWinsOver(selected, record) then
                selected = record
            end
        end
        if selected then
            return selected
        end
    end

    local tableCells = NS.Data.cells and NS.Data.cells[tableKey or "main"]
    local cellData = tableCells and tableCells[coord] or nil
    if cellData and Layers.IsLayerVisible(cellData.layer) then
        return cellData
    end

    return nil
end

local function GetUnscaledFontMeasurement(fontString, methodName)
    local method = fontString and fontString[methodName]
    if not method then
        return nil
    end

    local value = method(fontString)
    if value and value > 0 then
        return value / UI.GetLayoutScale()
    end

    return nil
end

local function CreateVerticalText(parent, x, y, width, height, text, font, bold)
    local resolvedFontSize = UI.FontSize(font, 13)
    local fs = UI.CreateText(parent, text, UI.FontWithFallbackSize(font, 13), "black", "CENTER", "MIDDLE", bold)

    if fs.SetRotation then
        local maxTextWidth = math.max(1, height)
        local maxTextHeight = math.max(1, width - 4)
        local stringWidth = GetUnscaledFontMeasurement(fs, "GetStringWidth")
        local stringHeight = GetUnscaledFontMeasurement(fs, "GetStringHeight")
            or GetUnscaledFontMeasurement(fs, "GetLineHeight")
        local labelWidth = math.min(maxTextWidth, math.max(1, (stringWidth or maxTextWidth) + MergedVerticalLabel.widthPadding))
        local labelHeight = math.min(maxTextHeight, math.max(1, (stringHeight or resolvedFontSize) + MergedVerticalLabel.heightPadding))
        local centerX = x + (width / 2) + MergedVerticalLabel.nudgeX
        local centerY = y + (height / 2) + MergedVerticalLabel.nudgeY

        UI.SetLayoutBox(
            fs,
            "CENTER",
            parent,
            "TOPLEFT",
            centerX,
            -centerY,
            labelWidth,
            labelHeight
        )
        fs:SetRotation(math.pi / 2)
    else
        UI.SetLayoutBounds(fs, parent, x, y, width, height)
        fs:SetText((text or ""):gsub("(.)", "%1\n"))
    end

    return fs
end

local function CreateAtlasIcon(parent, width, height, atlas)
    local icon = parent:CreateTexture(nil, "ARTWORK")
    UI.ApplyTexturePixelSnapping(icon)
    icon:SetAtlas(atlas)

    local size = math.max(1, math.min(width, height) - 6)
    UI.SetLayoutBox(icon, "CENTER", parent, "CENTER", 0, 0, size, size)
    return icon
end

local function CreateCell(parent, x, y, width, height, cellData)
    cellData = cellData or {}
    CellStyles.SetCellStyleLayer(cellData, "default", StyleLayer.default, {
        bg = cellData.defaultBg or "blank",
    })
    CellStyles.SetCellStyleLayer(cellData, "cell", StyleLayer.cell, {
        bg = cellData.bg,
    })

    local cell = CreateFrame("Button", nil, parent)
    UI.SetLayoutBounds(cell, parent, x, y, width, height)
    cell:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    cell.cellData = cellData

    local bg = cell:CreateTexture(nil, "BACKGROUND")
    UI.ApplyTexturePixelSnapping(bg)
    bg:SetAllPoints(cell)
    cell.bg = bg

    local highlight = cell:CreateTexture(nil, "HIGHLIGHT")
    UI.ApplyTexturePixelSnapping(highlight)
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.22)

    local text
    if cellData.backgroundOnly then
        -- Background-only cells intentionally carry no visual content.
    elseif type(cellData.atlas) == "string" and cellData.atlas ~= "" then
        cell.icon = CreateAtlasIcon(cell, width, height, cellData.atlas)
    elseif cellData.vertical then
        text = CreateVerticalText(cell, 0, 0, width, height, cellData.text or "", cellData.font, cellData.bold)
    else
        text = UI.CreateText(cell, cellData.text or "", UI.FontWithFallbackSize(cellData.font, 12), "black", "CENTER", "MIDDLE", cellData.bold)
        text:SetPoint("CENTER", cell, "CENTER", 0, 0)
        UI.SetLayoutSize(text, math.max(1, width - 4), math.max(1, height - 4))
    end
    cell.text = text
    CellStyles.ApplyCellResolvedStyle(cell)

    cell:SetScript("OnEnter", function(self)
        Tooltips.ShowCellTooltip(self)
    end)

    cell:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    cell:SetScript("OnClick", function(self, button)
        local onClick = self.cellData and self.cellData.onClick
        if type(onClick) == "function" then
            onClick(self, button, self.cellData)
            return
        end

        if NS.HandleCellClick then
            NS:HandleCellClick(self.cellData, button)
        end
    end)

    if parent.bodyScrollFrame then
        BodyScroll.AttachWheel(cell, parent.bodyScrollFrame)
    end

    parent.cells = parent.cells or {}
    parent.cells[#parent.cells + 1] = cell
    Borders.RegisterCellCoordinate(parent, cell, cellData, x, y, width, height)
    return cell
end

local function CreateHeader(parent, x, y, width, height, text, cellData)
    return CreateCell(parent, x, y, width, height, MergeCellData({
        text = text,
        bg = "header",
        bold = true,
        font = { size = 13 },
        tooltip = { title = text },
        colTitle = text,
    }, cellData))
end

Cells.MergeData = MergeCellData
Cells.GetConfiguredData = GetConfiguredCellData
Cells.GetUnscaledFontMeasurement = GetUnscaledFontMeasurement
Cells.CreateVerticalText = CreateVerticalText
Cells.CreateAtlasIcon = CreateAtlasIcon
Cells.Create = CreateCell
Cells.CreateHeader = CreateHeader
