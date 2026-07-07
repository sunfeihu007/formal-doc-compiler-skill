#!/usr/bin/env bash
# uninstall.sh — remove the bundle and its client integrations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGET="$HOME/agent-skills/formal-doc-compiler-skill"

echo "Removing bundle integrations…"

strip_block() {
    local f="$1"
    if [[ -f "$f" ]] && grep -qF "$MARKER_START" "$f"; then
        echo "  Cleaning $f"
        awk -v s="$MARKER_START" -v e="$MARKER_END" '
            $0 ~ s {skip=1; next}
            $0 ~ e {skip=0; next}
            !skip
        ' "$f" > "$f.new" && mv "$f.new" "$f"
    fi
}

# Codex
strip_block "$HOME/.codex/AGENTS.md"
strip_block "$HOME/.codex/instructions.md"
rm -f "$HOME/.codex/prompts/compile.md" "$HOME/.codex/prompts/archive.md"

# Antigravity
strip_block "$HOME/Library/Application Support/Antigravity/rules.md"
strip_block "$HOME/.config/antigravity/rules.md"

# Trae — project rules of the current directory (user rules live in Trae's
# settings UI; remove the block there manually)
strip_block "$PWD/.trae/rules/project_rules.md"

# Claude Code — plugin route
if command -v claude >/dev/null 2>&1; then
    claude plugin uninstall formal-doc-compiler-skill 2>/dev/null || true
    claude plugin marketplace remove formal-doc-compiler 2>/dev/null || true
fi

# Claude Code — skills-directory route
for name in formal-doc-compiler-skill file-triage compliance-check cn-formal-style; do
    rm -rf "$HOME/.claude/skills/$name"
done
rm -f "$HOME/.claude/commands/compile.md" "$HOME/.claude/commands/archive.md"

# Legacy symlink from old versions
rm -f "$HOME/.claude/plugins/formal-doc-compiler-skill"

# The bundle itself
if [[ -d "$TARGET" ]]; then
    echo "  Removing $TARGET"
    rm -rf "$TARGET"
fi

echo
echo "Uninstall complete."
echo "Notes:"
echo "  - Cowork plugins are removed from Cowork's Settings → Plugins UI."
echo "  - Plugin-only third-party clients: remove via that client's plugin UI."
echo "  - The optional venv at ~/.formal-doc-compiler-skill/ (deps + your global"
echo "    deliverable archive) was NOT deleted — remove manually if you want."
