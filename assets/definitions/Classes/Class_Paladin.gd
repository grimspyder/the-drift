## Paladin Class - High HP, healing abilities
class_name Class_Paladin
extends DrifterClass

func _init() -> void:
	display_name = "Paladin"
	class_id = "paladin"
	hp_modifier = 1.4
	speed_modifier = 0.7
	damage_modifier = 1.0
	attack_speed_modifier = 0.7
	crit_chance = 0.05
	defense_modifier = 1.5
	starting_weapon = "mace"
	starting_armor = "plate"
	class_color = Color(0.9, 0.8, 0.3)
	primary_attribute = "health"
	secondary_attribute = "defense"
	ability_name = "Divine Heal"
	ability_description = "Restore health to yourself or nearby allies"
	description = "Devoted guardians blessed with divine light. Paladins can withstand tremendous punishment and heal themselves in battle."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.defense_modifier = rng.randf_range(1.4, 1.6)
	copy.hp_modifier = rng.randf_range(1.3, 1.5)
	return copy
