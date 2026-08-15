local _, NS = ...

NS.UI = NS.UI or {}
local RecommendationCard = {}
NS.UI.RecommendationCard = RecommendationCard

local colors = {
    CRITICAL = { 0.95, 0.35, 0.28 },
    HIGH = { 0.95, 0.72, 0.25 },
    USEFUL = { 0.35, 0.75, 1 },
    OPTIONAL = { 0.65, 0.68, 0.72 },
    COMPLETED = { 0.35, 0.82, 0.5 },
}

function RecommendationCard:Create(parent)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetHeight(100)
    card:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    card:SetBackdropColor(0.055, 0.065, 0.08, 0.96)
    card:SetBackdropBorderColor(0.17, 0.2, 0.24, 1)

    card.importance = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card.importance:SetPoint("TOPLEFT", 14, -10)

    card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    card.title:SetPoint("TOPLEFT", 14, -28)
    card.title:SetPoint("RIGHT", -14, 0)
    card.title:SetJustifyH("LEFT")
    card.title:SetWordWrap(false)

    card.description = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    card.description:SetPoint("TOPLEFT", 14, -47)
    card.description:SetPoint("RIGHT", -14, 0)
    card.description:SetHeight(30)
    card.description:SetJustifyH("LEFT")
    card.description:SetWordWrap(true)

    card.reason = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    card.reason:SetPoint("TOPLEFT", 14, -82)
    card.reason:SetPoint("RIGHT", -14, 0)
    card.reason:SetJustifyH("LEFT")
    card.reason:SetWordWrap(false)

    return card
end

function RecommendationCard:SetData(card, recommendation)
    local label = NS.Constants.IMPORTANCE_LABEL[recommendation.importance] or recommendation.importance
    local color = colors[recommendation.importance] or colors.USEFUL
    card.importance:SetText(label)
    card.importance:SetTextColor(color[1], color[2], color[3])
    card.title:SetText(recommendation.title or "")
    card.description:SetText(recommendation.description or "")
    card.reason:SetText(NS.L.WHY_PREFIX .. (recommendation.reason or ""))
    card:Show()
end
