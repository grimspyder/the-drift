# The Drift - Development Guide

This guide covers development setup, building, and releasing The Drift.

## Quick Start

### Setup

```bash
# Clone the repository
git clone https://github.com/grimspyder/the-drift.git
cd the-drift

# Install Godot 4.2+ from https://godotengine.org/download
# (Make sure it's in your PATH or set GODOT_BIN)

# Open in editor
godot --path . --editor
```

### Development Workflow

```bash
# Work on code in the Godot editor
# Run with F5 in the editor for quick testing

# For local builds:
export GODOT_BIN=/path/to/godot  # if not in PATH
./scripts/build.sh 0.1.0-dev

# Push changes
git add src/ assets/ autoload/ project.godot
git commit -m "Feature: description"
git push origin main
```

## Build & Release Infrastructure

### Files Overview

```
the-drift/
├── export_presets.cfg              # Godot export configuration
│                                   # - Windows (x86_64)
│                                   # - Linux/X11 (x86_64) 
│                                   # - macOS (Universal)
│
├── scripts/
│   ├── build.sh                    # Build all platforms (Linux/macOS)
│   ├── build.bat                   # Build all platforms (Windows)
│   └── push-itch.sh                # Upload to itch.io with butler
│
├── releases/
│   ├── BUILD_INSTRUCTIONS.md       # Detailed build guide
│   ├── RELEASE_CHECKLIST.md        # Pre-release checklist
│   ├── RELEASE_NOTES_TEMPLATE.md   # Template for release notes
│   ├── ITCH_IO_PAGE_TEMPLATE.md    # itch.io page content
│   ├── windows/                    # Windows build artifacts
│   ├── linux/                      # Linux build artifacts
│   └── macos/                      # macOS build artifacts
│
└── .github/workflows/
    └── build.yml                   # GitHub Actions CI/CD
                                    # - Builds all platforms on tag
                                    # - Creates GitHub Release
                                    # - Uploads artifacts
```

### Export Presets

The `export_presets.cfg` file configures how Godot exports the game:

- **Windows Desktop** → `releases/windows/The Drift vX.X.X.exe`
- **Linux/X11** → `releases/linux/the-drift-X.X.X.x86_64`
- **macOS** → `releases/macos/The Drift.dmg`

Each preset:
- Uses Release mode (optimized, no debug code)
- Optimizes for size
- Excludes development files (.git, .md, etc.)
- Embeds binary metadata for crash reporting

### Build Scripts

#### Linux/macOS: `scripts/build.sh`

```bash
./scripts/build.sh 0.1.0        # Build version 0.1.0
./scripts/build.sh              # Build version 0.1.0-beta (default)
```

Features:
- Detects Godot binary automatically
- Creates platform-specific directories
- Packages builds with version numbers
- Makes Linux builds executable
- Handles macOS builds if on macOS
- Color-coded output

#### Windows: `scripts/build.bat`

```cmd
scripts\build.bat 0.1.0
```

Similar to shell script but for Windows batch environment.

#### itch.io Upload: `scripts/push-itch.sh`

```bash
./scripts/push-itch.sh 0.1.0 beta     # Upload v0.1.0 to beta channel
./scripts/push-itch.sh 1.0.0 stable   # Upload v1.0.0 to stable channel
```

