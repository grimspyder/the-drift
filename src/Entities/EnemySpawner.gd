extends Node2D

## EnemySpawner - Spawns enemies in dungeon rooms
## Attach to Level scene or DungeonGenerator

## Enemy scenes to spawn (variant 1)
@export var enemy_scene: PackedScene

## Fast enemy variant scene (variant 2)
@export var fast_enemy_scene: PackedScene

## Whether to use both enemy types
@export var use_variants: bool = true

## Number of enemies to spawn per level
@export var enemy_count: int = 12

## Minimum enemies per room (can be 0)
@export var min_enemies_per_room: int = 0

## Maximum enemies per room
@export var max_enemies_per_room: int = 2

## Whether to spawn enemies
@export var spawn_enabled: bool = true

## Minimum distance from player spawn (in pixels) - gives player time to react
## Default 500px = outside enemy detection range (400px) + buffer
@export var min_spawn_distance: float = 500.0

## Ratio of fast enemies (0.0 to 1.0)
@export var fast_enemy_ratio: float = 0.4

## Shadow Realm enemy scenes (theme 5)
@export var shadow_wraith_scene: PackedScene
@export var void_beast_scene: PackedScene

## Ratio of shadow enemies in Shadow Realm (0.0 to 1.0)
@export var shadow_enemy_ratio: float = 0.6

## DungeonGenerator reference
var _dungeon_generator: Node2D

## Spawned enemies list
var _spawned_enemies: Array[Node] = []

## Current world theme ID
var _current_theme_id: int = 0


func _ready() -> void:
	# Find DungeonGenerator
	_dungeon_generator = _find_dungeon_generator()
	
	# Load enemy scenes if not assigned
	if enemy_scene == null:
		enemy_scene = load("res://src/Entities/Enemy.tscn")
	if fast_enemy_scene == null:
		fast_enemy_scene = load("res://src/Entities/FastEnemy.tscn")
	
	# Load shadow realm enemies
	if shadow_wraith_scene == null:
		shadow_wraith_scene = load("res://src/Entities/ShadowWraith.tscn")
	if void_beast_scene == null:
		void_beast_scene = load("res://src/Entities/VoidBeast.tscn")
	
	# Get current theme from GameManager
	_update_theme_from_gamemanager()
	
	# Connect to dungeon generation signal if available
	if _dungeon_generator and _dungeon_generator.has_signal("dungeon_generated"):
		_dungeon_generator.dungeon_generated.connect(_on_dungeon_generated)
	
	# Spawn enemies after a short delay (to ensure dungeon is ready)
	await get_tree().create_timer(0.1).timeout
	spawn_enemies()


func _update_theme_from_gamemanager() -> void:
	"""Get the current world ID from GameManager"""
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and "world_id" in game_manager:
		_current_theme_id = game_manager.world_id
		print("EnemySpawner: Current theme ID: ", _current_theme_id)


func _find_dungeon_generator() -> Node2D:
	var parent = get_parent()
	if parent and parent.has_node("DungeonGenerator"):
		return parent.get_node("DungeonGenerator")
	return null


func spawn_enemies() -> void:
	if not spawn_enabled:
		return
	
	# Refresh theme from GameManager (in case we drifted)
	_update_theme_from_gamemanager()
	
	# Clear existing enemies
	clear_enemies()
	
	if _dungeon_generator == null:
		return
	
	# Get room count and positions
	var room_count = _dungeon_generator.get_room_count()
	
	if room_count <= 1:
		print("EnemySpawner: Not enough rooms for enemies (skipping first room)")
		return
	
	# Get player spawn position (safe spawn point away from walls)
	var player_spawn_pos = Vector2.ZERO
	if _dungeon_generator.has_method("get_player_spawn_point"):
		player_spawn_pos = _dungeon_generator.get_player_spawn_point()
	else:
		player_spawn_pos = _dungeon_generator.get_first_room_center()
	
	# Spawn enemies in rooms (skip first room where player starts)
	# Only spawn in rooms that meet minimum distance from player
	var valid_rooms = 0
	var skipped_rooms = 0
	
	for i in range(1, room_count):
		# Get the room's center position
		var room_center = _dungeon_generator.get_room_center(i)
		
		# Check minimum distance from player
		var distance_to_player = player_spawn_pos.distance_to(room_center)
		
		if distance_to_player < min_spawn_distance:
			skipped_rooms += 1
			continue
		
		valid_rooms += 1
		var room_enemy_count = randi_range(min_enemies_per_room, max_enemies_per_room)
		
		for j in range(room_enemy_count):
			var spawn_pos = _get_random_position_in_room(i)
			_spawn_enemy(spawn_pos)
	
	print("EnemySpawner: Spawned ", _spawned_enemies.size(), " enemies in ", valid_rooms, " rooms")
	if skipped_rooms > 0:
		print("EnemySpawner: Skipped ", skipped_rooms, " rooms (too close to player)")


func _get_random_position_in_room(room_index: int) -> Vector2:
	if _dungeon_generator == null:
		return Vector2.ZERO
	
	# Get the specific room's center (not random!)
	var center = _dungeon_generator.get_room_center(room_index)
	# Add some randomness around the center (within 100 pixels)
	var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
	return center + offset


func _spawn_enemy(position: Vector2) -> void:
	var selected_scene: PackedScene
	
	# Theme 5: Shadow Realm - spawn shadow enemies
	if _current_theme_id == 5:
		if shadow_wraith_scene != null and void_beast_scene != null:
			if randf() < shadow_enemy_ratio:
				# 50/50 chance between the two shadow enemies
				if randf() < 0.5:
					selected_scene = shadow_wraith_scene
				else:
					selected_scene = void_beast_scene
			else:
				# Fallback to regular enemies
				selected_scene = _get_regular_enemy_scene()
		else:
			selected_scene = _get_regular_enemy_scene()
	else:
		# Regular worlds - use standard enemy types
		selected_scene = _get_regular_enemy_scene()
	
	if selected_scene == null:
		return
	
	var enemy = selected_scene.instantiate()
	enemy.position = position
	
	# Add to parent (same level as dungeon)
	get_parent().add_child(enemy)
	_spawned_enemies.append(enemy)
	
	print("EnemySpawner: Spawned enemy at ", position)


func _get_regular_enemy_scene() -> PackedScene:
	"""Get a regular enemy scene based on variant settings"""
	if use_variants and fast_enemy_scene != null and randf() < fast_enemy_ratio:
		return fast_enemy_scene
	return enemy_scene


func clear_enemies() -> void:
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_spawned_enemies.clear()


func _on_dungeon_generated() -> void:
	spawn_enemies()


func get_enemy_count() -> int:
	return _spawned_enemies.size()


func get_spawned_enemies() -> Array[Node]:
	return _spawned_enemies.duplicate()


func set_fast_enemy_ratio(ratio: float) -> void:
	fast_enemy_ratio = clamp(ratio, 0.0, 1.0)


func set_enemy_count(count: int) -> void:
	enemy_count = max(0, count)
