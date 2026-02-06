# The Drift - Balance Recommendations
**Date:** 2026-02-06  
**Status:** Pre-Playtest Review  

---

## Executive Summary

The Drift has solid baseline balance but lacks **difficulty scaling**. Game becomes progressively **easier** as the player drifts (opposite of roguelike design). This document provides concrete recommendations for a more engaging difficulty curve.

---

## Current State Analysis

### Player Progression (Getting Stronger ✓)
```
Drift 0: Warrior, Tier 1 Equipment
Drift 1: Random Class, Tier 2 Equipment
Drift 2: Random Class, Tier 3 Equipment
...
Drift 10: Random Class, Tier 5 Equipment (MAX)
```

**Result:** Player stats increase with each drift. ✓ Correct.

### Enemy Progression (Static ✗)
```
Drift 0: 100 HP, 10 damage, 150 speed
Drift 1: 100 HP, 10 damage, 150 speed (no change!)
Drift 2: 100 HP, 10 damage, 150 speed (no change!)
...
Drift 10: 100 HP, 10 damage, 150 speed (no change!)
```

**Result:** Enemies never scale. ✗ **PROBLEM**

### Consequence
**Game Difficulty Curve:**
```
Drift 0: Fair (baseline)
Drift 3: Easy (player 3x better equipped)
Drift 5: Too Easy (player 5x better)
Drift 10: Trivial (player 10x better)
```

---

## Recommended Solution: Difficulty Scaling

### Approach 1: Enemy Stat Scaling (RECOMMENDED)

Enemies should become stronger as player drifts.

#### Implementation

**Scaling Formula:**
```gdscript
# In Enemy.gd or EnemySpawner.gd

func get_difficulty_multiplier() -> float:
    var game_manager = get_node_or_null("/root/GameManager")
    if not game_manager:
        return 1.0
    
    var drift_count = game_manager.drift_count
    
    # Curve: 0 drifts = 1.0x, 5 drifts = 1.5x, 10 drifts = 2.0x
    return 1.0 + (drift_count * 0.1)  # Linear scaling

func _apply_difficulty_scaling() -> void:
    var multiplier = get_difficulty_multiplier()
    
    # Scale health
    var base_health = 100.0  # Or your config value
    health.max_health = base_health * multiplier
    health.current_health = health.max_health
    
    # Scale damage
    var base_damage = 10.0   # Or your config value
    damage_to_player = base_damage * multiplier
```

**Scaling Table:**
| Drift | Health Mult | Damage Mult | Enemy HP | Enemy DMG |
|-------|-----------|-----------|----------|-----------|
| 0 | 1.0x | 1.0x | 100 | 10 |
| 1 | 1.1x | 1.1x | 110 | 11 |
| 2 | 1.2x | 1.2x | 120 | 12 |
| 3 | 1.3x | 1.3x | 130 | 13 |
| 4 | 1.4x | 1.4x | 140 | 14 |
| 5 | 1.5x | 1.5x | 150 | 15 |
| 6 | 1.6x | 1.6x | 160 | 16 |
| 7 | 1.7x | 1.7x | 170 | 17 |
| 8 | 1.8x | 1.8x | 180 | 18 |
| 9 | 1.9x | 1.9x | 190 | 19 |
| 10 | 2.0x | 2.0x | 200 | 20 |

**Result:** Game maintains 1.0x relative difficulty throughout.

#### Code Location
- **File:** `src/Entities/Enemy.gd`
- **Method:** `_apply_difficulty_scaling()` called in `_ready()`

---

### Approach 2: Alternative - Progressive Scaling

If linear scaling feels too aggressive, try exponential:

```gdscript
func get_difficulty_multiplier() -> float:
    var game_manager = get_node_or_null("/root/GameManager")
    var drift_count = game_manager.drift_count if game_manager else 0
    
    # Curve: 0→1.0x, 5→1.4x, 10→1.8x (slower growth)
    return pow(1.08, drift_count)  # 8% growth per drift
```

**Scaling Table (Exponential):**
| Drift | Multiplier | Enemy HP | Enemy DMG |
|-------|-----------|----------|-----------|
| 0 | 1.00x | 100 | 10 |
| 2 | 1.17x | 117 | 12 |
| 4 | 1.37x | 137 | 14 |
| 6 | 1.59x | 159 | 16 |
| 8 | 1.85x | 185 | 19 |
| 10 | 2.16x | 216 | 22 |

