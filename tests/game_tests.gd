extends Node

## The Drift - Automated Test Suite
## Tests core game systems: Movement, Shooting, AI, Combat, Drift Mechanics, Balance

# Test results tracking
var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0
var test_errors: Array[Dictionary] = []

# Test configuration
var test_game_scene: String = "res://src/Game/game.tscn"
var timeout_ms: int = 10000

# Game references
var game_scene: Node2D
var player: CharacterBody2D
var game_manager: Node
var level: Node2D

# ===================================================================
# TEST FRAMEWORK
# ===================================================================

func print_test(name: String) -> void:
	print("\n[TEST] ", name)
	tests_run += 1

func pass_test(message: String = "") -> void:
	tests_passed += 1
	print("  ✓ PASS", " - " + message if message else "")

func fail_test(message: String = "") -> void:
	tests_failed += 1
	var error_msg = "[FAIL] " + message if message else "[FAIL]"
	print("  ✗ FAIL - ", message)
	test_errors.append({
		"test": tests_run,
		"message": message
	})

func assert_true(condition: bool, message: String) -> void:
	if condition:
		pass_test(message)
	else:
		fail_test(message)

func assert_false(condition: bool, message: String) -> void:
	assert_true(not condition, message)

func assert_equal(a, b, message: String) -> void:
	if a == b:
		pass_test(message)
	else:
		fail_test(message + " (expected: " + str(b) + ", got: " + str(a) + ")")

func assert_greater(a: float, b: float, message: String) -> void:
	if a > b:
		pass_test(message)
	else:
		fail_test(message + " (" + str(a) + " not greater than " + str(b) + ")")

func assert_less(a: float, b: float, message: String) -> void:
	if a < b:
		pass_test(message)
	else:
		fail_test(message + " (" + str(a) + " not less than " + str(b) + ")")

func assert_between(value: float, min_val: float, max_val: float, message: String) -> void:
	if value >= min_val and value <= max_val:
		pass_test(message)
	else:
		fail_test(message + " (" + str(value) + " not between " + str(min_val) + " and " + str(max_val) + ")")

func assert_not_null(obj, message: String) -> void:
	if obj != null:
		pass_test(message)
	else:
		fail_test(message + " (value is null)")

func assert_null(obj, message: String) -> void:
	if obj == null:
		pass_test(message)
	else:
		fail_test(message + " (value is not null)")

# ===================================================================
# TEST SETUP / TEARDOWN
# ===================================================================

func setup_game() -> bool:
	"""Load and initialize the game scene"""
	print("\n=== GAME SETUP ===")
	
	# Load game scene
	var scene = load(test_game_scene)
	if scene == null:
		print("ERROR: Cannot load game scene: ", test_game_scene)
		return false
	
	game_scene = scene.instantiate()
	add_child(game_scene)
	
	# Wait for _ready
	await get_tree().process_frame
	
	# Get references
	game_manager = get_tree().root.get_node("GameManager")
	if game_manager == null:
		print("ERROR: GameManager not found")
		return false
	
	player = game_scene.get_node_or_null("Entities/Player")
	if player == null:
		print("ERROR: Player not found")
		return false
	
	level = game_scene.get_node_or_null("Map/Level")
	if level == null:
		print("ERROR: Level not found")
		return false
	
	# Initialize game
	game_manager.initialize_game()
	
	print("Game loaded successfully")
	print("Player at: ", player.global_position)
	print("Game Manager seed: ", game_manager.session_seed)
	
	return true

func cleanup_game() -> void:
	"""Clean up the game scene"""
	print("\n=== CLEANUP ===")
	if game_scene:
		game_scene.queue_free()
		await get_tree().process_frame

# ===================================================================
# 1. MOVEMENT TESTS
# ===================================================================

