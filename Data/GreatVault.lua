local _, NS = ...

NS.Data = NS.Data or {}
local GreatVault = {}
NS.Data.GreatVault = GreatVault

local typeNames = {
    dungeon = "Great Vault dungeon progress",
    raid = "Great Vault raid progress",
    pvp = "Great Vault rated PvP progress",
    world = "Great Vault world progress",
    concession = "Great Vault activity progress",
    unknown = "Great Vault progress",
}

function GreatVault:Collect()
    local rawActivities, dataReady = NS.API.WoW:GetWeeklyRewardActivities()
    local retired = NS.API.WoW:IsWeeklyChestRetired()
    local rewardsAvailable = NS.API.WoW:HasAvailableWeeklyRewards()
    local normalized = {}

    for _, info in ipairs(rawActivities) do
        if type(info) == "table" then
            local typeKey = NS.API.WoW:GetWeeklyRewardTypeKey(info.type)
            local progress = tonumber(info.progress) or 0
            local threshold = tonumber(info.threshold) or 0
            local index = tonumber(info.index) or 0

            normalized[#normalized + 1] = NS.Model.Activity:New({
                id = string.format("vault_%s_%d", typeKey, index),
                type = NS.Constants.ACTIVITY_TYPE.GREAT_VAULT,
                name = typeNames[typeKey] or typeNames.unknown,
                available = retired ~= true,
                completed = threshold > 0 and progress >= threshold,
                repeatable = true,
                progressionTags = { "weekly", "great_vault", typeKey },
                source = "great_vault",
                metadata = {
                    vaultType = info.type,
                    vaultTypeKey = typeKey,
                    index = index,
                    threshold = threshold,
                    progress = progress,
                    activityTierID = info.activityTierID,
                    level = info.level,
                },
            })
        end
    end

    table.sort(normalized, function(a, b)
        local aOrder = NS.ActivityConfig.vaultTypeOrder[a.metadata.vaultTypeKey] or 99
        local bOrder = NS.ActivityConfig.vaultTypeOrder[b.metadata.vaultTypeKey] or 99
        if aOrder == bOrder then
            return (a.metadata.index or 0) < (b.metadata.index or 0)
        end
        return aOrder < bOrder
    end)

    return {
        available = dataReady and retired ~= true,
        dataReady = dataReady,
        retired = retired,
        activities = normalized,
        rewardsAvailable = rewardsAvailable == true,
    }, dataReady
end
