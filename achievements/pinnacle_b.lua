local module = {}

-- ACHIEVEMENT 1 : Cryo-Expert
-- Text : Shoot the Cryo-Launcher 4 times in a single battle
-- Code : ^

local function check_cryo(mission, pawn, weapon_id, p1, p2)
    if module.achievement1:is_active() and weapon_id == "Ranged_Ice" then
        module.achievement1:addProgress(1)
    end
end

local function reset_cryo()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement)
    achievement.objective = 4

    randomizer_helper.events.on_attack:subscribe(check_cryo)
    modApi.events.onMissionStart:subscribe(reset_cryo)
end

-- ACHIEVEMENT 2 : Trick Shot
-- Text : Kill 3 enemies with a single attack of the Janus Cannon
-- Code : Kill 3 enemies after using any weapon

local function check_janus(mission, pawn, weapon_id, p1, p2)
    if module.achievement2:is_active() then
        module.janus = true
        module.achievement2:resetProgress()
    else
        module.janus = nil
    end
end

local function kill_janus(mission, pawn)
    if module.janus and module.achievement2:is_active() and pawn:IsEnemy() and randomizer_helper.utils.is_player_turn() then
        module.achievement2:addProgress(1)
    end
end

function module.initialize_achievement_2(achievement)
    achievement.objective = 3

    randomizer_helper.events.on_attack:subscribe(check_janus)
    modapiext.events.onPawnKilled:subscribe(kill_janus)
end

-- ACHIEVEMENT 3 : Pacifist
-- Text : Kill fewer than 3 enemies in a single battle
-- Code : ^

local function fail_pacifist()
    if module.achievement3:is_active() and (module.achievement3:get_data("kills") or 0) >= 3 then
        module.achievement3.text = GetVanillaText("Ach_Pinnacle_B_3_Text") .. "\n" .. "Failed"
    end
end

local function not_very_pacifist(mission, pawn)
    if module.achievement3:is_active() and pawn:IsEnemy() then
        local killed = (module.achievement3:get_data("kills") or 0) + 1

        if killed >= 3 then
            module.achievement3.text = GetVanillaText("Ach_Pinnacle_B_3_Text") .. "\n" .. "Failed"
        end
        module.achievement3:set_data("kills", killed)
    end
end

local function become_pacifist()
    if module.achievement3:is_active() and (module.achievement3:get_data("kills") or 0) < 3 then
        module.achievement3:addProgress(true)
    end
end

local function reset_pacifist()
    if module.achievement3:is_active() then
        module.achievement3:set_data("kills", nil)
        module.achievement3.text = GetVanillaText("Ach_Pinnacle_B_3_Text")
    end
end

function module.initialize_achievement_3(achievement)
    achievement.objective = true
    modapiext.events.onPawnKilled:subscribe(not_very_pacifist)
    modApi.events.onMissionEnd:subscribe(become_pacifist)
    modApi.events.onMissionStart:subscribe(reset_pacifist)
end

return module
