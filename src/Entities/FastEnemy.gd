extends Enemy

## FastEnemy - Quicker, weaker enemy variant
## Inherits from Enemy but with different stats

@export var speed: float = 250.0  # Faster than basic enemy
@export var detection_range: float = 500.0  # Sees player from farther
@export var damage_to_player: float = 5.0   # Weaker attacks
@export var max_health: float = 30.0        # Less health


func _ready() -> void:
	# Call parent _ready first
	super._ready()
	
	# Override health with variant stats
	if health:
		health.max_health = max_health
		health.current_health = max_health


func _create_enemy_texture() -> Texture2D:
	# Create a faster-looking enemy (smaller, maybe green)
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.8, 0.3))  # Green color (faster)
	# Add a darker border
	for x in range(48):
		for y in range(48):
			var dist = Vector2(x - 24, y - 24).length()
			if dist > 22:
				image.set_pixel(x, y, Color(0.1, 0.5, 0.15))
			elif dist > 20:
				image.set_pixel(x, y, Color(0.15, 0.65, 0.2))
	return ImageTexture.create_from_image(image)
