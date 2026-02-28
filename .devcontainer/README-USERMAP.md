# Layer 4: User Mapping Architecture

## Overview

This directory contains two devcontainer configurations:

1. **Original (Layer 0-3)**: User baked into image at build time
2. **Layer 4 (User Mapping)**: User created dynamically at runtime

## Why Layer 4?

The Layer 4 approach solves a key problem: **image portability**.

### Traditional Approach (Layers 0-3)
- User is created during image build with specific UID/GID
- Image is tied to that user
- Cannot share images between workstations with different users
- Full rebuild required when switching users

### Layer 4 Approach
- Layers 0-3 built with generic user (or any user)
- Layer 4 adds an entrypoint script
- User is created/remapped at container **startup** based on environment variables
- Base images can be pushed to registry and shared
- Only Layer 4 needs customization per user (very fast to build)

## Architecture

```
Layer 0: workbench-base (Ubuntu, system tools, generic user)
    ↓
Layer 1c: biobench-base (Miniconda, scientific Python)
    ↓
Layer 2: gentec-bench (Bioinformatics tools, genetics packages)
    ↓
Layer 4: gentec-bench-usermap (Runtime user mapping)
```

## Files

- `Dockerfile.usermap` - Layer 4 Dockerfile (adds gosu + entrypoint)
- `entrypoint.sh` - Runtime script that creates/maps user
- `docker-compose.usermap.yml` - Compose config for Layer 4
- `devcontainer.usermap.json` - VSCode devcontainer config for Layer 4
- `build-usermap.sh` - Build script for Layer 4

## Usage

### Option 1: Use Existing Configuration (Layer 0-3)
Continue using the original setup:
- `devcontainer.json` → `docker-compose.yml` → `Dockerfile`
- User is built into the image

### Option 2: Switch to Layer 4 (User Mapping)
1. Build Layer 4:
   ```bash
   cd .devcontainer
   ./build-usermap.sh
   ```

2. Update `.devcontainer/devcontainer.json` to use Layer 4:
   - Rename `devcontainer.json` → `devcontainer.original.json`
   - Rename `devcontainer.usermap.json` → `devcontainer.json`

3. Rebuild devcontainer in VSCode

## Benefits of Layer 4

### For Single Workstation
- Faster rebuilds when changing users
- Cleaner separation of concerns

### For Multiple Workstations
- Build Layers 0-3 once, push to registry
- Pull base images on any workstation
- Only build tiny Layer 4 locally
- Different users on different machines work seamlessly

### For CI/CD
- Base images can be cached and reused
- No user-specific information in base layers
- Faster pipeline execution

## Screenshots Mount

Both configurations now include a mount for Windows screenshots:
- **Host**: `/mnt/c/Users/brett.heap/Pictures/Screenshots`
- **Container**: `/screenshots`
- **Environment Variable**: `WINDOWS_SCREENSHOTS` (optional override)

## Environment Variables

Layer 4 uses these environment variables (set automatically by docker-compose):
- `USERNAME` - Target username to create/map
- `USER_UID` - Target user ID
- `USER_GID` - Target group ID

## Technical Details

The entrypoint script (`entrypoint.sh`):
1. Reads target user/UID/GID from environment
2. Creates or renames group to match target GID
3. Creates or renames user to match target UID
4. Fixes ownership of critical directories (workspace, conda)
5. Uses `gosu` to switch to target user
6. Executes the container command as that user

This approach is safe, fast, and follows Docker best practices.
