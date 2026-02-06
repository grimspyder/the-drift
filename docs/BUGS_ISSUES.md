# The Drift - Bugs & Issues List
**Date:** 2026-02-06  
**Status:** Ready for fixing  

---

## 🔴 CRITICAL ISSUES (Block Playtest)

### Issue #1: Missing WASD Input Configuration
**File:** `project.godot`  
**Severity:** 🔴 CRITICAL  
**Category:** Configuration  

**Problem:**
The input actions `move_left`, `move_right`, `move_up`, `move_down` have empty event arrays. No keyboard keys are bound.

```gdscript
# Current (broken):
move_left={
  "deadzone": 0.5,
  "events": [Object(...)] # Empty!
}
```

**Impact:** 
- WASD keys completely unresponsive
- Game unplayable without input
- Core mechanic fails

**Solution:**
Add key mappings to project.godot:
```
move_left: KEY_A
move_right: KEY_D  
move_up: KEY_W
move_down: KEY_S
```

**Testing:**
- [ ] WASD keys respond with movement
- [ ] All four directions work
- [ ] Diagonal movement works (W+D)

---

### Issue #2: Projectile Layer/Mask Mismatch
**File:** `src/Entities/Projectile.gd` (line ~28)  
**Severity:** 🔴 CRITICAL  
**Category:** Physics/Collision  

**Problem:**
Projectile collision layer/mask don't match the physics layer definitions.

```gdscript
# Current (wrong):
collision_layer = 4   # Projectiles
collision_mask = 8    # Enemies

# Physics layers:
# Layer 1: Player
# Layer 2: Walls
# Layer 3: Projectiles    <- Should be 3, not 4!
# Layer 4: Enemies
```

**Issue:** Layer 4 is enemies. Layer 3 is projectiles. Code sets layer 4.

**Impact:**
- Projectiles may not appear on correct layer
- Collision detection unreliable
- Damage tests fail
- Visual projectiles don't hit enemies properly

**Solution:**
```gdscript
# Fix in Projectile.gd _ready():
collision_layer = 3           # Projectiles layer
collision_mask = 2 | 4        # Collide with Walls AND Enemies
```

**Testing:**
- [ ] Projectiles spawn visible
- [ ] Projectiles hit enemies
- [ ] Projectiles hit walls
- [ ] Damage dealt properly

---

### Issue #3: Enemy Missing Group Registration
**File:** `src/Entities/Enemy.gd`  
**Severity:** 🔴 CRITICAL  
**Category:** Group Management  

**Problem:**
Enemy.gd doesn't call `add_to_group("enemies")` in _ready().

Tests and systems query for enemies using:
```gdscript
var enemies = get_tree().get_nodes_in_group("enemies")
```

But enemies are never added to the group!

**Impact:**
- Enemy detection fails
- Tests can't find enemies
- AI updates may not work
- Enemy kill tracking fails
- Respawning broken

**Solution:**
```gdscript
# Add to Enemy.gd _ready() at start:
func _ready() -> void:
    add_to_group("enemies")  # <- Add this line
    
    # Create health component...
    if not has_node("Health"):
        health = Health.new()
        # ... rest of existing code
```

**Testing:**
- [ ] Enemies found via group query
- [ ] Multiple enemies register
- [ ] Group persists across drift
- [ ] Enemy removal clears group

---

### Issue #4: HUD Missing Group Registration
**File:** `src/UI/HUD.gd`  
**Severity:** 🔴 CRITICAL  
**Category:** Group Management  

**Problem:**
HUD doesn't register to "hud" group, but GameManager tries to access it:

```gdscript
# GameManager.gd:
var hud = get_tree().get_first_node_in_group("hud")
if hud and hud.has_method("show_time_warning"):
    hud.show_time_warning()
```

**Impact:**
- Warnings don't show
- HUD updates may fail
- Stats don't display
- Player loses critical feedback

**Solution:**
```gdscript
# Add to HUD.gd _ready():
func _ready() -> void:
    add_to_group("hud")
    # ... rest of existing code
```

**Testing:**
- [ ] HUD found via group query
- [ ] Warnings display correctly
- [ ] Health bar updates
- [ ] World info displays

---

### Issue #5: ExitStairs Missing Group Registration
**File:** `src/Map/ExitStairs.gd`  
**Severity:** 🔴 CRITICAL  
**Category:** Group Management  

**Problem:**
ExitStairs doesn't register to "exit_stairs" group.

Win condition testing relies on:
```gdscript
var stairs = get_tree().get_nodes_in_group("exit_stairs")
```

**Impact:**
- Win condition can't be detected
- Player can reach stairs but no victory
- Test suite fails
- Game can't be completed

