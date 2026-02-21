extends Area2D

## ExitStairs - Portal for advancing between levels
## Triggered when player touches, leads to next level or win condition

## Signal emitted when portal is triggered
signal stairs_entered

## Signal emitted when player advances to next level
signal portal_entered

## Visual sprite for the stairs
var sprite: Sprite2D

## Collision shape for detection
var collision_shape: CollisionShape2D

## Animation player for visual effects
var animation_player: AnimationPlayer

## Whether the stairs are active (can be triggered)
var active: bool = true

## Particles for visual effect
var particles: GPUParticles2D

## Current world ID (determines behavior)
var world_id: int = 0

## Maximum world count (for win condition)
var max_worlds: int = 6


func _ready() -> void:
	# Add to exit_stairs group for system queries
	add_to_group("exit_stairs")
	
	# Set up collision
	_setup_collision()
	
	# Create visual representation
	_create_visuals()
	
	# Connect body entered signal (for Player)
	body_entered.connect(_on_body_entered)
	
	print("ExitStairs: Created and ready")


func _setup_collision() -> void:
	# Create circular collision shape for detection
	collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 24 # Slightly smaller than tile size
	collision_shape.shape = shape
	add_child.call_deferred(collision_shape)


func _create_visuals() -> void:
	# Create sprite for the stairs
	sprite = Sprite2D.new()
	sprite.texture = _create_stairs_texture()
	sprite.scale = Vector2(0.8, 0.8)
	sprite.position = Vector2.ZERO
	add_child(sprite)
	
	# Create animation player for pulsing effect
	animation_player = AnimationPlayer.new()
	var pulse_anim = _create_pulse_animation()
	
	var anim_library = AnimationLibrary.new()
	anim_library.add_animation("pulse", pulse_anim)
	
	animation_player.add_animation_library("", anim_library)
	animation_player.play("pulse")
	add_child(animation_player)
	
	# Create glowing particles
	_create_particles()


func _create_stairs_texture() -> Texture2D:
	"""Create a procedural texture for stairs/portal"""
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0)) # Transparent background
	
	# Draw spiral/stairs pattern
	var center_x = 24
	var center_y = 24
	
	# Draw portal rings
	for i in range(5):
		var radius = 8 + i * 4
		var color = Color(0.2, 0.5, 1.0, 1.0 - (i * 0.15))
		_draw_circle(image, center_x, center_y, radius, color)
	
	# Draw center glow
	_draw_circle(image, center_x, center_y, 8, Color(0.5, 0.8, 1.0, 0.8))
	_draw_circle(image, center_x, center_y, 4, Color(0.8, 0.9, 1.0, 1.0))
	
	return ImageTexture.create_from_image(image)


func _draw_circle(image: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	"""Draw a filled circle on the image"""
	for x in range(cx - radius, cx + radius + 1):
		for y in range(cy - radius, cy + radius + 1):
			var dist = sqrt(pow(x - cx, 2) + pow(y - cy, 2))
			if dist <= radius and x >= 0 and x < 48 and y >= 0 and y < 48:
				image.set_pixel(x, y, color)


func _create_pulse_animation() -> Animation:
	"""Create a pulse animation for the stairs"""
	var animation = Animation.new()
	animation.length = 1.5
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Track for sprite scale
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:scale")
	
	# Keyframes: small -> large -> small
	animation.track_insert_key(track_index, 0.0, Vector2(0.7, 0.7))
	animation.track_insert_key(track_index, 0.75, Vector2(0.9, 0.9))
	animation.track_insert_key(track_index, 1.5, Vector2(0.7, 0.7))
	
	# Track for modulate color
	var color_track = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(color_track, ".:modulate")
	
	animation.track_insert_key(color_track, 0.0, Color(0.5, 0.7, 1.0))
	animation.track_insert_key(color_track, 0.75, Color(0.7, 0.9, 1.0))
	animation.track_insert_key(color_track, 1.5, Color(0.5, 0.7, 1.0))
	
	return animation


func _create_particles() -> void:
	"""Create particle effects for the stairs"""
	particles = GPUParticles2D.new()
	particles.amount = 20
	particles.lifetime = 1.0
	particles.position = Vector2.ZERO
	
	# Particle material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 16
	material.direction = Vector3(0, -1, 0)
	material.spread = 45
	material.initial_velocity_min = 20
	material.initial_velocity_max = 40
	material.gravity = Vector3(0, 0, 0)
	material.scale_min = 0.5
	material.scale_max = 1.0
	material.color = Color(0.4, 0.7, 1.0, 0.6)
	particles.process_material = material
	
	# Particle texture (simple dot)
	var particle_tex = _create_particle_texture()
	particles.texture = particle_tex
	
	add_child(particles)


func _create_particle_texture() -> Texture2D:
	"""Create a simple circular particle texture"""
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0))
	
	# Draw circle
	for x in range(8):
		for y in range(8):
			var dist = sqrt(pow(x - 3.5, 2) + pow(y - 3.5, 2))
			if dist <= 3.5:
				var alpha = 1.0 - (dist / 3.5)
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
	
	return ImageTexture.create_from_image(image)


func _on_body_entered(body: Node2D) -> void:
	"""Handle body entry - check if it's the player"""
	if not active:
		return
	
	# Check if the entering body is the player
	if body.is_in_group("player") or body.has_method("get_player_stats"):
		_trigger_stairs()


func _trigger_stairs() -> void:
	"""Trigger the stairs effect and emit signal"""
	if not active:
		return
	
	active = false
	
	# Check if this is the final world
	if world_id >= max_worlds - 1:
		# Final world - emit stairs_entered for win
		stairs_entered.emit()
		print("ExitStairs: Player reached final portal in world ", world_id)
	else:
		# Not final world - emit portal_entered to advance
		portal_entered.emit()
		print("ExitStairs: Player reached portal in world ", world_id)
	
	# Play trigger effect
	_play_trigger_effect()


func _play_trigger_effect() -> void:
	"""Play visual effect when stairs are triggered"""
	if animation_player:
		animation_player.stop()
	
	# Quick flash effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(_on_effect_complete)


func _on_effect_complete() -> void:
	"""Called when trigger effect completes"""
	print("ExitStairs: Trigger effect complete")


func set_active(value: bool) -> void:
	"""Set whether the stairs are active"""
	active = value
	if collision_shape:
		collision_shape.set_deferred("disabled", not active)


func is_active() -> bool:
	"""Check if stairs are active"""
	return active


func set_world_id(id: int) -> void:
	"""Set the world ID for this portal"""
	world_id = id
	# Update visuals based on world
	_update_portal_visuals()
	print("ExitStairs: World ID set to ", world_id)


func _update_portal_visuals() -> void:
	"""Update portal appearance based on world theme"""
	# Different colors for different worlds
	var portal_color: Color
	match world_id:
		0: portal_color = Color(0.2, 0.5, 1.0) # Blue - Prime
		1: portal_color = Color(0.2, 0.8, 0.4) # Green - Verdant
		2: portal_color = Color(0.9, 0.7, 0.3) # Yellow - Arid
		3: portal_color = Color(0.4, 0.5, 1.0) # Purple - Crystalline
		4: portal_color = Color(0.8, 0.3, 0.2) # Red - Ashen
		5: portal_color = Color(0.4, 0.2, 0.6) # Purple - Shadow
		_: portal_color = Color(0.2, 0.5, 1.0)
	
	# Update particle color
	if particles and particles.process_material:
		particles.process_material.color = portal_color


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	# Check if sprite is valid
	if not sprite or not sprite.texture:
		warnings.append("No sprite texture - using placeholder")
	
	return warnings
