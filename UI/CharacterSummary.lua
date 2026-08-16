local _, NS = ...

NS.UI = NS.UI or {}
local CharacterSummary = {}
NS.UI.CharacterSummary = CharacterSummary

function CharacterSummary:Create(parent)
    local frame = CreateFrame("Frame", nil, parent, "InsetFrameTemplate")
    frame:SetHeight(52)

    frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.name:SetPoint("LEFT", 14, 0)
    frame.name:SetJustifyH("LEFT")

    frame.details = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.details:SetPoint("LEFT", frame.name, "RIGHT", 10, 0)
    frame.details:SetPoint("RIGHT", -250, 0)
    frame.details:SetJustifyH("LEFT")
    frame.details:SetWordWrap(false)

    frame.itemLevel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.itemLevel:SetPoint("TOPRIGHT", -14, -10)
    frame.itemLevel:SetJustifyH("RIGHT")

    frame.lowest = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.lowest:SetPoint("BOTTOMRIGHT", -14, 9)
    frame.lowest:SetJustifyH("RIGHT")
    frame.lowest:SetTextColor(0.45, 0.78, 1)
    return frame
end

function CharacterSummary:Update(frame, character, experience, equipment)
    character = character or {}
    experience = experience or {}
    equipment = equipment or {}

    frame.name:SetText(character.name or NS.L.CHARACTER_UNAVAILABLE)
    local color = character.classColor or NS.UI.Theme.COLORS.gold
    frame.name:SetTextColor(color.r or color[1] or 1, color.g or color[2] or 0.82, color.b or color[3] or 0.35)
    frame.name:SetWidth(math.ceil(frame.name:GetStringWidth()) + 4)

    frame.details:ClearAllPoints()
    frame.details:SetPoint("LEFT", frame.name, "RIGHT", 10, 0)
    frame.details:SetPoint("RIGHT", -250, 0)
    local identity = {}
    if character.level then
        identity[#identity + 1] = string.format(NS.L.LEVEL_FORMAT, character.level)
    end
    identity[#identity + 1] = character.specName or NS.L.SPECIALIZATION_UNAVAILABLE
    if character.className then
        identity[#identity + 1] = character.className
    end
    if type(experience.percent) == "number" and character.maxLevel and character.level < character.maxLevel then
        identity[#identity + 1] = string.format(NS.L.XP_PROGRESS_FORMAT, experience.percent)
    end
    frame.details:SetText(table.concat(identity, " "))

    local equipped = NS.Util.Formatting:ItemLevel(character.equippedItemLevel, NS.L.UNAVAILABLE)
    frame.itemLevel:SetText(string.format(NS.L.EQUIPPED_FORMAT, equipped))

    local lowest = equipment.lowestItem
    if lowest and type(lowest.itemLevel) == "number" then
        local slotName = NS.L.SLOT_NAMES[lowest.slotKey] or lowest.slotKey or NS.L.UNKNOWN
        frame.lowest:SetText(string.format(NS.L.LOWEST_ITEM_FORMAT, lowest.itemLevel, slotName))
        frame.lowest:Show()
    else
        frame.lowest:Hide()
    end
end
