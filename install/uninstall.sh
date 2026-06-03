#!/usr/bin/env bash
# uninstall.sh — remove the bundle and its client integrations

set -euo pipefail

TARGET="$HOME/agent-skills/formal-doc-compiler-skill"
MARKER_START="# === formal-doc-compiler-skill skill bundle ==="
MARKER_END="# === end formal-doc-compiler-skill ==="

echo "Removing bundle integrations…"

# Codex
for f in "$HOME/.codex/AGENTS.md" "$HOME/.codex/instructions.md"; do
    if [[ -f "$f" ]] && grep -qF "$MARKER_START" "$f"; then
        echo "  Cleaning $f"
        # Delete lines between (and including) the markers
        awk -v s="$MARKER_START" -v e="$MARKER_END" '
            $0 ~ s {skip=1; next}
            $0 ~ e {skip=0; next}
            !skip
        ' "$f" > "$f.new" && mv "$f.new" "$f"
    fi
done
rm -f "$HOME/.codex/prompts/compile.md" "$HOME/.codex/prompts/archive.md"

# Antigravity
for f in \
    "$HOME/Library/Application Support/Antigravity/rules.md" \
    "$HOME/.config/antigravity/rules.md"; do
    if [[ -f "$f" ]] && grep -qF "$MARKER_START" "$f"; then
        echo "  Cleaning $f"
        awk -v s="$MARKER_START" -v e="$MARKER_END" '
            $0 ~ s {skip=1; next}
            $0 ~ e {skip=0; next}
            !skip
        ' "$f" > "$f.new" && mv "$f.new" "$f"
    fi
done

# Claude Code plugin
if command -v claude >/dev/null 2>&1; then
    claude plugin uninstall formal-doc-compiler-skill 2>/dev/null || true
fi

# Symlinks
rm -f "$HOME/.claude/plugins/formal-doc-compiler-skill"

# The bundle itself
if [[ -d "$TARGET" ]]; then
    echo "  Removing $TARGET"
    rm -rf "$TARGET"
fi

echo
echo "Uninstall complete."
echo "Note: Cowork plugins must be removed from Cowork's Settings → Plugins UI."
