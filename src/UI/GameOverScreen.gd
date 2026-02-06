extends Control

## GameOverScreen - Game over overlay for The Drift
## Displays death reason, final stats, and provides restart option

## Reference to main container
var main_container: Control

## Reason label
var reason_label: Label

## Stats container
var stats_container: VBoxContainer

## Session time label
var session_time_label: Label

## Drifts survived label
var drifts_survived_label: Label

## Enemies killed label
var enemies_killed_label: Label

## Worlds explored label
var worlds_explored_label: Label

## Button container
var button_container: HBoxContainer

## Restart button
var restart_button: Button

## Game over reason
var game_over_reason: String = ""

## Stats reference
var drifts_survived: int = 0
var enemies_killed: int = 0
var session_time: String = "00:00"
var worlds_explored: int = 1


func _ready() -> void:
	_setup_overlay()
	_create_ui()
	_connect_signals()


func _setup_overlay() -> void:
	# Full-screen semi-transparent background
	var background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0.1, 0.05, 0.05, 0.95)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Main container with centered layout
	main_container = Control.new()
	main_container.name = "MainContainer"
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.offset_left = 100
	main_container.offset_right = -100
	main_container.offset_top = 50
	main_container.offset_bottom = -50
	add_child(main_container)


func _create_ui() -> void:
	# Game Over title
	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "💀 GAME OVER 💀"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	title_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_label.offset_top = 30
	title_label.offset_bottom = 100
	title_label.add_theme_font_size_override("font_size", 52)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	main_container.add_child(title_label)
	
	# Reason label
	reason_label = Label.new()
	reason_label.name = "ReasonLabel"
	reason_label.text = game_over_reason
	reason_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reason_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	reason_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_label.offset_bottom = 100
	reason_label.offset_top = 100
	reason_label.offset_bottom = 150
	reason_label.add_theme_font_size_override("font_size", 24)
	reason_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3))
	main_container.add_child(reason_label)
	
	# Stats container
	stats_container = VBoxContainer.new()
	stats_container.name = "StatsContainer"
	stats_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	stats_container.offset_top = 180
	stats_container.offset_bottom = -150
	stats_container.add_theme_constant_override("separation", 15)
	main_container.add_child(stats_container)
	
	# Create individual stat labels
	_create_stat_label("Session Time:", session_time_label, "TimeLabel")
	_create_stat_label("Drifts Survived:", drifts_survived_label, "DriftsLabel")
	_create_stat_label("Enemies Defeated:", enemies_killed_label, "EnemiesLabel")
	_create_stat_label("Worlds Explored:", worlds_explored_label, "WorldsLabel")
	
	# Update stats display
	_update_stats_display()
	
	# Button container
	button_container = HBoxContainer.new()
	button_container.name = "ButtonContainer"
	button_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	button_container.offset_top = -100
	button_container.offset_bottom = -30
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 30)
	main_container.add_child(button_container)
	
	# Restart button
	restart_button = Button.new()
	restart_button.name = "RestartButton"
	restart_button.text = "🔄 Try Again"
	restart_button.custom_minimum_size = Vector2(200, 50)
	restart_button.add_theme_font_size_override("font_size", 20)
	restart_button.pressed.connect(_on_restart_pressed)
	button_container.add_child(restart_button)


func _create_stat_label(label_text: String, label_ref: Label, label_name: String) -> void:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 20)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var label = Label.new()
	label.name = label_name
	label.text = label_text
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	container.add_child(label)
	
	var value_label = Label.new()
	value_label.name = label_name + "Value"
	value_label.text = "---"
	value_label.add_theme_font_size_override("font_size", 26)
	value_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	container.add_child(value_label)
	
	stats_container.add_child(container)
	
	# Store reference
	match label_name:
		"TimeLabel":
			session_time_label = value_label
		"DriftsLabel":
			drifts_survived_label = value_label
		"EnemiesLabel":
			enemies_killed_label = value_label
		"WorldsLabel":
			worlds_explored_label = value_label


func _update_stats_display() -> void:
	"""Update the stats display with current values"""
	if session_time_label:
		session_time_label.text = session_time
	
	if drifts_survived_label:
		drifts_survived_label.text = str(drifts_survived)
	
	if enemies_killed_label:
		enemies_killed_label.text = str(enemies_killed)
	
	if worlds_explored_label:
		worlds_explored_label.text = str(worlds_explored)


func _connect_signals() -> void:
	# Signals are connected in _ready
	pass


func _on_restart_pressed() -> void:
	"""Handle restart button press"""
	print("GameOverScreen: Restarting game...")
	
	# Disable buttons to prevent double clicks
	restart_button.disabled = true
	
	# Get GameManager and restart
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("initialize_game"):
		game_manager.initialize_game()
	
	# Reload the game scene
	get_tree().change_scene_to_file("res://src/Game/game.tscn")


func set_game_over_reason(reason: String) -> void:
	"""Set the game over reason to display"""
	game_over_reason = reason
	if reason_label:
		reason_label.text = reason


func set_stats(session_time_str: String, drifts: int, enemies: int, worlds: int) -> void:
	"""Set the statistics to display"""
	session_time = session_time_str
	drifts_survived = drifts
	enemies_killed = enemies
	worlds_explored = worlds
	_update_stats_display()


func show_game_over() -> void:
	"""Show the game over screen with animation"""
	visible = true
	
	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(main_container, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(main_container, "modulate:a", 1.0, 0.5)
	
	# Play sound effect if available
	_play_game_over_sound()


func _play_game_over_sound() -> void:
	# TODO: Add sound effect when sound system is available
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if not is_instance_valid(main_container):
		warnings.append("Main container not initialized properly")
	
	return warnings