**Solution:**
```gdscript
# Add to ExitStairs.gd _ready():
func _ready() -> void:
    add_to_group("exit_stairs")
    # ... rest of existing code
```

**Testing:**
- [ ] Stairs found via group query
- [ ] Entering stairs triggers victory
- [ ] Win screen displays
- [ ] Stats recorded correctly

---

## 🟠 HIGH PRIORITY ISSUES

### Issue #6: Enemy Health Initialization Race Condition
**File:** `src/Entities/Enemy.gd` (lines 52-60)  
**Severity:** 🟠 HIGH  
**Category:** Logic/Initialization  

**Problem:**
Health component initialization might not sync with export variables.

```gdscript
@export var max_health: float = 100.0

func _ready() -> void:
    if not has_node("Health"):
        health = Health.new()
        # health.max_health = max_health  <- Not always set!
        add_child(health)
```

**Issue:** The `health.max_health` might not be properly initialized from the export var.

**Impact:**
- Enemy health inconsistent
- Damage calculations wrong
- Some enemies take different hit counts

**Solution:**
```gdscript
func _ready() -> void:
    if not has_node("Health"):
        health = Health.new()
        health.max_health = max_health  # Explicitly set from export
        health.current_health = max_health
        health.name = "Health"
        add_child(health)
    else:
        health = get_node("Health")
    
    # Connect signals
    health.died.connect(_on_died)
    health.damaged.connect(_on_damaged)
```

**Testing:**
- [ ] All enemies have correct max_health
- [ ] Damage calculations consistent
- [ ] Health displays correctly
- [ ] Death triggers at correct threshold

---

### Issue #7: FastEnemy Health Override Not Synced
**File:** `src/Entities/FastEnemy.gd` (lines 16-22)  
**Severity:** 🟠 HIGH  
**Category:** Logic  

**Problem:**
FastEnemy overrides health in _ready() after super._ready(), but values might not match export vars.

```gdscript
@export var max_health: float = 30.0

func _ready() -> void:
    super._ready()
    
    if health:
        health.max_health = max_health  # <- Might be out of sync
        health.current_health = max_health
```

**Solution:**
Ensure super._ready() properly initializes, then FastEnemy can confidently override.

**Testing:**
- [ ] FastEnemies have 30 HP (not 100)
- [ ] Weak enemies die in 1-2 hits
- [ ] Speed differential working

---

## 🟡 MEDIUM PRIORITY ISSUES

### Issue #8: Low Enemy Spawn Rate
**File:** `src/Entities/EnemySpawner.gd`  
**Severity:** 🟡 MEDIUM  
**Category:** Balance  

**Problem:**
Default spawn rate is too low:
```gdscript
@export var enemy_count: int = 5           # Only 5 per level!
@export var max_enemies_per_room: int = 2  # Max 2 per room
```

With ~30 rooms and only 5 total enemies, the dungeon feels empty and encounters are too rare.

**Impact:**
- Game feels sparse
- Player can avoid most combat
- Difficulty too easy
- Not much enemy variety

**Recommendation:**
Increase to:
```gdscript
@export var enemy_count: int = 12          # 12 per level
@export var max_enemies_per_room: int = 3  # Up to 3 per room
```

This gives ~2x enemy density while maintaining playability.

**Testing:**
- [ ] Playtested with humans
- [ ] Difficulty feels appropriate
- [ ] No performance issues with more enemies
- [ ] Still room to kite/maneuver

---

### Issue #9: No Difficulty Scaling with Drifts
**File:** `src/Entities/GameManager.gd` & Enemy spawning  
**Severity:** 🟡 MEDIUM  
**Category:** Balance  

**Problem:**
Game gets EASIER over time (inverse roguelike progression):
- Player: Gets stronger (better classes, tier upgrades)
- Enemies: Stay at base stats (100 HP, 10 damage forever)

By drift 5+, player is massively overpowered.

**Impact:**
- Game lacks endgame challenge
- Long sessions become trivial
- No tension in later worlds
- Time limit (60min) not threatening

**Recommendation:**
Implement scaling in GameManager or EnemySpawner:

```gdscript
# In EnemySpawner or Enemy:
var game_manager = get_node("/root/GameManager")
var drift_count = game_manager.drift_count

var health_multiplier = 1.0 + (drift_count * 0.3)
var damage_multiplier = 1.0 + (drift_count * 0.2)

health.max_health = base_health * health_multiplier
damage_to_player = base_damage * damage_multiplier
```

**Testing:**
- [ ] Drift 0: ~100 HP enemies
- [ ] Drift 5: ~150 HP enemies
- [ ] Drift 10: ~200 HP enemies
- [ ] Game maintains challenge throughout

---

