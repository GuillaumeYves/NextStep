local _, NS = ...

NS.Data = NS.Data or {}
local Quests = {}
NS.Data.Quests = Quests

function Quests:Collect()
    local count, dataReady = NS.API.WoW:GetQuestLogEntryCount()
    local trackedQuestID = NS.API.WoW:GetSuperTrackedQuestID()
    local entries = {}
    local readyForTurnIn = {}
    local trackedQuest

    for index = 1, count do
        local info = NS.API.WoW:GetQuestLogInfo(index)
        if info and not info.isHeader and type(info.questID) == "number" and info.questID > 0 then
            local ready = NS.API.WoW:IsQuestReadyForTurnIn(info.questID) == true
            local rewardXP = ready and NS.API.WoW:GetQuestRewardXP(info.questID) or nil
            local entry = {
                questID = info.questID,
                title = info.title,
                isStory = info.isStory == true,
                readyForTurnIn = ready,
                rewardXP = rewardXP,
            }
            entries[#entries + 1] = entry
            if ready then
                readyForTurnIn[#readyForTurnIn + 1] = entry
            end
            if info.questID == trackedQuestID then
                trackedQuest = entry
            end
        end
    end

    if trackedQuestID and not trackedQuest then
        local ready = NS.API.WoW:IsQuestReadyForTurnIn(trackedQuestID) == true
        trackedQuest = {
            questID = trackedQuestID,
            title = NS.API.WoW:GetQuestTitle(trackedQuestID),
            readyForTurnIn = ready,
            rewardXP = ready and NS.API.WoW:GetQuestRewardXP(trackedQuestID) or nil,
        }
        if ready then
            readyForTurnIn[#readyForTurnIn + 1] = trackedQuest
        end
    end

    return {
        entries = entries,
        readyForTurnIn = readyForTurnIn,
        trackedQuest = trackedQuest,
        dataReady = dataReady,
        visibleEntryCount = count,
    }, dataReady
end
