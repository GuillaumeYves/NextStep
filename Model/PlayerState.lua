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
            classFile = nil,
            classColor = nil,
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
            availableDungeons = {},
        },
        equipment = {
            items = {},
            emptySlots = {},
            upgradeableItems = {},
            lowestItem = nil,
            classSet = { pieces = 0, requiredPieces = 4 },
            classSetDetectionReady = false,
            upgradeEligibilityReliable = false,
        },
        vault = {
            available = false,
            dataReady = false,
            activities = {},
            rewardsAvailable = false,
        },
        weekly = {
            vault = {},
            reset = { dataReady = false },
        },
        mythicPlus = {
            active = false,
            currentWeekRuns = {},
            dataReady = false,
        },
        progression = {
            dataReady = false,
        },
        activities = {},
        curatedRoutes = {
            packID = nil,
            patch = nil,
            reviewedAt = nil,
            phase = nil,
            available = {},
            dataReady = false,
        },
        patchCatalog = {
            patch = nil,
            reviewedAt = nil,
            entries = {},
            dataReady = false,
        },
        patchProgress = {
            character = { current = 0, total = 0, groups = {}, dataReady = false },
            account = { current = 0, total = 0, groups = {}, dataReady = false },
            dataReady = false,
        },
        capabilities = {
            character = false,
            experience = false,
            questLog = false,
            levelingDungeons = false,
            currencies = false,
            equipment = false,
            greatVault = false,
            mythicPlus = false,
            curatedRoutes = false,
            patchCatalog = false,
            patchProgress = false,
        },
    }
end