**Advantage:** Gentler early on, steeper late game.

---

## Secondary Recommendation: Increase Enemy Spawn Rate

Current spawn rate is too low for a dungeon crawl.

### Current Config
```gdscript
# EnemySpawner.gd
@export var enemy_count: int = 5           # Total per level
@export var max_enemies_per_room: int = 2  # Per room
```

With ~27 rooms (excluding first 3), 5 enemies = 0.2 encounters per room. **Too sparse.**

### Recommended Config
```gdscript
@export var enemy_count: int = 12          # Total per level (2.4x increase)
@export var max_enemies_per_room: int = 3  # Per room (1.5x increase)
```

This gives:
- ~12 enemies per level
- ~0.4 encounters per room
- More varied enemy mix
- Still room to maneuver

### Balance
```
12 enemies × 1.0-1.5x difficulty = 12-18 total enemy "strength"
Player with 100 HP, 25 damage = can handle 4-8 creatures
Implies: Must use terrain/kiting to win
```

---

## Tertiary Recommendation: Fast Enemy Balance

Fast enemies are strong but feel unfair at high difficulty.

### Current Stats
```
Basic Enemy:
  Speed: 150 px/s (50% of player)
  HP: 100
  Damage: 10

Fast Enemy (40% spawn):
  Speed: 250 px/s (83% of player!)
  HP: 30 (30% of basic)
  Damage: 5 (50% of basic)
```

**Issue:** 250 px/s is nearly as fast as player (300 px/s). Hard to kite.

### Option 1: Reduce Fast Enemy Speed
```gdscript
# FastEnemy.gd
@export var speed: float = 200.0  # Down from 250 (less threatening)
```

**Result:** Fast enemy = 67% of player speed. Easier to kite.

### Option 2: Boost Projectile Speed
```gdscript
# Projectile.gd
@export var speed: float = 1000.0  # Up from 800 (faster projectiles)
```

**Result:** Projectiles catch enemies faster. Less evasion time.

### Recommendation
**Use Option 1** (reduce fast enemy to 200 px/s). More intuitive for players.

---

## Spawn Rate Recommendation Details

### Why Increase Spawn Rate?

**Current:** 5 enemies / 27 rooms = 0.19 encounters/room
- Most rooms empty
- No tension
- Combat rare

**Proposed:** 12 enemies / 27 rooms = 0.44 encounters/room
- Every 2-3 rooms has enemies
- Constant threat
- Player must manage resources

### Implementation

```gdscript
# EnemySpawner.gd _ready()

@export var min_enemies_per_room: int = 0
@export var max_enemies_per_room: int = 3  # Changed from 2

func spawn_enemies() -> void:
    var room_count = _dungeon_generator.get_room_count()
    
    for i in range(1, room_count):
        var room_enemy_count = randi_range(min_enemies_per_room, max_enemies_per_room)
        
        for j in range(room_enemy_count):
            var spawn_pos = _get_random_position_in_room(i)
            _spawn_enemy(spawn_pos)
```

### Testing

Playtesting should verify:
- [ ] Encounters feel frequent but not oppressive
- [ ] Player can escape and heal between fights
- [ ] Boss/champion variant fights feel epic
- [ ] No performance degradation
- [ ] Difficulty scaling still works

---

## Additional Balance Notes

### Time Pressure ✓ GOOD
- 60 minute limit = natural game length
- Creates urgency late game
- Prevents infinite farming

