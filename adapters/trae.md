# Adapter — Trae (ByteDance AI IDE)

Trae reads agent rules from Markdown files, at two levels:

1. **User rules** — `user_rules.md`, managed through Trae's settings UI (Settings → Rules → User Rules). Applies to every project.
2. **Project rules** — `<project>/.trae/rules/project_rules.md`. Applies to one project; Trae creates the folder via the settings UI, but a hand-created file works too.

The bundle wires in through these rules files — same pattern as the Codex / Antigravity adapters, same block content.

## Install

The script does it for the current project:

```bash
bash install/install-trae.sh          # bundle → ~/agent-skills, block → ./.trae/rules/project_rules.md
```

Manual steps:

### Step 1 — Place the bundle

```bash
mkdir -p ~/agent-skills
cp -R <current-bundle-location> ~/agent-skills/formal-doc-compiler-skill
```

### Step 2 — Add the rules block

For **all projects**: open Trae → Settings → Rules → User Rules, and paste the block produced by:

```bash
source install/common.sh
emit_rules_block ~/agent-skills/formal-doc-compiler-skill
```

For **one project**: append the same block to `<project>/.trae/rules/project_rules.md` (create the file if needed). Trae also reads `.trae/rules/` in subdirectories if you only want it for one module.

The block tells the agent: when the user asks to compile a formal document from source materials, follow `skills/formal-doc-compiler-skill/SKILL.md`, with sub-procedure paths listed for on-demand reading. The YAML frontmatter at the top of each SKILL.md is metadata for other clients — Trae's agent should just skip it.

### Step 3 — Python dependencies

Same order of preference as the other adapters: `pip3 install --user pyyaml python-docx python-pptx openpyxl`, falling back to a venv at `~/.formal-doc-compiler-skill/venv`. Don't reach for `--break-system-packages` first.

## Verification

1. Open a new Trae conversation (in a project with the rules block, or with user rules set).
2. Ask: "你现在会怎么基于一个文件夹的材料写一份正式方案？" — the agent should describe the 9-step workflow.
3. Test with 2–3 sample files.

## Uninstall

- Remove the block between the `# === formal-doc-compiler-skill … ===` markers from user rules (settings UI) and/or `.trae/rules/project_rules.md`.
- `bash install/uninstall.sh` removes the bundle itself and cleans the current project's `project_rules.md` if it finds the markers there.

## Troubleshooting

- **Trae ignores the rules** — confirm the file is `.trae/rules/project_rules.md` (not `.trae/project_rules.md`), and that the conversation was started *after* the rules were added.
- **The agent describes the workflow but won't read the SKILL.md files** — some Trae agent configurations restrict file access to the project folder. In that case, copy the bundle into the project (e.g. `<project>/.trae/skills/formal-doc-compiler-skill/`) and update the paths in the block accordingly.
- **Compliance scanner fails** — check the Python deps; see `skills/compliance-check/SKILL.md` § Python dependencies.
