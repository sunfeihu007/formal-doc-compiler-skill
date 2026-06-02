#!/usr/bin/env bash
# install.sh — top-level installer for compile-from-sources bundle
#
# Usage:
#   bash install/install.sh                  # auto-detect client
#   bash install/install.sh codex            # force client
#   bash install/install.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

detect_client() {
    if [[ -d "$HOME/Library/Application Support/Claude" ]]; then
        if [[ -d "$HOME/Library/Application Support/Claude/local-agent-mode-sessions" ]]; then
            echo "claude-cowork"
            return
        fi
    fi
    if command -v codex >/dev/null 2>&1 || [[ -d "$HOME/.codex" ]]; then
        echo "codex"; return
    fi
    if command -v claude >/dev/null 2>&1 || [[ -d "$HOME/.claude" ]]; then
        echo "claude-code"; return
    fi
    if [[ -d "$HOME/.config/antigravity" ]] || [[ -d "$HOME/Library/Application Support/Antigravity" ]]; then
        echo "antigravity"; return
    fi
    echo "unknown"
}

usage() {
    cat <<EOF
Usage:
    bash install/install.sh [<client>]

Clients:
    claude-cowork   Claude desktop app (Cowork mode)
    claude-code     Claude Code CLI
    codex           OpenAI Codex CLI
    antigravity     Google Antigravity IDE
    generic         Generic fallback

If no client is given, the script tries to detect one from your environment.

Bundle location: $BUNDLE_ROOT
EOF
}

main() {
    local client="${1:-}"

    if [[ "$client" == "--help" || "$client" == "-h" ]]; then
        usage; exit 0
    fi

    if [[ -z "$client" ]]; then
        client=$(detect_client)
        echo "Detected client: $client"
        if [[ "$client" == "unknown" ]]; then
            echo
            echo "Could not auto-detect a client. Re-run with one of:"
            echo "    bash install/install.sh claude-cowork"
            echo "    bash install/install.sh claude-code"
            echo "    bash install/install.sh codex"
            echo "    bash install/install.sh antigravity"
            echo "    bash install/install.sh generic"
            exit 1
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
