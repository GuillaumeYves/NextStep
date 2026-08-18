local _, NS = ...

NS.Recommendation = NS.Recommendation or {}
local Rules = {}
NS.Recommendation.Rules = Rules

local function isLeveling(state)
    local character = state.character or {}
    return type(character.level) == "number"
        and type(character.maxLevel) == "number"
        and character.level < character.maxLevel
end

local function localizedNoun(key, count)
    local forms = NS.L.NOUNS[key]
    if not forms then
        return key
    end
    return count == 1 and forms.one or forms.other
end

local function hasCuratedRouteForGoal(state, goal)
    for _, route in ipairs((state.curatedRoutes and state.curatedRoutes.available) or {}) do
        if route.goal == goal then
            return true
        end
    end
    return false
end

function Rules:Leveling(state)
    if not isLeveling(state) then
        return nil
    end

    if hasCuratedRouteForGoal(state, NS.Constants.GOAL.EXPERIENCE) then
        return nil
    end

    local tracked = state.quests and state.quests.trackedQuest
    local title = NS.L.LEVELING_TITLE
    local description = NS.L.LEVELING_DESCRIPTION
    local reason = NS.Recommendation.Reasons.LEVELING
    local source = "character"

    if tracked and tracked.title and not tracked.readyForTurnIn then
        title = string.format(NS.L.TRACKED_QUEST_TITLE, tracked.title)
        description = tracked.isStory and NS.L.TRACKED_STORY_DESCRIPTION or NS.L.TRACKED_QUEST_DESCRIPTION
        reason = NS.Recommendation.Reasons.TRACKED_QUEST
        source = "quest_log"
    else
        local experience = state.experience or {}
        if type(experience.current) == "number" and type(experience.maximum) == "number"
            and experience.maximum > experience.current then
            local nextLevel = math.min(state.character.level + 1, state.character.maxLevel)
            title = string.format(NS.L.LEVELING_PROGRESS_TITLE, nextLevel)
            description = string.format(
                NS.L.LEVELING_PROGRESS_DESCRIPTION,
                NS.Util.Formatting:Number(experience.maximum - experience.current, "0"),
                nextLevel
            )
            source = "experience"
        end
    end

    return NS.Model.Recommendation:New({
        id = "continue_leveling",
        rule = "Leveling",
        category = "leveling",
        priority = NS.Recommendation.Scoring.PRIORITY.LEVELING,
        importance = NS.Constants.IMPORTANCE.HIGH,
        title = title,
        description = description,
        reason = reason,
        status = NS.Constants.STATUS.AVAILABLE,
        source = source,
        goals = { NS.Constants.GOAL.EXPERIENCE },
    })
end

function Rules:CuratedRoutes(state)
    local results = {}
    for _, route in ipairs((state.curatedRoutes and state.curatedRoutes.available) or {}) do
        local priority = NS.Recommendation.Scoring.PRIORITY[route.priorityKey]
        if type(priority) == "number" then
            results[#results + 1] = NS.Model.Recommendation:New({
                id = route.id,
                rule = "CuratedRoutes",
                category = route.category,
                priority = priority,
                importance = route.importance,
                title = route.title,
                description = route.description,
                reason = route.reason,
                status = NS.Constants.STATUS.AVAILABLE,
                source = route.source,
                goals = route.goals or { route.goal },
                metadata = route.metadata,
            })
        end
    end
    return #results > 0 and results or nil
end

