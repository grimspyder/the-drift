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


func _ready() -> void:
	# Add to player group for easy detection
	add_to_group("player")
	
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

	if input_direction.length() > 0:
		# Accelerate toward target velocity
		var target_velocity = input_direction * speed
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

	# Check for shoot input
	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0:
		shoot()
		shoot_cooldown = 1.0 / fire_rate


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

	# Optional: Add visual feedback or sound here


func take_damage(amount: float) -> void:
	# Public method for enemies to call
	if health:
		health.take_damage(amount)


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
	
	# Respawn handled by GameManager via player_died signal
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
