# Tile Sprite Prompts for The Drift - ENHANCED ATLAS FORMAT

Use these prompts with your AI-Pixel-Sprite-Sheet-Generator to create custom tiles for each world.

## CRITICAL: Tile Atlas Layout
Your sprite sheet MUST be organized in a grid with these exact positions:
- **Row 0**: Wall tiles (positions 0-5)
- **Row 1**: Floor tiles (positions 0-5)  
- **Row 2**: Corridor/Dirt tiles (positions 0-2)
- **Row 3**: Special/Door tiles (positions 0-2)

This allows the game to randomly select from variations for natural-looking maps.

## Common Requirements
- 32x32 pixels per tile
- Pixel art style
- Limited color palette (16-24 colors)
- Top-down perspective
- Seamless tiling (tiles should blend when placed next to each other)
- Transparent background
- 6 columns x 4 rows grid format

---

## World 0: Prime World (Starting Area) - Stone Dungeon

**Prompt:**
```
Create a 32x32 pixel TILE ATLAS for a fantasy dungeon crawler game called "The Drift". IMPORTANT: Layout MUST be exactly 6 columns x 4 rows (192x128 pixels total):

ROW 0 (Walls - positions 0-5):
- Position 0: Stone wall tile, dark gray with brick pattern
- Position 1: Stone wall tile variation with moss/age
- Position 2: Stone wall corner (interior left)
- Position 3: Stone wall corner (interior right)  
- Position 4: Wall with torch sconce (warm orange glow)
- Position 5: Cracked damaged wall

ROW 1 (Floors - positions 0-5):
- Position 0: Stone floor, medium gray with subtle cracks
- Position 1: Stone floor variation with darker patches
- Position 2: Stone floor with worn/dirt spots
- Position 3: Stone floor with debris/rubble
- Position 4: Darker stone floor (depth variation)
- Position 5: Light stone floor (highlight variation)

ROW 2 (Corridors/Dirt - positions 0-2):
- Position 0: Dirt corridor floor, brown-gray
- Position 1: Stone corridor with footprints
- Position 2: Wet/darker corridor patch

ROW 3 (Special - positions 0-2):
- Position 0: Wooden door (closed), brown with frame
- Position 1: Open doorway/archway
- Position 2: Stone stairs (top-down view)

Style: Pixel art, medieval dungeon, limited 16-color palette, top-down view, seamless edge tiling for floors and walls.
```

---

## World 1: Verdant Realm (Nature/Green) - Jungle Temple

**Prompt:**
```
Create a 32x32 pixel TILE ATLAS for an overgrown jungle temple in a game called "The Drift". IMPORTANT: Layout MUST be exactly 6 columns x 4 rows (192x128 pixels total):

ROW 0 (Walls):
- Position 0: Moss-covered stone wall, green-gray
- Position 1: Vine-covered wall with hanging vines
- Position 2: Ancient stone wall with hieroglyphics
- Position 3: Wall with roots crawling up
- Position 4: Damaged cracked wall with plants
- Position 5: Smooth temple wall section

ROW 1 (Floors):
- Position 0: Mossy stone floor, green-tinted
- Position 1: Stone floor with grass patches
- Position 2: Worn stone with dirt
- Position 3: Floor with small mushrooms
- Position 4: Dark damp floor section
- Position 5: Light mossy highlight

ROW 2 (Corridors):
- Position 0: Dirt path through jungle
- Position 1: Stone path with leaves
- Position 2: Overgrown broken path

ROW 3 (Special):
- Position 0: Closed wooden door, warped
- Position 1: Open temple archway
- Position 2: Stone altar/sacrifice spot

Style: Pixel art, lush jungle, green/brown palette, top-down view, seamless tiling.
```

---

## World 2: Arid Wastes (Desert) - Desert Ruins

**Prompt:**
```
Create a 32x32 pixel TILE ATLAS for a scorched desert temple ruin in a game called "The Drift". IMPORTANT: Layout MUST be exactly 6 columns x 4 rows:

ROW 0 (Walls):
- Position 0: Adobe wall, tan/beige
- Position 1: Cracked sun-damaged wall
- Position 2: Wall with ancient hieroglyphics
- Position 3: Sand-covered crumbling wall
- Position 4: Dark shadow in doorway
- Position 5: Smooth temple wall

ROW 1 (Floors):
- Position 0: Sandy floor, light beige
- Position 1: Sand with footprints
- Position 2: Worn stone through sand
- Position 3: Darker sand in shade
- Position 4: Dusty debris floor
- Position 5: Light sand highlight

ROW 2 (Corridors):
- Position 0: Sand corridor path
- Position 1: Wind-swept sand drift
- Position 2: Buried stone steps

ROW 3 (Special):
- Position 0: Closed gate/door
- Position 1: Open archway
- Position 2: Ancient obelisk marker

Style: Pixel art, desert ruins, warm earth tones, top-down view, seamless tiling.
```