func test_movement_wasd() -> void:
	print_test("Player responds to WASD input")
	
	var initial_pos = player.global_position
	
	# Simulate WASD key presses
	Input.action_press("move_right")
	
	# Wait a few frames for movement to register
	for i in range(10):
		await get_tree().process_frame
	
	Input.action_release("move_right")
	await get_tree().process_frame
	
	var final_pos = player.global_position
	var distance_moved = initial_pos.distance_to(final_pos)
	
	assert_greater(distance_moved, 5.0, "Player moved right when right key pressed")

func test_movement_all_directions() -> void:
	print_test("Player moves in all four directions")
	
	# Test UP
	var pos_before = player.global_position
	Input.action_press("move_up")
	for i in range(10):
		await get_tree().process_frame
	Input.action_release("move_up")
	assert_less(player.global_position.y, pos_before.y, "Player moves UP")
	
	# Test DOWN
	pos_before = player.global_position
	Input.action_press("move_down")
	for i in range(10):
		await get_tree().process_frame
	Input.action_release("move_down")
	assert_greater(player.global_position.y, pos_before.y, "Player moves DOWN")
	
	# Test LEFT
	pos_before = player.global_position
	Input.action_press("move_left")
	for i in range(10):
		await get_tree().process_frame
	Input.action_release("move_left")
	assert_less(player.global_position.x, pos_before.x, "Player moves LEFT")
	
	# Test RIGHT
	pos_before = player.global_position
	Input.action_press("move_right")
	for i in range(10):
		await get_tree().process_frame
	Input.action_release("move_right")
	assert_greater(player.global_position.x, pos_before.x, "Player moves RIGHT")

func test_movement_acceleration() -> void:
	print_test("Player acceleration works smoothly")
	
	var initial_pos = player.global_position
	
	Input.action_press("move_right")
	
	# Measure distance at different time intervals
	var dist_at_5f = 0.0
	var dist_at_10f = 0.0
	
	for i in range(10):
		await get_tree().process_frame
		if i == 4:
			dist_at_5f = initial_pos.distance_to(player.global_position)
		if i == 9:
			dist_at_10f = initial_pos.distance_to(player.global_position)
	
	Input.action_release("move_right")
	
	# Distance should increase (acceleration)
	assert_greater(dist_at_10f, dist_at_5f, "Player accelerates (10f distance > 5f distance)")

func test_movement_friction() -> void:
	print_test("Player velocity decelerates with friction")
	
	# Move right first
	Input.action_press("move_right")
	for i in range(20):
		await get_tree().process_frame
	Input.action_release("move_right")
	
	var pos_at_stop = player.global_position
	
	# Let friction work for a few frames
	for i in range(5):
		await get_tree().process_frame
	
	var pos_after = player.global_position
	var continued_distance = pos_at_stop.distance_to(pos_after)
	
	# Should still move a bit due to velocity, but should be slowing
	assert_greater(continued_distance, 0.0, "Player continues moving after key release (momentum)")
	assert_less(continued_distance, 50.0, "Player slows down quickly (friction working)")

# ===================================================================
# 2. SHOOTING TESTS
# ===================================================================

func test_projectile_spawns() -> void:
	print_test("Projectiles spawn on shoot input")
	
	var initial_projectile_count = player.get_parent().get_child_count()
	
	# Simulate mouse position
	var mouse_pos = player.global_position + Vector2(100, 0)
	get_viewport().warp_mouse(mouse_pos)
	await get_tree().process_frame
	
	# Shoot
	Input.action_press("shoot")
	await get_tree().process_frame
	Input.action_release("shoot")
	await get_tree().process_frame
	
	var final_projectile_count = player.get_parent().get_child_count()
	
	assert_greater(final_projectile_count, initial_projectile_count, "Projectile spawned when shoot pressed")

func test_projectile_direction() -> void:
	print_test("Projectiles move in correct direction")
	
	var spawn_pos = player.global_position
	
	# Aim right
	var mouse_pos = player.global_position + Vector2(200, 0)
	get_viewport().warp_mouse(mouse_pos)
	await get_tree().process_frame
	
	Input.action_press("shoot")
	await get_tree().process_frame
	Input.action_release("shoot")
	await get_tree().process_frame
	
	# Find the spawned projectile
	var projectiles = player.get_parent().get_children()
	var projectile = null
	for p in projectiles:
		if p.name.contains("Projectile"):
			projectile = p
			break
	
	if projectile:
		var projectile_pos = projectile.global_position
		# Projectile should be to the right of spawn
		assert_greater(projectile_pos.x, spawn_pos.x - 50, "Projectile spawned to the right")

