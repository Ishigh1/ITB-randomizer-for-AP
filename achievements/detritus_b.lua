local module = {}

-- ACHIEVEMENT 1
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

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = 10
    modapiext.events.onPawnHealed:subscribe(check_heal)
    modApi.events.onMissionStart:subscribe(reset_healing)
end

-- ACHIEVEMENT 2
-- Text : Finish 4 Corporate Islands without a Mech being destroyed at the end of a battle
-- Code : Finish 4 Corporate Islands without an ally being destroyed

local function mortality()
    module.achievement2.text = GetVanillaText("Ach_Detritus_B_2_Text") .. "\n" ..
                                   GetVanillaText("Ach_Detritus_B_2_Failed")
end

local function check_immortality(mission, pawn)
    if module.achievement2:is_active() and pawn:IsPlayer() then
        mortality()
        modApi:writeProfileData("Ach_Detritus_B_2_failed_immortality", true)
    end
end

local function regain_immortality()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
        modApi:writeProfileData("Ach_Detritus_B_2_failed_immortality", nil)
        module.achievement2.text = GetVanillaText("Ach_Detritus_B_2_Text")
    end
end

local function gain_immortality(island)
    if module.achievement2:is_active() and modApi:readProfileData("Ach_Detritus_B_2_failed_immortality") == nil then
        module.achievement2:addProgress(1)
    end
end

function module.initialize_achievement_2(achievement, mod)
    achievement.objective = true

    modapiext.events.onPawnKilled:subscribe(check_immortality)
    modApi.events.onPostStartGame:subscribe(regain_immortality)
    modApi.events.onIslandLeft:subscribe(gain_immortality)

    if modApi:readProfileData("Ach_Detritus_B_2_failed_immortality") == true then
        achievement.text = GetVanillaText("Ach_Detritus_B_2_Text") .. "\n" .. GetVanillaText("Ach_Detritus_B_2_Failed")
    end
end

-- ACHIEVEMENT 3
-- Text : Deal 8 damage to a unit with a single attack
-- Code : Make so that any unit loses 8 hp in a single skill

local function start_attack(mission, pawn, weapon_id, p1, p2)
    if module.achievement3:is_active() then
        module.attack = {}
    end
end

local function register_damage(mission, pawn, damage_taken)
    if module.achievement3:is_active() and module.attack ~= nil then
        local id = pawn:GetId()
        local total_damage = (module.attack[id] or 0) + damage_taken
        if total_damage >= 8 then
            module.achievement3:addProgress(true)
        else
            module.attack[id] = total_damage
        end
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = true
    modapiext.events.onSkillStart:subscribe(start_attack)
    modapiext.events.onQueuedSkillStart:subscribe(start_attack)
    modapiext.events.onPawnDamaged:subscribe(register_damage)
end

return module
