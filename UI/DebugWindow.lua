local _, NS = ...

NS.UI = NS.UI or {}
local DebugWindow = {}
NS.UI.DebugWindow = DebugWindow

function DebugWindow:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(720, 560)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 24,
        insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 20, -18)

    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -4, -4)

    frame.scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 20, -52)
    frame.scroll:SetPoint("BOTTOMRIGHT", -42, 20)

    frame.editBox = CreateFrame("EditBox", nil, frame.scroll)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject("ChatFontNormal")
    frame.editBox:SetWidth(645)
    frame.editBox:SetHeight(480)
    frame.editBox:SetTextInsets(4, 4, 4, 4)
    frame.editBox:SetScript("OnTextChanged", function(editBox)
        local _, lines = editBox:GetText():gsub("\n", "\n")
        editBox:SetHeight(math.max(480, (lines + 2) * 15))
    end)
    frame.editBox:SetScript("OnEscapePressed", function(editBox)
        editBox:ClearFocus()
    end)
    frame.scroll:SetScrollChild(frame.editBox)

    self.frame = frame
    return frame
end

function DebugWindow:ShowText(title, text)
    self:Create()
    self.frame.title:SetText(title)
    self.frame.editBox:SetText(text or "")
    self.frame.editBox:SetCursorPosition(0)
    self.frame:Show()
end

function DebugWindow:ShowState(state)
    self:ShowText("NextStep PlayerState", NS.Util.Debug:Serialize(state, 7))
end

function DebugWindow:ShowRecommendations(trace, recommendations)
    local lines = { "RULE TRACE", "" }
    for _, entry in ipairs(trace or {}) do
        lines[#lines + 1] = string.format("%s | fired=%s | invalid=%d", entry.rule, tostring(entry.fired), entry.invalidResults or 0)
        if entry.error then
            lines[#lines + 1] = "  error: " .. entry.error
        end
        for _, id in ipairs(entry.recommendationIDs or {}) do
            lines[#lines + 1] = "  recommendation: " .. id
        end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "RECOMMENDATIONS"
    lines[#lines + 1] = ""
    for _, recommendation in ipairs(recommendations or {}) do
        lines[#lines + 1] = string.format(
            "%s | rule=%s | priority=%s | importance=%s\n  reason: %s",
            recommendation.id,
            recommendation.rule or "unknown",
            tostring(recommendation.priority),
            recommendation.importance or "unknown",
            recommendation.reason or ""
        )
    end

    self:ShowText("NextStep Recommendations", table.concat(lines, "\n"))
end
