local ADDON_NAME, NS = ...

local UI = NS.UI
local Borders = UI.Borders
local CellStyles = UI.CellStyles
local GridLines = UI.GridLines
local Layers = UI.Layers
local RenderCache = {}
UI.RenderCache = RenderCache

local function RegisterGridParent(parent)
    if not parent or parent.gridParentRegistered then
        return
    end

    parent.gridParentRegistered = true
    NS.gridParents = NS.gridParents or {}
    NS.gridParents[#NS.gridParents + 1] = parent
end

local function ForEachRegisteredGridCell(parent, callback)
    if not parent or type(callback) ~= "function" then
        return
    end

    local seenCells = {}
    for _, grid in pairs(parent.gridTables or {}) do
        for _, columns in pairs(grid.rows or {}) do
            for _, cell in pairs(columns or {}) do
                if cell and not seenCells[cell] then
                    seenCells[cell] = true
                    callback(cell)
                end
            end
        end
    end
end

function RenderCache.ClearParent(parent, applyVisuals)
    if not parent then
        return
    end

    parent.blocksApplied = false
    parent.blockByCoord = {}
    parent.colorBlocksById = {}
    parent.gridLines = {}
    parent.gridLineBlocks = {}

    ForEachRegisteredGridCell(parent, function(cell)
        local cellData = cell.cellData
        if cellData then
            cellData.block = nil
            cellData.layer = nil
            cellData.layerName = nil
            if cellData.styleLayers then
                cellData.styleLayers.layer = nil
                cellData.styleLayers.block = nil
            end
        end
        if applyVisuals ~= false then
            CellStyles.ApplyCellResolvedStyle(cell)
        end
    end)
end

function RenderCache.CaptureCells(parent)
    local cells = {}

    ForEachRegisteredGridCell(parent, function(cell)
        local cellData = cell.cellData
        if cellData and cell.coordKey then
            cells[cell.coordKey] = {
                block = cellData.block,
                layer = cellData.layer,
                layerName = cellData.layerName,
                bg = cellData.resolvedBg or CellStyles.ResolveCellBackgroundColor(cellData),
                alpha = cellData.resolvedAlpha or CellStyles.ResolveCellVisualAlpha(cellData),
            }
        end
    end)

    return cells
end

function RenderCache.CopyBlockMap(blockByCoord)
    local copy = {}
    for coordKey, block in pairs(blockByCoord or {}) do
        copy[coordKey] = block
    end

    return copy
end

function RenderCache.BuildParent(parent, state)
    local previousContext = Layers.SetRenderContext(state)

    RenderCache.ClearParent(parent, true)
    Borders.BuildBorderGrid(parent)

    local cache = {
        key = state and state.key,
        blockByCoord = RenderCache.CopyBlockMap(parent.blockByCoord),
        cells = RenderCache.CaptureCells(parent),
        gridLines = GridLines.BuildRenderSegments(parent.gridLines),
    }

    Layers.SetRenderContext(previousContext)
    return cache
end

function RenderCache.GetParent(parent, state)
    if not parent then
        return nil
    end

    state = state or Layers.CurrentLayerRenderState()
    local key = state.key or Layers.LayerRenderStateKey(state)
    parent.renderCaches = parent.renderCaches or {}
    if not parent.renderCaches[key] then
        state.key = key
        parent.renderCaches[key] = RenderCache.BuildParent(parent, state)
    end

    return parent.renderCaches[key]
end

function RenderCache.ApplyParent(parent, cache)
    if not parent or not cache then
        return
    end

    parent.blocksApplied = true
    parent.blockByCoord = RenderCache.CopyBlockMap(cache.blockByCoord)
    parent.gridLines = cache.gridLines or {}
    parent.gridLineBlocks = {}

    ForEachRegisteredGridCell(parent, function(cell)
        local cellData = cell.cellData
        local state = cell.coordKey and cache.cells and cache.cells[cell.coordKey] or nil
        if cellData then
            cellData.block = state and state.block or nil
            cellData.layer = state and state.layer or nil
            cellData.layerName = state and state.layerName or nil
            if cellData.styleLayers then
                cellData.styleLayers.layer = nil
                cellData.styleLayers.block = nil
            end
        end

        if state then
            CellStyles.ApplyCellVisualStyle(cell, state.bg, state.alpha)
        else
            CellStyles.ApplyCellResolvedStyle(cell)
        end
    end)
end

function RenderCache.RenderLines(parent, lines)
    if not parent then
        return
    end

    RegisterGridParent(parent)

    local overlay = parent.gridOverlay
    if not overlay then
        overlay = CreateFrame("Frame", nil, parent)
        overlay:EnableMouse(false)
        parent.gridOverlay = overlay
    end
    overlay.deferScaleLayout = parent.deferScaleLayout

    GridLines.ReleaseOverlayLines(overlay)
    overlay:SetAllPoints(parent)
    overlay:SetFrameLevel(parent:GetFrameLevel() + 100)
    overlay:Show()

    for _, line in ipairs(lines or {}) do
        GridLines.RegisterTexture(overlay, line)
    end
end

function RenderCache.RefreshParent(parent, state)
    local cache = RenderCache.GetParent(parent, state or Layers.CurrentLayerRenderState())
    RenderCache.ApplyParent(parent, cache)
    RenderCache.RenderLines(parent, cache and cache.gridLines)
end

function RenderCache.Prewarm()
    local currentState = Layers.CurrentLayerRenderState()

    Layers.ForEachLayerRenderState(function(state)
        for _, parent in ipairs(NS.gridParents or {}) do
            RenderCache.GetParent(parent, state)
        end
    end)

    for _, parent in ipairs(NS.gridParents or {}) do
        RenderCache.RefreshParent(parent, currentState)
    end
end

function UI.DrawGridLines(parent)
    if parent.gridOverlay and parent.gridOverlay:IsShown() then
        return
    end

    RenderCache.RefreshParent(parent)
end

UI.PrewarmLayerRenderCaches = function()
    RenderCache.Prewarm()
end
