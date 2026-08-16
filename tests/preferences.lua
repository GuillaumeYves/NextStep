local NS = {
    modules = {},
    L = {
        FALLBACK = "fallback",
        FALLBACK_STALE_ROUTE_PACK = "stale",
        GOAL_LABELS = {
            experience = "Experience",
            gear = "Gear",
            mounts = "Mounts",
            pets = "Pets",
            achievements = "Achievements",
        },
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
        ["Veteran-Realm"] = {
            lastSeen = 123,
            goals = { experience = false, gear = false, mounts = true },
        },
    },
}

NS.Config:InitializeDatabase()
assert(NS.db.schemaVersion == 3, "Database schema did not migrate.")
assert(type(NS.db.settings.settingsWindow) == "table", "Settings window defaults did not migrate.")

local character = { name = "Veteran", realm = "Realm", level = 90, maxLevel = 90 }
local profile = NS.Config:GetCharacterProfile(character, true)
assert(profile.lastSeen == 123, "Existing character state was not preserved.")
assert(type(profile.widget) == "table", "The compact window settings were not added.")

local recommendations = {
    {
        id = "experience", importance = NS.Constants.IMPORTANCE.HIGH,
        status = NS.Constants.STATUS.AVAILABLE, goals = { NS.Constants.GOAL.EXPERIENCE },
    },
    {
        id = "gear", importance = NS.Constants.IMPORTANCE.HIGH,
        status = NS.Constants.STATUS.AVAILABLE, goals = { NS.Constants.GOAL.GEAR },
    },
}

local plan = NS.Planner:Build({ character = character }, recommendations)
assert(#plan.recommendations == 2, "Legacy goal choices must not filter the plan.")
assert(#plan.categories == 4, "The leveling category should be hidden at maximum level.")
assert(plan.categories[1].id == "gear" and #plan.categories[1].tasks == 1,
    "Gear tasks were not grouped first for a max-level character.")
assert(#plan.categories[2].tasks == 0 and #plan.categories[3].tasks == 0
    and #plan.categories[4].tasks == 0,
    "Empty supported collection categories should remain selectable.")

local levelingPlan = NS.Planner:Build({
    character = { name = "Rookie", realm = "Realm", level = 20, maxLevel = 90 },
}, recommendations)
assert(#levelingPlan.categories == 5 and levelingPlan.categories[1].id == "experience",
    "The leveling category should remain available below maximum level.")

print("Profile migration and category tests passed.")
