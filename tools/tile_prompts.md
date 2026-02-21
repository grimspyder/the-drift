# Tile Sprite Prompts for The Drift

Use these prompts with your AI-Pixel-Sprite-Sheet-Generator to create custom tiles for each world.

## Common Requirements
- 32x32 pixels per tile
- Pixel art style
- Limited color palette (16-24 colors)
- Top-down perspective
- Seamless tiling
- Transparent background
- Grid format on sprite sheet

---

## World 0: Prime World (Starting Area)

**Prompt:**
```
Create a 32x32 pixel tile map sprite sheet for a fantasy dungeon crawler game called "The Drift". Include these tiles:
- Stone floor tiles with cracks and subtle dirt (4 variations)
- Dark stone wall tiles (vertical, horizontal, corner)
- Wooden door tiles (closed, open)
- Stone stair tiles (up, down)
- Torch holder tiles with warm glow
- Cobweb corner decorations
- Rubble pile tiles
- Trap tile (pressure plate)
Style: Pixel art, medieval fantasy, limited palette, top-down view, seamless tiling.
```

---

## World 1: Verdant Realm (Nature/Green)

**Prompt:**
```
Create a 32x32 pixel tile map sprite sheet for an overgrown jungle temple in a game called "The Drift". Include these tiles:
- Mossy stone floor tiles with patches of grass (4 variations)
- Vine-covered stone wall tiles
- Flower tiles (red, blue, yellow)
- Mushroom patch tiles (glowing)
- Shallow water/lily pad tiles
- Ancient stone pillar tiles with roots
- Hidden treasure sparkle tiles
- Thorn trap tiles
Style: Pixel art, lush nature, bioluminescent accents, top-down view, seamless tiling.
```

---

## World 2: Arid Wastes (Desert)

**Prompt:**
```
Create a 32x32 pixel tile map sprite sheet for a scorched desert temple ruin in a game called "The Drift". Include these tiles:
- Sandy floor tiles with footprints (4 variations)
- Cracked adobe wall tiles with hieroglyphics
- Sand-covered stone stair tiles
- Dried fountain/basin tiles
- Ancient obelisk tiles
- Buried treasure sparkle tiles
- Heat shimmer effect tiles
- Sandstorm trap tiles
Style: Pixel art, desert ruins, warm earth tones, top-down view, seamless tiling.
```

---

## World 3: Crystalline Void (Magic/Crystal)

**Prompt:**
```
Create a 32x32 pixel tile map sprite sheet for a magical crystal cavern in a game called "The Drift". Include these tiles:
- Dark floor tiles with glowing crystal veins (4 variations)
- Purple crystal wall tiles (glowing)
- Magic rune floor tiles (animated glow effect described)
- Floating crystal shard tiles
- Energy portal tiles
- Crystal cluster decorations
- Mana pool tiles (glowing blue)
- Gravity trap tiles
Style: Pixel art, magical crystal, purple/blue glow, top-down view, seamless tiling.
```

---

## World 4: Ashen Realm (Fire/Destruction)

**Prompt:**
```
Create a 32x32 pixel tile map sprite sheet for a burned apocalyptic world in a game called "The Drift". Include these tiles:
- Ash-covered floor tiles with ember cracks (4 variations)
- Charred wooden beam wall tiles
- Cracked magma floor tiles (glowing orange)
- Ember pit tiles (glowing)
- Fire essence tiles (floating flames)
- Burnt corpse/debris tiles
- Smoke vent tiles
- Fire trap tiles
Style: Pixel art, apocalyptic, warm orange/red/black palette, top-down view, seamless tiling.
```

---

## World 5: Shadow Realm (Dark/Void)

**Prompt:**
```
Create a 32x32 pixel tile map sprite sheet for a shadow dimension/void in a game called "The Drift". Include these tiles:
- Dark purple void floor tiles (4 variations)
- Shadowy mist wall tiles
- Portal rift tiles (swirling dark energy)
- Shadow tendril decorations
- Dark crystal formations (purple glow)
- Void energy tiles (pulsing)
- Shadow trap tiles
- Exit portal tiles (bright light in darkness)
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
