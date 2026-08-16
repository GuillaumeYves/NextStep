local _, NS = ...

NS.API = NS.API or {}
local WoW = {}
NS.API.WoW = WoW

local SafeCall = NS.Util.SafeCall

function WoW:GetLocale()
    local ok, locale = SafeCall:Invoke(GetLocale)
    if ok and type(locale) == "string" and locale ~= "" then
        return locale
    end
    return "enUS"
end

function WoW:IsInCombat()
    return InCombatLockdown and InCombatLockdown() == true
end

function WoW:GetTimestamp()
    local ok, value = SafeCall:Invoke(GetServerTime)
    if ok and type(value) == "number" then
        return value
    end
    return time()
end

function WoW:GetWeeklyResetInfo()
    if not C_DateAndTime or not C_DateAndTime.GetSecondsUntilWeeklyReset then
        return nil, false
    end

    local secondsOK, seconds = SafeCall:Invoke(C_DateAndTime.GetSecondsUntilWeeklyReset)
    if not secondsOK or type(seconds) ~= "number" or seconds < 0 then
        return nil, false
    end

    local now = self:GetTimestamp()
    local regionName
    if C_Expansion and C_Expansion.GetCurrentRegionName then
        local regionOK, value = SafeCall:Invoke(C_Expansion.GetCurrentRegionName)
        if regionOK and type(value) == "string" and value ~= "" then
            regionName = value
        end
    end

    return {
        secondsUntilReset = seconds,
        resetAt = now + seconds,
        regionName = regionName,
    }, true
end

function WoW:GetInterfaceVersion()
    if type(GetBuildInfo) ~= "function" then
        return nil, false
    end
    local ok, _, _, _, interfaceVersion = SafeCall:Invoke(GetBuildInfo)
    if not ok or type(interfaceVersion) ~= "number" then
        return nil, false
    end
    return interfaceVersion, true
end

function WoW:GetCharacterIdentity()
    local name = UnitName("player")
    local realm = GetRealmName()
    local level = UnitLevel("player")
    local className, classFile, classID = UnitClass("player")

    local classColor
    if classFile and C_ClassColor and C_ClassColor.GetClassColor then
        local colorOK, color = SafeCall:Invoke(C_ClassColor.GetClassColor, classFile)
        if colorOK and type(color) == "table" then
            classColor = { r = color.r, g = color.g, b = color.b }
        end
    end

    return {
        name = name,
        realm = realm,
        level = level,
        classID = classID,
        className = className,
        classFile = classFile,
        classColor = classColor,
    }
end

function WoW:IsPreviewModifiedClick()
    if type(IsModifiedClick) ~= "function" then
        return false
    end
    local ok, modified = SafeCall:Invoke(IsModifiedClick, "DRESSUP")
    return ok and modified == true
end

function WoW:PreviewItem(itemLink)
    if type(itemLink) ~= "string" or type(HandleModifiedItemClick) ~= "function" then
        return false
    end
    local ok = SafeCall:Invoke(HandleModifiedItemClick, itemLink)
    return ok == true
end

local function loadCollections()
    if type(CollectionsJournal_LoadUI) ~= "function" then
        return false
    end
    local ok = SafeCall:Invoke(CollectionsJournal_LoadUI)
    return ok == true
end

function WoW:PreviewMount(mountID)
    if type(mountID) ~= "number" or not loadCollections()
        or type(SetCollectionsJournalShown) ~= "function"
        or type(MountJournal_SelectByMountID) ~= "function" then
        return false
    end
    local shownOK = SafeCall:Invoke(
        SetCollectionsJournalShown,
        true,
        COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS or 1
    )
    local selectedOK = SafeCall:Invoke(MountJournal_SelectByMountID, mountID)
    return shownOK == true and selectedOK == true
end