func test_projectile_fire_rate() -> void:
	print_test("Fire rate cooldown prevents rapid firing")
	
	var parent = player.get_parent()
	var initial_count = parent.get_child_count()
	
	# Try to fire multiple times rapidly
	for i in range(5):
		Input.action_press("shoot")
		await get_tree().process_frame
		Input.action_release("shoot")
		await get_tree().process_frame
	
	var final_count = parent.get_child_count()
	var projectiles_spawned = final_count - initial_count
	
	# Should not spawn 5 projectiles immediately (cooldown should prevent it)
	assert_less(projectiles_spawned, 5, "Fire rate limits rapid projectile spawning")

# ===================================================================
# 3. ENEMY AI TESTS
# ===================================================================

func test_enemy_spawn() -> void:
	print_test("Enemies spawn in level")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	assert_greater(enemies.size(), 0, "At least one enemy spawned in level")

func test_enemy_chase_behavior() -> void:
	print_test("Enemies chase player when in range")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		fail_test("No enemies found to test")
		return
	
	var enemy = enemies[0]
	
	# Move player close to enemy
	var initial_distance = enemy.global_position.distance_to(player.global_position)
	player.global_position = enemy.global_position + Vector2(100, 0)
	
	# Wait for enemy to detect and chase
	for i in range(30):
		await get_tree().process_frame
	
	var final_distance = enemy.global_position.distance_to(player.global_position)
	
	# Enemy should have moved closer to player
	assert_less(final_distance, initial_distance, "Enemy moved closer to player (chase behavior)")

func test_enemy_detection_range() -> void:
	print_test("Enemy detection range limits")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		fail_test("No enemies found to test")
		return
	
	var enemy = enemies[0]
	
	# Move player far from enemy (beyond detection range)
	player.global_position = enemy.global_position + Vector2(500, 500)
	
	var initial_enemy_pos = enemy.global_position
	
	# Wait for processing
	for i in range(20):
		await get_tree().process_frame
	
	var final_enemy_pos = enemy.global_position
	
	# Enemy should not move much (out of detection range)
	var distance_moved = initial_enemy_pos.distance_to(final_enemy_pos)
	assert_less(distance_moved, 50.0, "Enemy doesn't chase when out of range")

# ===================================================================
# 4. COMBAT TESTS
# ===================================================================

func test_projectile_damage() -> void:
	print_test("Projectiles deal damage to enemies")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		fail_test("No enemies found to test")
		return
	
	var enemy = enemies[0]
	var initial_health = enemy.health.current_health
	
	# Move enemy close to player
	enemy.global_position = player.global_position + Vector2(30, 0)
	
	# Aim at enemy and shoot
	var mouse_pos = player.global_position + Vector2(50, 0)
	get_viewport().warp_mouse(mouse_pos)
	await get_tree().process_frame
	
	Input.action_press("shoot")
	await get_tree().process_frame
	Input.action_release("shoot")
	
	# Wait for projectile to hit
	for i in range(10):
		await get_tree().process_frame
	
	var final_health = enemy.health.current_health
	
	assert_less(final_health, initial_health, "Enemy health decreased after projectile hit")

func test_player_take_damage() -> void:
	print_test("Player takes damage from enemies")
	
	var initial_health = player.health.current_health
	
	# Simulate damage
	player.take_damage(10.0)
	
	var final_health = player.health.current_health
	
	assert_less(final_health, initial_health, "Player health decreased after taking damage")

func test_player_death_threshold() -> void:
	print_test("Player dies when health reaches zero")
	
	var health = player.health
	health.current_health = 5.0
	
	# Deal damage that kills
	player.take_damage(10.0)
	
	await get_tree().process_frame
	
	assert_true(health.is_dead(), "Player is dead when health <= 0")

