local _, NS = ...

local Config = NS:RegisterModule("Config", {})
NS.Config = Config

Config.DEFAULTS = {
    schemaVersion = NS.Constants.SCHEMA_VERSION,
    settings = {
        showOptionalRecommendations = false,
        maximumRecommendations = NS.Constants.DEFAULT_MAX_RECOMMENDATIONS,
        debugMode = false,
        lockWindow = false,
        rememberWindowPosition = true,
        window = {
            point = "CENTER",
            relativePoint = "CENTER",
            x = 0,
            y = 0,
        },
    },
    characters = {},
}

Config.CHARACTER_DEFAULTS = {
    profileVersion = NS.Constants.CHARACTER_SCHEMA_VERSION,
    onboardingComplete = false,
    goals = {
        experience = true,
        gear = true,
        mounts = false,
        pets = false,
    },
    widget = {
        enabled = true,
        point = "TOP",
        relativePoint = "TOP",
        x = 0,
        y = -160,
    },
}

function Config:GetCharacterKey(character)
    if type(character) ~= "table" or type(character.name) ~= "string" or character.name == ""
        or type(character.realm) ~= "string" or character.realm == "" then
        return nil
    end
    return NS.Util.Formatting:CharacterKey(character)
end

function Config:GetCharacterDefaults(character)
    local defaults = NS.Util.Table:Copy(self.CHARACTER_DEFAULTS)
    if type(character) == "table" and type(character.level) == "number"
        and type(character.maxLevel) == "number" and character.level >= character.maxLevel then
        defaults.goals.experience = false
    end
    return defaults
end

function Config:GetCharacterProfile(character, create)
    if not NS.db then
        return nil
    end

    local key = self:GetCharacterKey(character)
    if not key then
        return nil
    end

    local profile = NS.db.characters[key]
    if type(profile) ~= "table" then
        if not create then
            return nil
        end
        profile = self:GetCharacterDefaults(character)
        NS.db.characters[key] = profile
    elseif create then
        NS.Util.Table:ApplyDefaults(profile, self:GetCharacterDefaults(character))
        profile.profileVersion = NS.Constants.CHARACTER_SCHEMA_VERSION
    end

    return profile, key
end

function Config:GetActiveCharacterProfile(create)
    return self:GetCharacterProfile(NS.playerState and NS.playerState.character, create)
end

function Config:InitializeDatabase()
    if type(_G.NextStepDB) ~= "table" then
        _G.NextStepDB = {}
    end

    NS.Util.Table:ApplyDefaults(_G.NextStepDB, self.DEFAULTS)
    _G.NextStepDB.schemaVersion = NS.Constants.SCHEMA_VERSION
    NS.db = _G.NextStepDB

    local maximum = tonumber(NS.db.settings.maximumRecommendations)
    if not maximum then
        maximum = NS.Constants.DEFAULT_MAX_RECOMMENDATIONS
    end
    NS.db.settings.maximumRecommendations = math.max(
        NS.Constants.MIN_RECOMMENDATIONS,
        math.min(NS.Constants.MAX_RECOMMENDATIONS, math.floor(maximum))
    )
end

function Config:ResetSettings()
    NS.db.settings = NS.Util.Table:Copy(self.DEFAULTS.settings)
end

function Config:ResetCharacterProfile(character)
    local key = self:GetCharacterKey(character)
    if not key or not NS.db then
        return nil
    end

    local lastSeen = type(NS.db.characters[key]) == "table" and NS.db.characters[key].lastSeen or nil
    local profile = self:GetCharacterDefaults(character)
    profile.lastSeen = lastSeen
    NS.db.characters[key] = profile
    return profile
end
