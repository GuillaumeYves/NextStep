local NS = {
    modules = {},
    L = {
        FALLBACK = "fallback",
        FALLBACK_SELECTED_GOALS = "selected goals fallback",
    },
}

function NS:RegisterModule(name, module)
    self.modules[name] = module
    self[name] = module
    return module
end

local function loadModule(path)
    local chunk, loadError = loadfile(path)
    assert(chunk, loadError)
    chunk("NextStep", NS)
end

loadModule("Core/Constants.lua")
loadModule("Util/Table.lua")
loadModule("Util/Formatting.lua")
loadModule("Core/Config.lua")
loadModule("Planner/Planner.lua")

_G.NextStepDB = {
    schemaVersion = 1,
    settings = {},
    characters = {
        ["Veteran-Realm"] = { lastSeen = 123 },
    },
}

NS.Config:InitializeDatabase()
assert(NS.db.schemaVersion == 2, "Database schema did not migrate.")

local maxLevelCharacter = {
    name = "Veteran",
    realm = "Realm",
    level = 90,
    maxLevel = 90,
}
local profile = NS.Config:GetCharacterProfile(maxLevelCharacter, true)
assert(profile.lastSeen == 123, "Existing character state was not preserved.")
assert(profile.goals.experience == false, "Max-level default should not prioritize experience.")
assert(profile.goals.gear == true, "Gear should remain a default goal.")

profile.goals.gear = false
profile.goals.mounts = true

local recommendations = {
    {
        id = "experience",
        priority = 90,
        importance = NS.Constants.IMPORTANCE.HIGH,
        status = NS.Constants.STATUS.AVAILABLE,
        goals = { NS.Constants.GOAL.EXPERIENCE },
    },
    {
        id = "gear",
        priority = 80,
        importance = NS.Constants.IMPORTANCE.HIGH,
        status = NS.Constants.STATUS.AVAILABLE,
        goals = { NS.Constants.GOAL.GEAR },
    },
    {
        id = "critical_reward",
        priority = 100,
        importance = NS.Constants.IMPORTANCE.CRITICAL,
        status = NS.Constants.STATUS.AVAILABLE,
        goals = { NS.Constants.GOAL.GEAR },
    },
}

local plan = NS.Planner:Build({ character = maxLevelCharacter }, recommendations)
assert(#plan.recommendations == 1, "Goal filtering returned an unexpected recommendation count.")
assert(plan.recommendations[1].id == "critical_reward", "Critical recommendations must remain visible.")

local filteredPlan = NS.Planner:Build({ character = maxLevelCharacter }, { recommendations[1] })
assert(filteredPlan.isFallback == true, "An unmatched goal should produce a fallback plan.")
assert(filteredPlan.fallbackMessage == NS.L.FALLBACK_SELECTED_GOALS, "Goal fallback message was not selected.")

local levelingProfile = NS.Config:GetCharacterProfile({
    name = "Rookie",
    realm = "Realm",
    level = 20,
    maxLevel = 90,
}, true)
assert(levelingProfile.goals.experience == true, "Leveling characters should prioritize experience by default.")

print("Preference and migration tests passed.")