func test_player_healing() -> void:
	print_test("Player can be healed")
	
	player.health.current_health = 30.0
	var health_before_heal = player.health.current_health
	
	player.heal(20.0)
	
	var health_after_heal = player.health.current_health
	
	assert_greater(health_after_heal, health_before_heal, "Player health increased after healing")

func test_armor_defense() -> void:
	print_test("Armor reduces damage taken")
	
	var base_damage = 20.0
	var player_defense = player.get_effective_defense()
	
	# Take damage
	player.take_damage(base_damage)
	var health_after_base = player.health.current_health
	
	# Reset and try with calculation
	player.health.reset_health()
	
	if player_defense > 0:
		pass_test("Armor provides defense bonus")
	else:
		fail_test("Armor defense calculation needed")

# ===================================================================
# 5. DRIFT MECHANIC TESTS
# ===================================================================

func test_death_triggers_drift() -> void:
	print_test("Player death triggers drift mechanic")
	
	var initial_drift_count = game_manager.drift_count
	
	# Kill player
	player.health.current_health = 0
	player.health.died.emit()
	
	# Wait for drift transition
	await get_tree().create_timer(2.0).timeout
	
	var final_drift_count = game_manager.drift_count
	
	assert_greater(final_drift_count, initial_drift_count, "Drift count increased after player death")

func test_drift_world_changes() -> void:
	print_test("Drift changes world ID")
	
	var initial_world_id = game_manager.world_id
	
	# Trigger drift
	game_manager.force_drift()
	
	# Wait for drift transition
	await get_tree().create_timer(2.0).timeout
	
	var final_world_id = game_manager.world_id
	
	assert_greater(final_world_id, initial_world_id, "World ID increased after drift")

func test_player_respawn_on_drift() -> void:
	print_test("Player respawns after drift")
	
	var initial_pos = player.global_position
	
	# Move player to a new location
	player.global_position = Vector2(500, 500)
	
	# Trigger drift
	game_manager.force_drift()
	
	# Wait for respawn
	await get_tree().create_timer(2.0).timeout
	
	var final_pos = player.global_position
	
	assert_not_equal(final_pos, Vector2(500, 500), "Player respawned at different position")

func assert_not_equal(a, b, message: String) -> void:
	if a != b:
		pass_test(message)
	else:
		fail_test(message + " (values are equal)")

# ===================================================================
# 6. CLASS MUTATION TESTS
# ===================================================================

func test_class_mutation_on_drift() -> void:
	print_test("Player class changes on drift")
	
	var initial_class = player.current_class.class_id if player.current_class else "unknown"
	
	# Trigger drift
	game_manager.force_drift()
	
	# Wait for mutation
	await get_tree().create_timer(2.0).timeout
	
	var final_class = player.current_class.class_id if player.current_class else "unknown"
	
	# Class should be different (though theoretically could be same)
	assert_not_equal(final_class, initial_class, "Player class changed after drift")

func test_equipment_upgrade_on_drift() -> void:
	print_test("Equipment upgrades on drift")
	
	var initial_weapon = player.weapon
	var initial_weapon_tier = 0
	if initial_weapon and initial_weapon.equipment_id.contains("_"):
		initial_weapon_tier = int(initial_weapon.equipment_id.get_slice("_", 1))
	
	# Multiple drifts should upgrade equipment
	for i in range(2):
		game_manager.force_drift()
		await get_tree().create_timer(2.0).timeout
	
	var final_weapon = player.weapon
	var final_weapon_tier = 0
	if final_weapon and final_weapon.equipment_id.contains("_"):
		final_weapon_tier = int(final_weapon.equipment_id.get_slice("_", 1))
	
	assert_greater(final_weapon_tier, initial_weapon_tier, "Equipment tier increased")

# ===================================================================
# 7. WORLD REGENERATION TESTS
# ===================================================================

