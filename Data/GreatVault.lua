local _, NS = ...

NS.Data = NS.Data or {}
local GreatVault = {}
NS.Data.GreatVault = GreatVault

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
            local preview = NS.API.WoW:GetWeeklyRewardPreview(info.id)
            local encounters = {}
            if typeKey == "raid" then
                encounters = NS.API.WoW:GetWeeklyRewardEncounterInfo(info.type, index)
            end
            local generatedRewardLinks = {}
            for _, reward in ipairs(info.rewards or {}) do
                if type(reward) == "table" and reward.itemDBID ~= nil then
                    local rewardLink = NS.API.WoW:GetWeeklyRewardItemLink(reward.itemDBID)
                    if rewardLink then
                        generatedRewardLinks[#generatedRewardLinks + 1] = rewardLink
                    end
                end
            end
            local nextIncrease = NS.API.WoW:GetNextWeeklyActivityIncrease(
                info.activityTierID,
                info.level
            )

            normalized[#normalized + 1] = NS.Model.Activity:New({
                id = string.format("vault_%s_%d", typeKey, index),
                type = NS.Constants.ACTIVITY_TYPE.GREAT_VAULT,
                name = NS.L.VAULT_ACTIVITY_NAMES[typeKey] or NS.L.VAULT_ACTIVITY_NAMES.unknown,
                available = retired ~= true,
                completed = threshold > 0 and progress >= threshold,
                repeatable = true,
                progressionTags = { "weekly", "great_vault", typeKey },
                source = "great_vault",
                metadata = {
                    vaultType = info.type,
                    activityID = info.id,
                    vaultTypeKey = typeKey,
                    index = index,
                    threshold = threshold,
                    progress = progress,
                    activityTierID = info.activityTierID,
                    level = info.level,
                    rewardItemLink = preview and preview.itemLink or nil,
                    rewardItemLevel = preview and preview.itemLevel or nil,
                    rewardIconFileID = preview and preview.iconFileID or nil,
                    rewardPreviewIsExample = preview ~= nil,
                    upgradeRewardItemLink = preview and preview.upgradeItemLink or nil,
                    upgradeRewardItemLevel = preview and preview.upgradeItemLevel or nil,
                    raidString = info.raidString,
                    encounters = encounters,
                    generatedRewardLinks = generatedRewardLinks,
                    nextIncrease = nextIncrease,
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

function GreatVault:ApplyProgressionContext(vault, progression)
    vault = vault or {}
    progression = progression or {}
    vault.seasonPhase = progression.seasonPhase
    vault.currentRewardCeiling = progression.currentRewardCeiling
    vault.currentBaselineItemLevel = progression.currentBaselineItemLevel
    vault.futureRewardsPending = progression.futureRewardsPending == true
    for _, activity in ipairs(vault.activities or {}) do
        local metadata = activity.metadata or {}
        metadata.futurePreview = vault.futureRewardsPending
        metadata.aboveCurrentCeiling = type(metadata.rewardItemLevel) == "number"
            and type(vault.currentRewardCeiling) == "number"
            and metadata.rewardItemLevel > vault.currentRewardCeiling
    end
    return vault
end
