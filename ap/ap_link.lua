local module = {}

local function reset_unlocked_content()
    module.unlocked_items = {
        ["Unlock Rift Walkers"] = 1,
        count = 1
    }
    modApi:writeProfileData("unlocked_items", module.unlocked_items)
end

local function initialize_unlocked_content()
    module.unlocked_items = modApi:readProfileData("unlocked_items")
    if module.unlocked_items == nil then
        reset_unlocked_content()
    end
end

-- Can be called with nil to recover the queued bonus
function module.handle_bonus(item_name)
    local changed = false
    if item_name ~= nil then
        if item_name == "3 Starting Grid Defense" then
            module.queue.starting_defense = module.queue.starting_defense + 3
            changed = true
        elseif item_name == "2 Starting Grid Power" then
            module.queue.starting_power = module.queue.starting_power + 2
            changed = true
        elseif item_name == "1 Grid Power" then
            module.queue.power = module.queue.power + 1
            changed = true
        elseif item_name == "-1 Grid Power" then
            module.queue.power = module.queue.power - 1
            changed = true
        elseif item_name == "New Game" then -- Dummy item to not rewrite the logic
            module.queue.starting_defense = 0
            module.queue.starting_power = 0
            module.queue.dying = false
            changed = true
        elseif item_name == "New Save" then -- Dummy item to not rewrite the logic
            module.queue = {}
            module.queue.starting_defense = 0
            module.queue.starting_power = 0
            module.queue.defense = 0
            module.queue.power = 0
            changed = true
        elseif item_name == "DeathLink" then
            if Game ~= nil then
                module.queue.dying = true
                changed = true
            end
        end
    end

    if modApi:getGameState() == "Mission" then
        if module.queue.dying then
            Game:ModifyPowerGrid(-100)
        end

        if module.queue.starting_defense ~= 0 or module.queue.defense ~= 0 then
            local resist = Game:GetResist()
            resist = resist + module.queue.starting_defense + module.queue.defense
            Game:SetResist(resist)
            randomizer_helper.tracking.last_overload = resist

            module.queue.starting_defense = 0
            module.queue.defense = 0
            changed = true
        end

        if module.queue.starting_power ~= 0 or module.queue.power ~= 0 then
            local power = module.queue.starting_power + module.queue.power
            while power > 0 do
                Game:ModifyPowerGrid(SERIOUSLY_JUST_ONE)
                power = power - 1
            end
            if power < 0 then
                Game:ModifyPowerGrid(power)
            end
            module.queue.starting_power = 0
            module.queue.power = 0
            changed = true
        end
    end

    if (changed) then
        modApi:writeProfileData("queued_items", module.queue)
    end
end

local function add_to_unlocked(item)
    if (item.index < module.unlocked_items.count) then
        return true
    end

    local item_name = module.AP:get_item_name(item.item)
    local previous_value = module.unlocked_items[item_name]

    if previous_value then
        module.unlocked_items[item_name] = previous_value + 1
    end
    module.unlocked_items[item_name] = 1
    module.unlocked_items.count = module.unlocked_items.count + 1
    modApi:writeProfileData("unlocked_items", module.unlocked_items)
    module.handle_bonus(item_name)
    return true
end

local function on_room_info()
    local slot = module.slot
    local password = module.password
    local items_handling = tonumber("111", 2)
    local tags = {"Lua-APClientPP"}
    if module.deathlink then
        table.insert(tags, "DeathLink")
    end
    module.AP:ConnectSlot(slot, password, items_handling, tags, {0, 4, 1})
end

local function on_slot_connected(slot_data)
	local squad_randomizer = require(module.mod.scriptPath .. "squad_randomizer")
    function module.randomize_squad()
        squad_randomizer.edit_squads(module.mod, slot_data)
    end
    module.randomize_squad()

    module.ui:detach()
    module.ui = nil
end

local function on_items_received(items)
    local count = 1
    for _, item in ipairs(items) do
        if item.index == 0 then
            item.index = count
            count = count + 1
        end
        add_to_unlocked(item)
    end
end

local function on_location_checked(locations)
    for _, location_name in ipairs(locations) do
        module.queued_locations[module.AP:get_location_id(location_name)] = nil
    end
end

local function on_bounced(bounce)
    if not module.deathlink then
        return
    end

    for index, value in ipairs(bounce.tags) do
        if value == "DeathLink" then
            module.handle_bonus("DeathLink")
            return
        end
    end
end

local function on_defeat(killer)
    module.randomize_squad()

    if module.deathlink and module.queue ~= nil and not module.queue.dying then
        module.queue.dying = true
        local cause
        if killer == nil then
            cause = module.slot .. " didn't feel like saving the world."
        else
            cause = module.slot .. "'s grid fell against a " .. killer .. "."
        end
        local data = {
            time = module.AP:get_server_time(),
            cause = cause,
            source = module.slot
        }
        module.AP:Bounce(data, nil, nil, {"DeathLink"})
    end
end

local function initialize_socket()
    local very_unique_id = ""
    local game_name = "Into the Breach"
    local server = module.server

    module.AP = module.ap_dll(very_unique_id, game_name, server)

    module.AP:set_room_info_handler(on_room_info)
    module.AP:set_slot_connected_handler(on_slot_connected)
    module.AP:set_items_received_handler(on_items_received)
    module.AP:set_location_checked_handler(on_location_checked)
    module.AP:set_bounced_handler(on_bounced)

    if module.deathlink then
        randomizer_helper.events.on_game_lost:subscribe(on_defeat)
    end
end

local function keep_alive()
    if not module.initializing then
        module.frame = module.frame + 1
        if module.AP == nil then
            initialize_socket()
        else
            module.AP:poll()

            if module.AP:get_state() == module.AP.State.SLOT_CONNECTED and module.frame % 60 == 0 then
                local locations = {}
                for location_name, _ in pairs(module.queued_locations) do
                    if location_name == "Victory" then
                        module.AP:StatusUpdate(module.AP.ClientStatus.GOAL)
                    else
                        table.insert(locations, module.AP:get_location_id(location_name))
                    end
                end
                module.AP:LocationChecks(locations)

                module.queued_locations = {}
            end
        end
    end
end

local function win()
    module.queued_locations["Victory"] = true
    modApi:writeProfileData("victory", true)
    module.frame = 0
end

function module.init(mod)
    module.frame = 0
    module.queue = modApi:readProfileData("queued_items")
    module.queued_locations = {}
    module.in_mission = false
    module.initializing = true
    module.mod = mod

    if module.queue == nil then
        module.handle_bonus("New Save")
    end

    if modApi:readProfileData("victory") then
        win()
    end

    initialize_unlocked_content()

	local ap_ui = require(mod.scriptPath .. "ap/ap_ui")(module)
    module.ap_dll = package.loadlib(mod.resourcePath .. "lib/lua-apclientpp.dll", "luaopen_apclientpp")()
    modApi.events.onGameVictory:subscribe(win)
    modApi.events.onMainMenuEntered:subscribe(ap_ui)
    modApi.events.onFrameDrawn:subscribe(keep_alive)
end

function module.complete_location(location_name)
    module.queued_locations[location_name] = true
    module.frame = 0
end

local old_get_text = GetText
function GetText(id, r1, r2, r3)
    if id == "Gameover_Timeline" then
        on_defeat(randomizer_helper.tracking.last_attacker)
    end
    return old_get_text(id, r1, r2, r3)
end

return module
