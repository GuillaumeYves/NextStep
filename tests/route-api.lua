GetBuildInfo = function()
    return "12.1.0", "12345", "Aug 16 2026", 120100, "12.1.0", "Release"
end

GetServerTime = function()
    return 100000
end

local previewedItem
local selectedMount
local selectedPet
local selectedCollectionTab

IsModifiedClick = function(kind)
    assert(kind == "DRESSUP", "Preview click used the wrong modified-click binding.")
    return true
end

HandleModifiedItemClick = function(itemLink)
    previewedItem = itemLink
end

CollectionsJournal_LoadUI = function()
end

SetCollectionsJournalShown = function(shown, tab)
    assert(shown == true, "The collection journal was not opened.")
    selectedCollectionTab = tab
end

COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS = 1
COLLECTIONS_JOURNAL_TAB_INDEX_PETS = 2

MountJournal_SelectByMountID = function(mountID)
    selectedMount = mountID
end

PetJournal = {}
PetJournal_SelectSpecies = function(journal, speciesID)
    assert(journal == PetJournal, "The pet journal frame was not passed through.")
    selectedPet = speciesID
end

C_DateAndTime = {
    GetSecondsUntilWeeklyReset = function()
        return 7200
    end,
}

C_Expansion = {
    GetCurrentRegionName = function()
        return "Europe"
    end,
}

C_QuestLog = {
    IsQuestFlaggedCompleted = function(questID)
        return questID == 92899
    end,
}

C_MountJournal = {
    GetMountFromItem = function(itemID)
        assert(itemID == 246731, "Unexpected mount item ID.")
        return 777
    end,
    GetMountFromSpell = function(spellID)
        assert(spellID == 1001, "Unexpected mount spell ID.")
        return 777
    end,
    GetMountInfoByID = function(mountID)
        assert(mountID == 777, "The mount ID mapping was not used.")
        return "Dusk Grimlynx", 1001, 1002, false, true, 1, false, false, nil, false, true, 777, false
    end,
    GetMountInfoExtraByID = function(mountID)
        assert(mountID == 777, "Unexpected mount extra info ID.")
        return 5000, "A test mount.", "Drop: Test Boss", false, 230
    end,
    GetMountLink = function(spellID)
        assert(spellID == 1001, "Unexpected mount link spell ID.")
        return "mount:1001"
    end,
}

C_PetJournal = {
    GetNumPetsInJournal = function(creatureID)
        assert(creatureID == 260149, "Unexpected pet creature ID.")
        return 3, 1
    end,
    GetPetInfoBySpeciesID = function(speciesID)
        assert(speciesID == 5132, "Unexpected pet species ID.")
        return "Zesty", 8888, 6, 270000, "Achievement: Safari", "A test pet.",
            false, true, true, false, true
    end,
    GetNumCollectedInfo = function(speciesID)
        assert(speciesID == 5132, "Unexpected collected pet species ID.")
        return 0, 3
    end,
}

EJ_GetEncounterInfo = function(encounterID)
    assert(encounterID == 111, "Unexpected encounter ID.")
    return "Test Boss", "Description", encounterID, 1, "encounter:111", 222
end

GetAchievementInfo = function(achievementID)
    assert(achievementID == 62492, "Unexpected achievement ID.")
    return achievementID, "The Coiled Isle Safari", 10, false, nil, nil, nil,
        "Collect every wild pet.", 0, 9999, "Pet: Zesty"
end

GetAchievementNumCriteria = function(achievementID)
    assert(achievementID == 62492, "Unexpected achievement criteria count request.")
    return 2
end

GetAchievementLink = function(achievementID)
    assert(achievementID == 62492, "Unexpected achievement link request.")
    return "achievement:62492"
end

GetAchievementCriteriaInfo = function(achievementID, index, countHidden)
    assert(achievementID == 62492 and countHidden == true, "Achievement criteria arguments were not preserved.")
    return index == 1 and "Poisoned Parasite" or "Cursed Spawn", 96, index == 1,
        index == 1 and 1 or 0, 1, nil, 0, 262221 + index
end

GetInventoryItemID = function(_, slotID)
    return slotID == 1 and 1001 or nil
end

GetInventoryItemLink = function(_, slotID)
    return slotID == 1 and "item:1001" or nil
end

