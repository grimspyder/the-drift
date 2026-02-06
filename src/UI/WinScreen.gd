extends Control

## WinScreen - Victory overlay for completing the dungeon
## Displays completion stats and provides restart/main menu options

## Reference to main container
var main_container: Control

## Title label
var title_label: Label

## Stats container
var stats_container: VBoxContainer

## Completion time label
var completion_time_label: Label

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

## Main menu button
var main_menu_button: Button

## Stats reference
var drifts_survived: int = 0
var enemies_killed: int = 0
var completion_time: String = "00:00"


func _ready() -> void:
	_setup_overlay()
	_create_ui()
	_connect_signals()


func _setup_overlay() -> void:
	# Full-screen semi-transparent background
	var background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0.05, 0.05, 0.1, 0.95)
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
	# Title label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "🎉 DUNGEON COMPLETE! 🎉"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	title_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_label.offset_top = 30
	title_label.offset_bottom = 120
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	main_container.add_child(title_label)
	
	# Subtitle
	var subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.text = "You have successfully escaped The Drift!"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	subtitle_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	subtitle_label.offset_top = 80
	subtitle_label.offset_bottom = 120
	subtitle_label.add_theme_font_size_override("font_size", 24)
	subtitle_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	main_container.add_child(subtitle_label)
	
	# Stats container
	stats_container = VBoxContainer.new()
	stats_container.name = "StatsContainer"
	stats_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	stats_container.offset_top = 150
	stats_container.offset_bottom = -150
	stats_container.add_theme_constant_override("separation", 15)
	main_container.add_child(stats_container)
	
	# Create individual stat labels
	_create_stat_label("Completion Time:", completion_time_label, "TimeLabel")
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
	restart_button.text = "🔄 Play Again"
	restart_button.custom_minimum_size = Vector2(200, 50)
	restart_button.add_theme_font_size_override("font_size", 20)
	restart_button.pressed.connect(_on_restart_pressed)
	button_container.add_child(restart_button)
	
	# Main menu button
	main_menu_button = Button.new()
	main_menu_button.name = "MainMenuButton"
	main_menu_button.text = "🏠 Main Menu"
	main_menu_button.custom_minimum_size = Vector2(200, 50)
	main_menu_button.add_theme_font_size_override("font_size", 20)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	button_container.add_child(main_menu_button)


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
			completion_time_label = value_label
		"DriftsLabel":
			drifts_survived_label = value_label
		"EnemiesLabel":
			enemies_killed_label = value_label
		"WorldsLabel":
			worlds_explored_label = value_label


func _update_stats_display() -> void:
	"""Update the stats display with current values"""
	if completion_time_label:
		completion_time_label.text = completion_time
	
	if drifts_survived_label:
		drifts_survived_label.text = str(drifts_survived)
	
	if enemies_killed_label:
		enemies_killed_label.text = str(enemies_killed)
	
	if worlds_explored_label:
		# Calculate worlds explored (drifts + 1 for initial world)
		worlds_explored_label.text = str(drifts_survived + 1)


func _connect_signals() -> void:
	# Signals are connected in _ready
	pass


func _on_restart_pressed() -> void:
	"""Handle restart button press"""
	print("WinScreen: Restarting game...")
	
	# Disable buttons to prevent double clicks
	restart_button.disabled = true
	main_menu_button.disabled = true
	
	# Get GameManager and restart
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("initialize_game"):
		game_manager.initialize_game()
	
	# Reload the game scene
	get_tree().change_scene_to_file("res://src/Game/game.tscn")


func _on_main_menu_pressed() -> void:
	"""Handle main menu button press"""
	print("WinScreen: Returning to main menu...")
	
	# Disable buttons
	restart_button.disabled = true
	main_menu_button.disabled = true
	
	# TODO: Change to main menu scene when available
	# For now, just reload to game scene
	get_tree().change_scene_to_file("res://src/Game/game.tscn")


func set_stats(completion_time_str: String, drifts: int, enemies: int) -> void:
	"""Set the statistics to display"""
	completion_time = completion_time_str
	drifts_survived = drifts
	enemies_killed = enemies
	_update_stats_display()


func show_victory() -> void:
	"""Show the victory screen with animation"""
	visible = true
	
	# Animate in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(main_container, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(main_container, "modulate:a", 1.0, 0.5)
	
	# Play sound effect if available
	_play_victory_sound()


func _play_victory_sound() -> void:
	# TODO: Add sound effect when sound system is available
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if not is_instance_valid(main_container):
		warnings.append("Main container not initialized properly")
	
	return warnings
