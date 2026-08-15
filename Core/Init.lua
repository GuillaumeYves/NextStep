local addonName, NS = ...

NS.addonName = addonName
NS.version = "0.1.0"
NS.modules = NS.modules or {}

function NS:RegisterModule(name, module)
    self.modules[name] = module
    self[name] = module
    return module
end

function NS:GetModule(name)
    return self.modules[name]
end

function NS:Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff58c6ffNextStep:|r " .. tostring(message))
    end
end

function NS:Initialize()
    if self.initialized then
        return
    end

    self.Config:InitializeDatabase()
    self.UI.MainWindow:Create()
    self.UI.DebugWindow:Create()
    self.UI.Settings:Create()
    self:RegisterSlashCommands()
    self.initialized = true
end

function NS:Refresh(reason)
    if not self.initialized then
        return
    end

    local state = self.Data.Player:Collect()
    local recommendations, trace = self.Recommendation.Engine:Build(state)
    local plan = self.Planner:Build(state, recommendations)

    self.playerState = state
    self.recommendations = recommendations
    self.ruleTrace = trace
    self.plan = plan

    self.Data.Player:RecordCharacterSeen(state)
    self.UI.MainWindow:Update(state, plan)
    self.lastRefreshReason = reason
end

function NS:RequestRefresh(reason, delay)
    self.Events:RequestRefresh(reason, delay)
end

function NS:RegisterSlashCommands()
    _G.SLASH_NEXTSTEP1 = "/nextstep"
    _G.SLASH_NEXTSTEP2 = "/ns"
    _G.SlashCmdList.NEXTSTEP = function(input)
        NS:HandleSlashCommand(input)
    end
end

function NS:HandleSlashCommand(input)
    local command = strtrim(input or ""):lower()

    if command == "" then
        self.UI.MainWindow:Toggle()
    elseif command == "debug" then
        self.db.settings.debugMode = not self.db.settings.debugMode
        self:Print("Debug mode " .. (self.db.settings.debugMode and "enabled." or "disabled."))
    elseif command == "debug state" then
        if self.API.WoW:IsInCombat() then
            self:RequestRefresh("debug_state")
            self:Print("Refresh deferred until combat ends. Showing cached state.")
        else
            self:Refresh("debug_state")
        end
        self.UI.DebugWindow:ShowState(self.playerState)
    elseif command == "debug recommendations" then
        if self.API.WoW:IsInCombat() then
            self:RequestRefresh("debug_recommendations")
            self:Print("Refresh deferred until combat ends. Showing cached recommendations.")
        else
            self:Refresh("debug_recommendations")
        end
        self.UI.DebugWindow:ShowRecommendations(self.ruleTrace, self.recommendations)
    elseif command == "reset" then
        self.Config:ResetSettings()
        self.UI.MainWindow:ResetPosition()
        self.UI.Settings:Update()
        self:RequestRefresh("settings_reset", 0)
        self:Print("Settings reset.")
    else
        self:Print("Commands: /nextstep, /ns, /ns debug, /ns debug state, /ns debug recommendations, /ns reset")
    end
end
