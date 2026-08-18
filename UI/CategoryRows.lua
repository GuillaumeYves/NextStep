local _, NS = ...

NS.UI = NS.UI or {}
local CategoryRows = {}
NS.UI.CategoryRows = CategoryRows

local ROW_HEIGHT = 154
local ROW_GAP = 8
local PREVIEW_COUNT = 5

local GOAL_ICONS = {
    experience = "Interface\\Icons\\INV_Misc_Book_11",
    progression = "Interface\\Icons\\INV_Misc_Map_01",
    gear = "Interface\\Icons\\INV_Chest_Chain_05",
    mounts = "Interface\\Icons\\Ability_Mount_RidingHorse",
    pets = "Interface\\Icons\\INV_Pet_Achievement_CaptureAWildPet",
    achievements = "Interface\\Icons\\Achievement_General",
}

local function firstSentence(value)
    if type(value) ~= "string" then
        return ""
    end
    return value:match("^(.-%.)%s") or value
end

local function routeSteps(recommendation)
    local steps = recommendation and recommendation.metadata and recommendation.metadata.steps
    return NS.Util.Formatting:RouteSteps(steps, 3)
        or firstSentence(recommendation and recommendation.description)
end

local function patchLabel(value)
    value = tostring(value or NS.SeasonConfig.clientVersion or "")
    return value:gsub("%.0$", "")
end

local function createArrow(parent, label)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(26, 24)
    button:SetText(label)
    local text = button:GetFontString()
    if text then
        text:ClearAllPoints()
        text:SetPoint("CENTER", 0, 1)
    end
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(label == "<" and NS.L.WIDGET_PREVIOUS or NS.L.WIDGET_NEXT)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return button
end

local updateRow

