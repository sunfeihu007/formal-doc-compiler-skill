#!/usr/bin/env bash
# install.sh — top-level installer for formal-doc-compiler-skill bundle
#
# Usage:
#   bash install/install.sh                  # auto-detect client
#   bash install/install.sh codex            # force client
#   bash install/install.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

detect_clients() {
    # Print ALL plausible clients, one per line — the caller decides.
    if [[ -d "$HOME/Library/Application Support/Claude/local-agent-mode-sessions" ]]; then
        echo "claude-cowork"
    fi
    if command -v claude >/dev/null 2>&1 || [[ -d "$HOME/.claude" ]]; then
        echo "claude-code"
    fi
    if command -v codex >/dev/null 2>&1 || [[ -d "$HOME/.codex" ]]; then
        echo "codex"
    fi
    if [[ -d "$HOME/.config/antigravity" ]] || [[ -d "$HOME/Library/Application Support/Antigravity" ]]; then
        echo "antigravity"
    fi
    if [[ -d "./.trae" ]] || [[ -d "$HOME/Library/Application Support/Trae" ]] \
        || [[ -d "$HOME/Library/Application Support/Trae CN" ]]; then
        echo "trae"
    fi
}

usage() {
    cat <<EOF
Usage:
    bash install/install.sh [<client>]

Clients:
    claude-code     Claude Code CLI (plugin marketplace, with skills-dir fallback)
    claude-cowork   Claude desktop app (Cowork mode) — .plugin file
    codex           OpenAI Codex CLI — AGENTS.md + prompts
    trae            Trae IDE (ByteDance) — .trae/rules + user rules
    antigravity     Google Antigravity IDE — rules file
    plugin-file     Any client that installs Claude-format .plugin files
    generic         Anything else — bundle + manual wiring

If no client is given, the script tries to detect one from your environment.
If several are detected, you'll be asked to pick.

Bundle location: $BUNDLE_ROOT
EOF
}

main() {
    local client="${1:-}"

    if [[ "$client" == "--help" || "$client" == "-h" ]]; then
        usage; exit 0
    fi

    if [[ -z "$client" ]]; then
        local detected=()
        while IFS= read -r line; do [[ -n "$line" ]] && detected+=("$line"); done < <(detect_clients)

        if [[ ${#detected[@]} -eq 0 ]]; then
            echo "Could not auto-detect a client."
            usage
            exit 1
        elif [[ ${#detected[@]} -eq 1 ]]; then
            client="${detected[0]}"
            echo "Detected client: $client"
        else
            echo "Multiple clients detected:"
            local i=1
            for c in "${detected[@]}"; do echo "  $i) $c"; i=$((i+1)); done
            if [[ -t 0 ]]; then
                read -rp "Which one do you want to install for? [1-${#detected[@]}] " pick
                client="${detected[$((pick-1))]}"
            else
                echo "Non-interactive shell — re-run with an explicit client, e.g.:"
                for c in "${detected[@]}"; do echo "    bash install/install.sh $c"; done
                exit 1
            fi
        fi
    fi

    local sub="$SCRIPT_DIR/install-${client}.sh"
    if [[ ! -f "$sub" ]]; then
        echo "No installer for client '$client'. See adapters/${client}.md for manual steps."
        exit 1
    fi

    echo "Running $sub …"
    BUNDLE_ROOT="$BUNDLE_ROOT" bash "$sub"
    echo "Done."
}

main "$@"
