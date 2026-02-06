## Wizard Class - Low HP, ranged magic focused
class_name Class_Wizard
extends DrifterClass

func _init() -> void:
	display_name = "Wizard"
	class_id = "wizard"
	hp_modifier = 0.6
	speed_modifier = 0.8
	damage_modifier = 1.8
	attack_speed_modifier = 1.2
	crit_chance = 0.12
	defense_modifier = 0.7
	resource_bonus = 0.3
	starting_weapon = "staff"
	starting_armor = "robe"
	class_color = Color(0.2, 0.4, 0.9)
	primary_attribute = "damage"
	secondary_attribute = "crit"
	ability_name = "Magic Missile"
	ability_description = "Fire 3 magical projectiles at enemies"
	description = "Scholars of the arcane arts, Wizards channel raw magical energy to devastate foes from a distance. Fragile but devastating."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.resource_bonus = rng.randf_range(0.2, 0.4)
	return copy
