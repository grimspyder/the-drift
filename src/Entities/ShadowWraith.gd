extends Enemy

## ShadowWraith - Ethereal enemy from the Shadow Realm
## High damage, moderate health, phases through obstacles

@export var max_health_base: float = 80.0

func _init() -> void:
	speed = 180.0
	detection_range = 600.0 # Can detect player from further away
	damage_to_player = 20.0 # High damage

func _ready() -> void:
	# Call parent _ready first (which handles difficulty scaling)
	super._ready()


func _apply_difficulty_scaling() -> void:
	"""Override difficulty scaling for ShadowWraith stats"""
	var multiplier = _get_difficulty_multiplier()
	
	# Scale max health
	health.max_health = max_health_base * multiplier
	health.current_health = health.max_health
	
	# Scale damage to player
	var base_damage = 20.0
	damage_to_player = base_damage * multiplier


func _create_enemy_texture() -> Texture2D:
	# Create a ghostly purple wraith texture
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0)) # Transparent base
	
	# Draw ghostly wraith shape
	for x in range(64):
		for y in range(64):
			var dist = Vector2(x - 32, y - 32).length()
			# Wraith body (ghostly shape)
			if dist < 28 and y > 10:
				var alpha = 1.0 - (dist / 28.0)
				alpha *= (float(y) / 64.0) # Fade towards bottom
				image.set_pixel(x, y, Color(0.4, 0.2, 0.6, alpha))
			# Glowing eyes
			if abs(x - 24) < 4 and abs(y - 24) < 3:
				image.set_pixel(x, y, Color(1, 0.3, 0.5, 1))
			if abs(x - 40) < 4 and abs(y - 24) < 3:
				image.set_pixel(x, y, Color(1, 0.3, 0.5, 1))
	
	return ImageTexture.create_from_image(image)
