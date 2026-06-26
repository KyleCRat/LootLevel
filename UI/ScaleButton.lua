local ADDON_NAME, NS = ...

local UI = NS.UI

function UI.RefreshCombatLockoutControls()
    local locked = NS.IsCombatLocked and NS:IsCombatLocked()

    if NS.scaleButton then
        NS.scaleButton:SetAlpha(locked and 0.45 or 1)
        NS.scaleButton:EnableMouse(not locked)
    end

    if locked and NS.scalePopup and NS.scalePopup.Hide then
        NS.scalePopup:Hide()
    end

    if locked and UI.ScaleLayout and UI.ScaleLayout.EndPreview then
        UI.ScaleLayout.EndPreview()
    end

    if UI.LayerSelector and UI.LayerSelector.Refresh then
        UI.LayerSelector.Refresh()
    end
end

function UI.CreateScaleButton(parent)
    local button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    UI.SetLayoutBox(button, "TOPRIGHT", parent, "TOPRIGHT", -38, -7, 46, 20)

    if button.SetBackdrop then
        button:SetBackdrop(UI.FrameBackdrop)
        button:SetBackdropColor(0.18, 0.18, 0.18, 0.95)
        button:SetBackdropBorderColor(0, 0, 0, 1)
    end

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    UI.ApplyTexturePixelSnapping(highlight)
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.18)

    local label = UI.CreateText(button, UI.FormatScalePercent(UI.GetScalePercent()), { size = 10 }, "white", "CENTER", "MIDDLE", true)
    UI.SetLayoutBox(label, "CENTER", button, "CENTER", 0, 0, 42, 16)
    NS.scaleButtonText = label
    NS.scaleButton = button

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Scale", 1, 1, 1)
        GameTooltip:AddLine("Drag to resize the table in pixel-snapped steps.", 0.85, 0.85, 0.85, true)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local slider = LibStub and LibStub("LibPopupSlider-1.0", true)
    if slider then
        local popup = slider:Create(button, {
            minValue = UI.Scale.minPercent,
            maxValue = UI.Scale.maxPercent,
            step = UI.Scale.stepPercent,
            label = "Scale",
            formatValue = UI.FormatScalePercent,
            sliderHeight = 130,
            popupWidth = 48,
            thumbSize = 18,
            markerSize = 6,
            font = NS.FONT_BOLD_PATH,
            fontFlags = "",
            fontSize = 10,
            valueFitText = "200%",
            onValueChanged = function(value)
                NS:SetFrameScalePercent(value)
            end,
        })
        popup:SetValue(UI.GetScalePercent(), true)
        NS.scalePopup = popup
    else
        button:SetScript("OnMouseDown", function()
            NS:Print("LibPopupSlider-1.0 is not loaded.")
        end)
    end

    UI.RefreshCombatLockoutControls()
    return button
end
