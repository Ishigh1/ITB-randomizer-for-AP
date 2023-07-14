local function metadata(self)
end

local function init(self, options)
	require(self.scriptPath .. "helpers/randomizer_helper")
	require(self.scriptPath .. "helpers/GameEvents")

	self.run_post_load = {}
	modApi.events.onModsLoaded:subscribe(function()
		for _, f in ipairs(self.run_post_load) do
			f()
		end
	end)

	self.run_post_mission = {}
	modApi.events.onMissionEnd:subscribe(function()
		for _, f in ipairs(self.run_post_mission) do
			f()
		end
		self.run_post_mission = nil
	end)

	self.ap_link = require(self.scriptPath .. "ap/ap_link")
	require(self.scriptPath .. "unimplemented_units")

	local achievements = require(self.scriptPath .. "achievements/global")
	achievements.initialize(self)
	achievements.add_achievements()

	self.ap_link.init(self)
end

local function load(self, options, version)
	require(self.scriptPath .. "squad_lock").initialize(self)
	require(self.scriptPath .. "upgrades").initialize(self)
	LOG("Don't forget to makeitso")
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