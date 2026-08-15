local _, NS = ...

NS.Model = NS.Model or {}
local Activity = {}
NS.Model.Activity = Activity

function Activity:New(values)
    values = values or {}
    return {
        id = values.id,
        type = values.type,
        name = values.name,
        available = values.available,
        completed = values.completed,
        repeatable = values.repeatable,
        rewardSummary = values.rewardSummary,
        progressionTags = values.progressionTags or {},
        lockout = values.lockout,
        source = values.source,
        metadata = values.metadata or {},
    }
end
