local _, NS = ...

NS.UI = NS.UI or {}
local Header = {}
NS.UI.Header = Header

function Header:Create(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", 74, -28)
    frame:SetPoint("TOPRIGHT", -42, -28)
    frame:SetHeight(22)

    frame.tagline = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.tagline:SetPoint("LEFT")
    frame.tagline:SetText(NS.L.TAGLINE)
    frame.tagline:SetTextColor(unpack(NS.UI.Theme.COLORS.mutedText))
    return frame
end

function Header:Update()
end
