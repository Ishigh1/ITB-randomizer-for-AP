local function add_env_hazard(self, name, env_class, spaces)
    if modApi:getGameState() ~= "Mission" then
        return false
    end
    local hazard = env_class:new()
    hazard:Start()
    if spaces == nil then
        local function plan_hazard()
            if modApi:getGameState() ~= "Mission" then
                return
            end
            if not hazard:Plan() then
                local saved_spaces = self.profile_manager:get_data(name .. "|trap")
                if saved_spaces == nil then
                    saved_spaces = {}
                end
                table.insert(saved_spaces, hazard.Locations)
                self.profile_manager:set_data(name, saved_spaces)
                return
            end

            local delay = SkillEffect()
            delay:AddDelay(1.1)
            Board:AddEffect(delay)

            modApi:scheduleHook(1000, plan_hazard)
        end
        plan_hazard()
    else
        hazard.Locations = spaces
    end

    local function mark_hazard()
        hazard:MarkBoard()
    end

    local unhook

    local function send_hazard()
        local function apply_hazard()
            if modApi:getGameState() ~= "Mission" then
                return
            end
            if not hazard:ApplyEffect() then
                return
            end

            local delay = SkillEffect()
            delay:AddDelay(1.1)
            Board:AddEffect(delay)

            modApi:scheduleHook(1000, apply_hazard)
        end
        apply_hazard()
        self.profile_manager:set_data(name, nil)
        unhook()
    end

    function unhook()
        modApi.events.onMissionUpdate:unsubscribe(mark_hazard)
        modApi.events.onPostEnvironment:unsubscribe(send_hazard)
        modApi.events.onGameExited:unsubscribe(unhook)
    end

    modApi.events.onMissionUpdate:subscribe(mark_hazard)
    modApi.events.onPostEnvironment:subscribe(send_hazard)
    modApi.events.onGameExited:subscribe(unhook)
end

local function add_airstrike(self, spaces)
    return self:add_env_hazard("airstrike", Env_Airstrike, spaces)
end

local function add_final(self, spaces)
    return self:add_env_hazard("final", Env_Final, spaces)
end

local function add_lightning(self, spaces)
    return self:add_env_hazard("lightning", Env_Lightning, spaces)
end

local function add_snowstorm(self, spaces)
    return self:add_env_hazard("snowstorm", Env_SnowStorm, spaces)
end

local function add_wind(self, spaces)
    return self:add_env_hazard("wind", Env_RandomWind, spaces)
end

local function add_landfall(self, spaces)
    return self:add_env_hazard("landfall", Env_Seismic, spaces)
end

local function add_boss(self)
    if modApi:getGameState() ~= "Mission" then
        return false
    end

    local boss = self.gift_data.boss_enemies[math.random(1, 8)]
    Board:SpawnPawn(boss)
end

local function add_all_traps(self)
    return add_airstrike(self) and add_final(self) and add_lightning(self) and add_snowstorm(self)
        and add_wind(self) and add_landfall(self) and add_boss(self)
end

local function load_traps(self)
    local spaces = self.profile_manager:get_data("airstrike")
    if spaces then
        for i, space in pairs(spaces) do
            add_airstrike(self, space)
        end
    end
    spaces = self.profile_manager:get_data("final")
    if spaces then
        for i, space in pairs(spaces) do
            add_final(self, space)
        end
    end
    spaces = self.profile_manager:get_data("lightning")
    if spaces then
        for i, space in pairs(spaces) do
            add_lightning(self, space)
        end
    end
    spaces = self.profile_manager:get_data("snowstorm")
    if spaces then
        for i, space in pairs(spaces) do
            add_snowstorm(self, space)
        end
    end
    spaces = self.profile_manager:get_data("wind")
    if spaces then
        for i, space in pairs(spaces) do
            add_wind(self, space)
        end
    end
    spaces = self.profile_manager:get_data("landfall")
    if spaces then
        for i, space in pairs(spaces) do
            add_landfall(self, space)
        end
    end
end

local function init(self, profile_manager, gift_data)
    self.profile_manager = profile_manager
    self.gift_data = gift_data
    local function run_trap_loading()
        self:load_traps()
    end
    modApi.events.onContinueClicked:subscribe(run_trap_loading)
end

return {
    init = init,
    load_traps = load_traps,
    add_env_hazard = add_env_hazard,
    ["Airstrike Trap"] = add_airstrike,
    ["Boulder Trap"] = add_final,
    ["Lightning Trap"] = add_lightning,
    ["Snowstorm Trap"] = add_snowstorm,
    ["Wind Trap"] = add_wind,
    ["Landfall Trap"] = add_landfall,
    ["All Trap"] = add_all_traps,
    ["Boss Enemy Trap"] = add_boss
}
