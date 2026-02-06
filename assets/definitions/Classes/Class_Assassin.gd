## Assassin Class - Very low HP, very high damage
class_name Class_Assassin
extends DrifterClass

func _init() -> void:
	display_name = "Assassin"
	class_id = "assassin"
	hp_modifier = 0.5
	speed_modifier = 1.4
	damage_modifier = 1.8
	attack_speed_modifier = 1.5
	crit_chance = 0.2
	crit_multiplier = 2.5
	defense_modifier = 0.6
	starting_weapon = "dual_daggers"
	starting_armor = "leather"
	class_color = Color(0.6, 0.1, 0.1)
	primary_attribute = "damage"
	secondary_attribute = "crit"
	ability_name = "Execution"
	ability_description = "Deal massive damage to low-health enemies"
	description = "Master killers who specialize in eliminating targets with ruthless efficiency. Assassins are extremely fragile but can destroy anything they touch."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.damage_modifier = rng.randf_range(1.6, 2.0)
	copy.crit_multiplier = rng.randf_range(2.3, 2.7)
	return copy
