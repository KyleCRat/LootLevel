local ADDON_NAME, NS = ...

local UI = NS.UI
local Helpers = NS.Helpers
local Fonts = {}
UI.Fonts = Fonts

local VALID_FONT_FLAGS = {
    [""] = true,
    OUTLINE = true,
    THICKOUTLINE = true,
    OUTLINESLUG = true,
    MONOCHROMEOUTLINE = true,
    MONOCHROMETHICKOUTLINE = true,
}

local function NormalizeFontFlagString(value)
    local flags = tostring(value or ""):upper():gsub("[%s,]+", "")
    if VALID_FONT_FLAGS[flags] then
        return flags
    end

    return ""
end

local function NormalizeFontOutline(value)
    if value == true then
        return "OUTLINE"
    end
    if value == false or value == nil then
        return ""
    end

    local outline = tostring(value):lower()
    if outline == "normal" or outline == "outline" then
        return "OUTLINE"
    end
    if outline == "thick" or outline == "thickoutline" then
        return "THICKOUTLINE"
    end
    if outline == "slug" or outline == "outlineslug" then
        return "OUTLINESLUG"
    end
    if outline == "mono" or outline == "monochrome" or outline == "monochromeoutline" then
        return "MONOCHROMEOUTLINE"
    end
    if outline == "monothick" or outline == "monochromethick" or outline == "monochromethickoutline" then
        return "MONOCHROMETHICKOUTLINE"
    end

    return ""
end

local function FontFlags(font)
    if type(font) ~= "table" then
        return ""
    end

    if font.flags ~= nil then
        return NormalizeFontFlagString(font.flags)
    end

    local outlineValue = font.outline
    if outlineValue == nil then
        outlineValue = font.border
    end

    local outline = NormalizeFontOutline(outlineValue)
    local monochrome = font.monochrome == true
    local slug = font.slug == true

    if outline == "OUTLINESLUG" or outline == "MONOCHROMEOUTLINE" or outline == "MONOCHROMETHICKOUTLINE" then
        return outline
    end

    if monochrome then
        if outline == "THICKOUTLINE" then
            return "MONOCHROMETHICKOUTLINE"
        end
        if outline == "OUTLINE" then
            return "MONOCHROMEOUTLINE"
        end
        return ""
    end

    if outline == "THICKOUTLINE" then
        return "THICKOUTLINE"
    end
    if outline == "OUTLINE" then
        return slug and "OUTLINESLUG" or "OUTLINE"
    end

    return ""
end

local function FontSize(font, fallbackSize)
    if type(font) == "table" then
        return tonumber(font.size) or fallbackSize
    end

    return fallbackSize
end

local function FontWithFallbackSize(font, fallbackSize)
    if type(font) ~= "table" then
        return { size = fallbackSize }
    end

    local copy = Helpers.ShallowCopy(font) or {}
    if copy.size == nil then
        copy.size = fallbackSize
    end

    return copy
end

local function ResolveTextFont(font, fallbackSize, bold)
    local size = math.max(1, FontSize(font, fallbackSize or 12))
    local path = bold and NS.FONT_BOLD_PATH or NS.FONT_PATH
    if type(font) == "table" and type(font.path) == "string" then
        path = font.path
    end

    return {
        path = path,
        size = size,
        flags = FontFlags(font),
    }
end

local function ApplyFontRecord(record)
    local fontString = record.fontString
    if not fontString then
        return
    end

    local size = math.max(1, UI.ScalePixel(record.size))
    fontString:SetFont(record.path, size, record.flags or "")
end

local function RegisterFontRecord(record)
    local scaleLayout = UI.ScaleLayout
    if (scaleLayout and (scaleLayout.deferredDepth or 0) > 0)
        or (record.fontString and record.fontString.deferScaleLayout)
    then
        record.deferScaleLayout = true
    end

    NS.layoutFonts = NS.layoutFonts or {}
    NS.layoutFonts[#NS.layoutFonts + 1] = record
    ApplyFontRecord(record)
    return record
end

local function RefreshScaledFonts(includeDeferred)
    for _, record in ipairs(NS.layoutFonts or {}) do
        if includeDeferred or not record.deferScaleLayout then
            ApplyFontRecord(record)
        end
    end
end

local function CreateText(parent, text, font, colorName, justifyH, justifyV, bold)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    local resolvedFont = ResolveTextFont(font, 12, bold)
    RegisterFontRecord({
        fontString = fs,
        path = resolvedFont.path,
        size = resolvedFont.size,
        flags = resolvedFont.flags,
    })
    fs:SetText(text or "")
    fs:SetJustifyH(justifyH or "CENTER")
    fs:SetJustifyV(justifyV or "MIDDLE")
    fs:SetTextColor(UI.Color(colorName or "black"))
    if fs.SetWordWrap then
        fs:SetWordWrap(false)
    end
    return fs
end

Fonts.NormalizeFlagString = NormalizeFontFlagString
Fonts.NormalizeOutline = NormalizeFontOutline
Fonts.Flags = FontFlags
Fonts.Size = FontSize
Fonts.WithFallbackSize = FontWithFallbackSize
Fonts.ResolveTextFont = ResolveTextFont
Fonts.RegisterRecord = RegisterFontRecord
Fonts.RefreshScaled = RefreshScaledFonts
Fonts.CreateText = CreateText

UI.FontSize = FontSize
UI.FontWithFallbackSize = FontWithFallbackSize
UI.ResolveTextFont = ResolveTextFont
UI.RegisterFontRecord = RegisterFontRecord
UI.RefreshScaledFonts = RefreshScaledFonts
UI.CreateText = CreateText
