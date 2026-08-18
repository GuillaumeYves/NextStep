local _, NS = ...

NS.UI = NS.UI or {}
local MainWindow = {}
NS.UI.MainWindow = MainWindow

local validPoints = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true,
    RIGHT = true, BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}

function MainWindow:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "PortraitFrameTemplate")
    frame:SetSize(940, 920)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()

    if frame.TitleContainer and frame.TitleContainer.TitleText then
        frame.TitleContainer.TitleText:SetText(NS.L.ADDON_NAME)
    end
    if frame.PortraitContainer and frame.PortraitContainer.portrait then
        frame.PortraitContainer.portrait:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    elseif frame.portrait then
        frame.portrait:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    end

    frame:SetScript("OnDragStart", function(self)
        if not NS.db.settings.lockWindow then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        MainWindow:SavePosition()
    end)

    frame.header = NS.UI.Header:Create(frame)

    frame.content = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    frame.content:SetPoint("TOPLEFT", 4, -55)
    frame.content:SetPoint("BOTTOMRIGHT", -6, 6)

    frame.characterSummary = NS.UI.CharacterSummary:Create(frame.content)
    frame.characterSummary:SetPoint("TOPLEFT", 12, -10)
    frame.characterSummary:SetPoint("TOPRIGHT", -12, -10)

    frame.currencies = NS.UI.CurrencyStrip:Create(frame.content)
    frame.currencies:SetPoint("TOPLEFT", 12, -68)
    frame.currencies:SetPoint("TOPRIGHT", -12, -68)

    frame.vault = NS.UI.VaultPanel:Create(frame.content)
    frame.vault:SetPoint("TOPLEFT", 12, -124)
    frame.vault:SetPoint("TOPRIGHT", -12, -124)

    frame.reset = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.reset:SetPoint("TOPLEFT", 16, -488)
    frame.reset:SetPoint("RIGHT", -16, 0)
    frame.reset:SetJustifyH("LEFT")

    frame.patchProgress = NS.UI.PatchProgress:Create(frame.content)
    frame.patchProgress:SetPoint("TOPLEFT", 12, -508)
    frame.patchProgress:SetPoint("TOPRIGHT", -12, -508)

    frame.categories = NS.UI.CategoryRows:Create(frame.content)
    frame.categories:SetPoint("TOPLEFT", 18, -570)
    frame.categories:SetPoint("BOTTOMRIGHT", -18, 42)

    frame.footerLine = frame.content:CreateTexture(nil, "ARTWORK")
    frame.footerLine:SetColorTexture(0.42, 0.32, 0.16, 1)
    frame.footerLine:SetPoint("BOTTOMLEFT", 14, 36)
    frame.footerLine:SetPoint("BOTTOMRIGHT", -14, 36)
    frame.footerLine:SetHeight(1)

    frame.refresh = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
    frame.refresh:SetSize(82, 24)
    frame.refresh:SetPoint("BOTTOMRIGHT", -100, 6)
    frame.refresh:SetText(NS.L.REFRESH)
    frame.refresh:SetScript("OnClick", function()
        NS:RequestRefresh("manual", 0)
    end)

    frame.settings = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
    frame.settings:SetSize(82, 24)
    frame.settings:SetPoint("BOTTOMRIGHT", -12, 6)
    frame.settings:SetText(NS.L.SETTINGS)
    frame.settings:SetScript("OnClick", function()
        NS.UI.Settings:Toggle()
    end)

    self.frame = frame
    self:RestorePosition()
    return frame
end

function MainWindow:BuildResetText(state)
    local reset = state.weekly and state.weekly.reset or {}
    local progression = state.progression or {}
    local phase = NS.L.SEASON_PHASE_UNKNOWN
    if progression.seasonPhase == "preseason" then
        phase = NS.L.SEASON_PHASE_PRESEASON
    elseif progression.seasonPhase == "active" then
        phase = NS.L.SEASON_PHASE_ACTIVE
    end
    if not reset.dataReady or type(reset.resetAt) ~= "number" then
        return phase .. "  " .. NS.L.WEEKLY_RESET_UNAVAILABLE
    end
    return string.format(
        NS.L.WEEKLY_RESET_FORMAT,
        phase,
        date("%Y-%m-%d %H:%M", reset.resetAt),
        reset.regionName or NS.L.UNKNOWN
    )
end

function MainWindow:Update(state, plan)
    local frame = self:Create()
    NS.UI.Header:Update(frame.header, state.character)
    NS.UI.CharacterSummary:Update(frame.characterSummary, state.character, state.experience, state.equipment)
    NS.UI.CurrencyStrip:Update(frame.currencies, state.currencies)
    NS.UI.VaultPanel:Update(frame.vault, state.vault)
    NS.UI.PatchProgress:Update(frame.patchProgress, state.patchProgress)
    NS.UI.CategoryRows:Update(frame.categories, plan.categories)
    frame.reset:SetText(self:BuildResetText(state))
end

function MainWindow:Toggle()
    local frame = self:Create()
    if frame:IsShown() then frame:Hide() else self:Show() end
end

function MainWindow:Show()
    local frame = self:Create()
    frame:Show()
    frame:Raise()
    NS:RequestRefresh("window_opened", 0)
end

function MainWindow:SavePosition()
    if not self.frame or not NS.db.settings.rememberWindowPosition then return end
    local point, _, relativePoint, x, y = self.frame:GetPoint(1)
    local position = NS.db.settings.window
    position.point, position.relativePoint, position.x, position.y = point, relativePoint, x, y
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
    if not self.frame then return end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER")
end
