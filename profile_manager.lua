return function(ap_link, seed_name, slot)
    local all_profiles = modApi:readProfileData("randomizer_profiles")
    if all_profiles == nil then
        all_profiles = {}
    end

    local current_profile = all_profiles[seed_name .. "|" .. slot]
    if current_profile == nil then
        current_profile = {}
        all_profiles[seed_name] = current_profile
        modApi:writeProfileData("randomizer_profiles", all_profiles)
    end

    local module = {}

    function module.get_data(name)
        return current_profile[name]
    end

    function module.set_data(name, value)
        current_profile[name] = value
        modApi:writeProfileData("randomizer_profiles", all_profiles)
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
        modApi:writeProfileData("randomizer_profiles", all_profiles)
    end

    function module.register_achievement(achievement, team)
        function achievement:is_active()
            return GAME ~= nil and not self:isComplete() and (
                GAME.additionalSquadData.squad == team --When outside of battle
                or GAME.additionalSquadData.squad == self.squad -- When in battle
        )
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
            achievement:addProgress(progress)
        end

        local old_add_progress = achievement.addProgress
        function achievement:addProgress(progress)
            old_add_progress(self, progress)
            achievement:set_achievement_data("progress", achievement:getProgress())
        end
    end

    return module
end