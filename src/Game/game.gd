extends Node2D

# The Drift - Main Game Scene
# Core architecture: Map -> Entities -> UI hierarchy

# References to main subsystems
var map_node: Node2D
var level_node: Node2D
var entities_node: Node2D
var ui_node: CanvasLayer

## Reference to GameManager (autoload)
var game_manager: Node


func _ready() -> void:
	# Get GameManager autoload
	game_manager = get_node("/root/GameManager")
	
	# Initialize subsystems
	setup_map()
	setup_entities()
	setup_ui()
	
	# Generate initial level
	_generate_initial_level()
	
	# Connect signals
	connect_signals()
	
	# Register with GameManager
	if game_manager:
		game_manager.register_level(level_node)
		
		# Find and register player
		var player = entities_node.get_node_or_null("Player")
		if player:
			game_manager.register_player(player)
	
	print("The Drift initialized.")
	if game_manager:
		print("World: ", game_manager.world_id)
		print("Session seed: ", game_manager.session_seed)


func _process(_delta: float) -> void:
	# Main game loop processing
	pass

# -------------------------------------------------------------------------
# Level Generation
# -------------------------------------------------------------------------

func _generate_initial_level() -> void:
	"""Generate the initial level"""
	if level_node:
		level_node.generate_level()


func _generate_level() -> void:
	"""Generate a level"""
	if level_node:
		# Calculate deterministic seed
		var seed_value = 0
		if game_manager:
			seed_value = game_manager.session_seed + game_manager.world_id
		
		print("Generating level with seed: ", seed_value)
		
		# Call generate on the level
		level_node.generate_level(seed_value)


# -------------------------------------------------------------------------
# Subsystem Setup
# -------------------------------------------------------------------------

func setup_map() -> void:
	map_node = Node2D.new()
	map_node.name = "Map"
	add_child(map_node)
	
	# Instantiate the Level scene
	var level_scene = load("res://src/Map/Level.tscn")
	if level_scene:
		level_node = level_scene.instantiate()
		map_node.add_child(level_node)
		print("Level loaded successfully")
	else:
		push_error("Failed to load Level scene!")


func setup_entities() -> void:
	entities_node = Node2D.new()
	entities_node.name = "Entities"
	add_child(entities_node)
	# Entities (Player, Enemies) will be spawned here


func setup_ui() -> void:
	ui_node = CanvasLayer.new()
	ui_node.name = "UI"
	ui_node.layer = 100  # Render on top of everything
	add_child(ui_node)
	
	# Instantiate and add HUD
	var hud_scene = load("res://src/UI/HUD.tscn")
	if hud_scene:
		var hud = hud_scene.instantiate()
		ui_node.add_child(hud)
		print("HUD loaded successfully")
	else:
		push_error("Failed to load HUD scene!")


# -------------------------------------------------------------------------
# Signal Connections
# -------------------------------------------------------------------------

func connect_signals() -> void:
	# Connect to Player death signal for drift mechanic
	# The GameManager handles player death via registered signals
	pass


# -------------------------------------------------------------------------
# Drift Mechanic (handled by GameManager, but referenced here)
# -------------------------------------------------------------------------

func get_player_spawn_position() -> Vector2:
	"""Get player spawn position from level"""
	if level_node and level_node.has_method("get_player_spawn_position"):
		return level_node.get_player_spawn_position()
	return Vector2(320, 240)  # Default fallback


func get_world_info() -> Dictionary:
	"""Get current world information"""
	if game_manager and game_manager.has_method("get_world_info"):
		return game_manager.get_world_info()
	return {}


func get_session_seed() -> int:
	"""Get the current session seed"""
	if game_manager:
		return game_manager.session_seed
	return randi()


func force_drift() -> void:
	"""Force a drift (for testing)"""
	if game_manager and game_manager.has_method("force_drift"):
		game_manager.force_drift()


func skip_world() -> void:
	"""Skip to the next world (for testing)"""
	if game_manager and game_manager.has_method("skip_world"):
		game_manager.skip_world()


# -------------------------------------------------------------------------
# Debug/Test Functions
# -------------------------------------------------------------------------

func debug_print_state() -> void:
	"""Print current game state (for debugging)"""
	print("=== Game State ===")
	if game_manager:
		var info = game_manager.get_world_info()
		print("World ID: ", info.get("world_id", 0))
		print("Theme: ", info.get("theme_name", "Unknown"))
		print("Drift #: ", info.get("drift_count", 0))
		print("Session time: ", info.get("session_time", ""))
		print("Is drifting: ", info.get("is_driftging", false))
	
	var player = entities_node.get_node_or_null("Player")
	if player and player.has_method("get_player_stats"):
		var stats = player.get_player_stats()
		print("Player class: ", stats.get("class", "Unknown"))
		print("Player health: ", stats.get("health", 0), "/", stats.get("max_health", 0))
	print("==================")
