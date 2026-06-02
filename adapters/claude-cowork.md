# Adapter — Claude Cowork (desktop app)

Cowork has a native plugin system that this bundle ships as a pre-packaged `.plugin` file. The fastest path is to install that file directly.

## Path A — install the prebuilt .plugin (recommended)

The repo ships a prebuilt plugin at `dist/compile-from-sources-0.2.0.plugin`.

1. Locate the file:
   ```
   <bundle-root>/dist/compile-from-sources-0.2.0.plugin
   ```
2. Surface it to the user (use whatever your client's file-sharing mechanism is — `present_files`, an open-folder action, etc.).
3. Ask the user to click the **Save plugin** button in the resulting card. Cowork handles the rest.

After install, Cowork will register:
- Skills: `compile-from-sources`, `file-triage`, `compliance-check`, `cn-formal-style`, `archive` (the archive command-skill)
- Commands: `/compile`, `/archive`

## Path B — install from source (for development)

If the user is iterating on the bundle and wants live edits:

1. Build a .plugin from the current source:
   ```bash
   cd <bundle-root>/dist
   zip -r compile-from-sources-dev.plugin ../plugin-template/ -x "*.DS_Store"
   ```
   Note: the bundle uses a plugin-template/ structure that mirrors Cowork's expected layout. If it isn't present yet, see Path C.
2. Surface the .plugin and have the user save it.

## Path C — build the plugin layout from this bundle

If `dist/` doesn't have a prebuilt .plugin (e.g., the user cloned the bundle fresh and the dist file is gone), you need to construct the Cowork plugin layout:

```bash
WORK=$(mktemp -d)
mkdir -p "$WORK/compile-from-sources/.claude-plugin"
mkdir -p "$WORK/compile-from-sources/commands"
mkdir -p "$WORK/compile-from-sources/skills/compile-from-sources/references"
mkdir -p "$WORK/compile-from-sources/skills/file-triage/references"
mkdir -p "$WORK/compile-from-sources/skills/compliance-check/references"
mkdir -p "$WORK/compile-from-sources/skills/cn-formal-style/references"

# plugin.json
cat > "$WORK/compile-from-sources/.claude-plugin/plugin.json" <<'JSON'
{
  "name": "compile-from-sources",
  "version": "0.2.0",
  "description": "Turn a folder of mixed source materials into a polished formal document.",
  "author": { "name": "compile-from-sources contributors" },
  "license": "MIT"
}
JSON

# Skills require frontmatter — wrap each instructions/*.md
B=<bundle-root>
for skill in compile-from-sources file-triage compliance-check cn-formal-style; do
  src="$B/instructions/${skill}.md"
  dst="$WORK/compile-from-sources/skills/${skill}/SKILL.md"
  cat > "$dst" <<EOF
---
name: ${skill}
description: "See body for description."
---

EOF
  cat "$src" >> "$dst"
done

# Commands (compile, archive) — also need frontmatter
for cmd in compile archive; do
  cat > "$WORK/compile-from-sources/commands/${cmd}.md" <<EOF
---
description: "See body for description."
allowed-tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob", "Task", "TaskCreate", "TaskUpdate", "AskUserQuestion"]
---

EOF
  cat "$B/instructions/${cmd}.md" >> "$WORK/compile-from-sources/commands/${cmd}.md"
done

# Copy references and scripts into the right SKILL refs/ folders
cp $B/references/parsing-toolkit.md $B/references/workflow-template.md $B/references/red-flags.md $B/references/archive-locations.md \
    "$WORK/compile-from-sources/skills/compile-from-sources/references/"
cp $B/references/triage-heuristics.md "$WORK/compile-from-sources/skills/file-triage/references/"
cp $B/references/extract-text.md $B/references/scan-script.md $B/scripts/scan.py $B/templates/wordlist-starter.yaml \
    "$WORK/compile-from-sources/skills/compliance-check/references/"
cp $B/references/full-script-example.md $B/references/quote-fix-script.md \
    "$WORK/compile-from-sources/skills/cn-formal-style/references/"

# README + CONNECTORS + CHANGELOG
cp $B/README.md $B/CHANGELOG.md "$WORK/compile-from-sources/"
echo "# Connectors\nThis plugin does not require external connectors." > "$WORK/compile-from-sources/CONNECTORS.md"

# Pack
cd "$WORK/compile-from-sources" && zip -r /tmp/compile-from-sources.plugin . -x "*.DS_Store"
echo "Built: /tmp/compile-from-sources.plugin"
```

Replace `<bundle-root>` with the actual path. Then surface `/tmp/compile-from-sources.plugin` and have the user save it.

## Verification

After install:

1. In a new Cowork conversation, ask: "what skills are installed?" — `compile-from-sources`, `file-triage`, `compliance-check`, `cn-formal-style` should appear.
2. Type `/compile` — Cowork should recognize the command.

## Uninstall

In Cowork: Settings → Plugins → find `compile-from-sources` → Remove.

## Troubleshooting

- **"Save plugin button doesn't appear"** — Cowork only renders the button for files ending in `.plugin`. Confirm the file extension.
- **"Plugin installs but `/compile` doesn't appear"** — restart the Cowork conversation. Skill / command registration happens at conversation start.
- **"Plugin installs but archive writes fail"** — this is fixed in 0.2.0+. The plugin no longer tries to write to its own install directory. Confirm version.
