local _, NS = ...

NS.UI = NS.UI or {}
local MainWindow = {}
NS.UI.MainWindow = MainWindow

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

function MainWindow:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(640, 700)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.025, 0.03, 0.04, 0.98)
    frame:SetBackdropBorderColor(0.18, 0.22, 0.28, 1)
    frame:Hide()

    frame:SetScript("OnDragStart", function(self)
        if not NS.db.settings.lockWindow then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        MainWindow:SavePosition()
    end)

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -6, -6)

    frame.header = NS.UI.Header:Create(frame)

    frame.characterSummary = NS.UI.CharacterSummary:Create(frame)
    frame.characterSummary:SetPoint("TOPLEFT", 24, -92)
    frame.characterSummary:SetPoint("TOPRIGHT", -24, -92)

    frame.sectionTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.sectionTitle:SetPoint("TOPLEFT", 24, -178)
    frame.sectionTitle:SetText(NS.L.WHAT_MATTERS_NEXT)
    frame.sectionTitle:SetTextColor(0.62, 0.68, 0.75)

    frame.recommendationList = NS.UI.RecommendationList:Create(frame)
    frame.recommendationList:SetPoint("TOPLEFT", 24, -202)
    frame.recommendationList:SetPoint("BOTTOMRIGHT", -24, 78)

    frame.emptyState = NS.UI.EmptyState:Create(frame)
    frame.emptyState:SetPoint("TOPLEFT", 24, -202)
    frame.emptyState:SetPoint("BOTTOMRIGHT", -24, 78)

    frame.footerLine = frame:CreateTexture(nil, "ARTWORK")
    frame.footerLine:SetColorTexture(0.18, 0.22, 0.28, 1)
    frame.footerLine:SetPoint("BOTTOMLEFT", 24, 66)
    frame.footerLine:SetPoint("BOTTOMRIGHT", -24, 66)
    frame.footerLine:SetHeight(1)

    frame.summary = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.summary:SetPoint("BOTTOMLEFT", 24, 24)
    frame.summary:SetPoint("RIGHT", -220, 0)
    frame.summary:SetJustifyH("LEFT")

    frame.refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.refresh:SetSize(82, 26)
    frame.refresh:SetPoint("BOTTOMRIGHT", -112, 20)
    frame.refresh:SetText(NS.L.REFRESH)
    frame.refresh:SetScript("OnClick", function()
        NS:RequestRefresh("manual", 0)
    end)

    frame.settings = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.settings:SetSize(82, 26)
    frame.settings:SetPoint("BOTTOMRIGHT", -24, 20)
    frame.settings:SetText(NS.L.SETTINGS)
    frame.settings:SetScript("OnClick", function()
        NS.UI.Settings:Toggle()
    end)

    self.frame = frame
    self:RestorePosition()
    return frame
end

function MainWindow:BuildSummary(state)
    local vault = state.weekly and state.weekly.vault or {}
    local vaultText
    if state.vault and state.vault.dataReady then
        vaultText = string.format("Vault %d/%d", vault.completedOptions or 0, vault.totalOptions or 0)
    else
        vaultText = NS.L.VAULT_UNAVAILABLE
    end

    local currency = state.currencies and state.currencies[1]
    local currencyText = NS.L.NO_CURRENCY
    if currency then
        currencyText = string.format("%s %s", currency.name or "Currency", NS.Util.Formatting:Number(currency.quantity, "0"))
    end
    return vaultText .. "  |  " .. currencyText
end

function MainWindow:Update(state, plan)
    local frame = self:Create()
    NS.UI.Header:Update(frame.header, state.character)
    NS.UI.CharacterSummary:Update(frame.characterSummary, state.character)
    NS.UI.RecommendationList:Update(frame.recommendationList, plan.recommendations or {})
    NS.UI.EmptyState:Update(frame.emptyState, plan.fallbackMessage)
    frame.emptyState:SetShown(plan.isFallback)
    frame.summary:SetText(self:BuildSummary(state))
end

function MainWindow:Toggle()
    local frame = self:Create()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        NS:RequestRefresh("window_opened", 0)
    end
end

function MainWindow:SavePosition()
    if not self.frame or not NS.db.settings.rememberWindowPosition then
        return
    end
    local point, _, relativePoint, x, y = self.frame:GetPoint(1)
    local position = NS.db.settings.window
    position.point = point
    position.relativePoint = relativePoint
    position.x = x
    position.y = y
end

function MainWindow:RestorePosition()
    local frame = self.frame
    local position = NS.db.settings.window
    frame:ClearAllPoints()
    if NS.db.settings.rememberWindowPosition and validPoints[position.point] and validPoints[position.relativePoint] then
        frame:SetPoint(position.point, UIParent, position.relativePoint, position.x or 0, position.y or 0)
    else
        frame:SetPoint("CENTER")
    end
end

function MainWindow:ResetPosition()
    if not self.frame then
        return
    end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER")
end
