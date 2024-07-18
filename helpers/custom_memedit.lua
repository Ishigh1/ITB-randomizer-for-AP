assert(modApi.gameVersion == "1.2.93")

local AccessEnum               = {
    R = 0,
    W = 1,
    RW = 2,
}

local TypeEnum                 = {
    int = 0,
    unsigned_int = 1,
    byte = 2,
    bool = 3,
    double = 4,
    string = 5,
    IntList = 6,
    SharedVoidPtrList = 7,
}

local addresses_and_options    = memedit:loadAddressesFromFile()

-- The following can be omitted, but they are additional flags that can be helpful.
addresses_and_options.silent   = false
addresses_and_options.debug    = false
addresses_and_options.hex      = true
addresses_and_options.verbose  = false

-- Now add your own addresses to game for example
addresses_and_options.game.Rep = { 0x848C, AccessEnum.RW, TypeEnum.int }
addresses_and_options.game.Cores = { 0x8490, AccessEnum.RW, TypeEnum.int }
addresses_and_options.game.Power = { 0xC040, AccessEnum.RW, TypeEnum.int }
addresses_and_options.game.MaxPower = { 0xC044, AccessEnum.RW, TypeEnum.int }
addresses_and_options.game.BaseDef = { 0xC11C, AccessEnum.RW, TypeEnum.int }
addresses_and_options.game.PilotDef = { 0xC128, AccessEnum.R, TypeEnum.int }
-- addresses_and_options.game.OverloadDef = { 0xC174, AccessEnum.RW, TypeEnum.int }
addresses_and_options.game.Seed = { 0xC178, AccessEnum.RW, TypeEnum.int }
-- { address, access_enum, type_enum }

-- Then create a shallow copy of the memedit tool, and load it with our altered address list.
-- This loads memedit into `my_memedit.dll`
local custom_memedit           = shallow_copy(memedit)
custom_memedit:load(addresses_and_options)

local custom_memedit_methods = {
    memedit = custom_memedit,
    get_rep = custom_memedit.dll.game.getRep,
    set_rep = custom_memedit.dll.game.setRep,
    get_cores = custom_memedit.dll.game.getCores,
    set_cores = custom_memedit.dll.game.setCores,
    get_power = custom_memedit.dll.game.getPower,
    set_power = custom_memedit.dll.game.setPower,
    get_max_power = custom_memedit.dll.game.getMaxPower,
    get_seed = custom_memedit.dll.game.getSeed,
    get_base_def = custom_memedit.dll.game.getBaseDef,
    set_base_def = custom_memedit.dll.game.setBaseDef,
}

function custom_memedit_methods.add_overload(overload)
    local current_overload = Game:GetResist()
    current_overload = current_overload + overload * 2
    if current_overload > 10 then
        local extra_overload = (current_overload - 10) / 2
        current_overload = extra_overload - math.min(extra_overload, overload)
        if current_overload > 25 then
            current_overload = 25
        end
    end
    Game:SetResist(current_overload)
end

function custom_memedit_methods.add_power(power)
    local current_power = custom_memedit_methods.get_power()
    local max_power = custom_memedit_methods.get_max_power()
    local total_power = current_power + power
    if total_power <= max_power then
        custom_memedit_methods.set_power(total_power)
    else
        custom_memedit_methods.set_power(max_power)
        custom_memedit_methods.add_overload(total_power - max_power)
    end
end

function custom_memedit_methods.add_cores(cores)
    local current_cores = custom_memedit_methods.get_cores()
    custom_memedit_methods.set_cores(current_cores + cores)
end

return custom_memedit_methods