function WoW:PreviewPet(speciesID)
    if type(speciesID) ~= "number" or not loadCollections()
        or type(SetCollectionsJournalShown) ~= "function"
        or type(PetJournal_SelectSpecies) ~= "function" or not PetJournal then
        return false
    end
    local shownOK = SafeCall:Invoke(
        SetCollectionsJournalShown,
        true,
        COLLECTIONS_JOURNAL_TAB_INDEX_PETS or 2
    )
    local selectedOK = SafeCall:Invoke(PetJournal_SelectSpecies, PetJournal, speciesID)
    return shownOK == true and selectedOK == true
end

function WoW:GetPetSpeciesInfo(speciesID)
    if type(speciesID) ~= "number" or not C_PetJournal or not C_PetJournal.GetPetInfoBySpeciesID then
        return nil, false
    end
    local ok, name, iconFileID, petType, creatureID, sourceText, description,
        isWild, canBattle, isTradeable, isUnique, obtainable = SafeCall:Invoke(
        C_PetJournal.GetPetInfoBySpeciesID,
        speciesID
    )
    if not ok or type(name) ~= "string" or name == "" then
        return nil, false
    end
    local collectedCount = 0
    if C_PetJournal.GetNumCollectedInfo then
        local countOK, count = SafeCall:Invoke(C_PetJournal.GetNumCollectedInfo, speciesID)
        if countOK and type(count) == "number" then
            collectedCount = count
        end
    end
    return {
        speciesID = speciesID,
        name = name,
        iconFileID = iconFileID,
        petType = petType,
        creatureID = creatureID,
        sourceText = sourceText,
        description = description,
        isWild = isWild == true,
        canBattle = canBattle == true,
        isTradeable = isTradeable == true,
        isUnique = isUnique == true,
        obtainable = obtainable ~= false,
        collected = collectedCount > 0,
        collectedCount = collectedCount,
    }, true
end

function WoW:GetMountCollectionInfoBySpellID(spellID)
    if type(spellID) ~= "number" or not C_MountJournal
        or not C_MountJournal.GetMountFromSpell
        or not C_MountJournal.GetMountInfoByID
        or not C_MountJournal.GetMountInfoExtraByID then
        return nil, false
    end

    local mountOK, mountID = SafeCall:Invoke(C_MountJournal.GetMountFromSpell, spellID)
    if not mountOK or type(mountID) ~= "number" then
        return nil, false
    end
    local infoOK, name, returnedSpellID, iconFileID, _, _, sourceType, _,
        isFactionSpecific, faction, shouldHideOnChar, isCollected =
        SafeCall:Invoke(C_MountJournal.GetMountInfoByID, mountID)
    if not infoOK or type(name) ~= "string" or name == "" then
        return nil, false
    end
    local extraOK, _, description, sourceText = SafeCall:Invoke(
        C_MountJournal.GetMountInfoExtraByID,
        mountID
    )
    local mountLink
    if C_MountJournal.GetMountLink then
        local linkOK, link = SafeCall:Invoke(C_MountJournal.GetMountLink, returnedSpellID or spellID)
        mountLink = linkOK and link or nil
    end
    return {
        spellID = returnedSpellID or spellID,
        mountID = mountID,
        name = name,
        iconFileID = iconFileID,
        sourceType = sourceType,
        sourceText = extraOK and sourceText or nil,
        description = extraOK and description or nil,
        mountLink = mountLink,
        factionSpecific = isFactionSpecific == true,
        faction = faction,
        hiddenOnCharacter = shouldHideOnChar == true,
        collected = isCollected == true,
    }, true
end

function WoW:GetMaximumPlayerLevel()
    local ok, maxLevel = SafeCall:Invoke(GetMaxLevelForPlayerExpansion)
    if ok and type(maxLevel) == "number" and maxLevel > 0 then
        return maxLevel
    end
    return nil
end

function WoW:GetSpecialization()
    if not C_SpecializationInfo or not C_SpecializationInfo.GetSpecialization then
        return nil, nil
    end

    local ok, specIndex = SafeCall:Invoke(C_SpecializationInfo.GetSpecialization)
    if not ok or type(specIndex) ~= "number" or specIndex <= 0 then
        return nil, nil
    end

    local infoOk, specID, specName = SafeCall:Invoke(C_SpecializationInfo.GetSpecializationInfo, specIndex)
    if not infoOk then
        return nil, nil
    end
    return specID, specName
