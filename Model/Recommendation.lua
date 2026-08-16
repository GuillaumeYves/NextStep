local _, NS = ...

NS.Model = NS.Model or {}
local Recommendation = {}
NS.Model.Recommendation = Recommendation

function Recommendation:New(values)
    values = values or {}
    return {
        id = values.id,
        rule = values.rule,
        category = values.category,
        priority = values.priority,
        importance = values.importance,
        title = values.title,
        description = values.description,
        reason = values.reason,
        status = values.status,
        source = values.source,
        goals = values.goals or {},
        estimatedMinutes = values.estimatedMinutes,
        actionData = values.actionData,
        metadata = values.metadata or {},
    }
end

function Recommendation:IsValid(value)
    return type(value) == "table"
        and type(value.id) == "string"
        and value.id ~= ""
        and type(value.title) == "string"
        and type(value.reason) == "string"
        and type(value.priority) == "number"
        and NS.Constants.IMPORTANCE_SCORE[value.importance] ~= nil
end
