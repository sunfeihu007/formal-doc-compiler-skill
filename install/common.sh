#!/usr/bin/env bash
# common.sh — shared helpers for the install scripts. Source, don't execute.

MARKER_START="# === formal-doc-compiler-skill skill bundle ==="
MARKER_END="# === end formal-doc-compiler-skill ==="

# emit_rules_block <bundle-target-path>
# The instructions block appended to AGENTS.md / rules files for clients
# that work off a system-prompt file. Single definition — keep the paths
# here and nowhere else.
emit_rules_block() {
    local target="$1"
    cat <<EOF


$MARKER_START

When the user asks to compile a formal document from source materials —
tender / RFP / 招标要求 / 方案 / 报告 / 白皮书 / proposal / white paper /
research brief / project summary — follow the 9-step workflow in:

  $target/skills/formal-doc-compiler-skill/SKILL.md

Sub-procedures (read on demand):
- File triage:           $target/skills/file-triage/SKILL.md
- Compliance scan:       $target/skills/compliance-check/SKILL.md
- Chinese typography:    $target/skills/cn-formal-style/SKILL.md
- Archive deliverable:   $target/commands/archive.md

Scanner: $target/scripts/scan.py
Wordlist template: $target/templates/wordlist-starter.yaml

Within any of those files, resolve \${BUNDLE_ROOT} to $target/

$MARKER_END
EOF
}

# place_bundle <bundle-root> <target-path>
place_bundle() {
    local src="$1" target="$2"
    if [[ -e "$target" ]] && [[ "$target" -ef "$src" ]]; then
        echo "Bundle already at $target"
        return
    fi
    if [[ -e "$target" ]]; then
        echo "Target exists; backing up to ${target}.bak.$$"
        mv "$target" "${target}.bak.$$"
    fi
    mkdir -p "$(dirname "$target")"
    cp -R "$src" "$target"
    echo "Bundle placed at $target"
}

# install_python_deps — best effort, safest strategy first.
# Order: already importable → pip --user → dedicated venv → manual note.
# Never uses --break-system-packages.
install_python_deps() {
    local deps=(pyyaml python-docx python-pptx openpyxl)
    if python3 -c "import yaml, docx, pptx, openpyxl" >/dev/null 2>&1; then
        echo "Python dependencies already available."
        return 0
    fi
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "pip3 not found — install Python deps manually: ${deps[*]}"
        return 0
    fi
    if pip3 install --user --quiet "${deps[@]}" 2>/dev/null; then
        echo "Installed Python deps with pip --user."
        return 0
    fi
    local venv="$HOME/.formal-doc-compiler-skill/venv"
    echo "System Python is externally managed; creating venv at $venv"
    if python3 -m venv "$venv" && "$venv/bin/pip" install --quiet "${deps[@]}"; then
        echo "Installed deps in $venv."
        echo "Run the scanner with: $venv/bin/python <bundle>/scripts/scan.py ..."
        return 0
    fi
    echo "Could not install Python deps automatically."
    echo "Install manually, e.g.:  python3 -m venv $venv && $venv/bin/pip install ${deps[*]}"
    return 0
}

# newest_plugin_file <bundle-root> — highest-version dist/*.plugin, if any
newest_plugin_file() {
    ls "$1"/dist/*.plugin 2>/dev/null | sort -V | tail -1
}
