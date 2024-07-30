local module = {}

local FIRST_ACHIEVEMENT_ID = 6777699702823011
local LAST_ACHIEVEMENT_ID = 6777699702823049

local function reset_unlocked_content()
    module.unlocked_items = {
        count = 0
    }
    module.profile_manager:set_data("unlocked_items", module.unlocked_items)
end

local function initialize_unlocked_content()
    module.unlocked_items = module.profile_manager:get_data("unlocked_items")
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
            if Game ~= nil then
                randomizer_helper.memedit.set_base_def((module.unlocked_items["3 Starting Grid Defense"] or 0) * 3)
            end
        elseif item_name == "2 Starting Grid Power" then
            if Game ~= nil then
                randomizer_helper.memedit.add_power(2)
            end
        elseif item_name == "1 Starting Grid Power" then
            if Game ~= nil then
                randomizer_helper.memedit.add_power(1)
            end
        elseif item_name == "1 Starting Power Core" then
            if Game ~= nil then
                randomizer_helper.memedit.add_cores(1)
            end
        elseif item_name == "3 Grid Power" then
            module.queue.power = module.queue.power + 3
            changed = true
        elseif item_name == "2 Power Cores" then
            module.queue.core = module.queue.core + 2
            changed = true
        elseif item_name == "Boss Enemy Trap" or item_name == "Airstrike Trap" or item_name == "Boulder Trap"
            or item_name == "Lightning Trap" or item_name == "Snowstorm Trap" or item_name == "Wind Trap"
            or item_name == "Landfall Trap" or item_name == "All Trap" then
            table.insert(module.queue.traps, item_name)
            changed = true
        elseif item_name == "New Game" then -- Dummy item to not rewrite the logic
            module.queue.dying = nil
            changed = true
        elseif item_name == "New Save" then -- Dummy item to not rewrite the logic
            module.queue = {}
            module.queue.power = 0
            module.queue.core = 0
            module.queue.traps = {}
            changed = true
        elseif item_name == "DeathLink" then
            if Game ~= nil then
                randomizer_helper.memedit.set_power(0)
            end
        end
    end

    if Game ~= nil then
        if module.queue.power then
            randomizer_helper.memedit.add_power(module.queue.power)
            module.queue.power = 0
            changed = true
        end
        if module.queue.core then
            randomizer_helper.memedit.add_cores(module.queue.core)
            module.queue.core = 0
            changed = true
        end
    end

    if modApi:getGameState() == "Mission" then
        if module.queue.dying then
            Game:ModifyPowerGrid(-100)
        end
    end

    local running = true
    while running and #module.queue.traps > 0 do
        if module.trap_handler[module.queue.traps[1]](module.trap_handler) then
            table.remove(module.queue.traps, 1)
            changed = true
        else
            running = false
        end
    end

    if (changed) then
        module.profile_manager:set_data("queued_items", module.queue)
    end
end

local function add_to_unlocked(item)
    LOG("index : " .. item.index)
    if (item.index < module.unlocked_items.count) then
        return true
    end

    local item_name = module.mapping.item_id_to_name[string.format("%.0f", item.item)]
    local previous_value = module.unlocked_items[item_name]

    LOG("Received " .. item_name)
    modApi.toasts:add({
        title = "Item Received",
        name = item_name,
        image = module.item_name_to_image[item_name]
    })

    if previous_value then
        module.unlocked_items[item_name] = previous_value + 1
    else
        module.unlocked_items[item_name] = 1
    end
    module.unlocked_items.count = module.unlocked_items.count + 1
    LOG("Current items : " .. json.encode(module.unlocked_items))
    module.profile_manager:set_data("unlocked_items", module.unlocked_items)
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
    module.AP:ConnectSlot(slot, password, items_handling, tags, { 0, 4, 6 })
end

local function win()
    module.profile_manager:set_data("Victory", true)
    module.frame = 0
end

