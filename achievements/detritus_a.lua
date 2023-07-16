local module = {}

-- ACHIEVEMENT 1
-- Text : Have the Chain Whip attack chain through 10 tiles
-- Code : ^

local function register_attack(mission, pawn, weaponId, p1, p2, skillEffect)
    if module.achievement2:is_active() then
        local effects = skillEffect.effect
        if effects == nil then
            return
        end

        local affected = 0
        local locs = {}
        for i = 1, effects:size() do
            local space_damage = effects:index(i)
            local loc = space_damage.loc
            if locs[loc] == nil then
                affected = affected + 1
                locs[loc] = 1
                if affected == 10 then
                    mod_loader.mods["randomizer"].pinnacle_a_1 = module.achievement1
                    skillEffect:AddScript("mod_loader.mods[\"randomizer\"].pinnacle_a_1 = true")
                end
            end
        end
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = true

    modapiext.events.onSkillBuild:subscribe(register_attack)
end

-- ACHIEVEMENT 2
-- Text : Finish the first 2 Corporate Islands in under 30 minutes
-- Code : Beat the second island less than 30 minutes after starting

local function reset_speedrun()
    if module.achievement2:is_active() then
        module.achievement2:set_flag("start", os.time())
        module.achievement2:resetProgression()
    end
end

local function check_speedrun(island)
    if module.achievement2:is_active() and (os.time() - module.achievement2:get_flag("start") / 60 <= 30)  then
        module.achievement2:addProgression(1)
    end
end

function module.initialize_achievement_2(achievement, mod)
    modApi.events.onPostStartGame:subscribe(reset_speedrun)
    modApi.events.onIslandLeft:subscribe(check_speedrun)
    achievement.objective = 2
end

-- ACHIEVEMENT 3
-- Text : Block 4 emerging Vek in a single turn
-- Code : ^

local function notice_block()
    if module.achievement3:is_active() then
        module.achievement3:addProgress(1)
    end
end

local function reset_block()
    if module.achievement3:is_active() then
        module.achievement3:resetProgress()
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = 4
    GameEvents.onSpawnBlocked:subscribe(notice_block)
    GameEvents.onEnemyTurn:subscribe(reset_block)
end

return module
