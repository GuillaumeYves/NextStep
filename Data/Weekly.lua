local _, NS = ...

NS.Data = NS.Data or {}
local Weekly = {}
NS.Data.Weekly = Weekly

function Weekly:Collect(vault)
    local completed = 0
    local total = 0

    for _, activity in ipairs(vault.activities or {}) do
        total = total + 1
        if activity.completed then
            completed = completed + 1
        end
    end

    return {
        vault = {
            completedOptions = completed,
            totalOptions = total,
            rewardsAvailable = vault.rewardsAvailable,
        },
    }
end