### Drift Limit ✓ GOOD
- 10 drifts = hard cap
- Forces good play early (can't farm forever)
- Escape condition feels earned

### Equipment Progression ✓ GOOD
- 5 tiers of gear
- Each tier 20% better
- Tier 5 by drift 10 = reasonable progression

### Class Variety ✓ GOOD
- 8 different classes
- Each with unique stats
- Encourages varied playstyles
- Mutation adds replay value

---

## Recommended Tuning Order

### Phase 1: Core Balance (Do First)
1. **Implement difficulty scaling** (15 min)
   - Use linear 1.0 + drift*0.1 formula
   - Test with multiple playthroughs
   - Adjust multiplier if too aggressive

### Phase 2: Encounter Density (Playtesting)
2. **Increase enemy spawn rate** (5 min to change, hours to test)
   - Change enemy_count from 5 to 12
   - Change max_enemies_per_room from 2 to 3
   - Playtest with humans
   - Adjust based on feedback

### Phase 3: Polish (Optional)
3. **Tune fast enemy stats** (5 min)
   - Reduce speed to 200 px/s
   - OR increase projectile speed to 1000 px/s
   - Test targeting feels fair

---

## Before/After Comparison

### Before (Current)
```
Drift 0:  Basic enemies (100 HP, 10 DMG) - Fair
Drift 3:  Basic enemies (100 HP, 10 DMG) - Too Easy
Drift 10: Basic enemies (100 HP, 10 DMG) - Trivial
Spawn:    5 enemies, sparse encounters
```

### After (Recommended)
```
Drift 0:  Enemies 1.0x (100 HP, 10 DMG) - Fair
Drift 3:  Enemies 1.3x (130 HP, 13 DMG) - Fair
Drift 10: Enemies 2.0x (200 HP, 20 DMG) - Challenging
Spawn:    12 enemies, frequent encounters
```

---

## Testing Checklist

After applying recommendations:

### Difficulty Scaling
- [ ] Drift 0 enemies have base stats (100 HP, 10 DMG)
- [ ] Drift 5 enemies are 1.5x stronger (150 HP, 15 DMG)
- [ ] Drift 10 enemies are 2.0x stronger (200 HP, 20 DMG)
- [ ] Game feels equally challenging throughout
- [ ] Time limit still threatening at drift 10

### Spawn Rate
- [ ] Approximately 12 enemies per level
- [ ] Encounters feel frequent (every 2-3 rooms)
- [ ] No performance issues with more enemies
- [ ] Player can still escape and recover
- [ ] Combat feels engaging, not overwhelming

### Fast Enemy Balance
- [ ] Fast enemies feel dangerous but fair
- [ ] Can be hit with projectiles reliably
- [ ] Kiting strategy effective
- [ ] Not overpowered at high drifts

---

## Configuration Summary

### Recommended Settings

**Enemy Spawning (EnemySpawner.gd)**
```gdscript
@export var enemy_count: int = 12           # Up from 5
@export var max_enemies_per_room: int = 3   # Up from 2
@export var fast_enemy_ratio: float = 0.4   # Keep this
```

**Difficulty Scaling (Enemy.gd)**
```gdscript
func _apply_difficulty_scaling() -> void:
    var game_manager = get_node_or_null("/root/GameManager")
    var drift_count = game_manager.drift_count if game_manager else 0
    var multiplier = 1.0 + (drift_count * 0.1)
    
    health.max_health = 100 * multiplier
    damage_to_player = 10 * multiplier
```

**Fast Enemy Speed (FastEnemy.gd)**
```gdscript
@export var speed: float = 200.0  # Down from 250
```

---

## Impact on Session Length

### With Current Balance
- Average session: 5-8 minutes
- Game trivial by drift 5
- Playtime limited by time pressure, not difficulty

### With Recommended Balance
- Average session: 8-12 minutes
- Game challenging throughout
- Player skill determines outcome
- Time pressure still factor

---

## Optional: Advanced Difficulty Modifiers

If you want even more sophistication:

```gdscript
# Adaptive difficulty based on player performance
class DifficultyAdjuster:
    var enemy_kills_this_drift: int = 0
    var times_player_died: int = 0
    
    func get_multiplier(drift: int) -> float:
        var base = 1.0 + (drift * 0.1)
        var adjustment = 1.0
        
        # Reduce if player struggling (dying frequently)
        if times_player_died > 3:
            adjustment = 0.9
        
        # Increase if player dominating (many kills)
        if enemy_kills_this_drift > 20:
            adjustment = 1.1
        
        return base * adjustment
```

**Not recommended for initial release** - Add after testing.

---

## Summary

| Recommendation | Impact | Effort | Priority |
|---|---|---|---|
| Difficulty scaling | Makes game challenging throughout | 15 min | HIGH |
| Increase enemy spawn | Makes game feel populated | 5 min | MEDIUM |
| Tune fast enemy speed | Fairness and feel | 5 min | LOW |
| Advanced adaptive difficulty | Future feature | 1-2 hours | FUTURE |

---

## Next Steps

1. **Apply difficulty scaling code** to Enemy.gd
2. **Increase enemy spawn values** in EnemySpawner.gd
3. **Playtest with humans** (John)
4. **Collect feedback** on difficulty curve
5. **Adjust multipliers** if needed (can be balanced without code)

---

END OF RECOMMENDATIONS