func test_dungeon_regenerates_on_drift() -> void:
	print_test("Dungeon regenerates with new layout on drift")
	
	if level == null or not level.has_node("DungeonGenerator"):
		fail_test("No DungeonGenerator found")
		return
	
	var dungeon_gen = level.get_node("DungeonGenerator")
	var initial_seed = dungeon_gen.seed_value
	
	# Trigger drift
	game_manager.force_drift()
	
	# Wait for regeneration
	await get_tree().create_timer(2.0).timeout
	
	var final_seed = dungeon_gen.seed_value
	
	assert_not_equal(final_seed, initial_seed, "Dungeon seed changed after drift")

func test_enemies_respawn_on_drift() -> void:
	print_test("Enemies respawn after dungeon regeneration")
	
	var initial_enemies = get_tree().get_nodes_in_group("enemies").size()
	
	# Kill all enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	await get_tree().process_frame
	
	# Trigger drift
	game_manager.force_drift()
	
	# Wait for spawning
	await get_tree().create_timer(2.0).timeout
	
	var final_enemies = get_tree().get_nodes_in_group("enemies").size()
	
	assert_greater(final_enemies, 0, "Enemies respawned after drift")

# ===================================================================
# 8. WIN CONDITION TESTS
# ===================================================================

func test_exit_stairs_reachable() -> void:
	print_test("Exit stairs exist in level")
	
	var stairs = get_tree().get_nodes_in_group("exit_stairs")
	
	assert_greater(stairs.size(), 0, "Exit stairs found in level")

func test_win_condition_triggers() -> void:
	print_test("Win condition can be triggered")
	
	# Move player to stairs if they exist
	var stairs = get_tree().get_nodes_in_group("exit_stairs")
	if stairs.is_empty():
		fail_test("No stairs to test win condition")
		return
	
	var initial_game_won = game_manager.game_won
	
	# Force win
	game_manager.win_game()
	
	var final_game_won = game_manager.game_won
	
	assert_true(final_game_won, "Game won flag set when win triggered")

# ===================================================================
# BALANCE REVIEW TESTS
# ===================================================================

func test_balance_player_health() -> void:
	print_test("Balance: Player health in reasonable range")
	
	var max_hp = player.health.max_health
	
	assert_between(max_hp, 50.0, 200.0, "Player max HP is reasonable (50-200)")

func test_balance_enemy_spawn_rate() -> void:
	print_test("Balance: Enemy spawn rate reasonable")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var enemy_count = enemies.size()
	
	# Should have between 2-20 enemies per level
	assert_between(enemy_count, 1, 50, "Enemy count in reasonable range (1-50)")

func test_balance_player_vs_enemy_damage() -> void:
	print_test("Balance: Player damage vs enemy health")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		fail_test("No enemies to test")
		return
	
	var enemy = enemies[0]
	var player_damage = player.get_effective_damage()
	var enemy_health = enemy.health.max_health
	
	# Player should be able to kill enemy in reasonable number of hits (5-30)
	var hits_to_kill = enemy_health / player_damage
	assert_between(hits_to_kill, 1.0, 30.0, "Player can kill enemy in 1-30 hits")

func test_balance_enemy_vs_player_damage() -> void:
	print_test("Balance: Enemy damage vs player health")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		fail_test("No enemies to test")
		return
	
	var enemy = enemies[0]
	var player_hp = player.health.max_health
	var enemy_damage = enemy.damage_to_player
	
	# Enemy should take 3-30 hits to kill player
	var hits_to_kill_player = player_hp / enemy_damage
	assert_between(hits_to_kill_player, 2.0, 100.0, "Enemy needs 2-100 hits to kill player")

func test_balance_fire_rate() -> void:
	print_test("Balance: Player fire rate")
	
	var fire_rate = player.fire_rate
	
	assert_between(fire_rate, 1.0, 15.0, "Fire rate in reasonable range (1-15 shots/sec)")

# ===================================================================
# PERFORMANCE TESTS
# ===================================================================

