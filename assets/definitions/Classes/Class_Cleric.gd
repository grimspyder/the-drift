## Cleric Class - Medium stats, support abilities
class_name Class_Cleric
extends DrifterClass

func _init() -> void:
	display_name = "Cleric"
	class_id = "cleric"
	hp_modifier = 1.0
	speed_modifier = 0.9
	damage_modifier = 0.85
	attack_speed_modifier = 0.9
	crit_chance = 0.08
	defense_modifier = 1.0
	resource_bonus = 0.2
	starting_weapon = "staff"
	starting_armor = "cloth"
	class_color = Color(0.9, 0.9, 0.7)
	primary_attribute = "support"
	secondary_attribute = "health"
	ability_name = "Blessing"
	ability_description = "Grant a buff to nearby allies"
	description = "Devoted healers who balance offense with support. Clerics can empower their allies while still holding their own in combat."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.resource_bonus = rng.randf_range(0.15, 0.3)
	copy.defense_modifier = rng.randf_range(0.9, 1.1)
	return copy
