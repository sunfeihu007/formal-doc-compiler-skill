#!/usr/bin/env bash
# install-trae.sh — wire the bundle into Trae (ByteDance AI IDE).
#
# Trae reads rules from:
#   - user rules  (all projects)  — managed in Trae's settings UI
#   - project rules — <project>/.trae/rules/project_rules.md
#
# This script places the bundle, writes the project-level rules block for the
# CURRENT directory, and prints the same block for pasting into user rules.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGET="$HOME/agent-skills/formal-doc-compiler-skill"

echo "Bundle: $BUNDLE_ROOT"
echo "Target: $TARGET"

place_bundle "$BUNDLE_ROOT" "$TARGET"

# Project-level rules for the current directory (skip if we're inside the bundle itself)
PROJECT_DIR="$PWD"
if [[ "$PROJECT_DIR" -ef "$BUNDLE_ROOT" || "$PROJECT_DIR" -ef "$TARGET" ]]; then
    echo "Running inside the bundle itself — skipping project rules."
    echo "cd into your work project and re-run to add project-level rules."
else
    RULES="$PROJECT_DIR/.trae/rules/project_rules.md"
    mkdir -p "$(dirname "$RULES")"
    if [[ -f "$RULES" ]] && grep -qF "$MARKER_START" "$RULES"; then
        echo "Project rules already contain the bundle block; skipping."
    else
        emit_rules_block "$TARGET" >> "$RULES"
        echo "Appended bundle block to $RULES"
    fi
fi

install_python_deps

cat <<EOF

Trae install complete for this project.

To enable it for ALL projects, open Trae → Settings → Rules → User Rules
and paste this block:
$(emit_rules_block "$TARGET")
EOF
