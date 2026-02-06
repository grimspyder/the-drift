extends CharacterBody2D

## Player movement speed (pixels per second)
@export var speed: float = 300.0

## Movement acceleration
@export var acceleration: float = 1500.0

## Movement friction (higher = quicker stop)
@export var friction: float = 1200.0

## Projectile scene to spawn when shooting
@export var projectile_scene: PackedScene

## Fire rate (shots per second)
@export var fire_rate: float = 5.0

## Player health (for combat)
@export var max_health: float = 100.0

## Player sprite component
var sprite: Sprite2D

## Player collision shape
var collision_shape: CollisionShape2D

## Camera following player
var camera: Camera2D

## Time until next shot allowed
var shoot_cooldown: float = 0.0

## Whether player is aiming at mouse
var facing_direction: Vector2 = Vector2.RIGHT

## Health component
var health: Health

## Player death signal (for GameManager to handle drift)
signal player_died

## -------------------------------------------------------------------------
## CLASS AND EQUIPMENT SYSTEM
## -------------------------------------------------------------------------

## Current player class
var current_class: DrifterClass

## Current weapon
var weapon: Equipment

## Current armor
var armor: Equipment

## Equipment database reference
var equipment_db: EquipmentDatabase

## Whether player has mutated (for drift effect)
var has_mutated: bool = false


func _ready() -> void:
	# Add to player group for easy detection
	add_to_group("player")
	
	# Initialize equipment database
	equipment_db = EquipmentDatabase.new()
	add_child(equipment_db)
	
	# Create health component
	health = Health.new()
	health.max_health = max_health
	health.current_health = max_health
	health.name = "Health"
	add_child(health)
	
	# Connect health signals
	health.died.connect(_on_died)
	
	# Create placeholder sprite if not using external texture
	if sprite == null:
		sprite = Sprite2D.new()
		var placeholder_texture = _create_placeholder_texture()
		sprite.texture = placeholder_texture
		sprite.scale = Vector2(0.5, 0.5)  # 32x32 equivalent
		sprite.position = Vector2.ZERO
		add_child(sprite)

	# Create collision shape if not using external
	if collision_shape == null:
		collision_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(32, 32)  # Match sprite size
		collision_shape.shape = shape
		collision_shape.position = Vector2.ZERO
		add_child(collision_shape)
	
	# Set up physics layers
	# Layer 1: Player, Layer 2: Walls
	collision_layer = 1  # Player is on layer 1
	collision_mask = 2   # Player collides with walls on layer 2

	# Create and setup camera
	camera = Camera2D.new()
	camera.position = Vector2.ZERO
	camera.enabled = true
	add_child(camera)

	# Load projectile scene if not assigned
	if projectile_scene == null:
		projectile_scene = load("res://src/Entities/Projectile.tscn")
	
	# Initialize starting class and equipment
	_initialize_class_and_equipment()


func _initialize_class_and_equipment() -> void:
	"""Initialize player with starting class and equipment"""
	var class_db = ClassDatabase.new()
	add_child(class_db)
	
	# Start with Warrior class
	current_class = class_db.get_class("warrior")
	if current_class:
		_apply_class_stats()
	
	# Get starting equipment
	var equip_data = equipment_db.get_equipment_for_class(current_class.class_id, 0)
	weapon = equip_data["weapon"]
	armor = equip_data["armor"]
	
	print("Player initialized as: ", current_class.display_name)
	print("Weapon: ", weapon.get_full_name())
	print("Armor: ", armor.get_full_name())


func _create_placeholder_texture() -> Texture2D:
	# Create a simple colored square texture
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.6, 0.9))  # Blue color
	# Add a simple border
	for x in range(64):
		for y in range(64):
			if x < 4 or x >= 60 or y < 4 or y >= 60:
				image.set_pixel(x, y, Color(0.1, 0.4, 0.7))
	return ImageTexture.create_from_image(image)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_aiming()
	_handle_shooting(delta)

	# Apply movement
	move_and_slide()


func _handle_movement(delta: float) -> void:
	# Get input direction
	var input_direction = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1

	# Normalize input
	input_direction = input_direction.normalized()

	# Apply speed modifier from class and armor
	var effective_speed = speed
	if current_class:
		effective_speed = current_class.get_effective_speed(effective_speed)
	if armor:
		effective_speed *= armor.speed_modifier
	
	if input_direction.length() > 0:
		# Accelerate toward target velocity
		var target_velocity = input_direction * effective_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _handle_aiming() -> void:
	# Look at mouse position
	var mouse_position = get_global_mouse_position()
	facing_direction = (mouse_position - global_position).normalized()

	# Rotate sprite to face mouse
	if facing_direction.length() > 0:
		rotation = facing_direction.angle()


func _handle_shooting(delta: float) -> void:
	# Update cooldown
	if shoot_cooldown > 0:
		shoot_cooldown -= delta

	# Get effective attack speed
	var effective_fire_rate = fire_rate
	if current_class:
		effective_fire_rate *= current_class.attack_speed_modifier
	if weapon:
		effective_fire_rate *= weapon.attack_speed
	
	# Check for shoot input
	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0:
		shoot()
		shoot_cooldown = 1.0 / effective_fire_rate


