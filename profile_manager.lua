return function(ap_link, seed_name, slot)
    local all_profiles = modApi:readProfileData("randomizer_profiles")
    local new = false
    if all_profiles == nil then
        all_profiles = {}
    end

    local profile_path = seed_name .. "|" .. slot
    local current_profile = all_profiles[profile_path]
    if current_profile == nil then
        current_profile = {}
        all_profiles[profile_path] = current_profile
        modApi:writeProfileData("randomizer_profiles", all_profiles)
    end

    local module = {}

    function module.get_data(name)
        return current_profile[name]
    end

    function module.set_data(name, value)
        current_profile[name] = value
        new = true
    end

    function module.get_achievement_data(achievement, name)
        local achievement_data = current_profile[achievement.id]
        if achievement_data ~= nil then
            return achievement_data[name]
        end
    end

    function module.set_achievement_data(achievement, name, value)
        local achievement_data = current_profile[achievement.id]
        if achievement_data == nil then
            achievement_data = {}
            current_profile[achievement.id] = achievement_data
        end
        achievement_data[name] = value
        new = true
    end

    function module.register_achievement(achievement, team)
        if ap_link.custom then
            function achievement:is_active()
                return GAME ~= nil and not self:isComplete() and (Board == nil or not modapiext.weapon:isTipImage())
            end
        else
            function achievement:is_active()
                return GAME ~= nil and not self:isComplete() and (
                    GAME.additionalSquadData.squad == team --When outside of battle
                    or (GAME.additionalSquadData.squad == self.squad and -- When in battle
                    (Board == nil or --Just exiting a battle
                    not modapiext.weapon:isTipImage())) -- Avoid counting weapon preview
            )
            end
        end

        function achievement:get_data(name)
            return module.get_achievement_data(achievement, name)
        end

        function achievement:set_data(name, value)
            module.set_achievement_data(achievement, name, value)
        end

        achievement:resetProgress()

        function achievement:addReward()
            ap_link.complete_location(self.name)
        end

        local progress = achievement:get_data("progress")
        if progress ~= nil then
            achievement:setProgress(progress)
        end

        local old_set_progress = achievement.setProgress
        function achievement:setProgress(progress)
            old_set_progress(self, progress)
            achievement:set_data("progress", achievement:getProgress())
        end
    end

    local function save_data()
        if new then
            modApi:writeProfileData("randomizer_profiles", all_profiles)
            new = false
        end
    end

    modApi.events.onSaveDataUpdated:subscribe(save_data)

    return module
end