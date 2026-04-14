#!/bin/bash
# Build Layer 2 (gentec-bench)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/.devcontainer/build.sh"
