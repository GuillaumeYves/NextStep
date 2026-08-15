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
