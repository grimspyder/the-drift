extends CanvasLayer

## HUD (Heads-Up Display) for The Drift
## Displays health, drift counter, timer, class/equipment, and world theme

# -------------------------------------------------------------------------
# References to UI Elements
# -------------------------------------------------------------------------

# Health Bar
@onready var health_bar_container: Control = $HealthBarContainer
@onready var health_bar_background: ColorRect = $HealthBarContainer/HealthBarBackground
@onready var health_bar_fill: ColorRect = $HealthBarContainer/HealthBarFill
@onready var health_label: Label = $HealthBarContainer/HealthLabel

# Drift Counter
@onready var drift_container: Control = $DriftContainer
@onready var drift_number_label: Label = $DriftContainer/DriftNumberLabel
@onready var drift_remaining_label: Label = $DriftContainer/DriftRemainingLabel

# Session Timer
@onready var timer_container: Control = $TimerContainer
@onready var elapsed_time_label: Label = $TimerContainer/ElapsedTimeLabel
@onready var remaining_time_label: Label = $TimerContainer/RemainingTimeLabel

# Class & Equipment
@onready var class_equipment_container: Control = $ClassEquipmentContainer
@onready var class_label: Label = $ClassEquipmentContainer/ClassLabel
@onready var equipment_label: Label = $ClassEquipmentContainer/EquipmentLabel
@onready var material_indicator: ColorRect = $ClassEquipmentContainer/MaterialIndicator

# World Theme Indicator
@onready var theme_container: Control = $ThemeContainer
@onready var theme_label: Label = $ThemeContainer/ThemeLabel

# -------------------------------------------------------------------------
# Game References
# -------------------------------------------------------------------------

var game_manager: Node
var player: CharacterBody2D
var _update_timer: Timer

# -------------------------------------------------------------------------
# Initialization
# -------------------------------------------------------------------------

func _ready() -> void:
	# Get GameManager autoload
	game_manager = get_node_or_null("/root/GameManager")
	
	# Find player in scene tree
	_find_player()
	
	# Set up update timer (1 second intervals for timer display)
	_update_timer = Timer.new()
	_update_timer.wait_time = 0.5
	_update_timer.timeout.connect(_on_update_timer_timeout)
	_update_timer.autostart = true
	add_child(_update_timer)
	
	# Initial UI update
	_update_all_ui()
	
	print("HUD: Initialized")


func _find_player() -> void:
	# Try to find player through game manager first
	if game_manager and game_manager.has_method("register_player"):
		# Player is registered with game manager, will be found on first update
		pass
	
	# Also try to find in scene
	var entities = get_tree().get_first_node_in_group("entities")
	if entities:
		for child in entities.get_children():
			if child is CharacterBody2D and child.has_method("get_player_stats"):
				player = child
				break
	
	# If still not found, try direct path from game scene
	if not player:
		var game = get_tree().get_first_node_in_group("game")
		if game:
			var entities_node = game.find_child("Entities", true, false)
			if entities_node:
				for child in entities_node.get_children():
					if child is CharacterBody2D:
						player = child
						break


# -------------------------------------------------------------------------
# UI Update Functions
# -------------------------------------------------------------------------

func _on_update_timer_timeout() -> void:
	_update_all_ui()


func _update_all_ui() -> void:
	_find_player()
	_update_health()
	_update_drift_counter()
	_update_timer()
	_update_class_equipment()
	_update_theme_indicator()


func _update_health() -> void:
	if not player or not player.has_method("get_health"):
		return
	
	var health = player.get_health()
	if not health:
		return
	
	var current_health = health.current_health
	var max_health = health.max_health
	var health_percent = max(0.0, current_health / max_health) if max_health > 0 else 0.0
	
	# Update health label
	health_label.text = "HP: %d / %d" % [int(current_health), int(max_health)]
	
	# Update health bar fill width
	var bar_width = health_bar_background.size.x - 4  # Account for borders
	health_bar_fill.size.x = bar_width * health_percent
	
	# Update health bar color based on percentage
	var bar_color: Color
	if health_percent > 0.6:
		bar_color = Color(0.2, 0.8, 0.3)  # Green
	elif health_percent > 0.3:
		bar_color = Color(0.9, 0.8, 0.2)  # Yellow
	else:
		bar_color = Color(0.9, 0.2, 0.2)  # Red
	
	health_bar_fill.color = bar_color


func _update_drift_counter() -> void:
	if not game_manager:
		return
	
	var world_info = game_manager.get_world_info() if game_manager.has_method("get_world_info") else {}
	
	var drift_number = world_info.get("drift_count", 0) + 1  # Display as 1-indexed
	var drifts_remaining = world_info.get("drifts_remaining", 10)
	
	drift_number_label.text = "Drift #%d" % drift_number
	drift_remaining_label.text = "Remaining: %d" % drifts_remaining
	
	# Change color if low on drifts
	if drifts_remaining <= 2:
		drift_remaining_label.modulate = Color(0.9, 0.3, 0.3)  # Red warning
	else:
		drift_remaining_label.modulate = Color(0.9, 0.9, 0.9)  # Normal white


