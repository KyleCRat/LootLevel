local ADDON_NAME, NS = ...

local UI = NS.UI
local Coordinates = NS.Coordinates
local Layers = UI.Layers
local LayerResolver = {}
UI.LayerResolver = LayerResolver

local CoordFromIndex = Coordinates.CoordFromIndex
local NormalizeCoord = Coordinates.NormalizeCoord
local NormalizeCellSpan = Coordinates.NormalizeCellSpan
local ForEachCellSpanCoord = Coordinates.ForEachCellSpanCoord

local function DefinitionWinsOver(existing, candidate)
    if not existing then
        return true
    end

    local existingLayerOrder = Layers.LayerRenderOrder(existing.layer)
    local candidateLayerOrder = Layers.LayerRenderOrder(candidate.layer)
    if candidateLayerOrder ~= existingLayerOrder then
        return candidateLayerOrder > existingLayerOrder
    end

    local existingPriority = existing.priority or 0
    local candidatePriority = candidate.priority or 0
    if candidatePriority ~= existingPriority then
        return candidatePriority > existingPriority
    end

    return (candidate.order or 0) >= (existing.order or 0)
end

local function AssignOwner(ownership, coord, definition)
    coord = NormalizeCoord(coord)
    if not coord or not definition or not Layers.IsLayerVisible(definition.layer) then
        return
    end

    if DefinitionWinsOver(ownership[coord], definition) then
        ownership[coord] = definition
    end
end

local function BuildTableOwnership(tableKey)
    local ownership = {}

    for coord, records in pairs((NS.Data.cellRecords and NS.Data.cellRecords[tableKey or "main"]) or {}) do
        for _, record in ipairs(records or {}) do
            AssignOwner(ownership, coord, record)
        end
    end

    for _, mergedCell in ipairs(NS.Data.mergedCells or {}) do
        if mergedCell.table == tableKey and Layers.IsLayerVisible(mergedCell.layer) then
            local span = NormalizeCellSpan(nil, nil, mergedCell.span)
            ForEachCellSpanCoord(span, function(_, _, coord)
                AssignOwner(ownership, coord, mergedCell)
            end)
        end
    end

    return ownership
end

local function OwnerAt(ownership, coord)
    coord = NormalizeCoord(coord)
    return coord and ownership and ownership[coord] or nil
end

local function DefinitionOwnsCoord(ownership, coord, definition)
    return OwnerAt(ownership, coord) == definition
end

local function SpanBounds(fromColumn, toColumn, fromRow, toRow)
    return {
        fromColumn = fromColumn,
        toColumn = toColumn,
        fromRow = fromRow,
        toRow = toRow,
        fromCoord = CoordFromIndex(fromColumn, fromRow),
        toCoord = CoordFromIndex(toColumn, toRow),
    }
end

local function AddVerticalFragments(fragments, owned, column, fromRow, toRow)
    local startRow
    for row = fromRow, toRow do
        local isOwned = owned[row] and owned[row][column]
        if isOwned and not startRow then
            startRow = row
        elseif not isOwned and startRow then
            fragments[#fragments + 1] = SpanBounds(column, column, startRow, row - 1)
            startRow = nil
        end
    end

    if startRow then
        fragments[#fragments + 1] = SpanBounds(column, column, startRow, toRow)
    end
end

local function AddHorizontalFragments(fragments, owned, row, fromColumn, toColumn)
    local startColumn
    for column = fromColumn, toColumn do
        local isOwned = owned[row] and owned[row][column]
        if isOwned and not startColumn then
            startColumn = column
        elseif not isOwned and startColumn then
            fragments[#fragments + 1] = SpanBounds(startColumn, column - 1, row, row)
            startColumn = nil
        end
    end

    if startColumn then
        fragments[#fragments + 1] = SpanBounds(startColumn, toColumn, row, row)
    end
end

local function OwnedSpanFragments(definition, ownership)
    local span = NormalizeCellSpan(nil, nil, definition and definition.span)
    if not span then
        return {}
    end

    local owned = {}
    local anyOwned = false
    local allOwned = true

    ForEachCellSpanCoord(span, function(column, row, coord)
        if DefinitionOwnsCoord(ownership, coord, definition) then
            owned[row] = owned[row] or {}
            owned[row][column] = true
            anyOwned = true
        else
            allOwned = false
        end
    end)

    if not anyOwned then
        return {}
    end

    if allOwned then
        return { span }
    end

    local fragments = {}
    -- Only one-dimensional spans have an obvious partial fallback shape.
    if span.fromColumn == span.toColumn then
        AddVerticalFragments(fragments, owned, span.fromColumn, span.fromRow, span.toRow)
    elseif span.fromRow == span.toRow then
        AddHorizontalFragments(fragments, owned, span.fromRow, span.fromColumn, span.toColumn)
    end

    return fragments
end

LayerResolver.DefinitionWinsOver = DefinitionWinsOver
LayerResolver.BuildTableOwnership = BuildTableOwnership
LayerResolver.OwnerAt = OwnerAt
LayerResolver.DefinitionOwnsCoord = DefinitionOwnsCoord
LayerResolver.OwnedSpanFragments = OwnedSpanFragments
