local module = {}

-- ACHIEVEMENT 1
-- Text : Kill an enemy by pulling it into yourself
-- Code : I don't know how do do this one well, so just kill someone with Attraction Pulse

local function check_pull(mission, pawn, weapon_id, p1, p2)
    if module.achievement1:is_active() and string.sub(weapon_id, 0, 16) == "Science_Pullmech" then
        module.pull = true
    else
        module.pull = nil
    end
end

local function kill_pull(mission, pawn)
    if module.pull and module.achievement1:is_active() and pawn:isEnemy() and randomizer_helper.utils.is_player_turn() == TEAM_PLAYER then
        module.achievement1:addProgress(true)
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = true

    randomizer_helper.events.on_attack:subscribe(check_pull)
    modapiext.events.onPawnKilled:subscribe(kill_pull)
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
