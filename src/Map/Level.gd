extends Node2D

## Level scene for The Drift
## A test room with walls and floor for gameplay testing

## TileMap node reference
@onready var tile_map: TileMap = $TileMap

## Room dimensions (in tiles)
const ROOM_WIDTH: int = 20
const ROOM_HEIGHT: int = 15

## Tile size (32x32 pixels)
const TILE_SIZE: int = 32


func _ready() -> void:
	_build_room()


func _build_room() -> void:
	# Build walls around the room perimeter
	for x in range(ROOM_WIDTH):
		# Top wall
		_set_tile_with_collision(x, 0, 0, "wall")
		# Bottom wall
		_set_tile_with_collision(x, ROOM_HEIGHT - 1, 0, "wall")
	
	for y in range(ROOM_HEIGHT):
		# Left wall
		_set_tile_with_collision(0, y, 0, "wall")
		# Right wall
		_set_tile_with_collision(ROOM_WIDTH - 1, y, 0, "wall")
	
	# Fill floor with floor tiles (no collision)
	for x in range(1, ROOM_WIDTH - 1):
		for y in range(1, ROOM_HEIGHT - 1):
			_set_floor_tile(x, y, 0)


func _set_tile_with_collision(x: int, y: int, layer: int, tile_type: String) -> void:
	var atlas_coords = Vector2i(0, 0) if tile_type == "wall" else Vector2i(1, 0)
	tile_map.set_cell(layer, Vector2i(x, y), 0, atlas_coords)


func _set_floor_tile(x: int, y: int, layer: int) -> void:
	var atlas_coords = Vector2i(1, 0)  # Floor tile
	tile_map.set_cell(layer, Vector2i(x, y), 0, atlas_coords)


func get_room_center() -> Vector2:
	# Calculate the center position in pixels
	var center_x = (ROOM_WIDTH * TILE_SIZE) / 2
	var center_y = (ROOM_HEIGHT * TILE_SIZE) / 2
	return Vector2(center_x, center_y)


func get_room_bounds() -> Rect2i:
	# Return the room bounds in tile coordinates
	return Rect2i(0, 0, ROOM_WIDTH, ROOM_HEIGHT)