end

function WoW:GetItemLevels()
    local ok, average, equipped = SafeCall:Invoke(GetAverageItemLevel)
    if not ok then
        return nil, nil
    end
    return average, equipped
end

function WoW:GetItemDisplayInfo(itemIDOrLink, classCheckItemID)
    if not C_Item or not C_Item.GetItemInfo or itemIDOrLink == nil then
        return nil, false
    end

    local ok, name, itemLink, quality, _, _, _, _, _, _, iconFileID, _, _, _, _, _, setID =
        SafeCall:Invoke(C_Item.GetItemInfo, itemIDOrLink)
    if not ok then
        return nil, false
    end

    local classSpecific
    if classCheckItemID and C_Item.IsItemSpecificToPlayerClass then
        local classOK, value = SafeCall:Invoke(
            C_Item.IsItemSpecificToPlayerClass,
            classCheckItemID
        )
        if classOK then
            classSpecific = value == true
        end
    end
    return {
        name = name,
        itemLink = itemLink,
        quality = quality,
        iconFileID = iconFileID,
        setID = setID,
        classSpecific = classSpecific,
    }, name ~= nil or iconFileID ~= nil
end

function WoW:GetExperience()
    local currentOK, current = SafeCall:Invoke(UnitXP, "player")
    local maximumOK, maximum = SafeCall:Invoke(UnitXPMax, "player")
    local restedOK, rested = SafeCall:Invoke(GetXPExhaustion)

    if not currentOK or not maximumOK then
        return nil, nil, nil, false
    end
    return current, maximum, restedOK and rested or nil, true
end

function WoW:GetQuestLogEntryCount()
    if not C_QuestLog or not C_QuestLog.GetNumQuestLogEntries then
        return 0, false
    end
    local ok, count = SafeCall:Invoke(C_QuestLog.GetNumQuestLogEntries)
    return ok and count or 0, ok
end

function WoW:GetQuestLogInfo(index)
    if not C_QuestLog or not C_QuestLog.GetInfo then
        return nil
    end
    local ok, info = SafeCall:Invoke(C_QuestLog.GetInfo, index)
    return ok and info or nil
end

function WoW:IsQuestReadyForTurnIn(questID)
    if not C_QuestLog or not C_QuestLog.ReadyForTurnIn then
        return nil
    end
    local ok, ready = SafeCall:Invoke(C_QuestLog.ReadyForTurnIn, questID)
    if ok then
        return ready
    end
    return nil
end

function WoW:GetQuestRewardXP(questID)
    if type(GetQuestLogRewardXP) ~= "function" then
        return nil
    end
    local ok, rewardXP = SafeCall:Invoke(GetQuestLogRewardXP, questID)
    return ok and rewardXP or nil
end

function WoW:GetSuperTrackedQuestID()
    if not C_SuperTrack or not C_SuperTrack.GetSuperTrackedQuestID then
        return nil
    end
    local ok, questID = SafeCall:Invoke(C_SuperTrack.GetSuperTrackedQuestID)
    return ok and questID or nil
end

function WoW:GetQuestTitle(questID)
    if not C_QuestLog or not C_QuestLog.GetTitleForQuestID then
        return nil
    end
    local ok, title = SafeCall:Invoke(C_QuestLog.GetTitleForQuestID, questID)
    return ok and title or nil
end

function WoW:IsQuestCompleted(questID)
    if not C_QuestLog or not C_QuestLog.IsQuestFlaggedCompleted then
        return nil, false
    end
    local ok, completed = SafeCall:Invoke(C_QuestLog.IsQuestFlaggedCompleted, questID)
    if not ok then
        return nil, false
    end
    return completed == true, true
end

