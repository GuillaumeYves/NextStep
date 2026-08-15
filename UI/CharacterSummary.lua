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

    frame.itemLevel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.itemLevel:SetPoint("RIGHT", -14, 0)
    frame.itemLevel:SetJustifyH("RIGHT")

    return frame
end

function CharacterSummary:Update(frame, character)
    character = character or {}
    frame.name:SetText(character.name or "Character unavailable")

    local details = {}
    if character.level then
        details[#details + 1] = "Level " .. tostring(character.level)
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
