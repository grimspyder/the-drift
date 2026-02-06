## Hunter Class - Medium stats, speed + ranged
class_name Class_Hunter
extends DrifterClass

func _init() -> void:
	display_name = "Hunter"
	class_id = "hunter"
	hp_modifier = 0.9
	speed_modifier = 1.3
	damage_modifier = 1.1
	attack_speed_modifier = 1.1
	crit_chance = 0.1
	defense_modifier = 0.85
	starting_weapon = "bow"
	starting_armor = "leather"
	class_color = Color(0.4, 0.6, 0.2)
	primary_attribute = "speed"
	secondary_attribute = "damage"
	ability_name = "Quick Shot"
	ability_description = "Fire a rapid shot that deals bonus damageTracks"
	description = " who rely on speed and precision. Hunters can outs maneuver most enemies while delivering precise strikes from range."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.speed_modifier = rng.randf_range(1.2, 1.4)
	return copy