function Rules:PatchCatalog(state)
    local results = {}
    local covered = {}
    for _, route in ipairs((state.curatedRoutes and state.curatedRoutes.available) or {}) do
        local metadata = route.metadata or {}
        local target = metadata.target or {}
        if target.mountID then
            covered["mount:" .. target.mountID] = true
        end
        if target.speciesID then
            covered["pet:" .. target.speciesID] = true
        end
        if metadata.achievementID then
            covered["achievement:" .. metadata.achievementID] = true
        end
    end

    for _, entry in ipairs((state.patchCatalog and state.patchCatalog.entries) or {}) do
        local target = entry.target or {}
        local coverageKey
        if entry.kind == "mount" and target.mountID then
            coverageKey = "mount:" .. target.mountID
        elseif entry.kind == "pet" and target.speciesID then
            coverageKey = "pet:" .. target.speciesID
        elseif entry.kind == "achievement" and entry.achievementID then
            coverageKey = "achievement:" .. entry.achievementID
        end
        if not coverageKey or not covered[coverageKey] then
            local hasReward = type(entry.rewardText) == "string" and entry.rewardText ~= ""
            local titleFormat = entry.kind == "achievement"
                and NS.L.PATCH_CATALOG_ACHIEVEMENT_TITLE or NS.L.PATCH_CATALOG_TITLE
            results[#results + 1] = NS.Model.Recommendation:New({
                id = entry.id,
                rule = "PatchCatalog",
                category = "collection",
                priority = hasReward
                    and NS.Recommendation.Scoring.PRIORITY.PATCH_CATALOG_REWARD
                    or NS.Recommendation.Scoring.PRIORITY.PATCH_CATALOG,
                importance = hasReward
                    and NS.Constants.IMPORTANCE.USEFUL
                    or NS.Constants.IMPORTANCE.OPTIONAL,
                title = string.format(titleFormat, entry.name),
                description = entry.description or NS.L.PATCH_CATALOG_SOURCE_UNAVAILABLE,
                reason = entry.reason,
                status = NS.Constants.STATUS.AVAILABLE,
                source = "retail_collection_catalog",
                goals = { entry.goal },
                metadata = {
                    patch = state.patchCatalog.patch,
                    reviewedAt = state.patchCatalog.reviewedAt,
                    confidence = "high",
                    iconFileID = entry.iconFileID,
                    target = target,
                    sourceText = entry.sourceText,
                    flavorText = entry.flavorText,
                    achievementID = entry.achievementID,
                    rewardText = entry.rewardText,
                    progress = entry.progress,
                    missingCriteria = entry.missingCriteria,
                    sources = entry.sources,
                    summary = entry.description,
                },
            })
        end
    end
    return #results > 0 and results or nil
end

function Rules:QuestTurnIns(state)
    if not isLeveling(state) then
        return nil
    end

    local count = 0
    local totalXP = 0
    for _, quest in ipairs((state.quests and state.quests.readyForTurnIn) or {}) do
        if type(quest.rewardXP) == "number" and quest.rewardXP > 0 then
            count = count + 1
            totalXP = totalXP + quest.rewardXP
        end
    end
    if count == 0 then
        return nil
    end

    return NS.Model.Recommendation:New({
        id = "turn_in_completed_xp_quests",
        rule = "QuestTurnIns",
        category = "leveling",
        priority = NS.Recommendation.Scoring.PRIORITY.QUEST_TURN_IN,
        importance = NS.Constants.IMPORTANCE.HIGH,
        title = NS.L.QUEST_TURN_IN_TITLE,
        description = string.format(
            NS.L.QUEST_TURN_IN_DESCRIPTION,
            count,
            localizedNoun("quest", count),
            NS.Util.Formatting:Number(totalXP, "0")
        ),
        reason = NS.Recommendation.Reasons.QUEST_TURN_IN,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "quest_log",
        goals = { NS.Constants.GOAL.EXPERIENCE },
        metadata = { questCount = count, rewardXP = totalXP },
    })
end

function Rules:RestedExperience(state)
    if not isLeveling(state) then
        return nil
    end

    local experience = state.experience or {}
    if type(experience.rested) ~= "number" or experience.rested <= 0
        or type(experience.restedPercentOfLevel) ~= "number" then
        return nil
    end

    return NS.Model.Recommendation:New({
        id = "use_rested_experience",
        rule = "RestedExperience",
        category = "leveling",
        priority = NS.Recommendation.Scoring.PRIORITY.RESTED_XP,
        importance = NS.Constants.IMPORTANCE.USEFUL,
        title = NS.L.RESTED_XP_TITLE,
        description = string.format(
            NS.L.RESTED_XP_DESCRIPTION,
            NS.Util.Formatting:Number(experience.rested, "0"),
            math.floor(experience.restedPercentOfLevel + 0.5)
        ),
        reason = NS.Recommendation.Reasons.RESTED_XP,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "experience",
        goals = { NS.Constants.GOAL.EXPERIENCE },
    })
end

