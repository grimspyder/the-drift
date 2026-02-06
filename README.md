# The Drift

A roguelike game with a unique **"Many Worlds" death mechanic** built with [Godot 4.x](https://godotengine.org/).

![The Drift](assets/screenshot-placeholder.png)

## Overview

**The Drift** is an indie roguelike where death isn't the end—it's a branching point. When your character dies, the universe splits into parallel timelines. Explore the consequences of different choices across multiple realities.

**Status:** 🎮 Beta Testing  
**Latest Version:** v0.1.0-beta  
**Engine:** Godot 4.2+  
**Platforms:** Windows, Linux, macOS

## Features

- 🎯 **Many Worlds Mechanic** - Death creates branching timelines
- 🎲 **Procedural Generation** - Unique levels each run
- ⚔️ **Combat System** - Fast-paced twin-stick shooter mechanics
- 🎨 **Pixel Art** - Retro-inspired visuals
- 🎵 **Atmospheric Audio** - Immersive soundscapes

## Download

### Latest Release: v0.1.0-beta

| Platform | Download | Size |
|----------|----------|------|
| **Windows** | [The Drift v0.1.0.exe](https://github.com/grimspyder/the-drift/releases/download/v0.1.0/The%20Drift%20v0.1.0.exe) | ~50MB |
| **Linux** | [the-drift-0.1.0.x86_64](https://github.com/grimspyder/the-drift/releases/download/v0.1.0/the-drift-0.1.0.x86_64) | ~48MB |
| **macOS** | [The Drift v0.1.0.dmg](https://github.com/grimspyder/the-drift/releases/download/v0.1.0/The%20Drift%20v0.1.0.dmg) | ~55MB |

Or play on [itch.io](https://grimspyder.itch.io/the-drift)

### System Requirements

**Windows 10+**
- 2GB RAM
- DirectX 11 GPU
- 100MB disk space

**Linux (Ubuntu 20.04+)**
- 2GB RAM
- OpenGL GPU
- 100MB disk space

**macOS 10.13+**
- 2GB RAM
- Metal GPU
- 100MB disk space

## How to Play

### Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | WASD / Arrow Keys | Left Stick |
| Shoot | Left Mouse Button | Right Trigger |
| Pause | ESC | Start |

### Gameplay Tips

1. **Survive** - Avoid enemy projectiles and defeat enemies
2. **Explore** - Each room has secrets and loot
3. **Die Strategically** - Your death branches the timeline
4. **Return to Worlds** - Re-enter previous timelines to discover new paths
5. **Reach the Exit** - Escape through the portal to beat the level

## Installation

### Windows
1. Download the `.exe` file
2. Run the installer
3. Launch from Start Menu

### Linux
```bash
# Make executable
chmod +x the-drift-0.1.0.x86_64

# Run
./the-drift-0.1.0.x86_64
```

### macOS
1. Download and mount the `.dmg` file
2. Drag "The Drift" to Applications folder
3. Launch from Launchpad

## Building from Source

### Requirements
- Godot 4.2+ (download from https://godotengine.org/)
- Git
- Platform-specific build tools

### Build

```bash
# Clone the repository
git clone https://github.com/grimspyder/the-drift.git
cd the-drift

# Set Godot path (if not in PATH)
export GODOT_BIN=/path/to/godot

# Build for your platform
./scripts/build.sh 0.1.0
```

For detailed build instructions, see [BUILD_INSTRUCTIONS.md](releases/BUILD_INSTRUCTIONS.md)

## Development

### Project Structure

```
the-drift/
├── src/                        # Source code
│   ├── Entities/              # Game objects (player, enemies, etc.)
│   ├── Game/                  # Main game scene
│   ├── UI/                    # User interface
│   ├── Levels/                # Level generation and management
│   └── Mechanics/             # Game mechanics (combat, death, etc.)
├── assets/                    # Sprites, sounds, fonts
├── autoload/                  # Global scripts
├── scripts/                   # Build and utility scripts
└── releases/                  # Build artifacts

```

### Key Systems

- **Player Controller** - Movement and shooting
- **Enemy AI** - Pathfinding and combat
- **Procedural Generation** - Dynamic level layout
- **Combat System** - Projectiles, damage, collisions
- **Many Worlds Mechanic** - Timeline branching and management

### Running in Godot Editor

```bash
# Open project in editor
godot --path . --editor

# Or run in-editor with F5
```

## Roadmap

- [x] Core mechanics implemented
- [x] Player controller
- [x] Enemy AI
- [x] Procedural generation
- [x] Combat system
- [x] Death/Many Worlds mechanic
- [ ] UI and menus
- [ ] Audio implementation
- [ ] Visual polish
- [ ] Level balancing
- [ ] Stable release

## Contributing

The Drift is currently in closed beta. To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -am 'Add feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## Bug Reports

Found a bug? Please report it on [GitHub Issues](https://github.com/grimspyder/the-drift/issues) with:
- Game version
- Platform/OS
- Steps to reproduce
- Screenshots/video if possible

## Feedback

We'd love to hear your thoughts!
- Discord: (link here)
- Email: (contact here)
- itch.io: https://grimspyder.itch.io/the-drift

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

**Created by:** John (Grim)

**Engine:** [Godot Engine](https://godotengine.org/) - Free & Open Source  
**Fonts:** (list fonts used)  
**Audio:** (list audio sources)  
**Inspiration:** Death's Door, Hades, Enter the Gungeon

## Support

If you enjoy The Drift, please consider:
- ⭐ Starring on GitHub
- 💬 Leaving a review on itch.io
- 🐛 Reporting bugs
- 💡 Suggesting features
- 🤝 Contributing code

## Changelog

### v0.1.0-beta (2026-02-06)
- Initial public beta release
- Core mechanics: player, enemies, procedural generation
- Many Worlds death mechanic
- Twin-stick shooter combat
- Linux, Windows, macOS support

---

**Play The Drift:** [GitHub Releases](https://github.com/grimspyder/the-drift/releases) | [itch.io](https://grimspyder.itch.io/the-drift)

**Follow Development:** [GitHub](https://github.com/grimspyder/the-drift)

Last Updated: 2026-02-06
