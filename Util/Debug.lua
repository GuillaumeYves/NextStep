local _, NS = ...

NS.Util = NS.Util or {}
local Debug = {}
NS.Util.Debug = Debug

local function serializeValue(value, depth, visited, indent)
    local valueType = type(value)
    if valueType == "string" then
        return string.format("%q", value)
    end
    if valueType ~= "table" then
        return tostring(value)
    end
    if visited[value] then
        return "<cycle>"
    end
    if depth <= 0 then
        return "<table>"
    end

    visited[value] = true
    local lines = { "{" }
    local nextIndent = indent .. "  "
    local keys = {}
    for key in pairs(value) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    for _, key in ipairs(keys) do
        local rendered = serializeValue(value[key], depth - 1, visited, nextIndent)
        lines[#lines + 1] = nextIndent .. "[" .. tostring(key) .. "] = " .. rendered .. ","
    end
    lines[#lines + 1] = indent .. "}"
    visited[value] = nil
    return table.concat(lines, "\n")
end

function Debug:Serialize(value, depth)
    return serializeValue(value, depth or 6, {}, "")
end
