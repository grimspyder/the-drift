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

## Ratio of fast enemies (0.0 to 1.0)
@export var fast_enemy_ratio: float = 0.4

## DungeonGenerator reference
var _dungeon_generator: Node2D

## Spawned enemies list
var _spawned_enemies: Array[Node] = []


func _ready() -> void:
	# Find DungeonGenerator
	_dungeon_generator = _find_dungeon_generator()
	
	# Load enemy scenes if not assigned
	if enemy_scene == null:
		enemy_scene = load("res://src/Entities/Enemy.tscn")
	if fast_enemy_scene == null:
		fast_enemy_scene = load("res://src/Entities/FastEnemy.tscn")
	
	# Connect to dungeon generation signal if available
	if _dungeon_generator and _dungeon_generator.has_signal("dungeon_generated"):
		_dungeon_generator.dungeon_generated.connect(_on_dungeon_generated)
	
	# Spawn enemies after a short delay (to ensure dungeon is ready)
	await get_tree().create_timer(0.1).timeout
	spawn_enemies()


func _find_dungeon_generator() -> Node2D:
	var parent = get_parent()
	if parent and parent.has_node("DungeonGenerator"):
		return parent.get_node("DungeonGenerator")
	return null


func spawn_enemies() -> void:
	if not spawn_enabled:
		return
	
	# Clear existing enemies
	clear_enemies()
	
	if _dungeon_generator == null:
		return
	
	# Get room count and positions
	var room_count = _dungeon_generator.get_room_count()
	
	if room_count <= 1:
		print("EnemySpawner: Not enough rooms for enemies (skipping first room)")
		return
	
	# Spawn enemies in rooms (skip first room where player starts)
	for i in range(1, room_count):
		var room_enemy_count = randi_range(min_enemies_per_room, max_enemies_per_room)
		
		for j in range(room_enemy_count):
			var spawn_pos = _get_random_position_in_room(i)
			_spawn_enemy(spawn_pos)
	
	print("EnemySpawner: Spawned ", _spawned_enemies.size(), " enemies")


func _get_random_position_in_room(room_index: int) -> Vector2:
	if _dungeon_generator == null:
		return Vector2.ZERO
	
	var center = _dungeon_generator.get_random_room_center()
	# Add some randomness around the center (within 100 pixels)
	var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
	return center + offset


func _spawn_enemy(position: Vector2) -> void:
	var selected_scene: PackedScene
	
	# Choose enemy type based on ratio
	if use_variants and fast_enemy_scene != null and randf() < fast_enemy_ratio:
		selected_scene = fast_enemy_scene
	else:
		selected_scene = enemy_scene
	
	if selected_scene == null:
		return
	
	var enemy = selected_scene.instantiate()
	enemy.position = position
	
	# Add to parent (same level as dungeon)
	get_parent().add_child(enemy)
	_spawned_enemies.append(enemy)
	
	print("EnemySpawner: Spawned enemy at ", position)


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
