local _, NS = ...

NS.Model = NS.Model or {}
local PlayerState = {}
NS.Model.PlayerState = PlayerState

function PlayerState:New()
    return {
        generatedAt = nil,
        character = {
            name = nil,
            realm = nil,
            level = nil,
            maxLevel = nil,
            classID = nil,
            className = nil,
            specID = nil,
            specName = nil,
            averageItemLevel = nil,
            equippedItemLevel = nil,
        },
        currencies = {},
        experience = {
            current = nil,
            maximum = nil,
            rested = nil,
            percent = nil,
            restedPercentOfLevel = nil,
        },
        quests = {
            entries = {},
            readyForTurnIn = {},
            trackedQuest = nil,
            dataReady = false,
        },
        leveling = {
            dungeonFinderAvailable = false,
            availableDungeonCount = 0,
        },
        equipment = {
            items = {},
            emptySlots = {},
            upgradeEligibilityReliable = false,
        },
        vault = {
            available = false,
            dataReady = false,
            activities = {},
            rewardsAvailable = false,
        },
        weekly = {},
        activities = {},
        capabilities = {
            character = false,
            experience = false,
            questLog = false,
            levelingDungeons = false,
            currencies = false,
            equipment = false,
            greatVault = false,
        },
    }
end
