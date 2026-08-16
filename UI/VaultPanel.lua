local _, NS = ...

NS.UI = NS.UI or {}
local VaultPanel = {}
NS.UI.VaultPanel = VaultPanel

local TYPE_ORDER = { "raid", "dungeon", "world" }
local CATEGORY_ATLASES = {
    raid = "evergreen-weeklyrewards-category-raids",
    dungeon = "evergreen-weeklyrewards-category-dungeons",
    world = "evergreen-weeklyrewards-category-world",
    pvp = "evergreen-weeklyrewards-category-pvp",
    concession = "evergreen-weeklyrewards-category-world",
    unknown = "evergreen-weeklyrewards-category-world",
}

local function createSlot(parent)
    local slot = CreateFrame("Button", nil, parent)
    slot:SetSize(196, 108)
    slot:EnableMouse(true)

    slot.background = slot:CreateTexture(nil, "BACKGROUND")
    slot.background:SetAllPoints()
    slot.background:SetAtlas("evergreen-weeklyrewards-reward-locked", false)

    slot.hover = slot:CreateTexture(nil, "BORDER")
    slot.hover:SetAllPoints()
    slot.hover:SetAtlas("evergreen-weeklyrewards-reward-selected", false)
    slot.hover:SetAlpha(0.55)
    slot.hover:Hide()

    slot.check = slot:CreateTexture(nil, "OVERLAY")
    slot.check:SetAtlas("activities-icon-checkmark", true)
    slot.check:SetPoint("TOPRIGHT", -8, -7)

    slot.rewardIconBorder = CreateFrame("Frame", nil, slot, "BackdropTemplate")
    slot.rewardIconBorder:SetSize(42, 42)
    slot.rewardIconBorder:SetPoint("LEFT", 12, -5)
    NS.UI.Theme:ApplyCard(slot.rewardIconBorder)
    slot.rewardIcon = slot.rewardIconBorder:CreateTexture(nil, "ARTWORK")
    slot.rewardIcon:SetPoint("TOPLEFT", 3, -3)
    slot.rewardIcon:SetPoint("BOTTOMRIGHT", -3, 3)
    slot.rewardIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    slot.lockIcon = slot:CreateTexture(nil, "ARTWORK")
    slot.lockIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-LOCK")
    slot.lockIcon:SetSize(22, 22)
    slot.lockIcon:SetPoint("TOPRIGHT", -10, -9)

    slot.requirement = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slot.requirement:SetPoint("TOPLEFT", 62, -15)
    slot.requirement:SetPoint("RIGHT", -36, 0)
    slot.requirement:SetJustifyH("LEFT")

    slot.reward = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.reward:SetPoint("TOPLEFT", 62, -43)
    slot.reward:SetPoint("RIGHT", -36, 0)
    slot.reward:SetJustifyH("LEFT")

    slot.progress = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.progress:SetPoint("BOTTOMRIGHT", -9, 7)

    slot:SetScript("OnEnter", function(self)
        self.hover:Show()
        NS.UI.Tooltips:ShowVaultActivity(self, self.activity)
    end)
    slot:SetScript("OnLeave", function(self)
        self.hover:Hide()
        NS.UI.Tooltips:Hide()
    end)
    slot:RegisterForClicks("LeftButtonUp")
    slot:SetScript("OnClick", function(self)
        local metadata = self.activity and self.activity.metadata or {}
        NS.UI.Tooltips:HandleTargetClick({
            kind = "item",
            itemLink = metadata.rewardItemLink,
        })
    end)
    return slot
end

local function createRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", 27, -8 - ((index - 1) * 116))
    row:SetPoint("RIGHT", -27, 0)
    row:SetHeight(108)

    row.category = CreateFrame("Frame", nil, row)
    row.category:SetSize(210, 108)
    row.category:SetPoint("LEFT", 0, 0)
    row.category.art = row.category:CreateTexture(nil, "BACKGROUND")
    row.category.art:SetAllPoints()
    row.category.art:SetAtlas("evergreen-weeklyrewards-category-world", false)
    row.category.art:SetAlpha(0.72)
    row.category.label = row.category:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    row.category.label:SetPoint("LEFT", 18, 0)
    row.category.label:SetWidth(174)
    row.category.label:SetWordWrap(true)
    row.category.label:SetTextColor(1, 0.82, 0.15)
    row.category.label:SetShadowOffset(1, -1)

    row.slots = {}
    for slotIndex = 1, 3 do
        local slot = createSlot(row)
        slot:SetPoint("LEFT", 220 + ((slotIndex - 1) * 202), 0)
        row.slots[slotIndex] = slot
    end
    return row
end

