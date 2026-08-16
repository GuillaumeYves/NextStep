local _, NS = ...

NS.Recommendation = NS.Recommendation or {}
local Scoring = {}
NS.Recommendation.Scoring = Scoring

Scoring.PRIORITY = {
    EMPTY_MAIN_HAND = 98,
    VAULT_CLAIM = 95,
    QUEST_TURN_IN = 92,
    IMMEDIATE_ITEM_UPGRADE = 91,
    CURATED_LEVELING_ROUTE = 89,
    LEVELING = 88,
    VAULT_FIRST_OPTION = 85,
    OPTIMIZED_VAULT = 87,
    FAST_GEAR_ROUTE = 93,
    CURATED_GEAR_ROUTE = 84,
    EMPTY_EQUIPMENT = 82,
    VAULT_LATER_OPTION = 80,
    LEVELING_DUNGEON = 65,
    RESTED_XP = 60,
    CURATED_COLLECTION_GUARANTEED = 58,
    CURATED_COLLECTION_ACHIEVEMENT = 56,
    CURATED_COLLECTION_CHANCE = 45,
    PATCH_CATALOG_REWARD = 36,
    PATCH_CATALOG = 30,
    TIER_SET = 42,
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
