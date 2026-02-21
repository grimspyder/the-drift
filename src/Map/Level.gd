extends Node2D

## Level scene for The Drift
## Uses DungeonGenerator for procedural level generation with theme support

## Preload MapLoader script (class_name may not be available without .uid)
const MapLoaderScript = preload("res://src/Map/MapLoader.gd")

const TILE_SIZE: int = 32

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
		_level_seed = randi()
	
	print("Level: Generating with seed ", _level_seed)
	
	# Get theme for world 0 (starting world)
	_current_theme = _theme_db.get_theme_for_world_id(0)
	
	# Try custom map first, then fall back to procedural
	var map_data = MapLoaderScript.load_map(0)
	if not map_data.is_empty():
		var version = int(map_data.get("version", 1))
		if version >= 3:
			_apply_image_map(map_data, 0)
		else:
			_setup_custom_map_tileset()
			_apply_custom_map(map_data, 0)
	else:
		# Procedural: apply theme tileset then generate
		_apply_theme_to_tilemap()
		dungeon_generator.apply_theme_settings(_current_theme)
		dungeon_generator.generate_dungeon(_level_seed)
		_place_portal(0)
	
	print("Level: Generation complete")


func _setup_custom_map_tileset() -> void:
	"""Create a TileSet for custom maps using the world atlas PNG."""
	var atlas_tex: ImageTexture = null
	
	# Try to load the world atlas PNG
	if _current_theme:
		var atlas_path = "res://assets/tilesets/world_%d_atlas.png" % _current_theme.theme_id
		var abs_path = ProjectSettings.globalize_path(atlas_path)
		var image = Image.load_from_file(abs_path)
		if image:
			image.convert(Image.FORMAT_RGBA8)
			atlas_tex = ImageTexture.create_from_image(image)
			print("Level: Loaded world atlas: ", abs_path, " (", image.get_width(), "x", image.get_height(), ")")
	
	# Fallback: try basic_tiles.png
	if not atlas_tex:
		var fallback_path = ProjectSettings.globalize_path("res://assets/tilesets/basic_tiles.png")
		var image = Image.load_from_file(fallback_path)
		if image:
			image.convert(Image.FORMAT_RGBA8)
			atlas_tex = ImageTexture.create_from_image(image)
			print("Level: Using fallback basic_tiles.png")
	
	# Last resort: generate programmatic tiles
	if not atlas_tex:
		var atlas_img = Image.create(64, 32, false, Image.FORMAT_RGBA8)
		for y in range(32):
			for x in range(32):
				atlas_img.set_pixel(x, y, Color(0.16, 0.16, 0.21))
				atlas_img.set_pixel(32 + x, y, Color(0.54, 0.48, 0.38))
		atlas_tex = ImageTexture.create_from_image(atlas_img)
		print("Level: Using programmatic fallback tiles")
	
	# Build TileSet
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 2)
	tileset.set_physics_layer_collision_mask(0, 0)
	
	var source = TileSetAtlasSource.new()
	source.texture = atlas_tex
	source.texture_region_size = Vector2i(32, 32)
	
	var cols = atlas_tex.get_width() / 32
	var rows = atlas_tex.get_height() / 32
	for row in range(rows):
		for col in range(cols):
			source.create_tile(Vector2i(col, row))
	
	tileset.add_source(source)
	
	# Wall collision (row 0 = walls)
	for col in range(cols):
		var wall_data = source.get_tile_data(Vector2i(col, 0), 0)
		if wall_data:
			wall_data.set_collision_polygons_count(0, 1)
			wall_data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(-16, -16), Vector2(16, -16),
				Vector2(16, 16), Vector2(-16, 16)
			]))
	
	tile_map.tile_set = tileset
	tile_map.clear()
	tile_map.modulate = Color.WHITE
	print("Level: Custom map tileset ready (", cols, "x", rows, " tiles)")


func regenerate_level() -> void:
	"""Regenerate the level with the same seed"""
	generate_level(_level_seed)