C_Item = {
    GetDetailedItemLevelInfo = function(itemLink)
        if itemLink == "item:1001" then
            return 292, 292, 292
        elseif itemLink == "item:vault" then
            return 315, 315, 315
        elseif itemLink == "item:vault-upgrade" then
            return 318, 318, 318
        end
    end,
    GetItemInfo = function(item)
        return "Test Helm", item, 4, 292, 80, "Armor", "Plate", 1, "INVTYPE_HEAD", 5555,
            0, 4, 4, 1, 11, 9001
    end,
    IsItemSpecificToPlayerClass = function(itemID)
        assert(itemID == 1001, "Class-set detection should use the numeric equipped item ID.")
        return true
    end,
    GetItemUpgradeInfo = function()
        return {
            currentLevel = 3,
            maxLevel = 6,
            maxItemLevel = 308,
            trackString = "Champion",
            trackStringID = 3,
        }
    end,
}

C_WeeklyRewards = {
    GetExampleRewardItemHyperlinks = function(activityID)
        assert(activityID == 99, "Unexpected Vault activity ID.")
        return "item:vault", "item:vault-upgrade"
    end,
    GetNextActivitiesIncrease = function(activityTierID, level)
        assert(activityTierID == 7 and level == 7, "Unexpected Vault tier lookup.")
        return true, 8, 8, 315
    end,
    GetActivityEncounterInfo = function(activityType, activityIndex)
        assert(activityType == 3 and activityIndex == 1, "Unexpected Vault encounter request.")
        return { { encounterID = 111, bestDifficulty = 15, uiOrder = 1, instanceID = 222 } }
    end,
    GetItemHyperlink = function(itemDBID)
        assert(itemDBID == "reward-1", "Unexpected generated reward ID.")
        return "item:generated"
    end,
}

C_MythicPlus = {
    IsMythicPlusActive = function()
        return true
    end,
    GetRunHistory = function(includePreviousWeeks, includeIncompleteRuns, currentSeasonOnly)
        assert(includePreviousWeeks == true, "Previous run history is required for capability context.")
        assert(includeIncompleteRuns == false and currentSeasonOnly == true, "Run history filters are incorrect.")
        return { { level = 7, thisWeek = true, completed = true } }
    end,
}

C_CurrencyInfo = {
    GetCurrencyInfo = function(currencyID)
        assert(currencyID == 3442, "Unexpected currency ID.")
        return {
            currencyID = currencyID,
            name = "Adventurer Mistcrest",
            quantity = 40,
            maxQuantity = 90,
            totalEarned = 50,
            useTotalEarnedForMaxQty = true,
            iconFileID = 1234,
        }
    end,
    GetCurrencyLink = function(currencyID, quantity)
        assert(currencyID == 3442 and quantity == 40, "Currency link arguments were not preserved.")
        return "currency:3442"
    end,
}

local SafeCall = {}
function SafeCall:Invoke(callback, ...)
    local results = { pcall(callback, ...) }
    assert(results[1], results[2])
    table.remove(results, 1)
    return true, unpack(results)
end

local NS = {
    Util = { SafeCall = SafeCall },
}

local chunk, loadError = loadfile("API/WoW.lua")
assert(chunk, loadError)
chunk("NextStep", NS)

local interfaceVersion, interfaceKnown = NS.API.WoW:GetInterfaceVersion()
assert(interfaceKnown == true and interfaceVersion == 120100, "The interface version was not normalized.")

assert(NS.API.WoW:IsPreviewModifiedClick() == true, "Ctrl-click preview was not detected.")
assert(NS.API.WoW:PreviewItem("item:1001") == true and previewedItem == "item:1001",
    "Item preview did not use the standard modified item click.")
assert(NS.API.WoW:PreviewMount(777) == true and selectedMount == 777 and selectedCollectionTab == 1,
    "Mount preview did not select the mount collection entry.")
assert(NS.API.WoW:PreviewPet(5132) == true and selectedPet == 5132 and selectedCollectionTab == 2,
    "Pet preview did not select the pet collection entry.")

local reset, resetKnown = NS.API.WoW:GetWeeklyResetInfo()
assert(resetKnown == true and reset.resetAt == 107200, "The weekly reset timestamp was not normalized.")
assert(reset.regionName == "Europe", "The region name was not normalized.")

local questCompleted, questKnown = NS.API.WoW:IsQuestCompleted(92899)
assert(questKnown == true and questCompleted == true, "Quest completion was not normalized.")

