local _, NS = ...

NS.UI = NS.UI or {}
local PatchProgress = {}
NS.UI.PatchProgress = PatchProgress

local function createBar(parent)
    local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
    bar:SetHeight(16)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    NS.UI.Theme:ApplyCard(bar)
    bar.label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bar.label:SetJustifyH("LEFT")
    bar.value = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.value:SetPoint("CENTER", 0, 0)
    bar.value:SetShadowOffset(1, -1)
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        NS.UI.Tooltips:ShowPatchProgress(self, self.progress, self.tooltipTitle)
    end)
    bar:SetScript("OnLeave", function()
        NS.UI.Tooltips:Hide()
    end)
    return bar
end

local function updateBar(bar, progress, label, tooltipTitle)
    progress = progress or {}
    local current = tonumber(progress.current) or 0
    local total = tonumber(progress.total) or 0
    bar.progress = progress
    bar.tooltipTitle = tooltipTitle
    bar.label:SetText(string.format(NS.L.PATCH_PROGRESS_LABEL_FORMAT, label, current, total))
    bar:SetMinMaxValues(0, math.max(1, total))
    bar:SetValue(math.min(current, total))
    local color = NS.UI.Theme:GetProgressColor(current, total)
    bar:SetStatusBarColor(color[1], color[2], color[3], 1)
    bar:SetBackdropBorderColor(color[1], color[2], color[3], 1)
    bar:SetBackdropColor(color[1] * 0.16, color[2] * 0.16, color[3] * 0.16, 0.95)
    if total > 0 then
        bar.value:SetText(string.format(
            NS.L.PATCH_PROGRESS_PERCENT,
            math.floor((current / total) * 100 + 0.5)
        ))
    else
        bar.value:SetText(NS.L.UNAVAILABLE)
    end
end

function PatchProgress:Create(parent)
    local frame = CreateFrame("Frame", nil, parent, "InsetFrameTemplate")
    frame:SetHeight(54)

    frame.character = createBar(frame)
    frame.character:SetPoint("BOTTOMLEFT", 12, 8)
    frame.character:SetPoint("RIGHT", frame, "CENTER", -8, 0)
    frame.character.label:SetPoint("BOTTOMLEFT", frame.character, "TOPLEFT", 0, 4)
    frame.character.label:SetPoint("RIGHT", frame.character, "RIGHT", 0, 0)

    frame.account = createBar(frame)
    frame.account:SetPoint("BOTTOMRIGHT", -12, 8)
    frame.account:SetPoint("LEFT", frame, "CENTER", 8, 0)
    frame.account.label:SetPoint("BOTTOMLEFT", frame.account, "TOPLEFT", 0, 4)
    frame.account.label:SetPoint("RIGHT", frame.account, "RIGHT", 0, 0)
    return frame
end

function PatchProgress:Update(frame, progress)
    progress = progress or {}
    updateBar(
        frame.character,
        progress.character,
        NS.L.PATCH_PROGRESS_CHARACTER,
        NS.L.PATCH_PROGRESS_CHARACTER_TOOLTIP
    )
    updateBar(
        frame.account,
        progress.account,
        NS.L.PATCH_PROGRESS_ACCOUNT,
        NS.L.PATCH_PROGRESS_ACCOUNT_TOOLTIP
    )
    frame:SetShown(progress.dataReady == true)
end
