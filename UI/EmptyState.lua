local _, NS = ...

NS.UI = NS.UI or {}
local EmptyState = {}
NS.UI.EmptyState = EmptyState

function EmptyState:Create(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    frame:SetBackdropColor(0.055, 0.065, 0.08, 0.9)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("CENTER", 0, 18)
    frame.title:SetText(NS.L.ALL_CLEAR)

    frame.message = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.message:SetPoint("TOPLEFT", 42, -105)
    frame.message:SetPoint("TOPRIGHT", -42, -105)
    frame.message:SetJustifyH("CENTER")
    frame.message:SetWordWrap(true)

    return frame
end

function EmptyState:Update(frame, message)
    frame.message:SetText(message or NS.L.FALLBACK)
end
