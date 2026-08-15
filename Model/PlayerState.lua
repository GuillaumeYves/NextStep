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
        equipment = {
            items = {},
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
            currencies = false,
            equipment = false,
            greatVault = false,
        },
    }
end
