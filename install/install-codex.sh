#!/usr/bin/env bash
# install-codex.sh — wire the bundle into ~/.codex/

set -euo pipefail

BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TARGET="$HOME/agent-skills/compile-from-sources"

echo "Bundle: $BUNDLE_ROOT"
echo "Target: $TARGET"

# Step 1 — place bundle in stable location
if [[ -e "$TARGET" ]]; then
    if [[ "$TARGET" -ef "$BUNDLE_ROOT" ]]; then
        echo "Bundle already at $TARGET"
    else
        echo "Target exists and is different; backing up to ${TARGET}.bak.$$"
        mv "$TARGET" "${TARGET}.bak.$$"
        mkdir -p "$(dirname "$TARGET")"
        cp -R "$BUNDLE_ROOT" "$TARGET"
    fi
else
    mkdir -p "$(dirname "$TARGET")"
    cp -R "$BUNDLE_ROOT" "$TARGET"
fi

# Step 2 — append to ~/.codex/AGENTS.md
mkdir -p "$HOME/.codex"
AGENTS="$HOME/.codex/AGENTS.md"
MARKER_START="# === compile-from-sources skill bundle ==="
MARKER_END="# === end compile-from-sources ==="

if [[ -f "$AGENTS" ]] && grep -qF "$MARKER_START" "$AGENTS"; then
    echo "AGENTS.md already contains the bundle block; skipping."
else
    cat >> "$AGENTS" <<EOF


$MARKER_START

When the user asks to compile a formal document from source materials —
tender / RFP / 招标要求 / 方案 / 报告 / 白皮书 / proposal / white paper /
research brief / project summary — follow the 9-step workflow in:

  $TARGET/instructions/compile.md

Sub-procedures (read on demand):
- File triage:        $TARGET/instructions/file-triage.md
- Compliance scan:    $TARGET/instructions/compliance-check.md
- Chinese typography: $TARGET/instructions/cn-formal-style.md
- Archive:            $TARGET/instructions/archive.md

Scanner: $TARGET/scripts/scan.py
Wordlist template: $TARGET/templates/wordlist-starter.yaml

Resolve \${BUNDLE_ROOT} to $TARGET/

$MARKER_END
EOF
    echo "Appended bundle block to $AGENTS"
fi

# Step 3 — install slash commands
mkdir -p "$HOME/.codex/prompts"

cat > "$HOME/.codex/prompts/compile.md" <<EOF
Read $TARGET/instructions/compile.md and follow it step by step.

If the user passed arguments, treat them as:
- First arg: source folder path
- Second arg: doc type (tender / proposal / whitepaper / brief / summary)

Resolve \${BUNDLE_ROOT} to $TARGET/
EOF

cat > "$HOME/.codex/prompts/archive.md" <<EOF
Read $TARGET/instructions/archive.md and follow it step by step.

If the user passed a file path argument, use that as the deliverable to
archive. Otherwise look for the most recent deliverable in the conversation.

Resolve \${BUNDLE_ROOT} to $TARGET/
EOF

echo "Installed prompts: /compile, /archive"

# Step 4 — Python deps
if command -v pip3 >/dev/null 2>&1; then
    echo "Installing Python dependencies (pyyaml, python-docx, python-pptx, openpyxl)…"
    pip3 install --quiet pyyaml python-docx python-pptx openpyxl --break-system-packages 2>/dev/null \
        || pip3 install --quiet pyyaml python-docx python-pptx openpyxl \
        || echo "Could not install Python deps; please install manually."
fi

echo
echo "Codex install complete."
echo "Try it: start a Codex session and type /compile (or just ask to compile a folder)."
