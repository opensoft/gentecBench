#!/bin/bash
# Build script for Layer 4: User Mapping Layer
# Creates: gentec-bench-usermap:latest
# This script intelligently rebuilds all required layers if missing

set -e

echo "=========================================="
echo "Smart Build: Layer 4 User Mapping"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BIO_BASE_DIR="$(cd "$BENCH_DIR/../base-image" && pwd)"
WORKBENCH_BASE_DIR="$(cd "$BENCH_DIR/../../base-image" && pwd)"
REPO_DIR="$(cd "$BENCH_DIR/../.." && pwd)"
source "$REPO_DIR/scripts/lib/image-names.sh"

# Parse arguments
USERNAME=${1:-$(whoami)}
if [ "$USERNAME" = "--user" ]; then
    USERNAME="${2:-$(whoami)}"
fi

echo "Configuration:"
echo "  Username: $USERNAME"
echo ""

# Function to check if an image exists
image_exists() {
    docker image inspect "$1" >/dev/null 2>&1
}

# Function to build a layer
build_layer() {
    local layer_name="$1"
    local layer_dir="$2"
    local build_script="$3"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Building: $layer_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd "$layer_dir"
    bash "$build_script" --user "$USERNAME"
    echo ""
}

# Check and build Layer 0: workbench-base
if ! image_exists "workbench-base:latest"; then
    echo "⚠️  Layer 0 (workbench-base:latest) not found. Building..."
    echo ""
    build_layer "Layer 0: workbench-base" "$WORKBENCH_BASE_DIR" "build.sh"
else
    echo "✓ Layer 0: workbench-base:latest exists"
fi

# Check and build Layer 1c: bio-bench-base
if ! image_exists "$(family_base_image bio)"; then
    echo "⚠️  Layer 1c ($(family_base_image bio)) not found. Building..."
    echo ""
    build_layer "Layer 1c: $(family_base_image bio)" "$BIO_BASE_DIR" "build.sh"
else
    echo "✓ Layer 1c: $(family_base_image bio) exists"
fi

# Check and build Layer 2: gentec-bench
GENTEC_IMAGE="gentec-bench:latest"
if ! image_exists "$GENTEC_IMAGE"; then
    echo "⚠️  Layer 2 ($GENTEC_IMAGE) not found. Building..."
    echo ""
    build_layer "Layer 2: gentec-bench" "$SCRIPT_DIR" "build.sh"
else
    echo "✓ Layer 2: $GENTEC_IMAGE exists"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building: Layer 4 (User Mapping)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$SCRIPT_DIR"

# Build the user mapping layer
echo "Building gentec-bench-usermap:latest from $GENTEC_IMAGE..."
docker build \
    --build-arg BASE_IMAGE=$GENTEC_IMAGE \
    -f Dockerfile.usermap \
    -t "gentec-bench-usermap:latest" \
    .

echo ""
echo "=========================================="
echo "✓ All layers built successfully!"
echo "=========================================="
echo ""
echo "Image hierarchy:"
echo "  Layer 0: workbench-base:latest"
echo "  Layer 1c: $(family_base_image bio)"
echo "  Layer 2: $GENTEC_IMAGE"
echo "  Layer 4: gentec-bench-usermap:latest"
echo ""
echo "This Layer 4 image adds runtime user mapping to gentec-bench."
echo ""
echo "Next steps:"
echo "  1. Update devcontainer.json to use docker-compose.usermap.yml"
echo "  2. Rebuild your devcontainer in VSCode"
echo ""
echo "Benefits:"
echo "  • Base images (Layers 0-2) can be built once and pushed to registry"
echo "  • Only Layer 4 needs to be rebuilt for different users"
echo "  • Fast container startup with dynamic user creation"
