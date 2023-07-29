local module = {}

-- ACHIEVEMENT 1
-- Text : Drown 3 enemies in water in a single battle with the Rift Walkers squad
-- Code : Kill 3 enemies that could drown when they are in water

local function check_drowned(mission, pawn)
    if module.achievement1:is_active() and pawn:IsEnemy() and pawn:GetPathProf() %
        3 == 0 and Board:GetTerrain(pawn:GetSpace()) == TERRAIN_WATER then
            module.achievement1:addProgress(1)
    end
end

local function reset_drowned()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = 3
    modApi.events.onMissionStart:subscribe(reset_drowned)
    modapiext.events.onPawnKilled:subscribe(check_drowned)
end

-- ACHIEVEMENT 2
-- Text : Kill an enemy 5 or more tiles away with a Dash Punch with the Rift Walkers squad
-- Code : Kill an enemy while having moved 5+ tiles this action, doesn't have to be with Dash Punch

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
        pawn:IsEnemy() and Game:GetTeamTurn() == TEAM_PLAYER then
        local enemy_position = pawn:GetSpace()
        local unit_position = module.ramming.pos
        if math.abs(enemy_position.x - unit_position.x) + math.abs(enemy_position.y - unit_position.y) >= 5 then
            local new_position = Board:GetPawn(module.ramming.id):GetSpace()    
            if math.abs(new_position.x - unit_position.x) + math.abs(new_position.y - unit_position.y) >= 4 then
                module.achievement2:addProgress(true)
            end
        end
    end
end

function module.initialize_achievement_2(achievement, mod)
    achievement.objective = true
    randomizer_helper.events.on_attack:subscribe(save_position)
    modapiext.events.onPawnKilled:subscribe(check_dash)
end

-- ACHIEVEMENT 3
-- Text : Complete 1st Corporate Island with the Rift Walkers squad
-- Code : Complete any Island with the Rift Walkers squad

function module.initialize_achievement_3(achievement, mod)
    modApi.events.onIslandLeft:subscribe(function()
        if module.achievement3:is_active() then
            module.achievement3:addProgress(true)
        end
    end)
    achievement.objective = true
end

return module
