local module = {}

-- ACHIEVEMENT 1 : Spider Breeding
-- Text : Spawn 15 Arachnoids in one Island.
-- Code : Spawn 15 allies in one island

local function reset_breeding()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

local function new_unit(mission, pawn)
    if module.achievement1:is_active() and mission.deployment.phase == 2 and pawn:IsPlayer() then
        module.achievement1:addProgress(1)
    end
end

function module.initialize_achievement_1(achievement, mod)
    modApi.events.onPostStartGame:subscribe(reset_breeding)
    modApi.events.onIslandLeft:subscribe(reset_breeding)
    modapiext.events.onPawnTracked:subscribe(new_unit)

    achievement.objective = 15
end

-- ACHIEVEMENT 2 : Working Together
-- Text : Area Shift 4 units at once.
-- Code : Move 4 units at once.


local function register_pushes(mission, pawn)
    if module.achievement2:is_active() and randomizer_helper.utils.is_player_turn() then
        local moved_units = module.achievement2.moved_units
        if moved_units ~= nil and not moved_units[pawn:GetId()] then
            moved_units[pawn:GetId()] = true
            module.achievement2:addProgress(1)
        end
    end
end

local function reset_pushes()
    if module.achievement2:is_active() then
        module.achievement2.moved_units = {}
        module.achievement2:resetProgress(1)
    end
end

function module.initialize_achievement_2(achievement, mod)
    modapiext.events.onPawnPositionChanged:subscribe(register_pushes)
    randomizer_helper.events.on_attack:subscribe(reset_pushes)

    achievement.objective = 4
end

-- ACHIEVEMENT 3 : Efficient Explosives
-- Text : Kill 3 Enemies with 1 shot of the Ricochet Rocket.
-- Code : Kill 3 Enemies with 1 shot.

local function register_kill(mission, pawn)
    if module.achievement3:is_active() and pawn:IsEnemy() and randomizer_helper.utils.is_player_turn() then
        module.achievement3:addProgress(1)
    end
end

local function reset_kills()
    if module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement, mod)
    modapiext.events.onPawnKilled:subscribe(register_kill)
    randomizer_helper.events.on_attack:subscribe(reset_kills)
    achievement.objective = 3
end

return module
