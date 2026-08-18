local _, NS = ...

NS.Data = NS.Data or {}
local PatchProgress = {}
NS.Data.PatchProgress = PatchProgress

local function copyGroup(id, source)
    source = source or {}
    return {
        id = id,
        current = tonumber(source.current) or 0,
        total = tonumber(source.total) or 0,
        entries = source.entries,
        dataReady = source.dataReady == true or (tonumber(source.total) or 0) > 0,
    }
end

local function collectWeekly(vault)
    local result = { id = "weekly", current = 0, total = 0, entries = {}, dataReady = false }
    if not vault or not vault.dataReady then
        return result
    end
    for _, activity in ipairs(vault.activities or {}) do
        local metadata = activity.metadata or {}
        if activity.available ~= false and (tonumber(metadata.threshold) or 0) > 0 then
            result.total = result.total + 1
            if activity.completed then
                result.current = result.current + 1
            end
            result.entries[#result.entries + 1] = {
                id = activity.id,
                name = activity.name,
                completed = activity.completed == true,
            }
        end
    end
    result.dataReady = result.total > 0
    return result
end

local function sumGroups(groups)
    local result = { current = 0, total = 0, groups = groups, dataReady = false }
    for _, group in ipairs(groups) do
        if group.dataReady then
            result.current = result.current + group.current
            result.total = result.total + group.total
        end
    end
    result.dataReady = result.total > 0
    return result
end

function PatchProgress:Collect(state)
    state = state or {}
    local curatedCompletion = state.curatedRoutes and state.curatedRoutes.completion or {}
    local catalogCompletion = state.patchCatalog and state.patchCatalog.completion or {}

    local campaign = copyGroup("campaign", curatedCompletion.character)
    local weekly = collectWeekly(state.vault)
    local character = sumGroups({ campaign, weekly })

    local mounts = copyGroup("mounts", catalogCompletion.mounts)
    local pets = copyGroup("pets", catalogCompletion.pets)
    local achievements = copyGroup("achievements", catalogCompletion.achievements)
    local account = sumGroups({ mounts, pets, achievements })

    return {
        patch = (state.patchCatalog and state.patchCatalog.patch)
            or (state.curatedRoutes and state.curatedRoutes.patch),
        character = character,
        account = account,
        dataReady = character.dataReady or account.dataReady,
    }
end
