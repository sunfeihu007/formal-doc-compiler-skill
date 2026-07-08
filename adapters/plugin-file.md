# Adapter — plugin-only third-party clients

Use this for any third-party client whose only extension mechanism is importing a Claude-format plugin file (`.plugin` — a zip containing `.claude-plugin/plugin.json`, `skills/*/SKILL.md`, `commands/*.md`).

## Install

1. Get the plugin file — either the prebuilt one in `dist/`, or build fresh:

   ```bash
   bash <bundle-root>/build.sh
   # or: bash install/install-plugin-file.sh   (builds only if stale, prints the path)
   ```

2. Import `dist/formal-doc-compiler-skill-<version>.plugin` with the client's plugin mechanism (import / open / drag-drop — whatever the client offers).

3. The client should register:
   - Skills: `formal-doc-compiler-skill`, `file-triage`, `compliance-check`, `requirement-traceability`, `cn-formal-style`
   - Commands: `/compile`, `/archive` (if the client supports commands)

## What's inside the zip

```
.claude-plugin/plugin.json      # name, version, description
commands/compile.md             # /compile entry point
commands/archive.md             # /archive procedure
skills/<name>/SKILL.md          # frontmatter description + workflow body
skills/<name>/references/*.md   # deep-dive notes, read on demand
scripts/scan.py                 # compliance scanner
templates/wordlist-starter.yaml # empty compliance wordlist
```

`${BUNDLE_ROOT}` inside the skill files means the directory the client unpacked the plugin into (the Claude convention is `${CLAUDE_PLUGIN_ROOT}`).

## Client capability notes

The skills are written client-neutrally — they refer to capabilities ("your client's task-list mechanism", "your client's file-presentation mechanism") rather than specific tool names. A client only needs:

- file reading + shell access for the full workflow (parsing, scanner, docx generation)
- without shell access, the drafting workflow still works; the compliance scanner and visual verification degrade gracefully (the skill says what to skip)

## Verification

Ask the client: "what skills do you have installed?" — the five skills should appear. Then run a small compile task with 2–3 sample files.

## Uninstall

Use the client's plugin management UI.
