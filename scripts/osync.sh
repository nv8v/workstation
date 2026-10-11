#!/usr/bin/env bash
# ==============================================================================
# Script: osync.sh
# Purpose: Bidirectional synchronization for Obsidian vault with OneDrive
# ==============================================================================

set -euo pipefail

LOCAL_DIR="${HOME}/Documents/Notes"
REMOTE_DIR="OneDrive:Obsidian"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Pre-execution checks
if ! command -v rclone >/dev/null 2>&1; then
    error "rclone is not installed or not in PATH."
    exit 1
fi

if [[ ! -d "$LOCAL_DIR" ]]; then
    mkdir -p "$LOCAL_DIR"
    info "Created local Obsidian notes directory at $LOCAL_DIR"
fi

# Guard against routine usage of --resync which risks overwriting changes
for arg in "$@"; do
    if [[ "$arg" == "--resync" ]]; then
        warn "CRITICAL: Routine synchronization must not use --resync to prevent data loss."
        warn "--resync should only be used when explicitly initializing or recovering the bisync database."
    fi
done

info "Starting Obsidian vault synchronization..."
info "Local:  ${LOCAL_DIR}"
info "Remote: ${REMOTE_DIR}"

# Execute bidirectional synchronization preserving passed arguments and exit code
rclone bisync "$LOCAL_DIR" "$REMOTE_DIR" "$@"
SYNC_STATUS=$?

if [[ $SYNC_STATUS -eq 0 ]]; then
    success "Obsidian synchronization completed successfully!"
else
    error "Obsidian synchronization encountered errors (exit code: ${SYNC_STATUS})."
fi

exit $SYNC_STATUS