func regenerate_level_with_seed(new_seed: int) -> void:
	"""Regenerate the level with a new seed (used during drift)"""
	_play_drift_transition()
	
	_level_seed = new_seed
	
	var game_manager = get_node_or_null("/root/GameManager")
	var world_id = 0
	if game_manager and "world_id" in game_manager:
		world_id = game_manager.world_id
	
	_current_theme = _theme_db.get_theme_for_world_id(world_id)
	_apply_theme_to_tilemap()
	
	# Try custom map first, then fall back to procedural
	var map_data = MapLoaderScript.load_map(world_id)
	if not map_data.is_empty():
		var version = int(map_data.get("version", 1))
		if version >= 3:
			_apply_image_map(map_data, world_id)
		else:
			_apply_custom_map(map_data, world_id)
	else:
		dungeon_generator.apply_theme_settings(_current_theme)
		dungeon_generator.generate_dungeon(_level_seed)
		_place_portal(world_id)
	
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


func _apply_image_map(map_data: Dictionary, world_id: int) -> void:
	"""Apply a v3 image-based map: uploaded image as background, walkable grid for collision."""
	var width: int = int(map_data.get("width", 0))
	var height: int = int(map_data.get("height", 0))
	print("Level: Loading v3 image map for world ", world_id, " (", width, "x", height, ")")

	# Remove any previous background sprite
	_clear_map_background()

	# Decode and place the embedded image as a background Sprite2D
	var image_data_str: String = map_data.get("image_data", "")
	if image_data_str != "":
		var texture = _decode_base64_image(image_data_str)
		if texture:
			_place_map_background(texture, width, height)
		else:
			push_error("Level: Failed to decode embedded map image")
	else:
		print("Level: v3 map has no image_data — rendering without background")

	# Set up a collision-only tileset (transparent tiles, walls have physics)
	_setup_collision_only_tileset()

	# Apply walkable grid to TileMap (wall = atlas 0,0 with collision, floor = atlas 1,0)
	MapLoaderScript.apply_map(map_data, tile_map)

	# Place player spawn and exit
	var spawn_pos = MapLoaderScript.get_player_start(map_data)
	dungeon_generator._player_spawn_point = spawn_pos
	print("Level: Image map player start at ", spawn_pos)

	var exit_pos = MapLoaderScript.get_exit_position(map_data)
	_spawn_exit_at(exit_pos, world_id)

	print("Level: v3 image map loaded — ", width, "x", height)


func _decode_base64_image(data_url: String) -> ImageTexture:
	"""Decode a base64 data URL (data:image/png;base64,...) into an ImageTexture."""
	var comma = data_url.find(",")
	if comma == -1:
		push_error("Level: Invalid image data URL (no comma separator)")
		return null

	var b64 = data_url.substr(comma + 1)
	var bytes: PackedByteArray = Marshalls.base64_to_raw(b64)
	if bytes.is_empty():
		push_error("Level: base64 decode produced empty buffer")
		return null

	var img = Image.new()
	var err = img.load_png_from_buffer(bytes)
	if err != OK:
		# Try JPG as fallback
		err = img.load_jpg_from_buffer(bytes)
	if err != OK:
		push_error("Level: Could not decode image from buffer, error: " + str(err))
		return null

	img.convert(Image.FORMAT_RGBA8)
	print("Level: Decoded map image: ", img.get_width(), "x", img.get_height())
	return ImageTexture.create_from_image(img)


func _place_map_background(texture: ImageTexture, map_w: int, map_h: int) -> void:
	"""Add a Sprite2D behind the TileMap displaying the full map image."""
	var sprite = Sprite2D.new()
	sprite.name = "MapBackground"
	sprite.texture = texture
	sprite.z_index = -10

	# Center the sprite on the map area (tiles start at TileMap origin)
	var map_pixel_w = map_w * TILE_SIZE
	var map_pixel_h = map_h * TILE_SIZE
	sprite.position = tile_map.position + Vector2(map_pixel_w * 0.5, map_pixel_h * 0.5)
	sprite.scale = Vector2(
		float(map_pixel_w) / float(texture.get_width()),
		float(map_pixel_h) / float(texture.get_height())
	)

	add_child(sprite)
	print("Level: Map background placed — ", map_pixel_w, "x", map_pixel_h, " px")


