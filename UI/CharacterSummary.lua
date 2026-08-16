local _, NS = ...

NS.UI = NS.UI or {}
local CharacterSummary = {}
NS.UI.CharacterSummary = CharacterSummary

function CharacterSummary:Create(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetHeight(68)
    NS.UI.Theme:ApplyInset(frame)

    frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.name:SetPoint("TOPLEFT", 14, -12)

    frame.details = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.details:SetPoint("TOPLEFT", frame.name, "BOTTOMLEFT", 0, -8)
    frame.details:SetPoint("RIGHT", -165, 0)
    frame.details:SetJustifyH("LEFT")
    frame.details:SetWordWrap(false)

    frame.itemLevel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.itemLevel:SetPoint("RIGHT", -14, 0)
    frame.itemLevel:SetJustifyH("RIGHT")

    return frame
end

function CharacterSummary:Update(frame, character, experience)
    character = character or {}
    experience = experience or {}
    frame.name:SetText(character.name or NS.L.CHARACTER_UNAVAILABLE)

    local details = {}
    if character.level then
        local levelText = string.format(NS.L.LEVEL_FORMAT, character.level)
        if type(experience.percent) == "number" and character.maxLevel and character.level < character.maxLevel then
            levelText = levelText .. string.format(NS.L.XP_PROGRESS_FORMAT, experience.percent)
        end
        details[#details + 1] = levelText
    end
    if character.className then
        details[#details + 1] = character.className
    end
    details[#details + 1] = character.specName or NS.L.SPECIALIZATION_UNAVAILABLE
    frame.details:SetText(table.concat(details, "  |  "))

    local equipped = NS.Util.Formatting:ItemLevel(character.equippedItemLevel, NS.L.UNAVAILABLE)
    local average = NS.Util.Formatting:ItemLevel(character.averageItemLevel, NS.L.UNAVAILABLE)
    frame.itemLevel:SetText(string.format(NS.L.EQUIPPED_FORMAT, equipped)
        .. "\n" .. string.format(NS.L.AVERAGE_FORMAT, average))
end
