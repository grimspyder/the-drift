# Build & Release Instructions for The Drift

## Overview

This document explains how to build and release The Drift across all supported platforms.

## Prerequisites

### For Local Building

1. **Godot 4.2+** - Download from https://godotengine.org/download
2. **Git** - For version control
3. **Platform-specific tools:**
   - **Windows:** Visual Studio Build Tools (for building on Windows)
   - **Linux:** GCC, build-essential
   - **macOS:** Xcode Command Line Tools (`xcode-select --install`)

### For itch.io Uploads

1. **butler** - Download from https://itch.io/app
2. itch.io account with game page already created

## Quick Start

### Local Build

```bash
# Set Godot binary path (if not in PATH)
export GODOT_BIN=/path/to/godot

# Build version 0.1.0
cd /path/to/the-drift
./scripts/build.sh 0.1.0

# Releases will be in ./releases/
```

### Windows-only Build

```bash
cd C:\path\to\the-drift
scripts\build.bat 0.1.0
```

## Release Workflow

### 1. Prepare Release

```bash
# Update version in relevant files
# - export_presets.cfg (if needed)
# - project.godot (if version tracking added)
# - README.md (update install instructions)

# Create release notes from template
cp releases/RELEASE_NOTES_TEMPLATE.md releases/RELEASE_NOTES_v0.1.0.md
# Edit RELEASE_NOTES_v0.1.0.md with actual changes
```

### 2. Build for All Platforms

```bash
# Run the build script
./scripts/build.sh 0.1.0

# This will:
# - Create releases/windows/the-drift-0.1.0/
# - Create releases/linux/the-drift-0.1.0/
# - Create releases/macos/the-drift-0.1.0/ (if on macOS)
```

### 3. Test Builds (Optional but Recommended)

```bash
# Windows
releases/windows/the-drift-0.1.0/The\ Drift.exe

# Linux
releases/linux/the-drift-0.1.0/the-drift.x86_64

# macOS
open releases/macos/the-drift-0.1.0/The\ Drift.app
```

### 4. Commit & Tag

```bash
git add -A
git commit -m "Release v0.1.0"
git tag -a v0.1.0 -m "Release v0.1.0: Initial Beta"
git push origin main
git push origin v0.1.0
```

### 5. Create GitHub Release

The GitHub Actions workflow will automatically:
1. Build all platforms when you push a version tag
2. Upload build artifacts
3. Create a GitHub Release with the artifacts

You can also manually create a release:
1. Go to GitHub repo → Releases → Draft New Release
2. Select your tag (e.g., v0.1.0)
3. Paste release notes
4. Upload build artifacts
5. Publish

### 6. Upload to itch.io (Optional)

```bash
# Requires butler installed and configured
./scripts/push-itch.sh 0.1.0 beta

# This will:
# - Push Windows build to grimspyder/the-drift:beta
# - Push Linux build to grimspyder/the-drift:beta
# - Push macOS build to grimspyder/the-drift:beta
# - Update game page with version
```

## Version Numbering

Use semantic versioning: `MAJOR.MINOR.PATCH-PRERELEASE`

Examples:
- `0.1.0-beta` - First beta
- `0.1.1-beta` - Beta bugfix
- `0.2.0-beta` - Beta with new features
- `1.0.0` - First stable release

## Release Channels

### itch.io Channels

- **beta** - Early access, pre-release builds
- **stable** - Stable, recommended for most players
- **dev** - Development builds, bleeding edge

Upload with:
```bash
./scripts/push-itch.sh 0.1.0 beta      # Upload to beta channel
./scripts/push-itch.sh 1.0.0 stable    # Upload to stable channel
```

## GitHub Actions CI/CD

The workflow in `.github/workflows/build.yml`:

- **Triggers:** 
  - Push to `main` branch
  - Tag pushes (v*)
  - Manual trigger (`workflow_dispatch`)

- **Actions:**
  - Builds on Linux, Windows, macOS
  - Uploads artifacts to GitHub Actions
  - Creates GitHub Release with assets (on tag push)

- **Artifacts:**
  - Retained for 7 days
  - Available via Actions tab

## Troubleshooting

### Godot not found
```bash
# Set GODOT_BIN to full path
export GODOT_BIN="/opt/godot/godot-4.2.1"
./scripts/build.sh 0.1.0
```

### Export fails
- Ensure project builds in Godot editor first
- Check `export_presets.cfg` is valid
- Verify all assets are properly imported

### Artifact upload fails (GitHub Actions)
- Check that build artifacts exist in `releases/` directory
- Verify file paths in workflow match actual outputs
- Check GitHub token has `repo` permission

### butler upload fails
- Ensure butler is installed: `butler -V`
- Create game page on itch.io first
- Check butler is authenticated: `butler login`

## File Structure

```
the-drift/
├── export_presets.cfg          # Godot export configuration
├── scripts/
│   ├── build.sh                # Main build script (Linux/macOS)
│   ├── build.bat               # Windows build script
│   └── push-itch.sh            # itch.io upload script
├── releases/                   # Release artifacts directory
│   ├── windows/
│   │   └── the-drift-0.1.0/
│   ├── linux/
│   │   └── the-drift-0.1.0/
│   ├── macos/
│   │   └── the-drift-0.1.0/
│   ├── RELEASE_NOTES_TEMPLATE.md
│   └── BUILD_INSTRUCTIONS.md
└── .github/workflows/
    └── build.yml               # GitHub Actions workflow
```

## Next Steps

1. ✅ Install Godot 4.2+
2. ✅ Test the build script: `./scripts/build.sh 0.1.0-test`
3. ✅ Verify releases are created properly
4. ✅ Set up itch.io game page (if using itch.io)
5. ✅ Create first release tag and push to GitHub
6. ✅ Monitor GitHub Actions build
7. ✅ Download and test artifacts

## Support

- GitHub Issues: https://github.com/grimspyder/the-drift/issues
- Godot Docs: https://docs.godotengine.org/en/stable/
- itch.io Butler: https://itch.io/docs/butler/

---

**Last Updated:** 2026-02-06  
**Maintained by:** DevOps Agent
