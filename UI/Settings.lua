local _, NS = ...

NS.UI = NS.UI or {}
local Settings = {}
NS.UI.Settings = Settings

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

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(440, 310)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    NS.UI.Theme:ApplyWindow(frame)
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 20, -18)
    frame.title:SetText(NS.L.SETTINGS_TITLE)
    frame.title:SetTextColor(unpack(NS.UI.Theme.COLORS.gold))

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -4, -4)

    frame.optional = createCheck(frame, NS.L.SHOW_OPTIONAL, -55, function(button)
        NS.db.settings.showOptionalRecommendations = button:GetChecked() and true or false
        NS:RequestRefresh("settings_optional", 0)
    end)

    frame.widget = createCheck(frame, NS.L.SHOW_NEXT_STEP_WIDGET, -88, function(button)
        NS.UI.NextStepWidget:SetEnabled(button:GetChecked() and true or false)
    end)

    frame.lock = createCheck(frame, NS.L.LOCK_WINDOW, -121, function(button)
        NS.db.settings.lockWindow = button:GetChecked() and true or false
    end)

    frame.remember = createCheck(frame, NS.L.REMEMBER_POSITION, -154, function(button)
        NS.db.settings.rememberWindowPosition = button:GetChecked() and true or false
    end)

    frame.maximumLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.maximumLabel:SetPoint("TOPLEFT", 24, -202)

    frame.minus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.minus:SetSize(28, 24)
    frame.minus:SetPoint("TOPRIGHT", -72, -194)
    frame.minus:SetText("-")
    frame.minus:SetScript("OnClick", function()
        local value = math.max(NS.Constants.MIN_RECOMMENDATIONS, NS.db.settings.maximumRecommendations - 1)
        NS.db.settings.maximumRecommendations = value
        Settings:Update()
        NS:RequestRefresh("settings_maximum", 0)
    end)

    frame.plus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.plus:SetSize(28, 24)
    frame.plus:SetPoint("LEFT", frame.minus, "RIGHT", 6, 0)
    frame.plus:SetText("+")
    frame.plus:SetScript("OnClick", function()
        local value = math.min(NS.Constants.MAX_RECOMMENDATIONS, NS.db.settings.maximumRecommendations + 1)
        NS.db.settings.maximumRecommendations = value
        Settings:Update()
        NS:RequestRefresh("settings_maximum", 0)
    end)

    frame.goals = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.goals:SetSize(185, 28)
    frame.goals:SetPoint("BOTTOMLEFT", 24, 24)
    frame.goals:SetText(NS.L.EDIT_CHARACTER_GOALS)
    frame.goals:SetScript("OnClick", function()
        frame:Hide()
        NS.UI.Onboarding:ShowForCurrentCharacter()
    end)

    self.frame = frame
    self:Update()
    return frame
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
