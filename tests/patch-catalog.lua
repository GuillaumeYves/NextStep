local NS = {
    API = { WoW = {} },
    Data = {},
    Constants = {
        GOAL = {
            MOUNTS = "mounts",
            PETS = "pets",
            ACHIEVEMENTS = "achievements",
        },
    },
    SeasonConfig = { routePack = "12.1" },
    L = setmetatable({}, { __index = function(_, key) return key end }),
}

function NS.API.WoW:GetInterfaceVersion()
    return 120100, true
end

function NS.API.WoW:GetMountCollectionInfoBySpellID(spellID)
    return {
        mountID = spellID + 1,
        spellID = spellID,
        name = "Mount " .. spellID,
        iconFileID = 1,
        sourceText = "Mount source",
        collected = spellID == 1261369,
    }, true
end

function NS.API.WoW:GetPetSpeciesInfo(speciesID)
    return {
        speciesID = speciesID,
        name = "Pet " .. speciesID,
        iconFileID = 2,
        sourceText = "Pet source",
        obtainable = true,
        collected = speciesID == 5119,
    }, true
end

function NS.API.WoW:GetAchievementProgress(achievementID)
    return {
        achievementID = achievementID,
        name = "Achievement " .. achievementID,
        description = "Achievement requirement",
        iconFileID = 3,
        completed = achievementID == 63359,
        completedCriteria = 0,
        totalCriteria = 1,
        criteria = { { name = "Do the exact requirement", completed = false } },
    }, true
end

local function loadAddonFile(path)
    local chunk, loadError = loadfile(path)
    assert(chunk, loadError)
    chunk("NextStep", NS)
end

loadAddonFile("Config/RoutePacks/12_1/Manifest.lua")
loadAddonFile("Config/RoutePacks/12_1/Catalog.lua")
loadAddonFile("Data/PatchCatalog.lua")

local state = { progression = { seasonPhase = "preseason" } }
local catalog, ready = NS.Data.PatchCatalog:Collect(state)
assert(ready == true and catalog.dataReady == true, "Patch catalog should be ready.")
assert(#catalog.entries > 200, "The public 12.1 catalog should include all supported collections.")

local foundUpcoming
for _, entry in ipairs(catalog.entries) do
    assert(entry.name and entry.target and entry.iconFileID, "Catalog entries must be renderable.")
    assert(entry.id ~= "12_1_catalog_mount_1261369", "Collected mounts must be omitted.")
    assert(entry.id ~= "12_1_catalog_pet_5119", "Collected pets must be omitted.")
    assert(entry.id ~= "12_1_catalog_achievement_63359", "Completed achievements must be omitted.")
    if entry.id == "12_1_catalog_mount_1301070" then
        foundUpcoming = entry.releaseStatus == "upcoming"
    end
end
assert(foundUpcoming, "Season-gated collection entries should be marked upcoming in pre-season.")

print("Patch collection catalog tests passed.")