function module:achievement_count()
    local achievements = 0
    for _, location_id in ipairs(self.AP.checked_locations) do
        if location_id <= LAST_ACHIEVEMENT_ID then
            achievements = achievements + 1;
        end
    end
    return achievements
end

local function check_win()
    local achievements = module:achievement_count()

    LOG("Cleared the game with " .. achievements .. " achievements (" .. module.required_achievements .. " required)"
        .. "Difficulty : " .. GetDifficulty() .. " (" .. module.difficulty .. " required)")
    if achievements >= module.required_achievements and GetDifficulty() >= module.difficulty then
        win()
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
        module.required_achievements = slot_data.required_achievements
        module.difficulty = slot_data.difficulty

        if not module.profile_manager:get_data("queued_locations") then
            module.profile_manager:set_data("queued_locations", {})
        end

        module.queue = module.profile_manager:get_data("queued_items")
        if module.queue == nil then
            module.handle_bonus("New Save")
        end

        module.islands_secured = module.profile_manager:get_data("islands_secured")
        if module.islands_secured == nil then
            module.islands_secured = 0
        end
        for island = 1, module.islands_secured do
            module.complete_location("Island " .. island .. " cleared")
        end

        initialize_unlocked_content()

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
        LOG("Added achievements")

        module.gift_API:open_giftbox(true, {})

        module.energylink_shop = require(module.mod.scriptPath .. "ap/energylink_shop")
        module.energylink_shop:init(module)

        module.progress_bar = require(module.mod.scriptPath .. "ap/progress_bar")
        module.progress_bar:init(module)

        module.trap_handler = require(module.mod.scriptPath .. "ap/trap_handler")
        module.trap_handler:init(module.profile_manager, module.gift_data)
    end
    module.ui:detach()
    module.ui = nil

    modApi.toasts.add = old_toast
    module.profile_initializing = false
    LOG("Finished initializing the randomizer")
end

local function on_items_received(items)
    local count = 0
    for _, item in ipairs(items) do
        if item.index == 0 then
            item.index = count
            count = count + 1
        end
        add_to_unlocked(item)
    end
end

local function on_location_checked(locations)
    local old_toast = modApi.toasts.add
    function modApi.toasts.add() -- just disable the toast for achievements
    end

    local queued_locations = module.profile_manager:get_data("queued_locations")
    for _, location_id in ipairs(locations) do
        local location_name = module.mapping.location_id_to_name[string.format("%.0f", location_id)]
        LOG("Checked location " .. location_name)
        if location_id <= LAST_ACHIEVEMENT_ID then
            local achievement = modApi.achievements:get("randomizer", location_name)
            achievement:completeProgress()
        end
        queued_locations[location_name] = nil
    end
    module.profile_manager:set_data("queued_locations", queued_locations)
    modApi.toasts.add = old_toast

    if module.progress_bar ~= nil then
        module.progress_bar:update()
    end
end

local function on_bounced(bounce)
    if not module.deathlink and not bounce.tags then
        return
    end

    for _, value in ipairs(bounce.tags) do
        if value == "DeathLink" then
            module.handle_bonus("DeathLink")
            return
        end
    end
end

local function on_retrieved(map, keys, extra_data)
    if extra_data.id == module.id then
        if extra_data.action == "get rep" then
            module.energylink_shop:update_energylink(map[module.energylink_shop.energylink_name])
        end
    end
end