local function createRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)

    row.divider = row:CreateTexture(nil, "ARTWORK")
    row.divider:SetPoint("BOTTOMLEFT", 4, 0)
    row.divider:SetPoint("BOTTOMRIGHT", -4, 0)
    row.divider:SetHeight(1)
    row.divider:SetColorTexture(0.35, 0.27, 0.14, 0.7)

    row.categoryIconBorder = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.categoryIconBorder:SetSize(38, 38)
    row.categoryIconBorder:SetPoint("TOPLEFT", 12, -14)
    NS.UI.Theme:ApplyCard(row.categoryIconBorder)

    row.categoryIcon = row.categoryIconBorder:CreateTexture(nil, "ARTWORK")
    row.categoryIcon:SetPoint("TOPLEFT", 3, -3)
    row.categoryIcon:SetPoint("BOTTOMRIGHT", -3, 3)
    row.categoryIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    row.category = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.category:SetPoint("TOPLEFT", 58, -16)
    row.category:SetWidth(86)
    row.category:SetJustifyH("LEFT")
    row.category:SetWordWrap(true)
    row.category:SetTextColor(unpack(NS.UI.Theme.COLORS.gold))

    row.previews = {}
    for previewIndex = 1, PREVIEW_COUNT do
        local preview = CreateFrame("Button", nil, row, "BackdropTemplate")
        preview:SetSize(24, 24)
        preview:SetPoint("BOTTOMLEFT", 10 + ((previewIndex - 1) * 27), 12)
        NS.UI.Theme:ApplyCard(preview)
        preview.icon = preview:CreateTexture(nil, "ARTWORK")
        preview.icon:SetPoint("TOPLEFT", 2, -2)
        preview.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        preview.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        preview:RegisterForClicks("LeftButtonUp")
        preview:SetScript("OnEnter", function(self)
            NS.UI.Theme:SetCardHovered(self, true)
            NS.UI.Tooltips:ShowTarget(self, self.recommendation)
        end)
        preview:SetScript("OnLeave", function(self)
            NS.UI.Theme:SetCardHovered(self, false)
            if self.isCurrent and self.goalColor then
                local color = self.goalColor
                self:SetBackdropBorderColor(color[1], color[2], color[3], 1)
            end
            NS.UI.Tooltips:Hide()
        end)
        preview:SetScript("OnClick", function(self)
            local recommendation = self.recommendation
            local target = recommendation and recommendation.metadata and recommendation.metadata.target
            if NS.UI.Tooltips:HandleTargetClick(target) then
                return
            end
            if self.row and self.taskIndex then
                self.scroll.indices[self.row.categoryData.id] = self.taskIndex
                updateRow(self.row, self.row.categoryData, self.taskIndex)
            end
        end)
        row.previews[previewIndex] = preview
    end

    row.task = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.task:SetPoint("TOPLEFT", 150, -8)
    row.task:SetPoint("BOTTOMRIGHT", -72, 8)
    NS.UI.Theme:ApplyCard(row.task)
    row.task:EnableMouse(true)
    row.task.accent = row.task:CreateTexture(nil, "ARTWORK")
    row.task.accent:SetPoint("TOPLEFT", 1, -1)
    row.task.accent:SetPoint("BOTTOMLEFT", 1, 1)
    row.task.accent:SetWidth(3)
    row.task.progress = CreateFrame("StatusBar", nil, row.task, "BackdropTemplate")
    row.task.progress:SetPoint("BOTTOMLEFT", 6, 5)
    row.task.progress:SetPoint("BOTTOMRIGHT", -6, 5)
    row.task.progress:SetHeight(12)
    row.task.progress:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    NS.UI.Theme:ApplyCard(row.task.progress)
    row.task.progress.text = row.task.progress:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.task.progress.text:SetPoint("CENTER", 0, 0)
    row.task.progress.text:SetShadowOffset(1, -1)
    row.task:SetScript("OnEnter", function(self)
        NS.UI.Theme:SetCardHovered(self, true)
        NS.UI.Tooltips:ShowRecommendation(self, self.recommendation)
    end)
    row.task:SetScript("OnLeave", function(self)
        NS.UI.Theme:SetCardHovered(self, false)
        NS.UI.Tooltips:Hide()
    end)

    row.target = CreateFrame("Button", nil, row.task, "BackdropTemplate")
    row.target:SetSize(54, 54)
    row.target:SetPoint("TOPLEFT", 10, -12)
    NS.UI.Theme:ApplyCard(row.target)
    row.target.icon = row.target:CreateTexture(nil, "ARTWORK")
    row.target.icon:SetPoint("TOPLEFT", 3, -3)
    row.target.icon:SetPoint("BOTTOMRIGHT", -3, 3)
    row.target.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.target:SetScript("OnEnter", function(self)
        NS.UI.Tooltips:ShowTarget(self, self.recommendation)
    end)
    row.target:SetScript("OnLeave", function()
        NS.UI.Tooltips:Hide()
    end)
    row.target:RegisterForClicks("LeftButtonUp")
    row.target:SetScript("OnClick", function(self)
        local recommendation = self.recommendation
        local target = recommendation and recommendation.metadata and recommendation.metadata.target
        NS.UI.Tooltips:HandleTargetClick(target)
    end)

    row.acquisition = row.task:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.acquisition:SetPoint("TOP", row.target, "BOTTOM", 0, -4)
    row.acquisition:SetWidth(68)
    row.acquisition:SetJustifyH("CENTER")

    row.title = row.task:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.title:SetPoint("TOPLEFT", 74, -8)
    row.title:SetPoint("RIGHT", -10, 0)
    row.title:SetHeight(28)
    row.title:SetJustifyH("LEFT")
    row.title:SetJustifyV("TOP")
    row.title:SetWordWrap(true)

    row.step = row.task:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.step:SetPoint("TOPLEFT", 74, -38)
    row.step:SetPoint("RIGHT", -10, 0)
    row.step:SetHeight(58)
    row.step:SetJustifyH("LEFT")
    row.step:SetJustifyV("TOP")
    row.step:SetWordWrap(true)

    row.reason = row.task:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.reason:SetPoint("BOTTOMLEFT", 74, 20)
    row.reason:SetPoint("RIGHT", -10, 0)
    row.reason:SetHeight(30)
    row.reason:SetJustifyH("LEFT")
    row.reason:SetWordWrap(true)

    row.previous = createArrow(row, "<")
    row.previous:SetPoint("RIGHT", -41, 9)
    row.next = createArrow(row, ">")
    row.next:SetPoint("LEFT", row.previous, "RIGHT", 4, 0)
    row.position = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.position:SetPoint("TOPRIGHT", -14, -20)
    row.position:SetWidth(54)
    row.position:SetJustifyH("CENTER")
    return row