func _update_timer() -> void:
	if not game_manager:
		return
	
	var world_info = game_manager.get_world_info() if game_manager.has_method("get_world_info") else {}
	
	var elapsed = world_info.get("session_time", "00:00")
	var remaining = world_info.get("session_time_remaining", "60:00")
	
	elapsed_time_label.text = "Elapsed: %s" % elapsed
	remaining_time_label.text = "Left: %s" % remaining
	
	# Show warning if time is running low (under 5 minutes)
	var remaining_seconds = _parse_time_string(remaining)
	if remaining_seconds < 300:  # 5 minutes
		remaining_time_label.modulate = Color(0.9, 0.3, 0.3)  # Red warning
	else:
		remaining_time_label.modulate = Color(0.9, 0.9, 0.9)  # Normal white


func _parse_time_string(time_str: String) -> int:
	# Parse "MM:SS" format to seconds
	var parts = time_str.split(":")
	if parts.size() == 2:
		var minutes = parts[0].to_int()
		var seconds = parts[1].to_int()
		return minutes * 60 + seconds
	return 3600  # Default to 1 hour


func _update_class_equipment() -> void:
	if not player or not player.has_method("get_player_stats"):
		return
	
	var stats = player.get_player_stats()
	
	# Update class label
	class_label.text = stats.get("class", "Unknown")
	
	# Update equipment label
	var weapon = stats.get("weapon", "Unarmed")
	var weapon_damage = stats.get("weapon_damage", 0)
	equipment_label.text = "%s (+%.0f DMG)" % [weapon, weapon_damage]
	
	# Update material indicator color based on tier
	var equipment = player.weapon if player.has("weapon") else null
	if equipment and equipment.has_method("get_tier_name"):
		var tier = equipment.material_tier
		material_indicator.color = Equipment.get_tier_color(tier)


func _update_theme_indicator() -> void:
	if not game_manager:
		return
	
	var world_info = game_manager.get_world_info() if game_manager.has_method("get_world_info") else {}
	
	var theme_name = world_info.get("theme_name", "Unknown")
	theme_label.text = theme_name
	
	# Get theme color from WorldThemeDatabase
	var theme_db = get_node_or_null("/root/GameManager/WorldThemeDatabase")
	if theme_db:
		var theme_id = game_manager.world_id if game_manager.has("world_id") else 0
		var theme = theme_db.get_theme(theme_id)
		if theme:
			theme_label.modulate = theme.floor_color.lightened(0.3)
	else:
		# Default colors for known themes
		var theme_colors = {
			"Prime": Color(0.9, 0.9, 0.7),
			"Verdant": Color(0.3, 0.8, 0.4),
			"Arid": Color(0.9, 0.7, 0.3),
			"Crystalline": Color(0.4, 0.5, 0.9),
			"Ashen": Color(0.7, 0.3, 0.2),
		}
		theme_label.modulate = theme_colors.get(theme_name, Color.WHITE)


# -------------------------------------------------------------------------
# Public Update Functions (called from other scripts)
# -------------------------------------------------------------------------

func update_health_ui() -> void:
	_update_health()


func update_drift_ui() -> void:
	_update_drift_counter()
	_update_theme_indicator()


func update_timer_ui() -> void:
	_update_timer()


func update_class_equipment_ui() -> void:
	_update_class_equipment()


func update_all_ui() -> void:
	_update_all_ui()


# -------------------------------------------------------------------------
# Visual Feedback Functions
# -------------------------------------------------------------------------

func flash_health_bar(flash_color: Color = Color(1.0, 1.0, 1.0, 0.8)) -> void:
	# Flash the health bar white for damage feedback
	var tween = create_tween()
	tween.tween_property(health_bar_fill, "modulate", flash_color, 0.1)
	tween.tween_property(health_bar_fill, "modulate", Color.WHITE, 0.2)


func show_drift_effect() -> void:
	# Visual effect when drifting
	var tween = create_tween()
	
	# Fade out
	tween.tween_property(drift_container, "modulate:a", 0.0, 0.5)
	
	# Update drift counter
	_update_drift_counter()
	
	# Fade in
	tween.tween_property(drift_container, "modulate:a", 1.0, 0.5)


func show_level_up_effect() -> void:
	# Visual feedback for mutation/upgrade
	var tween = create_tween()
	
	# Pulse the class label
	tween.tween_property(class_label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(class_label, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Change color temporarily
	tween.tween_property(class_label, "modulate", Color(0.5, 1.0, 0.5), 0.3)
	tween.tween_property(class_label, "modulate", Color.WHITE, 0.3)
