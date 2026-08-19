local _, NS = ...

NS.UI = NS.UI or {}
local Theme = {}
NS.UI.Theme = Theme

Theme.COLORS = {
    gold = { 1, 0.82, 0.35 },
    mutedGold = { 0.72, 0.57, 0.28 },
    text = { 0.92, 0.86, 0.72 },
    mutedText = { 0.64, 0.6, 0.52 },
    panel = { 0.045, 0.052, 0.065, 0.96 },
    inset = { 0.018, 0.022, 0.03, 0.96 },
    hover = { 0.075, 0.09, 0.12, 0.98 },
}

Theme.GOAL_COLORS = {
    experience = { 0.35, 0.78, 1 },
    progression = { 0.34, 0.76, 0.68 },
    gear = { 0.78, 0.48, 1 },
    mounts = { 1, 0.66, 0.25 },
    pets = { 0.38, 0.84, 0.48 },
    achievements = { 0.95, 0.72, 0.24 },
}

Theme.IMPORTANCE_COLORS = {
    CRITICAL = { 1, 0.34, 0.24 },
    HIGH = { 1, 0.78, 0.24 },
    USEFUL = { 0.36, 0.72, 1 },
    OPTIONAL = { 0.7, 0.7, 0.7 },
    COMPLETED = { 0.36, 0.82, 0.45 },
}

Theme.PROGRESS_COLORS = {
    low = { 0.88, 0.18, 0.16 },
    mediumLow = { 1, 0.48, 0.10 },
    mediumHigh = { 1, 0.82, 0.12 },
    high = { 0.24, 0.82, 0.32 },
    unavailable = { 0.42, 0.42, 0.42 },
}

function Theme:GetProgressColor(current, total)
    current = tonumber(current) or 0
    total = tonumber(total) or 0
    if total <= 0 then
        return self.PROGRESS_COLORS.unavailable
    end
    local ratio = math.max(0, math.min(1, current / total))
    if ratio < 0.25 then
        return self.PROGRESS_COLORS.low
    elseif ratio < 0.5 then
        return self.PROGRESS_COLORS.mediumLow
    elseif ratio < 0.75 then
        return self.PROGRESS_COLORS.mediumHigh
    end
    return self.PROGRESS_COLORS.high
end

local windowBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 24,
    insets = { left = 7, right = 7, top = 7, bottom = 7 },
}

local insetBackdrop = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

function Theme:ApplyWindow(frame)
    frame:SetBackdrop(windowBackdrop)
    frame:SetBackdropColor(0.06, 0.05, 0.04, 0.98)
    frame:SetBackdropBorderColor(0.72, 0.56, 0.28, 1)
    self:AddMidnightBackground(frame)
end

function Theme:AddMidnightBackground(frame)
    if frame.nextStepMidnightBackground then
        return frame.nextStepMidnightBackground
    end
    local background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    background:SetPoint("TOPLEFT", 8, -8)
    background:SetPoint("BOTTOMRIGHT", -8, 8)
    background:SetAtlas("ui-frame-midnight-backgroundtile", false)
    background:SetHorizTile(true)
    background:SetVertTile(true)
    background:SetAlpha(0.9)
    frame.nextStepMidnightBackground = background
    return background
end

function Theme:AddDivider(parent, left, right, y)
    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetAtlas("evergreen-weeklyrewards-divider", false)
    divider:SetPoint("LEFT", left or 12, y or 0)
    divider:SetPoint("RIGHT", right or -12, y or 0)
    divider:SetHeight(4)
    return divider
end

function Theme:ApplyProgressBar(bar)
    if bar.nextStepProgressBackground then
        return
    end

    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

    local background = bar:CreateTexture(nil, "BACKGROUND", nil, -1)
    background:SetAllPoints()
    background:SetColorTexture(0.04, 0.07, 0.18, 0.96)

    local borderLeft = bar:CreateTexture(nil, "ARTWORK")
    borderLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
    borderLeft:SetSize(9, 22)
    borderLeft:SetTexCoord(0.007843, 0.043137, 0.193548, 0.774193)
    borderLeft:SetPoint("LEFT", -3, 0)

    local borderRight = bar:CreateTexture(nil, "ARTWORK")
    borderRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
    borderRight:SetSize(9, 22)
    borderRight:SetTexCoord(0.043137, 0.007843, 0.193548, 0.774193)
    borderRight:SetPoint("RIGHT", 3, 0)

    local borderMiddle = bar:CreateTexture(nil, "ARTWORK")
    borderMiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
    borderMiddle:SetTexCoord(0.113726, 0.1490196, 0.193548, 0.774193)
    borderMiddle:SetPoint("TOPLEFT", borderLeft, "TOPRIGHT")
    borderMiddle:SetPoint("BOTTOMRIGHT", borderRight, "BOTTOMLEFT")

    bar.nextStepProgressBackground = background
    bar.nextStepProgressBorder = { borderLeft, borderMiddle, borderRight }
end

function Theme:AddTopBand(frame, height)
    if frame.nextStepTopBand then
        return frame.nextStepTopBand
    end
    local band = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    band:SetPoint("TOPLEFT", 8, -8)
    band:SetPoint("TOPRIGHT", -8, -8)
    band:SetHeight(height or 64)
    band:SetColorTexture(0.12, 0.09, 0.045, 0.72)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT", band, "BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT", band, "BOTTOMRIGHT")
    line:SetHeight(1)
    line:SetColorTexture(0.7, 0.52, 0.23, 0.85)
    frame.nextStepTopBand = band
    return band
end

function Theme:ApplyInset(frame)
    frame:SetBackdrop(insetBackdrop)
    frame:SetBackdropColor(unpack(self.COLORS.inset))
    frame:SetBackdropBorderColor(0.25, 0.22, 0.17, 1)
end

function Theme:ApplyCard(frame)
    frame:SetBackdrop(insetBackdrop)
    frame:SetBackdropColor(unpack(self.COLORS.panel))
    frame:SetBackdropBorderColor(0.24, 0.21, 0.16, 1)
end

function Theme:SetCardHovered(frame, hovered)
    if hovered then
        frame:SetBackdropColor(unpack(self.COLORS.hover))
        frame:SetBackdropBorderColor(0.76, 0.62, 0.34, 1)
    else
        self:ApplyCard(frame)
    end
end
