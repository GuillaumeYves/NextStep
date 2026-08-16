local _, NS = ...

NS.UI = NS.UI or {}
local Theme = {}
NS.UI.Theme = Theme

Theme.COLORS = {
    gold = { 1, 0.82, 0.35 },
    mutedGold = { 0.72, 0.57, 0.28 },
    text = { 0.92, 0.86, 0.72 },
    mutedText = { 0.64, 0.6, 0.52 },
    panel = { 0.055, 0.045, 0.035, 0.96 },
    inset = { 0.025, 0.022, 0.018, 0.94 },
}

Theme.IMPORTANCE_COLORS = {
    CRITICAL = { 1, 0.34, 0.24 },
    HIGH = { 1, 0.78, 0.24 },
    USEFUL = { 0.36, 0.72, 1 },
    OPTIONAL = { 0.7, 0.7, 0.7 },
    COMPLETED = { 0.36, 0.82, 0.45 },
}

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
end

function Theme:ApplyInset(frame)
    frame:SetBackdrop(insetBackdrop)
    frame:SetBackdropColor(unpack(self.COLORS.inset))
    frame:SetBackdropBorderColor(0.32, 0.25, 0.14, 1)
end

function Theme:ApplyCard(frame)
    frame:SetBackdrop(insetBackdrop)
    frame:SetBackdropColor(unpack(self.COLORS.panel))
    frame:SetBackdropBorderColor(0.28, 0.22, 0.13, 1)
end
