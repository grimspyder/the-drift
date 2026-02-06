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

## Whether game is active
var game_active: bool = true

## Reference to current level
var _current_level: Node2D

## Reference to player
var _player: CharacterBody2D


func _ready() -> void:
	# This should be set as an autoload in project.godot
	print("GameManager: Initialized")
	print("GameManager: Max drifts: ", max_drifts)


func initialize_game() -> void:
	"""Reset all game state for a new game"""
	world_id = 0
	drift_count = 0
	session_time = 0.0
	game_active = true
	print("GameManager: Game initialized")


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
	if not game_active:
		return
	
	print("GameManager: Player died! Drift #", drift_count + 1)
	
	# Increment drift count
	drift_count += 1
	
	# Check for game over
	if drift_count >= max_drifts:
		game_over("Too many drifts! Game Over.")
		return
	
	# Increment world ID (changes world theme)
	world_id += 1
	print("GameManager: Shifting to World ", world_id)
	
	# Regenerate world with new seed (drift)
	_regenerate_world()


func _regenerate_world() -> void:
	"""Regenerate the current world (called on player death/drifting)"""
	if _current_level and _current_level.has_method("regenerate_level"):
		_current_level.regenerate_level()
	
	# Respawn player
	_respawn_player()
	
	print("GameManager: World regenerated (World ", world_id, ", Drift #", drift_count, ")")


func _respawn_player() -> void:
	"""Respawn player at start of new world"""
	if _player == null:
		# Find player in scene
		var parent = get_tree().current_scene
		if parent and parent.has_node("Player"):
			_player = parent.get_node("Player")
	
	if _player and _player.has_method("reset_player"):
		var spawn_pos = Vector2.ZERO
		if get_parent() and get_parent().has_method("get_player_spawn_position"):
			spawn_pos = get_parent().get_player_spawn_position()
		_player.global_position = spawn_pos
		_player.reset_player()
		print("GameManager: Player respawned")


func game_over(reason: String) -> void:
	"""Handle game over condition"""
	game_active = false
	print("GameManager: GAME OVER - ", reason)
	# TODO: Show game over screen with stats


func get_drift_remaining() -> int:
	"""Get remaining drifts allowed"""
	return max(0, max_drifts - drift_count)


func get_session_formatted() -> String:
	"""Get formatted session time string"""
	var minutes = int(session_time) / 60
	var seconds = int(session_time) % 60
	return "%02d:%02d" % [minutes, seconds]


func _process(delta: float) -> void:
	if game_active:
		session_time += delta
		if session_time >= max_session_time:
			game_over("Session time limit reached!")
