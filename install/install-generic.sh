#!/usr/bin/env bash
# install-generic.sh — drop the bundle in ~/agent-skills/ and print instructions

set -euo pipefail

BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TARGET="$HOME/agent-skills/formal-doc-compiler-skill"

if [[ ! -e "$TARGET" ]] || ! [[ "$TARGET" -ef "$BUNDLE_ROOT" ]]; then
    [[ -e "$TARGET" ]] && mv "$TARGET" "${TARGET}.bak.$$"
    mkdir -p "$(dirname "$TARGET")"
    cp -R "$BUNDLE_ROOT" "$TARGET"
fi

if command -v pip3 >/dev/null 2>&1; then
    pip3 install --quiet pyyaml python-docx python-pptx openpyxl --break-system-packages 2>/dev/null \
        || pip3 install --quiet pyyaml python-docx python-pptx openpyxl \
        || echo "Could not install Python deps; please install manually."
fi

cat <<EOF

Bundle placed at: $TARGET

Next step depends on your client. See:
    $TARGET/adapters/generic.md

In short: tell your agent client to read
    $TARGET/instructions/compile.md
when the user asks to compile a formal document from source materials.

EOF