local function on_set_reply(message)
    if message.id == module.id then
        if message.action == "take rep" then
            local change = message.original_value - message.value
            if change == module.energylink_shop.price and Game ~= nil then
                local rep = randomizer_helper.memedit.get_rep()
                randomizer_helper.memedit.set_rep(rep + 1)
                module.energylink_shop:update_energylink(message.value)
            else
                module.AP:Set(module.energylink_shop.energylink_name, 0, false,
                    {
                        { "add", change },
                    },
                    {
                        slot = module.energylink_shop.slot,
                    })
                module.energylink_shop:update_energylink(change)
            end
        elseif message.action == "give rep" then
            module.energylink_shop:update_energylink(message.value)
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
                    local point = Point(math.random(0, 7), math.random(0, 7))
                    local damage = SpaceDamage(point, 0)
                    damage.iShield = EFFECT_CREATE
                    Board:AddEffect(damage)
                end
            elseif trait_name == "Egg" then
                for _ = 1, amount, 1 do
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
    module.id = module.gift_API:generate_GUID("")

    module.AP:set_room_info_handler(on_room_info)
    module.AP:set_slot_connected_handler(on_slot_connected)
    module.AP:set_items_received_handler(on_items_received)
    module.AP:set_location_checked_handler(on_location_checked)
    module.AP:set_bounced_handler(on_bounced)
    module.AP:set_retrieved_handler(on_retrieved)
    module.AP:set_set_reply_handler(on_set_reply)

    if module.deathlink then
        randomizer_helper.events.on_game_lost:subscribe(on_defeat)
    end
end

local function keep_alive()
    if not module.initializing then
        if module.AP == nil then
            initialize_socket()
        else
            module.frame = module.frame + 1
            module.AP:poll()

            if not module.profile_initializing and module.frame % 60 == 0 then
                module.squad_randomizer.edit_squads()

                local locations = {}
                for location_name, _ in pairs(module.profile_manager:get_data("queued_locations")) do
                    local id = module.mapping.location_name_to_id[location_name]
                    if id == nil then
                        LOG("Error : failed checking location " .. location_name)
                    else
                        LOG("Checking location " .. location_name .. " ID : " .. tostring(id))
                        table.insert(locations, id)
                    end
                end
                if module.profile_manager:get_data("Victory")
                    and module.AP.ClientStatus ~= module.AP.ClientStatus.GOAL then
                    module.AP:StatusUpdate(module.AP.ClientStatus.GOAL)
                end

                if (#locations > 0) then
                    module.AP:LocationChecks(locations)
                end
            end
        end
    end
end

local function check_giftbox()
    module.gift_API:start_gift_recovery(-1)
end

function module.init(mod)
    module.frame = 0
    module.in_mission = false
    module.initializing = true
    module.profile_initializing = true
    module.mod = mod

    module.mapping = json.decode(File(mod.scriptPath .. "data/mapping.json"):read_to_string())
    module.item_name_to_image = require(mod.scriptPath .. "data/item_name_to_image")

    local ap_ui = require(mod.scriptPath .. "ap/ap_ui")(module)
    module.ap_dll = package.loadlib(mod.resourcePath .. "lib/lua-apclientpp.dll", "luaopen_apclientpp")()
    modApi.events.onGameVictory:subscribe(check_win)
    modApi.events.onMainMenuEntered:subscribe(ap_ui)
    modApi.events.onFrameDrawn:subscribe(keep_alive)
    modApi.events.onMissionStart:subscribe(check_giftbox)

    module.gift_data = require(mod.scriptPath .. "ap/gift_data")
end

function module.complete_location(location_name)
    if not list_contains(module.AP.checked_locations, module.mapping.location_name_to_id[location_name]) then
        local queued_locations = module.profile_manager:get_data("queued_locations")
        queued_locations[location_name] = true
        module.profile_manager:set_data("queued_locations", queued_locations)

        module.frame = 0
    end
end

local old_get_text = GetText
function GetText(id, r1, r2, r3)
    if id == "Gameover_Timeline" then
        on_defeat(randomizer_helper.tracking.last_attacker)
    elseif id == "Store_BuyTitle" then
        module.energylink_shop:show()
    elseif id == "Button_Select_Mission_Store" then
        local islands_secured = Game:GetSector()
        if islands_secured > module.islands_secured then
            module.profile_manager:set_data("islands_secured", islands_secured)
            module.islands_secured = islands_secured
            module.complete_location("Island " .. islands_secured .. " cleared")
        end
        module.energylink_shop:hide()
    end
    return old_get_text(id, r1, r2, r3)
end

return module