func _clear_map_background() -> void:
	"""Remove any existing background sprite from a previous map load."""
	var existing = get_node_or_null("MapBackground")
	if existing:
		existing.queue_free()


func _setup_collision_only_tileset() -> void:
	"""Build a TileSet with fully transparent tiles so the image shows through,
	but wall tiles (atlas 0,0) still have physics collision shapes."""
	# 2x1 transparent texture: col 0 = wall slot, col 1 = floor slot
	var img = Image.create(TILE_SIZE * 2, TILE_SIZE, false, Image.FORMAT_RGBA8)
	# Leave all pixels transparent
	var texture = ImageTexture.create_from_image(img)

	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 2)
	tileset.set_physics_layer_collision_mask(0, 0)

	var source = TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	source.create_tile(Vector2i(0, 0))  # wall
	source.create_tile(Vector2i(1, 0))  # floor

	tileset.add_source(source)

	# Wall tile gets a full-cell collision polygon
	var wall_data: TileData = source.get_tile_data(Vector2i(0, 0), 0)
	if wall_data:
		wall_data.set_collision_polygons_count(0, 1)
		wall_data.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(-16, -16), Vector2(16, -16),
			Vector2(16, 16), Vector2(-16, 16)
		]))

	tile_map.tile_set = tileset
	tile_map.clear()
	tile_map.modulate = Color.WHITE
	print("Level: Collision-only tileset ready")


func _apply_custom_map(map_data: Dictionary, world_id: int) -> void:
	"""Apply a hand-crafted map from the Map Editor"""
	print("Level: Loading custom map for world ", world_id)
	
	# Debug: print TileSet info before applying
	print("Level: TileMap tileset has ", tile_map.tile_set.get_source_count(), " sources")
	var source = tile_map.tile_set.get_source(tile_map.tile_set.get_source_id(0)) as TileSetAtlasSource
	if source:
		print("Level: Source texture: ", source.texture, " size: ", source.texture.get_width(), "x", source.texture.get_height())
	
	# Apply tiles to the TileMap
	MapLoaderScript.apply_map(map_data, tile_map)
	tile_map.modulate = Color.WHITE
	tile_map.z_index = 0
	
	# Debug: verify tiles were placed
	var used = tile_map.get_used_cells(0)
	print("Level: TileMap now has ", used.size(), " cells on layer 0")
	
	# Set player spawn from map data
	var spawn_pos = MapLoaderScript.get_player_start(map_data)
	dungeon_generator._player_spawn_point = spawn_pos
	print("Level: Custom map player start at ", spawn_pos)
	
	# Place exit portal directly from map data (don't use DungeonGenerator for this)
	var exit_pos = MapLoaderScript.get_exit_position(map_data)
	_spawn_exit_at(exit_pos, world_id)
	
	print("Level: Custom map loaded — ", map_data.get("width", 0), "x", map_data.get("height", 0))


func _spawn_exit_at(position: Vector2, world_id: int) -> void:
	"""Spawn exit stairs directly at a position (for custom maps)"""
	var stairs_scene = load("res://src/Map/ExitStairs.tscn")
	if stairs_scene:
		var stairs = stairs_scene.instantiate()
		stairs.global_position = position
		add_child(stairs)
		
		if stairs.has_method("set_world_id"):
			stairs.set_world_id(world_id)
		
		# Register with GameManager
		var game_manager = get_node_or_null("/root/GameManager")
		if game_manager and game_manager.has_method("register_exit_stairs"):
			game_manager.register_exit_stairs(stairs)
		
		print("Level: Exit portal spawned at ", position, " for world ", world_id)
	else:
		push_error("Level: Failed to load ExitStairs scene!")


