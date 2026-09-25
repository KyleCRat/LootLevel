local ADDON_NAME, NS = ...

local UI = NS.UI
local CellBackgrounds = {}
UI.CellBackgrounds = CellBackgrounds

local function CreateTexture(cell)
    local texture = cell:CreateTexture(nil, "BACKGROUND")
    UI.ApplyTexturePixelSnapping(texture)
    texture:SetAllPoints(cell)
    return texture
end

local function LayoutSplit(cell, width, height)
    local split = cell.splitBg
    if width <= 0 or height <= 0 or (split.width == width and split.height == height) then
        return
    end
    split.width, split.height = width, height

    local diagonal = math.sqrt(width * width + height * height)
    local rotation = math.atan2(height, width)
    -- Rotated rectangle edges meet along the bottom-left to top-right diagonal.
    -- Perpendicular offsets keep both halves exact even for non-square cells.
    for index, part in ipairs(split) do
        local direction = index == 1 and 1 or -1
        part.mask:ClearAllPoints()
        part.mask:SetSize(diagonal * 2, diagonal)
        part.mask:SetPoint("CENTER", cell, "CENTER", -direction * height / 2, direction * width / 2)
        part.mask:SetRotation(rotation)
    end
end

local function CreateSplit(cell)
    local split = {}
    for index = 1, 2 do
        local texture = CreateTexture(cell)
        local mask = cell:CreateMaskTexture()
        mask:SetTexture("Interface\\Masks\\SquareMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetSnapToPixelGrid(false)
        mask:SetTexelSnappingBias(0)
        texture:AddMaskTexture(mask)
        split[index] = { texture = texture, mask = mask }
    end
    cell.splitBg = split
    -- Use the final rounded cell size, after deferred table scaling has finished.
    cell:HookScript("OnSizeChanged", LayoutSplit)
    LayoutSplit(cell, cell:GetWidth(), cell:GetHeight())
    return split
end

function CellBackgrounds.Create(cell)
    cell.bg = CreateTexture(cell)
end

-- bg accepts a color key/RGBA or { topLeft = color, bottomRight = color }.
function CellBackgrounds.Apply(cell, bg)
    if type(bg) == "table" and (bg.topLeft ~= nil or bg.bottomRight ~= nil) then
        assert(bg.topLeft ~= nil and bg.bottomRight ~= nil, "LootLevel: split backgrounds require both corner colors")
        local topR, topG, topB, topA = UI.Color(bg.topLeft)
        local bottomR, bottomG, bottomB, bottomA = UI.Color(bg.bottomRight)
        if topR ~= bottomR or topG ~= bottomG or topB ~= bottomB or topA ~= bottomA then
            local split = cell.splitBg or CreateSplit(cell)
            cell.bg:Hide()
            split[1].texture:SetColorTexture(topR, topG, topB, topA)
            split[2].texture:SetColorTexture(bottomR, bottomG, bottomB, bottomA)
            split[1].texture:Show()
            split[2].texture:Show()
            return
        end
        bg = bg.bottomRight
    end

    if cell.splitBg then
        for _, part in ipairs(cell.splitBg) do
            part.texture:Hide()
        end
    end
    cell.bg:SetColorTexture(UI.Color(bg))
    cell.bg:Show()
end
