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

local function createNavigationButton(parent, label, tooltip)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(28, 26)
    button:SetText(label)
    local text = button:GetFontString()
    if text then
        text:ClearAllPoints()
        text:SetPoint("CENTER", 0, 1)
    end
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tooltip)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return button
end

local function firstSentence(value)
    if type(value) ~= "string" then
        return ""
    end
    return value:match("^(.-%.)%s") or value
end

function NextStepWidget:GetSelectedCategory()
    for _, category in ipairs((self.plan and self.plan.categories) or {}) do
        if category.id == self.selectedCategoryID then
            return category
        end
    end
    return nil
end

function NextStepWidget:SelectCategory(categoryID)
    self.selectedCategoryID = categoryID
    self.categoryIndices = self.categoryIndices or {}
    self.categoryIndices[categoryID] = self.categoryIndices[categoryID] or 1
    self:Render()
end

function NextStepWidget:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(420, 184)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    NS.UI.Theme:ApplyWindow(frame)
    NS.UI.Theme:AddTopBand(frame, 34)
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

    frame.category = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.category:SetSize(250, 26)
    frame.category:SetPoint("TOPLEFT", 12, -10)
    frame.category:SetupMenu(function(_, rootDescription)
        for _, category in ipairs((NextStepWidget.plan and NextStepWidget.plan.categories) or {}) do
            rootDescription:CreateRadio(
                category.label,
                function(categoryID)
                    return NextStepWidget.selectedCategoryID == categoryID
                end,
                function(categoryID)
                    NextStepWidget:SelectCategory(categoryID)
                end,
                category.id
            )
        end
    end)

    frame.openMain = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.openMain:SetSize(92, 26)
    frame.openMain:SetPoint("TOPRIGHT", -35, -10)
    frame.openMain:SetText(NS.L.WIDGET_OPEN_MAIN)
    frame.openMain:SetScript("OnClick", function()
        NS.UI.MainWindow:Show()
    end)

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetSize(24, 24)
    frame.close:SetPoint("TOPRIGHT", -5, -5)
    frame.close:SetScript("OnClick", function()
        NextStepWidget:SetEnabled(false)
        NS:Print(NS.L.WIDGET_DISABLED_MESSAGE)
    end)

    frame.stepLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.stepLabel:SetPoint("TOPLEFT", 14, -47)
    frame.stepLabel:SetText(NS.L.WIDGET_CURRENT_STEP)
    frame.stepLabel:SetTextColor(unpack(NS.UI.Theme.COLORS.mutedGold))

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 14, -64)
    frame.title:SetPoint("RIGHT", -14, 0)
    frame.title:SetHeight(32)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetJustifyV("TOP")
    frame.title:SetWordWrap(true)

    frame.whyLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.whyLabel:SetPoint("TOPLEFT", 14, -101)
    frame.whyLabel:SetText(NS.L.WIDGET_WHY)
    frame.whyLabel:SetTextColor(unpack(NS.UI.Theme.COLORS.mutedGold))

    frame.details = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.details:SetSize(22, 20)
    frame.details:SetPoint("TOPRIGHT", -14, -97)
    frame.details:SetText("?")
    frame.details:SetScript("OnEnter", function(self)
        NS.UI.Tooltips:ShowRecommendation(self, self.recommendation)
    end)
    frame.details:SetScript("OnLeave", function()
        NS.UI.Tooltips:Hide()
    end)

    frame.reason = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.reason:SetPoint("TOPLEFT", 14, -117)
    frame.reason:SetPoint("BOTTOMRIGHT", -105, 12)
    frame.reason:SetJustifyH("LEFT")
    frame.reason:SetJustifyV("TOP")
    frame.reason:SetWordWrap(true)

    frame.previous = createNavigationButton(frame, "<", NS.L.WIDGET_PREVIOUS)
    frame.previous:SetPoint("BOTTOMRIGHT", -76, 12)
    frame.previous:SetScript("OnClick", function()
        NextStepWidget:Move(-1)
    end)

    frame.next = createNavigationButton(frame, ">", NS.L.WIDGET_NEXT)
    frame.next:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.next:SetScript("OnClick", function()
        NextStepWidget:Move(1)
    end)

    frame.position = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.position:SetPoint("BOTTOMRIGHT", -40, 20)
    frame.position:SetWidth(36)
    frame.position:SetJustifyH("CENTER")

    self.frame = frame
    return frame
end

function NextStepWidget:Render()
    local frame = self:Create()
    local category = self:GetSelectedCategory()
    local tasks = category and category.tasks or {}
    local count = #tasks
    local index = math.max(1, math.min((self.categoryIndices and self.categoryIndices[self.selectedCategoryID]) or 1, math.max(1, count)))
    self.categoryIndices = self.categoryIndices or {}
    self.categoryIndices[self.selectedCategoryID] = index

    if frame.category.SetText then
        frame.category:SetText(category and category.label or NS.L.WIDGET_CATEGORY)
    end

    local recommendation = tasks[index]
    frame.details.recommendation = recommendation
    frame.details:SetShown(recommendation ~= nil)
    if recommendation then
        frame.title:SetText(recommendation.title or "")
        frame.reason:SetText(firstSentence(recommendation.reason))
    else
        frame.title:SetText(NS.L.CATEGORY_NO_TASK_TITLE)
        frame.reason:SetText(NS.L.CATEGORY_NO_TASK_REASON)
    end

    frame.previous:SetShown(count > 1)
    frame.next:SetShown(count > 1)
    frame.position:SetShown(count > 1)
    if count > 1 then
        frame.position:SetText(string.format(NS.L.WIDGET_POSITION, index, count))
        frame.previous:SetEnabled(index > 1)
        frame.next:SetEnabled(index < count)
    end
end

function NextStepWidget:Move(direction)
    local category = self:GetSelectedCategory()
    local count = category and #category.tasks or 0
    local current = self.categoryIndices and self.categoryIndices[self.selectedCategoryID] or 1
    local nextIndex = NS.Util.RecommendationNavigation:Move(current, count, direction)
    if nextIndex ~= current then
        self.categoryIndices[self.selectedCategoryID] = nextIndex
        self:Render()
    end
end

function NextStepWidget:RestorePosition(profile)
    local frame = self:Create()
    local position = profile and profile.widget or {}
    frame:ClearAllPoints()
    if NS.db.settings.rememberWindowPosition
        and validPoints[position.point] and validPoints[position.relativePoint] then
        frame:SetPoint(position.point, UIParent, position.relativePoint, position.x or 0, position.y or 0)
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, -160)
    end
end

function NextStepWidget:SavePosition()
    local profile = NS.Config:GetCharacterProfile(self.character, true)
    if not profile or not self.frame or not NS.db.settings.rememberWindowPosition then
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
    if enabled and NS.plan then
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
    if not profile or profile.widget.enabled == false then
        frame:Hide()
        return
    end

    if self.profileKey ~= profileKey then
        self.profileKey = profileKey
        self.selectedCategoryID = nil
        self.categoryIndices = {}
        self:RestorePosition(profile)
    end

    self.plan = plan
    local selectedExists = self:GetSelectedCategory() ~= nil
    if not selectedExists then
        self.selectedCategoryID = nil
        for _, category in ipairs(plan.categories or {}) do
            if #category.tasks > 0 then
                self.selectedCategoryID = category.id
                break
            end
        end
        if not self.selectedCategoryID then
            self.selectedCategoryID = plan.categories and plan.categories[1] and plan.categories[1].id or nil
        end
    end
    self:Render()
    frame:Show()
end
