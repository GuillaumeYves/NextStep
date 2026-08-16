local addonName, NS = ...

NS.addonName = addonName
NS.version = "0.3.0"
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
    self.UI.NextStepWidget:Create()
    self.UI.Onboarding:Create()
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
    self:BuildPlanFromState(state, reason)
    self.Data.Player:RecordCharacterSeen(state)
end

function NS:RefreshExperience(reason)
    if not self.initialized or not self.playerState then
        self:Refresh(reason)
        return
    end

    local experience, ready = self.Data.Experience:Collect()
    self.playerState.experience = experience
    self.playerState.capabilities.experience = ready
    self.playerState.generatedAt = self.API.WoW:GetTimestamp()
    self:BuildPlanFromState(self.playerState, reason)
end

function NS:BuildPlanFromState(state, reason)
    local recommendations, trace = self.Recommendation.Engine:Build(state)
    local plan = self.Planner:Build(state, recommendations)

    self.playerState = state
    self.recommendations = recommendations
    self.ruleTrace = trace
    self.plan = plan

    self.UI.MainWindow:Update(state, plan)
    self.UI.NextStepWidget:Update(state.character, plan)
    self.UI.Onboarding:MaybeShow(state.character)
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
    elseif command == "tutorial" then
        self.UI.Onboarding:ShowForCurrentCharacter()
    elseif command == "debug" then
        self.db.settings.debugMode = not self.db.settings.debugMode
        self:Print(self.db.settings.debugMode and self.L.DEBUG_MODE_ENABLED or self.L.DEBUG_MODE_DISABLED)
    elseif command == "debug state" then
        if self.API.WoW:IsInCombat() then
            self:RequestRefresh("debug_state")
            self:Print(self.L.DEBUG_STATE_DEFERRED)
        else
            self:Refresh("debug_state")
        end
        self.UI.DebugWindow:ShowState(self.playerState)
    elseif command == "debug recommendations" then
        if self.API.WoW:IsInCombat() then
            self:RequestRefresh("debug_recommendations")
            self:Print(self.L.DEBUG_RECOMMENDATIONS_DEFERRED)
        else
            self:Refresh("debug_recommendations")
        end
        self.UI.DebugWindow:ShowRecommendations(self.ruleTrace, self.recommendations)
    elseif command == "reset" then
        self.Config:ResetSettings()
        if self.playerState then
            self.Config:ResetCharacterProfile(self.playerState.character)
        end
        self.UI.MainWindow:ResetPosition()
        self.UI.NextStepWidget:ResetPosition()
        self.UI.Onboarding.dismissedThisSession = false
        self.UI.Settings:Update()
        self:RequestRefresh("settings_reset", 0)
        self:Print(self.L.SETTINGS_RESET)
    else
        self:Print(self.L.COMMANDS_HELP)
    end
end
