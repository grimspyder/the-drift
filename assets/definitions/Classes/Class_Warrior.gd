## Warrior Class - High HP, melee focused
class_name Class_Warrior
extends DrifterClass

func _init() -> void:
	display_name = "Warrior"
	class_id = "warrior"
	hp_modifier = 1.5
	speed_modifier = 0.9
	damage_modifier = 1.3
	attack_speed_modifier = 0.8
	crit_chance = 0.08
	defense_modifier = 1.3
	starting_weapon = "sword"
	starting_armor = "plate"
	class_color = Color(0.8, 0.2, 0.2)
	primary_attribute = "health"
	secondary_attribute = "defense"
	ability_name = "Power Strike"
	ability_description = "Deal 150% damage with your next attack"
	description = "Veterans of countless battles, Warriors excel in direct combat. Their heavy armor and powerful strikes make them the vanguard of any expedition."


## Get randomized variant
func duplicate_randomized(rng: RandomNumberGenerator) -> DrifterClass:
	var copy = super.duplicate_randomized(rng)
	copy.ability_name = "Power Strike"
	return copy
