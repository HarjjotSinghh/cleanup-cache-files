#!/usr/bin/env bash
# ======================================================
# Script Name: deep_cleanup.sh
# Description: Safely removes common cache, dependency,
#              and build artifact directories.
# Author: Harjot Singh Rana (@HarjjotSinghh)
# ======================================================

set -euo pipefail

# Default: current directory
TARGET_DIR="${1:-.}"

# Optional dry run mode
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
	DRY_RUN=true
	TARGET_DIR="${2:-.}"
elif [[ "${2:-}" == "--dry-run" ]]; then
	DRY_RUN=true
fi

# Common directory patterns to remove
CLEAN_DIRS=(
	# Generic caches
	"cache" ".cache" "__pycache__"
	# Node.js / frontend
	"node_modules" "build" ".next" ".nuxt" ".output" ".turbo"
	# Python
	"venv" ".venv"
	# Rust
	".cargo" "target"
	# Go
	"pkg" "bin" ".gocache"
)

echo "🧹 Starting deep cleanup in: $TARGET_DIR"
$DRY_RUN && echo "🔍 Dry run mode enabled — nothing will actually be deleted."
echo "-------------------------------------------------------------"

for DIR_NAME in "${CLEAN_DIRS[@]}"; do
	echo "🔎 Searching for '$DIR_NAME' directories..."
	FOUND_DIRS=$(find "$TARGET_DIR" -type d -name "$DIR_NAME" 2>/dev/null || true)

	if [[ -z "$FOUND_DIRS" ]]; then
		echo "❌ No '$DIR_NAME' directories found."
	else
		while IFS= read -r DIR; do
			if [[ -d "$DIR" ]]; then
				if $DRY_RUN; then
					echo "🟡 Would remove: $DIR"
				else
					echo "🗑️  Removing: $DIR"
					rm -rf "$DIR"
				fi
			fi
		done <<< "$FOUND_DIRS"
	fi
done

echo "✅ Cleanup complete!"
$DRY_RUN && echo "💡 Run without '--dry-run' to apply changes."
