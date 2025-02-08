local module = {}

-- ACHIEVEMENT 1 : Healing
-- Text : Heal 10 Mech Health in a single battle
-- Code : Restore 10 HP to player units during a battle

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

function module.initialize_achievement_1(achievement)
    achievement.objective = 10
    modapiext.events.onPawnHealed:subscribe(check_heal)
    modApi.events.onMissionStart:subscribe(reset_healing)
end

-- ACHIEVEMENT 2 : Immortal
-- Text : Finish 4 Corporate Islands without a Mech being destroyed at the end of a battle
-- Code : Finish 4 Corporate Islands without a Mech being destroyed

local function mortality()
    module.achievement2.text = GetVanillaText("Ach_Detritus_B_2_Text") .. "\n" ..
        GetVanillaText("Ach_Detritus_B_2_Failed")
end

local function check_immortality(mission, pawn)
    if module.achievement2:is_active() and pawn:IsMech() then
        mortality()
        module.achievement2:set_data("failed_immortality", true)
    end
end

local function regain_immortality()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
        module.achievement2:set_data("Ach_Detritus_B_2_failed_immortality", nil)
        module.achievement2.text = GetVanillaText("Ach_Detritus_B_2_Text")
    end
end

local function gain_immortality(island)
    if module.achievement2:is_active() and module.achievement2:get_data("Ach_Detritus_B_2_failed_immortality") == nil then
        module.achievement2:setProgress(island)
    end
end

function module.initialize_achievement_2(achievement)
    achievement.objective = 4

    modapiext.events.onPawnKilled:subscribe(check_immortality)
    modApi.events.onPostStartGame:subscribe(regain_immortality)
    randomizer_helper.events.on_island_completed:subscribe(gain_immortality)
end

-- ACHIEVEMENT 3 : Overkill
-- Text : Deal 8 damage to a unit with a single attack
-- Code : Make so that any unit loses 8 hp in a single skill

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
        if damage >= 8 then
            skillEffect[method](skillEffect, "mod_loader.mods[\"randomizer\"].detritus_b_3:addProgress(true)")
            return
        end
    end
end

local function register_attack(mission, pawn, weaponId, p1, p2, p3, skillEffect)
    if module.achievement3:is_active() then
        handle_effect(skillEffect.effect, skillEffect, "AddScript")
        handle_effect(skillEffect.q_effect, skillEffect, "AddQueuedScript")
    end
end

function module.initialize_achievement_3(achievement)
    achievement.objective = true
    randomizer_helper.events.on_build:subscribe(register_attack)
end

return module
