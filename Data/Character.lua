local _, NS = ...

NS.Data = NS.Data or {}
local Character = {}
NS.Data.Character = Character

function Character:Collect()
    local identity = NS.API.WoW:GetCharacterIdentity()
    local specID, specName = NS.API.WoW:GetSpecialization()

    identity.maxLevel = NS.API.WoW:GetMaximumPlayerLevel()
    identity.specID = specID
    identity.specName = specName
    identity.averageItemLevel = nil
    identity.equippedItemLevel = nil

    return identity, identity.name ~= nil and identity.level ~= nil
end
