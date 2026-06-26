local ADDON_NAME, NS = ...

local Helpers = {}
NS.Helpers = Helpers

local function ShallowCopy(source)
    if type(source) ~= "table" then
        return nil
    end

    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function ShallowAssign(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return target
    end

    for key, value in pairs(source) do
        target[key] = value
    end
    return target
end

local function ShallowMerge(base, override)
    local merged = ShallowCopy(base) or {}
    ShallowAssign(merged, override)
    return merged
end

Helpers.ShallowCopy = ShallowCopy
Helpers.ShallowAssign = ShallowAssign
Helpers.ShallowMerge = ShallowMerge
