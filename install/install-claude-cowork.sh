#!/usr/bin/env bash
# install-claude-cowork.sh — surface the .plugin file to the user
# (builds it from source first if dist/ is empty or stale)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

VERSION="$(tr -d '[:space:]' < "$BUNDLE_ROOT/VERSION")"
PLUGIN_FILE="$(newest_plugin_file "$BUNDLE_ROOT")"

if [[ -z "$PLUGIN_FILE" || "$PLUGIN_FILE" != *"$VERSION"* ]]; then
    echo "No up-to-date .plugin in dist/ — building from source…"
    bash "$BUNDLE_ROOT/build.sh"
    PLUGIN_FILE="$(newest_plugin_file "$BUNDLE_ROOT")"
fi

echo "Cowork install requires a manual step:"
echo
echo "    1. Open the plugin file:"
echo "       $PLUGIN_FILE"
echo
echo "    2. Cowork will display a card with a 'Save plugin' button."
echo "       Click it. Cowork registers everything automatically."
echo
echo "    3. Verify by starting a new conversation and typing /compile"
echo
echo "If you're running this from inside a Cowork-aware agent, ask it to"
echo "surface $PLUGIN_FILE with its file-presentation mechanism."