end

updateRow = function(row, category, index)
    local tasks = category.tasks or {}
    local count = #tasks
    index = math.max(1, math.min(index or 1, math.max(1, count)))
    row.category:SetText(category.label)
    row.categoryIcon:SetTexture(GOAL_ICONS[category.id] or "Interface\\Icons\\INV_Misc_Map_01")
    local goalColor = NS.UI.Theme.GOAL_COLORS[category.id] or NS.UI.Theme.COLORS.mutedGold
    row.categoryIconBorder:SetBackdropBorderColor(goalColor[1], goalColor[2], goalColor[3], 0.9)
    row.task.accent:SetColorTexture(goalColor[1], goalColor[2], goalColor[3], 0.9)

    local previewStart = math.max(1, math.min(index - 2, math.max(1, count - PREVIEW_COUNT + 1)))
    for previewIndex, preview in ipairs(row.previews) do
        local taskIndex = previewStart + previewIndex - 1
        local previewTask = tasks[taskIndex]
        preview.row = row
        preview.scroll = row.scroll
        preview.taskIndex = taskIndex
        preview.recommendation = previewTask
        preview.isCurrent = taskIndex == index
        preview.goalColor = goalColor
        if previewTask then
            local previewMetadata = previewTask.metadata or {}
            local previewTarget = previewMetadata.target or {}
            preview.icon:SetTexture(
                previewTarget.iconFileID
                    or previewMetadata.iconFileID
                    or GOAL_ICONS[category.id]
                    or "Interface\\Icons\\INV_Misc_QuestionMark"
            )
            if preview.isCurrent then
                preview:SetBackdropBorderColor(goalColor[1], goalColor[2], goalColor[3], 1)
            else
                preview:SetBackdropBorderColor(0.28, 0.22, 0.13, 1)
            end
            preview:Show()
        else
            preview:Hide()
        end
    end

    local task = tasks[index]
    row.task.recommendation = task
    row.target.recommendation = task
    if task then
        local metadata = task.metadata or {}
        local target = metadata.target or {}
        row.title:SetText(task.title or "")
        row.step:SetText(routeSteps(task))
        row.reason:SetText(NS.L.WHY_PREFIX .. firstSentence(task.reason))
        local progress = task.metadata and task.metadata.progress
        if progress and type(progress.current) == "number" and type(progress.total) == "number"
            and progress.total > 0 then
            row.task.progress:SetMinMaxValues(0, progress.total)
            row.task.progress:SetValue(math.min(progress.current, progress.total))
            local progressColor = NS.UI.Theme:GetProgressColor(progress.current, progress.total)
            row.task.progress:SetStatusBarColor(
                progressColor[1],
                progressColor[2],
                progressColor[3],
                1
            )
            row.task.progress:SetBackdropBorderColor(
                progressColor[1],
                progressColor[2],
                progressColor[3],
                1
            )
            row.task.progress:SetBackdropColor(
                progressColor[1] * 0.16,
                progressColor[2] * 0.16,
                progressColor[3] * 0.16,
                0.95
            )
            row.task.progress.text:SetText(string.format(
                NS.L.TASK_PROGRESS_BAR_FORMAT,
                progress.current,
                progress.total,
                math.floor((math.min(progress.current, progress.total) / progress.total) * 100 + 0.5)
            ))
            row.task.progress:Show()
        else
            row.task.progress.text:SetText("")
            row.task.progress:Hide()
        end
        row.target.icon:SetTexture(target.iconFileID or metadata.iconFileID or GOAL_ICONS[category.id])
        local badge
        local badgeColor
        if target.releaseStatus == "upcoming" then
            badge = string.format(NS.L.TARGET_UPCOMING_FORMAT, patchLabel(metadata.patch))
            badgeColor = { 0.55, 0.64, 1 }
        elseif target.releaseStatus == "new" or target.featured then
            badge = string.format(NS.L.TARGET_NEW_FORMAT, patchLabel(metadata.patch))
            badgeColor = { 1, 0.78, 0.18 }
        end
        row.acquisition:SetText(badge or "")
        local labelColor = badgeColor or goalColor
        row.acquisition:SetTextColor(labelColor[1], labelColor[2], labelColor[3])
        row.acquisition:SetShown(badge ~= nil)
    else
        row.title:SetText(NS.L.CATEGORY_NO_TASK_TITLE)
        row.step:SetText(NS.L.CATEGORY_NO_TASK_DESCRIPTION)
        row.reason:SetText(NS.L.CATEGORY_NO_TASK_REASON)
        row.task.progress:Hide()
        row.task.progress.text:SetText("")
        row.target.icon:SetTexture(GOAL_ICONS[category.id] or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.acquisition:Hide()
    end
    row.previous:SetEnabled(index > 1)
    row.next:SetEnabled(index < count)
    row.previous:Show()
    row.next:Show()
    row.position:Show()
    if count > 0 then
        row.position:SetText(string.format(NS.L.WIDGET_POSITION, index, count))
    else
        row.position:SetText(string.format(NS.L.WIDGET_POSITION, 0, 0))
    end
    row.currentIndex = index
    row.categoryData = category
end

function CategoryRows:Create(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroll:EnableMouseWheel(true)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", scroll, "TOPLEFT", 8, 0)
    scroll.content = content
    scroll.rows = {}
    scroll.indices = {}

    scroll:SetScript("OnSizeChanged", function(_, width)
        content:SetWidth(math.max(1, width - 44))
    end)
    if scroll.ScrollBar then
        scroll.ScrollBar:ClearAllPoints()
        scroll.ScrollBar:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -3, -18)
        scroll.ScrollBar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", -3, 18)
    end
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local maximum = math.max(0, content:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(maximum, self:GetVerticalScroll() - delta * 52)))
    end)
    return scroll
