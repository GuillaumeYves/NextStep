local _, NS = ...

NS.Data = NS.Data or {}
local Equipment = {}
NS.Data.Equipment = Equipment

function Equipment:Collect()
    local average, equipped = NS.API.WoW:GetItemLevels()
    local items = {}
    local emptySlots = {}
    local slotsReady = true

    for _, slot in ipairs(NS.EquipmentConfig.essentialSlots) do
        local itemID, ready = NS.API.WoW:GetEquippedItemID(slot.slotID)
        slotsReady = slotsReady and ready
        local item = {
            slotID = slot.slotID,
            slotKey = slot.key,
            itemID = itemID,
        }
        items[#items + 1] = item
        if ready and not itemID then
            emptySlots[#emptySlots + 1] = item
        end
    end

    return {
        averageItemLevel = average,
        equippedItemLevel = equipped,
        items = items,
        emptySlots = emptySlots,
        upgradeEligibilityReliable = false,
    }, slotsReady or average ~= nil or equipped ~= nil
end
