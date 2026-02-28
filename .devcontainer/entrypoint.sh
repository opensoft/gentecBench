#!/bin/bash
# Entrypoint script for Layer 4: Runtime user mapping
# Creates or updates user to match host UID/GID at container startup

set -e

# Get target user info from environment (set by docker-compose)
TARGET_USER="${USERNAME:-vscode}"
TARGET_UID="${USER_UID:-1000}"
TARGET_GID="${USER_GID:-1000}"

echo "🔧 Layer 4: Configuring user mapping..."
echo "  Target user: $TARGET_USER (UID=$TARGET_UID, GID=$TARGET_GID)"

# Create or update group
if getent group "$TARGET_GID" >/dev/null 2>&1; then
    EXISTING_GROUP=$(getent group "$TARGET_GID" | cut -d: -f1)
    if [ "$EXISTING_GROUP" != "$TARGET_USER" ]; then
        echo "  Renaming group $EXISTING_GROUP -> $TARGET_USER"
        groupmod -n "$TARGET_USER" "$EXISTING_GROUP"
    fi
else
    echo "  Creating group: $TARGET_USER (GID=$TARGET_GID)"
    groupadd --gid "$TARGET_GID" "$TARGET_USER"
fi

# Create or update user
if getent passwd "$TARGET_UID" >/dev/null 2>&1; then
    EXISTING_USER=$(getent passwd "$TARGET_UID" | cut -d: -f1)
    if [ "$EXISTING_USER" != "$TARGET_USER" ]; then
        echo "  Renaming user $EXISTING_USER -> $TARGET_USER"
        usermod -l "$TARGET_USER" -d "/home/$TARGET_USER" -m "$EXISTING_USER" 2>/dev/null || true
        usermod -g "$TARGET_USER" "$TARGET_USER" 2>/dev/null || true
    fi
elif ! getent passwd "$TARGET_USER" >/dev/null 2>&1; then
    echo "  Creating user: $TARGET_USER (UID=$TARGET_UID)"
    useradd --uid "$TARGET_UID" --gid "$TARGET_GID" \
        --home-dir "/home/$TARGET_USER" \
        --create-home \
        --shell /bin/zsh \
        "$TARGET_USER"
fi

# Fix ownership of critical directories if they exist
echo "  Fixing ownership for mounted directories..."
[ -d "/workspace" ] && chown -R "$TARGET_UID:$TARGET_GID" "/workspace" 2>/dev/null || true
[ -d "/home/$TARGET_USER" ] && chown -R "$TARGET_UID:$TARGET_GID" "/home/$TARGET_USER" 2>/dev/null || true

# Ensure conda is accessible (if it exists)
if [ -d "/opt/conda" ]; then
    echo "  Ensuring conda access for $TARGET_USER..."
    chown -R "$TARGET_UID:$TARGET_GID" "/opt/conda" 2>/dev/null || true
fi

echo "✓ User mapping complete"
echo ""

# Switch to target user and execute the command
exec gosu "$TARGET_USER" "$@"
