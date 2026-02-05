extends Node2D

## DungeonGenerator - Procedural Level Generation for The Drift
## Generates random dungeons with non-overlapping rooms and L-shaped tunnels

# -------------------------------------------------------------------------
# Configuration
# -------------------------------------------------------------------------

## TileMap reference for placing tiles
@export var tile_map_path: NodePath

## Dungeon dimensions (in tiles)
@export var map_width: int = 80
@export var map_height: int = 45

## Room configuration
@export var min_room_size: int = 6
@export var max_room_size: int = 10
@export var target_room_count: int = 30
@export var max_attempts: int = 1000

## Seed for reproducible generation
@export var seed_value: int = 0

## Tile size (32x32 pixels)
const TILE_SIZE: int = 32

# -------------------------------------------------------------------------
# Internal State
# -------------------------------------------------------------------------

var _tile_map: TileMap
var _rng: RandomNumberGenerator
var _rooms: Array[Dictionary] = []

# -------------------------------------------------------------------------
# Room Class
# -------------------------------------------------------------------------

class Room:
	var position: Vector2i
	var size: Vector2i
	var center: Vector2i
	
	func _init(pos: Vector2i, sz: Vector2i):
		position = pos
		size = sz
		center = Vector2i(
			position.x + size.x / 2,
			position.y + size.y / 2
		)
	
	func intersects(other: Room) -> bool:
		# Add 1-tile buffer to prevent rooms from touching
		var my_left = position.x - 1
		var my_right = position.x + size.x + 1
		var my_top = position.y - 1
		var my_bottom = position.y + size.y + 1
		
		var other_left = other.position.x - 1
		var other_right = other.position.x + other.size.x + 1
		var other_top = other.position.y - 1
		var other_bottom = other.position.y + other.size.y + 1
		
		return (my_left < other_right and my_right > other_left and
				my_top < other_bottom and my_bottom > other_top)
	
	func get_rect() -> Rect2i:
		return Rect2i(position, size)

# -------------------------------------------------------------------------
# Public API
# -------------------------------------------------------------------------

func generate_dungeon(passed_seed: int = 0) -> void:
	"""Generate a new dungeon with the given seed (or random if 0)"""
	
	# Set up RNG with seed
	_rng = RandomNumberGenerator.new()
	if passed_seed != 0:
		seed_value = passed_seed
	else:
		seed_value = randi()
	_rng.seed = seed_value
	
	print("DungeonGenerator: Generating with seed ", seed_value)
	
	# Clear existing tiles
	_clear_tilemap()
	
	# Generate rooms
	_rooms.clear()
	_generate_rooms()
	
	# Generate tunnels connecting rooms
	_connect_rooms()
	
	# Generate outer walls
	_generate_boundary_walls()
	
	print("DungeonGenerator: Generated ", _rooms.size(), " rooms")


func get_random_room_center() -> Vector2:
	"""Get the center of a random room (for player/enemy spawning)"""
	if _rooms.is_empty():
		return Vector2(map_width * TILE_SIZE / 2, map_height * TILE_SIZE / 2)
	
	var random_room = _rooms.pick_random()
	return Vector2(random_room.center.x * TILE_SIZE, random_room.center.y * TILE_SIZE)


func get_first_room_center() -> Vector2:
	"""Get the center of the first room (for player spawning)"""
	if _rooms.is_empty():
		return Vector2(map_width * TILE_SIZE / 2, map_height * TILE_SIZE / 2)
	
	var first_room = _rooms[0]
	return Vector2(first_room.center.x * TILE_SIZE, first_room.center.y * TILE_SIZE)


func get_room_count() -> int:
	"""Return the number of generated rooms"""
	return _rooms.size()


func get_seed() -> int:
	"""Return the current seed value"""
	return seed_value


func clear_dungeon() -> void:
	"""Clear all tiles from the dungeon"""
	_clear_tilemap()
	_rooms.clear()


# -------------------------------------------------------------------------
# Room Generation
# -------------------------------------------------------------------------

func _generate_rooms() -> void:
	"""Generate random non-overlapping rooms"""
	var attempts = 0
	
	while _rooms.size() < target_room_count and attempts < max_attempts:
		attempts += 1
		
		# Random room size
		var room_width = _rng.randi_range(min_room_size, max_room_size)
		var room_height = _rng.randi_range(min_room_size, max_room_size)
		
		# Random room position (within map bounds, with 1-tile padding)
		var room_x = _rng.randi_range(1, map_width - room_width - 1)
		var room_y = _rng.randi_range(1, map_height - room_height - 1)
		
		var new_room = Room.new(Vector2i(room_x, room_y), Vector2i(room_width, room_height))
		
		# Check for overlaps with existing rooms
		if not _check_room_overlap(new_room):
			# Place the room
			_place_room(new_room)
			_rooms.append(new_room)
			print("Room ", _rooms.size(), ": pos(", room_x, ",", room_y, 
				  ") size(", room_width, "x", room_height, ")")
	
	print("Room generation complete: ", _rooms.size(), " rooms after ", attempts, " attempts")


