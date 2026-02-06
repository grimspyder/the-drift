extends Enemy

## FastEnemy - Quicker, weaker enemy variant
## Inherits from Enemy but with different stats

@export var max_health_base: float = 30.0 # Less health

func _init() -> void:
	speed = 250.0
	detection_range = 500.0
	damage_to_player = 5.0

func _ready() -> void:
	# Call parent _ready first (which handles difficulty scaling)
	super._ready()


func _apply_difficulty_scaling() -> void:
	"""Override difficulty scaling for FastEnemy stats"""
	var multiplier = _get_difficulty_multiplier()
	
	# Scale max health
	health.max_health = max_health_base * multiplier
	health.current_health = health.max_health
	
	# Scale damage to player
	var base_damage = 5.0
	damage_to_player = base_damage * multiplier


func _create_enemy_texture() -> Texture2D:
	# Create a faster-looking enemy (smaller, maybe green)
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.8, 0.3)) # Green color (faster)
	# Add a darker border
	for x in range(48):
		for y in range(48):
			var dist = Vector2(x - 24, y - 24).length()
			if dist > 22:
				image.set_pixel(x, y, Color(0.1, 0.5, 0.15))
			elif dist > 20:
				image.set_pixel(x, y, Color(0.15, 0.65, 0.2))
	return ImageTexture.create_from_image(image)
