## Base Class Definition for The Drift
## Extends Resource to allow for easy instantiation and modification

class_name DrifterClass
extends Resource

## Display name of the class
@export var display_name: String = "Warrior"

## Class ID (unique identifier)
@export var class_id: String = "warrior"

## Base health modifier (multiplier)
@export var hp_modifier: float = 1.0

## Movement speed modifier (multiplier)
@export var speed_modifier: float = 1.0

## Damage modifier (multiplier)
@export var damage_modifier: float = 1.0

## Attack speed modifier (multiplier)
@export var attack_speed_modifier: float = 1.0

## Critical hit chance (0.0 to 1.0)
@export var crit_chance: float = 0.05

## Critical hit damage multiplier
@export var crit_multiplier: float = 2.0

## Defense modifier (multiplier)
@export var defense_modifier: float = 1.0

## Resource generation bonus (0.0 = none, 0.5 = +50%, etc.)
@export var resource_bonus: float = 0.0

## Special ability name (if any)
@export var ability_name: String = ""

## Ability description
@export_multiline var ability_description: String = ""

## Starting weapon type for this class
@export var starting_weapon: String = "sword"

## Starting armor type for this class
@export var starting_armor: String = "leather"

## Visual color for this class (for sprite tinting)
@export var class_color: Color = Color.WHITE

## Primary attribute (health, speed, damage, etc.)
@export var primary_attribute: String = "damage"

## Secondary attribute
@export var secondary_attribute: String = "speed"

## Description/lore for this class
@export_multiline var description: String = ""


func _init(p_name: String = "BaseClass", p_id: String = "base") -> void:
	display_name = p_name
	class_id = p_id


## Get a copy of this class with randomized variants
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = duplicate()
	# Apply small random variations
	copy.hp_modifier = max(0.5, copy.hp_modifier + rng.randf_range(-0.1, 0.1))
	copy.speed_modifier = max(0.5, copy.speed_modifier + rng.randf_range(-0.1, 0.1))
	copy.damage_modifier = max(0.5, copy.damage_modifier + rng.randf_range(-0.1, 0.1))
	return copy


## Get the effective damage for this class
func get_effective_damage(base_damage: float) -> float:
	return base_damage * damage_modifier


## Get the effective max health for this class
func get_effective_max_health(base_health: float) -> float:
	return base_health * hp_modifier


## Get the effective speed for this class
func get_effective_speed(base_speed: float) -> float:
	return base_speed * speed_modifier
