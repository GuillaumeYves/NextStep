local NS = { Data = {}, UI = {} }

local function loadAddonFile(path)
    local chunk, loadError = loadfile(path)
    assert(chunk, loadError)
    chunk("NextStep", NS)
end

loadAddonFile("Data/PatchProgress.lua")
loadAddonFile("UI/Theme.lua")

local progress = NS.Data.PatchProgress:Collect({
    curatedRoutes = {
        patch = "12.1.0",
        completion = {
            character = { current = 1, total = 2, dataReady = true },
        },
    },
    vault = {
        dataReady = true,
        activities = {
            { id = "one", available = true, completed = true, metadata = { threshold = 1 } },
            { id = "two", available = true, completed = false, metadata = { threshold = 4 } },
            { id = "future", available = false, completed = false, metadata = { threshold = 6 } },
        },
    },
    patchCatalog = {
        patch = "12.1.0",
        completion = {
            mounts = { current = 2, total = 4 },
            pets = { current = 1, total = 2 },
            achievements = { current = 5, total = 10 },
        },
    },
})

assert(progress.dataReady == true and progress.patch == "12.1.0", "Patch progress should be ready.")
assert(progress.character.current == 2 and progress.character.total == 4,
    "Character progress should combine campaign milestones and available weekly slots.")
assert(progress.account.current == 8 and progress.account.total == 16,
    "Account progress should combine mount, pet, and achievement completion.")
assert(#progress.character.groups == 2 and #progress.account.groups == 3,
    "Patch progress should preserve its hover-detail groups.")

local colors = NS.UI.Theme.PROGRESS_COLORS
assert(NS.UI.Theme:GetProgressColor(0, 10) == colors.low, "Low progress should be red.")
assert(NS.UI.Theme:GetProgressColor(3, 10) == colors.mediumLow, "Early progress should be orange.")
assert(NS.UI.Theme:GetProgressColor(6, 10) == colors.mediumHigh, "Later progress should be yellow.")
assert(NS.UI.Theme:GetProgressColor(8, 10) == colors.high, "Near-complete progress should be green.")

print("Patch completion tests passed.")
