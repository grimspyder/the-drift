extends Node2D

# The Drift - Main Game Scene
# Core architecture: Map -> Entities -> UI hierarchy

# References to main subsystems
var map_node: Node2D
var level_node: Node2D
var entities_node: Node2D
var ui_node: CanvasLayer

## Current world ID (from GameManager)
var world_id: int = 0

## Session seed for deterministic generation
var session_seed: int = 0


func _ready() -> void:
	# Initialize subsystems
	setup_map()
	setup_entities()
	setup_ui()
	
	# Generate initial level
	_generate_initial_level()
	
	# Connect signals
	connect_signals()
	
	print("The Drift initialized. World ID: ", world_id)


func _process(_delta: float) -> void:
	# Main game loop processing
	pass

# -------------------------------------------------------------------------
# Level Generation
# -------------------------------------------------------------------------

func _generate_initial_level() -> void:
	"""Generate the initial level with random seed"""
	session_seed = randi()
	_generate_level()


func _generate_level() -> void:
	"""Generate a level using the world ID and session seed"""
	if level_node:
		# Calculate deterministic seed
		var level_seed = _get_deterministic_seed()
		print("Generating level with seed: ", level_seed)
		
		# Call generate on the level
		if level_node.has_method("generate_level"):
			level_node.generate_level(level_seed)


func _get_deterministic_seed() -> int:
	"""Calculate deterministic seed from world_id and session_seed"""
	# Use hash combination for deterministic but varied seeds
	return hash(world_id + session_seed)


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
	add_child(ui_node)
	# HUD, menus, etc. will be added to UI layer

# -------------------------------------------------------------------------
# Signal Connections
# -------------------------------------------------------------------------

func connect_signals() -> void:
	# Connect to Player death signal for drift mechanic
	# player.died.connect(_on_player_died)
	pass

# -------------------------------------------------------------------------
# Drift Mechanic
# -------------------------------------------------------------------------

func get_world_id() -> int:
	# Returns current world ID from GameManager autoload
	return world_id


func trigger_drift() -> void:
	"""Called when player dies - transfers to next world"""
	print("DRIFT TRIGGERED: Entering world #", world_id + 1)
	
	# Increment world ID
	world_id += 1
	
	# Regenerate level with new seed
	_generate_level()
	
	# TODO: Mutate player state (class shift, equipment variation)
	# TODO: Respawn player in first room


func set_session_seed(seed: int) -> void:
	"""Set the session seed for deterministic generation"""
	session_seed = seed
