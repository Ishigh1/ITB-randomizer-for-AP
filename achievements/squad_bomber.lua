local module = {}

-- ACHIEVEMENT 1 : Hold the Door
-- Text : Block 30 Emerging Vek by the end of Island 2.
-- Code : ^

local function notice_block()
    if module.achievement1:is_active() and not module.achievement1:get_data("failed_block") then
        module.achievement1:addProgress(1)
    end
end

local function fail_block(island)
    if module.achievement1:is_active() and island >= 2 and not module.achievement1:get_data("failed_block") then
        module.achievement1.text = GetVanillaText("Ach_Squad_Bomber_Text" .. "\n" .. "Failed")
        module.achievement1:set_data("failed_block", true)
    end
end

local function reset_block()
    if module.achievement1:is_active() then
        module.achievement1:resetProgress()
        module.achievement1.text = GetVanillaText("Ach_Squad_Bomber_Text")
        module.achievement1:set_data("failed_block", false)
    end
end

function module.initialize_achievement_1(achievement, mod)
    achievement.objective = 30

    GameEvents.onSpawnBlocked:subscribe(notice_block)
    modApi.events.onIslandLeft:subscribe(fail_block)
    modApi.events.onPostStartGame:subscribe(reset_block)
end

-- ACHIEVEMENT 2 : No Survivors
-- Text : Have 7 units (any team) die in a single turn.
-- Code : ^

local function count_kill()
    if module.achievement2:is_active() then
        module.achievement2:addProgress(1)
    end
end

local function reset_kills()
    if module.achievement2:is_active() then
        module.achievement2:resetProgress()
    end
end

function module.initialize_achievement_2(achievement, mod)
    achievement.objective = 7

    modapiext.events.onPawnKilled:subscribe(count_kill)
    GameEvents.onTurnStart:subscribe(reset_kills)
end

-- ACHIEVEMENT 3 : Powered Blast
-- Text : Pierce a Walking Bomb with the AP Cannon to kill an Enemy.
-- Code : Kill an enemy by attacking through something you summoned this turn

local function handle_effect(pawn, effects, skillEffect, method)
    if effects == nil then
        return
    end

    local up = 420 -- Any number bigger than board size
    local down = 420
    local left = 420
    local right = 420
    local base_space = pawn:GetSpace()
    local new_units = module.achievement3:get_data("new_units")
    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local loc = space_damage.loc
        local target = Board:GetPawn(loc)
        if target ~= nil then
            for _, id in pairs(new_units) do
                if (target:GetId() == id) then
                    if (loc.x == base_space.x) then
                        local yDiff = base_space.y - loc.y
                        if yDiff > 0 and yDiff < up then
                            up = yDiff
                        elseif yDiff < 0 and -yDiff < down then
                            down = -yDiff
                        end
                    elseif (loc.y == base_space.y) then
                        local xDiff = base_space.x - loc.x
                        if xDiff > 0 and xDiff < left then
                            left = xDiff
                        elseif xDiff < 0 and -xDiff < right then
                            right = -xDiff
                        end
                    end
                    break
                end
            end
        end
    end

    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local loc = space_damage.loc
        local target = Board:GetPawn(loc)
        if target ~= nil and target:IsEnemy() then
            if (loc.x == base_space.x) then
                local yDiff = base_space.y - loc.y
                if yDiff > 0 and yDiff > up then
                    table.insert(module.achievement3.pierce_victims, target:GetId())
                elseif yDiff < 0 and -yDiff > down then
                    table.insert(module.achievement3.pierce_victims, target:GetId())
                end
            elseif (loc.y == base_space.y) then
                local xDiff = base_space.x - loc.x
                if xDiff > 0 and xDiff > left then
                    table.insert(module.achievement3.pierce_victims, target:GetId())
                elseif xDiff < 0 and -xDiff > right then
                    table.insert(module.achievement3.pierce_victims, target:GetId())
                end
            end
        end
    end
end

local function register_attack(mission, pawn, weaponId, p1, p2, skillEffect)
    if module.achievement3:is_active() and pawn ~= nil and pawn:IsPlayer() then
        module.achievement3.pierce_victims = {}
        handle_effect(pawn, skillEffect.effect, skillEffect, "AddScript")
        handle_effect(pawn, skillEffect.q_effect, skillEffect, "AddQueuedScript")
    end
end

local function check_pierce(mission, pawn)
    if module.achievement3:is_active() and randomizer_helper.utils.is_player_turn() then
        local id = pawn:GetId()
        for _, v in pairs(module.achievement3.pierce_victims) do
            if v == id then
                module.achievement3:addProgress(true)
                return
            end
        end
    end
end

local function reset_pierce(action)
    if module.achievement3:is_active() and action == ATTACK_ORDER_IDLE then
        module.achievement3.pierce_victims = {}
        module.achievement3:set_data("new_units", {})
    end
end

local function new_unit(mission, pawn)
    if module.achievement3:is_active() and pawn:IsPlayer() then
        local new_units = module.achievement3:get_data("new_units") or {}
        local id = pawn:GetId()
        table.insert(new_units, id)
        module.achievement3:set_data("new_units", new_units)
    end
end

function module.initialize_achievement_3(achievement, mod)
    achievement.objective = true
    modapiext.events.onSkillBuild:subscribe(register_attack)
    modapiext.events.onPawnKilled:subscribe(check_pierce)
    randomizer_helper.events.on_vek_action_change:subscribe(reset_pierce)
    modapiext.events.onPawnTracked:subscribe(new_unit)
end

return module
