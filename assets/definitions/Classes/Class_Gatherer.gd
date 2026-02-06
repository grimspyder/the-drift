## Gatherer Class - Medium stats, resource bonuses
class_name Class_Gatherer
extends DrifterClass

func _init() -> void:
	display_name = "Gatherer"
	class_id = "gatherer"
	hp_modifier = 1.0
	speed_modifier = 1.1
	damage_modifier = 0.9
	attack_speed_modifier = 1.0
	crit_chance = 0.06
	defense_modifier = 0.9
	resource_bonus = 0.5
	starting_weapon = "scythe"
	starting_armor = "leather"
	class_color = Color(0.3, 0.7, 0.3)
	primary_attribute = "resources"
	secondary_attribute = "speed"
	ability_name = "Scavenge"
	ability_description = "Find resources from surroundings"
	description = "Survivalists who know how to make the most of any environment. Gatherers excel at finding and managing resources during their drifts."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.resource_bonus = rng.randf_range(0.4, 0.6)
	copy.speed_modifier = rng.randf_range(1.0, 1.2)
	return copy
