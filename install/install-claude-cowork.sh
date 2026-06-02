#!/usr/bin/env bash
# install-claude-cowork.sh — surface the prebuilt .plugin to the user

set -euo pipefail

BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PLUGIN_FILE="$BUNDLE_ROOT/dist/compile-from-sources-0.2.0.plugin"

if [[ ! -f "$PLUGIN_FILE" ]]; then
    echo "Prebuilt .plugin not found at $PLUGIN_FILE"
    echo "Please follow adapters/claude-cowork.md Path C to build one from source."
    exit 1
fi

echo "Cowork install requires a manual step:"
echo
echo "    1. Open the prebuilt plugin file:"
echo "       $PLUGIN_FILE"
echo
echo "    2. Cowork will display a card with a 'Save plugin' button."
echo "       Click it. Cowork registers everything automatically."
echo
echo "    3. Verify by starting a new conversation and typing /compile"
echo
echo "If you're running this from inside a Cowork-aware agent, ask it to"
echo "call present_files on $PLUGIN_FILE to surface the card for you."