Requires `butler` (download from https://itch.io/app)

### GitHub Actions Workflow

Triggers on:
- Push to `main` branch
- Tag push (v*)
- Manual trigger (`workflow_dispatch`)

Actions:
1. Download Godot 4.2.1
2. Export for Linux, Windows, macOS
3. Upload to GitHub Actions artifacts
4. On tag push: Create GitHub Release with builds as assets

View builds: GitHub → Actions tab

## Release Process

### Full Release Workflow

1. **Prepare Release**
   ```bash
   # Update version in files (if needed)
   # Update README.md, release notes
   # Commit changes
   git add -A
   git commit -m "Prepare release v0.1.0"
   ```

2. **Build Locally (Optional)**
   ```bash
   export GODOT_BIN=/path/to/godot
   ./scripts/build.sh 0.1.0
   # Test releases/*/the-drift-0.1.0/*
   ```

3. **Tag & Push**
   ```bash
   git tag -a v0.1.0 -m "Release v0.1.0"
   git push origin main
   git push origin v0.1.0
   ```

4. **Watch GitHub Actions**
   - Go to Actions tab
   - Wait for build to complete (~5-15 minutes)
   - Verify all platforms built successfully

5. **Create Release Note** (Automated or Manual)
   - GitHub Actions automatically creates release if available
   - Or manually: Go to Releases → Draft Release
   - Add RELEASE_NOTES_vX.X.X.md content
   - Attach artifacts if not already there
   - Publish

6. **Upload to itch.io** (Optional)
   ```bash
   ./scripts/push-itch.sh 0.1.0 beta
   ```

## Version Numbering

Use semantic versioning: `MAJOR.MINOR.PATCH[-PRERELEASE]`

Examples:
- `v0.1.0-beta` - First beta
- `v0.1.1-beta` - Beta bugfix  
- `v0.2.0-beta` - Beta with features
- `v1.0.0` - First stable release
- `v1.0.1` - Stability/bugfix patch
- `v1.1.0` - Minor feature release
- `v2.0.0` - Major release

For dev builds: `v0.1.0-dev-YYYYMMDD` or `v0.1.0-dev+SHA`

## Continuous Integration

### Automatic Builds

Every push to `main` triggers a build and uploads artifacts to Actions.

**Check builds:** GitHub → Actions → Latest workflow run

### Release Builds

Every tag matching `v*` triggers a full build and creates a GitHub Release.

**Process:**
```bash
git tag -a v0.1.0 -m "Release notes here"
git push origin v0.1.0
# Wait ~15 min → GitHub Release created automatically
```

## Troubleshooting

### Build fails locally

1. **Godot not found**
   ```bash
   export GODOT_BIN=/full/path/to/godot
   ./scripts/build.sh 0.1.0
   ```

2. **Project doesn't build in editor**
   - Open in Godot editor and check for errors
   - Fix any import/script errors
   - Try exporting directly from editor first

3. **Export fails for specific platform**
   - Check `export_presets.cfg` syntax
   - Ensure all assets exist and are imported
   - Try exporting from editor for that preset
   - Check Godot output console for specific errors

### GitHub Actions build fails

1. Check the Actions log for error details
2. Ensure `export_presets.cfg` is valid
3. Verify Godot version matches `GODOT_VERSION` in workflow
4. Check all assets are committed to git

### butler upload fails

```bash
# Check butler is installed
butler -V

# Login to itch.io
butler login

# Verify game page exists on itch.io
# Then try again
./scripts/push-itch.sh 0.1.0 beta
```

## Development Tools

### Recommended

- **Godot Editor** - Main IDE (Download from godotengine.org)
- **Git** - Version control
- **VS Code** - Code editor (with GDScript extension)
- **butler** - itch.io upload tool

### Optional

- **GIMP/Aseprite** - Sprite editing
- **Audacity** - Audio editing
- **Python** - Utilities/scripting

## Performance Targets

- **Target FPS:** 60 FPS on minimum spec hardware
- **Memory:** <500MB at runtime
- **Startup:** <5 seconds on SSD
- **Build time:** <2 minutes per platform (on decent hardware)

## Common Tasks

### Create Development Build

```bash
./scripts/build.sh 0.1.0-dev
# Creates releases/*/the-drift-0.1.0-dev/
```

### Package for itch.io

```bash
# Build first
./scripts/build.sh 0.2.0

# Upload to itch.io
./scripts/push-itch.sh 0.2.0 beta
```

### Create Release on GitHub

```bash
# Tag release
git tag -a v0.2.0 -m "v0.2.0: New features and bugfixes"
git push origin v0.2.0

# Wait for GitHub Actions to complete, then release appears automatically
```

### Run Locally with Godot

```bash
godot --path . --editor        # Open in editor
# or
godot --path .                 # Run directly
```

## Next Steps

1. Install Godot 4.2+
2. Run `./scripts/build.sh 0.1.0-test` to verify setup
3. Review `releases/BUILD_INSTRUCTIONS.md` for detailed instructions
4. Create itch.io game page for publishing
5. Set up CI/CD monitoring

## See Also

- [BUILD_INSTRUCTIONS.md](releases/BUILD_INSTRUCTIONS.md) - Detailed build guide
- [RELEASE_CHECKLIST.md](releases/RELEASE_CHECKLIST.md) - Release checklist
- [README.md](README.md) - Game overview
- [Godot Docs](https://docs.godotengine.org/) - Engine documentation
- [GitHub Workflow Docs](https://docs.github.com/en/actions) - CI/CD documentation

---

**Last Updated:** 2026-02-06  
**Maintained by:** DevOps Agent  
**Status:** Complete ✅
