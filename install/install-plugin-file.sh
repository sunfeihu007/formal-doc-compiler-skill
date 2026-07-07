#!/usr/bin/env bash
# install-plugin-file.sh — for third-party clients that install
# Claude-format .plugin files. Builds (if needed) and prints the file path;
# the user hands the file to their client's plugin-import UI.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="${BUNDLE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

VERSION="$(tr -d '[:space:]' < "$BUNDLE_ROOT/VERSION")"
PLUGIN_FILE="$(newest_plugin_file "$BUNDLE_ROOT")"

if [[ -z "$PLUGIN_FILE" || "$PLUGIN_FILE" != *"$VERSION"* ]]; then
    echo "No up-to-date .plugin in dist/ — building from source…"
    bash "$BUNDLE_ROOT/build.sh"
    PLUGIN_FILE="$(newest_plugin_file "$BUNDLE_ROOT")"
fi

echo
echo "Plugin file ready:"
echo "    $PLUGIN_FILE"
echo
echo "Import it with your client's plugin mechanism (import / open / drag-drop)."
echo "The zip layout is the Claude plugin format:"
echo "    .claude-plugin/plugin.json, skills/*/SKILL.md, commands/*.md,"
echo "    scripts/, templates/"
echo
echo "After import, the client should recognize the skills:"
echo "    formal-doc-compiler-skill, file-triage, compliance-check, cn-formal-style"
echo "and the commands /compile and /archive (if the client supports commands)."
