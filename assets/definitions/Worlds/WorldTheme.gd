## World Theme Definition for The Drift
## Defines the visual and gameplay properties of each world

class_name WorldTheme
extends Resource

## Theme ID (0=Prime, 1=Verdant, 2=Arid, 3=Crystalline, 4=Ashen)
@export var theme_id: int = 0

## Display name of the theme
@export var display_name: String = "Prime World"

## Theme description
@export_multiline var description: String = ""

## Floor tile color
@export var floor_color: Color = Color(0.45, 0.4, 0.35)

## Wall tile color
@export var wall_color: Color = Color(0.25, 0.22, 0.2)

## Ambient light color
@export var ambient_light_color: Color = Color(0.6, 0.6, 0.6)

## Ambient light energy
@export var ambient_light_energy: float = 0.7

## Fog color (for atmosphere)
@export var fog_color: Color = Color(0.5, 0.5, 0.5)

## Fog density (0.0 to 1.0)
@export var fog_density: float = 0.02

## Enemy spawn rate multiplier
@export var enemy_spawn_rate_mod: float = 1.0

## Enemy health modifier
@export var enemy_health_mod: float = 1.0

## Enemy damage modifier
@export var enemy_damage_mod: float = 1.0

## Special enemy types that spawn in this world
@export var special_enemies: Array = []

## Resource spawn rate modifier
@export var resource_spawn_mod: float = 1.0

## Hazard types present in this world
@export var hazards: Array = []

## Music/ambience type
@export var audio_theme: String = "default"

## Background color (for void areas)
@export var background_color: Color = Color(0.1, 0.1, 0.1)

## Particle effects type
@export var particle_effects: String = "none"

## Visual overlay (e.g., "rain", "embers", "sparkles")
@export var visual_overlay: String = "none"

## Is this an "easy" world?
@export var is_easy_mode: bool = false

## Is this a "hard" world?
@export var is_hard_mode: bool = false

## Map width for this world (overrides default)
@export var map_width: int = 80

## Map height for this world (overrides default)
@export var map_height: int = 45

## Minimum room size for this world
@export var min_room_size: int = 6

## Maximum room size for this world
@export var max_room_size: int = 10

## Target room count for this world
@export var target_room_count: int = 30

## Get a formatted difficulty description
func get_difficulty_description() -> String:
	if is_easy_mode:
		return "EASIER - Recommended for beginners"
	elif is_hard_mode:
		return "HARDER - Experienced drifters only"
	else:
		return "STANDARD - Balanced challenge"


## Get enemy spawn rate for this world
func get_enemy_spawn_rate(base_rate: float) -> float:
	return base_rate * enemy_spawn_rate_mod


## Get enemy health for this world
func get_enemy_health(base_health: float) -> float:
	return base_health * enemy_health_mod


## Get enemy damage for this world
func get_enemy_damage(base_damage: float) -> float:
	return base_damage * enemy_damage_mod


## Get resource spawn rate for this world
func get_resource_spawn_rate(base_rate: float) -> float:
	return base_rate * resource_spawn_mod


## Apply theme colors to a TileMap
func apply_to_tilemap(tile_map: TileMap) -> void:
	# Note: This is a placeholder - actual implementation would
	# need to use TileSet's modulation system
	if tile_map:
		tile_map.modulate = floor_color
