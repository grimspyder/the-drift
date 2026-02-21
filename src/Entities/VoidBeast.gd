extends Enemy

## VoidBeast - Tanky enemy from the Shadow Realm
## High health, slower but hits hard

@export var max_health_base: float = 150.0

func _init() -> void:
	speed = 100.0 # Slower than regular enemies
	detection_range = 350.0
	damage_to_player = 25.0 # Very high damage

func _ready() -> void:
	# Call parent _ready first (which handles difficulty scaling)
	super._ready()


func _apply_difficulty_scaling() -> void:
	"""Override difficulty scaling for VoidBeast stats"""
	var multiplier = _get_difficulty_multiplier()
	
	# Scale max health (tanky!)
	health.max_health = max_health_base * multiplier
	health.current_health = health.max_health
	
	# Scale damage to player
	var base_damage = 25.0
	damage_to_player = base_damage * multiplier


func _create_enemy_texture() -> Texture2D:
	# Create a hulking void beast texture (dark purple/black)
	var image = Image.create(72, 72, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.1, 0.05, 0.15)) # Dark purple base
	
	# Draw void beast shape
	for x in range(72):
		for y in range(72):
			var dist = Vector2(x - 36, y - 36).length()
			# Beast body
			if dist < 32:
				var shade = 0.1 + (0.1 * (1.0 - dist / 32.0))
				image.set_pixel(x, y, Color(shade, 0.05, 0.15))
			# Glowing core
			if dist < 12:
				image.set_pixel(x, y, Color(0.6, 0.1, 0.8))
			# Eyes
			if abs(x - 26) < 5 and abs(y - 28) < 4:
				image.set_pixel(x, y, Color(1, 0.5, 0, 1))
			if abs(x - 46) < 5 and abs(y - 28) < 4:
				image.set_pixel(x, y, Color(1, 0.5, 0, 1))
	
	return ImageTexture.create_from_image(image)
