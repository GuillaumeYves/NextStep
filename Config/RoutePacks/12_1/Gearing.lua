local _, NS = ...

local pack = NS.RoutePacks and NS.RoutePacks["12.1"]
if not pack then
    return
end

pack.progression = {
    standardUpgradeCost = 20,
    upgradeTracks = {
        adventurer = {
            currencyID = 3442,
            maxItemLevel = 282,
            sourceKey = "MISTCREST_SOURCE_ADVENTURER",
        },
        veteran = {
            currencyID = 3443,
            maxItemLevel = 295,
            sourceKey = "MISTCREST_SOURCE_VETERAN",
        },
        champion = {
            currencyID = 3444,
            maxItemLevel = 308,
            sourceKey = "MISTCREST_SOURCE_CHAMPION",
        },
        hero = {
            currencyID = 3445,
            maxItemLevel = 321,
            sourceKey = "MISTCREST_SOURCE_HERO",
        },
        myth = {
            currencyID = 3446,
            maxItemLevel = 334,
            sourceKey = "MISTCREST_SOURCE_MYTH",
        },
    },
    mythicPlusRewards = {
        { minLevel = 2, maxLevel = 3, endItemLevel = 295, vaultItemLevel = 305, crest = "champion" },
        { minLevel = 4, maxLevel = 4, endItemLevel = 298, vaultItemLevel = 308, crest = "hero" },
        { minLevel = 5, maxLevel = 5, endItemLevel = 302, vaultItemLevel = 308, crest = "hero" },
        { minLevel = 6, maxLevel = 6, endItemLevel = 305, vaultItemLevel = 311, crest = "hero" },
        { minLevel = 7, maxLevel = 7, endItemLevel = 305, vaultItemLevel = 315, crest = "hero" },
        { minLevel = 8, maxLevel = 8, endItemLevel = 308, vaultItemLevel = 315, crest = "hero" },
        { minLevel = 9, maxLevel = 9, endItemLevel = 308, vaultItemLevel = 315, crest = "myth" },
        { minLevel = 10, maxLevel = 99, endItemLevel = 311, vaultItemLevel = 318, crest = "myth" },
    },
    gearTargets = {
        { averageItemLevelBelow = 295, mythicPlusLevel = 2 },
        { averageItemLevelBelow = 298, mythicPlusLevel = 4 },
        { averageItemLevelBelow = 305, mythicPlusLevel = 7 },
        { mythicPlusLevel = 10 },
    },
    preMythicPlus = {
        mythicZeroItemLevel = 292,
        normalLairItemLevel = 292,
        worldLairItemLevel = 279,
        mythicZeroLockout = "weekly",
        -- Conservative live pre-season ceiling. Review when Season 2 activates.
        currentRewardCeiling = 298,
        ceilingEvidence = "observed_live_preview",
    },
    sourceIDs = {
        "blizzardSeason2Schedule",
        "wowheadMythicPlusSeason2",
        "wowheadGreatVault",
        "wowheadMistcrests",
        "wowheadLairs",
    },
    confidence = "medium",
    evidence = "published_reward_tables_with_conservative_targeting",
}