function VaultPanel:Create(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetHeight(356)
    NS.UI.Theme:ApplyInset(frame)

    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetPoint("TOPLEFT", 2, -2)
    frame.background:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.background:SetAtlas("ui-frame-midnight-backgroundtile", false)
    frame.background:SetHorizTile(true)
    frame.background:SetVertTile(true)
    frame.background:SetAlpha(0.78)

    frame.dividers = {}
    for dividerIndex = 1, 2 do
        local divider = frame:CreateTexture(nil, "ARTWORK")
        divider:SetAtlas("evergreen-weeklyrewards-divider", false)
        divider:SetPoint("TOPLEFT", frame, "TOPLEFT", 27, -120 - ((dividerIndex - 1) * 116))
        divider:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -27, -120 - ((dividerIndex - 1) * 116))
        divider:SetHeight(8)
        frame.dividers[dividerIndex] = divider
    end

    frame.message = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.message:SetPoint("CENTER", 0, -12)
    frame.message:SetText(NS.L.VAULT_UNAVAILABLE)

    frame.rows = {}
    for index = 1, 3 do
        frame.rows[index] = createRow(frame, index)
    end
    return frame
end

local function updateSlot(slot, activity)
    local metadata = activity.metadata or {}
    local threshold = math.max(1, metadata.threshold or 0)
    local progress = math.min(metadata.progress or 0, metadata.threshold or 0)
    slot.activity = activity
    slot.background:SetAtlas(
        activity.completed and "evergreen-weeklyrewards-reward-unlocked"
            or "evergreen-weeklyrewards-reward-locked",
        false
    )
    slot.check:SetShown(activity.completed)
    slot.lockIcon:SetShown(not activity.completed)
    slot.rewardIconBorder:SetShown(activity.completed and metadata.rewardIconFileID ~= nil)
    if metadata.rewardIconFileID then
        slot.rewardIcon:SetTexture(metadata.rewardIconFileID)
    end
    slot.requirement:ClearAllPoints()
    slot.reward:ClearAllPoints()
    if activity.completed and metadata.rewardIconFileID then
        slot.requirement:SetPoint("TOPLEFT", 62, -15)
        slot.reward:SetPoint("TOPLEFT", 62, -43)
    else
        slot.requirement:SetPoint("TOPLEFT", 14, -17)
        slot.reward:SetPoint("TOPLEFT", 14, -43)
    end
    slot.requirement:SetPoint("RIGHT", -36, 0)
    slot.reward:SetPoint("RIGHT", -36, 0)
    slot.requirement:SetText(string.format(NS.L.VAULT_SLOT_TARGET, threshold))
    slot.progress:SetText(string.format(NS.L.VAULT_SLOT_PROGRESS, progress, metadata.threshold or 0))
    slot.progress:SetTextColor(activity.completed and 0.25 or 0.65, activity.completed and 1 or 0.65, 0.25)

    if type(metadata.rewardItemLevel) == "number" then
        local rewardFormat = metadata.futurePreview
            and NS.L.VAULT_SLOT_FUTURE_REWARD or NS.L.VAULT_SLOT_CURRENT_REWARD
        slot.reward:SetText(string.format(rewardFormat, metadata.rewardItemLevel))
        slot.reward:SetTextColor(metadata.aboveCurrentCeiling and 1 or 0.52, 0.78, 1)
    else
        slot.reward:SetText(NS.L.VAULT_SLOT_REWARD_UNKNOWN)
        slot.reward:SetTextColor(0.62, 0.62, 0.62)
    end
    slot:Show()
end

function VaultPanel:Update(frame, vault)
    vault = vault or {}
    if not vault.dataReady then
        frame.message:SetText(NS.L.VAULT_UNAVAILABLE)
        frame.message:Show()
        for _, row in ipairs(frame.rows) do
            row:Hide()
        end
        for _, divider in ipairs(frame.dividers) do
            divider:Hide()
        end
        return
    end

    local grouped = {}
    for _, activity in ipairs(vault.activities or {}) do
        local key = activity.metadata and activity.metadata.vaultTypeKey or "unknown"
        grouped[key] = grouped[key] or {}
        grouped[key][#grouped[key] + 1] = activity
    end
    for _, activities in pairs(grouped) do
        table.sort(activities, function(a, b)
            return (a.metadata.index or 0) < (b.metadata.index or 0)
        end)
    end

    local visible = 0
    for _, key in ipairs(TYPE_ORDER) do
        local activities = grouped[key]
        if activities and #activities > 0 and visible < 3 then
            visible = visible + 1
            local row = frame.rows[visible]
            row.category.art:SetAtlas(CATEGORY_ATLASES[key] or CATEGORY_ATLASES.unknown, false)
            row.category.label:SetText(NS.L.VAULT_CATEGORY_LABELS[key] or NS.L.VAULT_CATEGORY_LABELS.unknown)
            row:Show()
            for slotIndex, slot in ipairs(row.slots) do
                local activity = activities[slotIndex]
                if activity then
                    updateSlot(slot, activity)
                else
                    slot.activity = nil
                    slot:Hide()
                end
            end
        end
    end

    for index = visible + 1, #frame.rows do
        frame.rows[index]:Hide()
    end
    for index, divider in ipairs(frame.dividers) do
        divider:SetShown(index < visible)
    end
    frame.message:SetShown(visible == 0)
    if visible == 0 then
        frame.message:SetText(NS.L.VAULT_NO_OPTIONS)
    end
end
