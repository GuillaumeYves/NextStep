local _, NS = ...

NS.Recommendation = NS.Recommendation or {}
local Engine = {}
NS.Recommendation.Engine = Engine

local function addResult(result, ruleName, recommendations, traceEntry, seen)
    if type(result) ~= "table" then
        return
    end

    local values = result.id and { result } or result
    for _, recommendation in ipairs(values) do
        if NS.Model.Recommendation:IsValid(recommendation) then
            if not seen[recommendation.id] then
                recommendation.rule = recommendation.rule or ruleName
                seen[recommendation.id] = true
                recommendations[#recommendations + 1] = recommendation
                traceEntry.recommendationIDs[#traceEntry.recommendationIDs + 1] = recommendation.id
            end
        else
            traceEntry.invalidResults = traceEntry.invalidResults + 1
        end
    end
end

function Engine:Build(state)
    local recommendations = {}
    local trace = {}
    local seen = {}

    for _, rule in ipairs(NS.Recommendation.Rules.ORDER) do
        local traceEntry = {
            rule = rule.name,
            fired = false,
            recommendationIDs = {},
            invalidResults = 0,
            error = nil,
        }
        local ok, result = pcall(rule.callback, state)
        if ok then
            addResult(result, rule.name, recommendations, traceEntry, seen)
            traceEntry.fired = #traceEntry.recommendationIDs > 0
        else
            traceEntry.error = tostring(result)
        end
        trace[#trace + 1] = traceEntry
    end

    table.sort(recommendations, function(a, b)
        return NS.Recommendation.Scoring:Compare(a, b)
    end)

    return recommendations, trace
end
