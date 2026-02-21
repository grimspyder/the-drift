## MapLoader — Loads hand-crafted JSON map files for The Drift
## Maps are created with the Map Editor tool and saved to assets/maps/
## Supports v1 (integer tile IDs) and v2 (atlas coordinate arrays)

class_name MapLoader
extends RefCounted

const TILE_SIZE: int = 32

# Function types: 0=solid, 1=floor, 2=hazard, 3=interactive, 4=light, 5=decorative
const FUNC_SOLID: int = 0
const FUNC_FLOOR: int = 1
const FUNC_HAZARD: int = 2
const FUNC_INTERACTIVE: int = 3
const FUNC_LIGHT: int = 4
const FUNC_DECORATIVE: int = 5


## Try to load a custom map for the given world. Returns empty dict if no map exists.
static func load_map(world_id: int) -> Dictionary:
	var map_path = "res://assets/maps/world_%d_level_1.json" % world_id
	var abs_path = ProjectSettings.globalize_path(map_path)
	
	print("MapLoader: Looking for custom map at: ", abs_path)
	
	var file = FileAccess.open(abs_path, FileAccess.READ)
	if not file:
		print("MapLoader: No custom map found — using procedural generation")
		return {}
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("MapLoader: JSON parse error: " + json.get_error_message())
		return {}
	
	var data = json.data
	if data == null or not data is Dictionary:
		push_error("MapLoader: JSON data is not a dictionary")
		return {}
	
	var version = int(data.get("version", 1))
	print("MapLoader: ✅ Loaded '", data.get("name", "?"), "' v", version, " (", int(data.get("width", 0)), "x", int(data.get("height", 0)), ")")
	return data


## Apply a loaded map to the TileMap. Returns true on success.
static func apply_map(map_data: Dictionary, tile_map: TileMap) -> bool:
	if map_data.is_empty():
		return false
	
	var width: int = int(map_data.get("width", 0))
	var height: int = int(map_data.get("height", 0))
	var version: int = int(map_data.get("version", 1))
	
	tile_map.clear()
	var placed = 0
	
	if version >= 3:
		# V3 format: walkable boolean grid (true = floor, false = wall)
		var walkable: Array = map_data.get("walkable", [])
		if walkable.size() == 0:
			push_error("MapLoader: No walkable data in v3 map!")
			return false
		print("MapLoader: Applying v3 walkable map ", width, "x", height)
		for y in range(walkable.size()):
			var row = walkable[y]
			if not row is Array:
				continue
			for x in range(row.size()):
				var is_floor = row[x]
				# Floor = atlas (1,0), Wall = atlas (0,0)
				var atlas_coord = Vector2i(1, 0) if is_floor else Vector2i(0, 0)
				tile_map.set_cell(0, Vector2i(x, y), 0, atlas_coord)
				placed += 1
	else:
		# V1/V2 format: tile arrays
		var map_tiles: Array = map_data.get("tiles", [])
		if map_tiles.size() == 0:
			push_error("MapLoader: No tile data in map!")
			return false
		print("MapLoader: Applying v", version, " map ", width, "x", height, " (", map_tiles.size(), " rows)")
		for y in range(map_tiles.size()):
			var row = map_tiles[y]
			if not row is Array:
				continue
			for x in range(row.size()):
				var cell = row[x]
				var atlas_coord: Vector2i
				
				if version >= 2:
					if cell is Array and cell.size() >= 2:
						atlas_coord = Vector2i(int(cell[0]), int(cell[1]))
					elif cell == null or (cell is float and cell == 0) or (cell is int and cell == 0):
						continue
					else:
						continue
				else:
					var tile_id: int = int(cell) if cell != null else 0
					if tile_id == 0:
						continue
					match tile_id:
						1, 8, 9, 10, 11, 12, 13, 16, 17:
							atlas_coord = Vector2i(0, 0)
						_:
							atlas_coord = Vector2i(1, 0)
				
				tile_map.set_cell(0, Vector2i(x, y), 0, atlas_coord)
				placed += 1
	
	print("MapLoader: Placed ", placed, " tiles")
	return true


## Get the player start position in world coordinates
static func get_player_start(map_data: Dictionary) -> Vector2:
	var start = map_data.get("player_start", [2, 2])
	return Vector2(int(start[0]) * TILE_SIZE + TILE_SIZE / 2, int(start[1]) * TILE_SIZE + TILE_SIZE / 2)


## Get the exit portal position in world coordinates
static func get_exit_position(map_data: Dictionary) -> Vector2:
	var exit_arr = map_data.get("exit_portal", [10, 10])
	return Vector2(int(exit_arr[0]) * TILE_SIZE + TILE_SIZE / 2, int(exit_arr[1]) * TILE_SIZE + TILE_SIZE / 2)


## Get all enemy spawn positions in world coordinates
static func get_enemy_spawns(map_data: Dictionary) -> Array:
	var spawns = map_data.get("enemy_spawns", [])
	var positions = []
	for s in spawns:
		positions.append(Vector2(int(s[0]) * TILE_SIZE + TILE_SIZE / 2, int(s[1]) * TILE_SIZE + TILE_SIZE / 2))
	return positions


## Check if a tile at given position is solid (for collision purposes)
static func is_tile_solid(map_data: Dictionary, x: int, y: int) -> bool:
	var version = int(map_data.get("version", 1))

	if version >= 3:
		# V3: boolean walkable grid — not walkable = solid
		var walkable: Array = map_data.get("walkable", [])
		if y < 0 or y >= walkable.size():
			return true
		var row = walkable[y]
		if not row is Array or x < 0 or x >= row.size():
			return true
		return not bool(row[x])

	var map_tiles = map_data.get("tiles", [])
	if y < 0 or y >= map_tiles.size():
		return true
	var row = map_tiles[y]
	if x < 0 or x >= row.size():
		return true
	var cell = row[x]

	if version >= 2:
		if cell is Array and cell.size() >= 3:
			return int(cell[2]) == FUNC_SOLID
		return false
	else:
		var tid = int(cell) if cell != null else 0
		return tid in [1, 8, 9, 10, 11, 12, 13, 16, 17]
