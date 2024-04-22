local module = {}

function module.initialize(mod)
    module.ap_link = mod.ap_link
    module.mod = mod
    module.profile_manager = mod.profile_manager
    module.path = mod.scriptPath .. "achievements/"
end

local function initialize_achievement(achievement, team, id, name)
    local achievement_module = require(module.path .. string.lower(team))
    achievement_module["initialize_achievement_" .. id](achievement, module.mod)

    modApi.achievements:add(achievement)
    achievement = modApi.achievements:get("randomizer", name)

    achievement_module["achievement" .. id] = achievement
    module.profile_manager.register_achievement(achievement, team)
end

function module.add_achievements()
    module.name_to_id = {}
    local squad_names =
    {
        "Archive_A",
        "Rust_A",
        "Pinnacle_A",
        "Detritus_A",
        "Archive_B",
        "Rust_B",
        "Pinnacle_B",
        "Detritus_B",
        "", -- secret doesn't have any achievement
        "Squad_Bomber",
        "Squad_Spiders"
    }

    local image_prefix = "img/achievements/"
    for squad_index, squad_name in ipairs(squad_names) do
        if squad_name == "" then
            image_prefix = "img/advanced/achievements/"
        else
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
                    image = image_prefix .. squad_name .. "_" .. i .. ".png",
                    squad = "squad" .. squad_index
                }

                initialize_achievement(achievement, squad_name, i, name)
            end
        end
    end
end

return module