function WoW:GetMountCollectionInfoByItemID(itemID)
    if not C_MountJournal or not C_MountJournal.GetMountFromItem
        or not C_MountJournal.GetMountInfoByID then
        return nil, false
    end

    local mountOK, mountID = SafeCall:Invoke(C_MountJournal.GetMountFromItem, itemID)
    if not mountOK or type(mountID) ~= "number" then
        return nil, false
    end

    local infoOK, name, _, icon, _, _, _, _, _, _, _, isCollected =
        SafeCall:Invoke(C_MountJournal.GetMountInfoByID, mountID)
    if not infoOK or type(isCollected) ~= "boolean" then
        return nil, false
    end

    return {
        itemID = itemID,
        mountID = mountID,
        name = name,
        iconFileID = icon,
        collected = isCollected,
    }, true
end

function WoW:GetPetCollectionInfoByCreatureID(creatureID)
    if not C_PetJournal or not C_PetJournal.GetNumPetsInJournal then
        return nil, false
    end

    local ok, maxAllowed, numPets = SafeCall:Invoke(C_PetJournal.GetNumPetsInJournal, creatureID)
    if not ok or type(numPets) ~= "number" then
        return nil, false
    end

    return {
        creatureID = creatureID,
        maxAllowed = maxAllowed,
        count = numPets,
        collected = numPets > 0,
    }, true
end

function WoW:GetAchievementProgress(achievementID)
    if type(GetAchievementInfo) ~= "function"
        or type(GetAchievementNumCriteria) ~= "function"
        or type(GetAchievementCriteriaInfo) ~= "function" then
        return nil, false
    end

    local infoOK, id, name, _, completed, _, _, _, description, _, icon, rewardText =
        SafeCall:Invoke(GetAchievementInfo, achievementID)
    if not infoOK or type(id) ~= "number" then
        return nil, false
    end

    local countOK, criteriaCount = SafeCall:Invoke(GetAchievementNumCriteria, achievementID)
    if not countOK or type(criteriaCount) ~= "number" then
        return nil, false
    end

    local criteria = {}
    local completedCount = 0
    for index = 1, criteriaCount do
        local criteriaOK, criteriaName, _, criteriaCompleted, quantity, requiredQuantity, _, _, assetID =
            SafeCall:Invoke(GetAchievementCriteriaInfo, achievementID, index, true)
        if not criteriaOK then
            return nil, false
        end
        if criteriaCompleted then
            completedCount = completedCount + 1
        end
        criteria[#criteria + 1] = {
            index = index,
            name = criteriaName,
            completed = criteriaCompleted == true,
            quantity = quantity,
            requiredQuantity = requiredQuantity,
            assetID = assetID,
        }
    end

    return {
        achievementID = achievementID,
        name = name,
        description = description,
        iconFileID = icon,
        rewardText = rewardText,
        completed = completed == true,
        completedCriteria = completedCount,
        totalCriteria = criteriaCount,
        criteria = criteria,
    }, true
end

