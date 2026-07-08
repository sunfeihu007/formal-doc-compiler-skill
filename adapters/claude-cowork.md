# Adapter — Claude Cowork (desktop app)

Cowork installs plugins from a packaged `.plugin` file (a zip in the Claude plugin layout). The repo builds that file from source with one command.

## Path A — prebuilt .plugin

The repo ships a prebuilt plugin at `dist/formal-doc-compiler-skill-<version>.plugin`.

1. Locate the newest file in `<bundle-root>/dist/`.
2. Surface it to the user (use your client's file-presentation mechanism — in Cowork, `present_files`).
3. Ask the user to click the **Save plugin** button in the resulting card. Cowork handles the rest.

After install, Cowork registers:
- Skills: `formal-doc-compiler-skill`, `file-triage`, `compliance-check`, `requirement-traceability`, `cn-formal-style`
- Commands: `/compile`, `/archive`

## Path B — build from source

```bash
bash <bundle-root>/build.sh
# → dist/formal-doc-compiler-skill-<VERSION>.plugin
```

`build.sh` stages `.claude-plugin/plugin.json`, `skills/`, `commands/`, `scripts/`, `templates/` into a zip, syncs the version from `VERSION`, and sanity-checks that every SKILL.md has a real frontmatter description. There is no other build procedure — the repo root is the single source of truth.

`install/install-claude-cowork.sh` runs the build automatically when `dist/` is missing or stale.

## Verification

1. In a new Cowork conversation, ask: "what skills are installed?" — the five skills above should appear.
2. Type `/compile` — Cowork should recognize the command.

## Uninstall

In Cowork: Settings → Plugins → find `formal-doc-compiler-skill` → Remove.

## Troubleshooting

- **"Save plugin button doesn't appear"** — Cowork only renders the button for files ending in `.plugin`. Confirm the file extension.
- **"Plugin installs but `/compile` doesn't appear"** — restart the Cowork conversation. Skill / command registration happens at conversation start.
- **"Archive writes fail"** — the archive must never target the plugin install dir; it goes to `<project>/.compile-deliverables/` or `~/.formal-doc-compiler-skill/deliverables/`. See `skills/formal-doc-compiler-skill/references/archive-locations.md`.
