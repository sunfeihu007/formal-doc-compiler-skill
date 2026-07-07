# Adapter — Claude Code (CLI)

This repo **is** a Claude Code plugin (root-level `.claude-plugin/plugin.json` + `skills/` + `commands/`) and also ships a marketplace manifest, so the repo itself is the install source.

> Note: `claude plugin install` only accepts plugins from a registered marketplace. It does **not** accept a `.plugin` file path — that's a Cowork / plugin-only-client mechanism.

## Path A — install straight from GitHub (recommended)

```bash
claude plugin marketplace add sunfeihu007/formal-doc-compiler-skill
claude plugin install formal-doc-compiler-skill@formal-doc-compiler
```

## Path B — install from a local clone

```bash
git clone https://github.com/sunfeihu007/formal-doc-compiler-skill
claude plugin marketplace add ./formal-doc-compiler-skill
claude plugin install formal-doc-compiler-skill@formal-doc-compiler
```

Or run the script, which does the same and installs Python deps:

```bash
bash install/install-claude-code.sh
```

## Path C — skills-directory fallback (no plugin system needed)

If the plugin routes fail (old CLI version, restricted environment), copy the pieces in directly:

```bash
TARGET=~/agent-skills/formal-doc-compiler-skill
cp -R <bundle-root> "$TARGET"
mkdir -p ~/.claude/skills ~/.claude/commands
cp -R "$TARGET"/skills/* ~/.claude/skills/
cp "$TARGET"/commands/*.md ~/.claude/commands/
```

`install/install-claude-code.sh` falls back to this automatically when the `claude` CLI is unavailable. In this mode, `${BUNDLE_ROOT}` inside the skill files means `~/agent-skills/formal-doc-compiler-skill`.

## Python dependencies

The compliance scanner needs `pyyaml` (+ `python-docx` / `python-pptx` / `openpyxl` per format). The install script handles this (pip `--user`, falling back to a venv at `~/.formal-doc-compiler-skill/venv`). Manual: see `skills/compliance-check/SKILL.md` § Python dependencies.

## Verification

```bash
claude plugin list
# Expected: formal-doc-compiler-skill (from marketplace formal-doc-compiler)
```

In an interactive session, `/compile` should be recognized, and asking "基于这个文件夹写一份方案" should trigger the `formal-doc-compiler-skill` skill.

## Uninstall

```bash
claude plugin uninstall formal-doc-compiler-skill
claude plugin marketplace remove formal-doc-compiler
```

or for the skills-directory fallback: `bash install/uninstall.sh`.

## Troubleshooting

- **`claude plugin marketplace add` errors** — your CLI may predate marketplaces; use Path C.
- **`/compile` recognized but workflow doesn't trigger** — make sure the working directory has source files. The skill checks file count before activating its main workflow.
- **`python3` errors during compliance scan** — see `skills/compliance-check/SKILL.md` § Python dependencies.
