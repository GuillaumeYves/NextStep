local NS = {
    modules = {},
    L = {
        FALLBACK = "fallback",
        FALLBACK_STALE_ROUTE_PACK = "stale",
        GOAL_LABELS = {
            experience = "Experience",
            progression = "Campaign",
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
assert(#plan.categories == 5, "Maximum-level characters should receive all five relevant categories.")
assert(plan.categories[1].id == "progression" and #plan.categories[1].tasks == 0,
    "Campaign and unlocks should be the first maximum-level category.")
assert(plan.categories[2].id == "gear" and #plan.categories[2].tasks == 1,
    "Gear tasks were not grouped after patch progression.")
assert(#plan.categories[3].tasks == 0 and #plan.categories[4].tasks == 0
    and #plan.categories[5].tasks == 0,
    "Empty supported collection categories should remain selectable.")

local categoryPlan = NS.Planner:Build({ character = character }, {
    {
        id = "mount_achievement", importance = NS.Constants.IMPORTANCE.USEFUL,
        status = NS.Constants.STATUS.AVAILABLE,
        goals = { NS.Constants.GOAL.MOUNTS, NS.Constants.GOAL.ACHIEVEMENTS },
    },
    {
        id = "mount_route", importance = NS.Constants.IMPORTANCE.USEFUL,
        status = NS.Constants.STATUS.AVAILABLE, goals = { NS.Constants.GOAL.MOUNTS },
    },
})
assert(#categoryPlan.categories[3].tasks == 2,
    "A category should preserve multiple concrete route recommendations.")
assert(#categoryPlan.categories[5].tasks == 1,
    "A route with multiple goals should appear in each relevant category.")

local weeklyPlan = NS.Planner:Build({ character = character }, {
    {
        id = "weekly", category = "weekly", importance = NS.Constants.IMPORTANCE.HIGH,
        status = NS.Constants.STATUS.AVAILABLE,
        goals = { NS.Constants.GOAL.PROGRESSION, NS.Constants.GOAL.GEAR },
    },
})
assert(#weeklyPlan.categories[1].tasks == 0 and #weeklyPlan.categories[2].tasks == 0,
    "Weekly work should remain outside scrollable campaign and gear categories.")

assert(NS.Util.Formatting:RouteSteps({ "First", "Second", "Third" }, 2) == "1. First\n2. Second",
    "Visible route steps should remain ordered and bounded.")

local levelingPlan = NS.Planner:Build({
    character = { name = "Rookie", realm = "Realm", level = 20, maxLevel = 90 },
}, recommendations)
assert(#levelingPlan.categories == 5 and levelingPlan.categories[1].id == "experience",
    "The leveling category should remain available below maximum level.")

print("Profile migration and category tests passed.")
