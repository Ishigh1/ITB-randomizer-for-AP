local function metadata(self)
end

local function init(self, options)
	require(self.scriptPath .. "helpers/randomizer_helper")
	require(self.scriptPath .. "helpers/GameEvents")

	self.ap_link = require(self.scriptPath .. "ap/ap_link")
	require(self.scriptPath .. "unimplemented_units")

	self.ap_link.init(self)
end

local function load(self, options, version)
	LOG("Don't forget to makeitso")
end

local function find(ui, classes, path)
	for key, value in pairs(ui) do
		for k, v in pairs(classes) do
			if value == v then
				classes[k] = nil
				
				LOG(k)
				LOG(path)
				LOG(k)
				return
			end
		end
	end
end 

function FindClasses()
	local ui = sdlext.getUiRoot()
	local classes = {"Prime", "Brute", "Ranged", "Science", "Cyborg"}
	local stack = {{ui, ""}}
	local attempts = 0
	while classes ~= {} and #stack ~= 0 do
		local info = table.remove(stack)
		local ui = info[1]
		local path = info[2]
		local attempts = attempts + 1
		if attempts % 10 == 0 then
			LOG("Failed " .. path)
		end

		for i, child in pairs(ui.children) do
			local new_path = path .. tostring(i)
			if child.children == nil or child.children == {} then
				find(child, classes, new_path)
			else
				find(child, classes, new_path)
				table.insert(stack, {ui, new_path})
			end
		end
	end
end

return {
	id = "randomizer",
	name = "Randomizer",
	description = "AP randomizer",
	version = "1.0.0",
	modApiVersion = "2.9.2",
	requirements = {},
	metadata = metadata,
	init = init,
	load = load,
}