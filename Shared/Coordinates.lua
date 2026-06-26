local ADDON_NAME, NS = ...

local Coordinates = {}
NS.Coordinates = Coordinates

local function ColumnName(index)
    index = tonumber(index)
    if not index or index < 1 then
        return nil
    end

    local name = ""
    while index > 0 do
        local remainder = (index - 1) % 26
        name = string.char(97 + remainder) .. name
        index = math.floor((index - 1) / 26)
    end

    return name
end

local function ColumnIndex(column)
    if type(column) == "number" then
        return column
    end

    column = tostring(column or ""):lower()
    local index = 0
    for position = 1, #column do
        local byte = string.byte(column, position)
        if byte < 97 or byte > 122 then
            return nil
        end
        index = (index * 26) + (byte - 96)
    end

    return index > 0 and index or nil
end

local function CoordFromIndex(column, row)
    local columnName = ColumnName(ColumnIndex(column))
    row = tonumber(row)
    if not columnName or not row then
        return nil
    end

    return ("%s%d"):format(columnName, row)
end

local function NormalizeCoord(coord)
    if type(coord) == "table" then
        if coord.coord then
            return NormalizeCoord(coord.coord)
        end
        if coord.col and coord.row then
            return CoordFromIndex(coord.col, coord.row)
        end
        if coord[1] and coord[2] then
            return CoordFromIndex(coord[1], coord[2])
        end
    end

    local text = tostring(coord or ""):lower()
    local column, row = text:match("^%s*([a-z]+)(%d+)%s*$")
    if not column or not row then
        return nil
    end

    return ("%s%d"):format(column, tonumber(row))
end

local function ParseCoord(coord)
    coord = NormalizeCoord(coord)
    if not coord then
        return nil, nil, nil
    end

    local column, row = coord:match("^([a-z]+)(%d+)$")
    return ColumnIndex(column), tonumber(row), coord
end

local function CellCoordinate(definition)
    return definition and NormalizeCoord(definition)
end

local function NormalizeCellRange(startCoord, endCoord)
    local startColumn, startRow = ParseCoord(startCoord)
    local endColumn, endRow = ParseCoord(endCoord or startCoord)
    if not startColumn or not endColumn or not startRow or not endRow then
        return nil
    end

    if startColumn > endColumn then
        startColumn, endColumn = endColumn, startColumn
    end
    if startRow > endRow then
        startRow, endRow = endRow, startRow
    end

    local coordinates = {}
    for row = startRow, endRow do
        for column = startColumn, endColumn do
            coordinates[#coordinates + 1] = CoordFromIndex(column, row)
        end
    end

    return {
        fromColumn = startColumn,
        toColumn = endColumn,
        fromRow = startRow,
        toRow = endRow,
        fromCoord = CoordFromIndex(startColumn, startRow),
        toCoord = CoordFromIndex(endColumn, endRow),
        coordinates = coordinates,
    }
end

local function NormalizeCellSpan(anchorColumn, anchorRow, definition)
    local fromColumn = tonumber(definition and (definition.gridFromColumn or definition.fromColumn)) or anchorColumn
    local toColumn = tonumber(definition and (definition.gridToColumn or definition.toColumn)) or anchorColumn
    local fromRow = tonumber(definition and (definition.gridFromRow or definition.fromRow)) or anchorRow
    local toRow = tonumber(definition and (definition.gridToRow or definition.toRow)) or anchorRow

    if not fromColumn or not toColumn or not fromRow or not toRow then
        return nil
    end

    if fromColumn > toColumn then
        fromColumn, toColumn = toColumn, fromColumn
    end
    if fromRow > toRow then
        fromRow, toRow = toRow, fromRow
    end

    return {
        fromColumn = fromColumn,
        toColumn = toColumn,
        fromRow = fromRow,
        toRow = toRow,
    }
end

local function ForEachCellSpanCoord(span, callback)
    if not span or type(callback) ~= "function" then
        return
    end

    for row = span.fromRow, span.toRow do
        for column = span.fromColumn, span.toColumn do
            callback(column, row, CoordFromIndex(column, row))
        end
    end
end

local function CoordKey(tableKey, coord)
    coord = NormalizeCoord(coord)
    if not coord then
        return nil
    end

    return ("%s:%s"):format(tableKey or "main", coord)
end

Coordinates.ColumnName = ColumnName
Coordinates.ColumnKeyFromIndex = ColumnName
Coordinates.ColumnIndex = ColumnIndex
Coordinates.CoordFromIndex = CoordFromIndex
Coordinates.NormalizeCoord = NormalizeCoord
Coordinates.ParseCoord = ParseCoord
Coordinates.CellCoordinate = CellCoordinate
Coordinates.NormalizeCellRange = NormalizeCellRange
Coordinates.NormalizeCellSpan = NormalizeCellSpan
Coordinates.ForEachCellSpanCoord = ForEachCellSpanCoord
Coordinates.CoordKey = CoordKey
