local _, NS = ...

NS.Data = NS.Data or {}
local Currency = {}
NS.Data.Currency = Currency

function Currency:Collect()
    local currencies = {}
    local capability = C_CurrencyInfo and type(C_CurrencyInfo.GetCurrencyInfo) == "function"

    for _, config in ipairs(NS.CurrencyConfig.tracked) do
        if config.enabled ~= false and type(config.currencyID) == "number" then
            local info = NS.API.WoW:GetCurrencyInfo(config.currencyID)
            if info and info.discovered ~= false then
                currencies[#currencies + 1] = {
                    currencyID = info.currencyID or config.currencyID,
                    name = info.name,
                    quantity = info.quantity,
                    maxQuantity = info.maxQuantity,
                    weeklyQuantity = info.quantityEarnedThisWeek,
                    maxWeeklyQuantity = info.maxWeeklyQuantity,
                    tracked = true,
                    description = config.description or info.description,
                    iconFileID = info.iconFileID,
                    canEarnPerWeek = info.canEarnPerWeek,
                    isAccountWide = info.isAccountWide,
                }
            end
        end
    end

    return currencies, capability and true or false
end
