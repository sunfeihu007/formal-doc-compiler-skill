#!/usr/bin/env bash
# install-claude-code.sh — install into Claude Code.
#
# Route A: register this repo as a local plugin marketplace, install from it.
#          (claude plugin install only accepts marketplace plugins — it does
#          NOT accept a .plugin file path.)
# Route B: no claude CLI / route A failed — copy skills into ~/.claude/skills/
#          and commands into ~/.claude/commands/, with the full bundle at
#          ~/agent-skills/formal-doc-compiler-skill for ${BUNDLE_ROOT} paths.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

MARKETPLACE_NAME="formal-doc-compiler"
PLUGIN_NAME="formal-doc-compiler-skill"

if command -v claude >/dev/null 2>&1; then
    echo "Route A: installing via Claude Code plugin marketplace…"
    claude plugin marketplace add "$BUNDLE_ROOT" 2>/dev/null \
        || echo "(marketplace may already be registered — continuing)"
    if claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}"; then
        echo
        echo "Installed. Verify with: claude plugin list"
        echo "Then try /compile in a new session."
        install_python_deps
        exit 0
    fi
    echo "Route A failed; falling back to skills-directory install."
fi

echo "Route B: copying skills into ~/.claude/skills/ …"
TARGET="$HOME/agent-skills/$PLUGIN_NAME"
place_bundle "$BUNDLE_ROOT" "$TARGET"

mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands"
for skill_dir in "$TARGET"/skills/*/; do
    name="$(basename "$skill_dir")"
    rm -rf "$HOME/.claude/skills/$name"
    cp -R "$skill_dir" "$HOME/.claude/skills/$name"
    echo "  skill: $name"
done
for cmd in "$TARGET"/commands/*.md; do
    cp "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
    echo "  command: /$(basename "$cmd" .md)"
done

install_python_deps

echo
echo "Installed via skills directory."
echo "Within skill files, \${BUNDLE_ROOT} = $TARGET"
echo "Try /compile in a new Claude Code session."
