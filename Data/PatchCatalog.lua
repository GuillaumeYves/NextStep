local _, NS = ...

NS.Data = NS.Data or {}
local PatchCatalog = {}
NS.Data.PatchCatalog = PatchCatalog

local INVALIDATING_REASONS = {
    player_login = true,
    PLAYER_ENTERING_WORLD = true,
    NEW_MOUNT_ADDED = true,
    PET_JOURNAL_LIST_UPDATE = true,
    ACHIEVEMENT_EARNED = true,
    CRITERIA_UPDATE = true,
    manual = true,
    window_opened = true,
    settings_reset = true,
}

local function releaseStatus(isSeasonEntry, state)
    if isSeasonEntry and state.progression and state.progression.seasonPhase == "preseason" then
        return "upcoming"
    end
    return "new"
end

local function sourceMetadata(pack, sourceID)
    local source = pack.sources and pack.sources[sourceID]
    if not source then
        return {}
    end
    return {
        {
            id = sourceID,
            kind = source.kind,
            title = NS.L[source.titleKey] or sourceID,
            url = source.url,
        },
    }
end

function PatchCatalog:Collect(state, reason)
    local packID = NS.SeasonConfig and NS.SeasonConfig.routePack
    local pack = packID and NS.RoutePacks and NS.RoutePacks[packID]
    local catalog = pack and pack.catalog
    if not pack or not catalog then
        return { entries = {}, dataReady = false }, false
    end

    local interfaceVersion, interfaceKnown = NS.API.WoW:GetInterfaceVersion()
    if not interfaceKnown or interfaceVersion ~= pack.interface then
        return { entries = {}, dataReady = false, unavailableReason = "interface_mismatch" }, false
    end
    if self.cache and not INVALIDATING_REASONS[reason] then
        return self.cache, true
    end

    local entries = {}
    local completion = {
        mounts = { current = 0, total = 0 },
        pets = { current = 0, total = 0 },
        achievements = { current = 0, total = 0 },
    }
    for _, spellID in ipairs(catalog.mounts or {}) do
        local info, known = NS.API.WoW:GetMountCollectionInfoBySpellID(spellID)
        if known and info and not info.hiddenOnCharacter then
            completion.mounts.total = completion.mounts.total + 1
            if info.collected then
                completion.mounts.current = completion.mounts.current + 1
            else
                entries[#entries + 1] = {
                    id = "12_1_catalog_mount_" .. spellID,
                    goal = NS.Constants.GOAL.MOUNTS,
                    kind = "mount",
                    name = info.name,
                    description = info.sourceText,
                    reason = string.format(NS.L.PATCH_CATALOG_MOUNT_REASON, info.name),
                    iconFileID = info.iconFileID,
                    sourceText = info.sourceText,
                    flavorText = info.description,
                    releaseStatus = releaseStatus(catalog.seasonMounts[spellID], state),
                    target = {
                        kind = "mount",
                        mountID = info.mountID,
                        spellID = info.spellID,
                        itemLink = info.mountLink,
                        iconFileID = info.iconFileID,
                        name = info.name,
                        releaseStatus = releaseStatus(catalog.seasonMounts[spellID], state),
                        acquisition = "client_confirmed",
                    },
                    sources = sourceMetadata(pack, "wowheadPatchMountCatalog"),
                }
            end
        end
    end

    for _, speciesID in ipairs(catalog.pets or {}) do
        local info, known = NS.API.WoW:GetPetSpeciesInfo(speciesID)
        if known and info and info.obtainable then
            completion.pets.total = completion.pets.total + 1
            if info.collected then
                completion.pets.current = completion.pets.current + 1
            else
                local status = releaseStatus(catalog.seasonPets[speciesID], state)
                entries[#entries + 1] = {
                    id = "12_1_catalog_pet_" .. speciesID,
                    goal = NS.Constants.GOAL.PETS,
                    kind = "pet",
                    name = info.name,
                    description = info.sourceText,
                    reason = string.format(NS.L.PATCH_CATALOG_PET_REASON, info.name),
                    iconFileID = info.iconFileID,
                    sourceText = info.sourceText,
                    flavorText = info.description,
                    releaseStatus = status,
                    target = {
                        kind = "pet",
                        speciesID = speciesID,
                        iconFileID = info.iconFileID,
                        name = info.name,
                        releaseStatus = status,
                        acquisition = "client_confirmed",
                    },
                    sources = sourceMetadata(pack, "wowheadPatchPetCatalog"),
                }
            end
        end
    end

    for _, achievementID in ipairs(catalog.achievements or {}) do
        local info, known = NS.API.WoW:GetAchievementProgress(achievementID)
        if known and info then
            completion.achievements.total = completion.achievements.total + 1
            if info.completed then
                completion.achievements.current = completion.achievements.current + 1
            else
                local status = releaseStatus(catalog.seasonAchievements[achievementID], state)
                local missingCriteria = {}
                for _, criterion in ipairs(info.criteria or {}) do
                    if not criterion.completed and type(criterion.name) == "string"
                        and criterion.name ~= "" then
                        missingCriteria[#missingCriteria + 1] = criterion.name
                    end
                end
                entries[#entries + 1] = {
                    id = "12_1_catalog_achievement_" .. achievementID,
                    goal = NS.Constants.GOAL.ACHIEVEMENTS,
                    kind = "achievement",
                    name = info.name,
                    description = info.description,
                    reason = string.format(NS.L.PATCH_CATALOG_ACHIEVEMENT_REASON, info.name),
                    iconFileID = info.iconFileID,
                    rewardText = info.rewardText,
                    progress = {
                        current = info.completedCriteria,
                        total = info.totalCriteria,
                    },
                    missingCriteria = missingCriteria,
                    achievementID = achievementID,
                    releaseStatus = status,
                    target = {
                        kind = "achievement",
                        achievementID = achievementID,
                        tooltipLink = info.achievementLink,
                        iconFileID = info.iconFileID,
                        name = info.name,
                        releaseStatus = status,
                        acquisition = "client_confirmed",
                    },
                    sources = sourceMetadata(pack, "wowheadPatchAchievementCatalog"),
                }
            end
        end
    end

    table.sort(entries, function(a, b)
        if a.goal == b.goal then
            return a.name < b.name
        end
        return a.goal < b.goal
    end)
    completion.account = {
        current = completion.mounts.current + completion.pets.current + completion.achievements.current,
        total = completion.mounts.total + completion.pets.total + completion.achievements.total,
    }
    completion.account.dataReady = completion.account.total > 0
    local result = {
        patch = pack.patch,
        reviewedAt = pack.reviewedAt,
        entries = entries,
        completion = completion,
        dataReady = true,
    }
    self.cache = result
    return result, true
end
