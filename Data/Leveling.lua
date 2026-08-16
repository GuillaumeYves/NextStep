local _, NS = ...

NS.Data = NS.Data or {}
local Leveling = {}
NS.Data.Leveling = Leveling

function Leveling:Collect(character)
    if type(character.level) ~= "number" then
        return {
            dungeonFinderAvailable = false,
            availableDungeonCount = 0,
            availableDungeons = {},
        }, false
    end

    local available, dungeons, ready = NS.API.WoW:GetLevelingDungeons(character.level)
    dungeons = type(dungeons) == "table" and dungeons or {}
    return {
        dungeonFinderAvailable = available,
        availableDungeonCount = #dungeons,
        availableDungeons = dungeons,
    }, ready
end