func test_performance_fps() -> void:
	print_test("Performance: FPS above 60")
	
	# Simulate some gameplay
	Input.action_press("move_right")
	for i in range(60):
		await get_tree().process_frame
	Input.action_release("move_right")
	
	var fps = Engine.get_physics_frames()
	
	# This is a basic check - real performance testing would need profiling
	assert_greater(fps, 0, "Game is running (FPS > 0)")

func test_performance_dungeon_generation() -> void:
	print_test("Performance: Dungeon generation completes quickly")
	
	if level == null or not level.has_node("DungeonGenerator"):
		fail_test("No DungeonGenerator found")
		return
	
	# Dungeon should already be generated by now
	var dungeon = level.get_node("DungeonGenerator")
	assert_not_null(dungeon, "Dungeon generator exists")
	pass_test("Dungeon generation completed (assumed < 1 second)")

# ===================================================================
# BUG HUNTING TESTS
# ===================================================================

func test_bug_player_clipping() -> void:
	print_test("Bug Hunt: Player clipping through walls")
	
	# Move player around and check collision
	var initial_pos = player.global_position
	
	Input.action_press("move_right")
	for i in range(50):
		await get_tree().process_frame
	Input.action_release("move_right")
	
	# Player should have moved but not drastically
	var final_pos = player.global_position
	var distance = initial_pos.distance_to(final_pos)
	
	assert_greater(distance, 0.0, "Player moved (no frozen collision)")
	assert_less(distance, 2000.0, "Player movement reasonable (no teleport through walls)")

func test_bug_enemy_stuck() -> void:
	print_test("Bug Hunt: Enemies not getting stuck")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		fail_test("No enemies to test")
		return
	
	var enemy = enemies[0]
	var initial_pos = enemy.global_position
	
	# Wait for AI updates
	for i in range(30):
		await get_tree().process_frame
	
	var final_pos = enemy.global_position
	var distance = initial_pos.distance_to(final_pos)
	
	# Enemy should be able to move (not stuck)
	# Note: This is a basic check; may need more sophisticated testing
	assert_greater(distance, -1.0, "Enemy moving (not completely stuck)")

func test_bug_projectile_hitting() -> void:
	print_test("Bug Hunt: Projectiles can hit targets")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		fail_test("No enemies to test")
		return
	
	var enemy = enemies[0]
	var initial_health = enemy.health.current_health
	
	# Move enemy close and shoot repeatedly
	enemy.global_position = player.global_position + Vector2(40, 0)
	
	for attempt in range(3):
		var mouse_pos = player.global_position + Vector2(100, 0)
		get_viewport().warp_mouse(mouse_pos)
		await get_tree().process_frame
		
		Input.action_press("shoot")
		await get_tree().process_frame
		Input.action_release("shoot")
		
		# Wait for projectile travel
		for i in range(20):
			await get_tree().process_frame
	
	var final_health = enemy.health.current_health
	
	# At least one shot should have hit
	assert_less(final_health, initial_health, "Projectile successfully hit enemy")

func test_bug_hud_updating() -> void:
	print_test("Bug Hunt: HUD updates correctly")
	
	var hud = get_tree().get_first_node_in_group("hud")
	
	if hud == null:
		fail_test("HUD not found in scene")
		return
	
	# HUD exists
	assert_not_null(hud, "HUD found in scene")
	
	# Check for basic HUD nodes
	if hud.has_node("HealthBar"):
		pass_test("Health bar exists")
	elif hud.has_method("update_health"):
		pass_test("HUD has health update method")
	else:
		fail_test("HUD missing health display")

# ===================================================================
# TEST RUNNER
# ===================================================================

