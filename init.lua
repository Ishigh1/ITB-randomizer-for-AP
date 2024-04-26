local function metadata(self)
end

local function init(self, options)
    require(self.scriptPath .. "helpers/randomizer_helper")
    randomizer_helper.memedit = require(self.scriptPath .. "helpers/custom_memedit")
    require(self.scriptPath .. "helpers/GameEvents")

    self.ap_link = require(self.scriptPath .. "ap/ap_link")
    require(self.scriptPath .. "unimplemented_units")

    self.ap_link.init(self)
end

local function load(self, options, version)
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
