extends Node2D

## Level scene for The Drift
## Uses DungeonGenerator for procedural level generation with theme support

## DungeonGenerator reference
@onready var dungeon_generator: Node2D = $DungeonGenerator

## TileMap reference (accessible via DungeonGenerator)
@onready var tile_map: TileMap = $TileMap

## Seed for level generation
var _level_seed: int = 0

## Current world theme
var _current_theme: WorldTheme

## Theme database reference
var _theme_db: WorldThemeDatabase

## Visual transition overlay
var _transition_overlay: ColorRect


func _ready() -> void:
	# Initialize theme database
	_theme_db = WorldThemeDatabase.new()
	add_child(_theme_db)
	
	# Create transition overlay
	_create_transition_overlay()
	
	# Generate initial level
	generate_level()


func _create_transition_overlay() -> void:
	"""Create a transition overlay for drift effects"""
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color.BLACK
	_transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.visible = false
	
	# Add to canvas layer for proper rendering
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(_transition_overlay)
	get_tree().current_scene.add_child.call_deferred(canvas_layer)


func generate_level(new_seed: int = 0) -> void:
	"""Generate a new level with optional seed"""
	_level_seed = new_seed
	if _level_seed == 0:
		_level_seed = randi() # Random seed if none provided
	
	print("Level: Generating with seed ", _level_seed)
	
	# Get theme for world 0 (starting world)
	_current_theme = _theme_db.get_theme_for_world_id(0)
	
	# Delegate to DungeonGenerator
	dungeon_generator.generate_dungeon(_level_seed)
	
	# Place exit stairs (only in world 0 for dungeon completion)
	var game_manager = get_node_or_null("/root/GameManager")
	var is_world_zero = game_manager and game_manager.world_id == 0
	if is_world_zero:
		_place_exit_stairs()
	
	# Apply theme colors
	_apply_theme_to_tilemap()
	
	print("Level: Generation complete")


func regenerate_level() -> void:
	"""Regenerate the level with the same seed"""
	generate_level(_level_seed)


func regenerate_level_with_seed(new_seed: int) -> void:
	"""Regenerate the level with a new seed (used during drift)"""
	# Play transition effect
	_play_drift_transition()
	
	# Generate new level
	_level_seed = new_seed
	_current_theme = _theme_db.get_theme_for_world_id(get_parent().world_id if get_parent() else 0)
	
	dungeon_generator.generate_dungeon(_level_seed)
	
	# Place exit stairs only in world 0
	var game_manager = get_node_or_null("/root/GameManager")
	var is_world_zero = game_manager and game_manager.world_id == 0
	if is_world_zero:
		_place_exit_stairs()
	
	_apply_theme_to_tilemap()
	
	print("Level: Regenerated with seed ", _level_seed, " and theme ", _current_theme.display_name)


func _play_drift_transition() -> void:
	"""Play visual transition effect for drifting"""
	if _transition_overlay:
		_transition_overlay.visible = true
		
		# Fade to white then back
		var tween = create_tween()
		tween.tween_property(_transition_overlay, "color", Color.WHITE, 0.3)
		tween.tween_property(_transition_overlay, "color", Color.BLACK, 0.3)
		tween.tween_callback(func(): if _transition_overlay: _transition_overlay.visible = false)


func apply_theme(theme: WorldTheme) -> void:
	"""Apply a world theme to the level"""
	_current_theme = theme
	_apply_theme_to_tilemap()
	
	print("Level: Applied theme: ", theme.display_name)


func _apply_theme_to_tilemap() -> void:
	"""Apply theme colors to the TileMap"""
	if not tile_map or not _current_theme:
		return
	
	# Apply floor color modulation
	tile_map.modulate = _current_theme.floor_color


func get_player_spawn_position() -> Vector2:
	"""Get the player spawn position (center of first room)"""
	return dungeon_generator.get_first_room_center()


func get_random_spawn_position() -> Vector2:
	"""Get a random spawn position (center of random room)"""
	return dungeon_generator.get_random_room_center()


func get_room_count() -> int:
	"""Get the number of rooms in the current level"""
	return dungeon_generator.get_room_count()


func get_level_seed() -> int:
	"""Get the current level seed"""
	return dungeon_generator.get_seed()


func clear_level() -> void:
	"""Clear the current level"""
	dungeon_generator.clear_dungeon()


func get_theme() -> WorldTheme:
	"""Get the current world theme"""
	return _current_theme


func _on_dungeon_generated() -> void:
	"""Signal handler called when dungeon generation is complete"""
	print("Level: Dungeon generation complete. Rooms: ", get_room_count())


func get_enemy_spawn_rate() -> float:
	"""Get the enemy spawn rate modified by theme"""
	if _current_theme:
		return _current_theme.get_enemy_spawn_rate(1.0)
	return 1.0


func get_resource_spawn_rate() -> float:
	"""Get the resource spawn rate modified by theme"""
	if _current_theme:
		return _current_theme.get_resource_spawn_rate(1.0)
	return 1.0


func get_hazards() -> Array:
	"""Get the hazards present in this world"""
	if _current_theme:
		return _current_theme.hazards
	return []


func is_hard_mode() -> bool:
	"""Check if current world is hard mode"""
	if _current_theme:
		return _current_theme.is_hard_mode
	return false


func is_easy_mode() -> bool:
	"""Check if current world is easy mode"""
	if _current_theme:
		return _current_theme.is_easy_mode
	return false


# -------------------------------------------------------------------------
# Exit Stairs Placement
# -------------------------------------------------------------------------

func _place_exit_stairs() -> void:
	"""Place exit stairs in the dungeon for completing the level"""
	if dungeon_generator and dungeon_generator.has_method("place_exit_stairs"):
		var stairs_pos = dungeon_generator.place_exit_stairs()
		print("Level: Exit stairs placed at ", stairs_pos)
	else:
		print("Level: Failed to place exit stairs - DungeonGenerator method not available")
