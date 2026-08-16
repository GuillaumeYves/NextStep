local _, NS = ...

NS.Util = NS.Util or {}
local RecommendationNavigation = {}
NS.Util.RecommendationNavigation = RecommendationNavigation

function RecommendationNavigation:ResolveIndex(recommendations, currentIndex, currentID)
    local count = type(recommendations) == "table" and #recommendations or 0
    if count == 0 then
        return 0
    end

    if currentID then
        for index, recommendation in ipairs(recommendations) do
            if recommendation.id == currentID then
                return index
            end
        end
    end

    local index = tonumber(currentIndex) or 1
    return math.max(1, math.min(count, math.floor(index)))
end

function RecommendationNavigation:Move(currentIndex, count, direction)
    count = math.max(0, tonumber(count) or 0)
    if count == 0 then
        return 0
    end

    local index = tonumber(currentIndex) or 1
    local delta = tonumber(direction) or 0
    return math.max(1, math.min(count, math.floor(index + delta)))
end
