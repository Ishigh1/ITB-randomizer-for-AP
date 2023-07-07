-- Credits to Lemonymous for making this list

local VERSION = "0.1.0"

local function initEvents()
	-- Commented out events are already vanilla constants
	-- Presumably all integers up to 73 or beyond might be
	-- an event. But these are the ones I have identified.
	EVENT_SOMETHING_WITH_SKILL_TARGETING_1 = 1
	-- EVENT_ENEMY_KILLED = 2
	-- EVENT_MOUNTAIN_DESTROYED = 3
	EVENT_ENEMY_TURN = 4
	EVENT_PLAYER_TURN = 5
	EVENT_GRID_RESISTED = 9
	EVENT_GRID_DAMAGED = 7
	EVENT_SOMETHING_WITH_SKILL_TARGETING_2 = 11
	EVENT_MINOR_ENEMY_KILLED = 12
	EVENT_SOMETHING_WITH_UNIT = 13
	EVENT_TURN_START = 14
	-- EVENT_SPAWNBLOCKED = 16
	EVENT_1_GRID_REMAINING = 17
	-- EVENT_ACID_DESTROYED = 18
	EVENT_ENEMY_DAMAGED = 19
	EVENT_ENEMY_KILLED_2 = 21
	EVENT_MECH_DAMAGED = 24
	EVENT_MECH_DESTROYED = 25
	EVENT_FOREST_SET_ON_FIRE = 26
	EVENT_DESERT_TURNED_TO_SMOKE = 27
	EVENT_UNIT_DESTROYED = 28
	EVENT_MECH_REDUCED_TO_1_HP = 29
	EVENT_MECH_DESTROYED_2 = 30
	EVENT_MECH_REVIVED = 31
	EVENT_MECH_REPAIRED = 32
	EVENT_1_2_GRID_REMAINING = 34
	EVENT_POD_DESTROYED = 37
	EVENT_ATTACK_CANCELED_WITH_SMOKE = 42
	EVENT_ENEMY_STEPPED_ON_MINE = 43
	EVENT_UNIQUE_BUILDING_DESTROYED = 55
	-- EVENT_REPAIR_PICKUP = 72
	-- EVENT_REPAIR_UNDO = 73

	GameEvents.eventList = {
		onSomethingWithSkillTargeting1 = EVENT_SOMETHING_WITH_SKILL_TARGETING_1,
		onEnemyKilled = EVENT_ENEMY_KILLED,
		onMountainDestroyed = EVENT_MOUNTAIN_DESTROYED,
		onEnemyTurn = EVENT_ENEMY_TURN,
		onPlayerTurn = EVENT_PLAYER_TURN,
		onGridResisted = EVENT_GRID_RESISTED,
		onGridDamaged = EVENT_GRID_DAMAGED,
		onSomethingWithSkillTargeting2 = EVENT_SOMETHING_WITH_SKILL_TARGETING_2,
		onMinorEnemyKilled = EVENT_MINOR_ENEMY_KILLED,
		onSomethingWithUnit = EVENT_SOMETHING_WITH_UNIT,
		onTurnStart = EVENT_TURN_START,
		onSpawnBlocked = EVENT_SPAWNBLOCKED,
		on1GridRemaining = EVENT_1_GRID_REMAINING,
		onAcidDestroyed = EVENT_ACID_DESTROYED,
		onEnemyDamaged = EVENT_ENEMY_DAMAGED,
		onEnemyKilled2 = EVENT_ENEMY_KILLED_2,
		onMechDamaged = EVENT_MECH_DAMAGED,
		onMechDestroyed = EVENT_MECH_DESTROYED,
		onForestSetOnFire = EVENT_FOREST_SET_ON_FIRE,
		onDesertTurnedToSmoke = EVENT_DESERT_TURNED_TO_SMOKE,
		onUnitDestroyed = EVENT_UNIT_DESTROYED,
		onMechReducedTo1Hp = EVENT_MECH_REDUCED_TO_1_HP,
		onMechDestroyed2 = EVENT_MECH_DESTROYED_2,
		onMechRevived = EVENT_MECH_REVIVED,
		onMechRepaired = EVENT_MECH_REPAIRED,
		on1or2GridRemaining = EVENT_1_2_GRID_REMAINING,
		onPodDestroyed = EVENT_POD_DESTROYED,
		onAttackCanceledWithSmoke = EVENT_ATTACK_CANCELED_WITH_SMOKE,
		onEnemySteppdOnMine = EVENT_ENEMY_STEPPED_ON_MINE,
		onUniqueBuildingDestroyed = EVENT_UNIQUE_BUILDING_DESTROYED,
		onRepairPickup = EVENT_REPAIR_PICKUP,
		onRepairUndo = EVENT_REPAIR_UNDO,

		-- add more events here if they are found
	}

	for funcName, eventId in pairs(GameEvents.eventList) do
		if GameEvents[funcName] == nil then
			GameEvents[funcName] = Event()
		end
	end
end

local function checkEvents(mission)
	for funcName, eventId in pairs(GameEvents.eventList) do
		local isEvent = Game:IsEvent(eventId)
		if isEvent then
			GameEvents[funcName]:dispatch(Game:GetEventCount(eventId))
		end
	end
end

local function finalizeInit(self)
	modApi.events.onMissionUpdate:subscribe(checkEvents)
end

local function onModsInitialized()
	local isHighestVersion = true
		and GameEvents.initialized ~= true
		and GameEvents.version == VERSION

	if isHighestVersion then
		GameEvents:finalizeInit()
		GameEvents.initialized = true
	end
end

local isNewerVersion = false
	or GameEvents == nil
	or VERSION > GameEvents.version

if isNewerVersion then
	GameEvents = GameEvents or {}
	GameEvents.version = VERSION
	GameEvents.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)

	initEvents()
end

return GameEvents
