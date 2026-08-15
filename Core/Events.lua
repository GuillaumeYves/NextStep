local addonName, NS = ...

local Events = NS:RegisterModule("Events", {})
NS.Events = Events

Events.frame = CreateFrame("Frame")
Events.pendingRefresh = false
Events.refreshSerial = 0

local refreshEvents = {
    PLAYER_ENTERING_WORLD = true,
    PLAYER_EQUIPMENT_CHANGED = true,
    CURRENCY_DISPLAY_UPDATE = true,
    WEEKLY_REWARDS_UPDATE = true,
}

function Events:RegisterRuntimeEvents()
    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self.frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
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
    elseif event == "PLAYER_REGEN_ENABLED" then
        if self.pendingRefresh then
            local reason = self.pendingReason or "combat_ended"
            self.pendingRefresh = false
            self.pendingReason = nil
            self:RequestRefresh(reason, 0)
        end
    elseif refreshEvents[event] then
        self:RequestRefresh(event)
    end
end

Events.frame:SetScript("OnEvent", function(_, event, ...)
    Events:OnEvent(event, ...)
end)
Events.frame:RegisterEvent("ADDON_LOADED")
