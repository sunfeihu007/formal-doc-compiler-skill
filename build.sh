#!/usr/bin/env bash
# build.sh — build dist/formal-doc-compiler-skill-<VERSION>.plugin from source.
#
# The repo root IS the plugin (single source of truth). This script just
# stages the plugin-relevant subset and zips it for clients that install
# from a .plugin file (Claude Cowork and other plugin-only clients).
#
# Usage: bash build.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
OUT="$ROOT/dist/formal-doc-compiler-skill-${VERSION}.plugin"

# Keep manifest versions in sync with VERSION
python3 - "$ROOT" "$VERSION" <<'PY'
import json, sys
from pathlib import Path
root, version = Path(sys.argv[1]), sys.argv[2]
for name, key_path in [("plugin.json", ("version",)),
                       ("marketplace.json", ("metadata", "version"))]:
    f = root / ".claude-plugin" / name
    data = json.loads(f.read_text(encoding="utf-8"))
    node = data
    for key in key_path[:-1]:
        node = node[key]
    if node.get(key_path[-1]) != version:
        node[key_path[-1]] = version
        f.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n",
                     encoding="utf-8")
        print(f"synced {name} version -> {version}")
PY

# Sanity: every skill must have a real frontmatter description
python3 - "$ROOT" <<'PY'
import sys
from pathlib import Path
root = Path(sys.argv[1])
bad = []
for skill_md in sorted(root.glob("skills/*/SKILL.md")):
    head = skill_md.read_text(encoding="utf-8").split("---")
    if len(head) < 3 or "description:" not in head[1] or "See body" in head[1]:
        bad.append(str(skill_md))
if bad:
    sys.exit("missing/placeholder frontmatter description in: " + ", ".join(bad))
print("frontmatter check OK")
PY

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/.claude-plugin"
cp "$ROOT/.claude-plugin/plugin.json" "$WORK/.claude-plugin/"
cp -R "$ROOT/commands" "$ROOT/skills" "$ROOT/scripts" "$ROOT/templates" "$WORK/"
cp "$ROOT/README.md" "$ROOT/CHANGELOG.md" "$ROOT/LICENSE" "$WORK/"
printf '# Connectors\n\nThis plugin does not require external connectors.\n' > "$WORK/CONNECTORS.md"

mkdir -p "$ROOT/dist"
rm -f "$ROOT"/dist/*.plugin
(cd "$WORK" && zip -qr "$OUT" . -x "*.DS_Store" -x "*__pycache__*")

echo "Built: $OUT"
unzip -l "$OUT" | tail -3
