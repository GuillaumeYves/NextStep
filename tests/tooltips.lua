local calls = {}

GameTooltip = {
    SetOwner = function(_, owner, anchor)
        calls.owner = owner
        calls.anchor = anchor
    end,
    SetMinimumWidth = function(_, width)
        calls.minimumWidth = width
    end,
    SetAchievementByID = function(_, achievementID)
        calls.achievementID = achievementID
    end,
    SetHyperlink = function(_, link)
        calls.hyperlink = link
    end,
    SetItemByID = function(_, itemID)
        calls.itemID = itemID
    end,
    SetText = function(_, value)
        calls.text = value
    end,
    AddLine = function()
    end,
    AddDoubleLine = function()
    end,
    Show = function()
        calls.shown = true
    end,
    Hide = function()
    end,
}

local NS = {
    API = { WoW = {} },
    Constants = {
        GOAL = { ACHIEVEMENTS = "achievements" },
    },
    UI = {},
    L = setmetatable({
        ACQUISITION_LABELS = setmetatable({}, { __index = function(_, key) return key end }),
        CONFIDENCE_LABELS = setmetatable({}, { __index = function(_, key) return key end }),
    }, { __index = function(_, key) return key end }),
}

local function loadAddonFile(path)
    local chunk, loadError = loadfile(path)
    assert(chunk, loadError)
    chunk("NextStep", NS)
end

local function resetCalls()
    calls = {}
end

local function recommendation(target)
    return {
        title = "Test recommendation",
        metadata = { target = target },
    }
end

loadAddonFile("UI/Tooltips.lua")

local owner = {}
local mountTarget = {
    kind = "mount",
    itemID = 275656,
    itemLink = "item:275656",
    mountLink = "mount:1297224",
    achievementID = 63359,
    achievementLink = "achievement:63359",
    acquisition = "achievement",
}

NS.UI.Tooltips:ShowTarget(owner, recommendation(mountTarget))
assert(calls.hyperlink == "item:275656" and calls.achievementID == nil,
    "Mount hover should prefer the native reward item tooltip.")

resetCalls()
NS.UI.Tooltips:ShowTarget(owner, recommendation(mountTarget), "achievements")
assert(calls.achievementID == 63359 and calls.hyperlink == nil,
    "Achievement-category hover should use the native achievement tooltip.")

resetCalls()
NS.UI.Tooltips:ShowTarget(owner, recommendation({
    kind = "achievement",
    achievementID = 62492,
    achievementLink = "achievement:62492",
    acquisition = "client_confirmed",
}))
assert(calls.achievementID == 62492 and calls.text == nil,
    "Achievement targets should use GameTooltip achievement data.")

resetCalls()
NS.UI.Tooltips:ShowTarget(owner, recommendation({
    kind = "item",
    itemID = 246731,
    acquisition = "client_confirmed",
}))
assert(calls.itemID == 246731,
    "Uncached item targets should use the native item ID tooltip.")

resetCalls()
NS.UI.Tooltips:ShowTarget(owner, recommendation({
    kind = "mount",
    mountLink = "mount:1295958",
    acquisition = "client_confirmed",
}))
assert(calls.hyperlink == "mount:1295958",
    "Mounts without a reward item should fall back to the Mount Journal tooltip.")

resetCalls()
NS.UI.Tooltips:ShowRecommendation(owner, recommendation(mountTarget), nil, "achievements")
assert(calls.achievementID == 63359 and calls.text == nil,
    "Recommendation cards should preserve the category-specific native tooltip.")

print("Native tooltip routing tests passed.")
