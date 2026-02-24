#!/bin/bash
# Setup script for gentecBench - Genetics & Genomics workbench
# Builds the gentecBench container image

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Ensure biobench-base image exists
if ! docker image inspect "biobench-base:$USERNAME" >/dev/null 2>&1; then
    echo "biobench-base:$USERNAME not found. Building base image..."
    if [ -x "$BIO_DIR/setup.sh" ]; then
        "$BIO_DIR/setup.sh" --user "$USERNAME"
    else
        echo "❌ Error: biobench-base:$USERNAME not found and no bioBenches/setup.sh available."
        echo "Please build the bio base image first."
        exit 1
    fi
fi

# Build the gentecBench image
echo "Building gentecBench image..."
docker compose -f "$SCRIPT_DIR/.devcontainer/docker-compose.yml" build

echo ""
echo "✓ gentecBench setup complete!"
echo "  Open in VS Code with Dev Containers to start working."
