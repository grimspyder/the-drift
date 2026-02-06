## EquipmentDatabase - Central registry for equipment in The Drift
## Handles weapon and armor definitions

class_name EquipmentDatabase
extends Node

## All registered equipment
var _equipment: Dictionary = {}

## Weapon templates
var _weapon_templates: Dictionary = {}

## Armor templates
var _armor_templates: Dictionary = {}

## RNG for random selection
var _rng: RandomNumberGenerator


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_register_all_equipment()


func _register_all_equipment() -> void:
	# Register weapon templates
	_register_weapon_templates()
	
	# Register armor templates
	_register_armor_templates()
	
	print("EquipmentDatabase: Registered ", _equipment.size(), " equipment types")


func _register_weapon_templates() -> void:
	# Melee weapons
	_weapon_templates["sword"] = {
		"name": "Sword",
		"base_damage": 15.0,
		"attack_speed": 1.0,
		"crit_bonus": 0.02,
		"weapon_type": "melee"
	}
	
	_weapon_templates["dagger"] = {
		"name": "Dagger",
		"base_damage": 10.0,
		"attack_speed": 1.5,
		"crit_bonus": 0.05,
		"weapon_type": "melee"
	}
	
	_weapon_templates["dual_daggers"] = {
		"name": "Dual Daggers",
		"base_damage": 8.0,
		"attack_speed": 1.8,
		"crit_bonus": 0.04,
		"weapon_type": "melee"
	}
	
	_weapon_templates["mace"] = {
		"name": "Mace",
		"base_damage": 18.0,
		"attack_speed": 0.7,
		"crit_bonus": 0.0,
		"weapon_type": "melee"
	}
	
	_weapon_templates["scythe"] = {
		"name": "Scythe",
		"base_damage": 20.0,
		"attack_speed": 0.6,
		"crit_bonus": 0.03,
		"weapon_type": "melee"
	}
	
	# Ranged weapons
	_weapon_templates["bow"] = {
		"name": "Bow",
		"base_damage": 12.0,
		"attack_speed": 1.2,
		"crit_bonus": 0.03,
		"weapon_type": "ranged"
	}
	
	_weapon_templates["staff"] = {
		"name": "Staff",
		"base_damage": 14.0,
		"attack_speed": 0.9,
		"crit_bonus": 0.04,
		"weapon_type": "magic"
	}
	
	_weapon_templates["wand"] = {
		"name": "Wand",
		"base_damage": 8.0,
		"attack_speed": 2.0,
		"crit_bonus": 0.02,
		"weapon_type": "magic"
	}


func _register_armor_templates() -> void:
	_armor_templates["cloth"] = {
		"name": "Cloth Robes",
		"base_defense": 2.0,
		"speed_modifier": 1.0,
		"health_bonus": 0.0
	}
	
	_armor_templates["leather"] = {
		"name": "Leather Armor",
		"base_defense": 5.0,
		"speed_modifier": 0.95,
		"health_bonus": 10.0
	}
	
	_armor_templates["mail"] = {
		"name": "Chain Mail",
		"base_defense": 10.0,
		"speed_modifier": 0.85,
		"health_bonus": 25.0
	}
	
	_armor_templates["plate"] = {
		"name": "Plate Armor",
		"base_defense": 18.0,
		"speed_modifier": 0.7,
		"health_bonus": 50.0
	}
	
	_armor_templates["robe"] = {
		"name": "Magic Robes",
		"base_defense": 4.0,
		"speed_modifier": 1.0,
		"health_bonus": 5.0,
		"magic_bonus": 0.2
	}


func create_weapon(template_id: String, tier: int = 0) -> Equipment:
	if not _weapon_templates.has(template_id):
		template_id = "sword"
	
	var template = _weapon_templates[template_id]
	var equip = Equipment.new()
	equip.equipment_id = template_id + "_" + str(tier)
	equip.display_name = template["name"]
	equip.slot = Equipment.Slot.WEAPON
	equip.material_tier = tier
	equip.base_damage = template["base_damage"]
	equip.attack_speed = template["attack_speed"]
	equip.crit_bonus = template.get("crit_bonus", 0.0)
	equip.special_effects = []
	equip.material_name = _get_tier_name(tier)
	equip.tint_color = Equipment.get_tier_color(tier)
	
	# Add random special effect based on tier
	if tier >= 2:
		equip.special_effects.append(equip.get_random_special_effect(_rng))
	if tier >= 4:
		equip.special_effects.append(equip.get_random_special_effect(_rng))
	
	return equip


func create_armor(template_id: String, tier: int = 0) -> Equipment:
	if not _armor_templates.has(template_id):
		template_id = "leather"
	
	var template = _armor_templates[template_id]
	var equip = Equipment.new()
	equip.equipment_id = template_id + "_" + str(tier)
	equip.display_name = template["name"]
	equip.slot = Equipment.Slot.ARMOR
	equip.material_tier = tier
	equip.base_defense = template["base_defense"]
	equip.speed_modifier = template.get("speed_modifier", 1.0)
	equip.health_bonus = template.get("health_bonus", 0.0)
	equip.special_effects = []
	equip.material_name = _get_tier_name(tier)
	equip.tint_color = Equipment.get_tier_color(tier)
	
	# Add random special effect based on tier
	if tier >= 3:
		equip.special_effects.append(equip.get_random_special_effect(_rng))
	
	return equip


func get_random_weapon(tier_range: Vector2i = Vector2i(0, 3)) -> Equipment:
	var templates = _weapon_templates.keys()
	var template_id = templates.pick_random()
	var tier = _rng.randi_range(tier_range.x, tier_range.y)
	return create_weapon(template_id, tier)


func get_random_armor(tier_range: Vector2i = Vector2i(0, 3)) -> Equipment:
	var templates = _armor_templates.keys()
	var template_id = templates.pick_random()
	var tier = _rng.randi_range(tier_range.x, tier_range.y)
	return create_armor(template_id, tier)


func get_upgraded_equipment(equip: Equipment) -> Equipment:
	var new_tier = min(equip.material_tier + 1, 6)
	if equip.slot == Equipment.Slot.WEAPON:
		return create_weapon(equip.equipment_id.get_slice("_", 0), new_tier)
	else:
		return create_armor(equip.equipment_id.get_slice("_", 0), new_tier)


func _get_tier_name(tier: int) -> String:
	var tier_names = ["Wood", "Copper", "Iron", "Steel", "Mithril", "Adamantite", "Dragon"]
	if tier < tier_names.size():
		return tier_names[tier]
	return "Legendary"


func get_tier_name(tier: int) -> String:
	return _get_tier_name(tier)


func get_equipment_for_class(class_id: String, tier: int = 0) -> Dictionary:
	# Get equipment based on class
	var class_db = load("res://src/Utils/ClassDatabase.gd").new()
	var class_def = class_db.get_class(class_id)
	
	var weapon = create_weapon(class_def.starting_weapon, tier)
	var armor = create_armor(class_def.starting_armor, tier)
	
	return {
		"weapon": weapon,
		"armor": armor
	}


func get_all_templates() -> Dictionary:
	return {
		"weapons": _weapon_templates.duplicate(),
		"armors": _armor_templates.duplicate()
	}
