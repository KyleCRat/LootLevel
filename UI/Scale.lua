local ADDON_NAME, NS = ...

local UI = NS.UI

function NS:SetFrameScalePercent(value, silent)
    if not self.db then
        return
    end

    local percent = UI.NormalizeScalePercent(value)
    self.db.scalePercent = percent

    UI.ScaleLayout.BeginPreview()
    UI.RefreshScaledLayout(false)
    UI.ScaleLayout.ScheduleDeferredRefresh()

    if self.scalePopup then
        self.scalePopup:SetValue(percent, true)
    end

    if self.frame then
        UI.SnapFramePosition(self.frame)
        if not silent then
            self:SaveFramePosition(self.frame)
        end
    end
end