func shoot() -> void:
	if projectile_scene == null:
		return

	# Spawn projectile
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)

	# Position projectile at player position (slightly offset in facing direction)
	projectile.global_position = global_position + (facing_direction * 20)

	# Set projectile direction
	projectile.set_direction(facing_direction)
	
	# Apply damage from weapon
	if weapon:
		projectile.damage = weapon.get_damage()
	
	# Apply crit from class
	if current_class and randf() < current_class.crit_chance:
		projectile.is_crit = true
		projectile.damage *= current_class.crit_multiplier


func take_damage(amount: float) -> void:
	# Apply armor defense
	var effective_damage = amount
	if armor:
		effective_damage = max(1.0, effective_damage - armor.get_defense())
	
	if health:
		health.take_damage(effective_damage)


func heal(amount: float) -> void:
	# Public method for healing
	if health:
		health.heal(amount)


func _on_died() -> void:
	# Emit death signal for GameManager to handle
	player_died.emit()
	
	# Visual feedback - turn gray
	if sprite:
		sprite.modulate = Color(0.3, 0.3, 0.3)
	
	# Disable collision
	collision_layer = 0
	collision_mask = 0
	
	print("Player died! Waiting for drift...")


func _get_input_direction() -> Vector2:
	"""Get normalized input direction from keyboard"""
	var direction = Vector2.ZERO

	direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))

	return direction.normalized()


func get_health() -> Health:
	return health


func reset_player() -> void:
	# Reset health on respawn
	if health:
		health.reset_health()
	
	# Re-enable collision
	collision_layer = 1
	collision_mask = 2
	
	# Reset sprite color
	if sprite:
		sprite.modulate = Color.WHITE


## -------------------------------------------------------------------------
## CLASS MUTATION SYSTEM (for drift)
## -------------------------------------------------------------------------

func mutate_on_drift(new_class_id: String, new_weapon_tier: int, new_armor_tier: int) -> void:
	"""Mutate player to a new class and equipment tier after drifting"""
	
	var class_db = ClassDatabase.new()
	
	# Get new class
	var old_class_name = current_class.display_name if current_class else "Unknown"
	current_class = class_db.get_class(new_class_id)
	
	if not current_class:
		current_class = class_db.get_random_class()
	
	# Apply class stats
	_apply_class_stats()
	
	# Upgrade equipment
	if weapon:
		weapon = equipment_db.create_weapon(weapon.equipment_id.get_slice("_", 0), new_weapon_tier)
	if armor:
		armor = equipment_db.create_armor(armor.equipment_id.get_slice("_", 0), new_armor_tier)
	
	# Visual mutation
	_apply_visual_mutation()
	
	has_mutated = true
	
	print("Player mutated!")
	print("Old class: ", old_class_name, " -> New class: ", current_class.display_name)
	print("New weapon: ", weapon.get_full_name())
	print("New armor: ", armor.get_full_name())


func mutate_random(exclude_class: String = "") -> void:
	"""Mutate player to a random new class"""
	var class_db = ClassDatabase.new()
	var new_class = class_db.get_random_class_exclude([exclude_class])
	
	if new_class:
		# Calculate new equipment tier (increases with drift count)
		var gm = load("res://src/Entities/GameManager.gd").new()
		var tier = gm.drift_count if gm else 0
		tier = mini(tier, 5)  # Cap at tier 5
		
		mutate_on_drift(new_class.class_id, tier, tier)


func _apply_class_stats() -> void:
	"""Apply current class modifiers to player stats"""
	if not current_class or not health:
		return
	
	# Apply health modifier
	var new_max_health = max_health * current_class.hp_modifier
	health.max_health = new_max_health
	health.current_health = new_max_health
	
	# Apply armor health bonus
	if armor:
		health.max_health += armor.health_bonus
		health.current_health += armor.health_bonus


func _apply_visual_mutation() -> void:
	"""Apply visual changes based on new class"""
	if not sprite or not current_class:
		return
	
	# Tint sprite with class color
	sprite.modulate = current_class.class_color
	
	# Reset after a moment for transition effect
	await get_tree().create_timer(0.5).timeout
	if sprite:
		sprite.modulate = Color.WHITE


func get_player_stats() -> Dictionary:
	"""Return player stats for UI display"""
	var stats = {
		"class": current_class.display_name if current_class else "Unknown",
		"health": health.current_health if health else 0,
		"max_health": health.max_health if health else 0,
		"weapon": weapon.get_full_name() if weapon else "Unarmed",
		"weapon_damage": weapon.get_damage() if weapon else 0,
		"armor": armor.get_full_name() if armor else "No Armor",
		"armor_defense": armor.get_defense() if armor else 0,
		"speed": speed * (current_class.speed_modifier if current_class else 1.0),
		"crit_chance": current_class.crit_chance * 100 if current_class else 0,
		"crit_damage": current_class.crit_multiplier * 100 if current_class else 0,
	}
	return stats


func get_effective_damage() -> float:
	"""Calculate effective damage including class and weapon modifiers"""
	var base_damage = weapon.get_damage() if weapon else 10.0
	if current_class:
		base_damage = current_class.get_effective_damage(base_damage)
	return base_damage


func get_effective_defense() -> float:
	"""Calculate effective defense including class and armor modifiers"""
	var base_defense = armor.get_defense() if armor else 0.0
	if current_class:
		base_defense *= current_class.defense_modifier
	return base_defense