func _check_room_overlap(room: Room) -> bool:
	"""Check if a room overlaps with any existing rooms"""
	for existing_room in _rooms:
		if room.intersects(existing_room):
			return true
	return false


func _place_room(room: Room) -> void:
	"""Place floor tiles for a room"""
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			_set_floor_tile(x, y)


# -------------------------------------------------------------------------
# Tunnel Generation
# -------------------------------------------------------------------------

func _connect_rooms() -> void:
	"""Connect rooms with L-shaped tunnels"""
	if _rooms.size() < 2:
		return
	
	for i in range(_rooms.size() - 1):
		var room_a = _rooms[i]
		var room_b = _rooms[i + 1]
		_create_l_tunnel(room_a.center, room_b.center)


func _create_l_tunnel(start: Vector2i, end: Vector2i) -> void:
	"""Create an L-shaped tunnel between two points"""
	# Randomly choose horizontal-first or vertical-first
	if _rng.randf() < 0.5:
		# Horizontal then vertical
		_carve_h_tunnel(start.x, end.x, start.y)
		_carve_v_tunnel(start.y, end.y, end.x)
	else:
		# Vertical then horizontal
		_carve_v_tunnel(start.y, end.y, start.x)
		_carve_h_tunnel(start.x, end.x, end.y)


func _carve_h_tunnel(x1: int, x2: int, y: int) -> void:
	"""Carve a horizontal tunnel"""
	var start_x = mini(x1, x2)
	var end_x = maxi(x1, x2)
	for x in range(start_x, end_x + 1):
		_set_floor_tile(x, y)


func _carve_v_tunnel(y1: int, y2: int, x: int) -> void:
	"""Carve a vertical tunnel"""
	var start_y = mini(y1, y2)
	var end_y = maxi(y1, y2)
	for y in range(start_y, end_y + 1):
		_set_floor_tile(x, y)


# -------------------------------------------------------------------------
# Boundary Walls
# -------------------------------------------------------------------------

func _generate_boundary_walls() -> void:
	"""Generate walls around the dungeon perimeter"""
	# Top and bottom walls
	for x in range(map_width):
		_set_wall_tile(x, 0)
		_set_wall_tile(x, map_height - 1)
	
	# Left and right walls
	for y in range(map_height):
		_set_wall_tile(0, y)
		_set_wall_tile(map_width - 1, y)


# -------------------------------------------------------------------------
# Tile Operations
# -------------------------------------------------------------------------

func _clear_tilemap() -> void:
	"""Clear all tiles from the TileMap"""
	if _tile_map:
		_tile_map.clear()


func _set_wall_tile(x: int, y: int) -> void:
	"""Set a wall tile at the specified position"""
	if _tile_map:
		_tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))


func _set_floor_tile(x: int, y: int) -> void:
	"""Set a floor tile at the specified position"""
	if _tile_map:
		_tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))


# -------------------------------------------------------------------------
# Node Lifecycle
# -------------------------------------------------------------------------

func _ready() -> void:
	# Get TileMap reference - look in parent (Level) if not in self
	if tile_map_path:
		var path_str = tile_map_path
		if path_str.begins_with("../"):
			# Relative path from parent
			var parent = get_parent()
			if parent and parent.has_node(path_str.substr(3)):
				_tile_map = parent.get_node(path_str.substr(3))
		elif has_node(path_str):
			_tile_map = get_node(path_str)
	
	# Fallback: look for TileMap in parent (Level node)
	if not _tile_map and get_parent().has_node("TileMap"):
		_tile_map = get_parent().get_node("TileMap")
	
	# Validate TileMap exists
	if not _tile_map:
		push_error("DungeonGenerator: TileMap not found! Please assign tile_map_path or add a TileMap child node.")
		return
	
	print("DungeonGenerator ready. Map size: ", map_width, "x", map_height)
	
	# Auto-generate dungeon on ready (can be disabled in inspector)
	generate_dungeon()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if tile_map_path == null or not has_node(tile_map_path):
		if not has_node("TileMap"):
			warnings.append("No TileMap assigned or found. Please add a TileMap child or assign tile_map_path.")
	
	return warnings
