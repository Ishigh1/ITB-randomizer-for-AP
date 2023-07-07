local module = {}

-- ACHIEVEMENT 1
-- Text : Have Mech Armor absorb 5 damage in a single battle
-- Code : Have a mech with armored be attacked or be there at turn start with a Psion Tyrant alive

local function register_armor(skillEffect, effects)
    if effects == nil then
        return {}
    end

    local new_effects = {}
    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local damage = space_damage.iDamage
        if damage ~= 0 and damage ~= DAMAGE_ZERO and damage ~= DAMAGE_DEATH then
            local loc = space_damage.loc
            local pawn = Board:GetPawn(loc)
            if pawn ~= nil and pawn:IsPlayer() and pawn:IsArmor() then
                new_effects[i] = "mod_loader.mods[\"randomizer\"].check_attacked_armor(" .. pawn:GetId() .. ")"
            end
        end
    end
    return new_effects
end

local function register_attack(mission, pawn, weaponId, p1, p2, skillEffect)
    if module.achievement1:is_active() then
        local scripts = register_armor(skillEffect, skillEffect.effect)
        for _, script in pairs(scripts) do
            skillEffect:AddScript(script)
        end

        scripts = register_armor(skillEffect, skillEffect.q_effect)
        for _, script in pairs(scripts) do
            skillEffect:AddQueuedScript(script)
        end
    end
end

local function handle_tentacles(action_id)
    if action_id == ATTACK_ORDER_TENTACLES then
        local enemies = extract_table(Board:GetPawns(TEAM_ENEMY))
        local tentacle_vek = false
        for i, pawn_id in ipairs(enemies) do
            local pawn = Board:GetPawn(Board:GetPawnSpace(pawn_id))
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
            local pawn = Board:GetPawn(Board:GetPawnSpace(pawn_id))
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

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = 5

    modapiext.events.onSkillBuild:subscribe(register_attack)
    memedit_functions.events.on_vek_action_change:subscribe(handle_tentacles)
    modApi.events.onMissionStart:subscribe(reset_armor)

    local randomizer_mod = mod_loader.mods["randomizer"]
    function randomizer_mod.check_attacked_armor(mech_id)
        local mech = Board:GetPawn(mech_id)
        if not mech:IsAcid() and not mech:IsShield() then
            module.achievement1:addProgress(1)
        end
    end
end

-- ACHIEVEMENT 2
-- Text : Have 4 enemies die from enemy fire in a single battle
-- Code : Have 4 enemies die while it's their turn to act

local function check_team_kill(mission, pawn)
    if module.achievement2:is_active() and pawn:IsEnemy() and
        (memedit_functions.events.current_action == ATTACK_ORDER_TENTACLES or memedit_functions.events.current_action ==
            ATTACK_ORDER_IDLE) then
        module.achievement2:addProgress(1)
    end
end

local function reset_team_kills()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement, mod)
    achievement.objective = 4

    modapiext.events.onPawnKilled:subscribe(check_team_kill)
    modApi.events.onMissionStart:subscribe(reset_team_kills)
end

-- ACHIEVEMENT 3
-- Text : Push 3 enemies with a single attack
-- Code : See 3 enemy moves following an attack

local function register_pushes(mission, pawn)
    if module.achievement3:is_active() and pawn:IsEnemy() and Game:GetTeamTurn() == TEAM_PLAYER then
        module.achievement3:addProgress(1)
    end
end

local function reset_pushes()
    if module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement, mod)
    modapiext.events.onPawnPositionChanged:subscribe(register_pushes)
    modapiext.events.onSkillStart:subscribe(reset_pushes)
    achievement.objective = 3
end

return module
