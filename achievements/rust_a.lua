local module = {}

-- ACHIEVEMENT 1 : Overpower
-- Text : Overpower your Power Grid twice by earning or buying Power when it is full
-- Code : See overpower rise twice not due to AP

local function register_overpower(overpower)
    if module.achievement1:is_active() then
        module.achievement1:setProgress(Game:GetResist() / 2)
    end
end

function module.initialize_achievement_1(achievement)
    achievement.objective = 2

    randomizer_helper.events.on_overload_change:subscribe(register_overpower)
end

-- ACHIEVEMENT 2 : Stormy Weather
-- Text : Deal 12 damage with Electric Smoke in a single battle
-- Code : See 12 damages in ATTACK_ORDER_LIGHTNING. Also counts explosions happening at that time

local function check_smoke(mission, pawn, damage)
    if module.achievement2:is_active() and randomizer_helper.tracking.current_action == ATTACK_ORDER_LIGHTNING then
        module.achievement2:addProgress(damage)
    end
end

local function reset_smoke()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement)
    achievement.objective = 12

    modapiext.events.onPawnDamaged:subscribe(check_smoke)
    modApi.events.onMissionStart:subscribe(reset_smoke)
end

-- ACHIEVEMENT 3 : Perfect Battle
-- Text : Take no Mech or Building Damage in a single battle (Repaired damage is still damage)
-- Code : ^

local function fail_perfect()
    if module.achievement3:is_active() and not module.achievement3:get_data("failed_perfect") then
        module.achievement3:set_data("failed_perfect", true)
        module.achievement3.text = GetVanillaText("Ach_Rust_A_3_Text") .. "\n" .. "Failed"
    end
end

local function check_perfect(mission, pawn)
    if pawn:IsPlayer() then
        fail_perfect()
    end
end

local function reset_perfect()
    if module.achievement3:is_active() and module.achievement3:get_data("failed_perfect") then
        module.achievement3.text = GetVanillaText("Ach_Rust_A_3_Text")
        module.achievement3:set_data("failed_perfect", nil)
    end
end

local function validate_perfect()
    if module.achievement3:is_active() and not module.achievement3:get_data("failed_perfect") then
        module.achievement3:addProgress(true)
    end
end

function module.initialize_achievement_3(achievement)
    achievement.objective = true
    randomizer_helper.events.on_building_damaged:subscribe(fail_perfect)
    modapiext.events.onPawnDamaged:subscribe(check_perfect)
    modApi.events.onMissionStart:subscribe(reset_perfect)
    modApi.events.onMissionEnd:subscribe(validate_perfect)
end

return module
