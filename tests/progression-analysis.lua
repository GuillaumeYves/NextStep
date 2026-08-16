local NS = {
    Data = {},
    Model = {},
    Recommendation = {},
    Util = {
        Formatting = {
            List = function(_, values)
                return table.concat(values, ", ")
            end,
            Number = function(_, value)
                return tostring(value)
            end,
        },
    },
    EquipmentConfig = {
        minimumGuidanceLevel = 1,
        essentialSlots = {
            { slotID = 1, key = "head" },
            { slotID = 2, key = "neck" },
        },
    },
    API = { WoW = {} },
}

function NS.API.WoW:GetItemLevels()
    return 300, 300
end

function NS.API.WoW:GetWeeklyResetInfo()
    return { secondsUntilReset = 3600, resetAt = 200000, regionName = "Europe" }, true
end

function NS.API.WoW:GetEquippedItemDetails(slotID)
    if slotID == 1 then
        return {
            itemID = 1001,
            itemLink = "item:1001",
            name = "Test Helm",
            iconFileID = 5555,
            itemLevel = 292,
            upgradeInfo = {
                currentLevel = 3,
                maxLevel = 6,
                maxItemLevel = 308,
                trackString = "Champion",
                trackStringID = 3,
            },
        }, true
    end
    return {
        itemID = 1002,
        itemLink = "item:1002",
        name = "Test Neck",
        itemLevel = 300,
    }, true
end

local function loadAddonFile(path)
    local chunk, loadError = loadfile(path)
    assert(chunk, loadError)
    chunk("NextStep", NS)
end

loadAddonFile("Config/SeasonConfig.lua")
loadAddonFile("Config/RoutePacks/12_1/Manifest.lua")
loadAddonFile("Config/RoutePacks/12_1/Gearing.lua")
loadAddonFile("Localization/Strings.lua")
NS.L = NS.Locales.enUS
loadAddonFile("Data/Equipment.lua")
loadAddonFile("Data/Progression.lua")
loadAddonFile("Data/GreatVault.lua")
loadAddonFile("Data/Weekly.lua")
loadAddonFile("Model/Recommendation.lua")

NS.Constants = {
    GOAL = { EXPERIENCE = "experience", GEAR = "gear" },
    IMPORTANCE = { CRITICAL = "CRITICAL", HIGH = "HIGH", USEFUL = "USEFUL" },
    IMPORTANCE_SCORE = { CRITICAL = 100, HIGH = 80, USEFUL = 50 },
    STATUS = { AVAILABLE = "available" },
}
loadAddonFile("Recommendation/Scoring.lua")
NS.Recommendation.Reasons = {
    LEVELING = "leveling",
    TRACKED_QUEST = "tracked",
    QUEST_TURN_IN = "turn in",
    RESTED_XP = "rested",
    LEVELING_DUNGEON = "dungeon",
    EMPTY_GEAR = "empty",
    VAULT_CLAIM = "claim",
    VAULT_UNLOCK = "unlock",
}
loadAddonFile("Recommendation/Rules.lua")