local mount, mountKnown = NS.API.WoW:GetMountCollectionInfoByItemID(246731)
assert(mountKnown == true and mount.collected == true, "Mount ownership was not normalized.")
assert(mount.mountID == 777 and mount.iconFileID == 1002, "Mount metadata was not normalized.")
assert(mount.itemID == 246731 and mount.mountLink == "mount:1001",
    "Item-backed mounts should retain both reward and Mount Journal identities.")

local spellMount, spellMountKnown = NS.API.WoW:GetMountCollectionInfoBySpellID(1001)
assert(spellMountKnown == true and spellMount.sourceText == "Drop: Test Boss",
    "Mount Journal source text was not normalized.")
assert(spellMount.mountLink == "mount:1001", "Mount Journal link was not normalized.")

local pet, petKnown = NS.API.WoW:GetPetCollectionInfoByCreatureID(260149)
assert(petKnown == true and pet.collected == true and pet.count == 1, "Pet ownership was not normalized.")

local species, speciesKnown = NS.API.WoW:GetPetSpeciesInfo(5132)
assert(speciesKnown == true and species.name == "Zesty" and species.iconFileID == 8888,
    "Pet species preview metadata was not normalized.")

local achievement, achievementKnown = NS.API.WoW:GetAchievementProgress(62492)
assert(achievementKnown == true and achievement.completed == false, "Achievement state was not normalized.")
assert(achievement.completedCriteria == 1 and achievement.totalCriteria == 2, "Achievement progress was not counted.")
assert(achievement.criteria[2].name == "Cursed Spawn", "Achievement criteria were not preserved.")
assert(achievement.achievementLink == "achievement:62492", "The native achievement tooltip link was not preserved.")

local item, itemKnown = NS.API.WoW:GetEquippedItemDetails(1)
assert(itemKnown == true and item.itemLevel == 292, "Equipped item level was not normalized.")
assert(item.upgradeInfo.maxItemLevel == 308, "Equipped upgrade information was not normalized.")
assert(item.iconFileID == 5555, "Equipped item icon was not normalized.")
assert(item.setID == 9001 and item.classSpecific == true, "Equipped class-set data was not normalized.")

local preview, previewKnown = NS.API.WoW:GetWeeklyRewardPreview(99)
assert(previewKnown == true and preview.itemLevel == 315, "Vault preview item level was not normalized.")
assert(preview.upgradeItemLevel == 318, "Vault upgrade preview was not normalized.")
assert(preview.iconFileID == 5555, "Vault preview icon was not normalized.")

local encounters, encountersKnown = NS.API.WoW:GetWeeklyRewardEncounterInfo(3, 1)
assert(encountersKnown == true and encounters[1].name == "Test Boss",
    "Vault encounter progress was not normalized.")
assert(NS.API.WoW:GetWeeklyRewardItemLink("reward-1") == "item:generated",
    "Generated Vault reward links were not normalized.")

local increase, increaseKnown = NS.API.WoW:GetNextWeeklyActivityIncrease(7, 7)
assert(increaseKnown == true and increase.level == 8 and increase.itemLevel == 315, "Next Vault increase was not normalized.")

local mythicPlus, mythicPlusKnown = NS.API.WoW:GetMythicPlusState()
assert(mythicPlusKnown == true and mythicPlus.active == true, "Mythic Plus state was not normalized.")
assert(#mythicPlus.runs == 1, "Mythic Plus run history was not preserved.")

local currency, currencyKnown = NS.API.WoW:GetCurrencyInfo(3442)
assert(currencyKnown == true and currency.totalEarned == 50, "Currency cap fields were not preserved.")
assert(NS.API.WoW:GetCurrencyLink(3442, 40) == "currency:3442", "Currency link was not preserved.")

NS.CurrencyConfig = { tracked = { { currencyID = 3442, enabled = true } } }
local currencyChunk, currencyLoadError = loadfile("Data/Currency.lua")
assert(currencyChunk, currencyLoadError)
currencyChunk("NextStep", NS)
local currencies, currencyCapability = NS.Data.Currency:Collect()
assert(currencyCapability == true and #currencies == 1, "Tracked currency collection failed.")
assert(currencies[1].totalEarned == 50 and currencies[1].maxQuantity == 90,
    "Dynamic currency cap fields were not normalized.")
assert(currencies[1].currencyLink == "currency:3442", "Currency tooltip link was not normalized.")

print("Curated route API wrapper tests passed.")
