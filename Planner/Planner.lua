local _, NS = ...

local Planner = NS:RegisterModule("Planner", {})
NS.Planner = Planner

local function hasGoal(recommendation, goal)
    for _, value in ipairs(recommendation.goals or {}) do
        if value == goal then
            return true
        end
    end
    return false
end

function Planner:Build(state, recommendations)
    local settings = NS.db.settings
    NS.Config:GetCharacterProfile(state.character, true)
    local maximum = tonumber(settings.maximumRecommendations) or NS.Constants.DEFAULT_MAX_RECOMMENDATIONS
    maximum = math.max(NS.Constants.MIN_RECOMMENDATIONS, math.min(NS.Constants.MAX_RECOMMENDATIONS, maximum))

    local eligible = {}
    for _, recommendation in ipairs(recommendations or {}) do
        local isOptional = recommendation.importance == NS.Constants.IMPORTANCE.OPTIONAL
        local isCompleted = recommendation.status == NS.Constants.STATUS.COMPLETED
        if not isCompleted and (settings.showOptionalRecommendations or not isOptional) then
            eligible[#eligible + 1] = recommendation
        end
    end

    local selected = {}
    for index = 1, math.min(maximum, #eligible) do
        selected[#selected + 1] = eligible[index]
    end

    local categoryEligible = {}
    for _, recommendation in ipairs(recommendations or {}) do
        if recommendation.status ~= NS.Constants.STATUS.COMPLETED then
            categoryEligible[#categoryEligible + 1] = recommendation
        end
    end

    local categories = {}
    local atMaxLevel = type(state.character.level) == "number"
        and type(state.character.maxLevel) == "number"
        and state.character.level >= state.character.maxLevel
    for _, goal in ipairs(NS.Constants.GOAL_ORDER) do
        local maxLevelOnly = goal == NS.Constants.GOAL.PROGRESSION
        if (goal ~= NS.Constants.GOAL.EXPERIENCE or not atMaxLevel)
            and (not maxLevelOnly or atMaxLevel) then
            local tasks = {}
            for _, recommendation in ipairs(categoryEligible) do
                if hasGoal(recommendation, goal) and recommendation.category ~= "weekly" then
                    tasks[#tasks + 1] = recommendation
                end
            end
            categories[#categories + 1] = {
                id = goal,
                label = NS.L.GOAL_LABELS[goal] or goal,
                tasks = tasks,
            }
        end
    end

    local routePackIsStale = state.curatedRoutes
        and state.curatedRoutes.unavailableReason == "interface_mismatch"
    local fallbackMessage = NS.L.FALLBACK
    if routePackIsStale then
        fallbackMessage = NS.L.FALLBACK_STALE_ROUTE_PACK
    end
    return {
        generatedAt = state.generatedAt,
        recommendations = selected,
        categories = categories,
        isFallback = #selected == 0,
        fallbackMessage = fallbackMessage,
    }
end
