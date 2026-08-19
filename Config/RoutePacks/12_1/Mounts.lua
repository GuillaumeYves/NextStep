local _, NS = ...

local pack = NS.RoutePacks and NS.RoutePacks["12.1"]
if not pack then
    return
end

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_dusk_grimlynx",
    goal = "mounts",
    category = "collection",
    priorityKey = "CURATED_COLLECTION_GUARANTEED",
    importance = "USEFUL",
    titleKey = "ROUTE_MOUNT_GRIMLYNX_TITLE",
    descriptionKey = "ROUTE_MOUNT_GRIMLYNX_DESCRIPTION",
    reasonKey = "ROUTE_MOUNT_GRIMLYNX_REASON",
    stepKeys = {
        "ROUTE_AMANI_STEP_1",
        "ROUTE_MOUNT_GRIMLYNX_STEP_2",
    },
    requirements = {
        atMaxLevel = true,
        mountItemNotCollected = { 246731 },
        questIncomplete = { 92899 },
    },
    sourceIDs = {
        "wowheadAmaniCampaignRewards",
        "wowheadDuskGrimlynx",
        "wowheadHistoryLesson",
        "wowheadHagarsInvitation",
    },
    confidence = "high",
    evidence = "quest_reward",
    metadata = {
        family = "collection_guaranteed",
        itemID = 246731,
        questID = 92899,
        startQuestID = 92895,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_preyhunters_fury",
    goal = "mounts",
    category = "collection",
    priorityKey = "CURATED_COLLECTION_GUARANTEED",
    importance = "HIGH",
    titleKey = "ROUTE_MOUNT_PREYHUNTER_FURY_TITLE",
    descriptionKey = "ROUTE_MOUNT_PREYHUNTER_FURY_DESCRIPTION",
    reasonKey = "ROUTE_MOUNT_PREYHUNTER_FURY_REASON",
    stepKeys = {
        "ROUTE_PREY_TRACK_STEP_1",
        "ROUTE_MOUNT_PREYHUNTER_FURY_STEP_2",
        "ROUTE_PREY_TRACK_VENDOR_STEP",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
        mountItemNotCollected = { 275660 },
    },
    sourceIDs = { "blizzardSeason2Schedule", "wowheadPreyhunterFury" },
    confidence = "high",
    evidence = "season_track_reward",
    metadata = {
        family = "collection_guaranteed",
        itemID = 275660,
        questID = 96004,
        trackLevel = 10,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_breath_of_ruin",
    goal = "mounts",
    goals = { "mounts", "achievements" },
    category = "collection",
    priorityKey = "CURATED_COLLECTION_ACHIEVEMENT",
    importance = "HIGH",
    titleKey = "ROUTE_MOUNT_BREATH_OF_RUIN_TITLE",
    descriptionKey = "ROUTE_MOUNT_BREATH_OF_RUIN_DESCRIPTION",
    reasonKey = "ROUTE_MOUNT_BREATH_OF_RUIN_REASON",
    stepKeys = {
        "ROUTE_MOUNT_BREATH_OF_RUIN_STEP_1",
        "ROUTE_MOUNT_BREATH_OF_RUIN_STEP_2",
        "ROUTE_MOUNT_BREATH_OF_RUIN_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
        mountItemNotCollected = { 276882 },
        achievementIncomplete = { 62449 },
    },
    sourceIDs = {
        "blizzardSeason2Schedule",
        "wowheadKeystoneLegendSeason2",
        "wowheadBreathOfRuin",
    },
    confidence = "high",
    evidence = "achievement_reward",
    metadata = {
        family = "collection_achievement",
        itemID = 276882,
        achievementID = 62449,
        ratingTarget = 3000,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_primeval_skyfriend",
    goal = "mounts",
    category = "collection",
    priorityKey = "CURATED_COLLECTION_CHANCE",
    importance = "OPTIONAL",
    titleKey = "ROUTE_MOUNT_PRIMEVAL_SKYFRIEND_TITLE",
    descriptionKey = "ROUTE_MOUNT_PRIMEVAL_SKYFRIEND_DESCRIPTION",
    reasonKey = "ROUTE_MOUNT_PRIMEVAL_SKYFRIEND_REASON",
    stepKeys = {
        "ROUTE_MOUNT_PRIMEVAL_SKYFRIEND_STEP_1",
        "ROUTE_MOUNT_PRIMEVAL_SKYFRIEND_STEP_2",
        "ROUTE_MOUNT_PRIMEVAL_SKYFRIEND_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
        mountItemNotCollected = { 275658 },
    },
    sourceIDs = {
        "blizzardSeason2Schedule",
        "blizzardVenomousAbyss",
        "wowheadPrimevalSkyfriend",
    },
    confidence = "high",
    evidence = "chance_drop",
    metadata = {
        family = "collection_chance",
        itemID = 275658,
        chanceBased = true,
        difficulty = "mythic",
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_delvers_arcane_golem",
    goal = "mounts",
    category = "collection",
    priorityKey = "CURATED_COLLECTION_GUARANTEED",
    importance = "HIGH",
    titleKey = "ROUTE_MOUNT_ARCANE_GOLEM_TITLE",
    descriptionKey = "ROUTE_MOUNT_ARCANE_GOLEM_DESCRIPTION",
    reasonKey = "ROUTE_MOUNT_ARCANE_GOLEM_REASON",
    stepKeys = {
        "ROUTE_MOUNT_ARCANE_GOLEM_STEP_1",
        "ROUTE_MOUNT_ARCANE_GOLEM_STEP_2",
    },
    requirements = {
        atMaxLevel = true,
        mountItemNotCollected = { 262496 },
    },
    sourceIDs = { "icyVeinsGnarldor", "wowheadArcaneGolem" },
    confidence = "high",
    evidence = "fixed_treasure",
    metadata = {
        family = "collection_guaranteed",
        itemID = 262496,
        x = 60.43,
        y = 68.11,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_auriferous_venomfang",
    goal = "mounts",
    goals = { "mounts", "achievements" },
    category = "collection",
    priorityKey = "CURATED_COLLECTION_ACHIEVEMENT",
    importance = "USEFUL",
    titleKey = "ROUTE_MOUNT_AURIFEROUS_TITLE",
    descriptionKey = "ROUTE_MOUNT_AURIFEROUS_DESCRIPTION",
    reasonKey = "ROUTE_MOUNT_AURIFEROUS_REASON",
    stepKeys = {
        "ROUTE_MOUNT_AURIFEROUS_STEP_1",
        "ROUTE_MOUNT_AURIFEROUS_STEP_2",
    },
    requirements = {
        atMaxLevel = true,
        mountItemNotCollected = { 275656 },
        achievementIncomplete = { 63359 },
    },
    sourceIDs = { "icyVeinsCoiledIsle", "wowheadAuriferousVenomfang" },
    confidence = "high",
    evidence = "achievement_reward",
    metadata = {
        family = "collection_achievement",
        itemID = 275656,
        achievementID = 63359,
        treasureCount = 22,
        featured = true,
    },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_writhing_brood",
    goal = "mounts",
    category = "collection",
    priorityKey = "CURATED_COLLECTION_CHANCE",
    importance = "OPTIONAL",
    titleKey = "ROUTE_MOUNT_WRITHING_BROOD_TITLE",
    descriptionKey = "ROUTE_MOUNT_WRITHING_BROOD_DESCRIPTION",
    reasonKey = "ROUTE_MOUNT_WRITHING_BROOD_REASON",
    stepKeys = {
        "ROUTE_MOUNT_WRITHING_BROOD_STEP_1",
        "ROUTE_MOUNT_WRITHING_BROOD_STEP_2",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
        mountItemNotCollected = { 276804 },
    },
    sourceIDs = { "wowheadWrithingBrood", "wowheadAltarOfFangs" },
    confidence = "high",
    evidence = "chance_drop",
    metadata = {
        family = "collection_chance",
        itemID = 276804,
        chanceBased = true,
        featured = true,
    },
}
