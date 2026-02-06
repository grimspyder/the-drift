extends Node

## GameManager - Global game state management for The Drift
## Handles player death, world regeneration (drift), and session tracking

## Current world ID (determines theme/tileset)
var world_id: int = 0

## Number of drifts (deaths/respawns) in current session
var drift_count: int = 0

## Maximum allowed drifts before game over
var max_drifts: int = 10

## Current session time in seconds
var session_time: float = 0.0

## Maximum session duration (1 hour)
var max_session_time: float = 3600.0

## Base seed for this session
var session_seed: int = 0

## Whether game is active
var game_active: bool = true

## Whether player is currently drifting
var is_driftging: bool = false

## Reference to current level
var _current_level: Node2D

## Reference to player
var _player: CharacterBody2D

## World theme database
var _theme_db: WorldThemeDatabase

## Drift transition timer
var _drift_transition_timer: float = 0.0

## Duration of drift transition
const DRIFT_TRANSITION_DURATION: float = 1.5


func _ready() -> void:
	# This should be set as an autoload in project.godot
	print("GameManager: Initialized")
	print("GameManager: Max drifts: ", max_drifts)
	
	# Initialize theme database
	_theme_db = WorldThemeDatabase.new()
	add_child(_theme_db)
	
	# Generate session seed
	session_seed = randi()
	print("GameManager: Session seed: ", session_seed)


func initialize_game() -> void:
	"""Reset all game state for a new game"""
	world_id = 0
	drift_count = 0
	session_time = 0.0
	session_seed = randi()
	game_active = true
	is_driftging = false
	print("GameManager: Game initialized")
	print("GameManager: Session seed: ", session_seed)


func register_player(player: CharacterBody2D) -> void:
	"""Register player reference for death handling"""
	_player = player
	if player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)
	print("GameManager: Player registered")


func register_level(level: Node2D) -> void:
	"""Register level reference for regeneration"""
	_current_level = level
	print("GameManager: Level registered")


func _on_player_died() -> void:
	"""Handle player death - trigger drift mechanic"""
	if not game_active or is_driftging:
		return
	
	print("GameManager: Player died! Drift #", drift_count + 1)
	
	# Start drift transition
	is_driftging = true
	_drift_transition_timer = DRIFT_TRANSITION_DURATION
	
	# Wait for transition then complete drift
	_complete_drift_after_delay()


func _complete_drift_after_delay() -> void:
	"""Complete the drift after transition delay"""
	await get_tree().create_timer(DRIFT_TRANSITION_DURATION).timeout
	
	if not game_active:
		return
	
	# Increment drift count
	drift_count += 1
	
	# Check for game over
	if drift_count >= max_drifts:
		game_over("Too many drifts! Game Over.")
		return
	
	# Check session time
	if session_time >= max_session_time:
		game_over("Session time limit reached!")
		return
	
	# Increment world ID (changes world theme)
	world_id += 1
	print("GameManager: Shifting to World ", world_id)
	
	# Calculate new seed for world generation
	var new_seed = _calculate_world_seed()
	
	# Regenerate world with new seed (drift)
	_regenerate_world(new_seed)
	
	# Mutate player
	_mutate_player()
	
	# Apply world theme
	_apply_world_theme()
	
	# Reset drift state
	is_driftging = false
	
	print("GameManager: Drift complete! World ", world_id, ", Drift #", drift_count)


func _calculate_world_seed() -> int:
	"""Calculate seed for world generation based on world_id and session_seed"""
	# Hash the world_id with session_seed to create deterministic but different seeds
	var hash_input = str(world_id) + "_" + str(session_seed)
	var hash_value = hash(hash_input)
	
	# Ensure positive seed
	if hash_value < 0:
		hash_value = -hash_value
	
	# Mix in some randomness
	hash_value = hash_value ^ randi()
	
	return hash_value


func _regenerate_world(new_seed: int) -> void:
	"""Regenerate the current world (called on player death/drifting)"""
	if _current_level and _current_level.has_method("regenerate_level_with_seed"):
		_current_level.regenerate_level_with_seed(new_seed)
	elif _current_level and _current_level.has_method("regenerate_level"):
		_current_level.regenerate_level()
	
	# Respawn player at start of new world
	_respawn_player()


