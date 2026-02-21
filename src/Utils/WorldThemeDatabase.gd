## WorldThemeDatabase - Central registry for world themes in The Drift
## Defines the 5 world variations: Prime, Verdant, Arid, Crystalline, Ashen

class_name WorldThemeDatabase
extends Node

## All registered themes
var _themes: Dictionary = {}

## Current active theme
var _current_theme: WorldTheme


func _ready() -> void:
	_register_all_themes()


func _register_all_themes() -> void:
	# Theme 0: Prime (default)
	var prime = WorldTheme.new()
	prime.theme_id = 0
	prime.display_name = "Prime World"
	prime.description = "The original reality - a dimension of stability and familiar danger."
	prime.floor_color = Color(0.45, 0.4, 0.35)
	prime.wall_color = Color(0.25, 0.22, 0.2)
	prime.ambient_light_color = Color(0.6, 0.6, 0.6)
	prime.ambient_light_energy = 0.7
	prime.enemy_spawn_rate_mod = 1.0
	prime.enemy_health_mod = 1.0
	prime.enemy_damage_mod = 1.0
	prime.resource_spawn_mod = 1.0
	prime.tile_set_path = "res://assets/tilesets/world_0.tres"
	register_theme(prime)
	
	# Theme 1: Verdant (green, nature)
	var verdant = WorldTheme.new()
	verdant.theme_id = 1
	verdant.display_name = "Verdant Realm"
	verdant.description = "A world overrun with lush vegetation and bioluminescent flora."
	verdant.floor_color = Color(0.2, 0.35, 0.2)
	verdant.wall_color = Color(0.15, 0.25, 0.15)
	verdant.ambient_light_color = Color(0.3, 0.6, 0.4)
	verdant.ambient_light_energy = 0.6
	verdant.fog_color = Color(0.2, 0.4, 0.25)
	verdant.fog_density = 0.03
	verdant.enemy_spawn_rate_mod = 1.1
	verdant.enemy_health_mod = 0.9
	verdant.enemy_damage_mod = 1.0
	verdant.resource_spawn_mod = 1.3
	verdant.special_enemies = ["plant", "fungus"]
	verdant.hazards = ["spores", "thorns"]
	verdant.visual_overlay = "sparkles"
	verdant.is_easy_mode = true
	verdant.tile_set_path = "res://assets/tilesets/world_1.tres"
	register_theme(verdant)
	
	# Theme 2: Arid (yellow, desert)
	var arid = WorldTheme.new()
	arid.theme_id = 2
	arid.display_name = "Arid Wastes"
	arid.description = "A scorching desert dimension of endless dunes and ancient ruins."
	arid.floor_color = Color(0.85, 0.75, 0.5)
	arid.wall_color = Color(0.6, 0.5, 0.3)
	arid.ambient_light_color = Color(0.9, 0.8, 0.6)
	arid.ambient_light_energy = 0.9
	arid.fog_color = Color(0.9, 0.7, 0.4)
	arid.fog_density = 0.01
	arid.enemy_spawn_rate_mod = 0.9
	arid.enemy_health_mod = 1.2
	arid.enemy_damage_mod = 1.1
	arid.resource_spawn_mod = 0.7
	arid.special_enemies = ["sand_worm", "scarab"]
	arid.hazards = ["heat", "sandstorms"]
	arid.visual_overlay = "heat_haze"
	arid.is_hard_mode = true
	arid.tile_set_path = "res://assets/tilesets/world_2.tres"
	register_theme(arid)
	
	# Theme 3: Crystalline (blue, magic)
	var crystalline = WorldTheme.new()
	crystalline.theme_id = 3
	crystalline.display_name = "Crystalline Void"
	crystalline.description = "A dimension of floating crystal formations infused with raw magic."
	crystalline.floor_color = Color(0.3, 0.4, 0.6)
	crystalline.wall_color = Color(0.2, 0.3, 0.5)
	crystalline.ambient_light_color = Color(0.4, 0.6, 0.9)
	crystalline.ambient_light_energy = 0.8
	crystalline.fog_color = Color(0.4, 0.5, 0.8)
	crystalline.fog_density = 0.04
	crystalline.enemy_spawn_rate_mod = 1.2
	crystalline.enemy_health_mod = 1.1
	crystalline.enemy_damage_mod = 1.2
	crystalline.resource_spawn_mod = 1.5
	crystalline.special_enemies = ["crystal_golem", "magic_mirror"]
	crystalline.hazards = ["arcane_surge", "gravity_wells"]
	crystalline.visual_overlay = "magic_particles"
	crystalline.is_hard_mode = true
	crystalline.tile_set_path = "res://assets/tilesets/world_3.tres"
	register_theme(crystalline)
	
	# Theme 4: Ashen (red/black, fire)
	var ashen = WorldTheme.new()
	ashen.theme_id = 4
	ashen.display_name = "Ashen Realm"
	ashen.description = "A world burned to ash, home to fire elementals and undead warriors."
	ashen.floor_color = Color(0.2, 0.18, 0.18)
	ashen.wall_color = Color(0.15, 0.12, 0.12)
	ashen.ambient_light_color = Color(0.7, 0.3, 0.2)
	ashen.ambient_light_energy = 0.5
	ashen.fog_color = Color(0.3, 0.2, 0.2)
	ashen.fog_density = 0.05
	ashen.enemy_spawn_rate_mod = 1.0
	ashen.enemy_health_mod = 1.3
	ashen.enemy_damage_mod = 1.3
	ashen.resource_spawn_mod = 0.8
	ashen.special_enemies = ["fire_elemental", "ash_zombie"]
	ashen.hazards = ["fire", "ember_storm"]
	ashen.visual_overlay = "embers"
	ashen.is_hard_mode = true
	ashen.tile_set_path = "res://assets/tilesets/world_4.tres"
	register_theme(ashen)
	
	# Theme 5: Shadow Realm (purple/black, dark)
	var shadow = WorldTheme.new()
	shadow.theme_id = 5
	shadow.display_name = "Shadow Realm"
	shadow.description = "A dark dimension of shadows and void creatures. Navigation is difficult."
	shadow.floor_color = Color(0.15, 0.12, 0.2)
	shadow.wall_color = Color(0.08, 0.06, 0.12)
	shadow.ambient_light_color = Color(0.3, 0.2, 0.4)
	shadow.ambient_light_energy = 0.4
	shadow.fog_color = Color(0.1, 0.08, 0.15)
	shadow.fog_density = 0.08
	shadow.enemy_spawn_rate_mod = 1.3
	shadow.enemy_health_mod = 1.4
	shadow.enemy_damage_mod = 1.5
	shadow.resource_spawn_mod = 0.5
	shadow.special_enemies = ["shadow_wraith", "void_beast"]
	shadow.hazards = ["darkness", "void_portals"]
	shadow.visual_overlay = "shadow_mist"
	shadow.is_hard_mode = true
	# Map settings for this world
	shadow.map_width = 60 # Smaller map = more claustrophobic
	shadow.map_height = 35
	shadow.min_room_size = 4
	shadow.max_room_size = 7
	shadow.target_room_count = 20
	shadow.tile_set_path = "res://assets/tilesets/world_5.tres"
	register_theme(shadow)
	
	print("WorldThemeDatabase: Registered ", _themes.size(), " world themes")


