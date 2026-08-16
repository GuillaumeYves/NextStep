local _, NS = ...

NS.UI = NS.UI or {}
local RecommendationCard = {}
NS.UI.RecommendationCard = RecommendationCard

function RecommendationCard:Create(parent)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetHeight(112)
    card:EnableMouse(true)
    NS.UI.Theme:ApplyCard(card)

    card.accent = card:CreateTexture(nil, "ARTWORK")
    card.accent:SetPoint("TOPLEFT", 1, -1)
    card.accent:SetPoint("BOTTOMLEFT", 1, 1)
    card.accent:SetWidth(3)

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
    card.description:SetHeight(34)
    card.description:SetJustifyH("LEFT")
    card.description:SetWordWrap(true)

    card.reason = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    card.reason:SetPoint("TOPLEFT", 14, -86)
    card.reason:SetPoint("RIGHT", -14, 0)
    card.reason:SetHeight(20)
    card.reason:SetJustifyH("LEFT")
    card.reason:SetWordWrap(true)

    card:SetScript("OnEnter", function(self)
        NS.UI.Theme:SetCardHovered(self, true)
        NS.UI.Tooltips:ShowRecommendation(self, self.recommendation)
    end)
    card:SetScript("OnLeave", function()
        NS.UI.Theme:SetCardHovered(card, false)
        NS.UI.Tooltips:Hide()
    end)

    return card
end

function RecommendationCard:SetData(card, recommendation)
    card.recommendation = recommendation
    local label = NS.L.IMPORTANCE_LABELS[recommendation.importance] or recommendation.importance
    local color = NS.UI.Theme.IMPORTANCE_COLORS[recommendation.importance]
        or NS.UI.Theme.IMPORTANCE_COLORS.USEFUL
    card.importance:SetText(label)
    card.importance:SetTextColor(color[1], color[2], color[3])
    card.accent:SetColorTexture(color[1], color[2], color[3], 0.9)
    card.title:SetText(recommendation.title or "")
    card.description:SetText(recommendation.description or "")
    card.reason:SetText(NS.L.WHY_PREFIX .. (recommendation.reason or ""))
    card:Show()
end
