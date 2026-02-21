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

	var png_path = "res://assets/tilesets/world_%d.jpg" % _current_theme.theme_id
	var custom_tileset = _build_tileset_from_texture(png_path)
	if custom_tileset:
		tile_map.tile_set = custom_tileset
		tile_map.clear()
		# Custom tilesets have their own colors — don't modulate
		tile_map.modulate = Color.WHITE
		print("Level: Applied TileSet from: ", png_path)
	else:
		push_error("Level: Failed to build tileset from: " + png_path)
		# Fallback: use modulation for basic tiles
		tile_map.modulate = _current_theme.floor_color


func _build_tileset_from_texture(texture_path: String) -> TileSet:
	# Load texture directly from filesystem (bypasses Godot import system)
	var abs_path = ProjectSettings.globalize_path(texture_path)
	var image = Image.load_from_file(abs_path)
	if not image:
		push_error("Level: Could not load image from: " + abs_path)
		return null
	
	var img_w = image.get_width()
	var img_h = image.get_height()
	print("Level: Loaded sprite sheet ", img_w, "x", img_h, " format=", image.get_format(), " from ", abs_path)
	
	# Convert to RGBA8 so all image operations use the same format
	image.convert(Image.FORMAT_RGBA8)
	
	# The generated sheets are NxN grids (e.g. 640x640 with 4 columns)
	# Row 0 = floor variations, Row 1 = wall variations
	var cols = 4
	var rows = 4
	var src_tile_w = img_w / cols
	var src_tile_h = img_h / rows
	print("Level: Source tile size: ", src_tile_w, "x", src_tile_h)
	
	# Extract wall tile from row 1, col 0 (dark stone walls)
	var wall_img = image.get_region(Rect2i(0, src_tile_h, src_tile_w, src_tile_h))
	wall_img.resize(32, 32, Image.INTERPOLATE_NEAREST)
	
	# Extract floor tile from row 0, col 0 (stone floor)
	var floor_img = image.get_region(Rect2i(0, 0, src_tile_w, src_tile_h))
	floor_img.resize(32, 32, Image.INTERPOLATE_NEAREST)
	
	# Compose a 64x32 atlas image: wall at (0,0), floor at (1,0)
	var atlas_img = Image.create(64, 32, false, Image.FORMAT_RGBA8)
	atlas_img.blit_rect(wall_img, Rect2i(0, 0, 32, 32), Vector2i(0, 0))
	atlas_img.blit_rect(floor_img, Rect2i(0, 0, 32, 32), Vector2i(32, 0))
	
	var atlas_texture = ImageTexture.create_from_image(atlas_img)
	if not atlas_texture:
		push_error("Level: Could not create atlas texture")
		return null

	# Create TileSet with physics layer
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 2)
	tileset.set_physics_layer_collision_mask(0, 0)

	# Create atlas source from composed 64x32 atlas
	var source = TileSetAtlasSource.new()
	source.texture = atlas_texture
	source.texture_region_size = Vector2i(32, 32)

	# (0,0) = wall, (1,0) = floor — matches DungeonGenerator set_cell calls
	source.create_tile(Vector2i(0, 0))
	source.create_tile(Vector2i(1, 0))

	# Add source to tileset first
	var source_id = tileset.add_source(source)

	# Set collision on wall tile
	var wall_data: TileData = source.get_tile_data(Vector2i(0, 0), 0)
	wall_data.set_collision_polygons_count(0, 1)
	wall_data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16),
		Vector2(16, 16), Vector2(-16, 16)
	]))

	print("Level: Built TileSet — wall from row1, floor from row0, source_id=", source_id)
	return tileset


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