func register_theme(theme: WorldTheme) -> void:
	_themes[theme.theme_id] = theme


func get_theme(theme_id: int) -> WorldTheme:
	if _themes.has(theme_id):
		return _themes[theme_id]
	return _themes[0] # Return Prime as fallback


func get_current_theme() -> WorldTheme:
	return get_theme(_current_theme.theme_id if _current_theme else 0)


func get_theme_by_name(name: String) -> WorldTheme:
	for theme in _themes.values():
		if theme.display_name.to_lower() == name.to_lower():
			return theme
	return null


func cycle_theme(current_id: int) -> WorldTheme:
	var next_id = (current_id + 1) % _themes.size()
	return get_theme(next_id)


func get_random_theme() -> WorldTheme:
	var ids = _themes.keys()
	return get_theme(ids.pick_random())


func get_all_themes() -> Array:
	return _themes.values()


func get_theme_count() -> int:
	return _themes.size()


func get_theme_for_world_id(world_id: int) -> WorldTheme:
	# Themes cycle through the available options based on world_id
	var theme_count = _themes.size()
	var theme_index = world_id % theme_count
	return get_theme(theme_index)


func get_difficulty_indicator(theme_id: int) -> String:
	var theme = get_theme(theme_id)
	if theme.is_easy_mode:
		return "★☆☆ (Easy)"
	elif theme.is_hard_mode:
		return "★★☆ (Hard)"
	else:
		return "★★☆ (Normal)"
