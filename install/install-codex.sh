#!/usr/bin/env bash
# install-codex.sh — wire the bundle into ~/.codex/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGET="$HOME/agent-skills/formal-doc-compiler-skill"

echo "Bundle: $BUNDLE_ROOT"
echo "Target: $TARGET"

# Step 1 — place bundle in stable location
place_bundle "$BUNDLE_ROOT" "$TARGET"

# Step 2 — append to ~/.codex/AGENTS.md
mkdir -p "$HOME/.codex"
AGENTS="$HOME/.codex/AGENTS.md"

if [[ -f "$AGENTS" ]] && grep -qF "$MARKER_START" "$AGENTS"; then
    echo "AGENTS.md already contains the bundle block; skipping."
else
    emit_rules_block "$TARGET" >> "$AGENTS"
    echo "Appended bundle block to $AGENTS"
fi

# Step 3 — install slash commands
mkdir -p "$HOME/.codex/prompts"

cat > "$HOME/.codex/prompts/compile.md" <<EOF
Read $TARGET/skills/formal-doc-compiler-skill/SKILL.md and follow it step by step.

If the user passed arguments, treat them as:
- First arg: source folder path
- Second arg: doc type (tender / proposal / whitepaper / brief / summary)

Resolve \${BUNDLE_ROOT} to $TARGET/
EOF

cat > "$HOME/.codex/prompts/archive.md" <<EOF
Read $TARGET/commands/archive.md and follow it step by step
(ignore the YAML frontmatter at the top — it's for other clients).

If the user passed a file path argument, use that as the deliverable to
archive. Otherwise look for the most recent deliverable in the conversation.

Resolve \${BUNDLE_ROOT} to $TARGET/
EOF

echo "Installed prompts: /compile, /archive"

# Step 4 — Python deps
install_python_deps

echo
echo "Codex install complete."
echo "Try it: start a Codex session and type /compile (or just ask to compile a folder)."
