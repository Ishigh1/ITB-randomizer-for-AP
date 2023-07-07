local module = {}

local function reset_grid_appliance()
    modApi:writeProfileData("applied_grid", false)
end

local function get_starting_bonuses()
    if (modApi:readProfileData("applied_grid")) then
        module.ap_link.in_mission = true
        return
    end

    module.ap_link.handle_bonus("New Game")

    local value = (module.ap_link.unlocked_items["2 Starting Grid Power"] or 0) * 2 - 4
    for i, mission in ipairs(GAME.Missions) do
        mission.PowerStart = 5 + value
    end
    
    GetGame():ModifyPowerGrid(value)

    module.def_malus = (module.ap_link.unlocked_items["3 Starting Grid Defense"] or 0) * 3 - 15
    Game:SetResist(module.def_malus)
    memedit_functions.tracking.last_overload = module.def_malus

    modApi:writeProfileData("applied_grid", true)

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
    modApi.events.onMissionStart:subscribe(get_starting_bonuses)
    modApi.events.onMissionEnd:subscribe(stop_mission)
end

return module