local module = {}

-- ACHIEVEMENT 1 : Quantum Entanglement
-- Text : Teleport a unit 4 tiles away
-- Code : Use Teleporter on an unit 4 tiles away

local function check_teleport(mission, pawn, weapon_id, p1, p2)
    if module.achievement1:is_active() and weapon_id == "Science_Swap_AB" and p1:Manhattan(p2) == 4 then
        module.achievement1:addProgress(true)
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = true

    randomizer_helper.events.on_attack:subscribe(check_teleport)
end

-- ACHIEVEMENT 2 : Scorched Earth
-- Text : End a battle with 12 tiles on Fire
-- Code : Just have 12 tiles lit at the same time

local function count_fire(fire)
    if module.achievement2:is_active() then
        if fire then
            module.achievement2:addProgress(1)
        else
            module.achievement2:addProgress(-1)
        end
    end
end

local function reset_fire()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement, mod)
    achievement.objective = 12

    randomizer_helper.events.on_tile_fire:subscribe(count_fire)
    modApi.events.onMissionStart:subscribe(reset_fire)
end

-- ACHIEVEMENT 3 : This is Fine
-- Text : Have 5 enemies on Fire simultaneously
-- Code : ^
local function pawn_fire(mission, pawn, isFire)
    if module.achievement3:is_active() then
        if isFire and pawn:IsEnemy() then
            local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))
            local fire = 0
            for i, id in pairs(pawns) do
                local pawn = Board:GetPawn(id)
                if pawn:IsFire() then
                    fire = fire + 1
                    if fire == 5 then
                        module.achievement3:addProgress(true)
                        return
                    end
                end
            end
        end
    end
end

local function reset_pawn_fire()
    if module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = true

    modapiext.events.onPawnIsFire:subscribe(pawn_fire)
    modApi.events.onMissionStart:subscribe(reset_pawn_fire)
end

return module
