local _, NS = ...

local pack = NS.RoutePacks and NS.RoutePacks["12.1"]
if not pack then
    return
end

local routes = pack.routes

routes[#routes + 1] = {
    id = "12_1_leveling_exiles_reach",
    goal = "experience",
    category = "leveling",
    priorityKey = "CURATED_LEVELING_ROUTE",
    importance = "HIGH",
    titleKey = "ROUTE_LEVELING_EXILES_TITLE",
    descriptionKey = "ROUTE_LEVELING_EXILES_DESCRIPTION",
    reasonKey = "ROUTE_LEVELING_EXILES_REASON",
    stepKeys = {
        "ROUTE_LEVELING_EXILES_STEP_1",
        "ROUTE_LEVELING_EXILES_STEP_2",
    },
    requirements = { minLevel = 1, maxLevel = 9 },
    sourceIDs = { "blizzardStarterGuide" },
    confidence = "high",
    evidence = "official_path",
}

routes[#routes + 1] = {
    id = "12_1_leveling_dragonflight",
    goal = "experience",
    category = "leveling",
    priorityKey = "CURATED_LEVELING_ROUTE",
    importance = "HIGH",
    titleKey = "ROUTE_LEVELING_DRAGONFLIGHT_TITLE",
    descriptionKey = "ROUTE_LEVELING_DRAGONFLIGHT_DESCRIPTION",
    reasonKey = "ROUTE_LEVELING_DRAGONFLIGHT_REASON",
    stepKeys = {
        "ROUTE_LEVELING_DRAGONFLIGHT_STEP_1",
        "ROUTE_LEVELING_DRAGONFLIGHT_STEP_2",
    },
    requirements = { minLevel = 10, maxLevel = 69 },
    sourceIDs = { "blizzardStarterGuide" },
    confidence = "high",
    evidence = "official_path",
}

routes[#routes + 1] = {
    id = "12_1_leveling_war_within",
    goal = "experience",
    category = "leveling",
    priorityKey = "CURATED_LEVELING_ROUTE",
    importance = "HIGH",
    titleKey = "ROUTE_LEVELING_WAR_WITHIN_TITLE",
    descriptionKey = "ROUTE_LEVELING_WAR_WITHIN_DESCRIPTION",
    reasonKey = "ROUTE_LEVELING_WAR_WITHIN_REASON",
    stepKeys = {
        "ROUTE_LEVELING_WAR_WITHIN_STEP_1",
        "ROUTE_LEVELING_WAR_WITHIN_STEP_2",
    },
    requirements = { minLevel = 70, maxLevel = 79 },
    sourceIDs = { "blizzardStarterGuide" },
    confidence = "high",
    evidence = "official_path",
}

routes[#routes + 1] = {
    id = "12_1_leveling_midnight_campaign",
    goal = "experience",
    category = "leveling",
    priorityKey = "CURATED_LEVELING_ROUTE",
    importance = "HIGH",
    titleKey = "ROUTE_LEVELING_MIDNIGHT_TITLE",
    descriptionKey = "ROUTE_LEVELING_MIDNIGHT_DESCRIPTION",
    reasonKey = "ROUTE_LEVELING_MIDNIGHT_REASON",
    stepKeys = {
        "ROUTE_LEVELING_MIDNIGHT_STEP_1",
        "ROUTE_LEVELING_MIDNIGHT_STEP_2",
    },
    requirements = {
        minLevel = 80,
        belowMaxLevel = true,
        questIncomplete = { 95008 },
    },
    sourceIDs = { "blizzardStarterGuide" },
    confidence = "high",
    evidence = "official_path",
}

routes[#routes + 1] = {
    id = "12_1_leveling_midnight_alt",
    goal = "experience",
    category = "leveling",
    priorityKey = "CURATED_LEVELING_ROUTE",
    importance = "HIGH",
    titleKey = "ROUTE_LEVELING_ALT_TITLE",
    descriptionKey = "ROUTE_LEVELING_ALT_DESCRIPTION",
    reasonKey = "ROUTE_LEVELING_ALT_REASON",
    stepKeys = {
        "ROUTE_LEVELING_ALT_STEP_1",
        "ROUTE_LEVELING_ALT_STEP_2",
        "ROUTE_LEVELING_ALT_STEP_3",
    },
    requirements = {
        minLevel = 80,
        belowMaxLevel = true,
        questComplete = { 95008 },
    },
    sourceIDs = {
        "wowheadMidnightAltLeveling",
        "wowheadMidnightAdventureUnlock",
        "blizzardQuestExperience",
    },
    confidence = "medium",
    evidence = "community_optimized",
}
