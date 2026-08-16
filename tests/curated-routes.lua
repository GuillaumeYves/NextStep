local completedQuests = {}
local mountCollected = false
local petCollected = false
local completedAchievements = {}

local NS = {
    API = {
        WoW = {
            GetInterfaceVersion = function()
                return 120100, true
            end,
            IsQuestCompleted = function(_, questID)
                return completedQuests[questID] == true, true
            end,
            GetMountCollectionInfoByItemID = function(_, itemID)
                return {
                    itemID = itemID,
                    name = "Test Mount",
                    iconFileID = 7777,
                    collected = mountCollected,
                }, true
            end,
            GetItemDisplayInfo = function(_, itemID)
                return {
                    name = "Item " .. itemID,
                    itemLink = "item:" .. itemID,
                    iconFileID = 8888,
                }, true
            end,
            GetPetCollectionInfoByCreatureID = function(_, creatureID)
                return { creatureID = creatureID, collected = petCollected }, true
            end,
            GetAchievementProgress = function(_, achievementID)
                local total = achievementID == 62492 and 8 or 22
                local criteria = {}
                for index = 1, total do
                    criteria[index] = {
                        name = "Criterion " .. index,
                        completed = index <= 3,
                    }
                end
                return {
                    achievementID = achievementID,
                    completed = completedAchievements[achievementID] == true,
                    completedCriteria = 3,
                    totalCriteria = total,
                    criteria = criteria,
                }, true
            end,
        },
    },
    Data = {},
}

local function loadAddonFile(path)
    local chunk, loadError = loadfile(path)
    assert(chunk, loadError)
    chunk("NextStep", NS)
end

loadAddonFile("Config/SeasonConfig.lua")
loadAddonFile("Config/RoutePacks/12_1/Manifest.lua")
loadAddonFile("Config/RoutePacks/12_1/Leveling.lua")
loadAddonFile("Config/RoutePacks/12_1/Gearing.lua")
loadAddonFile("Config/RoutePacks/12_1/Mounts.lua")
loadAddonFile("Config/RoutePacks/12_1/Pets.lua")
loadAddonFile("Localization/Strings.lua")
NS.L = NS.Locales.enUS
loadAddonFile("Recommendation/Scoring.lua")
loadAddonFile("Data/CuratedRoutes.lua")

