local module = {}

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

function module.edit_squads(slot_data)
	if modApi.squad_text[1] == "squad1" then
		return
	end

	modApi.squadIndices = {}
	modApi.mod_squads_by_id = {}
	modApi.currentMod = "randomizer"
	local old_squads = modApi.mod_squads
	local old_text = modApi.squad_text
	local old_icon = modApi.squad_icon
	
	modApi.mod_squads = {}
	modApi.squad_text = {}
	modApi.squad_icon = {}

	for index = 1, modApi.constants.MAX_SQUADS do
		local vanilla_squad = old_squads[index]
		local squad_name = vanilla_squad[1]
		local squad
		if slot_data == nil or slot_data[squad_name] == nil then
			squad = {
				vanilla_squad[2],
				vanilla_squad[3],
				vanilla_squad[4],
			}
		else
			squad = slot_data[squad_name]
		end
		modApi:addSquad(
			{squad_name, squad[1], squad[2], squad[3], id = "squad" .. index}, 
			"squad" .. index, 
			old_text[index * 2], 
			old_icon[index])

		modApi.squadIndices[index] = #modApi.mod_squads
	end
    save_squad_selection()
end

return module