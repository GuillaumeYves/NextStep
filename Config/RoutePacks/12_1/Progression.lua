local _, NS = ...

local pack = NS.RoutePacks and NS.RoutePacks["12.1"]
if not pack then
    return
end

local routes = pack.routes

pack.characterMilestones = {
    {
        id = "legacy_history_lesson",
        titleKey = "PATCH_PROGRESS_MILESTONE_HISTORY_LESSON",
        questID = 92899,
    },
    {
        id = "legacy_dead_end",
        titleKey = "PATCH_PROGRESS_MILESTONE_DEAD_END",
        questID = 93012,
    },
}

routes[#routes + 1] = {
    id = "12_1_campaign_legacy_of_the_amani",
    goal = "progression",
    category = "progression",
    priorityKey = "CURATED_PATCH_CAMPAIGN",
    importance = "HIGH",
    titleKey = "ROUTE_PATCH_CAMPAIGN_TITLE",
    descriptionKey = "ROUTE_PATCH_CAMPAIGN_DESCRIPTION",
    reasonKey = "ROUTE_PATCH_CAMPAIGN_REASON",
    stepKeys = {
        "ROUTE_PATCH_CAMPAIGN_STEP_1",
        "ROUTE_PATCH_CAMPAIGN_STEP_2",
        "ROUTE_PATCH_CAMPAIGN_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        questIncomplete = { 93012 },
    },
    sourceIDs = {
        "blizzardPatchOverview",
        "wowheadAmaniCampaignRewards",
        "wowheadHagarsInvitation",
        "wowheadDeadEnd",
    },
    confidence = "high",
    evidence = "quest_chain",
    metadata = {
        family = "campaign",
        startQuestID = 92895,
        completionQuestID = 93012,
        featured = true,
    },
}

routes[#routes + 1] = {
    id = "12_1_outdoor_vaults_of_atal_utek",
    goal = "progression",
    category = "progression",
    priorityKey = "CURATED_PATCH_OUTDOOR",
    importance = "USEFUL",
    titleKey = "ROUTE_PATCH_VAULTS_TITLE",
    descriptionKey = "ROUTE_PATCH_VAULTS_DESCRIPTION",
    reasonKey = "ROUTE_PATCH_VAULTS_REASON",
    stepKeys = {
        "ROUTE_PATCH_VAULTS_STEP_1",
        "ROUTE_PATCH_VAULTS_STEP_2",
        "ROUTE_PATCH_VAULTS_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        questComplete = { 93012 },
    },
    sourceIDs = { "blizzardPatchOverview" },
    confidence = "high",
    evidence = "official_activity_route",
    metadata = {
        family = "delve_outdoor",
        activity = "vaults_of_atal_utek",
        featured = true,
    },
}

routes[#routes + 1] = {
    id = "12_1_outdoor_tokka_reputation",
    goal = "progression",
    category = "progression",
    priorityKey = "CURATED_PATCH_REPUTATION",
    importance = "USEFUL",
    titleKey = "ROUTE_PATCH_TOKKA_TITLE",
    descriptionKey = "ROUTE_PATCH_TOKKA_DESCRIPTION",
    reasonKey = "ROUTE_PATCH_TOKKA_REASON",
    stepKeys = {
        "ROUTE_PATCH_TOKKA_STEP_1",
        "ROUTE_PATCH_TOKKA_STEP_2",
        "ROUTE_PATCH_TOKKA_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        questComplete = { 93012 },
    },
    sourceIDs = { "blizzardPatchOverview" },
    confidence = "high",
    evidence = "official_activity_route",
    metadata = {
        family = "delve_outdoor",
        activity = "tokka_reputation",
        featured = true,
    },
}

routes[#routes + 1] = {
    id = "12_1_outdoor_coiled_isle",
    goal = "progression",
    category = "progression",
    priorityKey = "CURATED_PATCH_STORY",
    importance = "USEFUL",
    titleKey = "ROUTE_PATCH_OUTDOOR_TITLE",
    descriptionKey = "ROUTE_PATCH_OUTDOOR_DESCRIPTION",
    reasonKey = "ROUTE_PATCH_OUTDOOR_REASON",
    stepKeys = {
        "ROUTE_PATCH_OUTDOOR_STEP_1",
        "ROUTE_PATCH_OUTDOOR_STEP_2",
        "ROUTE_PATCH_OUTDOOR_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        questComplete = { 93012 },
    },
    sourceIDs = { "blizzardPatchOverview" },
    confidence = "high",
    evidence = "official_activity_route",
    metadata = {
        family = "delve_outdoor",
        activity = "coiled_isle",
        featured = true,
    },
}

routes[#routes + 1] = {
    id = "12_1_delves_season_2",
    goal = "progression",
    category = "progression",
    priorityKey = "CURATED_PATCH_DELVE",
    importance = "HIGH",
    titleKey = "ROUTE_PATCH_DELVE_TITLE",
    descriptionKey = "ROUTE_PATCH_DELVE_DESCRIPTION",
    reasonKey = "ROUTE_PATCH_DELVE_REASON",
    stepKeys = {
        "ROUTE_PATCH_DELVE_STEP_1",
        "ROUTE_PATCH_DELVE_STEP_2",
        "ROUTE_PATCH_DELVE_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
    },
    sourceIDs = {
        "blizzardPatchOverview",
        "blizzardSeason2Schedule",
        "blizzardJourneys",
    },
    confidence = "high",
    evidence = "official_activity_route",
    metadata = {
        family = "delve_outdoor",
        activity = "bountiful_delve",
        featured = true,
    },
}

routes[#routes + 1] = {
    id = "12_1_raid_venomous_abyss",
    goal = "gear",
    category = "gear",
    priorityKey = "CURATED_PATCH_RAID",
    importance = "HIGH",
    titleKey = "ROUTE_PATCH_RAID_TITLE",
    descriptionKey = "ROUTE_PATCH_RAID_DESCRIPTION",
    reasonKey = "ROUTE_PATCH_RAID_REASON",
    stepKeys = {
        "ROUTE_PATCH_RAID_STEP_1",
        "ROUTE_PATCH_RAID_STEP_2",
        "ROUTE_PATCH_RAID_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
    },
    sourceIDs = {
        "blizzardSeason2Schedule",
        "blizzardVenomousAbyss",
        "wowheadGreatVault",
    },
    confidence = "high",
    evidence = "published_release_schedule",
    metadata = {
        family = "raid",
        activity = "venomous_abyss",
        featured = true,
    },
}

routes[#routes + 1] = {
    id = "12_1_outdoor_prey_season_2",
    goal = "progression",
    category = "progression",
    priorityKey = "CURATED_PATCH_OUTDOOR",
    importance = "HIGH",
    titleKey = "ROUTE_PATCH_PREY_TITLE",
    descriptionKey = "ROUTE_PATCH_PREY_DESCRIPTION",
    reasonKey = "ROUTE_PATCH_PREY_REASON",
    stepKeys = {
        "ROUTE_PATCH_PREY_STEP_1",
        "ROUTE_PATCH_PREY_STEP_2",
        "ROUTE_PATCH_PREY_STEP_3",
    },
    requirements = {
        atMaxLevel = true,
        seasonPhase = "active",
        questIncomplete = { 96004 },
    },
    sourceIDs = { "blizzardSeason2Schedule" },
    confidence = "high",
    evidence = "official_activity_route",
    metadata = {
        family = "delve_outdoor",
        activity = "prey_season_2",
        startQuestID = 96004,
        featured = true,
    },
}
