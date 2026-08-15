local _, NS = ...

NS.API = NS.API or {}
local WoW = {}
NS.API.WoW = WoW

local SafeCall = NS.Util.SafeCall

function WoW:IsInCombat()
    return InCombatLockdown and InCombatLockdown() == true
end

function WoW:GetTimestamp()
    local ok, value = SafeCall:Invoke(GetServerTime)
    if ok and type(value) == "number" then
        return value
    end
    return time()
end

function WoW:GetCharacterIdentity()
    local name = UnitName("player")
    local realm = GetRealmName()
    local level = UnitLevel("player")
    local className, _, classID = UnitClass("player")

    return {
        name = name,
        realm = realm,
        level = level,
        classID = classID,
        className = className,
    }
end

function WoW:GetMaximumPlayerLevel()
    local ok, maxLevel = SafeCall:Invoke(GetMaxLevelForPlayerExpansion)
    if ok and type(maxLevel) == "number" and maxLevel > 0 then
        return maxLevel
    end
    return nil
end

function WoW:GetSpecialization()
    if not C_SpecializationInfo or not C_SpecializationInfo.GetSpecialization then
        return nil, nil
    end

    local ok, specIndex = SafeCall:Invoke(C_SpecializationInfo.GetSpecialization)
    if not ok or type(specIndex) ~= "number" or specIndex <= 0 then
        return nil, nil
    end

    local infoOk, specID, specName = SafeCall:Invoke(C_SpecializationInfo.GetSpecializationInfo, specIndex)
    if not infoOk then
        return nil, nil
    end
    return specID, specName
end

function WoW:GetItemLevels()
    local ok, average, equipped = SafeCall:Invoke(GetAverageItemLevel)
    if not ok then
        return nil, nil
    end
    return average, equipped
end

function WoW:GetCurrencyInfo(currencyID)
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return nil, false
    end

    local ok, info = SafeCall:Invoke(C_CurrencyInfo.GetCurrencyInfo, currencyID)
    if not ok then
        return nil, false
    end
    return info, true
end

function WoW:GetWeeklyRewardActivities()
    if not C_WeeklyRewards or not C_WeeklyRewards.GetActivities then
        return {}, false
    end

    local ok, activities = SafeCall:Invoke(C_WeeklyRewards.GetActivities)
    if not ok or type(activities) ~= "table" then
        return {}, false
    end
    return activities, true
end

function WoW:IsWeeklyChestRetired()
    if not C_WeeklyRewards or not C_WeeklyRewards.IsWeeklyChestRetired then
        return nil
    end
    local ok, retired = SafeCall:Invoke(C_WeeklyRewards.IsWeeklyChestRetired)
    if ok then
        return retired
    end
    return nil
end

function WoW:HasAvailableWeeklyRewards()
    if not C_WeeklyRewards or not C_WeeklyRewards.HasAvailableRewards then
        return nil
    end
    local ok, available = SafeCall:Invoke(C_WeeklyRewards.HasAvailableRewards)
    if ok then
        return available
    end
    return nil
end

function WoW:GetWeeklyRewardTypeKey(activityType)
    local types = Enum and Enum.WeeklyRewardChestThresholdType
    if not types then
        return "unknown"
    end
    if activityType == types.Activities then
        return "dungeon"
    elseif activityType == types.Raid then
        return "raid"
    elseif activityType == types.RankedPvP then
        return "pvp"
    elseif activityType == types.World then
        return "world"
    elseif activityType == types.Concession then
        return "concession"
    end
    return "unknown"
end
