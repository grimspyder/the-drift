## Equipment Definition for The Drift
## Represents a piece of equipment (weapon or armor)

class_name Equipment
extends Resource

## Equipment slot type
enum Slot {WEAPON, ARMOR, ACCESSORY}

## Equipment ID
@export var equipment_id: String = "wooden_sword"

## Display name
@export var display_name: String = "Wooden Sword"

## Equipment slot
@export var slot: Slot = Slot.WEAPON

## Material tier (0=wood, 1=copper, 2=iron, 3=steel, 4=mithril, 5=adamantite)
@export var material_tier: int = 0

## Base damage (for weapons)
@export var base_damage: float = 10.0

## Base defense (for armor)
@export var base_defense: float = 5.0

## Attack speed (weapons only, shots per second)
@export var attack_speed: float = 1.0

## Critical hit chance bonus
@export var crit_bonus: float = 0.0

## Critical hit damage bonus
@export var crit_damage_bonus: float = 0.0

## Speed modifier
@export var speed_modifier: float = 1.0

## Health bonus
@export var health_bonus: float = 0.0

## Special effects (list of effect IDs)
@export var special_effects: Array = []

## Visual color tint for this equipment
@export var tint_color: Color = Color.WHITE

## Equipment description
@export_multiline var description: String = ""

## Required class to use this equipment (empty = all classes)
@export var required_class: String = ""

## Material name for display
@export var material_name: String = "Wood"

## Get the tier name
func get_tier_name() -> String:
	var tier_names = ["Wood", "Copper", "Iron", "Steel", "Mithril", "Adamantite", "Dragon"]
	if material_tier < tier_names.size():
		return tier_names[material_tier]
	return "Legendary"


## Get the full display name (e.g., "Copper Sword")
func get_full_name() -> String:
	return get_tier_name() + " " + display_name


## Get the damage output
func get_damage() -> float:
	return base_damage * (1.0 + material_tier * 0.25)


## Get the defense value
func get_defense() -> float:
	return base_defense * (1.0 + material_tier * 0.25)


## Check if this equipment is better than another
func is_better_than(other: Equipment) -> bool:
	if slot != other.slot:
		return false
	
	if slot == Slot.WEAPON:
		return get_damage() > other.get_damage()
	else:
		return get_defense() > other.get_defense()


## Create a copy with increased tier
func increase_tier() -> Equipment:
	var copy = duplicate()
	copy.material_tier = min(copy.material_tier + 1, 6)
	return copy


## Get random special effect
func get_random_special_effect(rng: RandomNumberGenerator) -> String:
	var effects = ["vampiric", "freezing", "burning", "shocking", "poisoned", "blessed", "cursed"]
	return effects.pick_random()


## Material tier colors
static func get_tier_color(tier: int) -> Color:
	var colors = [
		Color(0.55, 0.35, 0.2), # Wood - brown
		Color(0.72, 0.45, 0.2), # Copper - copper/orange
		Color(0.75, 0.75, 0.78), # Iron - gray
		Color(0.55, 0.55, 0.6), # Steel - blue-gray
		Color(0.3, 0.6, 0.8), # Mithril - light blue
		Color(0.6, 0.5, 0.8), # Adamantite - purple
		Color(0.9, 0.3, 0.1), # Dragon - red-orange
	]
	if tier < colors.size():
		return colors[tier]
	return Color.GOLD
