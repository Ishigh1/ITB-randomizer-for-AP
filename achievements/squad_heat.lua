local module = {}

-- ACHIEVEMENT 1 : Boosted
-- Text : Boost 8 Mechs in one mission.
-- Code : ^

local function check_boost(mission, pawn, isBoost)
    if module.achievement1:is_active() and pawn:IsPlayer() and isBoost then
        module.achievement1:addProgress(1)
    end
end

local function reset_boosts()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement)
    modapiext.events.onPawnIsBoosted:subscribe(check_boost)
    modApi.events.onMissionStart:subscribe(reset_boosts)

    achievement.objective = 8
end

-- ACHIEVEMENT 2 : Feed the Flame
-- Text : Light 3 Enemies on fire with a single attack.
-- Code : ^

local function check_fire(mission, pawn, isFire)
    if module.achievement2:is_active() and pawn:IsEnemy() and isFire then
        module.achievement2:addProgress(1)
    end
end

local function reset_fire()
    if module.achievement2:is_active() and module.achievement2:getProgress() > 0 then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement)
    modapiext.events.onPawnIsFire:subscribe(check_fire)
    randomizer_helper.events.on_attack:subscribe(reset_fire)

    achievement.objective = 3
end

-- ACHIEVEMENT 3 : Maximum Firepower
-- Text : Deal 8 damage with a single activation of the Quick-Fire Rockets.
-- Code : Deal 8 damages with a single attack

local function handle_effect(effects)
    if effects == nil then
        return 0
    end

    local total_damage = 0
    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local loc = space_damage.loc
        local pawn = Board:GetPawn(loc)
        if pawn ~= nil then
            local damage = space_damage.iDamage
            if damage > 0 and damage < DAMAGE_ZERO then
                if pawn:IsAcid() then
                    damage = damage * 2
                end
                total_damage = total_damage + damage
            end
        end
    end

    local pushs = randomizer_helper.utils.compute_push(effects)
    for start_location, target_location in pairs(pushs) do
        total_damage = total_damage + 1

        pawn = Board:GetPawn(target_location)
        if pawn ~= nil then
            total_damage = total_damage + 1
        end
    end

    return total_damage
end

local function final_register_attack(mission, pawn, weaponId, p1, p2, p3, skillEffect)
    if module.achievement3:is_active() and pawn:IsPlayer() then
        local total_damage = handle_effect(skillEffect.effect)
        if total_damage >= 2 then
            skillEffect:AddScript("mod_loader.mods[\"randomizer\"].squad_heat_3:addProgress(true)")
            return
        end
        total_damage = total_damage + handle_effect(skillEffect.q_effect)
        if total_damage >= 2 then
            skillEffect:AddQueuedScript("mod_loader.mods[\"randomizer\"].squad_heat_3:addProgress(true)")
            return
        end
    end
end

function module.initialize_achievement_3(achievement)
    randomizer_helper.events.on_build:subscribe(final_register_attack)

    achievement.objective = true
end

return module
