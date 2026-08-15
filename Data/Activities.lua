local _, NS = ...

NS.Data = NS.Data or {}
local Activities = {}
NS.Data.Activities = Activities

function Activities:Collect(vault)
    local activities = {}
    NS.Util.Table:Append(activities, vault.activities)
    return activities
end
