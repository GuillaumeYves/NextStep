local _, NS = ...

NS.UI = NS.UI or {}
local Header = {}
NS.UI.Header = Header

function Header:Create(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", 24, -18)
    frame:SetPoint("TOPRIGHT", -54, -18)
    frame:SetHeight(66)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    frame.title:SetPoint("TOPLEFT")
    frame.title:SetText(NS.L.ADDON_NAME)
    frame.title:SetTextColor(unpack(NS.UI.Theme.COLORS.gold))

    frame.tagline = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.tagline:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -5)
    frame.tagline:SetText(NS.L.TAGLINE)
    frame.tagline:SetTextColor(unpack(NS.UI.Theme.COLORS.text))

    frame.greeting = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.greeting:SetPoint("TOPRIGHT", 0, -6)
    frame.greeting:SetJustifyH("RIGHT")

    return frame
end

function Header:Update(frame, character)
    if not frame then
        return
    end
    if character and character.name then
        frame.greeting:SetText(character.name)
    else
        frame.greeting:SetText("")
    end
end
