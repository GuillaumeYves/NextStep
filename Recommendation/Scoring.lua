local _, NS = ...

NS.Recommendation = NS.Recommendation or {}
local Scoring = {}
NS.Recommendation.Scoring = Scoring

Scoring.PRIORITY = {
    EMPTY_MAIN_HAND = 98,
    VAULT_CLAIM = 95,
    QUEST_TURN_IN = 92,
    LEVELING = 88,
    VAULT_FIRST_OPTION = 85,
    EMPTY_EQUIPMENT = 82,
    VAULT_LATER_OPTION = 80,
    LEVELING_DUNGEON = 65,
    RESTED_XP = 60,
}

function Scoring:GetVaultPriority(index)
    if index == 1 then
        return self.PRIORITY.VAULT_FIRST_OPTION
    end
    return self.PRIORITY.VAULT_LATER_OPTION
end

function Scoring:Compare(a, b)
    if a.priority == b.priority then
        return a.id < b.id
    end
    return a.priority > b.priority
end
