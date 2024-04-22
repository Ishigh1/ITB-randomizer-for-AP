local module = {}

local function reset_unlocked_content()
    module.unlocked_items = {
        ["Rift Walkers"] = 1,
        count = 1
    }
    module.profile_manager.set_data("unlocked_items", module.unlocked_items)
end

local function initialize_unlocked_content()
    module.unlocked_items = module.profile_manager.get_data("unlocked_items")
    if module.unlocked_items == nil then
        LOG("Creating unlocked items")
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
        elseif item_name == "Boss Enemy" then
            module.queue.boss = module.queue.boss + 1
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
            module.queue.boss = 0
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

        if module.queue.boss > 0 then
            for i = 1, module.queue.boss, 1 do
                local boss = module.gift_data.boss_enemies[math.random(1, 8)]
                Board:SpawnPawn(boss)
            end
        end
    end

    if (changed) then
        module.profile_manager.set_data("queued_items", module.queue)
    end
end

local function add_to_unlocked(item)
    LOG("index : " .. item.index)
    if (item.index < module.unlocked_items.count) then
        return true
    end

    local item_name = module.AP:get_item_name(item.item)
    local previous_value = module.unlocked_items[item_name]

    LOG("Received " .. item_name)
    modApi.toasts:add({
        title = "Item Received",
        name = item_name
    })

    if previous_value then
        module.unlocked_items[item_name] = previous_value + 1
    else
        module.unlocked_items[item_name] = 1
    end
    module.unlocked_items.count = module.unlocked_items.count + 1
    LOG("Current items : " .. randomizer_helper.tools.tprint(module.unlocked_items))
    module.profile_manager.set_data("unlocked_items", module.unlocked_items)
    module.handle_bonus(item_name)
    return true
end

local function on_room_info()
    local slot = module.slot
    local password = module.password
    local items_handling = tonumber("111", 2)
    local tags = { "Lua-APClientPP" }
    if module.deathlink then
        table.insert(tags, "DeathLink")
    end
    if module.hint then
        table.insert(tags, "TextOnly")
    end
    module.AP:ConnectSlot(slot, password, items_handling, tags, { 0, 4, 1 })
end

local function make_profile()
    local file = Directory.savedata():directory("profile_" .. Settings.last_profile):file("profile.lua")
    if not file:exists() then
        file:make_directories()
        modApi:copyFile(module.mod.scriptPath .. "data/profile.lua",
            GetSavedataLocation() .. "profile_" .. Settings.last_profile .. "/profile.lua")
    end
end

local function win()
    if module.hint then -- Waiting for item scouting to exist
        -- if GetDifficulty()
    else
        module.queued_locations["Victory"] = true
        module.profile_manager.set_data("victory", true)
        module.frame = 0
    end
end

local function on_slot_connected(slot_data)
    LOG("Preparing profile...")
    local old_toast = modApi.toasts.add
    if not module.hint then
        function modApi.toasts.add() -- just disable the toast for achievements
        end

        local seed_name = module.AP:get_seed()
        module.profile_manager = require(module.mod.scriptPath .. "profile_manager")(module, seed_name, module.slot)
        module.mod.profile_manager = module.profile_manager

        module.custom = slot_data.custom

        module.queue = module.profile_manager.get_data("queued_items")
        if module.queue == nil then
            module.handle_bonus("New Save")
        end

        initialize_unlocked_content()

        if module.profile_manager.get_data("victory") then
            win()
        end

        module.squad_randomizer = require(module.mod.scriptPath .. "squad_randomizer")
        module.squad_randomizer.slot_data = slot_data.squads
        module.squad_randomizer.ap_link = module
        module.squad_randomizer.edit_squads()

        module.squad_lock = require(module.mod.scriptPath .. "squad_lock")
        module.squad_lock.initialize(module)
        require(module.mod.scriptPath .. "upgrades").initialize(module.mod)

        modApi.achievements.canBeAdded = function()
            return true
        end
        local achievements = require(module.mod.scriptPath .. "achievements/global")
        achievements.initialize(module.mod)
        achievements.add_achievements()

        module.gift_API:open_giftbox(true, {})
    end
    module.ui:detach()
    module.ui = nil

    modApi.toasts.add = old_toast
    module.profile_initializing = false
    LOG("Finished initializing the randomizer")
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
    if not module.hint then
        module.squad_randomizer.edit_squads()
    end

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
        module.AP:Bounce(data, nil, nil, { "DeathLink" })
    end
end

local function on_gift_notification()
    if GetCurrentMission() == modApi.current_mission then
        module.gift_API:start_gift_recovery(-1)
    end
end

local function on_gift_received(gift)
    local name = gift.Amount .. " * " .. gift.ItemName
    LOG("Received " .. name)
    if GetCurrentMission() == modApi.current_mission then
        local handled = false
        for _, v in pairs(gift.Traits) do
            local trait_name = v.Trait
            local amount = v.Duration * gift.Amount
            local quality = v.Quality
            local strength = quality * amount
            if trait_name == "Armor" then
                for i = 0.5, strength, 0.5 do
                    handled = true
                    local point = Point(math.random(1, 8), math.random(1, 8))
                    local damage = SpaceDamage(point, 0)
                    damage.iShield = EFFECT_CREATE
                    Board:AddEffect(damage)
                end
            elseif trait_name == "Egg" then
                for i = 1, amount, 1 do
                    handled = true
                    local spawn_name
                    if math.random(1, 100 * quality) < 50 then
                        spawn_name = module.gift_data.enemy_gift[GAME.Island][math.random(1, 5)]
                    else
                        spawn_name = module.gift_data.ally_gift[math.random(1, 5)]
                    end
                    Board:SpawnPawn(spawn_name)
                end
            end
        end
        if handled then
            modApi.toasts:add({
                title = "Gift Received",
                name = name
            })
        end
        return handled
    end
    return false
end

local function initialize_socket()
    LOG("Initializing Socket")

    local very_unique_id = ""
    local game_name
    if not module.hint then
        game_name = "Into the Breach"
    end
    local server = module.server

    module.AP = module.ap_dll(very_unique_id, game_name, server)
    module.gift_API = require(module.mod.scriptPath .. "ap/gift-api/init")
    module.gift_API:init(module.AP)
    module.gift_API:set_gift_notification_handler(on_gift_notification)
    module.gift_API:set_gift_handler(on_gift_received)

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

            if not module.profile_initializing and module.frame % 60 == 0 then
                module.squad_randomizer.edit_squads()

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

local function check_giftbox()
    module.gift_API:start_gift_recovery(-1)
end

function module.init(mod)
    module.frame = 0
    module.queued_locations = {}
    module.in_mission = false
    module.initializing = true
    module.profile_initializing = true
    module.mod = mod

    local ap_ui = require(mod.scriptPath .. "ap/ap_ui")(module)
    module.ap_dll = package.loadlib(mod.resourcePath .. "lib/lua-apclientpp.dll", "luaopen_apclientpp")()
    modApi.events.onGameVictory:subscribe(win)
    modApi.events.onMainMenuEntered:subscribe(ap_ui)
    modApi.events.onFrameDrawn:subscribe(keep_alive)
    modApi.events.onMissionStart:subscribe(check_giftbox)

    module.gift_data = require(mod.scriptPath .. "ap/gift_data")
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
