local module = {}

-- ACHIEVEMENT 1
-- Text : Kill an enemy by pulling it into yourself
-- Code : ^


local function handle_effect(pawn, effects, skillEffect, method)
    if effects == nil then
        return
    end

    local pushs = randomizer_helper.utils.compute_push(effects)
    local space = pawn:GetSpace()
    for start_location, target_location in pairs(pushs) do
        local enemy = Board:GetPawn(start_location)
        if enemy:IsEnemy() and space == target_location then
            mod_loader.mods["randomizer"].pinnacle_a_1 = module.achievement1
            skillEffect[method](skillEffect, "table.insert(mod_loader.mods[\"randomizer\"].pinnacle_a_1.pulled, " .. enemy:GetId() .. ")")
        end
    end
end

local function register_attack(mission, pawn, weaponId, p1, p2, skillEffect)
    if module.achievement1:is_active() and pawn ~= nil and pawn:IsPlayer() then
        module.achievement1.pulled = {}
        handle_effect(pawn, skillEffect.effect, skillEffect, "AddScript")
        handle_effect(pawn, skillEffect.q_effect, skillEffect, "AddQueuedScript")
    end
end

local function test_deadly_pull(mission, pawn)
    if module.achievement1:is_active() then
        local id = pawn:GetId()
        for _, v in pairs(module.achievement1.pulled) do
            if v == id then
                module.achievement1:addProgress(true)
                return
            end
        end
    end
end

local function reset_pull(action)
    if action == ATTACK_ORDER_IDLE and module.achievement1:is_active() then
        module.achievement1.pulled = {}
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = true

    modapiext.events.onSkillBuild:subscribe(register_attack)
    modapiext.events.onPawnKilled:subscribe(test_deadly_pull)
    randomizer_helper.events.on_vek_action_change:subscribe(reset_pull)
end

-- ACHIEVEMENT 2
-- Text : Hit 4 enemies with a single laser
-- Code : Have 4 enemies in your attack area with a laser weapon
local function handle_effect(effects, skillEffect, method)
    if effects == nil then
        return
    end

    local affected = 0
    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local loc = space_damage.loc
        local pawn = Board:GetPawn(loc)
        if pawn ~= nil and pawn:IsEnemy() then
            affected = affected + 1
            if affected == 4 then
                mod_loader.mods["randomizer"].pinnacle_a_2 = module.achievement2
                skillEffect[method](skillEffect, "mod_loader.mods[\"randomizer\"].pinnacle_a_2:addProgress(true)")
            end
        end
    end
end

local function register_attack(mission, pawn, weaponId, p1, p2, skillEffect)
    if module.achievement2:is_active() then
        handle_effect(skillEffect.effect, skillEffect, "AddScript")
        handle_effect(skillEffect.q_effect, skillEffect, "AddQueuedScript")
    end
end

function module.initialize_achievement_2(achievement, mod)
    achievement.objective = true

    modapiext.events.onSkillBuild:subscribe(register_attack)
end

-- ACHIEVEMENT 3
-- Text : Block damage with a Shield 4 times in a single battle
-- Code : Have a mech or building lose shield 4 times

local function notice_pawn_shield(mission, pawn, isShield)
    if module.achievement3:is_active() and not isShield then
        module.achievement3:addProgress(1)
    end
end

local function count_shield(shield)
    if module.achievement3:is_active() and not shield then
        module.achievement3:addProgress(1)
    end
end

local function reset_shield()
    if module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = 4

    modapiext.events.onPawnIsShielded:subscribe(notice_pawn_shield)
    randomizer_helper.events.on_tile_shield:subscribe(count_shield)
    modApi.events.onMissionStart:subscribe(reset_shield)
end

return module
