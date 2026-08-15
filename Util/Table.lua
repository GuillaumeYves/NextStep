local _, NS = ...

NS.Util = NS.Util or {}
local TableUtil = {}
NS.Util.Table = TableUtil

function TableUtil:Copy(source)
    if type(source) ~= "table" then
        return source
    end

    local result = {}
    for key, value in pairs(source) do
        result[key] = self:Copy(value)
    end
    return result
end

function TableUtil:ApplyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = self:Copy(value)
        elseif type(value) == "table" and type(target[key]) == "table" then
            self:ApplyDefaults(target[key], value)
        end
    end
end

function TableUtil:Append(target, values)
    if type(values) ~= "table" then
        return
    end

    for _, value in ipairs(values) do
        target[#target + 1] = value
    end
end
