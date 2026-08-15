local _, NS = ...

NS.Util = NS.Util or {}
local SafeCall = {}
NS.Util.SafeCall = SafeCall

function SafeCall:Invoke(callback, ...)
    if type(callback) ~= "function" then
        return false
    end

    local results = { pcall(callback, ...) }
    if not results[1] then
        if NS.db and NS.db.settings.debugMode then
            NS:Print(string.format(NS.L.API_CALL_FAILED, tostring(results[2])))
        end
        return false
    end

    table.remove(results, 1)
    return true, unpack(results)
end