### Issue #10: Fast Enemy Speed Outpaces Projectiles
**File:** `src/Entities/FastEnemy.gd` & Projectile.gd  
**Severity:** 🟡 MEDIUM  
**Category:** Balance  

**Problem:**
Fast enemies move at 250 px/s while player base speed is 300 px/s, but projectile speed is 800 px/s.

When kiting, a fast enemy can potentially outrun projectiles if the angle is bad.

```
Fast Enemy: 250 px/s
Projectile: 800 px/s
Time to cross 100px: 0.125 sec
Evasion margin: Tight
```

**Impact:**
- Difficult to hit fast enemies with poor aim
- Frustrating when projectiles "miss" close targets
- Balance feels unfair

**Recommendation:**
Option A: Reduce fast enemy speed to 200 px/s
Option B: Increase projectile speed to 1000 px/s
Option C: Increase projectile size/hitbox

**Testing:**
- [ ] Projectiles reliably hit enemies
- [ ] No "phantom miss" complaints
- [ ] Balance feels fair for player

---

## 🟢 MINOR ISSUES

### Issue #11: Double Projectile Cleanup
**File:** `src/Entities/Projectile.gd`  
**Severity:** 🟢 MINOR  
**Category:** Code Quality  

**Problem:**
Projectile has both collision signal cleanup AND lifetime cleanup:

```gdscript
func _on_body_entered(body: Node) -> void:
    # ...
    queue_free()  # First cleanup

func _on_timer_timeout() -> void:
    queue_free()  # Second cleanup - already freed?
```

**Issue:** Calling queue_free() twice is harmless but inefficient.

**Solution:**
```gdscript
var is_destroyed: bool = false

func _on_body_entered(body: Node) -> void:
    if is_destroyed:
        return
    is_destroyed = true
    body.take_damage(damage)
    queue_free()

func _on_timer_timeout() -> void:
    if is_destroyed:
        return
    is_destroyed = true
    queue_free()
```

**Impact:** Negligible - Godot handles gracefully.

**Testing:**
- [ ] No double-damage bugs
- [ ] No error messages
- [ ] Performance unchanged

---

### Issue #12: Missing Player Speed Class Modifier Application
**Severity:** 🟢 MINOR (Actually NOT a bug)  
**Status:** VERIFIED OK ✓

**Note:** Initial review flagged this, but code review confirms it's correctly implemented in `Player.gd _handle_movement()`. Class modifiers ARE applied. No fix needed.

---

## Summary Table

| # | Issue | Severity | Category | Fix Time |
|---|-------|----------|----------|----------|
| 1 | WASD Input Bindings | 🔴 CRITICAL | Config | 5 min |
| 2 | Projectile Layer/Mask | 🔴 CRITICAL | Physics | 5 min |
| 3 | Enemy Group | 🔴 CRITICAL | Groups | 2 min |
| 4 | HUD Group | 🔴 CRITICAL | Groups | 2 min |
| 5 | ExitStairs Group | 🔴 CRITICAL | Groups | 2 min |
| 6 | Enemy Health Init | 🟠 HIGH | Logic | 10 min |
| 7 | FastEnemy Health | 🟠 HIGH | Logic | 5 min |
| 8 | Low Spawn Rate | 🟡 MEDIUM | Balance | Playtesting |
| 9 | No Difficulty Scaling | 🟡 MEDIUM | Balance | 30 min |
| 10 | Fast Enemy Speed | 🟡 MEDIUM | Balance | Playtesting |
| 11 | Double Cleanup | 🟢 MINOR | Code | 10 min |
| 12 | Speed Modifiers | ✓ OK | - | - |

---

## Fix Priority Order

### Phase 1: Critical (30 min)
1. Add WASD input bindings to project.godot
2. Fix Projectile layer/mask in Projectile.gd
3. Add group registrations:
   - Enemy: add_to_group("enemies")
   - HUD: add_to_group("hud")
   - ExitStairs: add_to_group("exit_stairs")

### Phase 2: High Priority (20 min)
4. Fix enemy health initialization
5. Fix FastEnemy health override
6. Clean up projectile double-cleanup

### Phase 3: Balance (Ongoing)
7. Increase enemy spawn rate (playtesting)
8. Implement difficulty scaling
9. Tune fast enemy speed/stats

---

## Verification Checklist

After fixes, verify:
- [ ] Game starts without errors
- [ ] WASD movement works
- [ ] Shooting fires projectiles
- [ ] Projectiles hit enemies (damage dealt)
- [ ] Enemies spawn and attack
- [ ] Player takes damage
- [ ] Death triggers drift
- [ ] Drift regenerates world
- [ ] Classes mutate on drift
- [ ] Can reach exit stairs and win
- [ ] All groups working correctly
- [ ] No console errors

---

END OF ISSUES LIST