local equipment, equipmentReady = NS.Data.Equipment:Collect()
assert(equipmentReady == true, "Equipment should be ready.")
assert(#equipment.upgradeableItems == 1, "One upgradeable item should be detected.")
assert(equipment.upgradeableItems[1].upgrade.maxItemLevel == 308, "Upgrade cap was not normalized.")
assert(equipment.lowestItem.slotKey == "head" and equipment.lowestItem.itemLevel == 292,
    "The lowest equipped slot was not normalized.")

local state = {
    character = { level = 90, maxLevel = 90, averageItemLevel = 300 },
    equipment = equipment,
    currencies = {
        { currencyID = 3444, name = "Champion Mistcrest", quantity = 12 },
    },
    mythicPlus = {
        active = true,
        dataReady = true,
        currentWeekRuns = {
            { level = 7 },
        },
    },
    vault = {
        dataReady = true,
        retired = false,
        rewardsAvailable = false,
        activities = {
            {
                id = "vault_dungeon_1",
                available = true,
                completed = true,
                metadata = { vaultTypeKey = "dungeon", index = 1, threshold = 1, progress = 1, rewardItemLevel = 315 },
            },
            {
                id = "vault_dungeon_2",
                available = true,
                completed = false,
                metadata = { vaultTypeKey = "dungeon", index = 2, threshold = 4, progress = 1, rewardItemLevel = 305 },
            },
            {
                id = "vault_dungeon_3",
                available = true,
                completed = false,
                metadata = { vaultTypeKey = "dungeon", index = 3, threshold = 8, progress = 1 },
            },
        },
    },
    curatedRoutes = { available = {} },
}

state.progression = NS.Data.Progression:Collect(state)
assert(state.progression.gearRoute.targetLevel == 7, "Item level 300 should target the +7 reward breakpoint.")
assert(state.progression.seasonPhase == "active", "An active Mythic Plus season was not recognized.")
assert(state.progression.gearRoute.endItemLevel == 305, "The +7 end reward is incorrect.")
assert(state.progression.gearRoute.vaultItemLevel == 315, "The +7 Vault reward is incorrect.")
assert(state.progression.bestUpgrade.standardGap == 8, "The standard Mistcrest gap is incorrect.")
assert(state.progression.dungeonVault.missingRuns == 3, "The second Vault option should need three more +7 runs.")

local weekly = NS.Data.Weekly:Collect(state.vault)
assert(weekly.vault.bestRewardItemLevel == 315, "The best earned Vault reward item level was not summarized.")
assert(weekly.reset.resetAt == 200000 and weekly.reset.regionName == "Europe", "Weekly reset state was not normalized.")

local upgradeRecommendation = NS.Recommendation.Rules:UpgradeableEquipment(state)
assert(upgradeRecommendation.id == "upgrade_equipped_1", "The equipped upgrade rule did not select the weakest item.")
assert(upgradeRecommendation.description:match("gap: 8"), "The standard currency gap was not explained.")
assert(#upgradeRecommendation.metadata.steps >= 1, "The equipped upgrade route should include a vendor step.")

local dungeonRecommendation = NS.Recommendation.Rules:LevelingDungeons({
    character = { level = 40, maxLevel = 90 },
    leveling = {
        dungeonFinderAvailable = true,
        availableDungeonCount = 1,
        availableDungeons = { { dungeonID = 99, name = "Test Dungeon" } },
    },
})
assert(dungeonRecommendation.id == "leveling_dungeon_route", "The leveling dungeon rule should remain independent of gear analysis.")

local vaultRecommendations = NS.Recommendation.Rules:GreatVault(state)
assert(#vaultRecommendations == 1, "The optimized dungeon plan should replace the generic dungeon plan.")
assert(vaultRecommendations[1].description:match("3 more dungeons at Mythic %+7"), "The optimized Vault path is not exact.")
assert(vaultRecommendations[1].title:match("315"), "The target Vault item level is missing.")

state.mythicPlus.active = false
state.character.averageItemLevel = 300
state.equipment.items[1].itemLevel = 278
local preseason = NS.Data.Progression:Collect(state)
assert(preseason.seasonPhase == "preseason", "The pre-season state was not recognized.")
assert(preseason.currentRewardCeiling == 298, "Pre-season present-tense guidance must stop at item level 298.")
assert(preseason.futureRewardsPending == true, "Future Season 2 rewards must be marked as pending in pre-season.")
assert(preseason.gearRoute.kind == "mythic_zero", "Pre-season gearing should use the Mythic 0 baseline.")
assert(#preseason.gearRoutes == 2 and preseason.gearRoutes[2].kind == "world_lair",
    "The World Lair route should appear when a known slot is below item level 279.")
assert(preseason.dungeonVault == nil, "Future Mythic Plus Vault rewards leaked into pre-season guidance.")

local preseasonVault = {
    activities = {
        { metadata = { rewardItemLevel = 305 } },
    },
}
NS.Data.GreatVault:ApplyProgressionContext(preseasonVault, preseason)
assert(preseasonVault.activities[1].metadata.futurePreview == true,
    "Pre-season Vault rewards were not marked as next-reset previews.")
assert(preseasonVault.activities[1].metadata.aboveCurrentCeiling == true,
    "A Vault preview above the pre-season ceiling was not identified.")

state.progression = preseason
local preseasonGearRoutes = NS.Recommendation.Rules:FastGearRoute(state)
assert(#preseasonGearRoutes == 2, "Both useful pre-season gear activities should be recommended.")
assert(preseasonGearRoutes[1].title:match("weekly Mythic 0"),
    "Mythic 0 should be the first precise pre-season gearing step.")
local preseasonUpgrade = NS.Recommendation.Rules:UpgradeableEquipment(state)
assert(preseasonUpgrade.metadata.maxItemLevel == 298, "Pre-season item guidance exceeded the current ceiling.")
assert(preseasonUpgrade.metadata.trackMaxItemLevel == 308, "The underlying client track maximum was not retained.")
assert(preseasonUpgrade.description:match("stops at 298"),
    "The pre-season upgrade description did not explain the current guidance ceiling.")
assert(not preseasonUpgrade.description:match("reach 308"),
    "The pre-season upgrade description exposed a future track cap as current guidance.")

state.equipment.classSetDetectionReady = true
state.equipment.classSet = {
    setID = 9001,
    pieces = 2,
    requiredPieces = 4,
    representativeItem = state.equipment.items[1],
}
local tierSet = NS.Recommendation.Rules:TierSet(state)
assert(tierSet and tierSet.importance == NS.Constants.IMPORTANCE.OPTIONAL,
    "Incomplete class-set progress should produce an optional goal.")
assert(tierSet.metadata.target.releaseStatus == "upcoming",
    "Pre-season class-set progress should be labeled as upcoming.")
state.equipment.classSet.pieces = 4
state.progression.seasonPhase = "active"
NS.SeasonConfig.currentTierSetIDs = { [9001] = true }
assert(NS.Recommendation.Rules:TierSet(state) == nil,
    "A completed 4-piece class set should not produce an optional goal.")

print("Progression analysis tests passed.")