function WoW:GetLevelingDungeons(level)
    if not C_LFGInfo or not C_LFGInfo.CanPlayerUseLFD or not C_LFGInfo.GetLevelUpInstances then
        return false, {}, false
    end

    local useOK, canUse = SafeCall:Invoke(C_LFGInfo.CanPlayerUseLFD)
    local listOK, instances = SafeCall:Invoke(C_LFGInfo.GetLevelUpInstances, level, false)
    if not useOK or not listOK or type(instances) ~= "table" then
        return false, {}, false
    end

    local dungeons = {}
    for _, dungeonID in ipairs(instances) do
        local dungeon = { dungeonID = dungeonID }
        if C_LFGInfo.GetDungeonInfo then
            local infoOK, info = SafeCall:Invoke(C_LFGInfo.GetDungeonInfo, dungeonID)
            if infoOK and type(info) == "table" then
                dungeon.name = info.name
                dungeon.iconID = info.iconID
                dungeon.link = info.link
            end
        end
        dungeons[#dungeons + 1] = dungeon
    end

    return canUse == true and #dungeons > 0, dungeons, true
end

function WoW:GetEquippedItemID(slotID)
    if type(GetInventoryItemID) ~= "function" then
        return nil, false
    end
    local ok, itemID = SafeCall:Invoke(GetInventoryItemID, "player", slotID)
    return ok and itemID or nil, ok
end

function WoW:GetEquippedItemDetails(slotID)
    if type(GetInventoryItemID) ~= "function" or type(GetInventoryItemLink) ~= "function" then
        return nil, false
    end

    local idOK, itemID = SafeCall:Invoke(GetInventoryItemID, "player", slotID)
    local linkOK, itemLink = SafeCall:Invoke(GetInventoryItemLink, "player", slotID)
    if not idOK or not linkOK then
        return nil, false
    end
    if not itemID then
        return { slotID = slotID, itemID = nil }, true
    end

    local itemLevel
    if itemLink and C_Item and C_Item.GetDetailedItemLevelInfo then
        local levelOK, actualItemLevel = SafeCall:Invoke(C_Item.GetDetailedItemLevelInfo, itemLink)
        if levelOK then
            itemLevel = actualItemLevel
        end
    end

    local displayInfo = itemLink and self:GetItemDisplayInfo(itemLink, itemID) or nil

    local upgradeInfo
    if itemLink and C_Item and C_Item.GetItemUpgradeInfo then
        local upgradeOK, info = SafeCall:Invoke(C_Item.GetItemUpgradeInfo, itemLink)
        if upgradeOK and type(info) == "table" then
            upgradeInfo = {
                currentLevel = info.currentLevel,
                maxLevel = info.maxLevel,
                maxItemLevel = info.maxItemLevel,
                trackString = info.trackString,
                trackStringID = info.trackStringID,
            }
        end
    end

    return {
        slotID = slotID,
        itemID = itemID,
        itemLink = itemLink,
        name = displayInfo and displayInfo.name or nil,
        iconFileID = displayInfo and displayInfo.iconFileID or nil,
        itemLevel = itemLevel,
        setID = displayInfo and displayInfo.setID or nil,
        classSpecific = displayInfo and displayInfo.classSpecific or nil,
        upgradeInfo = upgradeInfo,
    }, itemLevel ~= nil
end

function WoW:GetCurrencyInfo(currencyID)
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return nil, false
    end

    local ok, info = SafeCall:Invoke(C_CurrencyInfo.GetCurrencyInfo, currencyID)
    if not ok then
        return nil, false
    end
    return info, true
end

function WoW:GetCurrencyLink(currencyID, quantity)
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyLink then
        return nil
    end
    local ok, link = SafeCall:Invoke(C_CurrencyInfo.GetCurrencyLink, currencyID, quantity)
    return ok and link or nil
end

function WoW:GetWeeklyRewardActivities()
    if not C_WeeklyRewards or not C_WeeklyRewards.GetActivities then
        return {}, false
    end

    local ok, activities = SafeCall:Invoke(C_WeeklyRewards.GetActivities)
    if not ok or type(activities) ~= "table" then
        return {}, false
    end
    return activities, true
end

function WoW:GetWeeklyRewardPreview(activityID)
    if not C_WeeklyRewards or not C_WeeklyRewards.GetExampleRewardItemHyperlinks
        or not C_Item or not C_Item.GetDetailedItemLevelInfo then
        return nil, false
    end

    local ok, itemLink, upgradeItemLink =
        SafeCall:Invoke(C_WeeklyRewards.GetExampleRewardItemHyperlinks, activityID)
    if not ok then
        return nil, false
    end

    local itemLevel
    local upgradeItemLevel
    if itemLink then
        local levelOK, level = SafeCall:Invoke(C_Item.GetDetailedItemLevelInfo, itemLink)
        itemLevel = levelOK and level or nil
    end
    if upgradeItemLink then
        local levelOK, level = SafeCall:Invoke(C_Item.GetDetailedItemLevelInfo, upgradeItemLink)
        upgradeItemLevel = levelOK and level or nil
    end

    local itemDisplay = itemLink and self:GetItemDisplayInfo(itemLink) or nil

    return {
        itemLink = itemLink,
        itemLevel = itemLevel,
        iconFileID = itemDisplay and itemDisplay.iconFileID or nil,
        upgradeItemLink = upgradeItemLink,
        upgradeItemLevel = upgradeItemLevel,
    }, itemLevel ~= nil
end

function WoW:GetWeeklyRewardEncounterInfo(activityType, activityIndex)
    if not C_WeeklyRewards or not C_WeeklyRewards.GetActivityEncounterInfo then
        return {}, false
    end

    local ok, encounters = SafeCall:Invoke(
        C_WeeklyRewards.GetActivityEncounterInfo,
        activityType,
        activityIndex
    )
    if not ok or type(encounters) ~= "table" then
        return {}, false
    end

    local normalized = {}
    for _, encounter in ipairs(encounters) do
        if type(encounter) == "table" and type(encounter.encounterID) == "number" then
            local name
            if type(EJ_GetEncounterInfo) == "function" then
                local nameOK, encounterName = SafeCall:Invoke(EJ_GetEncounterInfo, encounter.encounterID)
                if nameOK then
                    name = encounterName
                end
            end
            normalized[#normalized + 1] = {
                encounterID = encounter.encounterID,
                name = name,
                bestDifficulty = encounter.bestDifficulty,
                uiOrder = encounter.uiOrder,
                instanceID = encounter.instanceID,
            }
        end
    end
    table.sort(normalized, function(a, b)
        return (a.uiOrder or 0) < (b.uiOrder or 0)
    end)
    return normalized, true
end

function WoW:GetWeeklyRewardItemLink(itemDBID)
    if itemDBID == nil or not C_WeeklyRewards or not C_WeeklyRewards.GetItemHyperlink then
        return nil
    end
    local ok, itemLink = SafeCall:Invoke(C_WeeklyRewards.GetItemHyperlink, itemDBID)
    return ok and itemLink or nil
end

function WoW:GetNextWeeklyActivityIncrease(activityTierID, level)
    if not C_WeeklyRewards or not C_WeeklyRewards.GetNextActivitiesIncrease then
        return nil, false
    end
    local ok, hasSeasonData, nextActivityTierID, nextLevel, itemLevel =
        SafeCall:Invoke(C_WeeklyRewards.GetNextActivitiesIncrease, activityTierID, level)
    if not ok then
        return nil, false
    end
    return {
        hasSeasonData = hasSeasonData == true,
        activityTierID = nextActivityTierID,
        level = nextLevel,
        itemLevel = itemLevel,
    }, true
end

function WoW:GetMythicPlusState()
    if not C_MythicPlus or not C_MythicPlus.IsMythicPlusActive
        or not C_MythicPlus.GetRunHistory then
        return { active = false, runs = {} }, false
    end

    local activeOK, active = SafeCall:Invoke(C_MythicPlus.IsMythicPlusActive)
    local runsOK, runs = SafeCall:Invoke(C_MythicPlus.GetRunHistory, true, false, true)
    if not activeOK or not runsOK or type(runs) ~= "table" then
        return { active = active == true, runs = {} }, false
    end
    return { active = active == true, runs = runs }, true
end

function WoW:IsWeeklyChestRetired()
    if not C_WeeklyRewards or not C_WeeklyRewards.IsWeeklyChestRetired then
        return nil
    end
    local ok, retired = SafeCall:Invoke(C_WeeklyRewards.IsWeeklyChestRetired)
    if ok then
        return retired
    end
    return nil
end

function WoW:HasAvailableWeeklyRewards()
    if not C_WeeklyRewards or not C_WeeklyRewards.HasAvailableRewards then
        return nil
    end
    local ok, available = SafeCall:Invoke(C_WeeklyRewards.HasAvailableRewards)
    if ok then
        return available
    end
    return nil
end

function WoW:GetWeeklyRewardTypeKey(activityType)
    local types = Enum and Enum.WeeklyRewardChestThresholdType
    if not types then
        return "unknown"
    end
    if activityType == types.Activities then
        return "dungeon"
    elseif activityType == types.Raid then
        return "raid"
    elseif activityType == types.RankedPvP then
        return "pvp"
    elseif activityType == types.World then
        return "world"
    elseif activityType == types.Concession then
        return "concession"
    end
    return "unknown"
end
