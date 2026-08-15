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
    frame:SetSize(330, 230)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 24,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 20, -18)
    frame.title:SetText("NextStep Settings")

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -4, -4)

    frame.optional = createCheck(frame, "Show optional recommendations", -55, function(button)
        NS.db.settings.showOptionalRecommendations = button:GetChecked() and true or false
        NS:RequestRefresh("settings_optional", 0)
    end)

    frame.lock = createCheck(frame, "Lock window", -88, function(button)
        NS.db.settings.lockWindow = button:GetChecked() and true or false
    end)

    frame.remember = createCheck(frame, "Remember window position", -121, function(button)
        NS.db.settings.rememberWindowPosition = button:GetChecked() and true or false
    end)

    frame.maximumLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.maximumLabel:SetPoint("TOPLEFT", 24, -166)

    frame.minus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.minus:SetSize(28, 24)
    frame.minus:SetPoint("TOPRIGHT", -72, -158)
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

    self.frame = frame
    self:Update()
    return frame
end

function Settings:Update()
    if not self.frame or not NS.db then
        return
    end
    self.frame.optional:SetChecked(NS.db.settings.showOptionalRecommendations)
    self.frame.lock:SetChecked(NS.db.settings.lockWindow)
    self.frame.remember:SetChecked(NS.db.settings.rememberWindowPosition)
    self.frame.maximumLabel:SetText("Maximum recommendations: " .. NS.db.settings.maximumRecommendations)
end

function Settings:Toggle()
    if not self.frame then
        self:Create()
    end
    self:Update()
    self.frame:SetShown(not self.frame:IsShown())
end
