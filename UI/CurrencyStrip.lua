local _, NS = ...

NS.UI = NS.UI or {}
local CurrencyStrip = {}
NS.UI.CurrencyStrip = CurrencyStrip

local MAX_CURRENCIES = 5
local CELL_WIDTH = 166
local CELL_GAP = 8

local function capText(currency)
    if currency.useTotalEarnedForMaxQuantity and (currency.maxQuantity or 0) > 0 then
        return string.format(
            NS.L.CURRENCY_SEASON_CAP_SHORT,
            currency.totalEarned or 0,
            currency.maxQuantity
        )
    elseif currency.canEarnPerWeek and (currency.maxWeeklyQuantity or 0) > 0 then
        return string.format(
            NS.L.CURRENCY_WEEKLY_CAP_SHORT,
            currency.weeklyQuantity or 0,
            currency.maxWeeklyQuantity
        )
    elseif (currency.maxQuantity or 0) > 0 then
        return string.format(NS.L.CURRENCY_CAP_SHORT, currency.quantity or 0, currency.maxQuantity)
    end
    return ""
end

local function showTooltip(button)
    local currency = button.currency
    if not currency then
        return
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetMinimumWidth(300)
    if currency.currencyLink then
        GameTooltip:SetHyperlink(currency.currencyLink)
    else
        GameTooltip:SetText(currency.name or NS.L.CURRENCY_FALLBACK)
        if currency.description then
            GameTooltip:AddLine(currency.description, 0.9, 0.9, 0.9, true)
        end
    end
    if currency.useTotalEarnedForMaxQuantity and (currency.maxQuantity or 0) > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(string.format(
            NS.L.CURRENCY_SEASON_CAP_TOOLTIP,
            currency.totalEarned or 0,
            currency.maxQuantity
        ), 0.45, 0.85, 1, true)
    end
    if currency.canEarnPerWeek and (currency.maxWeeklyQuantity or 0) > 0 then
        GameTooltip:AddLine(string.format(
            NS.L.CURRENCY_WEEKLY_CAP_TOOLTIP,
            currency.weeklyQuantity or 0,
            currency.maxWeeklyQuantity
        ), 0.45, 0.85, 1, true)
    end
    GameTooltip:Show()
end

local function createCell(parent)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(CELL_WIDTH, 36)
    NS.UI.Theme:ApplyCard(button)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetSize(26, 26)
    button.icon:SetPoint("LEFT", 7, 0)
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    button.quantity = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.quantity:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 7, -2)
    button.quantity:SetPoint("RIGHT", -6, 0)
    button.quantity:SetJustifyH("LEFT")

    button.cap = button:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    button.cap:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMRIGHT", 7, 2)
    button.cap:SetPoint("RIGHT", -6, 0)
    button.cap:SetJustifyH("LEFT")

    button:SetScript("OnEnter", function(self)
        NS.UI.Theme:SetCardHovered(self, true)
        showTooltip(self)
    end)
    button:SetScript("OnLeave", function(self)
        NS.UI.Theme:SetCardHovered(self, false)
        NS.UI.Tooltips:Hide()
    end)
    return button
end

function CurrencyStrip:Create(parent)
    local frame = CreateFrame("Frame", nil, parent, "InsetFrameTemplate")
    frame:SetHeight(48)
    frame.cells = {}
    for index = 1, MAX_CURRENCIES do
        frame.cells[index] = createCell(frame)
    end
    return frame
end

function CurrencyStrip:Update(frame, currencies)
    currencies = currencies or {}
    local visible = math.min(MAX_CURRENCIES, #currencies)
    local totalWidth = visible * CELL_WIDTH + math.max(0, visible - 1) * CELL_GAP
    local availableWidth = frame:GetWidth()
    if availableWidth <= 0 then
        availableWidth = 880
    end
    local start = math.max(8, math.floor((availableWidth - totalWidth) / 2))

    for index, cell in ipairs(frame.cells) do
        local currency = currencies[index]
        cell:ClearAllPoints()
        if currency then
            cell:SetPoint("LEFT", frame, "LEFT", start + (index - 1) * (CELL_WIDTH + CELL_GAP), 0)
            cell.currency = currency
            cell.icon:SetTexture(currency.iconFileID or "Interface\\Icons\\INV_Misc_Coin_01")
            cell.quantity:SetText(NS.Util.Formatting:Number(currency.quantity, "0"))
            cell.cap:SetText(capText(currency))
            cell:Show()
        else
            cell.currency = nil
            cell:Hide()
        end
    end
    frame:SetShown(visible > 0)
end
