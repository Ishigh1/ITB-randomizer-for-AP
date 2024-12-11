local module = {}

-- ACHIEVEMENT 1 : Unbreakable
-- Text : Have Mech Armor absorb 5 damage in a single battle
-- Code : Have a mech with armored be attacked or be there at turn start with a Psion Tyrant alive

local function register_armor(skillEffect, effects, f)
    if effects == nil then
        return
    end

    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local damage = space_damage.iDamage

        if damage > 0 and damage < DAMAGE_ZERO then
            local previous_space_damage = effects:index(i)
            previous_space_damage.sScript =
                "local pawn = Board:GetPawn(Point(" .. space_damage.loc.x .. ", " .. space_damage.loc.y .. "))\n"
                .. "if pawn ~= nil and pawn:IsPlayer() and pawn:IsArmor() and not pawn:IsAcid() and not pawn:IsShield() then\n"
                .. "mod_loader.mods[\"randomizer\"].archive_b_1:addProgress(1)\n"
                .. "end\n" --The pawn sometimes isn't already there, so I check what's there just after the damage
                .. (previous_space_damage.sScript or "")
        end
    end
end

local function register_attack(mission, pawn, weaponId, p1, p2, p3, skillEffect)
    if module.achievement1:is_active() then
        register_armor(skillEffect, skillEffect.effect, skillEffect.AddScript)
        register_armor(skillEffect, skillEffect.q_effect, skillEffect.AddQueuedScript)
    end
end

local function handle_tentacles(action_id)
    if action_id == ATTACK_ORDER_TENTACLES then
        local enemies = extract_table(Board:GetPawns(TEAM_ENEMY))
        local tentacle_vek = false
        for i, pawn_id in ipairs(enemies) do
            local pawn = Board:GetPawn(pawn_id)
            if pawn:GetMechName() == "Psion Tyrant" then
                tentacle_vek = true
                break
            end
        end

        if not tentacle_vek then
            return
        end

        local allies = extract_table(Board:GetPawns(TEAM_PLAYER))
        for i, pawn_id in ipairs(allies) do
            local pawn = Board:GetPawn(pawn_id)
            if pawn:IsArmor() and not pawn:IsAcid() and not pawn:IsShield() then
                module.achievement1:addProgress(1)
            end
        end
    end
end

local function reset_armor()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement)
    achievement.objective = 5

    randomizer_helper.events.on_build:subscribe(register_attack)
    randomizer_helper.events.on_vek_action_change:subscribe(handle_tentacles)
    modApi.events.onMissionStart:subscribe(reset_armor)
end

-- ACHIEVEMENT 2 : Unwitting Allies
-- Text : Have 4 enemies die from enemy fire in a single battle
-- Code : Have 4 enemies die while it's their turn to act

local function check_team_kill(mission, pawn)
    if module.achievement2:is_active() then
        LOG(pawn:GetMechName() .. "was just killed")
        LOG("Was it an enemy ? " .. tostring(pawn:IsEnemy()))
        LOG("Was it their turn ? " .. tostring(randomizer_helper.utils.is_enemy_turn()))
        LOG("What was the phase ? " .. tostring(randomizer_helper.tracking.current_action))
        LOG("Whose turn was it ? " .. tostring(Game:GetTeamTurn()))
        if pawn:IsEnemy() and
            (randomizer_helper.tracking.current_action == ATTACK_ORDER_TENTACLES or randomizer_helper.utils.is_enemy_turn()) then
            module.achievement2:addProgress(1)
        end
    end
end

local function reset_team_kills()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement)
    achievement.objective = 4

    modapiext.events.onPawnKilled:subscribe(check_team_kill)
    modApi.events.onMissionStart:subscribe(reset_team_kills)
end

-- ACHIEVEMENT 3 : Mass Displacement
-- Text : Push 3 enemies with a single attack
-- Code : See 3 enemy moves following an attack

local function register_pushes(mission, pawn)
    if module.achievement3:is_active() and pawn:IsEnemy() and randomizer_helper.utils.is_player_turn() then
        module.achievement3:addProgress(1)
    end
end

local function reset_pushes()
    if module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement)
    modapiext.events.onPawnPositionChanged:subscribe(register_pushes)
    randomizer_helper.events.on_attack:subscribe(reset_pushes)
    achievement.objective = 3
end

return module
