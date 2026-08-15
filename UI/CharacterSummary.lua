local _, NS = ...

NS.UI = NS.UI or {}
local CharacterSummary = {}
NS.UI.CharacterSummary = CharacterSummary

function CharacterSummary:Create(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetHeight(68)
    frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    frame:SetBackdropColor(0.075, 0.09, 0.115, 0.9)

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
    frame.name:SetText(character.name or "Character unavailable")

    local details = {}
    if character.level then
        local levelText = "Level " .. tostring(character.level)
        if type(experience.percent) == "number" and character.maxLevel and character.level < character.maxLevel then
            levelText = levelText .. string.format(" (%.1f%% XP)", experience.percent)
        end
        details[#details + 1] = levelText
    end
    if character.className then
        details[#details + 1] = character.className
    end
    details[#details + 1] = character.specName or NS.L.SPECIALIZATION_UNAVAILABLE
    frame.details:SetText(table.concat(details, "  |  "))

    local equipped = NS.Util.Formatting:ItemLevel(character.equippedItemLevel)
    local average = NS.Util.Formatting:ItemLevel(character.averageItemLevel)
    frame.itemLevel:SetText("Equipped " .. equipped .. "\nAverage " .. average)
end
