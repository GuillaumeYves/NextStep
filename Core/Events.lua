local addonName, NS = ...

local Events = NS:RegisterModule("Events", {})
NS.Events = Events

Events.frame = CreateFrame("Frame")
Events.pendingRefresh = false
Events.refreshSerial = 0
Events.experienceRefreshSerial = 0

local refreshEvents = {
    PLAYER_ENTERING_WORLD = true,
    PLAYER_EQUIPMENT_CHANGED = true,
    CURRENCY_DISPLAY_UPDATE = true,
    WEEKLY_REWARDS_UPDATE = true,
    QUEST_LOG_UPDATE = true,
    QUEST_TURNED_IN = true,
    SUPER_TRACKING_CHANGED = true,
    LFG_UPDATE_RANDOM_INFO = true,
    NEW_MOUNT_ADDED = true,
    PET_JOURNAL_LIST_UPDATE = true,
    GET_ITEM_INFO_RECEIVED = true,
    CHALLENGE_MODE_COMPLETED = true,
    ACHIEVEMENT_EARNED = true,
    CRITERIA_UPDATE = true,
}

function Events:RegisterRuntimeEvents()
    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self.frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
    self.frame:RegisterEvent("QUEST_LOG_UPDATE")
    self.frame:RegisterEvent("QUEST_TURNED_IN")
    self.frame:RegisterEvent("SUPER_TRACKING_CHANGED")
    self.frame:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
    self.frame:RegisterEvent("NEW_MOUNT_ADDED")
    self.frame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
    self.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self.frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self.frame:RegisterEvent("ACHIEVEMENT_EARNED")
    self.frame:RegisterEvent("CRITERIA_UPDATE")
    self.frame:RegisterEvent("UPDATE_EXHAUSTION")
    self.frame:RegisterEvent("PLAYER_XP_UPDATE")
    self.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self.frame:RegisterEvent("UNIT_LEVEL")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function Events:RequestRefresh(reason, delay)
    if NS.API.WoW:IsInCombat() then
        self.pendingRefresh = true
        self.pendingReason = reason
        return
    end

    self.refreshSerial = self.refreshSerial + 1
    local serial = self.refreshSerial
    local wait = delay
    if wait == nil then
        wait = NS.Constants.REFRESH_DELAY
    end

    local callback = function()
        if serial == Events.refreshSerial then
            if NS.API.WoW:IsInCombat() then
                Events.pendingRefresh = true
                Events.pendingReason = reason
            else
                NS:Refresh(reason)
            end
        end
    end

    if wait > 0 and C_Timer and C_Timer.After then
        C_Timer.After(wait, callback)
    else
        callback()
    end
end

function Events:RequestExperienceRefresh(reason, delay)
    if NS.API.WoW:IsInCombat() then
        self.pendingExperienceRefresh = true
        self.pendingExperienceReason = reason
        return
    end

    self.experienceRefreshSerial = self.experienceRefreshSerial + 1
    local serial = self.experienceRefreshSerial
    local wait = delay or NS.Constants.REFRESH_DELAY
    local callback = function()
        if serial ~= Events.experienceRefreshSerial then
            return
        end
        if NS.API.WoW:IsInCombat() then
            Events.pendingExperienceRefresh = true
            Events.pendingExperienceReason = reason
        else
            NS:RefreshExperience(reason)
        end
    end

    if wait > 0 and C_Timer and C_Timer.After then
        C_Timer.After(wait, callback)
    else
        callback()
    end
end

function Events:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon ~= addonName then
            return
        end
        self.frame:UnregisterEvent("ADDON_LOADED")
        NS:Initialize()
        self:RegisterRuntimeEvents()
        return
    end

    if event == "PLAYER_LOGIN" then
        self:RequestRefresh("player_login", 0.5)
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:RequestRefresh(event, 0.5)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...
        if unit == "player" then
            self:RequestRefresh(event)
        end
    elseif event == "UNIT_LEVEL" then
        local unit = ...
        if unit == "player" then
            self:RequestRefresh(event)
        end
    elseif event == "PLAYER_XP_UPDATE" then
        local unit = ...
        if unit == "player" then
            self:RequestExperienceRefresh(event, 0.5)
        end
    elseif event == "UPDATE_EXHAUSTION" then
        self:RequestExperienceRefresh(event, 0.5)
    elseif event == "PLAYER_REGEN_ENABLED" then
        if self.pendingRefresh then
            local reason = self.pendingReason or "combat_ended"
            self.pendingRefresh = false
            self.pendingReason = nil
            self.pendingExperienceRefresh = false
            self.pendingExperienceReason = nil
            self:RequestRefresh(reason, 0)
        elseif self.pendingExperienceRefresh then
            local reason = self.pendingExperienceReason or "experience_after_combat"
            self.pendingExperienceRefresh = false
            self.pendingExperienceReason = nil
            self:RequestExperienceRefresh(reason, 0)
        end
    elseif refreshEvents[event] then
        self:RequestRefresh(event)
    end
end

Events.frame:SetScript("OnEvent", function(_, event, ...)
    Events:OnEvent(event, ...)
end)
Events.frame:RegisterEvent("ADDON_LOADED")