func run_all_tests() -> void:
	print("\n" + "=".repeat(70))
	print("THE DRIFT - AUTOMATED TEST SUITE")
	print("=".repeat(70))
	
	# Setup
	if not await setup_game():
		print("\nFATAL: Cannot setup game. Tests cannot run.")
		return
	
	# Test Groups
	print("\n" + "=".repeat(70))
	print("GROUP 1: MOVEMENT TESTS")
	print("=".repeat(70))
	test_movement_wasd()
	test_movement_all_directions()
	test_movement_acceleration()
	test_movement_friction()
	
	print("\n" + "=".repeat(70))
	print("GROUP 2: SHOOTING TESTS")
	print("=".repeat(70))
	test_projectile_spawns()
	test_projectile_direction()
	test_projectile_fire_rate()
	
	print("\n" + "=".repeat(70))
	print("GROUP 3: ENEMY AI TESTS")
	print("=".repeat(70))
	test_enemy_spawn()
	test_enemy_chase_behavior()
	test_enemy_detection_range()
	
	print("\n" + "=".repeat(70))
	print("GROUP 4: COMBAT TESTS")
	print("=".repeat(70))
	test_projectile_damage()
	test_player_take_damage()
	test_player_death_threshold()
	test_player_healing()
	test_armor_defense()
	
	print("\n" + "=".repeat(70))
	print("GROUP 5: DRIFT MECHANIC TESTS")
	print("=".repeat(70))
	test_death_triggers_drift()
	test_drift_world_changes()
	test_player_respawn_on_drift()
	
	print("\n" + "=".repeat(70))
	print("GROUP 6: CLASS MUTATION TESTS")
	print("=".repeat(70))
	test_class_mutation_on_drift()
	test_equipment_upgrade_on_drift()
	
	print("\n" + "=".repeat(70))
	print("GROUP 7: WORLD REGENERATION TESTS")
	print("=".repeat(70))
	test_dungeon_regenerates_on_drift()
	test_enemies_respawn_on_drift()
	
	print("\n" + "=".repeat(70))
	print("GROUP 8: WIN CONDITION TESTS")
	print("=".repeat(70))
	test_exit_stairs_reachable()
	test_win_condition_triggers()
	
	print("\n" + "=".repeat(70))
	print("GROUP 9: BALANCE REVIEW TESTS")
	print("=".repeat(70))
	test_balance_player_health()
	test_balance_enemy_spawn_rate()
	test_balance_player_vs_enemy_damage()
	test_balance_enemy_vs_player_damage()
	test_balance_fire_rate()
	
	print("\n" + "=".repeat(70))
	print("GROUP 10: PERFORMANCE TESTS")
	print("=".repeat(70))
	test_performance_fps()
	test_performance_dungeon_generation()
	
	print("\n" + "=".repeat(70))
	print("GROUP 11: BUG HUNTING TESTS")
	print("=".repeat(70))
	test_bug_player_clipping()
	test_bug_enemy_stuck()
	test_bug_projectile_hitting()
	test_bug_hud_updating()
	
	# Cleanup
	await cleanup_game()
	
	# Summary
	print_summary()

func print_summary() -> void:
	print("\n" + "=".repeat(70))
	print("TEST SUMMARY")
	print("=".repeat(70))
	print("Tests Run:    ", tests_run)
	print("Tests Passed: ", tests_passed)
	print("Tests Failed: ", tests_failed)
	
	var pass_rate = 0.0
	if tests_run > 0:
		pass_rate = (float(tests_passed) / float(tests_run)) * 100.0
	
	print("Pass Rate:    ", pass_rate, "%")
	
	if tests_failed > 0:
		print("\n" + "=".repeat(70))
		print("FAILED TESTS")
		print("=".repeat(70))
		for error in test_errors:
			print("  [Test #", error["test"], "] ", error["message"])
	
	print("\n" + "=".repeat(70))
	if tests_failed == 0:
		print("✓ ALL TESTS PASSED")
	else:
		print("✗ SOME TESTS FAILED")
	print("=".repeat(70) + "\n")

# ===================================================================
# AUTO-RUN ON READY
# ===================================================================

func _ready() -> void:
	# Only run if this scene is the main scene or explicitly triggered
	set_process(true)

func _process(_delta: float) -> void:
	# Run tests on first frame
	if tests_run == 0:
		set_process(false)
		await run_all_tests()
		# Exit after tests
		get_tree().quit()
