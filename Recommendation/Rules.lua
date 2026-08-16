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

function Rules:Leveling(state)
    if not isLeveling(state) then
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

    return NS.Model.Recommendation:New({
        id = "leveling_dungeon_route",
        rule = "LevelingDungeons",
        category = "leveling",
        priority = NS.Recommendation.Scoring.PRIORITY.LEVELING_DUNGEON,
        importance = NS.Constants.IMPORTANCE.USEFUL,
        title = NS.L.LEVELING_DUNGEON_TITLE,
        description = string.format(
            NS.L.LEVELING_DUNGEON_DESCRIPTION,
            count,
            localizedNoun("dungeon", count)
        ),
        reason = NS.Recommendation.Reasons.LEVELING_DUNGEON,
        status = NS.Constants.STATUS.AVAILABLE,
        source = "dungeon_finder",
        goals = { NS.Constants.GOAL.EXPERIENCE, NS.Constants.GOAL.GEAR },
        metadata = { availableDungeonCount = count },
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
        if activity then
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
                    activityID = activity.id,
                    vaultTypeKey = key,
                    threshold = activity.metadata.threshold,
                    progress = activity.metadata.progress,
                    followingThreshold = group[2] and group[2].metadata.threshold or nil,
                },
            })
        end
    end

    return #recommendations > 0 and recommendations or nil
end

Rules.ORDER = {
    { name = "Leveling", callback = function(state) return Rules:Leveling(state) end },
    { name = "QuestTurnIns", callback = function(state) return Rules:QuestTurnIns(state) end },
    { name = "RestedExperience", callback = function(state) return Rules:RestedExperience(state) end },
    { name = "LevelingDungeons", callback = function(state) return Rules:LevelingDungeons(state) end },
    { name = "EmptyEquipment", callback = function(state) return Rules:EmptyEquipment(state) end },
    { name = "GreatVault", callback = function(state) return Rules:GreatVault(state) end },
}
