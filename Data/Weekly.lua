local _, NS = ...

NS.Data = NS.Data or {}
local Weekly = {}
NS.Data.Weekly = Weekly

function Weekly:Collect(vault)
    local completed = 0
    local total = 0
    local bestRewardItemLevel

    for _, activity in ipairs(vault.activities or {}) do
        total = total + 1
        if activity.completed then
            completed = completed + 1
            local itemLevel = activity.metadata and activity.metadata.rewardItemLevel
            if type(itemLevel) == "number" then
                bestRewardItemLevel = math.max(bestRewardItemLevel or 0, itemLevel)
            end
        end
    end

    local reset, resetReady = NS.API.WoW:GetWeeklyResetInfo()
    return {
        vault = {
            completedOptions = completed,
            totalOptions = total,
            rewardsAvailable = vault.rewardsAvailable,
            bestRewardItemLevel = bestRewardItemLevel,
        },
        reset = {
            dataReady = resetReady,
            secondsUntilReset = reset and reset.secondsUntilReset or nil,
            resetAt = reset and reset.resetAt or nil,
            regionName = reset and reset.regionName or nil,
        },
    }
end
