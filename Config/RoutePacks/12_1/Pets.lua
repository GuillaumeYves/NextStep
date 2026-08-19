local _, NS = ...

local pack = NS.RoutePacks and NS.RoutePacks["12.1"]
if not pack then
    return
end

pack.routes[#pack.routes + 1] = {
    id = "12_1_pet_akiki",
    goal = "pets",
    category = "collection",
    priorityKey = "CURATED_COLLECTION_GUARANTEED",
    importance = "USEFUL",
    titleKey = "ROUTE_PET_AKIKI_TITLE",
    descriptionKey = "ROUTE_PET_AKIKI_DESCRIPTION",
    reasonKey = "ROUTE_PET_AKIKI_REASON",
    stepKeys = {
        "ROUTE_AMANI_STEP_1",
        "ROUTE_PET_AKIKI_STEP_2",
    },
    requirements = {
        atMaxLevel = true,
        petCreatureNotCollected = { 260149 },
        questIncomplete = { 93012 },
    },
    sourceIDs = {
        "wowheadAmaniCampaignRewards",
        "wowheadAkiki",
        "wowheadDeadEnd",
        "wowheadHagarsInvitation",
    },
    confidence = "high",
    evidence = "quest_reward",
    metadata = {
        family = "collection_guaranteed",
        creatureID = 260149,
        speciesID = 5007,
        questID = 93012,
        startQuestID = 92895,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_pet_preyhunters_prismguard",
    goal = "pets",
    category = "collection",
    priorityKey = "CURATED_COLLECTION_GUARANTEED",
    importance = "USEFUL",
    titleKey = "ROUTE_PET_PREYHUNTER_PRISMGUARD_TITLE",
    descriptionKey = "ROUTE_PET_PREYHUNTER_PRISMGUARD_DESCRIPTION",
    reasonKey = "ROUTE_PET_PREYHUNTER_PRISMGUARD_REASON",
    stepKeys = {
        "ROUTE_PREY_TRACK_STEP_1",
        "ROUTE_PET_PREYHUNTER_PRISMGUARD_STEP_2",
        "ROUTE_PREY_TRACK_VENDOR_STEP",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
        petCreatureNotCollected = { 266833 },
    },
    sourceIDs = { "blizzardSeason2Schedule", "wowheadPreyhunterPrismguard" },
    confidence = "high",
    evidence = "season_track_reward",
    metadata = {
        family = "collection_guaranteed",
        creatureID = 266833,
        speciesID = 5076,
        questID = 96004,
        trackLevel = 8,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_pet_ulatook",
    goal = "pets",
    goals = { "pets", "achievements" },
    category = "collection",
    priorityKey = "CURATED_COLLECTION_ACHIEVEMENT",
    importance = "HIGH",
    titleKey = "ROUTE_PET_ULATOOK_TITLE",
    descriptionKey = "ROUTE_PET_ULATOOK_DESCRIPTION",
    reasonKey = "ROUTE_PET_ULATOOK_REASON",
    stepKeys = {
        "ROUTE_PET_ULATOOK_STEP_1",
        "ROUTE_PET_ULATOOK_STEP_2",
        "ROUTE_PET_ULATOOK_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
        petCreatureNotCollected = { 270425 },
        achievementIncomplete = { 63609 },
    },
    sourceIDs = {
        "blizzardVenomousAbyss",
        "wowheadNoEggScramble",
        "wowheadUlatook",
    },
    confidence = "high",
    evidence = "achievement_reward",
    metadata = {
        family = "collection_achievement",
        creatureID = 270425,
        speciesID = 5130,
        achievementID = 63609,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_pet_coiled_isle_safari",
    goal = "pets",
    goals = { "pets", "achievements" },
    category = "collection",
    priorityKey = "CURATED_COLLECTION_ACHIEVEMENT",
    importance = "USEFUL",
    titleKey = "ROUTE_PET_COILED_SAFARI_TITLE",
    descriptionKey = "ROUTE_PET_COILED_SAFARI_DESCRIPTION",
    reasonKey = "ROUTE_PET_COILED_SAFARI_REASON",
    stepKeys = {
        "ROUTE_PET_COILED_SAFARI_STEP_1",
        "ROUTE_PET_COILED_SAFARI_STEP_2",
    },
    requirements = {
        atMaxLevel = true,
        achievementIncomplete = { 62492 },
        anyPetCreatureNotCollected = {
            262222,
            262226,
            262243,
            262244,
            262245,
            262246,
            262247,
            262248,
        },
    },
    sourceIDs = { "wowheadCoiledIsleSafari", "icyVeinsCoiledIsle" },
    confidence = "high",
    evidence = "achievement_reward",
    metadata = {
        family = "collection_achievement",
        achievementID = 62492,
        rewardPetName = "Zesty",
        speciesID = 5132,
        featured = true,
    },
}
