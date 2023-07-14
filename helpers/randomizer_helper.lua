randomizer_helper = {
    events = {},
    tracking = {}
}
randomizer_helper.events.on_vek_action_change = Event()
randomizer_helper.events.on_overload_change = Event()
randomizer_helper.events.on_building_damaged = Event()
randomizer_helper.events.on_tile_fire = Event()
randomizer_helper.events.on_tile_shield = Event()
randomizer_helper.events.on_game_lost = Event()

-- Things might look weird because I have to take in account the fact that most hooks in-game happen one frame after attack order changes
randomizer_helper.tracking.current_action = ATTACK_ORDER_IDLE
local next_action = ATTACK_ORDER_IDLE

randomizer_helper.tracking.last_overload = 0

randomizer_helper.tracking.board = {}

local function reset_board_tracking()
    randomizer_helper.tracking.board = {}
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

local function register_attack(mission, pawn, weaponId, p1, p2)
    randomizer_helper.tracking.last_attacker = pawn:GetMechName()
end

local function register_game_changes()
    if modApi:getGameState() == "Mission" then
        if randomizer_helper.tracking.board == {} then
            make_tracking()
        end

        randomizer_helper.current_action = next_action
        next_action = memedit:require().board.getAttackOrder()
        if next_action ~= randomizer_helper.current_action then
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
end

modApi.events.onFrameDrawn:subscribe(register_game_changes)
modApi.events.onMissionUpdate:subscribe(register_game_changes)
modApi.events.onMissionStart:subscribe(reset_board_tracking)
modApi.events.onPostLoadGame:subscribe(reset_board_tracking)
modapiext.events.onSkillStart:subscribe(register_attack)
modapiext.events.onQueuedSkillStart:subscribe(register_attack)