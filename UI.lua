local ADDON_NAME, NS = ...

local UI = NS.UI

function NS:HandleCellClick(cellData, button)
    local tooltipTitle = UI.Tooltips and UI.Tooltips.TooltipTitle
    local label = tooltipTitle and tooltipTitle(cellData) or cellData and cellData.colTitle or "cell"
    if button == "RightButton" then
        self:Print(("Right-clicked %s."):format(label))
    else
        self:Print(("Selected %s."):format(label))
    end
end
