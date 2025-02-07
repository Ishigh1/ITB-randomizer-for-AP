local module = {}

-- ACHIEVEMENT 1 : Watery Grave
-- Text : Drown 3 enemies in water in a single battle with the Rift Walkers squad
-- Code : Kill 3 enemies that could drown when they are in water

local function check_drowned(mission, pawn)
    if module.achievement1:is_active() and pawn:IsEnemy() and pawn:GetPathProf() %
        4 == 0 and Board:GetTerrain(pawn:GetSpace()) == TERRAIN_WATER then
        module.achievement1:addProgress(1)
    end
end

local function reset_drowned()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement)
    achievement.objective = 3
    modApi.events.onMissionStart:subscribe(reset_drowned)
    modapiext.events.onPawnKilled:subscribe(check_drowned)
end

-- ACHIEVEMENT 2 : Ramming Speed
-- Text : Kill an enemy 5 or more tiles away with a Dash Punch with the Rift Walkers squad
-- Code : Move 4+ tiles and kill an enemy further away

local function save_position(mission, pawn, weapon_id, p1, p2)
    if module.achievement2:is_active() then
        module.ramming = {
            pos = p1,
            id = pawn:GetId()
        }
    end
end

local function check_dash(mission, pawn)
    if module.achievement2:is_active() and module.ramming ~= nil and
        pawn:IsEnemy() and randomizer_helper.utils.is_player_turn(mission) then
        local unit_position = module.ramming.pos
        local new_position = Board:GetPawn(module.ramming.id):GetSpace()
        local unit_move_distance = math.abs(new_position.x - unit_position.x) +
            math.abs(new_position.y - unit_position.y)
        if unit_move_distance >= 4 then
            local enemy_position = pawn:GetSpace()
            local enemy_distance = math.abs(enemy_position.x - unit_position.x) +
                math.abs(enemy_position.y - unit_position.y)
            if enemy_distance > unit_move_distance then
                module.achievement2:addProgress(true)
            end
        end
    end
end

function module.initialize_achievement_2(achievement)
    achievement.objective = true
    randomizer_helper.events.on_attack:subscribe(save_position)
    modapiext.events.onPawnKilled:subscribe(check_dash)
end

-- ACHIEVEMENT 3 : Island Secure
-- Text : Complete 1st Corporate Island with the Rift Walkers squad
-- Code : Complete any Island with the Rift Walkers squad

function module.initialize_achievement_3(achievement)
    modApi.events.onIslandLeft:subscribe(function(island)
        if module.achievement3:is_active() then
            module.achievement3:addProgress(true)
        end
    end)
    achievement.objective = true
end

return module
