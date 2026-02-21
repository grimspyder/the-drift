extends Node2D

## Level scene for The Drift
## Uses DungeonGenerator for procedural level generation with theme support

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
		_level_seed = randi() # Random seed if none provided
	
	print("Level: Generating with seed ", _level_seed)
	
	# Get theme for world 0 (starting world)
	_current_theme = _theme_db.get_theme_for_world_id(0)
	
	# Apply theme-specific settings to dungeon generator
	dungeon_generator.apply_theme_settings(_current_theme)
	
	# Load custom tileset BEFORE dungeon generation (so tiles are placed correctly)
	_apply_theme_to_tilemap()
	
	# Delegate to DungeonGenerator
	dungeon_generator.generate_dungeon(_level_seed)
	
	# Place portal (in ALL levels - allows player to advance)
	_place_portal(0)
	
	print("Level: Generation complete")


func regenerate_level() -> void:
	"""Regenerate the level with the same seed"""
	generate_level(_level_seed)


func regenerate_level_with_seed(new_seed: int) -> void:
	"""Regenerate the level with a new seed (used during drift)"""
	# Play transition effect
	_play_drift_transition()
	
	# Generate new level
	_level_seed = new_seed
	
	# Get world_id from GameManager (access as property, not has())
	var game_manager = get_node_or_null("/root/GameManager")
	var world_id = 0
	if game_manager and "world_id" in game_manager:
		world_id = game_manager.world_id
	
	_current_theme = _theme_db.get_theme_for_world_id(world_id)
	
	# Apply theme-specific settings to dungeon generator
	dungeon_generator.apply_theme_settings(_current_theme)
	
	# Load custom tileset BEFORE dungeon generation (so tiles are placed correctly)
	_apply_theme_to_tilemap()
	
	dungeon_generator.generate_dungeon(_level_seed)
	
	# Place portal in ALL levels
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
	"""Create a TileSet from a 64x32 atlas texture: wall=(0,0), floor=(1,0)."""
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 2)
	tileset.set_physics_layer_collision_mask(0, 0)

	var source = TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(32, 32)

	source.create_tile(Vector2i(0, 0)) # Wall
	source.create_tile(Vector2i(1, 0)) # Floor

	var source_id = tileset.add_source(source)

	# Wall collision
	var wall_data: TileData = source.get_tile_data(Vector2i(0, 0), 0)
	wall_data.set_collision_polygons_count(0, 1)
	wall_data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16),
		Vector2(16, 16), Vector2(-16, 16)
	]))

	print("Level: Built TileSet — source_id=", source_id)
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
