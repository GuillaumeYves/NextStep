local _, NS = ...

local function merge(target, source)
    for key, value in pairs(source or {}) do
        if type(value) == "table" then
            target[key] = type(target[key]) == "table" and target[key] or {}
            merge(target[key], value)
        else
            target[key] = value
        end
    end
    return target
end

local clientLocale = NS.API.WoW:GetLocale()
local selectedLocale = NS.Locales[clientLocale] and clientLocale or "enUS"

NS.clientLocale = clientLocale
NS.selectedLocale = selectedLocale
NS.L = merge({}, NS.Locales.enUS)
if selectedLocale ~= "enUS" then
    merge(NS.L, NS.Locales[selectedLocale])
end
