extends Node2D

# The Drift - Main Game Scene
# Core architecture: Map -> Entities -> UI hierarchy

# References to main subsystems
var map_node: Node2D
var entities_node: Node2D
var ui_node: CanvasLayer

func _ready() -> void:
	# Initialize subsystems
	setup_map()
	setup_entities()
	setup_ui()
	
	# Connect signals (will implement as systems grow)
	connect_signals()
	
	print("The Drift initialized. World ID: ", get_world_id())

func _process(_delta: float) -> void:
	# Main game loop processing
	pass

# -------------------------------------------------------------------------
# Subsystem Setup
# -------------------------------------------------------------------------

func setup_map() -> void:
	map_node = Node2D.new()
	map_node.name = "Map"
	add_child(map_node)
	# Map initialization will happen here (DungeonGenerator)

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
# Drift Mechanic (placeholder - Task 3.2)
# -------------------------------------------------------------------------

func get_world_id() -> int:
	# Returns current world ID from GameManager autoload
	return 0

func trigger_drift() -> void:
	# Called when player dies
	# 1. Increment world_id
	# 2. Regenerate level
	# 3. Mutate player state (class shift, equipment variation)
	# 4. Respawn player
	print("DRIFT TRIGGERED: Entering next world...")
