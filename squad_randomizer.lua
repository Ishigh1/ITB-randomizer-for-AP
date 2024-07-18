local module = {}

module.vanilla_squads = copy_table(modApi.mod_squads)

local function save_squad_selection()
    local selected = {}
    for i = 1, modApi.constants.MAX_SQUADS do
        local index = modApi.squadIndices[i]
        local name = modApi.squad_text[(index - 1) * 2 + 1]
        selected[i] = name
    end

    local modcontent = modApi:getCurrentModcontentPath()

    sdlext.config(modcontent, function(obj)
        obj.selectedSquads = selected
    end)
end

function module.random_squad(index)
    local vanilla_squad = module.vanilla_squads[index]
    local squad_name = vanilla_squad[1]
    local squad
    if module.slot_data == nil or module.slot_data[squad_name] == nil then
        squad = { vanilla_squad[2], vanilla_squad[3], vanilla_squad[4] }
    else
        squad = module.slot_data[squad_name]
    end

    return {
        squad_name,
        squad[1],
        squad[2],
        squad[3],
        id = "squad" .. index
    }
end

function module.edit_squads()
    if modApi.squad_text[1] == "squad1" then
        return
    end

    modApi.squadIndices = {}
    modApi.mod_squads_by_id = {}
    modApi.currentMod = "randomizer"
    local old_text = modApi.squad_text
    local old_icon = modApi.squad_icon

    modApi.mod_squads = {}
    modApi.squad_text = {}
    modApi.squad_icon = {}
    module.squads = {
        Prime = {},
        Brute = {},
        Ranged = {},
        Science = {},
        TechnoVek = {}
    }

    for index = 1, modApi.constants.MAX_SQUADS do
        local squad = module.random_squad(index)
        for i = 2, 4, 1 do
            local unit = _G[squad[i]]
            table.insert(module.squads[unit.Class], squad[1])
        end
        modApi:addSquad(squad, squad[1], old_text[index * 2], old_icon[index])

        modApi.squadIndices[index] = #modApi.mod_squads
    end
    save_squad_selection()
end

return module