function Rules:LevelingDungeons(state)
    if not isLeveling(state) then
        return nil
    end

    local leveling = state.leveling or {}
    local count = tonumber(leveling.availableDungeonCount) or 0
    if not leveling.dungeonFinderAvailable or count <= 0 then
        return nil
    end

    local dungeonNames = {}
    local dungeonIDs = {}
    local dungeonIcon
    for _, dungeon in ipairs(leveling.availableDungeons or {}) do
        dungeonIDs[#dungeonIDs + 1] = dungeon.dungeonID
        dungeonIcon = dungeonIcon or dungeon.iconID
        if type(dungeon.name) == "string" and dungeon.name ~= "" then
            dungeonNames[#dungeonNames + 1] = dungeon.name
        end
    end

    local description
    if #dungeonNames > 0 then
        description = string.format(
            NS.L.LEVELING_DUNGEON_CHOICES,
            NS.Util.Formatting:List(dungeonNames, 3, NS.L.LIST_AND_MORE)
        )
    else
        description = string.format(
            NS.L.LEVELING_DUNGEON_DESCRIPTION,
            count,
            localizedNoun("dungeon", count)
        )
    end
    return NS.Model.Recommendation:New({
        id = "leveling_dungeon_route",
        rule = "LevelingDungeons",
        category = "leveling",
        priority = NS.Recommendation.Scoring.PRIORITY.LEVELING_DUNGEON,
        importance = NS.Constants.IMPORTANCE.USEFUL,
        title = NS.L.LEVELING_DUNGEON_TITLE,
        description = description,
        reason = NS.Recommendation.Reasons.LEVELING_DUNGEON,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "dungeon_finder",
        goals = { NS.Constants.GOAL.EXPERIENCE, NS.Constants.GOAL.GEAR },
        metadata = {
            availableDungeonCount = count,
            dungeonIDs = dungeonIDs,
            dungeonNames = dungeonNames,
            target = {
                kind = "dungeon",
                iconFileID = dungeonIcon,
                acquisition = "client_confirmed",
            },
        },
    })
end

function Rules:EmptyEquipment(state)
    local character = state.character or {}
    if type(character.level) ~= "number" or character.level < NS.EquipmentConfig.minimumGuidanceLevel then
        return nil
    end

    local allEmptySlots = state.equipment and state.equipment.emptySlots or {}
    local emptySlots = {}
    for _, slot in ipairs(allEmptySlots) do
        if not isLeveling(state) or slot.slotKey == "mainHand" then
            emptySlots[#emptySlots + 1] = slot
        end
    end
    if #emptySlots == 0 then
        return nil
    end

    local names = {}
    local mainHandMissing = false
    for _, slot in ipairs(emptySlots) do
        names[#names + 1] = NS.L.SLOT_NAMES[slot.slotKey] or slot.slotKey
        if slot.slotKey == "mainHand" then
            mainHandMissing = true
        end
    end

    local format = isLeveling(state) and NS.L.EMPTY_GEAR_LEVELING_DESCRIPTION or NS.L.EMPTY_GEAR_MAX_DESCRIPTION
    return NS.Model.Recommendation:New({
        id = "fill_empty_equipment_slots",
        rule = "EmptyEquipment",
        category = "gear",
        priority = mainHandMissing
            and NS.Recommendation.Scoring.PRIORITY.EMPTY_MAIN_HAND
            or NS.Recommendation.Scoring.PRIORITY.EMPTY_EQUIPMENT,
        importance = mainHandMissing and NS.Constants.IMPORTANCE.CRITICAL or NS.Constants.IMPORTANCE.HIGH,
        title = NS.L.EMPTY_GEAR_TITLE,
        description = string.format(format, NS.Util.Formatting:List(names, 3, NS.L.LIST_AND_MORE)),
        reason = NS.Recommendation.Reasons.EMPTY_GEAR,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "equipment",
        goals = { NS.Constants.GOAL.GEAR },
        metadata = { emptySlotCount = #emptySlots, mainHandMissing = mainHandMissing },
    })
end

local function equipmentSlotName(item)
    return NS.L.SLOT_NAMES[item.slotKey] or item.slotKey or NS.L.UNKNOWN
end

function Rules:UpgradeableEquipment(state)
    if isLeveling(state) then
        return nil
    end

    local opportunity = state.progression and state.progression.bestUpgrade
    if not opportunity or not opportunity.item or not opportunity.item.upgrade then
        return nil
    end

    local item = opportunity.item
    local upgrade = item.upgrade
    local slotName = equipmentSlotName(item)
    local itemName = item.name or slotName
    local trackName = upgrade.trackString or NS.L.UNKNOWN
    local guidanceMaxItemLevel = upgrade.maxItemLevel
    local currentRewardCeiling = state.progression and state.progression.currentRewardCeiling
    if type(currentRewardCeiling) == "number" then
        guidanceMaxItemLevel = math.min(guidanceMaxItemLevel, currentRewardCeiling)
        if type(item.itemLevel) == "number" and item.itemLevel >= guidanceMaxItemLevel then
            return nil
        end
    end
    local currencyName = opportunity.currency and opportunity.currency.name or trackName
    local title = string.format(NS.L.UPGRADE_ITEM_TITLE, slotName)
    local description
    local steps = {}

    if opportunity.sourceDescription then
        steps[#steps + 1] = string.format(
            NS.L.UPGRADE_ITEM_SOURCE,
            currencyName,
            opportunity.sourceDescription
        )
    end
    steps[#steps + 1] = NS.L.UPGRADE_ITEM_VENDOR_STEP

    if type(opportunity.currencyQuantity) == "number" and type(opportunity.standardGap) == "number" then
        if opportunity.standardGap > 0 then
            title = string.format(NS.L.UPGRADE_ITEM_EARN_TITLE, currencyName, slotName)
            if currentRewardCeiling then
                description = string.format(NS.L.UPGRADE_ITEM_PRESEASON_GAP_DESCRIPTION,
                    itemName, item.itemLevel, opportunity.standardGap, currencyName, currentRewardCeiling)
            else
                description = string.format(NS.L.UPGRADE_ITEM_GAP_DESCRIPTION,
                    itemName, item.itemLevel, guidanceMaxItemLevel, opportunity.standardGap)
            end
        else
            if currentRewardCeiling then
                description = string.format(NS.L.UPGRADE_ITEM_PRESEASON_READY_DESCRIPTION,
                    itemName, item.itemLevel, opportunity.currencyQuantity, currencyName, currentRewardCeiling)
            else
                description = string.format(NS.L.UPGRADE_ITEM_READY_DESCRIPTION,
                    itemName, item.itemLevel, trackName, upgrade.currentLevel, upgrade.maxLevel,
                    guidanceMaxItemLevel, opportunity.currencyQuantity, currencyName)
            end
        end
    else
        if currentRewardCeiling then
            description = string.format(NS.L.UPGRADE_ITEM_PRESEASON_UNKNOWN_DESCRIPTION,
                itemName, item.itemLevel, currentRewardCeiling)
        else
            description = string.format(NS.L.UPGRADE_ITEM_UNKNOWN_CURRENCY_DESCRIPTION,
                itemName, item.itemLevel, trackName, upgrade.currentLevel,
                upgrade.maxLevel, guidanceMaxItemLevel)
        end
    end

    return NS.Model.Recommendation:New({
        id = "upgrade_equipped_" .. tostring(item.slotID),
        rule = "UpgradeableEquipment",
        category = "gear",
        priority = NS.Recommendation.Scoring.PRIORITY.IMMEDIATE_ITEM_UPGRADE,
        importance = NS.Constants.IMPORTANCE.HIGH,
        title = title,
        description = description,
        reason = currentRewardCeiling
            and string.format(NS.L.UPGRADE_ITEM_PRESEASON_REASON, currentRewardCeiling)
            or NS.L.UPGRADE_ITEM_REASON,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "equipment_upgrade",
        goals = { NS.Constants.GOAL.GEAR },
        metadata = {
            slotID = item.slotID,
            itemID = item.itemID,
            itemLink = item.itemLink,
            iconFileID = item.iconFileID,
            itemLevel = item.itemLevel,
            maxItemLevel = guidanceMaxItemLevel,
            trackMaxItemLevel = upgrade.maxItemLevel,
            currentRewardCeiling = currentRewardCeiling,
            target = {
                kind = "item",
                itemID = item.itemID,
                itemLink = item.itemLink,
                name = itemName,
                iconFileID = item.iconFileID,
                acquisition = "client_confirmed",
            },
            exactCostKnown = false,
            steps = steps,
            patch = state.progression.patch,
            reviewedAt = state.progression.reviewedAt,
            confidence = state.progression.confidence,
            sources = state.progression.sources,
        },
    })
end

function Rules:FastGearRoute(state)
    if isLeveling(state) then
        return nil
    end

    local routes = state.progression and state.progression.gearRoutes
    if type(routes) ~= "table" or #routes == 0 then
        local route = state.progression and state.progression.gearRoute
        routes = route and { route } or {}
    end
    if #routes == 0 then
        return nil
    end

    local recommendations = {}
    for _, route in ipairs(routes) do
        if (route.slotsBelowEndReward or 0) > 0 then
            local title
            local description
            local reason
            local icon = "Interface\\Icons\\INV_Chest_Chain_05"
            if route.kind == "mythic_plus" then
                title = string.format(NS.L.GEAR_ROUTE_MPLUS_TITLE, route.targetLevel)
                description = string.format(NS.L.GEAR_ROUTE_MPLUS_DESCRIPTION,
                    route.targetLevel, route.endItemLevel, route.vaultItemLevel, route.slotsBelowEndReward)
                reason = NS.L.GEAR_ROUTE_MPLUS_REASON
                route.steps = {
                    string.format(NS.L.GEAR_ROUTE_MPLUS_STEP_1, route.targetLevel),
                    NS.L.GEAR_ROUTE_MPLUS_STEP_2,
                }
            elseif route.kind == "mythic_zero" then
                title = NS.L.GEAR_ROUTE_MYTHIC_ZERO_TITLE
                description = string.format(NS.L.GEAR_ROUTE_MYTHIC_ZERO_DESCRIPTION, route.slotsBelowEndReward)
                reason = NS.L.GEAR_ROUTE_MYTHIC_ZERO_REASON
                route.steps = {
                    NS.L.GEAR_ROUTE_MYTHIC_ZERO_STEP_1,
                    NS.L.GEAR_ROUTE_MYTHIC_ZERO_STEP_2,
                }
                icon = "Interface\\Icons\\INV_Misc_Chest_04"
                route.rewardText = NS.L.GEAR_ROUTE_MYTHIC_ZERO_REWARD
            elseif route.kind == "world_lair" then
                title = NS.L.GEAR_ROUTE_WORLD_LAIR_TITLE
                description = string.format(NS.L.GEAR_ROUTE_WORLD_LAIR_DESCRIPTION, route.slotsBelowEndReward)
                reason = NS.L.GEAR_ROUTE_WORLD_LAIR_REASON
                route.steps = {
                    NS.L.GEAR_ROUTE_WORLD_LAIR_STEP_1,
                    NS.L.GEAR_ROUTE_WORLD_LAIR_STEP_2,
                }
                icon = "Interface\\Icons\\INV_Misc_Chest_03"
                route.rewardText = NS.L.GEAR_ROUTE_WORLD_LAIR_REWARD
            end
            if title then
                route.family = "gear"
                route.patch = state.progression.patch
                route.reviewedAt = state.progression.reviewedAt
                route.confidence = state.progression.confidence
                route.sources = state.progression.sources
                route.target = {
                    kind = "gear_route",
                    iconFileID = icon,
                    acquisition = "verified_route",
                }
                recommendations[#recommendations + 1] = NS.Model.Recommendation:New({
                    id = "season_gear_route_" .. route.kind,
                    rule = "FastGearRoute",
                    category = "gear",
                    priority = NS.Recommendation.Scoring.PRIORITY.FAST_GEAR_ROUTE,
                    importance = NS.Constants.IMPORTANCE.HIGH,
                    title = title,
                    description = description,
                    reason = reason,
                    status = NS.Constants.STATUS.AVAILABLE,
                    source = "progression_meta",
                    goals = { NS.Constants.GOAL.GEAR },
                    metadata = route,
                })
            end
        end
    end
    return recommendations
end

function Rules:TierSet(state)
    if isLeveling(state) then
        return nil
    end
    local equipment = state.equipment or {}
    local classSet = equipment.classSet or {}
    local pieces = tonumber(classSet.pieces) or 0
    if not equipment.classSetDetectionReady then
        return nil
    end
    local phase = state.progression and state.progression.seasonPhase
    if phase ~= "preseason" and phase ~= "active" then
        return nil
    end

    local upcoming = phase == "preseason"
    local representative = classSet.representativeItem or {}
    if upcoming then
        pieces = 0
        representative = {}
    else
        local verifiedSetIDs = NS.SeasonConfig.currentTierSetIDs
        if type(verifiedSetIDs) ~= "table" then
            return nil
        end
        if not classSet.setID or not verifiedSetIDs[classSet.setID] then
            pieces = 0
            representative = {}
        end
    end
    if pieces >= 4 then
        return nil
    end
    return NS.Model.Recommendation:New({
        id = "season_tier_set_progress",
        rule = "TierSet",
        category = "gear",
        priority = NS.Recommendation.Scoring.PRIORITY.TIER_SET,
        importance = NS.Constants.IMPORTANCE.OPTIONAL,
        title = NS.L.TIER_SET_TITLE,
        description = string.format(
            upcoming and NS.L.TIER_SET_UPCOMING_DESCRIPTION or NS.L.TIER_SET_DESCRIPTION,
            pieces
        ),
        reason = NS.L.TIER_SET_REASON,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "equipment_and_season_schedule",
        goals = { NS.Constants.GOAL.GEAR },
        metadata = {
            progress = { current = pieces, total = 4 },
            patch = state.progression.patch,
            reviewedAt = state.progression.reviewedAt,
            confidence = "medium",
            sources = state.progression.sources,
            target = {
                kind = representative.itemLink and "item" or "gear_route",
                itemID = representative.itemID,
                itemLink = representative.itemLink,
                iconFileID = representative.iconFileID or "Interface\\Icons\\INV_Chest_Chain_05",
                acquisition = "verified_route",
                releaseStatus = upcoming and "upcoming" or "current",
            },
        },
    })
end

local function vaultProgressSentence(key, missing)
    if key == "dungeon" then
        return string.format(NS.L.VAULT_ROUTE_DUNGEON, missing, localizedNoun("dungeon", missing))
    elseif key == "raid" then
        return string.format(NS.L.VAULT_ROUTE_RAID, missing, localizedNoun("boss", missing))
    elseif key == "pvp" then
        return string.format(NS.L.VAULT_ROUTE_PROGRESS, missing, NS.L.VAULT_PROGRESS_SOURCES.pvp)
    elseif key == "world" then
        return string.format(NS.L.VAULT_ROUTE_PROGRESS, missing, NS.L.VAULT_PROGRESS_SOURCES.world)
    end
    return string.format(NS.L.VAULT_ROUTE_PROGRESS, missing, NS.L.VAULT_PROGRESS_SOURCES.other)
end

local function vaultFollowingUnit(key, count)
    if key == "dungeon" then
        return localizedNoun("dungeon", count)
    elseif key == "raid" then
        return localizedNoun("raidBoss", count)
    end
    return localizedNoun("vaultProgress", count)
end

local function buildVaultRoute(key, activity, following)
    local metadata = activity.metadata or {}
    local missing = math.max(0, (metadata.threshold or 0) - (metadata.progress or 0))
    local description = vaultProgressSentence(key, missing)
    if following then
        local additional = math.max(0, (following.metadata.threshold or 0) - (metadata.threshold or 0))
        if additional > 0 then
            description = description .. string.format(
                NS.L.VAULT_ROUTE_FOLLOWING,
                additional,
                vaultFollowingUnit(key, additional)
            )
        end
    end
    return description
end

function Rules:GreatVault(state)
    if isLeveling(state) then
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
            goals = { NS.Constants.GOAL.GEAR },
            metadata = { family = "weekly" },
        })
    end

    local dungeonPlan = state.progression and state.progression.dungeonVault
    if dungeonPlan and dungeonPlan.missingRuns > 0 then
        local activityMetadata = dungeonPlan.activity.metadata or {}
        recommendations[#recommendations + 1] = NS.Model.Recommendation:New({
            id = dungeonPlan.activity.id .. "_optimized",
            rule = "GreatVault",
            category = "weekly",
            priority = NS.Recommendation.Scoring.PRIORITY.OPTIMIZED_VAULT,
            importance = NS.Constants.IMPORTANCE.HIGH,
            title = string.format(NS.L.VAULT_MPLUS_TITLE, dungeonPlan.targetItemLevel),
            description = string.format(
                NS.L.VAULT_MPLUS_DESCRIPTION,
                dungeonPlan.missingRuns,
                localizedNoun("dungeon", dungeonPlan.missingRuns),
                dungeonPlan.targetLevel
            ),
            reason = string.format(NS.L.VAULT_MPLUS_REASON, dungeonPlan.slotsBelowReward),
            status = NS.Constants.STATUS.AVAILABLE,
            source = "great_vault_and_progression_meta",
            goals = { NS.Constants.GOAL.GEAR },
            metadata = {
                family = "weekly",
                activityID = dungeonPlan.activity.id,
                targetLevel = dungeonPlan.targetLevel,
                targetItemLevel = dungeonPlan.targetItemLevel,
                missingRuns = dungeonPlan.missingRuns,
                steps = {
                    string.format(
                        NS.L.VAULT_MPLUS_STEP,
                        dungeonPlan.missingRuns,
                        localizedNoun("dungeon", dungeonPlan.missingRuns),
                        dungeonPlan.targetLevel
                    ),
                },
                patch = state.progression.patch,
                reviewedAt = state.progression.reviewedAt,
                confidence = state.progression.confidence,
                sources = state.progression.sources,
                target = {
                    kind = "vault_reward",
                    itemLink = activityMetadata.rewardItemLink,
                    iconFileID = activityMetadata.rewardIconFileID,
                    acquisition = "client_confirmed",
                },
            },
        })
    end

    local incompleteByType = {}
    for _, activity in ipairs(vault.activities or {}) do
        local metadata = activity.metadata or {}
        local key = metadata.vaultTypeKey or "unknown"
        local threshold = metadata.threshold or 0
        if activity.available and not activity.completed and threshold > 0 then
            incompleteByType[key] = incompleteByType[key] or {}
            incompleteByType[key][#incompleteByType[key] + 1] = activity
        end
    end

    for _, group in pairs(incompleteByType) do
        table.sort(group, function(a, b)
            return (a.metadata.threshold or 0) < (b.metadata.threshold or 0)
        end)
    end

    for _, key in ipairs({ "dungeon", "raid", "world", "pvp", "concession", "unknown" }) do
        local group = incompleteByType[key]
        local activity = group and group[1]
        if activity and not (key == "dungeon" and dungeonPlan) then
            local index = activity.metadata.index or 0
            recommendations[#recommendations + 1] = NS.Model.Recommendation:New({
                id = activity.id .. "_unlock",
                rule = "GreatVault",
                category = "weekly",
                priority = NS.Recommendation.Scoring:GetVaultPriority(index),
                importance = NS.Constants.IMPORTANCE.HIGH,
                title = string.format(
                    NS.L.VAULT_UNLOCK_TITLE,
                    NS.L.VAULT_CATEGORY_LABELS[key] or NS.L.VAULT_CATEGORY_LABELS.unknown
                ),
                description = buildVaultRoute(key, activity, group[2]),
                reason = NS.Recommendation.Reasons.VAULT_UNLOCK,
                status = NS.Constants.STATUS.AVAILABLE,
                source = "great_vault",
                goals = { NS.Constants.GOAL.GEAR },
                metadata = {
                    family = "weekly",
                    activityID = activity.id,
                    vaultTypeKey = key,
                    threshold = activity.metadata.threshold,
                    progress = activity.metadata.progress,
                    followingThreshold = group[2] and group[2].metadata.threshold or nil,
                    futurePreview = activity.metadata.futurePreview,
                    target = {
                        kind = "vault_reward",
                        itemLink = activity.metadata.rewardItemLink,
                        iconFileID = activity.metadata.rewardIconFileID,
                        acquisition = "client_confirmed",
                    },
                },
            })
        end
    end

    return #recommendations > 0 and recommendations or nil
end

Rules.ORDER = {
    { name = "CuratedRoutes", callback = function(state) return Rules:CuratedRoutes(state) end },
    { name = "PatchCatalog", callback = function(state) return Rules:PatchCatalog(state) end },
    { name = "Leveling", callback = function(state) return Rules:Leveling(state) end },
    { name = "QuestTurnIns", callback = function(state) return Rules:QuestTurnIns(state) end },
    { name = "RestedExperience", callback = function(state) return Rules:RestedExperience(state) end },
    { name = "LevelingDungeons", callback = function(state) return Rules:LevelingDungeons(state) end },
    { name = "EmptyEquipment", callback = function(state) return Rules:EmptyEquipment(state) end },
    { name = "UpgradeableEquipment", callback = function(state) return Rules:UpgradeableEquipment(state) end },
    { name = "FastGearRoute", callback = function(state) return Rules:FastGearRoute(state) end },
    { name = "TierSet", callback = function(state) return Rules:TierSet(state) end },
    { name = "GreatVault", callback = function(state) return Rules:GreatVault(state) end },
}
