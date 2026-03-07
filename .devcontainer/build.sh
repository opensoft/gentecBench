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
cd "$SCRIPT_DIR"

echo "Configuration:"
echo "  Tag: gentec-bench:latest (user-agnostic)"
echo ""

# Check if Layer 1c exists
if ! docker image inspect "biobench-base:latest" >/dev/null 2>&1; then
    echo "❌ Error: Layer 1c (biobench-base:latest) not found!"
    echo ""
    echo "Please build Layer 1c first:"
    echo "  cd ../../base-image"
    echo "  ./build.sh"
    exit 1
fi

# Build the image
echo "Building gentec-bench:latest..."
docker build \
    -t "gentec-bench:latest" \
    .

echo ""
echo "✓ Layer 2 built successfully!"
echo "  Image: gentec-bench:latest"
echo ""
echo "Next step: Layer 3 (user) is built automatically by ensure-layer3.sh"
echo "  when opening in VS Code, or manually:"
echo "  bash ../../scripts/ensure-layer3.sh --base gentec-bench:latest --chown /opt/conda"
