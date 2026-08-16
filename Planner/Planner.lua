local _, NS = ...

local Planner = NS:RegisterModule("Planner", {})
NS.Planner = Planner

local function matchesCharacterGoals(recommendation, profile)
    if recommendation.importance == NS.Constants.IMPORTANCE.CRITICAL then
        return true
    end
    if type(profile) ~= "table" or type(profile.goals) ~= "table"
        or type(recommendation.goals) ~= "table" or #recommendation.goals == 0 then
        return true
    end

    for _, goal in ipairs(recommendation.goals) do
        if profile.goals[goal] == true then
            return true
        end
    end
    return false
end

function Planner:Build(state, recommendations)
    local settings = NS.db.settings
    local profile = NS.Config:GetCharacterProfile(state.character, true)
    local maximum = tonumber(settings.maximumRecommendations) or NS.Constants.DEFAULT_MAX_RECOMMENDATIONS
    maximum = math.max(NS.Constants.MIN_RECOMMENDATIONS, math.min(NS.Constants.MAX_RECOMMENDATIONS, maximum))

    local selected = {}
    for _, recommendation in ipairs(recommendations or {}) do
        local isOptional = recommendation.importance == NS.Constants.IMPORTANCE.OPTIONAL
        local isCompleted = recommendation.status == NS.Constants.STATUS.COMPLETED
        if not isCompleted and matchesCharacterGoals(recommendation, profile)
            and (settings.showOptionalRecommendations or not isOptional) then
            selected[#selected + 1] = recommendation
            if #selected >= maximum then
                break
            end
        end
    end

    local hasUnmatchedRecommendations = #selected == 0 and #(recommendations or {}) > 0
    return {
        generatedAt = state.generatedAt,
        recommendations = selected,
        isFallback = #selected == 0,
        fallbackMessage = hasUnmatchedRecommendations and NS.L.FALLBACK_SELECTED_GOALS or NS.L.FALLBACK,
    }
end
