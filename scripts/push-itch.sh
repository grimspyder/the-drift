#!/bin/bash
# Push builds to itch.io using butler
# Requires: butler (https://itch.io/app)
# Usage: ./push-itch.sh <version> [channel]

set -e

VERSION="${1:-0.1.0-beta}"
CHANNEL="${2:-beta}"
ITCH_USER="grimspyder"
ITCH_GAME="the-drift"
RELEASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/releases"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}The Drift - itch.io Upload${NC}"
echo -e "${GREEN}Version: ${VERSION}, Channel: ${CHANNEL}${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

# Check if butler is available
if ! command -v butler &> /dev/null; then
    echo -e "${RED}Error: butler not found${NC}"
    echo "Download butler from https://itch.io/app and add it to your PATH"
    exit 1
fi

echo -e "${YELLOW}Butler version:${NC}"
butler -V

# Function to push a build
push_build() {
    local platform="$1"
    local build_path="$2"
    local channel="${3:-${CHANNEL}}"
    
    if [ ! -d "${build_path}" ]; then
        echo -e "${YELLOW}⊘ ${platform} build not found at ${build_path}${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Pushing ${platform} to itch.io (${ITCH_USER}/${ITCH_GAME}:${channel})...${NC}"
    
    butler push "${build_path}" "${ITCH_USER}/${ITCH_GAME}:${channel}" --userversion="${VERSION}" || {
        echo -e "${RED}Failed to push ${platform}${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ ${platform} pushed successfully${NC}"
}

echo ""
echo -e "${YELLOW}Starting itch.io upload...${NC}"
echo ""

# Upload all platforms
UPLOADED=0

if push_build "Windows" "${RELEASE_DIR}/windows/the-drift-${VERSION}" "${CHANNEL}"; then
    UPLOADED=$((UPLOADED + 1))
fi

if push_build "Linux" "${RELEASE_DIR}/linux/the-drift-${VERSION}" "${CHANNEL}"; then
    UPLOADED=$((UPLOADED + 1))
fi

if push_build "macOS" "${RELEASE_DIR}/macos/the-drift-${VERSION}" "${CHANNEL}"; then
    UPLOADED=$((UPLOADED + 1))
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}Upload Complete!${NC}"
echo -e "${GREEN}Platforms uploaded: ${UPLOADED}${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "View your game on itch.io:"
echo "https://itch.io/${ITCH_USER}/${ITCH_GAME}"
echo ""
