local _, NS = ...

local Planner = NS:RegisterModule("Planner", {})
NS.Planner = Planner

function Planner:Build(state, recommendations)
    local settings = NS.db.settings
    local maximum = tonumber(settings.maximumRecommendations) or NS.Constants.DEFAULT_MAX_RECOMMENDATIONS
    maximum = math.max(NS.Constants.MIN_RECOMMENDATIONS, math.min(NS.Constants.MAX_RECOMMENDATIONS, maximum))

    local selected = {}
    for _, recommendation in ipairs(recommendations or {}) do
        local isOptional = recommendation.importance == NS.Constants.IMPORTANCE.OPTIONAL
        local isCompleted = recommendation.status == NS.Constants.STATUS.COMPLETED
        if not isCompleted and (settings.showOptionalRecommendations or not isOptional) then
            selected[#selected + 1] = recommendation
            if #selected >= maximum then
                break
            end
        end
    end

    return {
        generatedAt = state.generatedAt,
        recommendations = selected,
        isFallback = #selected == 0,
        fallbackMessage = NS.L.FALLBACK,
    }
end
