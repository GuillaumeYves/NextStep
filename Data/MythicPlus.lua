local _, NS = ...

NS.Data = NS.Data or {}
local MythicPlus = {}
NS.Data.MythicPlus = MythicPlus

function MythicPlus:Collect()
    local raw, ready = NS.API.WoW:GetMythicPlusState()
    local currentWeekRuns = {}
    local currentWeekBestLevel
    local seasonBestLevel

    for _, run in pairs((raw and raw.runs) or {}) do
        if type(run) == "table" and type(run.level) == "number" then
            seasonBestLevel = math.max(seasonBestLevel or 0, run.level)
            if run.thisWeek == true and run.completed ~= false then
                currentWeekRuns[#currentWeekRuns + 1] = {
                    mapChallengeModeID = run.mapChallengeModeID,
                    level = run.level,
                    completed = run.completed,
                }
                currentWeekBestLevel = math.max(currentWeekBestLevel or 0, run.level)
            end
        end
    end

    table.sort(currentWeekRuns, function(a, b)
        return a.level > b.level
    end)

    return {
        active = raw and raw.active == true,
        currentWeekRuns = currentWeekRuns,
        currentWeekRunCount = #currentWeekRuns,
        currentWeekBestLevel = currentWeekBestLevel,
        seasonBestLevel = seasonBestLevel,
        dataReady = ready,
    }, ready
end
