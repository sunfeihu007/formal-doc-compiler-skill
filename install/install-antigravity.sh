#!/usr/bin/env bash
# install-antigravity.sh — wire the bundle into Antigravity rules

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGET="$HOME/agent-skills/formal-doc-compiler-skill"

echo "Bundle: $BUNDLE_ROOT"
echo "Target: $TARGET"

place_bundle "$BUNDLE_ROOT" "$TARGET"

# Find the rules file
RULES=""
for candidate in \
    "$HOME/Library/Application Support/Antigravity/rules.md" \
    "$HOME/.config/antigravity/rules.md"; do
    if [[ -d "$(dirname "$candidate")" ]]; then
        RULES="$candidate"
        break
    fi
done

if [[ -z "$RULES" ]]; then
    echo "Could not find an Antigravity config dir."
    echo "Please follow adapters/antigravity.md to locate yours and append manually."
    exit 1
fi

if [[ -f "$RULES" ]] && grep -qF "$MARKER_START" "$RULES"; then
    echo "Rules already contain the bundle block; skipping."
else
    emit_rules_block "$TARGET" >> "$RULES"
    echo "Appended bundle block to $RULES"
fi

install_python_deps

echo
echo "Antigravity install complete."
