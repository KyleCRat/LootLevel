local ADDON_NAME, NS = ...

local UI = NS.UI
local Coordinates = NS.Coordinates
local Tooltips = {}
UI.Tooltips = Tooltips

local ColumnName = Coordinates.ColumnName
local CoordFromIndex = Coordinates.CoordFromIndex

local function BuildTooltipLines(cellData, fallbackLabel)
    local tooltip = cellData.tooltip
    local lines = {}

    if type(tooltip) == "table" then
        for _, key in ipairs({ "a", "b", "c", "d", "e" }) do
            if tooltip[key] then
                lines[#lines + 1] = tooltip[key]
            end
        end

        if #lines > 0 then
            return lines
        end
    end

    if cellData.colTitle then
        lines[#lines + 1] = ("Column: %s"):format(cellData.colTitle)
    end
    if cellData.layerName then
        lines[#lines + 1] = ("Layer: %s"):format(cellData.layerName)
    end
    if cellData.text and cellData.text ~= "" then
        lines[#lines + 1] = ("Value: %s"):format(cellData.text)
    elseif fallbackLabel then
        lines[#lines + 1] = fallbackLabel
    end
    return lines
end

local function FormatGridTooltipLine(cell)
    if cell and cell.gridLabel then
        return cell.gridLabel
    end

    if not cell or not cell.gridCoord or not cell.gridColumn or not cell.gridRow then
        return nil
    end

    local tablePrefix = cell.gridTable and cell.gridTable ~= "main" and (cell.gridTable .. " ") or ""
    local span = cell.gridSpan
    if span and (span.fromColumn ~= span.toColumn or span.fromRow ~= span.toRow) then
        local startCoord = CoordFromIndex(span.fromColumn, span.fromRow)
        local endCoord = CoordFromIndex(span.toColumn, span.toRow)
        if startCoord and endCoord and startCoord ~= endCoord then
            return ("Merged cell: %s%s-%s"):format(tablePrefix, string.upper(startCoord), string.upper(endCoord))
        end
    end

    local column = string.upper(ColumnName(cell.gridColumn) or "")
    local coord = string.upper(cell.gridCoord)
    return ("Cell: %s%s  Column: %s  Row: %d"):format(tablePrefix, coord, column, cell.gridRow)
end

local function TooltipTitle(cellData)
    local tooltip = cellData and cellData.tooltip
    if type(tooltip) == "table" then
        return tooltip.title
    end

    return nil
end

local function ShowCellTooltip(cell)
    local data = cell.cellData or {}
    GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
    GameTooltip:SetText(TooltipTitle(data) or data.colTitle or "LootLevel cell", 1, 1, 1)

    local gridLine = FormatGridTooltipLine(cell)
    if gridLine then
        GameTooltip:AddLine(gridLine, 0.55, 0.75, 1, true)
    end

    local lines = BuildTooltipLines(data)
    for _, line in ipairs(lines) do
        GameTooltip:AddLine(line, 0.85, 0.85, 0.85, true)
    end

    GameTooltip:AddLine("Left-click to select this cell.", 0.45, 0.9, 0.65, true)
    GameTooltip:Show()
end

Tooltips.TooltipTitle = TooltipTitle
Tooltips.ShowCellTooltip = ShowCellTooltip
