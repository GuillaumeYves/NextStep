local _, NS = ...

NS.Data = NS.Data or {}
local Activities = {}
NS.Data.Activities = Activities

function Activities:Collect(vault, quests, leveling)
    local activities = {}
    NS.Util.Table:Append(activities, vault.activities)

    local tracked = quests and quests.trackedQuest
    if tracked and tracked.questID then
        activities[#activities + 1] = NS.Model.Activity:New({
            id = "quest_" .. tracked.questID,
            type = NS.Constants.ACTIVITY_TYPE.QUEST,
            name = tracked.title,
            available = true,
            completed = tracked.readyForTurnIn,
            repeatable = false,
            progressionTags = { "leveling", "quest" },
            source = "quest_log",
            metadata = { questID = tracked.questID, rewardXP = tracked.rewardXP },
        })
    end

    if leveling and leveling.dungeonFinderAvailable then
        for _, dungeon in ipairs(leveling.availableDungeons or {}) do
            activities[#activities + 1] = NS.Model.Activity:New({
                id = "leveling_dungeon_" .. tostring(dungeon.dungeonID),
                type = NS.Constants.ACTIVITY_TYPE.DUNGEON,
                name = dungeon.name or NS.L.LEVELING_DUNGEON_TITLE,
                available = true,
                completed = false,
                repeatable = true,
                progressionTags = { "leveling", "dungeon", "gear" },
                source = "dungeon_finder",
                metadata = {
                    dungeonID = dungeon.dungeonID,
                    iconID = dungeon.iconID,
                    link = dungeon.link,
                },
            })
        end
    end
    return activities
end