end

function CategoryRows:Update(scroll, categories)
    categories = categories or {}
    for index, category in ipairs(categories) do
        local row = scroll.rows[index]
        if not row then
            row = createRow(scroll.content)
            scroll.rows[index] = row
            row.scroll = scroll
            row.previous:SetScript("OnClick", function()
                local categoryID = row.categoryData.id
                scroll.indices[categoryID] = NS.Util.RecommendationNavigation:Move(
                    row.currentIndex, #row.categoryData.tasks, -1
                )
                updateRow(row, row.categoryData, scroll.indices[categoryID])
            end)
            row.next:SetScript("OnClick", function()
                local categoryID = row.categoryData.id
                scroll.indices[categoryID] = NS.Util.RecommendationNavigation:Move(
                    row.currentIndex, #row.categoryData.tasks, 1
                )
                updateRow(row, row.categoryData, scroll.indices[categoryID])
            end)
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -((index - 1) * (ROW_HEIGHT + ROW_GAP)))
        row:SetPoint("RIGHT", 0, 0)
        updateRow(row, category, scroll.indices[category.id] or 1)
        scroll.indices[category.id] = row.currentIndex
        row:Show()
    end
    for index = #categories + 1, #scroll.rows do
        scroll.rows[index]:Hide()
    end
    scroll.content:SetHeight(math.max(1, #categories * ROW_HEIGHT + math.max(0, #categories - 1) * ROW_GAP))
    scroll:SetVerticalScroll(0)
end
