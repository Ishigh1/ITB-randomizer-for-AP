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

function module.edit_squads(mod, slot_data)
	modApi.squadIndices = {}
	modApi.currentMod = mod

	for index = 1, modApi.constants.MAX_SQUADS do
		local vanilla_squad = modApi.mod_squads[index]
		local squad_name = vanilla_squad[1]
		local squad = slot_data[squad_name]
		if squad ~= nil then
			modApi:addSquad(
				{squad_name, squad[1], squad[2], squad[3], id = "squad" .. index}, 
				"squad" .. index, 
				modApi.squad_text[index * 2], 
				modApi.squad_icon[index])

			modApi.squadIndices[index] = #modApi.mod_squads
		else
			modApi.squadIndices[index] = index
		end
	end
    save_squad_selection()
	modApi.currentMod = mod
end

return module