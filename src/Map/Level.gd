extends Node2D

## Level scene for The Drift
## Uses DungeonGenerator for procedural level generation

## DungeonGenerator reference
@onready var dungeon_generator: Node2D = $DungeonGenerator

## TileMap reference (accessible via DungeonGenerator)
@onready var tile_map: TileMap = $DungeonGenerator/TileMap

## Seed for level generation
var _level_seed: int = 0


func _ready() -> void:
	# Initialize the dungeon
	generate_level()


func generate_level(new_seed: int = 0) -> void:
	"""Generate a new level with optional seed"""
	_level_seed = new_seed
	if _level_seed == 0:
		_level_seed = randi()  # Random seed if none provided
	
	print("Level: Generating with seed ", _level_seed)
	
	# Delegate to DungeonGenerator
	dungeon_generator.generate_dungeon(_level_seed)


func regenerate_level() -> void:
	"""Regenerate the level with the same seed"""
	generate_level(_level_seed)


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


func _on_dungeon_generated() -> void:
	"""Signal handler called when dungeon generation is complete"""
	print("Level: Dungeon generation complete. Rooms: ", get_room_count())
