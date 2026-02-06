extends CharacterBody2D

## Enemy - Basic enemy with chase AI
## Moves toward player when in range and deals damage on contact

## Movement speed (pixels per second)
@export var speed: float = 150.0

## Detection range - enemy starts chasing when player is within this distance
@export var detection_range: float = 400.0

## Attack range - distance to stop chasing and attack
@export var attack_range: float = 30.0

## Damage dealt to player on contact
@export var damage_to_player: float = 10.0

## Time between attacks
@export var attack_cooldown: float = 1.0

## Health component reference
var health: Health

## Player reference (for chasing)
var _player: CharacterBody2D

## Time until next attack allowed
var _attack_timer: float = 0.0

## Enemy sprite component
var sprite: Sprite2D

## Enemy collision shape
var collision_shape: CollisionShape2D

## Damage number label
var damage_label: Label

## Whether enemy is currently chasing
var _is_chasing: bool = false


func _ready() -> void:
	# Create health component if not present
	if not has_node("Health"):
		health = Health.new()
		health.name = "Health"
		add_child(health)
	else:
		health = get_node("Health")
	
	# Connect health signals
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	
	# Create placeholder sprite if not using external texture
	if sprite == null:
		sprite = Sprite2D.new()
		var placeholder_texture = _create_enemy_texture()
		sprite.texture = placeholder_texture
		sprite.scale = Vector2(0.5, 0.5)  # 32x32 equivalent
		sprite.position = Vector2.ZERO
		add_child(sprite)
	
	# Create collision shape if not using external
	if collision_shape == null:
		collision_shape = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 16  # Match sprite size
		collision_shape.shape = shape
		collision_shape.position = Vector2.ZERO
		add_child(collision_shape)
	
	# Set up physics layers
	# Layer 1: Player, Layer 2: Walls
	collision_layer = 8   # Enemy layer (layer 4)
	collision_mask = 3    # Collides with player (1) + walls (2)
	
	# Create damage label
	damage_label = Label.new()
	damage_label.name = "DamageLabel"
	damage_label.position = Vector2(0, -30)
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.modulate = Color(1, 0.3, 0.3)  # Red text
	add_child(damage_label)


func _create_enemy_texture() -> Texture2D:
	# Create a simple colored circle texture for enemy
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.9, 0.2, 0.2))  # Red color
	# Add a darker border
	for x in range(64):
		for y in range(64):
			var dist = Vector2(x - 32, y - 32).length()
			if dist > 30:
				image.set_pixel(x, y, Color(0.6, 0.1, 0.1))
			elif dist > 28:
				image.set_pixel(x, y, Color(0.8, 0.15, 0.15))
	return ImageTexture.create_from_image(image)


func _physics_process(delta: float) -> void:
	if not health.is_alive():
		return
	
	# Find player if not already found
	if _player == null:
		_player = _find_player()
	
	# Update attack timer
	if _attack_timer > 0:
		_attack_timer -= delta
	
	# Chase behavior
	if _player != null:
		var distance_to_player = global_position.distance_to(_player.global_position)
		
		if distance_to_player < detection_range:
			_is_chasing = true
		
		if _is_chasing and distance_to_player > attack_range:
			_move_toward_player(delta)
		elif _is_chasing and distance_to_player <= attack_range and _attack_timer <= 0:
			_attack_player()
	
	# Apply movement
	move_and_slide()


func _find_player() -> CharacterBody2D:
	# Look for player in parent scene
	var parent = get_parent()
	if parent.has_node("Player"):
		return parent.get_node("Player")
	# Also check with different naming patterns
	if parent.has_node("CharacterBody2D"):
		return parent.get_node("CharacterBody2D")
	# Try finding by group (more reliable)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as CharacterBody2D
	return null


func _move_toward_player(delta: float) -> void:
	if _player == null:
		return
	
	var direction = (_player.global_position - global_position).normalized()
	velocity = direction * speed
	
	# Rotate sprite to face player
	if direction.length() > 0:
		rotation = direction.angle()


func _attack_player() -> void:
	if _player == null or not _player.has_method("take_damage"):
		return
	
	# Deal damage to player
	_player.take_damage(damage_to_player)
	_attack_timer = attack_cooldown
	
	# Flash effect or visual feedback could go here


func _on_died() -> void:
	# Register enemy kill with GameManager
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("register_enemy_kill"):
		game_manager.register_enemy_kill()
	
	# Create death effect (particles could go here)
	# Hide sprite
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	# Disable collision
	collision_layer = 0
	collision_mask = 0
	
	# Despawn after short delay
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _on_damaged(amount: float, current_health: float) -> void:
	# Show damage number
	_show_damage_number(amount)
	
	# Flash white briefly
	if sprite:
		var original_modulate = sprite.modulate
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = original_modulate


func _show_damage_number(amount: float) -> void:
	if damage_label:
		damage_label.text = str(int(amount))
		var tween = create_tween()
		damage_label.position.y = -30
		damage_label.modulate.a = 1.0
		tween.tween_property(damage_label, "position:y", -50, 0.5)
		tween.tween_property(damage_label, "modulate:a", 0.0, 0.5)
