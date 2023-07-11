memedit_functions = {
    events = {},
    tracking = {}
}
memedit_functions.events.on_vek_action_change = Event()
memedit_functions.events.on_overload_change = Event()
memedit_functions.events.on_building_damaged = Event()
memedit_functions.events.on_tile_fire = Event()
memedit_functions.events.on_tile_shield = Event()

-- Things might look weird because I have to take in account the fact that most hooks in-game happen one frame after attack order changes
memedit_functions.tracking.current_action = ATTACK_ORDER_IDLE
local next_action = ATTACK_ORDER_IDLE

memedit_functions.tracking.last_overload = 0

memedit_functions.tracking.board = {}

local function reset_board_tracking()
    memedit_functions.tracking.board = {}
end

local function make_tracking()
    for tile_index, tile in ipairs(Board) do
        local tracking_content = {}
        tracking_content.health = Board:GetHealth(tile)
        tracking_content.fire = Board:IsFire(tile)
        tracking_content.shield = Board:IsShield(tile)

        memedit_functions.tracking.board[tile] = tracking_content
    end
end

local function register_game_changes()
    if memedit_functions.tracking.board == {} then
        make_tracking()
    end

    memedit.current_action = next_action
    next_action = memedit:require().board.getAttackOrder()
    if next_action ~= memedit.current_action then
        memedit_functions.events.on_vek_action_change:dispatch(next_action)
    end

    local new_overload = Game:GetResist()
    if new_overload ~= memedit_functions.tracking.last_overload then
        memedit_functions.events.on_overload_change:dispatch(new_overload - memedit_functions.tracking.last_overload)
    end
    memedit_functions.tracking.last_overload = new_overload

    for point, old_content in pairs(memedit_functions.tracking.board) do
        if Board:IsBuilding(point) and Board:GetHealth(point) ~= old_content.health then
            memedit_functions.events.on_building_damaged:dispatch()
            old_content.health = Board:GetHealth(point)
        end

        if Board:IsFire(point) ~= old_content.fire then
            local new_fire = not old_content.fire
            old_content.fire = new_fire
            memedit_functions.events.on_tile_fire:dispatch(new_fire)
        end

        if Board:IsShield(point) ~= old_content.shield then
            local new_shield = not old_content.shield
            old_content.shield = new_shield
            memedit_functions.events.on_tile_shield:dispatch(new_shield)
        end
    end
end

modApi.events.onMissionUpdate:subscribe(register_game_changes)
modApi.events.onMissionStart:subscribe(reset_board_tracking)
modApi.events.onPostLoadGame:subscribe(reset_board_tracking)
