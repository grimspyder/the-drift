extends Area2D

## ExitStairs - Exit point for completing a dungeon
## Triggered when player touches the stairs, leading to a win condition

## Signal emitted when stairs are triggered
signal stairs_entered

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


func _ready() -> void:
	# Add to exit_stairs group for system queries
	add_to_group("exit_stairs")
	
	# Set up collision
	_setup_collision()
	
	# Create visual representation
	_create_visuals()
	
	# Connect area entered signal
	area_entered.connect(_on_area_entered)
	
	print("ExitStairs: Created and ready")


func _setup_collision() -> void:
	# Create circular collision shape for detection
	collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 24  # Slightly smaller than tile size
	collision_shape.shape = shape
	add_child(collision_shape)


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
	animation_player.add_animation("pulse", pulse_anim)
	animation_player.play("pulse")
	add_child(animation_player)
	
	# Create glowing particles
	_create_particles()


func _create_stairs_texture() -> Texture2D:
	"""Create a procedural texture for stairs/portal"""
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Transparent background
	
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
	var track_index = animation.add_track(Animation.TYPE_PROPERTY)
	animation.track_set_path(track_index, ".:scale")
	
	# Keyframes: small -> large -> small
	animation.track_insert_key(track_index, 0.0, Vector2(0.7, 0.7))
	animation.track_insert_key(track_index, 0.75, Vector2(0.9, 0.9))
	animation.track_insert_key(track_index, 1.5, Vector2(0.7, 0.7))
	
	# Track for modulate color
	var color_track = animation.add_track(Animation.TYPE_PROPERTY)
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
	particles.emission_shape = GPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 16
	
	# Particle material
	var material = ParticleMaterial.new()
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
	var pass_tex = StandardMaterial2D.new()
	pass_tex.albedo_texture = particle_tex
	pass_tex.blend_mode = StandardMaterial2D.BLEND_ADD
	pass_tex.emission_enabled = true
	pass_tex.emission = Color(0.5, 0.8, 1.0)
	pass_tex.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pass_tex.albedo_color = Color(0.5, 0.8, 1.0, 0.6)
	particles.draw_pass_1 = pass_tex
	
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


func _on_area_entered(area: Area2D) -> void:
	"""Handle area entry - check if it's the player"""
	if not active:
		return
	
	# Check if the entering area is the player
	if area.is_in_group("player") or area.has_method("is_player"):
		_trigger_stairs()


func _trigger_stairs() -> void:
	"""Trigger the stairs effect and emit signal"""
	if not active:
		return
	
	active = false
	stairs_entered.emit()
	
	print("ExitStairs: Player reached exit!")
	
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


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	# Check if sprite is valid
	if not sprite or not sprite.texture:
		warnings.append("No sprite texture - using placeholder")
	
	return warnings