func _mutate_player() -> void:
	"""Mutate player to new class and equipment"""
	if _player and _player.has_method("mutate_random"):
		var exclude_class = ""
		# Try to get current class name to exclude
		if _player.current_class:
			exclude_class = _player.current_class.class_id
		
		_player.mutate_random(exclude_class)


func _apply_world_theme() -> void:
	"""Apply the world theme to the current level"""
	if not _theme_db:
		return
	
	var theme = _theme_db.get_theme_for_world_id(world_id)
	
	print("GameManager: Applying theme: ", theme.display_name)
	print("Theme description: ", theme.description)
	print("Difficulty: ", theme.get_difficulty_description())
	
	# Apply theme colors to level if available
	if _current_level and _current_level.has_method("apply_theme"):
		_current_level.apply_theme(theme)


func _respawn_player() -> void:
	"""Respawn player at start of new world"""
	if _player == null:
		# Find player in scene
		var parent = get_tree().current_scene
		if parent and parent.has_node("Player"):
			_player = parent.get_node("Player")
	
	if _player and _player.has_method("reset_player"):
		var spawn_pos = Vector2.ZERO
		if _current_level and _current_level.has_method("get_player_spawn_position"):
			spawn_pos = _current_level.get_player_spawn_position()
		elif get_parent() and get_parent().has_method("get_player_spawn_position"):
			spawn_pos = get_parent().get_player_spawn_position()
		_player.global_position = spawn_pos
		_player.reset_player()
		print("GameManager: Player respawned at ", spawn_pos)


func game_over(reason: String) -> void:
	"""Handle game over condition"""
	game_active = false
	print("GameManager: GAME OVER - ", reason)
	
	# TODO: Show game over screen with stats
	_show_game_over_screen(reason)


func _show_game_over_screen(reason: String) -> void:
	"""Display game over information"""
	print("=")
	print("GAME OVER")
	print("=")
	print("Reason: ", reason)
	print("Worlds explored: ", world_id + 1)
	print("Total drifts: ", drift_count)
	print("Session time: ", get_session_formatted())
	print("=")


func get_drift_remaining() -> int:
	"""Get remaining drifts allowed"""
	return max(0, max_drifts - drift_count)


func get_session_formatted() -> String:
	"""Get formatted session time string"""
	var minutes = int(session_time) / 60
	var seconds = int(session_time) % 60
	return "%02d:%02d" % [minutes, seconds]


func get_session_time_remaining() -> String:
	"""Get remaining session time formatted"""
	var remaining = max(0.0, max_session_time - session_time)
	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	return "%02d:%02d" % [minutes, seconds]


func _process(delta: float) -> void:
	if game_active:
		session_time += delta
		
		# Update drift transition timer
		if is_driftging and _drift_transition_timer > 0:
			_drift_transition_timer -= delta
		
		# Check session time limit
		if session_time >= max_session_time:
			game_over("Session time limit reached!")


func get_world_info() -> Dictionary:
	"""Get current world information"""
	var theme = _theme_db.get_theme_for_world_id(world_id) if _theme_db else null
	
	return {
		"world_id": world_id,
		"theme_name": theme.display_name if theme else "Unknown",
		"theme_description": theme.description if theme else "",
		"difficulty": theme.get_difficulty_description() if theme else "Unknown",
		"drift_count": drift_count,
		"drifts_remaining": get_drift_remaining(),
		"session_time": get_session_formatted(),
		"session_time_remaining": get_session_time_remaining(),
		"is_driftging": is_driftging
	}


func get_player_class_info() -> Dictionary:
	"""Get player class information"""
	if _player and _player.has_method("get_player_stats"):
		return _player.get_player_stats()
	return {}


func force_drift() -> void:
	"""Force a drift (for testing or special events)"""
	if not game_active:
		return
	_on_player_died()


func skip_world() -> void:
	"""Skip to the next world (for testing or special events)"""
	if not game_active:
		return
	
	world_id += 1
	var new_seed = _calculate_world_seed()
	_regenerate_world(new_seed)
	_apply_world_theme()
	print("GameManager: Skipped to World ", world_id)
