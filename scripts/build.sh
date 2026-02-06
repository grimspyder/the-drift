#!/bin/bash
# Build script for The Drift - Godot 4.x
# Automates export process for all platforms

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-0.1.0-beta}"
BUILD_DATE=$(date +%Y%m%d-%H%M%S)
RELEASE_DIR="${PROJECT_ROOT}/releases"
GODOT_BIN="${GODOT_BIN:-godot}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}The Drift - Build System${NC}"
echo -e "${GREEN}Version: ${VERSION}${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

# Check if Godot is available
if ! command -v ${GODOT_BIN} &> /dev/null; then
    echo -e "${RED}Error: Godot binary not found at '${GODOT_BIN}'${NC}"
    echo "Set GODOT_BIN environment variable to the path of your Godot 4.x executable"
    exit 1
fi

echo -e "${YELLOW}Godot binary: ${GODOT_BIN}${NC}"

# Create release directory structure
mkdir -p "${RELEASE_DIR}/windows"
mkdir -p "${RELEASE_DIR}/linux"
mkdir -p "${RELEASE_DIR}/macos"

# Function to export a preset
export_preset() {
    local preset_name="$1"
    local platform="$2"
    
    echo -e "${YELLOW}Exporting ${preset_name}...${NC}"
    
    cd "${PROJECT_ROOT}"
    
    # Use Godot headless export
    ${GODOT_BIN} --headless --export-release "${preset_name}" 2>&1 || {
        echo -e "${RED}Export failed for ${preset_name}${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ ${preset_name} exported successfully${NC}"
}

# Export for all platforms
echo ""
echo -e "${YELLOW}Starting multi-platform build...${NC}"
echo ""

if export_preset "Windows Desktop" "windows"; then
    # Create Windows release package
    WINDOWS_DIR="${RELEASE_DIR}/windows/the-drift-${VERSION}"
    mkdir -p "${WINDOWS_DIR}"
    cp "${RELEASE_DIR}/windows/"*.exe "${WINDOWS_DIR}/" 2>/dev/null || true
    echo -e "${GREEN}✓ Windows build packaged${NC}"
fi

if export_preset "Linux/X11" "linux"; then
    # Create Linux release package
    LINUX_DIR="${RELEASE_DIR}/linux/the-drift-${VERSION}"
    mkdir -p "${LINUX_DIR}"
    cp "${RELEASE_DIR}/linux/"*.x86_64 "${LINUX_DIR}/" 2>/dev/null || true
    chmod +x "${LINUX_DIR}"/* 2>/dev/null || true
    echo -e "${GREEN}✓ Linux build packaged${NC}"
fi

# macOS is optional (requires macOS host)
if command -v xcodebuild &> /dev/null; then
    if export_preset "macOS" "macos"; then
        MACOS_DIR="${RELEASE_DIR}/macos/the-drift-${VERSION}"
        mkdir -p "${MACOS_DIR}"
        cp "${RELEASE_DIR}/macos/"*.dmg "${MACOS_DIR}/" 2>/dev/null || true
        echo -e "${GREEN}✓ macOS build packaged${NC}"
    fi
else
    echo -e "${YELLOW}⊘ macOS export skipped (requires macOS host)${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}Build Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "Release artifacts:"
find "${RELEASE_DIR}" -type f \( -name "*.exe" -o -name "*.x86_64" -o -name "*.dmg" \) 2>/dev/null | sort

echo ""
echo "Releases directory: ${RELEASE_DIR}"
echo ""
