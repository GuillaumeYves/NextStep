local _, NS = ...

NS.Data = NS.Data or {}
local Equipment = {}
NS.Data.Equipment = Equipment

function Equipment:Collect()
    local average, equipped = NS.API.WoW:GetItemLevels()
    return {
        averageItemLevel = average,
        equippedItemLevel = equipped,
        items = {},
        upgradeEligibilityReliable = false,
    }, average ~= nil or equipped ~= nil
end
