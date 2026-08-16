local _, NS = ...

NS.Data = NS.Data or {}
local Equipment = {}
NS.Data.Equipment = Equipment

local tierSlots = {
    head = true,
    shoulder = true,
    chest = true,
    hands = true,
    legs = true,
}

function Equipment:Collect()
    local average, equipped = NS.API.WoW:GetItemLevels()
    local items = {}
    local emptySlots = {}
    local upgradeableItems = {}
    local slotsReady = true
    local lowestItemLevel
    local lowestItem
    local classSetCounts = {}
    local classSetItems = {}
    local classSetDetectionReady = true

    for _, slot in ipairs(NS.EquipmentConfig.essentialSlots) do
        local details, ready = NS.API.WoW:GetEquippedItemDetails(slot.slotID)
        slotsReady = slotsReady and ready
        details = details or {}
        local upgradeInfo = details.upgradeInfo
        local item = {
            slotID = slot.slotID,
            slotKey = slot.key,
            itemID = details.itemID,
            itemLink = details.itemLink,
            name = details.name,
            iconFileID = details.iconFileID,
            itemLevel = details.itemLevel,
            setID = details.setID,
            classSpecific = details.classSpecific,
        }
        if type(upgradeInfo) == "table" then
            item.upgrade = {
                currentLevel = upgradeInfo.currentLevel,
                maxLevel = upgradeInfo.maxLevel,
                maxItemLevel = upgradeInfo.maxItemLevel,
                trackString = upgradeInfo.trackString,
                trackStringID = upgradeInfo.trackStringID,
                eligible = type(upgradeInfo.currentLevel) == "number"
                    and type(upgradeInfo.maxLevel) == "number"
                    and type(upgradeInfo.maxItemLevel) == "number"
                    and type(details.itemLevel) == "number"
                    and upgradeInfo.currentLevel < upgradeInfo.maxLevel
                    and details.itemLevel < upgradeInfo.maxItemLevel,
            }
        end
        items[#items + 1] = item
        if tierSlots[item.slotKey] and item.itemID and type(item.classSpecific) ~= "boolean" then
            classSetDetectionReady = false
        end
        if tierSlots[item.slotKey] and item.classSpecific and type(item.setID) == "number" then
            classSetCounts[item.setID] = (classSetCounts[item.setID] or 0) + 1
            classSetItems[item.setID] = classSetItems[item.setID] or item
        end
        if ready and not item.itemID then
            emptySlots[#emptySlots + 1] = item
        end
        if type(item.itemLevel) == "number" then
            lowestItemLevel = math.min(lowestItemLevel or item.itemLevel, item.itemLevel)
            if not lowestItem or item.itemLevel < lowestItem.itemLevel then
                lowestItem = item
            end
        end
        if item.upgrade and item.upgrade.eligible then
            upgradeableItems[#upgradeableItems + 1] = item
        end
    end

    table.sort(upgradeableItems, function(a, b)
        if a.itemLevel == b.itemLevel then
            return (a.upgrade.maxItemLevel or 0) > (b.upgrade.maxItemLevel or 0)
        end
        return (a.itemLevel or 0) < (b.itemLevel or 0)
    end)

    local classSet = { pieces = 0, requiredPieces = 4 }
    for setID, pieces in pairs(classSetCounts) do
        if pieces > classSet.pieces then
            classSet.setID = setID
            classSet.pieces = pieces
            classSet.representativeItem = classSetItems[setID]
        end
    end

    return {
        averageItemLevel = average,
        equippedItemLevel = equipped,
        items = items,
        emptySlots = emptySlots,
        upgradeableItems = upgradeableItems,
        lowestItemLevel = lowestItemLevel,
        lowestItem = lowestItem,
        classSet = classSet,
        classSetDetectionReady = slotsReady and classSetDetectionReady,
        upgradeEligibilityReliable = slotsReady,
    }, slotsReady or average ~= nil or equipped ~= nil
end
