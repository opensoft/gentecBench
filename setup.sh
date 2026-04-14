#!/bin/bash
# Setup script for gentecBench - Genetics & Genomics workbench
# Builds the gentecBench container image

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$BIO_DIR/.." && pwd)"
source "$REPO_DIR/scripts/lib/image-names.sh"

# Parse arguments
USERNAME=${1:-$(whoami)}
if [ "$USERNAME" = "--user" ]; then
    USERNAME="${2:-$(whoami)}"
fi

echo "=========================================="
echo "Setting up gentecBench"
echo "=========================================="
echo ""
echo "Configuration:"
echo "  Username: $USERNAME"
echo ""

# Ensure the Layer 1c base image exists
BASE_IMAGE="$(resolve_existing_image "$(family_base_image bio)" "$(legacy_family_base_image bio 2>/dev/null || true)" || true)"
if [ -z "$BASE_IMAGE" ]; then
    echo "$(family_base_image bio) not found. Building base image..."
    if [ -x "$BIO_DIR/setup.sh" ]; then
        "$BIO_DIR/setup.sh" --user "$USERNAME"
    else
        echo "❌ Error: $(family_base_image bio) not found and no bioBenches/setup.sh available."
        echo "Please build the bio base image first."
        exit 1
    fi
fi

if ! docker image inspect "gentec-bench:latest" >/dev/null 2>&1; then
    echo "Building gentecBench image..."
    "$SCRIPT_DIR/build-layer.sh" --user "$USERNAME"
else
    echo "Ensuring gentec-bench:$USERNAME..."
    "$REPO_DIR/scripts/ensure-layer3.sh" --base "gentec-bench:latest" --user "$USERNAME" --chown /opt/conda
fi

echo ""
echo "✓ gentecBench setup complete!"
echo "  Open in VS Code with Dev Containers to start working."
