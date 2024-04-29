local module = {}

-- ACHIEVEMENT 1 : Stay With Me!
-- Text : Heal 12 damage over the course of a single Island.
-- Code : ^

local function check_heal(mission, pawn, diff)
    if module.achievement1:is_active() and pawn:IsPlayer() then
        module.achievement1:addProgress(diff)
    end
end

local function reset_healing()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement, mod)
    modapiext.events.onPawnHealed:subscribe(check_heal)
    modApi.events.onPostStartGame:subscribe(reset_healing)
    modApi.events.onIslandLeft:subscribe(reset_healing)

    achievement.objective = 12
end

-- ACHIEVEMENT 2 : Let's Walk
-- Text : Move Enemies with Control Shot 120 spaces in one game.
-- Code : Move enemies 120 spaces total


local function register_pushes(mission, pawn, old_position)
    if module.achievement2:is_active() and randomizer_helper.utils.is_player_turn() then
        local new_position = pawn:GetSpace()
        local unit_move_distance = math.abs(new_position.x - old_position.x) +
            math.abs(new_position.y - old_position.y)
        module.achievement2:addProgress(unit_move_distance)
    end
end

local function reset_pushes()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement, mod)
    modapiext.events.onPawnPositionChanged:subscribe(register_pushes)
    modApi.events.onPostStartGame:subscribe(reset_pushes)

    achievement.objective = 120
end

-- ACHIEVEMENT 3 : On the Backburner
-- Text : Do 4 damage with the Reverse Thrusters.
-- Code : Do 4 damage to a unit with a single attack

local function handle_effect(effects, skillEffect, method)
    if effects == nil then
        return
    end

    local total_damage = {}
    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local loc = space_damage.loc
        local pawn = Board:GetPawn(loc)
        if pawn ~= nil and pawn:IsEnemy() then
            local damage = space_damage.iDamage
            if damage > 0 and damage < DAMAGE_ZERO then
                if pawn:IsAcid() then
                    damage = damage * 2
                end

                local pawn_id = pawn:GetId()
                total_damage[pawn_id] = damage + (total_damage[pawn_id] or 0)
            end
        end
    end

    local pushs = randomizer_helper.utils.compute_push(effects)
    for start_location, target_location in pairs(pushs) do
        local pawn = Board:GetPawn(start_location)
        local pawn_id = pawn:GetId()
        total_damage[pawn_id] = 1 + (total_damage[pawn_id] or 0)

        pawn = Board:GetPawn(target_location)
        if pawn ~= nil then
            pawn_id = pawn:GetId()
            total_damage[pawn_id] = 1 + (total_damage[pawn_id] or 0)
        end
    end

    for _, damage in pairs(total_damage) do
        if damage >= 4 then
            mod_loader.mods["randomizer"].squad_mist_3 = module.achievement3
            skillEffect[method](skillEffect, "mod_loader.mods[\"randomizer\"].squad_mist_3:addProgress(true)")
            return
        end
    end
end

local function register_attack(mission, pawn, weaponId, p1, p2, skillEffect)
    if module.achievement3:is_active() then
        handle_effect(skillEffect.effect, skillEffect, "AddScript")
        handle_effect(skillEffect.q_effect, skillEffect, "AddQueuedScript")
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = true
    modapiext.events.onSkillBuild:subscribe(register_attack)
end

return module
