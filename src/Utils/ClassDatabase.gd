## ClassDatabase - Central registry for all available classes in The Drift
## Can be used as a singleton/autoload for easy access

class_name ClassDatabase
extends Node

## All available classes
var _classes: Dictionary = {}

## RNG for random selection
var _rng: RandomNumberGenerator


func _init() -> void:
	_rng = RandomNumberGenerator.new()
	_register_all_classes()


func _register_all_classes() -> void:
	# Register all 8 classes
	register_class(Class_Warrior.new())
	register_class(Class_Wizard.new())
	register_class(Class_Gatherer.new())
	register_class(Class_Hunter.new())
	register_class(Class_Paladin.new())
	register_class(Class_Cleric.new())
	register_class(Class_Rogue.new())
	register_class(Class_Assassin.new())
	
	print("ClassDatabase: Registered ", _classes.size(), " classes")


func register_class(class_def: DrifterClass) -> void:
	_classes[class_def.class_id] = class_def


func get_drifter_class(class_id: String) -> DrifterClass:
	if _classes.has(class_id):
		return _classes[class_id].duplicate()
	return null


func get_all_classes() -> Array:
	return _classes.values()


func get_random_class() -> DrifterClass:
	var class_ids = _classes.keys()
	var random_id = class_ids.pick_random()
	return get_drifter_class(random_id)


func get_random_class_exclude(exclude_ids: Array[String]) -> DrifterClass:
	var available = []
	for class_id in _classes.keys():
		if not class_id in exclude_ids:
			available.append(class_id)
	
	if available.is_empty():
		return get_random_class()
	
	var random_id = available.pick_random()
	return get_drifter_class(random_id)


func get_class_count() -> int:
	return _classes.size()


func get_classes_by_attribute(attribute: String) -> Array:
	var result = []
	for class_def in _classes.values():
		if class_def.primary_attribute == attribute or class_def.secondary_attribute == attribute:
			result.append(class_def)
	return result


func get_melee_classes() -> Array:
	return get_classes_by_attribute("damage")


func get_ranged_classes() -> Array:
	var result = []
	for class_def in _classes.values():
		if class_def.starting_weapon in ["bow", "staff"]:
			result.append(class_def)
	return result


func get_tank_classes() -> Array:
	return get_classes_by_attribute("health")


func get_support_classes() -> Array:
	return get_classes_by_attribute("support")


func get_random_variant(class_id: String) -> DrifterClass:
	var base_class = get_drifter_class(class_id)
	if base_class:
		return base_class.duplicate_randomized(_rng)
	return get_random_class()
