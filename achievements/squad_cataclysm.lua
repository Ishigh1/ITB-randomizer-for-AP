local module = {}

-- ACHIEVEMENT 1 : Unstable Ground
-- Text : Crack 10 tiles in one mission.
-- Code : ^

local function register_crack(new_crack)
    if module.achievement1:is_active() and new_crack then
        module.achievement1:addProgress(1)
    end
end

local function reset_cracks()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement)
    randomizer_helper.events.on_tile_crack:subscribe(register_crack)
    modApi.events.onMissionStart:subscribe(reset_cracks)

    achievement.objective = 10
end

-- ACHIEVEMENT 2 : Core of the Earth
-- Text : Drop 10 Enemies into pits on one Island.
-- Code : ^


local function check_fell(mission, pawn)
    if module.achievement2:is_active() and pawn:IsEnemy() and pawn:GetPathProf() % 2 == 0 and
        Board:GetTerrain(pawn:GetSpace()) == TERRAIN_HOLE then
        module.achievement2:addProgress(1)
    end
end

local function reset_falling()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement)
    modapiext.events.onPawnKilled:subscribe(check_fell)
    modApi.events.onPostStartGame:subscribe(reset_falling)

    achievement.objective = 10
end

-- ACHIEVEMENT 3 : Miner Inconvenience
-- Text : Destroy 20 mountains in one game.
-- Code : ^

local function register_mountain_break(old_terrain, new_terrain)
    if module.achievement3:is_active() and old_terrain == TERRAIN_MOUNTAIN then
        module.achievement3:addProgress(1)
    end
end

local function reset_mountains()
    if module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement)
    randomizer_helper.events.on_terrain_change:subscribe(register_mountain_break)
    modApi.events.onPostStartGame:subscribe(reset_mountains)
    achievement.objective = 20
end

return module
