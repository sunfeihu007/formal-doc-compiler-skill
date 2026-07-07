#!/usr/bin/env bash
# install-generic.sh — drop the bundle in ~/agent-skills/ and print instructions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGET="$HOME/agent-skills/formal-doc-compiler-skill"

place_bundle "$BUNDLE_ROOT" "$TARGET"
install_python_deps

cat <<EOF

Bundle placed at: $TARGET

Next step depends on your client. See:
    $TARGET/adapters/generic.md

In short: add this to your client's custom instructions / system prompt:
$(emit_rules_block "$TARGET")
EOF
