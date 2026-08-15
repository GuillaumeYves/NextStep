local _, NS = ...

NS.Data = NS.Data or {}
local Experience = {}
NS.Data.Experience = Experience

function Experience:Collect()
    local current, maximum, rested, ready = NS.API.WoW:GetExperience()
    local percent
    local restedPercent

    if type(maximum) == "number" and maximum > 0 then
        percent = math.max(0, math.min(100, ((current or 0) / maximum) * 100))
        if type(rested) == "number" then
            restedPercent = math.max(0, (rested / maximum) * 100)
        end
    end

    return {
        current = current,
        maximum = maximum,
        rested = rested,
        percent = percent,
        restedPercentOfLevel = restedPercent,
    }, ready
end
