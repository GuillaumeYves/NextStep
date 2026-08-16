local _, NS = ...

NS.UI = NS.UI or {}
local Settings = {}
NS.UI.Settings = Settings

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

local function createCheck(parent, label, y, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", 18, y)
    check:SetSize(26, 26)
    check.label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    check.label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    check.label:SetText(label)
    check:SetScript("OnClick", onClick)
    return check
end

function Settings:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "PortraitFrameTemplate")
    frame:SetSize(440, 270)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()

    if frame.TitleContainer and frame.TitleContainer.TitleText then
        frame.TitleContainer.TitleText:SetText(NS.L.SETTINGS_TITLE)
    end
    if frame.PortraitContainer and frame.PortraitContainer.portrait then
        frame.PortraitContainer.portrait:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    end

    frame:SetScript("OnDragStart", function(self)
        if not NS.db.settings.lockWindow then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Settings:SavePosition()
    end)

    frame.options = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    frame.options:SetPoint("TOPLEFT", 10, -58)
    frame.options:SetPoint("BOTTOMRIGHT", -10, 12)

    frame.optional = createCheck(frame.options, NS.L.SHOW_OPTIONAL, -18, function(button)
        NS.db.settings.showOptionalRecommendations = button:GetChecked() and true or false
        NS:RequestRefresh("settings_optional", 0)
    end)

    frame.widget = createCheck(frame.options, NS.L.SHOW_NEXT_STEP_WIDGET, -51, function(button)
        NS.UI.NextStepWidget:SetEnabled(button:GetChecked() and true or false)
    end)

    frame.lock = createCheck(frame.options, NS.L.LOCK_WINDOW, -84, function(button)
        NS.db.settings.lockWindow = button:GetChecked() and true or false
    end)

    frame.remember = createCheck(frame.options, NS.L.REMEMBER_POSITION, -117, function(button)
        NS.db.settings.rememberWindowPosition = button:GetChecked() and true or false
    end)

    frame.maximumLabel = frame.options:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.maximumLabel:SetPoint("TOPLEFT", 24, -164)

    frame.minus = CreateFrame("Button", nil, frame.options, "UIPanelButtonTemplate")
    frame.minus:SetSize(28, 24)
    frame.minus:SetPoint("TOPRIGHT", -62, -156)
    frame.minus:SetText("-")
    frame.minus:SetScript("OnClick", function()
        local value = math.max(NS.Constants.MIN_RECOMMENDATIONS, NS.db.settings.maximumRecommendations - 1)
        NS.db.settings.maximumRecommendations = value
        Settings:Update()
        NS:RequestRefresh("settings_maximum", 0)
    end)

    frame.plus = CreateFrame("Button", nil, frame.options, "UIPanelButtonTemplate")
    frame.plus:SetSize(28, 24)
    frame.plus:SetPoint("LEFT", frame.minus, "RIGHT", 6, 0)
    frame.plus:SetText("+")
    frame.plus:SetScript("OnClick", function()
        local value = math.min(NS.Constants.MAX_RECOMMENDATIONS, NS.db.settings.maximumRecommendations + 1)
        NS.db.settings.maximumRecommendations = value
        Settings:Update()
        NS:RequestRefresh("settings_maximum", 0)
    end)

    self.frame = frame
    self:RestorePosition()
    self:Update()
    return frame
end

function Settings:SavePosition()
    if not self.frame or not NS.db or not NS.db.settings.rememberWindowPosition then
        return
    end
    local point, _, relativePoint, x, y = self.frame:GetPoint(1)
    local position = NS.db.settings.settingsWindow
    position.point = point
    position.relativePoint = relativePoint
    position.x = x
    position.y = y
end

function Settings:RestorePosition()
    if not self.frame or not NS.db then
        return
    end
    local position = NS.db.settings.settingsWindow or {}
    self.frame:ClearAllPoints()
    if NS.db.settings.rememberWindowPosition
        and validPoints[position.point] and validPoints[position.relativePoint] then
        self.frame:SetPoint(position.point, UIParent, position.relativePoint, position.x or 0, position.y or 0)
    else
        self.frame:SetPoint("CENTER")
    end
end

function Settings:ResetPosition()
    if not self.frame then
        return
    end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER")
end

function Settings:Update()
    if not self.frame or not NS.db then
        return
    end
    self.frame.optional:SetChecked(NS.db.settings.showOptionalRecommendations)
    local profile = NS.Config:GetActiveCharacterProfile(false)
    self.frame.widget:SetEnabled(profile ~= nil)
    self.frame.widget:SetChecked(profile and profile.widget and profile.widget.enabled ~= false or false)
    self.frame.lock:SetChecked(NS.db.settings.lockWindow)
    self.frame.remember:SetChecked(NS.db.settings.rememberWindowPosition)
    self.frame.maximumLabel:SetText(string.format(NS.L.MAX_RECOMMENDATIONS, NS.db.settings.maximumRecommendations))
end

function Settings:Toggle()
    if not self.frame then
        self:Create()
    end
    self:Update()
    self.frame:SetShown(not self.frame:IsShown())
end
