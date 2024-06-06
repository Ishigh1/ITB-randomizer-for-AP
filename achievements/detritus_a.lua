local module = {}

-- ACHIEVEMENT 1 : Blitzkrieg
-- Text : Have the Chain Whip attack chain through 10 tiles
-- Code : Have any weapon affect 10 tiles

local function handle_effect(effects, skillEffect, method)
    if effects == nil then
        return
    end

    local affected = 0
    local locs = {}
    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local loc = space_damage.loc
        local loc_id = loc.x + loc.y * 10
        if locs[loc_id] == nil and loc_id >= 0 then
            affected = affected + 1
            locs[loc_id] = 1
            if affected == 10 then
                mod_loader.mods["randomizer"].pinnacle_a_1 = module.achievement1
                skillEffect[method](skillEffect, "mod_loader.mods[\"randomizer\"].pinnacle_a_1:addProgress(true)")
                return
            end
        end
    end
end

local function register_attack(mission, pawn, weaponId, p1, p2, skillEffect)
    if module.achievement1:is_active() then
        handle_effect(skillEffect.effect, skillEffect, "AddScript")
        handle_effect(skillEffect.q_effect, skillEffect, "AddQueuedScript")
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = true

    modapiext.events.onSkillBuild:subscribe(register_attack)
end

-- ACHIEVEMENT 2 : Lightning War
-- Text : Finish the first 2 Corporate Islands in under 30 minutes
-- Code : Beat the second island less than 30 minutes after starting

local function reset_speedrun()
    if module.achievement2:is_active() then
        module.achievement2:set_data("start", os.time())
        module.achievement2:resetProgress()
    end
end

local function check_speedrun()
    if module.achievement2:is_active() then
        local seconds = (os.time() - module.achievement2:get_data("start"))
        if (seconds < 1800) then
            module.achievement2:addProgress(1)
        else
            LOG("Wasn't fast enough for Lightning War : took " .. seconds .. " seconds")
        end
    end
end

function module.initialize_achievement_2(achievement, mod)
    modApi.events.onPostStartGame:subscribe(reset_speedrun)
    modApi.events.onIslandLeft:subscribe(check_speedrun)
    achievement.objective = 2
end

-- ACHIEVEMENT 3 : Hold the Line
-- Text : Block 4 emerging Vek in a single turn
-- Code : ^

local function notice_block()
    if module.achievement3:is_active() then
        module.achievement3:addProgress(1)
    end
end

local function reset_block(action)
    if action == ATTACK_ORDER_IDLE and module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = 4
    GameEvents.onSpawnBlocked:subscribe(notice_block)
    randomizer_helper.events.on_vek_action_change:subscribe(reset_block)
end

return module
