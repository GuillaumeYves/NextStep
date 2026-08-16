local _, NS = ...

NS.UI = NS.UI or {}
local Onboarding = {}
NS.UI.Onboarding = Onboarding

local function createGoalOption(parent, goal, y)
    local option = CreateFrame("Frame", nil, parent)
    option:SetPoint("TOPLEFT", 28, y)
    option:SetPoint("RIGHT", -28, 0)
    option:SetHeight(62)

    option.check = CreateFrame("CheckButton", nil, option, "UICheckButtonTemplate")
    option.check:SetPoint("TOPLEFT", 0, -2)
    option.check:SetSize(28, 28)

    option.title = option:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    option.title:SetPoint("TOPLEFT", option.check, "TOPRIGHT", 5, -2)
    option.title:SetText(NS.L.GOAL_LABELS[goal])

    option.description = option:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    option.description:SetPoint("TOPLEFT", option.title, "BOTTOMLEFT", 0, -4)
    option.description:SetPoint("RIGHT", -8, 0)
    option.description:SetJustifyH("LEFT")
    option.description:SetWordWrap(true)
    option.description:SetText(NS.L.GOAL_DESCRIPTIONS[goal])
    option.goal = goal
    return option
end

function Onboarding:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(570, 540)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    NS.UI.Theme:ApplyWindow(frame)
    frame:Hide()

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -5, -5)
    frame.close:SetScript("OnClick", function()
        Onboarding.dismissedThisSession = true
        frame:Hide()
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    frame.title:SetPoint("TOPLEFT", 28, -24)
    frame.title:SetText(NS.L.ONBOARDING_TITLE)
    frame.title:SetTextColor(unpack(NS.UI.Theme.COLORS.gold))

    frame.tagline = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.tagline:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -5)
    frame.tagline:SetText(NS.L.TAGLINE)

    frame.introduction = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.introduction:SetPoint("TOPLEFT", 28, -88)
    frame.introduction:SetPoint("RIGHT", -28, 0)
    frame.introduction:SetHeight(42)
    frame.introduction:SetJustifyH("LEFT")
    frame.introduction:SetWordWrap(true)

    frame.section = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.section:SetPoint("TOPLEFT", 28, -140)
    frame.section:SetText(NS.L.ONBOARDING_GOALS)
    frame.section:SetTextColor(unpack(NS.UI.Theme.COLORS.mutedGold))

    frame.goalOptions = {}
    for index, goal in ipairs(NS.Constants.GOAL_ORDER) do
        frame.goalOptions[goal] = createGoalOption(frame, goal, -160 - ((index - 1) * 66))
    end

    frame.widget = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.widget:SetPoint("BOTTOMLEFT", 28, 58)
    frame.widget:SetSize(28, 28)
    frame.widgetLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.widgetLabel:SetPoint("LEFT", frame.widget, "RIGHT", 5, 0)
    frame.widgetLabel:SetText(NS.L.ONBOARDING_SHOW_WIDGET)

    frame.errorText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.errorText:SetPoint("BOTTOMLEFT", 30, 28)
    frame.errorText:SetPoint("RIGHT", -190, 0)
    frame.errorText:SetJustifyH("LEFT")
    frame.errorText:SetTextColor(1, 0.25, 0.2)

    frame.save = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.save:SetSize(145, 28)
    frame.save:SetPoint("BOTTOMRIGHT", -24, 24)
    frame.save:SetText(NS.L.ONBOARDING_SAVE)
    frame.save:SetScript("OnClick", function()
        Onboarding:Save()
    end)

    self.frame = frame
    return frame
end

function Onboarding:ShowForCharacter(character)
    local profile = NS.Config:GetCharacterProfile(character, true)
    if not profile then
        return false
    end

    local frame = self:Create()
    self.character = character
    self.dismissedThisSession = false
    frame.introduction:SetText(string.format(NS.L.ONBOARDING_INTRODUCTION, character.name or NS.L.CHARACTER_UNAVAILABLE))
    frame.errorText:SetText("")

    for _, goal in ipairs(NS.Constants.GOAL_ORDER) do
        frame.goalOptions[goal].check:SetChecked(profile.goals[goal] == true)
    end
    frame.widget:SetChecked(profile.widget.enabled ~= false)
    frame:Show()
    frame:Raise()
    return true
end

function Onboarding:ShowForCurrentCharacter()
    if not NS.playerState or not self:ShowForCharacter(NS.playerState.character) then
        NS:Print(NS.L.CHARACTER_UNAVAILABLE)
        return false
    end
    return true
end

function Onboarding:MaybeShow(character)
    local profile = NS.Config:GetCharacterProfile(character, true)
    local frame = self:Create()
    if profile and not profile.onboardingComplete and not self.dismissedThisSession and not frame:IsShown() then
        self:ShowForCharacter(character)
    end
end

function Onboarding:Save()
    local profile = NS.Config:GetCharacterProfile(self.character, true)
    if not profile then
        return
    end

    local selections = {}
    local anySelected = false
    for _, goal in ipairs(NS.Constants.GOAL_ORDER) do
        local selected = self.frame.goalOptions[goal].check:GetChecked() and true or false
        selections[goal] = selected
        anySelected = anySelected or selected
    end

    if not anySelected then
        self.frame.errorText:SetText(NS.L.ONBOARDING_GOAL_REQUIRED)
        return
    end

    for goal, selected in pairs(selections) do
        profile.goals[goal] = selected
    end

    profile.widget.enabled = self.frame.widget:GetChecked() and true or false
    profile.onboardingComplete = true
    self.frame:Hide()
    NS.UI.Settings:Update()
    NS:RequestRefresh("onboarding_saved", 0)
end
