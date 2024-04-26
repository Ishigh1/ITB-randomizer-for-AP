local module = {}

local function reset_grid_appliance()
    module.mod.profile_manager.set_data("applied_grid", randomizer_helper.memedit.get_seed())
    randomizer_helper.memedit.set_base_def((module.ap_link.unlocked_items["3 Starting Grid Defense"] or 0) * 3)
    randomizer_helper.memedit.set_power((module.ap_link.unlocked_items["2 Starting Grid Power"] or 0) * 2 + 1)
    module.ap_link.handle_bonus("New Game")
end
local function apply_grid_bonuses()
    if module.mod.profile_manager.get_data("applied_grid") ~= randomizer_helper.memedit.get_seed() then
        reset_grid_appliance()
    else
        randomizer_helper.memedit.set_base_def((module.ap_link.unlocked_items["3 Starting Grid Defense"] or 0) * 3)
        module.ap_link.handle_bonus()
    end
end

local function get_starting_bonuses()
    module.ap_link.in_mission = true
    module.ap_link.handle_bonus()
end


local function stop_mission()
    module.ap_link.in_mission = false
end

function module.initialize(mod)
    module.mod = mod
    module.ap_link = mod.ap_link
    modApi.events.onPostStartGame:subscribe(reset_grid_appliance)
    modApi.events.onPostLoadGame:subscribe(apply_grid_bonuses)
    modApi.events.onMissionStart:subscribe(get_starting_bonuses)
    modApi.events.onMissionEnd:subscribe(stop_mission)
end

return module