func _apply_theme_to_tilemap() -> void:
	if not tile_map or not _current_theme:
		push_error("Level: Cannot apply theme - tile_map or _current_theme is null!")
		return

	# First try pre-made atlas (exported from Tile Selector tool)
	var atlas_path = "res://assets/tilesets/world_%d_atlas.png" % _current_theme.theme_id
	var custom_tileset = _build_tileset_from_atlas(atlas_path)
	
	if not custom_tileset:
		# Fallback: try the full sprite sheet with region extraction
		var sheet_path = "res://assets/tilesets/world_%d.png" % _current_theme.theme_id
		custom_tileset = _build_tileset_from_spritesheet(sheet_path)
	
	if custom_tileset:
		tile_map.tile_set = custom_tileset
		tile_map.clear()
		tile_map.modulate = Color.WHITE
		print("Level: Applied custom TileSet for world ", _current_theme.theme_id)
	else:
		push_error("Level: Failed to load any tileset for world " + str(_current_theme.theme_id))
		tile_map.modulate = _current_theme.floor_color


func _build_tileset_from_atlas(atlas_path: String) -> TileSet:
	"""Build a TileSet from a pre-made 64x32 atlas PNG (wall at 0,0 | floor at 32,0).
	These atlases are exported by the Tile Selector tool."""
	var abs_path = ProjectSettings.globalize_path(atlas_path)
	var image = Image.load_from_file(abs_path)
	if not image:
		print("Level: No atlas found at ", abs_path, " — will try sprite sheet")
		return null
	
	image.convert(Image.FORMAT_RGBA8)
	print("Level: Loaded atlas ", image.get_width(), "x", image.get_height(), " from ", abs_path)
	
	var texture = ImageTexture.create_from_image(image)
	if not texture:
		return null
	
	return _create_tileset_from_texture(texture)


func _build_tileset_from_spritesheet(texture_path: String) -> TileSet:
	"""Build a TileSet by extracting wall/floor tiles from a full sprite sheet."""
	var abs_path = ProjectSettings.globalize_path(texture_path)
	var image = Image.load_from_file(abs_path)
	if not image:
		push_error("Level: Could not load image from: " + abs_path)
		return null
	
	image.convert(Image.FORMAT_RGBA8)
	print("Level: Loaded sprite sheet ", image.get_width(), "x", image.get_height(), " from ", abs_path)
	
	var tile_regions = _get_tile_regions_for_theme()
	var wall_rect: Rect2i = tile_regions.wall
	var floor_rect: Rect2i = tile_regions.floor
	var wall_fill: Color = tile_regions.get("wall_fill", Color(0.15, 0.15, 0.2))
	var floor_fill: Color = tile_regions.get("floor_fill", Color(0.35, 0.33, 0.3))
	
	var wall_img = image.get_region(wall_rect)
	var floor_img = image.get_region(floor_rect)
	_fill_transparent_pixels(wall_img, wall_fill)
	_fill_transparent_pixels(floor_img, floor_fill)
	wall_img.resize(32, 32, Image.INTERPOLATE_NEAREST)
	floor_img.resize(32, 32, Image.INTERPOLATE_NEAREST)
	
	var atlas_img = Image.create(64, 32, false, Image.FORMAT_RGBA8)
	atlas_img.blit_rect(wall_img, Rect2i(0, 0, 32, 32), Vector2i(0, 0))
	atlas_img.blit_rect(floor_img, Rect2i(0, 0, 32, 32), Vector2i(32, 0))
	
	var atlas_texture = ImageTexture.create_from_image(atlas_img)
	if not atlas_texture:
		return null
	return _create_tileset_from_texture(atlas_texture)


func _create_tileset_from_texture(texture: Texture2D) -> TileSet:
	"""Create a TileSet from an atlas texture. Supports both formats:
	- Old: 64x32 (2 tiles: wall at 0,0 / floor at 1,0)
	- New: 192x128 (6x4 grid: row0=walls, row1=floors, row2=corridors, row3=specials)"""
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 2)
	tileset.set_physics_layer_collision_mask(0, 0)

	var source = TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(32, 32)

	var tex_w = texture.get_width()
	var tex_h = texture.get_height()
	var cols = tex_w / 32
	var rows = tex_h / 32
	print("Level: Atlas is ", tex_w, "x", tex_h, " = ", cols, " cols x ", rows, " rows")

	# Create tiles for every valid position in the atlas
	for row in range(rows):
		for col in range(cols):
			var coord = Vector2i(col, row)
			source.create_tile(coord)

	var source_id = tileset.add_source(source)

	# Set collision on all wall tiles (row 0 - walls)
	# Only set collision for walls, NOT for floors/corridors (player can walk there)
	for col in range(cols):
		var wall_data: TileData = source.get_tile_data(Vector2i(col, 0), 0)
		if wall_data:
			wall_data.set_collision_polygons_count(0, 1)
			wall_data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(-16, -16), Vector2(16, -16),
				Vector2(16, 16), Vector2(-16, 16)
			]))

	print("Level: Built TileSet — ", cols * rows, " tiles, source_id=", source_id)
	return tileset


