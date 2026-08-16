local _, NS = ...

NS.Data = NS.Data or {}
local Progression = {}
NS.Data.Progression = Progression

local function currencyMap(currencies)
    local result = {}
    for _, currency in ipairs(currencies or {}) do
        result[currency.currencyID] = currency
    end
    return result
end

local function rewardForLevel(meta, level)
    for _, reward in ipairs(meta.mythicPlusRewards or {}) do
        if level >= reward.minLevel and level <= reward.maxLevel then
            return reward
        end
    end
    return nil
end

local function countSlotsBelow(items, itemLevel)
    local count = 0
    if type(itemLevel) ~= "number" then
        return count
    end
    for _, item in ipairs(items or {}) do
        if type(item.itemLevel) == "number" and item.itemLevel < itemLevel then
            count = count + 1
        end
    end
    return count
end

local function selectGearBreakpoint(meta, averageItemLevel)
    if type(averageItemLevel) ~= "number" then
        return nil
    end
    for _, target in ipairs(meta.gearTargets or {}) do
        if not target.averageItemLevelBelow or averageItemLevel < target.averageItemLevelBelow then
            return target.mythicPlusLevel
        end
    end
    return nil
end

local function resolveUpgrade(meta, equipment, currencies)
    local standardCost = tonumber(meta.standardUpgradeCost)
    local candidates = {}

    for _, item in ipairs(equipment.upgradeableItems or {}) do
        if item.upgrade then
            local track
            for key, config in pairs(meta.upgradeTracks or {}) do
                if config.maxItemLevel == item.upgrade.maxItemLevel then
                    track = {
                        key = key,
                        currencyID = config.currencyID,
                        maxItemLevel = config.maxItemLevel,
                        sourceKey = config.sourceKey,
                    }
                    break
                end
            end

            local currency = track and currencies[track.currencyID] or nil
            local quantity = currency and tonumber(currency.quantity) or nil
            candidates[#candidates + 1] = {
                item = item,
                track = track,
                currency = currency,
                currencyQuantity = quantity,
                standardCost = standardCost,
                standardGap = quantity and standardCost and math.max(0, standardCost - quantity) or nil,
                exactCostKnown = false,
                sourceDescription = track and NS.L[track.sourceKey] or nil,
            }
        end
    end

    table.sort(candidates, function(a, b)
        local aReady = a.standardGap == 0
        local bReady = b.standardGap == 0
        if aReady ~= bReady then
            return aReady
        end
        if type(a.standardGap) == "number" and type(b.standardGap) == "number"
            and a.standardGap ~= b.standardGap then
            return a.standardGap < b.standardGap
        end
        return (a.item.itemLevel or 0) < (b.item.itemLevel or 0)
    end)

    return candidates[1]
end

local function resolveSources(pack, sourceIDs)
    local result = {}
    for _, sourceID in ipairs(sourceIDs or {}) do
        local source = pack.sources and pack.sources[sourceID]
        if source then
            result[#result + 1] = {
                id = sourceID,
                kind = source.kind,
                title = NS.L[source.titleKey] or sourceID,
                url = source.url,
            }
        end
    end
    return result
end

local function countRunsAtLevel(runs, level)
    local count = 0
    for _, run in ipairs(runs or {}) do
        if type(run.level) == "number" and run.level >= level then
            count = count + 1
        end
    end
    return count
end

