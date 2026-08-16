local _, NS = ...

NS.Data = NS.Data or {}
local Player = {}
NS.Data.Player = Player

function Player:Collect(reason)
    local state = NS.Model.PlayerState:New()
    local character, characterReady = NS.Data.Character:Collect()
    local experience, experienceReady = NS.Data.Experience:Collect()
    local quests, questsReady = NS.Data.Quests:Collect()
    local leveling, levelingReady = NS.Data.Leveling:Collect(character)
    local equipment, equipmentReady = NS.Data.Equipment:Collect()
    local currencies, currenciesReady = NS.Data.Currency:Collect()
    local vault, vaultReady = NS.Data.GreatVault:Collect()
    local mythicPlus, mythicPlusReady = NS.Data.MythicPlus:Collect()

    character.averageItemLevel = equipment.averageItemLevel
    character.equippedItemLevel = equipment.equippedItemLevel

    state.generatedAt = NS.API.WoW:GetTimestamp()
    state.character = character
    state.experience = experience
    state.quests = quests
    state.leveling = leveling
    state.currencies = currencies
    state.equipment = equipment
    state.vault = vault
    state.mythicPlus = mythicPlus
    state.progression = NS.Data.Progression:Collect(state)
    NS.Data.GreatVault:ApplyProgressionContext(state.vault, state.progression)
    state.weekly = NS.Data.Weekly:Collect(vault)
    state.activities = NS.Data.Activities:Collect(vault, quests, leveling)
    state.curatedRoutes, state.capabilities.curatedRoutes = NS.Data.CuratedRoutes:Collect(state)
    state.patchCatalog, state.capabilities.patchCatalog = NS.Data.PatchCatalog:Collect(state, reason)
    state.capabilities.character = characterReady
    state.capabilities.experience = experienceReady
    state.capabilities.questLog = questsReady
    state.capabilities.levelingDungeons = levelingReady
    state.capabilities.currencies = currenciesReady
    state.capabilities.equipment = equipmentReady
    state.capabilities.greatVault = vaultReady
    state.capabilities.mythicPlus = mythicPlusReady

    return state
end

function Player:RecordCharacterSeen(state)
    if not NS.db or not state or not state.character then
        return
    end

    local profile = NS.Config:GetCharacterProfile(state.character, true)
    if profile then
        profile.lastSeen = state.generatedAt
    end
end
