#!/usr/bin/env bash
# install-antigravity.sh — wire the bundle into Antigravity rules

set -euo pipefail

BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TARGET="$HOME/agent-skills/compile-from-sources"

echo "Bundle: $BUNDLE_ROOT"
echo "Target: $TARGET"

# Place the bundle
if [[ ! -e "$TARGET" ]] || ! [[ "$TARGET" -ef "$BUNDLE_ROOT" ]]; then
    [[ -e "$TARGET" ]] && mv "$TARGET" "${TARGET}.bak.$$"
    mkdir -p "$(dirname "$TARGET")"
    cp -R "$BUNDLE_ROOT" "$TARGET"
fi

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

mkdir -p "$(dirname "$RULES")"
MARKER_START="# === compile-from-sources skill bundle ==="
MARKER_END="# === end compile-from-sources ==="

if [[ -f "$RULES" ]] && grep -qF "$MARKER_START" "$RULES"; then
    echo "Rules already contain the bundle block; skipping."
else
    cat >> "$RULES" <<EOF


$MARKER_START

When the user asks to compile a formal document from source materials
(tender / RFP / 招标要求 / 方案 / 报告 / 白皮书 / proposal / white paper
/ research brief / project summary), follow the 9-step workflow in
$TARGET/instructions/compile.md.

Sub-procedures (read on demand):
- File triage:           $TARGET/instructions/file-triage.md
- Compliance scan:       $TARGET/instructions/compliance-check.md
- Chinese typography:    $TARGET/instructions/cn-formal-style.md
- Archive deliverable:   $TARGET/instructions/archive.md

Scanner: $TARGET/scripts/scan.py
Wordlist template: $TARGET/templates/wordlist-starter.yaml

Resolve \${BUNDLE_ROOT} to $TARGET/

$MARKER_END
EOF
    echo "Appended bundle block to $RULES"
fi

# Python deps
if command -v pip3 >/dev/null 2>&1; then
    pip3 install --quiet pyyaml python-docx python-pptx openpyxl --break-system-packages 2>/dev/null \
        || pip3 install --quiet pyyaml python-docx python-pptx openpyxl \
        || echo "Could not install Python deps; please install manually."
fi

echo
echo "Antigravity install complete."
