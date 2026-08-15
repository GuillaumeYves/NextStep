local _, NS = ...

NS.Recommendation = NS.Recommendation or {}
local Rules = {}
NS.Recommendation.Rules = Rules

local typeLabels = {
    dungeon = NS.L.VAULT_TYPE_DUNGEON,
    raid = NS.L.VAULT_TYPE_RAID,
    pvp = NS.L.VAULT_TYPE_PVP,
    world = NS.L.VAULT_TYPE_WORLD,
    concession = NS.L.VAULT_TYPE_CONCESSION,
    unknown = NS.L.VAULT_TYPE_UNKNOWN,
}

function Rules:Leveling(state)
    local character = state.character or {}
    if type(character.level) ~= "number" or type(character.maxLevel) ~= "number" then
        return nil
    end
    if character.level >= character.maxLevel then
        return nil
    end

    return NS.Model.Recommendation:New({
        id = "continue_leveling",
        rule = "Leveling",
        category = "leveling",
        priority = NS.Recommendation.Scoring.PRIORITY.LEVELING,
        importance = NS.Constants.IMPORTANCE.HIGH,
        title = NS.L.LEVELING_TITLE,
        description = NS.L.LEVELING_DESCRIPTION,
        reason = NS.Recommendation.Reasons.LEVELING,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "character",
    })
end

local function buildVaultDescription(activity)
    local metadata = activity.metadata or {}
    local missing = math.max(0, (metadata.threshold or 0) - (metadata.progress or 0))
    local label = typeLabels[metadata.vaultTypeKey] or typeLabels.unknown
    local noun = NS.Util.Formatting:Plural(missing, label)
    return string.format("Complete %d more qualifying %s.", missing, noun)
end

function Rules:GreatVault(state)
    local character = state.character or {}
    if type(character.level) == "number" and type(character.maxLevel) == "number"
        and character.level < character.maxLevel then
        return nil
    end

    local vault = state.vault or {}
    if not vault.dataReady or vault.retired == true then
        return nil
    end

    local recommendations = {}
    if vault.rewardsAvailable then
        recommendations[#recommendations + 1] = NS.Model.Recommendation:New({
            id = "vault_claim_reward",
            rule = "GreatVault",
            category = "weekly",
            priority = NS.Recommendation.Scoring.PRIORITY.VAULT_CLAIM,
            importance = NS.Constants.IMPORTANCE.CRITICAL,
            title = NS.L.VAULT_CLAIM_TITLE,
            description = NS.L.VAULT_CLAIM_DESCRIPTION,
            reason = NS.Recommendation.Reasons.VAULT_CLAIM,
            status = NS.Constants.STATUS.AVAILABLE,
            source = "great_vault",
        })
    end

    local nextByType = {}
    for _, activity in ipairs(vault.activities or {}) do
        local metadata = activity.metadata or {}
        local key = metadata.vaultTypeKey or "unknown"
        local threshold = metadata.threshold or 0
        if activity.available and not activity.completed and threshold > 0 then
            local current = nextByType[key]
            if not current or threshold < (current.metadata.threshold or math.huge) then
                nextByType[key] = activity
            end
        end
    end

    for _, key in ipairs({ "dungeon", "raid", "world", "pvp", "concession", "unknown" }) do
        local activity = nextByType[key]
        if activity then
            local index = activity.metadata.index or 0
            recommendations[#recommendations + 1] = NS.Model.Recommendation:New({
                id = activity.id .. "_unlock",
                rule = "GreatVault",
                category = "weekly",
                priority = NS.Recommendation.Scoring:GetVaultPriority(index),
                importance = NS.Constants.IMPORTANCE.HIGH,
                title = NS.L.VAULT_UNLOCK_TITLE,
                description = buildVaultDescription(activity),
                reason = NS.Recommendation.Reasons.VAULT_UNLOCK,
                status = NS.Constants.STATUS.AVAILABLE,
                source = "great_vault",
                metadata = {
                    activityID = activity.id,
                    vaultTypeKey = key,
                    threshold = activity.metadata.threshold,
                    progress = activity.metadata.progress,
                },
            })
        end
    end

    return #recommendations > 0 and recommendations or nil
end

Rules.ORDER = {
    { name = "Leveling", callback = function(state) return Rules:Leveling(state) end },
    { name = "GreatVault", callback = function(state) return Rules:GreatVault(state) end },
}
