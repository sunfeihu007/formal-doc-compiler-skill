#!/usr/bin/env bash
# install-claude-code.sh — install via claude CLI, with symlink fallback
set -euo pipefail

BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PLUGIN_FILE="$BUNDLE_ROOT/dist/formal-doc-compiler-skill-0.2.0.plugin"

echo "Bundle: $BUNDLE_ROOT"

if [[ -f "$PLUGIN_FILE" ]] && command -v claude >/dev/null 2>&1; then
    echo "Installing via claude CLI…"
    if claude plugin install "$PLUGIN_FILE"; then
        echo "Installed. List with: claude plugin list"
        exit 0
    fi
    echo "claude plugin install failed; falling back to symlink."
fi

# Fallback: symlink the dist .plugin extracted form into ~/.claude/plugins/
echo "Symlink fallback not yet implemented for raw bundle — please follow adapters/claude-code.md Path C."
exit 1
