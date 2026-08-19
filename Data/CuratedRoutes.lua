local _, NS = ...

NS.Data = NS.Data or {}
local CuratedRoutes = {}
NS.Data.CuratedRoutes = CuratedRoutes

local function copyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do
        result[key] = value
    end
    return result
end

local function copyArray(source)
    local result = {}
    for _, value in ipairs(source or {}) do
        result[#result + 1] = value
    end
    return result
end

local function contextRequirementsMatch(requirements, state)
    local character = state.character or {}
    local level = character.level
    local maxLevel = character.maxLevel
    if requirements.minLevel and (type(level) ~= "number" or level < requirements.minLevel) then
        return false
    end
    if requirements.maxLevel and (type(level) ~= "number" or level > requirements.maxLevel) then
        return false
    end
    if requirements.belowMaxLevel
        and (type(level) ~= "number" or type(maxLevel) ~= "number" or level >= maxLevel) then
        return false
    end
    if requirements.atMaxLevel
        and (type(level) ~= "number" or type(maxLevel) ~= "number" or level < maxLevel) then
        return false
    end
    if requirements.averageItemLevelBelow then
        local itemLevel = character.averageItemLevel
        if type(itemLevel) ~= "number" or itemLevel >= requirements.averageItemLevelBelow then
            return false
        end
    end
    if requirements.seasonPhase
        and (not state.progression or state.progression.seasonPhase ~= requirements.seasonPhase) then
        return false
    end
    return true
end

local function collectProgress(pack, state)
    local progress = {
        quests = {},
        mounts = {},
        pets = {},
        achievements = {},
    }

    for _, route in ipairs(pack.routes or {}) do
        local requirements = route.requirements or {}
        if contextRequirementsMatch(requirements, state) then
            for _, questID in ipairs(requirements.questComplete or {}) do
                if progress.quests[questID] == nil then
                    local completed, known = NS.API.WoW:IsQuestCompleted(questID)
                    progress.quests[questID] = { completed = completed, known = known }
                end
            end
            for _, questID in ipairs(requirements.questIncomplete or {}) do
                if progress.quests[questID] == nil then
                    local completed, known = NS.API.WoW:IsQuestCompleted(questID)
                    progress.quests[questID] = { completed = completed, known = known }
                end
            end
            for _, itemID in ipairs(requirements.mountItemNotCollected or {}) do
                if progress.mounts[itemID] == nil then
                    local info, known = NS.API.WoW:GetMountCollectionInfoByItemID(itemID)
                    progress.mounts[itemID] = { info = info, known = known }
                end
            end
            for _, creatureID in ipairs(requirements.petCreatureNotCollected or {}) do
                if progress.pets[creatureID] == nil then
                    local info, known = NS.API.WoW:GetPetCollectionInfoByCreatureID(creatureID)
                    progress.pets[creatureID] = { info = info, known = known }
                end
            end
            for _, creatureID in ipairs(requirements.anyPetCreatureNotCollected or {}) do
                if progress.pets[creatureID] == nil then
                    local info, known = NS.API.WoW:GetPetCollectionInfoByCreatureID(creatureID)
                    progress.pets[creatureID] = { info = info, known = known }
                end
            end
            for _, achievementID in ipairs(requirements.achievementIncomplete or {}) do
                if progress.achievements[achievementID] == nil then
                    local info, known = NS.API.WoW:GetAchievementProgress(achievementID)
                    progress.achievements[achievementID] = { info = info, known = known }
                end
            end
        end
    end

    return progress
end

local function anyCollectionMissing(ids, entries)
    local foundMissing = false
    for _, id in ipairs(ids or {}) do
        local entry = entries[id]
        if not entry or not entry.known or not entry.info then
            return false
        end
        if not entry.info.collected then
            foundMissing = true
        end
    end
    return foundMissing
end

local function achievementsAreIncomplete(ids, progress)
    for _, achievementID in ipairs(ids or {}) do
        local entry = progress.achievements[achievementID]
        if not entry or not entry.known or not entry.info or entry.info.completed then
            return false
        end
    end
    return true
end

local function allQuestsMatch(questIDs, progress, expected)
    for _, questID in ipairs(questIDs or {}) do
        local entry = progress.quests[questID]
        if not entry or not entry.known or entry.completed ~= expected then
            return false
        end
    end
    return true
end

local function collectionsAreMissing(ids, entries)
    for _, id in ipairs(ids or {}) do
        local entry = entries[id]
        if not entry or not entry.known or not entry.info or entry.info.collected then
            return false
        end
    end
    return true
end

local function requirementsMatch(route, state, progress)
    local requirements = route.requirements or {}
    if not contextRequirementsMatch(requirements, state) then
        return false
    end
    if not allQuestsMatch(requirements.questComplete, progress, true) then
        return false
    end
    if not allQuestsMatch(requirements.questIncomplete, progress, false) then
        return false
    end
    if not collectionsAreMissing(requirements.mountItemNotCollected, progress.mounts) then
        return false
    end
    if not collectionsAreMissing(requirements.petCreatureNotCollected, progress.pets) then
        return false
    end
    if requirements.anyPetCreatureNotCollected
        and not anyCollectionMissing(requirements.anyPetCreatureNotCollected, progress.pets) then
        return false
    end
    if not achievementsAreIncomplete(requirements.achievementIncomplete, progress) then
        return false
    end

    return true
end

local function applyProgressMetadata(metadata, route, progress)
    local requirements = route.requirements or {}
    local achievementID = requirements.achievementIncomplete
        and requirements.achievementIncomplete[1]
    local achievement = achievementID and progress.achievements[achievementID]
    achievement = achievement and achievement.info or nil
    if achievement then
        metadata.achievementID = achievementID
        metadata.achievementName = achievement.name
        metadata.rewardText = achievement.rewardText
        metadata.iconFileID = achievement.iconFileID
        metadata.achievementLink = achievement.achievementLink
        metadata.progress = {
            current = achievement.completedCriteria,
            total = achievement.totalCriteria,
        }
        metadata.missingCriteria = {}
        for _, criterion in ipairs(achievement.criteria or {}) do
            if not criterion.completed and type(criterion.name) == "string" and criterion.name ~= "" then
                metadata.missingCriteria[#metadata.missingCriteria + 1] = criterion.name
            end
        end
    end
end

local function acquisitionForEvidence(evidence)
    if evidence == "fixed_treasure" or evidence == "quest_reward"
        or evidence == "season_track_reward" then
        return "guaranteed"
    elseif evidence == "achievement_reward" then
        return "achievement"
    elseif evidence == "chance_drop" then
        return "chance"
    end
    return "verified_route"
end

local function applyTargetMetadata(metadata, route, progress)
    local requirements = route.requirements or {}
    local itemID = metadata.itemID
    local target = {
        kind = route.goal == "mounts" and "mount"
            or route.goal == "pets" and "pet"
            or "objective",
        itemID = itemID,
        speciesID = metadata.speciesID,
        achievementID = metadata.achievementID,
        achievementLink = metadata.achievementLink,
        acquisition = acquisitionForEvidence(route.evidence),
        dropRate = metadata.dropRate,
        dropRateKnown = type(metadata.dropRate) == "number",
        featured = metadata.featured == true,
    }

    local mountEntry = itemID and progress.mounts[itemID]
    if mountEntry and mountEntry.info then
        target.name = mountEntry.info.name
        target.iconFileID = mountEntry.info.iconFileID
        target.mountID = mountEntry.info.mountID
        target.spellID = mountEntry.info.spellID
        target.mountLink = mountEntry.info.mountLink
    end

    if target.speciesID and NS.API.WoW.GetPetSpeciesInfo then
        local petInfo = NS.API.WoW:GetPetSpeciesInfo(target.speciesID)
        if petInfo then
            target.name = petInfo.name
            target.iconFileID = petInfo.iconFileID
        end
    end

    if itemID and NS.API.WoW.GetItemDisplayInfo then
        local itemInfo = NS.API.WoW:GetItemDisplayInfo(itemID)
        if itemInfo then
            target.name = target.name or itemInfo.name
            target.iconFileID = target.iconFileID or itemInfo.iconFileID
            target.itemLink = itemInfo.itemLink
        end
    end

    if not target.iconFileID and metadata.iconFileID then
        target.iconFileID = metadata.iconFileID
    end
    if not target.name and metadata.rewardPetName then
        target.name = metadata.rewardPetName
    end
    if not target.name and requirements.petCreatureNotCollected then
        target.name = route.titleKey and NS.L[route.titleKey] or nil
    end
    metadata.target = target
end

local function localizeSteps(route)
    local steps = {}
    for _, key in ipairs(route.stepKeys or {}) do
        if type(NS.L[key]) == "string" then
            steps[#steps + 1] = NS.L[key]
        end
    end
    return steps
end

local function resolveSources(pack, route)
    local sources = {}
    for _, sourceID in ipairs(route.sourceIDs or {}) do
        local source = pack.sources and pack.sources[sourceID]
        if source then
            local resolved = copyTable(source)
            resolved.id = sourceID
            resolved.title = NS.L[source.titleKey] or sourceID
            sources[#sources + 1] = resolved
        end
    end
    return sources
end

local function buildCharacterCompletion(pack, progress)
    local completion = {
        current = 0,
        total = 0,
        entries = {},
        dataReady = false,
    }
    for _, milestone in ipairs(pack.characterMilestones or {}) do
        local quest = progress.quests[milestone.questID]
        if quest and quest.known then
            completion.total = completion.total + 1
            if quest.completed then
                completion.current = completion.current + 1
            end
            completion.entries[#completion.entries + 1] = {
                id = milestone.id,
                name = NS.L[milestone.titleKey] or milestone.id,
                completed = quest.completed == true,
            }
        end
    end
    completion.dataReady = completion.total > 0
    return completion
end

function CuratedRoutes:Collect(state)
    local packID = NS.SeasonConfig and NS.SeasonConfig.routePack
    local pack = packID and NS.RoutePacks and NS.RoutePacks[packID]
    if not pack then
        return { packID = packID, available = {}, dataReady = false }, false
    end

    local interfaceVersion, interfaceKnown = NS.API.WoW:GetInterfaceVersion()
    if not interfaceKnown or interfaceVersion ~= pack.interface then
        return {
            packID = pack.id,
            patch = pack.patch,
            reviewedAt = pack.reviewedAt,
            available = {},
            dataReady = false,
            unavailableReason = "interface_mismatch",
            clientInterface = interfaceVersion,
        }, false
    end

    local progress = collectProgress(pack, state)
    local available = {}
    for _, route in ipairs(pack.routes or {}) do
        if requirementsMatch(route, state, progress) then
            local title = NS.L[route.titleKey]
            local description = NS.L[route.descriptionKey]
            local reason = NS.L[route.reasonKey]
            if type(title) == "string" and type(description) == "string" and type(reason) == "string" then
                local metadata = copyTable(route.metadata)
                metadata.patch = pack.patch
                metadata.packID = pack.id
                metadata.reviewedAt = pack.reviewedAt
                metadata.phase = pack.phase
                metadata.confidence = route.confidence
                metadata.evidence = route.evidence
                metadata.steps = localizeSteps(route)
                metadata.sources = resolveSources(pack, route)
                metadata.summary = description
                applyProgressMetadata(metadata, route, progress)
                applyTargetMetadata(metadata, route, progress)

                available[#available + 1] = {
                    id = route.id,
                    goal = route.goal,
                    goals = copyArray(route.goals or { route.goal }),
                    category = route.category,
                    priorityKey = route.priorityKey,
                    importance = route.importance,
                    title = title,
                    description = metadata.steps[1] or description,
                    reason = reason,
                    source = "route_pack_" .. pack.id,
                    metadata = metadata,
                }
            end
        end
    end

    return {
        packID = pack.id,
        patch = pack.patch,
        reviewedAt = pack.reviewedAt,
        phase = pack.phase,
        available = available,
        completion = {
            character = buildCharacterCompletion(pack, progress),
        },
        dataReady = true,
    }, true
end
