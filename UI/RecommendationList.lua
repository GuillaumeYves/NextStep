local _, NS = ...

NS.UI = NS.UI or {}
local RecommendationList = {}
NS.UI.RecommendationList = RecommendationList

local CARD_HEIGHT = 112
local CARD_GAP = 8

function RecommendationList:Create(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:EnableMouseWheel(true)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(1)
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    scroll.content = content
    scroll.cards = {}

    scroll:SetScript("OnSizeChanged", function(_, width)
        content:SetWidth(width)
    end)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local target = self:GetVerticalScroll() - (delta * 42)
        NS.Util.Scroll:RestoreOffset(self, target, content:GetHeight())
    end)

    return scroll
end

function RecommendationList:Update(scroll, recommendations)
    local previousOffset = scroll:GetVerticalScroll()
    local count = #recommendations
    for index, recommendation in ipairs(recommendations) do
        local card = scroll.cards[index]
        if not card then
            card = NS.UI.RecommendationCard:Create(scroll.content)
            scroll.cards[index] = card
        end
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", 0, -((index - 1) * (CARD_HEIGHT + CARD_GAP)))
        card:SetPoint("RIGHT", scroll.content, "RIGHT", 0, 0)
        NS.UI.RecommendationCard:SetData(card, recommendation)
    end

    for index = count + 1, #scroll.cards do
        scroll.cards[index]:Hide()
    end

    local contentHeight = math.max(1, count * CARD_HEIGHT + math.max(0, count - 1) * CARD_GAP)
    scroll.content:SetHeight(contentHeight)
    NS.Util.Scroll:RestoreOffset(scroll, previousOffset, contentHeight)
    scroll:SetShown(count > 0)
end
