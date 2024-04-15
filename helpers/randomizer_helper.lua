randomizer_helper = {
    events = {},
    tracking = {},
    utils = {}
}
randomizer_helper.events.on_vek_action_change = Event()
randomizer_helper.events.on_overload_change = Event()
randomizer_helper.events.on_building_damaged = Event()
randomizer_helper.events.on_tile_fire = Event()
randomizer_helper.events.on_tile_shield = Event()
randomizer_helper.events.on_game_lost = Event()

randomizer_helper.events.on_attack = Event()

-- Things might look weird because I have to take in account the fact that most hooks in-game happen one frame after attack order changes
randomizer_helper.tracking.current_action = ATTACK_ORDER_IDLE
local next_action = ATTACK_ORDER_IDLE

randomizer_helper.tracking.board = {}

local function reset_board_tracking()
    randomizer_helper.tracking.board = {}
    randomizer_helper.tracking.board_reset = true
end

local function reset_game_tracking()
    randomizer_helper.tracking.last_overload = nil
    reset_board_tracking()
end

local function make_tracking()
    for tile_index, tile in ipairs(Board) do
        local tracking_content = {}
        tracking_content.health = Board:GetHealth(tile)
        tracking_content.fire = Board:IsFire(tile)
        tracking_content.shield = Board:IsShield(tile)

        randomizer_helper.tracking.board[tile] = tracking_content
    end
end

local function register_game_changes()
    if modApi:getGameState() == "Mission" then
        if randomizer_helper.tracking.board_reset then
            make_tracking()
            randomizer_helper.tracking.board_reset = false
        end

        randomizer_helper.tracking.current_action = next_action
        next_action = memedit:require().board.getAttackOrder()
        if next_action ~= randomizer_helper.tracking.current_action then
            randomizer_helper.events.on_vek_action_change:dispatch(next_action)
        end

        for point, old_content in pairs(randomizer_helper.tracking.board) do
            if Board:IsBuilding(point) and Board:GetHealth(point) ~= old_content.health then
                randomizer_helper.events.on_building_damaged:dispatch()
                old_content.health = Board:GetHealth(point)
            end

            if Board:IsFire(point) ~= old_content.fire then
                local new_fire = not old_content.fire
                old_content.fire = new_fire
                randomizer_helper.events.on_tile_fire:dispatch(new_fire)
            end

            if Board:IsShield(point) ~= old_content.shield then
                local new_shield = not old_content.shield
                old_content.shield = new_shield
                randomizer_helper.events.on_tile_shield:dispatch(new_shield)
            end
        end
    else
        randomizer_helper.tracking.board = {}
        randomizer_helper.tracking.last_attacker = nil
    end

    if Game ~= nil then
        local overload = Game:GetResist()
        if overload ~= randomizer_helper.tracking.last_overload then
            if randomizer_helper.tracking.last_overload ~= nil then
                randomizer_helper.events.on_overload_change:dispatch(overload - randomizer_helper.tracking.last_overload)
            end
            randomizer_helper.tracking.last_overload = overload
        end
    end
end

local function register_attack(mission, pawn, weapon_id, p1, p2)
    randomizer_helper.tracking.last_attacker = pawn:GetMechName()
    randomizer_helper.events.on_attack:dispatch(mission, pawn, weapon_id, p1, p2)
end


modApi.events.onFrameDrawn:subscribe(register_game_changes)
modApi.events.onMissionStart:subscribe(reset_board_tracking)
modApi.events.onPostLoadGame:subscribe(reset_game_tracking)
modApi.events.onPostStartGame:subscribe(reset_game_tracking)

modapiext.events.onSkillStart:subscribe(register_attack)
modapiext.events.onFinalEffectStart:subscribe(register_attack)
modapiext.events.onQueuedSkillStart:subscribe(register_attack)
modapiext.events.onQueuedFinalEffectStart:subscribe(register_attack)

function randomizer_helper.utils.compute_push(effects)
    local pushs = {}
    for i = 1, effects:size() do
        local space_damage = effects:index(i)
        local loc = space_damage.loc
        local pawn = Board:GetPawn(loc)
        if pawn ~= nil and space_damage.iPush <= 3 and not pawn:IsGuarding() then
            pushs[loc] = loc + DIR_VECTORS[space_damage.iPush]
        end
    end

    local free_spaces = {}
    local moved = true
    while moved do
        moved = false
        for pawn_loc, target_loc in pairs(pushs) do
            local terrain = Board:GetTerrain(target_loc)
            if free_spaces[target_loc] or (Board:GetPawn(target_loc) == nil and terrain ~= TERRAIN_MOUNTAIN and terrain ~= TERRAIN_BUILDING) then
                free_spaces[pawn_loc] = true
                pushs[pawn_loc] = nil
                moved = true
            end
        end
    end

    return pushs
end

function randomizer_helper.utils.is_player_turn()
    return Game:GetTeamTurn() == TEAM_PLAYER and randomizer_helper.tracking.current_action == ATTACK_ORDER_IDLE
end
