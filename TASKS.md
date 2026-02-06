# The Drift - MVP Task Breakdown

**Research Source:** `/home/grimspyder/clawd-workspace-research/notes/the-drift-research.md`
**Estimated Timeline:** 2-4 weeks
**Scope:** Single level, prove drift mechanic

---

## Development Sequence

### Phase 1: Foundation (Days 1-3)
**Task 1.1: Project Setup**
- Initialize Godot 4 project in repo
- Set up folder structure (src/, assets/, autoload/)
- Configure version control (.gitignore for Godot)
- Create main scene skeleton
**Agent:** Coding Agent (MiniMax M2.1)
**Dependencies:** None
**Status:** ✅ COMPLETE - Finished 2026-02-05 23:50 UTC
**Commit:** `735b250` - feat: Initialize Godot 4 project structure

**Task 1.2: Player Controller**
- CharacterBody2D player scene
- Input handling (WASD + mouse aim)
- Basic movement physics
- Placeholder sprite
**Agent:** Coding Agent
**Dependencies:** 1.1
**Status:** ✅ COMPLETE - Finished 2026-02-05 23:55 UTC
**Commit:** `XXX` - feat: Implement player controller with WASD movement and mouse aiming

---

### Phase 2: World Building (Days 4-6)
**Task 2.1: Static Level Layout**
- TileMap or tile system
- Collision layers
- Single room for testing
- Placeholder tileset
**Agent:** Coding Agent
**Dependencies:** 1.2
**Status:** ✅ COMPLETE - Finished 2026-02-05 23:50 UTC
**Commit:** `65996eb` - feat: Add static level layout with TileMap

**Task 2.2: Procedural Generation**
- DungeonGenerator node
- Random room placement (non-overlapping)
- L-tunnel connections
- Seed-based generation
**Agent:** Coding Agent
**Dependencies:** 2.1
**Status:** ✅ COMPLETE - Finished 2026-02-06
**Commit:** `b388ecd` - feat: Implement procedural dungeon generation with DungeonGenerator

---

### Phase 3: Core Systems (Days 7-10)
**Task 3.1: Combat System**
- Projectile shooting (mouse aim)
- Damage/hit detection
- Enemy prefab (chase AI)
- Basic health system
**Agent:** Coding Agent
**Dependencies:** 1.2, 2.1
**Status:** ✅ COMPLETE - Finished 2026-02-06
**Commit:** `778f74a` - feat: Implement combat system

**Task 3.2: The Drift Mechanic** ⭐ CRITICAL
- Death detection
- GameManager autoload
- World regeneration on death
- Player respawn
- Session tracking
**Agent:** Architecture Agent (design) → Coding Agent (impl)
**Dependencies:** 3.1
**Status:** ⏳ Blocked by 3.1

---

### Phase 4: Variations (Days 11-14)
**Task 4.1: World Themes**
- 5 world definitions (Prime, Verdant, Arid, Crystalline, Ashen)
- Tile color modulation per world
- Seed generation per world_id
**Agent:** Coding Agent
**Dependencies:** 3.2
**Status:** ⏳ Blocked by 3.2

**Task 4.2: Class System**
- 8 class definitions (Resource)
- Class stats (speed, damage)
- Random class shift on drift
- Warrior, Wizard, Gatherer, Hunter, Paladin, Cleric, Rogue, Assassin
**Agent:** Coding Agent
**Dependencies:** 3.2
**Status:** ⏳ Blocked by 3.2

**Task 4.3: Equipment Variation**
- Weapon/armor slots
- Material variants (wood→copper→iron)
- Random equip on drift
**Agent:** Coding Agent
**Dependencies:** 3.2
**Status:** ⏳ Blocked by 3.2

---

### Phase 5: UI & Polish (Days 15-18)
**Task 5.1: HUD**
- Health bar
- World indicator
- Death counter
- Session timer
**Agent:** Coding Agent
**Dependencies:** 3.2
**Status:** ⏳ Blocked by 3.2

**Task 5.2: Cooldown System**
- Session timer (1 hour limit)
- Max drift limit (10)
- Game over condition
**Agent:** Coding Agent
**Dependencies:** 3.2
**Status:** ⏳ Blocked by 3.2

**Task 5.3: Win Condition**
- Exit stairs
- Completion screen
- Stats summary
**Agent:** Coding Agent
**Dependencies:** 2.2
**Status:** ⏳ Blocked by 2.2

---

### Phase 6: Testing & Balance (Days 19-21)
**Task 6.1: Playtest & Balance**
- Difficulty tuning
- Enemy spawn rates
- Drift variations feel different
- Bug fixes
**Agent:** Testing Agent + John
**Dependencies:** All above
**Status:** ⏳ Blocked by completion

**Task 6.2: Build & Release**
- Export to Windows/Mac/Linux
- itch.io page setup
- Beta release notes
**Agent:** DevOps Agent
**Dependencies:** 6.1
**Status:** ⏳ Blocked by 6.1

---

## Project Structure

```
/home/grimspyder/the-drift/
├── project.godot          # Godot 4 configuration
├── .gitignore             # Git ignore for Godot
├── .gdignore              # Godot resource ignore
├── icon.svg               # Project icon
├── src/
│   ├── Game/
│   │   ├── game.gd        # Main game script
│   │   └── game.tscn     # Main scene (Map/Entities/UI)
│   ├── Entities/          # Player, Enemy prefabs
│   ├── Map/               # Dungeon generation
│   ├── Utils/             # Utilities
│   └── UI/                # HUD, menus
├── assets/
│   ├── sprites/           # Game sprites
│   ├── tilesets/          # Tile resources
│   └── definitions/       # Entity/Class definitions
└── autoload/              # Global singletons (GameManager, etc.)
```

---

## Task Status Summary

| Task | Status | Assigned | Due |
|------|--------|----------|-----|
| 1.1 Project Setup | ✅ Complete | - | Day 1 |
| 1.2 Player Controller | ⏳ Ready | - | Day 2-3 |
| 2.1 Static Level | ✅ Complete | - | Day 4-5 |
| 2.2 Procedural Gen | ✅ Complete | - | Day 6 |
| 3.1 Combat System | ⏳ Blocked | - | Day 7-9 |
| 3.2 Drift Mechanic | ⏳ Blocked | - | Day 10 |
| 4.1 World Themes | ⏳ Blocked | - | Day 11-12 |
| 4.2 Class System | ⏳ Blocked | - | Day 13 |
| 4.3 Equipment | ⏳ Blocked | - | Day 14 |
| 5.1 HUD | ⏳ Blocked | - | Day 15-16 |
| 5.2 Cooldown | ⏳ Blocked | - | Day 17 |
| 5.3 Win Condition | ⏳ Blocked | - | Day 18 |
| 6.1 Playtest | ⏳ Blocked | - | Day 19-20 |
| 6.2 Release | ⏳ Blocked | - | Day 21 |

---

## Next Actions
1. ✅ Task 1.1 Complete - Godot project initialized
2. ✅ Task 1.2 Complete - Player controller implemented
3. ✅ Task 2.1 Complete - Static level layout added
4. ✅ Task 2.2 Complete - Procedural dungeon generation implemented
5. ⏳ Spawn Coding Agent for Task 3.2 (The Drift Mechanic)

---

**Coordinator:** test-agent  
**Last Updated:** 2026-02-05 23:50 UTC
