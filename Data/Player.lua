local _, NS = ...

NS.Data = NS.Data or {}
local Player = {}
NS.Data.Player = Player

function Player:Collect()
    local state = NS.Model.PlayerState:New()
    local character, characterReady = NS.Data.Character:Collect()
    local experience, experienceReady = NS.Data.Experience:Collect()
    local quests, questsReady = NS.Data.Quests:Collect()
    local leveling, levelingReady = NS.Data.Leveling:Collect(character)
    local equipment, equipmentReady = NS.Data.Equipment:Collect()
    local currencies, currenciesReady = NS.Data.Currency:Collect()
    local vault, vaultReady = NS.Data.GreatVault:Collect()

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
    state.weekly = NS.Data.Weekly:Collect(vault)
    state.activities = NS.Data.Activities:Collect(vault, quests, leveling)
    state.capabilities.character = characterReady
    state.capabilities.experience = experienceReady
    state.capabilities.questLog = questsReady
    state.capabilities.levelingDungeons = levelingReady
    state.capabilities.currencies = currenciesReady
    state.capabilities.equipment = equipmentReady
    state.capabilities.greatVault = vaultReady

    return state
end

function Player:RecordCharacterSeen(state)
    if not NS.db or not state or not state.character then
        return
    end

    local key = NS.Util.Formatting:CharacterKey(state.character)
    NS.db.characters[key] = NS.db.characters[key] or {}
    NS.db.characters[key].lastSeen = state.generatedAt
end
