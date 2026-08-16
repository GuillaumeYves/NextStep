local NS = {
    API = {
        WoW = {
            GetLevelingDungeons = function(_, level)
                assert(level == 37, "Character level was not passed to the API wrapper.")
                return true, {
                    { dungeonID = 101, name = "The Stone Halls", iconID = 9001 },
                    { dungeonID = 102, name = "The Verdant Path", iconID = 9002 },
                }, true
            end,
        },
    },
    Data = {},
}

local chunk, loadError = loadfile("Data/Leveling.lua")
assert(chunk, loadError)
chunk("NextStep", NS)

local leveling, ready = NS.Data.Leveling:Collect({ level = 37 })
assert(ready == true, "Dungeon data should be marked ready.")
assert(leveling.dungeonFinderAvailable == true, "Dungeon Finder availability was lost.")
assert(leveling.availableDungeonCount == 2, "The normalized dungeon count is incorrect.")
assert(leveling.availableDungeons[1].dungeonID == 101, "The first dungeon ID was not preserved.")
assert(leveling.availableDungeons[2].name == "The Verdant Path", "The localized dungeon name was not preserved.")

print("Leveling dungeon normalization tests passed.")
