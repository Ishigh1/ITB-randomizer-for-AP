local module = {}

-- ACHIEVEMENT 1
-- Text : Shoot the Cryo-Launcher 4 times in a single battle
-- Code : ^

local function check_cryo(mission, pawn, weapon_id, p1, p2)
    if module.achievement1:is_active() and string.sub(weapon_id, 10) == "Ranged_Ice" then
        module.achievement1:addProgress(1)
    end
end

local function reset_cryo()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = 4

    modapiext.events.onSkillStart:subscribe(check_cryo)
    modApi.events.onMissionStart:subscribe(reset_cryo)
end

-- ACHIEVEMENT 2
-- Text : Kill 3 enemies with a single attack of the Janus Cannon
-- Code : Kill 3 enemies after using Janus

local function check_janus(mission, pawn, weapon_id, p1, p2)
    if module.achievement2:is_active() and string.sub(weapon_id, 16) == "Brute_Mirrorshot" then
        module.janus = true
    else
        module.janus = nil
        if module.achievement2:is_active() then
            module.achievement2:reset()
        end
    end
end

local function kill_janus(mission, pawn)
    if module.janus and module.achievement2:is_active() and pawn:isEnemy() and Game:GetTeamTurn() == TEAM_PLAYER then
        module.achievement2:addProgress(1)
    end
end

function module.initialize_achievement_2(achievement, mod)
    achievement.objective = 3

    modapiext.events.onSkillStart:subscribe(check_janus)
    modapiext.events.onPawnKilled:subscribe(kill_janus)
end

-- ACHIEVEMENT 3
-- Text : Kill fewer than 3 enemies in a single battle
-- Code : ^

local function fail_pacifist()
    if module.achievement3:is_active() and modApi:readProfileData("Ach_Rust_A_3_failed_perfect") == nil then
        module.achievement3.text = GetVanillaText("Ach_Detritus_B_2_Text") .. "\n" .. "Failed"
    end
end

local function not_very_pacifist(mission, pawn)
    if module.achievement3:is_active() and pawn:isEnemy() then
        local killed = (modApi:readProfileData("Ach_Pinnacle_B_3_kills") or 0) + 1

        if killed >= 3 then
            module.achievement3.text = GetVanillaText("Ach_Pinnacle_B_3_Text") .. "\n" .. "Failed"
        end
        modApi:writeProfileData("Ach_Pinnacle_B_3_kills", killed)
    end
end

local function become_pacifist()
    if module.achievement3:is_active() and (modApi:readProfileData("Ach_Pinnacle_B_3_kills") or 0) < 3 then
        module.achievement3:addProgress(true)
    end
end

local function reset_pacifist()
    if module.achievement3:is_active() then
        modApi:writeProfileData("Ach_Pinnacle_B_3_kills", nil)
        module.achievement3.text = GetVanillaText("Ach_Pinnacle_B_3_Text")
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = true
    modapiext.events.onPawnKilled:subscribe(not_very_pacifist)
    modApi.events.onMissionEnd:subscribe(become_pacifist)
    modApi.events.onMissionStart:subscribe(reset_pacifist)

    if (modApi:readProfileData("Ach_Pinnacle_B_3_kills") or 0) >= 3 then
        achievement.text = GetVanillaText("Ach_Pinnacle_B_3_Text") .. "\n" .. "Failed"
    end
end

return module
