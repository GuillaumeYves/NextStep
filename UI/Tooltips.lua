local _, NS = ...

NS.UI = NS.UI or {}
local Tooltips = {}
NS.UI.Tooltips = Tooltips

local function addSpacer()
    GameTooltip:AddLine(" ")
end

local function addHeading(text)
    GameTooltip:AddLine(text, 1, 0.82, 0, false)
end

local function joinSourceTitles(sources)
    local titles = {}
    for _, source in ipairs(sources or {}) do
        if type(source.title) == "string" and source.title ~= "" then
            titles[#titles + 1] = source.title
        end
    end
    return table.concat(titles, ", ")
end

local function addMissingCriteria(criteria)
    if type(criteria) ~= "table" or #criteria == 0 then
        return
    end
    addSpacer()
    addHeading(NS.L.TASK_TOOLTIP_MISSING)
    local maximum = math.min(8, #criteria)
    for index = 1, maximum do
        GameTooltip:AddLine("• " .. criteria[index], 0.9, 0.9, 0.9, true)
    end
    if #criteria > maximum then
        GameTooltip:AddLine(string.format(NS.L.TASK_TOOLTIP_MORE, #criteria - maximum), 0.65, 0.65, 0.65)
    end
end

local function targetCanPreview(target)
    return type(target) == "table" and (
        (target.kind == "mount" and type(target.mountID) == "number")
        or (target.kind == "pet" and type(target.speciesID) == "number")
        or type(target.itemLink) == "string"
    )
end

local function addPreviewHint(target)
    if targetCanPreview(target) then
        addSpacer()
        GameTooltip:AddLine(NS.L.CTRL_CLICK_PREVIEW, 0.35, 0.8, 1, true)
    end
end

function Tooltips:ShowRecommendation(owner, recommendation, anchor)
    if not recommendation then
        return
    end
    local metadata = recommendation.metadata or {}
    local target = metadata.target or {}
    GameTooltip:SetOwner(owner, anchor or "ANCHOR_RIGHT")
    GameTooltip:SetMinimumWidth(360)
    if target.kind == "item" and target.itemLink then
        GameTooltip:SetHyperlink(target.itemLink)
        addSpacer()
        addHeading(recommendation.title or NS.L.ADDON_NAME)
    else
        GameTooltip:SetText(recommendation.title or NS.L.ADDON_NAME)
    end
    if recommendation.description then
        GameTooltip:AddLine(recommendation.description, 1, 1, 1, true)
    end
    if recommendation.reason then
        addSpacer()
        addHeading(NS.L.TASK_TOOLTIP_WHY)
        GameTooltip:AddLine(recommendation.reason, 0.9, 0.9, 0.9, true)
    end

    local progress = metadata.progress
    if progress and type(progress.current) == "number" and type(progress.total) == "number" then
        addSpacer()
        addHeading(NS.L.TASK_TOOLTIP_PROGRESS)
        GameTooltip:AddLine(string.format(
            NS.L.TASK_TOOLTIP_PROGRESS_FORMAT,
            progress.current,
            progress.total
        ), 0.45, 0.85, 1, true)
    end
    addMissingCriteria(metadata.missingCriteria)

    if type(metadata.rewardText) == "string" and metadata.rewardText ~= "" then
        addSpacer()
        addHeading(NS.L.TASK_TOOLTIP_REWARD)
        GameTooltip:AddLine(metadata.rewardText, 0.45, 0.85, 1, true)
    end

    if type(metadata.steps) == "table" and #metadata.steps > 0 then
        addSpacer()
        addHeading(NS.L.ROUTE_DETAILS_STEPS)
        for index, step in ipairs(metadata.steps) do
            GameTooltip:AddLine(index .. ". " .. step, 0.9, 0.9, 0.9, true)
        end
    end
    if target.acquisition then
        addSpacer()
        addHeading(NS.L.TASK_TOOLTIP_ACQUISITION)
        GameTooltip:AddLine(
            NS.L.ACQUISITION_LABELS[target.acquisition] or target.acquisition,
            0.9,
            0.9,
            0.9,
            true
        )
        if target.acquisition == "chance" and not target.dropRateKnown then
            GameTooltip:AddLine(NS.L.DROP_RATE_UNPUBLISHED, 0.7, 0.7, 0.7, true)
        elseif target.dropRateKnown then
            GameTooltip:AddLine(string.format(NS.L.DROP_RATE_FORMAT, target.dropRate), 0.7, 0.7, 0.7, true)
        end
    elseif metadata.chanceBased then
        addSpacer()
        GameTooltip:AddLine(NS.L.TASK_TOOLTIP_CHANCE, 1, 0.62, 0.3, true)
    end
    addPreviewHint(target)

    if metadata.patch or metadata.confidence or metadata.sources then
        addSpacer()
        if metadata.patch then
            GameTooltip:AddLine(string.format(
                NS.L.ROUTE_DETAILS_REVIEWED,
                metadata.patch,
                metadata.reviewedAt or NS.L.UNKNOWN
            ), 0.65, 0.65, 0.65, true)
        end
        if metadata.confidence then
            GameTooltip:AddLine(string.format(
                NS.L.ROUTE_DETAILS_CONFIDENCE,
                NS.L.CONFIDENCE_LABELS[metadata.confidence] or metadata.confidence
            ), 0.65, 0.65, 0.65, true)
        end
        local sources = joinSourceTitles(metadata.sources)
        if sources ~= "" then
            GameTooltip:AddLine(string.format(NS.L.ROUTE_DETAILS_SOURCES, sources), 0.65, 0.65, 0.65, true)
        end
    end
    GameTooltip:Show()
end

function Tooltips:ShowTarget(owner, recommendation)
    local target = recommendation and recommendation.metadata and recommendation.metadata.target
    if not target then
        self:ShowRecommendation(owner, recommendation)
        return
    end
    if target.itemLink then
        GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(target.itemLink)
        addSpacer()
        addHeading(NS.L.TASK_TOOLTIP_ACQUISITION)
        GameTooltip:AddLine(
            NS.L.ACQUISITION_LABELS[target.acquisition] or target.acquisition or NS.L.UNKNOWN,
            0.9,
            0.9,
            0.9,
            true
        )
        if target.acquisition == "chance" and not target.dropRateKnown then
            GameTooltip:AddLine(NS.L.DROP_RATE_UNPUBLISHED, 0.7, 0.7, 0.7, true)
        elseif target.dropRateKnown then
            GameTooltip:AddLine(string.format(NS.L.DROP_RATE_FORMAT, target.dropRate), 0.7, 0.7, 0.7, true)
        end
        addPreviewHint(target)
        GameTooltip:Show()
        return
    end
    self:ShowRecommendation(owner, recommendation)
end

function Tooltips:HandleTargetClick(target)
    if not targetCanPreview(target) or not NS.API.WoW:IsPreviewModifiedClick() then
        return false
    end

    local previewed = false
    if target.kind == "mount" and target.mountID then
        previewed = NS.API.WoW:PreviewMount(target.mountID)
    elseif target.kind == "pet" and target.speciesID then
        previewed = NS.API.WoW:PreviewPet(target.speciesID)
    elseif target.itemLink then
        previewed = NS.API.WoW:PreviewItem(target.itemLink)
    end
    if not previewed then
        NS:Print(NS.L.PREVIEW_UNAVAILABLE)
    end
    return previewed
end

function Tooltips:ShowVaultActivity(owner, activity)
    if not activity then
        return
    end
    local metadata = activity.metadata or {}
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetMinimumWidth(340)
    if metadata.rewardItemLink then
        GameTooltip:SetHyperlink(metadata.rewardItemLink)
        addSpacer()
    else
        GameTooltip:SetText(activity.name or NS.L.VAULT_PANEL_TITLE)
    end
    local status = activity.completed and NS.L.VAULT_SLOT_UNLOCKED or NS.L.VAULT_SLOT_LOCKED
    GameTooltip:AddLine(string.format(NS.L.VAULT_TOOLTIP_STATUS, status), 1, 0.82, 0, true)
    GameTooltip:AddLine(string.format(
        NS.L.VAULT_TOOLTIP_PROGRESS,
        math.min(metadata.progress or 0, metadata.threshold or 0),
        metadata.threshold or 0
    ), 0.9, 0.9, 0.9, true)
    if type(metadata.rewardItemLevel) == "number" then
        local rewardFormat = metadata.futurePreview
            and NS.L.VAULT_TOOLTIP_FUTURE_REWARD or NS.L.VAULT_TOOLTIP_REWARD
        GameTooltip:AddLine(string.format(rewardFormat, metadata.rewardItemLevel), 0.45, 0.85, 1, true)
        if metadata.rewardPreviewIsExample then
            GameTooltip:AddLine(NS.L.VAULT_TOOLTIP_EXAMPLE, 0.65, 0.65, 0.65, true)
        end
    else
        GameTooltip:AddLine(NS.L.VAULT_TOOLTIP_REWARD_UNKNOWN, 0.65, 0.65, 0.65, true)
    end
    if type(metadata.encounters) == "table" and #metadata.encounters > 0 then
        addSpacer()
        addHeading(NS.L.VAULT_TOOLTIP_ENCOUNTERS)
        for _, encounter in ipairs(metadata.encounters) do
            if type(encounter.name) == "string" and encounter.name ~= "" then
                GameTooltip:AddLine(encounter.name, 0.9, 0.9, 0.9, true)
            end
        end
    end
    if type(metadata.generatedRewardLinks) == "table" and #metadata.generatedRewardLinks > 0 then
        addSpacer()
        addHeading(NS.L.VAULT_TOOLTIP_GENERATED_REWARDS)
        for _, rewardLink in ipairs(metadata.generatedRewardLinks) do
            GameTooltip:AddLine(rewardLink, 1, 1, 1, true)
        end
    else
        addSpacer()
        GameTooltip:AddLine(NS.L.VAULT_TOOLTIP_POOL_LIMIT, 0.65, 0.65, 0.65, true)
    end
    if metadata.rewardItemLink then
        addPreviewHint({ kind = "item", itemLink = metadata.rewardItemLink })
    end
    GameTooltip:Show()
end

function Tooltips:Hide()
    GameTooltip:Hide()
    GameTooltip:SetMinimumWidth(0)
end
