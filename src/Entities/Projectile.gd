extends Area2D

## Projectile movement speed
@export var speed: float = 800.0

## Projectile lifetime in seconds
@export var lifetime: float = 3.0

## Damage amount (for future use)
@export var damage: float = 10.0

## Direction the projectile is moving
var direction: Vector2 = Vector2.RIGHT

## Projectile sprite component
var sprite: Sprite2D

## Projectile collision shape
var collision_shape: CollisionShape2D


func _ready() -> void:
	# Create placeholder sprite (colored rectangle)
	sprite = Sprite2D.new()
	var placeholder_texture = _create_placeholder_texture()
	sprite.texture = placeholder_texture
	sprite.scale = Vector2(0.3, 0.1)  # Small bullet shape
	sprite.position = Vector2.ZERO
	add_child(sprite)

	# Create collision shape
	collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 6)  # Match sprite scale
	collision_shape.shape = shape
	collision_shape.position = Vector2.ZERO
	add_child(collision_shape)

	# Connect collision signal (for future enemy interaction)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Set lifetime timer
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_timer_timeout)


func _create_placeholder_texture() -> Texture2D:
	# Create a simple colored rectangle texture
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 0.8, 0.2))  # Golden yellow color
	return ImageTexture.create_from_image(image)


func _process(delta: float) -> void:
	# Move projectile in direction
	position += direction * speed * delta


func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	# Rotate sprite to face direction
	if direction.length() > 0:
		rotation = direction.angle()


func _on_body_entered(body: Node) -> void:
	# TODO: Implement damage logic when enemies are added
	print("Projectile hit body: ", body.name)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	# TODO: Handle other projectile collisions
	print("Projectile hit area: ", area.name)
	queue_free()


func _on_timer_timeout() -> void:
	# Despawn after lifetime expires
	queue_free()