func _get_tile_regions_for_theme() -> Dictionary:
	var theme_id = _current_theme.theme_id if _current_theme else 0
	match theme_id:
		0:
			return {
				"wall": Rect2i(615, 0, 200, 130),
				"floor": Rect2i(615, 165, 200, 165),
				"wall_fill": Color(0.12, 0.12, 0.15),
				"floor_fill": Color(0.35, 0.33, 0.30),
			}
		1:
			return {
				"wall": Rect2i(512, 0, 256, 256),
				"floor": Rect2i(0, 0, 256, 256),
				"wall_fill": Color(0.18, 0.25, 0.12),
				"floor_fill": Color(0.30, 0.45, 0.20),
			}
		2:
			return {
				"wall": Rect2i(0, 0, 400, 300),
				"floor": Rect2i(0, 340, 170, 170),
				"wall_fill": Color(0.45, 0.32, 0.18),
				"floor_fill": Color(0.65, 0.55, 0.35),
			}
		3:
			return {
				"wall": Rect2i(0, 0, 205, 300),
				"floor": Rect2i(0, 620, 205, 200),
				"wall_fill": Color(0.15, 0.05, 0.25),
				"floor_fill": Color(0.08, 0.06, 0.15),
			}
		4:
			return {
				"wall": Rect2i(615, 0, 200, 175),
				"floor": Rect2i(0, 195, 205, 195),
				"wall_fill": Color(0.12, 0.08, 0.05),
				"floor_fill": Color(0.10, 0.06, 0.04),
			}
		5:
			return {
				"wall": Rect2i(0, 170, 330, 170),
				"floor": Rect2i(0, 340, 330, 170),
				"wall_fill": Color(0.12, 0.02, 0.18),
				"floor_fill": Color(0.06, 0.01, 0.10),
			}
		_:
			return {
				"wall": Rect2i(0, 0, 200, 200),
				"floor": Rect2i(200, 0, 200, 200),
				"wall_fill": Color(0.15, 0.15, 0.15),
				"floor_fill": Color(0.35, 0.35, 0.35),
			}


func _fill_transparent_pixels(img: Image, fill_color: Color) -> void:
	"""Replace transparent pixels with a solid fill color so tiles render
	correctly when repeated in the TileMap (no white gaps from PNG transparency)."""
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var pixel = img.get_pixel(x, y)
			if pixel.a < 0.5:
				img.set_pixel(x, y, fill_color)
			elif pixel.a < 1.0:
				var blended = fill_color.lerp(pixel, pixel.a)
				blended.a = 1.0
				img.set_pixel(x, y, blended)


func get_player_spawn_position() -> Vector2:
	"""Get the player spawn position (valid floor position in first room, away from walls)"""
	return dungeon_generator.get_player_spawn_point()


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
# Portal Placement
# -------------------------------------------------------------------------

func _place_portal(world_id: int) -> void:
	"""Place a portal in the dungeon that allows player to advance to the next level"""
	if dungeon_generator and dungeon_generator.has_method("place_exit_stairs"):
		var portal_pos = dungeon_generator.place_exit_stairs()
		
		# Get the portal/stairs node and configure it for this world
		var portal = dungeon_generator.get_exit_stairs()
		if portal and portal.has_method("set_world_id"):
			portal.set_world_id(world_id)
		
		print("Level: Portal placed at ", portal_pos, " for world ", world_id)
	else:
		print("Level: Failed to place portal - DungeonGenerator method not available")
