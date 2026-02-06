## Rogue Class - Low HP, high speed, crit focus
class_name Class_Rogue
extends DrifterClass

func _init() -> void:
	display_name = "Rogue"
	class_id = "rogue"
	hp_modifier = 0.7
	speed_modifier = 1.5
	damage_modifier = 1.2
	attack_speed_modifier = 1.3
	crit_chance = 0.15
	crit_multiplier = 2.2
	defense_modifier = 0.75
	starting_weapon = "dagger"
	starting_armor = "leather"
	class_color = Color(0.4, 0.4, 0.4)
	primary_attribute = "speed"
	secondary_attribute = "crit"
	ability_name = "Backstab"
	ability_description = "Deal critical damage from behind"
	description = "Shadowy operatives who strike from the darkness. Rogues sacrifice durability for incredible speed and deadly precision."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.crit_chance = rng.randf_range(0.12, 0.18)
	copy.speed_modifier = rng.randf_range(1.4, 1.6)
	return copy