local pack = NS.RoutePacks["12.1"]
local routeIDs = {}
for _, route in ipairs(pack.routes) do
    assert(type(route.id) == "string" and route.id ~= "", "Every route needs an ID.")
    assert(not routeIDs[route.id], "Route IDs must be unique: " .. route.id)
    routeIDs[route.id] = true
    assert(type(NS.L[route.titleKey]) == "string", "Missing localized route title: " .. tostring(route.titleKey))
    assert(type(NS.L[route.descriptionKey]) == "string", "Missing localized route description: " .. tostring(route.descriptionKey))
    assert(type(NS.L[route.reasonKey]) == "string", "Missing localized route reason: " .. tostring(route.reasonKey))
    assert(type(route.stepKeys) == "table" and #route.stepKeys > 0, "Every route needs ordered steps.")
    assert(type(route.confidence) == "string", "Every route needs a confidence label.")
    assert(type(route.evidence) == "string", "Every route needs an evidence type.")
    assert(type(NS.Recommendation.Scoring.PRIORITY[route.priorityKey]) == "number",
        "Unknown route priority: " .. tostring(route.priorityKey))
    for _, sourceID in ipairs(route.sourceIDs or {}) do
        local source = pack.sources[sourceID]
        assert(source, "Unknown route source: " .. sourceID)
        assert(type(source.url) == "string" and source.url:match("^https://"), "Route sources need HTTPS URLs.")
        assert(type(NS.L[source.titleKey]) == "string", "Missing localized source title: " .. tostring(source.titleKey))
    end
end

local function findRoute(routes, routeID)
    for _, route in ipairs(routes.available) do
        if route.id == routeID then
            return route
        end
    end
    return nil
end

local function collect(level, maxLevel, averageItemLevel, seasonPhase)
    return NS.Data.CuratedRoutes:Collect({
        character = {
            level = level,
            maxLevel = maxLevel,
            averageItemLevel = averageItemLevel,
        },
        progression = { seasonPhase = seasonPhase or "preseason" },
    })
end

local routes, ready = collect(42, 90, 80)
assert(ready == true, "The active route pack should load.")
assert(#routes.available == 1, "A level 42 character should receive one core leveling route.")
assert(routes.available[1].id == "12_1_leveling_dragonflight", "The Dragonflight route was not selected.")
assert(routes.available[1].metadata.patch == "12.1.0", "Patch provenance was not normalized.")
assert(#routes.available[1].metadata.steps == 2, "Ordered route steps were not preserved.")

NS.API.WoW.GetInterfaceVersion = function()
    return 120200, true
end
routes, ready = collect(42, 90, 80)
assert(ready == false and #routes.available == 0, "A stale route pack should be suppressed.")
assert(routes.unavailableReason == "interface_mismatch", "A stale pack should expose its failure reason.")
NS.API.WoW.GetInterfaceVersion = function()
    return 120100, true
end

completedQuests[95008] = false
routes = collect(85, 90, 240)
assert(findRoute(routes, "12_1_leveling_midnight_campaign"), "The first-character Midnight route was not selected.")
assert(not findRoute(routes, "12_1_leveling_midnight_alt"), "The alt route fired without its unlock quest.")

completedQuests[95008] = true
routes = collect(85, 90, 240)
assert(findRoute(routes, "12_1_leveling_midnight_alt"), "The Midnight alt route was not selected.")
assert(not findRoute(routes, "12_1_leveling_midnight_campaign"), "The first-character route fired for an unlocked alt.")

completedQuests[95008] = false
routes = collect(90, 90, 280)
assert(findRoute(routes, "12_1_mount_dusk_grimlynx"), "The uncollected mount route was not selected.")
assert(findRoute(routes, "12_1_mount_dusk_grimlynx").metadata.target.iconFileID == 7777,
    "The mount target icon was not normalized.")
assert(findRoute(routes, "12_1_mount_dusk_grimlynx").metadata.target.acquisition == "guaranteed",
    "The documented acquisition type was not normalized.")
assert(findRoute(routes, "12_1_pet_akiki"), "The uncollected pet route was not selected.")
assert(findRoute(routes, "12_1_pet_akiki").metadata.target.speciesID == 5007,
    "Akiki's collection preview species ID was not normalized.")
assert(findRoute(routes, "12_1_mount_delvers_arcane_golem"), "The fixed treasure mount route was not selected.")
local treasureRoute = findRoute(routes, "12_1_mount_auriferous_venomfang")
assert(treasureRoute, "The achievement mount route was not selected.")
assert(treasureRoute.metadata.progress.current == 3 and treasureRoute.metadata.progress.total == 22,
    "Achievement progress was not attached to the route.")
assert(#treasureRoute.metadata.missingCriteria == 19, "Incomplete achievement criteria were not attached.")
assert(findRoute(routes, "12_1_pet_coiled_isle_safari"), "The Safari pet route was not selected.")
assert(findRoute(routes, "12_1_pet_coiled_isle_safari").metadata.target.speciesID == 5132,
    "Zesty's collection preview species ID was not normalized.")
assert(not findRoute(routes, "12_1_mount_writhing_brood"), "The seasonal chance route fired during pre-season.")
routes = collect(90, 90, 280, "active")
assert(findRoute(routes, "12_1_mount_writhing_brood"), "The seasonal chance route did not fire in season.")
assert(findRoute(routes, "12_1_mount_writhing_brood").metadata.target.dropRateKnown == false,
    "An unpublished chance reward must not invent a drop rate.")
completedAchievements[63359] = true
routes = collect(90, 90, 280, "active")
assert(not findRoute(routes, "12_1_mount_auriferous_venomfang"),
    "The completed achievement mount route remained visible.")
completedAchievements[63359] = false
local mountRoute = findRoute(routes, "12_1_mount_dusk_grimlynx")
assert(mountRoute.metadata.sources[1].url:match("wowhead%.com"), "Route source URLs were not preserved.")

assert(type(pack.progression) == "table", "The progression meta table is missing.")
assert(#pack.progression.mythicPlusRewards == 8, "The Season 2 Mythic Plus reward bands are incomplete.")
for _, sourceID in ipairs(pack.progression.sourceIDs) do
    assert(pack.sources[sourceID], "Unknown progression source: " .. sourceID)
end

mountCollected = true
petCollected = true
routes = collect(90, 90, 300)
assert(#routes.available == 0, "Completed collection routes or an inapplicable gear route remained visible.")

print("Curated route pack tests passed.")
