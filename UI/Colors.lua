local ADDON_NAME, NS = ...

local UI = NS.UI
local Colors = {}
UI.Colors = Colors

local function Color(name)
    local color = type(name) == "table" and name or NS.Colors[name or "blank"] or NS.Colors.blank
    return color[1], color[2], color[3], color[4] or 1
end

local function TextColorFor(colorName)
    if colorName == "blank" or colorName == "panel" or colorName == "frame" then
        return 1, 1, 1, 1
    end

    return 0, 0, 0, 1
end

Colors.Color = Color
Colors.TextColorFor = TextColorFor
UI.Color = Color
UI.TextColorFor = TextColorFor
