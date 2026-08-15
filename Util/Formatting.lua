local _, NS = ...

NS.Util = NS.Util or {}
local Formatting = {}
NS.Util.Formatting = Formatting

function Formatting:Number(value, fallback)
    if type(value) ~= "number" then
        return fallback or "Unavailable"
    end
    return BreakUpLargeNumbers(math.floor(value + 0.5))
end

function Formatting:ItemLevel(value)
    if type(value) ~= "number" or value <= 0 then
        return "Unavailable"
    end
    return string.format("%.1f", value)
end

function Formatting:Plural(count, singular, plural)
    if count == 1 then
        return singular
    end
    if plural then
        return plural
    end
    if singular:sub(-1) == "y" then
        return singular:sub(1, -2) .. "ies"
    end
    return singular .. "s"
end

function Formatting:CharacterKey(character)
    local name = character and character.name or "Unknown"
    local realm = character and character.realm or "Unknown"
    return name .. "-" .. realm
end