local function resolveDungeonVault(meta, state, targetLevel)
    if not targetLevel then
        return nil
    end
    local targetReward = rewardForLevel(meta, targetLevel)
    if not targetReward then
        return nil
    end

    local dungeonActivities = {}
    for _, activity in ipairs((state.vault and state.vault.activities) or {}) do
        if activity.metadata and activity.metadata.vaultTypeKey == "dungeon" then
            dungeonActivities[#dungeonActivities + 1] = activity
        end
    end
    table.sort(dungeonActivities, function(a, b)
        return (a.metadata.threshold or 0) < (b.metadata.threshold or 0)
    end)

    local runs = state.mythicPlus and state.mythicPlus.currentWeekRuns or {}
    local runsAtTarget = countRunsAtLevel(runs, targetLevel)
    local selected
    for _, activity in ipairs(dungeonActivities) do
        local missing = math.max(0, (activity.metadata.threshold or 0) - runsAtTarget)
        local currentLevel = activity.metadata.rewardItemLevel
        if missing > 0 and (type(currentLevel) ~= "number" or currentLevel < targetReward.vaultItemLevel) then
            selected = {
                activity = activity,
                targetLevel = targetLevel,
                targetItemLevel = targetReward.vaultItemLevel,
                runsAtTarget = runsAtTarget,
                missingRuns = missing,
                slotsBelowReward = countSlotsBelow(state.equipment.items, targetReward.vaultItemLevel),
            }
            break
        end
    end
    return selected
end

function Progression:Collect(state)
    local packID = NS.SeasonConfig and NS.SeasonConfig.routePack
    local pack = packID and NS.RoutePacks and NS.RoutePacks[packID]
    local meta = pack and pack.progression
    if not meta then
        return { dataReady = false }
    end

    local character = state.character or {}
    local mythicPlus = state.mythicPlus or {}
    local seasonPhase = mythicPlus.dataReady
        and (mythicPlus.active and "active" or "preseason")
        or "unknown"
    local atMaxLevel = type(character.level) == "number"
        and type(character.maxLevel) == "number"
        and character.level >= character.maxLevel
    if not atMaxLevel then
        return { dataReady = true, packID = packID, seasonPhase = seasonPhase }
    end

    local equipment = state.equipment or {}
    local targetLevel = mythicPlus.active and selectGearBreakpoint(meta, character.averageItemLevel) or nil
    local reward = targetLevel and rewardForLevel(meta, targetLevel) or nil
    local gearRoute
    local gearRoutes = {}

    if reward then
        gearRoute = {
            kind = "mythic_plus",
            targetLevel = targetLevel,
            endItemLevel = reward.endItemLevel,
            vaultItemLevel = reward.vaultItemLevel,
            slotsBelowEndReward = countSlotsBelow(equipment.items, reward.endItemLevel),
            slotsBelowVaultReward = countSlotsBelow(equipment.items, reward.vaultItemLevel),
        }
        gearRoutes[#gearRoutes + 1] = gearRoute
    elseif mythicPlus.dataReady and not mythicPlus.active then
        local baseline = meta.preMythicPlus.mythicZeroItemLevel
        local slotsBelowBaseline = countSlotsBelow(equipment.items, baseline)
        if slotsBelowBaseline > 0 then
            gearRoute = {
                kind = "mythic_zero",
                endItemLevel = baseline,
                slotsBelowEndReward = slotsBelowBaseline,
                lockout = meta.preMythicPlus.mythicZeroLockout,
            }
            gearRoutes[#gearRoutes + 1] = gearRoute
        end
        local worldLairItemLevel = meta.preMythicPlus.worldLairItemLevel
        local slotsBelowWorldLair = countSlotsBelow(equipment.items, worldLairItemLevel)
        if slotsBelowWorldLair > 0 then
            gearRoutes[#gearRoutes + 1] = {
                kind = "world_lair",
                endItemLevel = worldLairItemLevel,
                slotsBelowEndReward = slotsBelowWorldLair,
            }
        end
    end

    return {
        dataReady = true,
        packID = packID,
        patch = pack.patch,
        reviewedAt = pack.reviewedAt,
        confidence = meta.confidence,
        seasonPhase = seasonPhase,
        currentRewardCeiling = seasonPhase == "preseason"
            and meta.preMythicPlus.currentRewardCeiling or nil,
        currentBaselineItemLevel = seasonPhase == "preseason"
            and meta.preMythicPlus.mythicZeroItemLevel or nil,
        futureRewardsPending = seasonPhase == "preseason",
        sources = resolveSources(pack, meta.sourceIDs),
        gearRoute = gearRoute,
        gearRoutes = gearRoutes,
        bestUpgrade = resolveUpgrade(meta, equipment, currencyMap(state.currencies)),
        dungeonVault = resolveDungeonVault(meta, state, targetLevel),
    }
end