---

## World 3: Crystalline Void (Magic/Crystal) - Crystal Cavern

**Prompt:**
```
Create a 32x32 pixel TILE ATLAS for a magical crystal cavern in a game called "The Drift". IMPORTANT: Layout MUST be exactly 6 columns x 4 rows:

ROW 0 (Walls):
- Position 0: Dark crystal wall, deep purple
- Position 1: Glowing crystal formation
- Position 2: Jagged crystal outcrop
- Position 3: Smooth cavern wall
- Position 4: Wall with magic runes
- Position 5: Shadowy void wall

ROW 1 (Floors):
- Position 0: Dark cavern floor, purple-black
- Position 1: Floor with crystal veins (glowing)
- Position 2: Shimmering magical floor
- Position 3: Dusty crystal cave floor
- Position 4: Reflective mana pool edge
- Position 5: Dark pit edge

ROW 2 (Corridors):
- Position 0: Crystal corridor floor
- Position 1: Glowing path (magical light)
- Position 2: Cracked crystal floor

ROW 3 (Special):
- Position 0: Crystal barrier/door
- Position 1: Portal archway (glowing)
- Position 2: Magic altar/crystal cluster

Style: Pixel art, magical crystal, purple/blue glow, top-down view, seamless tiling.
```

---

## World 4: Ashen Realm (Fire/Destruction) - Burned World

**Prompt:**
```
Create a 32x32 pixel TILE ATLAS for a burned apocalyptic world in a game called "The Drift". IMPORTANT: Layout MUST be exactly 6 columns x 4 rows:

ROW 0 (Walls):
- Position 0: Charred black wall
- Position 1: Burnt wooden beam wall
- Position 2: Smoke-stained stone
- Position 3: Collapsed wall with debris
- Position 4: Wall with ember cracks (glowing)
- Position 5: Dark ash-covered wall

ROW 1 (Floors):
- Position 0: Ash-covered floor, gray-black
- Position 1: Floor with ember cracks (orange glow)
- Position 2: Burnt debris floor
- Position 3: Cracked magma floor
- Position 4: Charred wood planks
- Position 5: Dark soot floor

ROW 2 (Corridors):
- Position 0: Ash corridor path
- Position 1: Glowing ember trail
- Position 2: Burnt rubble corridor

ROW 3 (Special):
- Position 0: Melted door/gate
- Position 1: Fire barrier (animated)
- Position 2: Ash pile/embers

Style: Pixel art, apocalyptic, warm orange/red/black palette, top-down view, seamless tiling.
```

---

## World 5: Shadow Realm (Dark/Void) - Dark Dimension

**Prompt:**
```
Create a 32x32 pixel TILE ATLAS for a shadow dimension/void in a game called "The Drift". IMPORTANT: Layout MUST be exactly 6 columns x 4 rows:

ROW 0 (Walls):
- Position 0: Void wall, deep purple-black
- Position 1: Shadow mist wall
- Position 2: Dark crystal wall (purple glow)
- Position 3: Swirling void energy
- Position 4: Shadow tendril wall
- Position 5: Dark portal edge

ROW 1 (Floors):
- Position 0: Void floor, dark purple
- Position 1: Floor with shadow pools
- Position 2: Glowing purple rune floor
- Position 3: Misty shadow floor
- Position 4: Dark crystal floor
- Position 5: Pulsing void energy

ROW 2 (Corridors):
- Position 0: Shadow corridor
- Position 1: Glowing purple path
- Position 2: Misty void passage

ROW 3 (Special):
- Position 0: Shadow barrier/door
- Position 1: Portal archway
- Position 2: Void altar/crystal

Style: Pixel art, dark void, purple/black with eerie glow, top-down view, seamless tiling.
```

---

## Tips for Godot Integration

1. Generate tiles as separate sprite sheets
2. Import to Godot as TileSet resources
3. Set tile_set_path in each WorldTheme to point to the .tres file

Example Godot TileSet structure:
- Wall tiles: atlas coordinates (0,0) - (2,0)
- Floor tiles: atlas coordinates (0,1) - (5,1)  
- Decorations: atlas coordinates (0,2) - (3,2)
- Hazards: atlas coordinates (0,3) - (2,3)
