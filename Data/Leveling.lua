local _, NS = ...

NS.Data = NS.Data or {}
local Leveling = {}
NS.Data.Leveling = Leveling

function Leveling:Collect(character)
    if type(character.level) ~= "number" then
        return {
            dungeonFinderAvailable = false,
            availableDungeonCount = 0,
        }, false
    end

    local available, count, ready = NS.API.WoW:GetLevelingDungeonAvailability(character.level)
    return {
        dungeonFinderAvailable = available,
        availableDungeonCount = count,
    }, ready
end
