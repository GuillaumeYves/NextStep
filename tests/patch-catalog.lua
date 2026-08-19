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
        mountLink = "mount:" .. spellID,
        collected = spellID == 1261369,
    }, true
end

local itemDisplayCalls = 0
function NS.API.WoW:GetItemDisplayInfo(itemID)
    itemDisplayCalls = itemDisplayCalls + 1
    return {
        itemID = itemID,
        itemLink = "item:" .. itemID,
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
        achievementLink = "achievement:" .. achievementID,
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

local packCatalog = NS.RoutePacks["12.1"].catalog
local mountsWithoutRewardItems = {}
for _, spellID in ipairs(packCatalog.mounts) do
    if not packCatalog.mountItems[spellID] then
        mountsWithoutRewardItems[#mountsWithoutRewardItems + 1] = spellID
    end
end
assert(#mountsWithoutRewardItems == 2
    and mountsWithoutRewardItems[1] == 1261369
    and mountsWithoutRewardItems[2] == 1295958,
    "Every item-backed catalog mount should have a verified reward item mapping.")

local state = { progression = { seasonPhase = "preseason" } }
local catalog, ready = NS.Data.PatchCatalog:Collect(state)
assert(ready == true and catalog.dataReady == true, "Patch catalog should be ready.")
local callsAfterInitialScan = itemDisplayCalls
NS.Data.PatchCatalog:Collect(state, "CURRENCY_DISPLAY_UPDATE")
assert(itemDisplayCalls == callsAfterInitialScan,
    "Unrelated refreshes should reuse cached collection target data.")
NS.Data.PatchCatalog:Collect(state, "GET_ITEM_INFO_RECEIVED")
assert(itemDisplayCalls > callsAfterInitialScan,
    "Loaded item data should refresh catalog reward links.")
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
assert(catalog.completion.account.current == 3,
    "Collected mounts, pets, and achievements should contribute to account progress.")
assert(catalog.completion.account.total == 249,
    "Account progress should use every known, obtainable 12.1 catalog entry.")
for _, entry in ipairs(catalog.entries) do
    if entry.id == "12_1_catalog_mount_1296734" then
        assert(entry.target.itemID == 275442 and entry.target.itemLink == "item:275442",
            "Mount catalog targets should preserve their reward item tooltip.")
        assert(entry.target.mountLink == "mount:1296734",
            "Mount catalog targets should retain the Mount Journal fallback.")
    end
    if entry.kind == "achievement" then
        assert(entry.target.achievementLink == "achievement:" .. entry.achievementID,
            "Achievement targets should preserve their native tooltip link.")
    end
end

print("Patch collection catalog tests passed.")
