## Health Component - Reusable health system for Player and Enemies
## Attach to any entity that needs health/damage handling

class_name Health
extends Node

signal died
signal health_changed(new_health: float, max_health: float)
signal damaged(amount: float, current_health: float)

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var invincibility_time: float = 0.0 # Time after taking damage before can take damage again

var _last_damage_time: float = -100.0 # Allow immediate first damage
var _is_dead: bool = false


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if _is_dead:
		return
	
	# Check invincibility
	if invincibility_time > 0:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - _last_damage_time < invincibility_time:
			return
	
	current_health -= amount
	_last_damage_time = Time.get_ticks_msec() / 1000.0
	
	# Emit signals
	damaged.emit(amount, current_health)
	health_changed.emit(current_health, max_health)
	
	# Check for death
	if current_health <= 0:
		current_health = 0
		_is_dead = true
		died.emit()


func heal(amount: float) -> void:
	if _is_dead:
		return
	
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return not _is_dead


func is_dead() -> bool:
	return _is_dead


func reset_health() -> void:
	_is_dead = false
	current_health = max_health
	health_changed.emit(current_health, max_health)


func get_health_ratio() -> float:
	if max_health > 0:
		return current_health / max_health
	return 0.0
