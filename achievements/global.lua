local module = {}

function module.initialize(mod)
    module.ap_link = mod.ap_link
    module.mod = mod
    module.path = mod.scriptPath .. "achievements/"
end

local function complete_achievement(achievement)
    module.ap_link.complete_location(achievement.name)
end

local function initialize_achievement(achievement, team, id, name)
    achievement.addReward = complete_achievement
    local achievement_module = require(module.path .. string.lower(team))
    achievement_module["initialize_achievement_" .. id](achievement, module.mod)

    modApi.achievements:add(achievement)
    achievement = modApi.achievements:get("randomizer", name)
    function achievement:is_active()
        return GAME ~= nil and not self:isComplete() and (
            GAME.additionalSquadData.squad == team --When outside of battle
            or GAME.additionalSquadData.squad == self.squad -- When in battle
    )
    end
    achievement_module["achievement" .. id] = achievement
end

function module.add_achievements()
    module.name_to_id = {}
    local squad_names = {
        "Archive_A",
        "Rust_A", 
        "Pinnacle_A", 
        "Detritus_A",
        "Archive_B", 
        "Rust_B",
        "Pinnacle_B",
        "Detritus_B"
    }

    for squad_index, squad_name in ipairs(squad_names) do
        for i = 1, 3, 1 do
            local name = GetVanillaText("Ach_" .. squad_name .. "_" .. i .. "_Title")
            local tooltip = GetVanillaText("Ach_" .. squad_name .. "_" .. i .. "_Text")
            local progress_key = "Ach_" .. squad_name .. "_" .. i .. "_Progress"
            local progress = GetVanillaText(progress_key)
            if progress ~= progress_key then
                progress = string.gsub(progress, "%$1", "$")
                tooltip = tooltip .. "\n" .. progress
            end

            local achievement = {
                id = name,
                name = name,
                tooltip = tooltip,
                image = "img/achievements/" .. squad_name .. "_" .. i .. ".png",
                squad = "squad" .. squad_index
            }

            initialize_achievement(achievement, squad_name, i, name)
        end
    end
end

return module
