local _, NS = ...

NS.Data = NS.Data or {}
local Player = {}
NS.Data.Player = Player

function Player:Collect()
    local state = NS.Model.PlayerState:New()
    local character, characterReady = NS.Data.Character:Collect()
    local equipment, equipmentReady = NS.Data.Equipment:Collect()
    local currencies, currenciesReady = NS.Data.Currency:Collect()
    local vault, vaultReady = NS.Data.GreatVault:Collect()

    character.averageItemLevel = equipment.averageItemLevel
    character.equippedItemLevel = equipment.equippedItemLevel

    state.generatedAt = NS.API.WoW:GetTimestamp()
    state.character = character
    state.currencies = currencies
    state.equipment = equipment
    state.vault = vault
    state.weekly = NS.Data.Weekly:Collect(vault)
    state.activities = NS.Data.Activities:Collect(vault)
    state.capabilities.character = characterReady
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
