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

## Enemy kill counter
var enemies_killed: int = 0

## Exit stairs reference
var _exit_stairs: Node2D

## Maximum world count (for win condition)
const MAX_WORLDS: int = 6

## Win screen instance
var _win_screen: Control

## Game over screen instance
var _game_over_screen: Control

## Whether game has been won
var game_won: bool = false

## Warning thresholds
var _time_warning_shown: bool = false
var _drift_warning_shown: bool = false

const TIME_WARNING_THRESHOLD: float = 300.0 # 5 minutes remaining
const TIME_CRITICAL_THRESHOLD: float = 60.0 # 1 minute remaining
const DRIFT_WARNING_THRESHOLD: int = 8 # 2 drifts remaining


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
	enemies_killed = 0
	game_active = true
	is_driftging = false
	game_won = false
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
	
	# Reset warnings for new drift
	_time_warning_shown = false
	_drift_warning_shown = false
	
	# Check for game over (drift limit reached)
	if drift_count >= max_drifts:
		game_over("Too Many Drifts!")
		return
	
	# Check session time
	if session_time >= max_session_time:
		game_over("Time Expired!")
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
		hash_value = - hash_value
	
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


# -------------------------------------------------------------------------
# Enemy Kill Tracking
# -------------------------------------------------------------------------

func register_enemy_kill() -> void:
	"""Register an enemy kill"""
	enemies_killed += 1
	print("GameManager: Enemy killed! Total: ", enemies_killed)


func get_enemy_kills() -> int:
	"""Get total enemy kills"""
	return enemies_killed


func reset_enemy_kills() -> void:
	"""Reset enemy kill counter"""
	enemies_killed = 0


# -------------------------------------------------------------------------
# Win Condition
# -------------------------------------------------------------------------

func register_exit_stairs(stairs: Node2D) -> void:
	"""Register exit stairs reference"""
	# Disconnect old portal if exists
	if _exit_stairs and is_instance_valid(_exit_stairs):
		if _exit_stairs.has_signal("stairs_entered"):
			_exit_stairs.stairs_entered.disconnect(_on_stairs_entered)
		if _exit_stairs.has_signal("portal_entered"):
			_exit_stairs.portal_entered.disconnect(_on_portal_entered)
	
	_exit_stairs = stairs
	
	if stairs and stairs.has_signal("stairs_entered"):
		stairs.stairs_entered.connect(_on_stairs_entered)
	# Also connect to portal_entered signal
	if stairs and stairs.has_signal("portal_entered"):
		stairs.portal_entered.connect(_on_portal_entered)
	print("GameManager: Exit stairs registered for world ", stairs.world_id if "world_id" in stairs else 0)


func _on_portal_entered() -> void:
	"""Handle player entering a portal - advance to next level"""
	if not game_active or game_won:
		return
	
	# Check if this is the final world
	if world_id >= MAX_WORLDS - 1:
		# Final world - trigger win!
		print("GameManager: Player completed final world! Triggering win...")
		_on_stairs_entered()
		return
	
	# Advance to next world
	print("GameManager: Player entered portal! Advancing to next world...")
	_advance_to_next_world()


func _advance_to_next_world() -> void:
	"""Advance to the next world without player death"""
	# Increment world ID
	world_id += 1
	print("GameManager: Advancing to World ", world_id)
	
	# Calculate new seed for world generation
	var new_seed = _calculate_world_seed()
	
	# Regenerate world
	_regenerate_world(new_seed)
	
	# Mutate player
	_mutate_player()
	
	# Apply world theme
	_apply_world_theme()
	
	print("GameManager: Advanced to world ", world_id)


func _on_stairs_entered() -> void:
	"""Handle player reaching exit stairs - trigger win condition"""
	if not game_active or game_won:
		return
	
	print("GameManager: Player reached exit! Triggering win...")
	game_won = true
	game_active = false
	
	# Show win screen
	_show_win_screen()


func _show_win_screen() -> void:
	"""Display win screen with statistics"""
	print("=")
	print("VICTORY!")
	print("=")
	print("Congratulations! You escaped The Drift!")
	print("Total drifts survived: ", drift_count)
	print("Enemies defeated: ", enemies_killed)
	print("Session time: ", get_session_formatted())
	print("Worlds explored: ", world_id + 1)
	print("=")
	
	# Load and show win screen
	var win_screen_scene = load("res://src/UI/WinScreen.tscn")
	if win_screen_scene:
		_win_screen = win_screen_scene.instantiate()
		get_tree().current_scene.add_child(_win_screen)
		
		# Set statistics
		_win_screen.set_stats(
			get_session_formatted(),
			drift_count,
			enemies_killed
		)
		
		# Show with animation
		_win_screen.show_victory()
		
		print("WinScreen: Victory screen displayed")


func win_game() -> void:
	"""Force win condition (for testing or special events)"""
	if not game_active or game_won:
		return
	_on_stairs_entered()


# -------------------------------------------------------------------------
# Game State Helpers
# -------------------------------------------------------------------------

func get_session_formatted() -> String:
	"""Get formatted session time string"""
	var minutes = int(session_time) / 60
	var seconds = int(session_time) % 60
	return "%02d:%02d" % [minutes, seconds]


func game_over(reason: String) -> void:
	"""Handle game over condition"""
	game_active = false
	print("GameManager: GAME OVER - ", reason)
	
	# Show game over screen with stats
	_show_game_over_screen(reason)


func _show_game_over_screen(reason: String) -> void:
	"""Display game over screen with statistics"""
	print("=")
	print("GAME OVER")
	print("=")
	print("Reason: ", reason)
	print("Worlds explored: ", world_id + 1)
	print("Total drifts: ", drift_count)
	print("Session time: ", get_session_formatted())
	print("Enemies defeated: ", enemies_killed)
	print("=")
	
	# Load and show game over screen
	var game_over_scene = load("res://src/UI/GameOverScreen.tscn")
	if game_over_scene:
		_game_over_screen = game_over_scene.instantiate()
		get_tree().current_scene.add_child(_game_over_screen)
		
		# Set game over reason
		_game_over_screen.set_game_over_reason(reason)
		
		# Set statistics
		_game_over_screen.set_stats(
			get_session_formatted(),
			drift_count,
			enemies_killed,
			world_id + 1
		)
		
		# Show with animation
		_game_over_screen.show_game_over()
		
		print("GameOverScreen: Game over screen displayed")


func get_drift_remaining() -> int:
	"""Get remaining drifts allowed"""
	return max(0, max_drifts - drift_count)


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
			game_over("Time Expired!")
			return
		
		# Check for pre-warnings
		_check_warnings()


func _check_warnings() -> void:
	"""Check and display pre-warnings for time and drift limits"""
	
	# Time warning at 5 minutes remaining
	var time_remaining = max_session_time - session_time
	if time_remaining <= TIME_WARNING_THRESHOLD and not _time_warning_shown:
		_time_warning_shown = true
		_show_time_warning()
	
	# Drift warning at 2 drifts remaining
	if drift_count >= DRIFT_WARNING_THRESHOLD and not _drift_warning_shown:
		_drift_warning_shown = true
		_show_drift_warning()


func _show_time_warning() -> void:
	"""Show warning when time is running low"""
	print("GameManager: WARNING - 5 minutes remaining!")
	
	# Get HUD and show warning
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_time_warning"):
		hud.show_time_warning()


func _show_drift_warning() -> void:
	"""Show warning when drifts are running low"""
	print("GameManager: WARNING - 2 drifts remaining!")
	
	# Get HUD and show warning
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_drift_warning"):
		hud.show_drift_warning()


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
