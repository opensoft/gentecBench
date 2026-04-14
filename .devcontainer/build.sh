#!/bin/bash
# Build script for Layer 2: gentec-bench
# Creates: gentec-bench:latest (user-agnostic)
#
# Usage:
#   ./build.sh

set -e

echo "=========================================="
echo "Building Layer 2: gentec-bench (user-agnostic)"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$REPO_DIR/scripts/lib/image-names.sh"
cd "$SCRIPT_DIR"

BASE_IMAGE="$(resolve_existing_image "$(family_base_image bio)" "$(legacy_family_base_image bio 2>/dev/null || true)" || true)"

echo "Configuration:"
echo "  Tag: gentec-bench:latest (user-agnostic)"
echo "  Base image: ${BASE_IMAGE:-$(family_base_image bio)}"
echo ""

# Check if Layer 1c exists
if [ -z "$BASE_IMAGE" ]; then
    echo "❌ Error: Layer 1c ($(family_base_image bio)) not found!"
    echo ""
    echo "Please build Layer 1c first:"
    echo "  cd ../../base-image"
    echo "  ./build.sh"
    exit 1
fi

# Build the image
echo "Building gentec-bench:latest..."
docker build \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    -t "gentec-bench:latest" \
    .

echo ""
echo "✓ Layer 2 built successfully!"
echo "  Image: gentec-bench:latest"
echo ""
echo "Next step: Layer 3 (user) is built automatically by ensure-layer3.sh"
echo "  when opening in VS Code, or manually:"
echo "  bash ../../scripts/ensure-layer3.sh --base gentec-bench:latest --chown /opt/conda"
