local _, NS = ...

NS.UI = NS.UI or {}
local NextStepWidget = {}
NS.UI.NextStepWidget = NextStepWidget

local validPoints = {
    TOPLEFT = true,
    TOP = true,
    TOPRIGHT = true,
    LEFT = true,
    CENTER = true,
    RIGHT = true,
    BOTTOMLEFT = true,
    BOTTOM = true,
    BOTTOMRIGHT = true,
}

function NextStepWidget:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(380, 104)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    NS.UI.Theme:ApplyWindow(frame)
    frame:Hide()

    frame:SetScript("OnDragStart", function(self)
        if not NS.db.settings.lockWindow then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        NextStepWidget:SavePosition()
    end)

    frame.brand = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.brand:SetPoint("TOPLEFT", 14, -11)
    frame.brand:SetText(NS.L.WIDGET_HEADING)
    frame.brand:SetTextColor(unpack(NS.UI.Theme.COLORS.gold))

    frame.importance = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.importance:SetPoint("TOPRIGHT", -34, -11)

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetSize(24, 24)
    frame.close:SetPoint("TOPRIGHT", -5, -5)
    frame.close:SetScript("OnClick", function()
        NextStepWidget:SetEnabled(false)
        NS:Print(NS.L.WIDGET_DISABLED_MESSAGE)
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 14, -34)
    frame.title:SetPoint("RIGHT", -46, 0)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetWordWrap(false)

    frame.description = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.description:SetPoint("TOPLEFT", 14, -56)
    frame.description:SetPoint("BOTTOMRIGHT", -46, 12)
    frame.description:SetJustifyH("LEFT")
    frame.description:SetJustifyV("TOP")
    frame.description:SetWordWrap(true)

    frame.expand = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.expand:SetSize(28, 28)
    frame.expand:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.expand:SetText(">")
    frame.expand:SetScript("OnClick", function()
        NS.UI.MainWindow:Show()
    end)

    self.frame = frame
    return frame
end

function NextStepWidget:RestorePosition(profile)
    local frame = self:Create()
    local position = profile and profile.widget or {}
    frame:ClearAllPoints()
    if validPoints[position.point] and validPoints[position.relativePoint] then
        frame:SetPoint(position.point, UIParent, position.relativePoint, position.x or 0, position.y or 0)
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, -160)
    end
end

function NextStepWidget:SavePosition()
    local profile = NS.Config:GetCharacterProfile(self.character, true)
    if not profile or not self.frame then
        return
    end

    local point, _, relativePoint, x, y = self.frame:GetPoint(1)
    profile.widget.point = point
    profile.widget.relativePoint = relativePoint
    profile.widget.x = x
    profile.widget.y = y
end

function NextStepWidget:SetEnabled(enabled)
    local frame = self:Create()
    local profile = NS.Config:GetActiveCharacterProfile(true)
    if not profile then
        return
    end

    profile.widget.enabled = enabled and true or false
    if enabled and profile.onboardingComplete and NS.plan then
        self:Update(NS.playerState.character, NS.plan)
    else
        frame:Hide()
    end
    NS.UI.Settings:Update()
end

function NextStepWidget:ResetPosition()
    local profile = NS.Config:GetActiveCharacterProfile(true)
    if not profile then
        return
    end

    local defaults = NS.Config:GetCharacterDefaults(NS.playerState.character)
    profile.widget.point = defaults.widget.point
    profile.widget.relativePoint = defaults.widget.relativePoint
    profile.widget.x = defaults.widget.x
    profile.widget.y = defaults.widget.y
    self:RestorePosition(profile)
end

function NextStepWidget:Update(character, plan)
    local frame = self:Create()
    local profile, profileKey = NS.Config:GetCharacterProfile(character, true)
    self.character = character

    if not profile or not profile.onboardingComplete or profile.widget.enabled == false then
        frame:Hide()
        return
    end

    if self.profileKey ~= profileKey then
        self.profileKey = profileKey
        self:RestorePosition(profile)
    end

    local recommendation = plan and plan.recommendations and plan.recommendations[1]
    if recommendation then
        local color = NS.UI.Theme.IMPORTANCE_COLORS[recommendation.importance]
            or NS.UI.Theme.IMPORTANCE_COLORS.USEFUL
        frame.importance:SetText(NS.L.IMPORTANCE_LABELS[recommendation.importance] or recommendation.importance)
        frame.importance:SetTextColor(unpack(color))
        frame.title:SetText(recommendation.title or "")
        frame.description:SetText(recommendation.description or "")
    else
        frame.importance:SetText("")
        frame.title:SetText(NS.L.ALL_CLEAR)
        frame.description:SetText(plan and plan.fallbackMessage or NS.L.FALLBACK)
    end
    frame:Show()
end
