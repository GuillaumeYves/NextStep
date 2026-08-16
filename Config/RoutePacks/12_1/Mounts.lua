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
        itemID = 246731,
        questID = 92899,
        startQuestID = 92895,
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
    metadata = { itemID = 262496, x = 60.43, y = 68.11, featured = true },
}

pack.routes[#pack.routes + 1] = {
    id = "12_1_mount_auriferous_venomfang",
    goal = "mounts",
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
    metadata = { itemID = 276804, chanceBased = true, featured = true },
}
