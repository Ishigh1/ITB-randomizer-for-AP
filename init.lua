local function metadata(self)
end

local function init(self, options)
    json = require(self.resourcePath .. "lib/json")

    require(self.scriptPath .. "helpers/randomizer_helper")
    randomizer_helper.memedit = require(self.scriptPath .. "helpers/custom_memedit")
    require(self.scriptPath .. "helpers/GameEvents")

    self.ap_link = require(self.scriptPath .. "ap/ap_link")
    require(self.scriptPath .. "unimplemented_units")

    self.ap_link.init(self)
end

local function load(self, options, version)
    LOG("Randomizer version " .. version .. " loaded")
    LOG("Don't forget to makeitso if you didn't run the command once on this profile")
end

return {
    id = "randomizer",
    name = "Randomizer",
    description = "AP randomizer",
    version = "0.15.4",
    modApiVersion = "2.9.3",
    requirements = {},
    metadata = metadata,
    init = init,
    load = load,
}
