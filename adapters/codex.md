# Adapter — OpenAI Codex CLI

Codex doesn't have a plugin system per se. It has three extension mechanisms you can use:

1. **`~/.codex/AGENTS.md`** — global system prompt, read on every Codex session
2. **`~/.codex/prompts/*.md`** — custom prompts you can invoke by name
3. **MCP servers** — heavier-weight tool registration (not needed for this bundle)

This adapter wires the bundle into mechanisms 1 and 2. The install script does all of it:

```bash
bash install/install-codex.sh
```

Manual steps below, for repair or for walking a user through it.

## Install

### Step 1 — Place the bundle in a stable location

```bash
mkdir -p ~/agent-skills
# If the user already has the bundle locally (e.g., git clone), copy it here:
cp -R <current-bundle-location> ~/agent-skills/formal-doc-compiler-skill

# Or clone fresh from GitHub:
# git clone https://github.com/sunfeihu007/formal-doc-compiler-skill ~/agent-skills/formal-doc-compiler-skill
```

### Step 2 — Append the bundle block to `~/.codex/AGENTS.md`

Append (do not overwrite) the block that `install/common.sh`'s `emit_rules_block` generates. To produce it without installing:

```bash
source install/common.sh
emit_rules_block ~/agent-skills/formal-doc-compiler-skill
```

It tells the agent: when the user asks to compile a formal document from source materials, follow `skills/formal-doc-compiler-skill/SKILL.md`, with the sub-procedure paths (file-triage / compliance-check / cn-formal-style / archive) listed for on-demand reading. The YAML frontmatter at the top of each SKILL.md is metadata for other clients — Codex should just skip it.

### Step 3 — Add slash commands via `~/.codex/prompts/`

This lets the user type `/compile` and `/archive` (per Codex prompt conventions). The install script writes both prompt files; they point at `skills/formal-doc-compiler-skill/SKILL.md` and `commands/archive.md` respectively and pin `${BUNDLE_ROOT}` to the install path.

### Step 4 — Install Python dependencies

The compliance scanner needs `pyyaml` (+ format libraries). Preferred order — never start with `--break-system-packages`:

```bash
pip3 install --user pyyaml python-docx python-pptx openpyxl
# externally-managed Python? use a venv instead:
python3 -m venv ~/.formal-doc-compiler-skill/venv
~/.formal-doc-compiler-skill/venv/bin/pip install pyyaml python-docx python-pptx openpyxl
```

For drafting .docx documents, you'll also want Node.js with the docx library — install on demand, not at bundle install time:

```bash
# (only when first .docx generation is needed, in the project dir)
npm init -y && npm install docx
```

## Verification

Start a new Codex session and verify:

1. Ask Codex: "Do you know how to compile a formal document from source materials?" — it should describe the 9-step workflow from `AGENTS.md`.
2. Try the prompt: `/compile`. Codex should read the SKILL.md and begin the workflow.
3. Run: `python3 ~/agent-skills/formal-doc-compiler-skill/scripts/scan.py --help`. Should print argparse help.

## Uninstall

```bash
bash install/uninstall.sh
```

(Removes the AGENTS.md block between the `===` markers, the prompt files, and the bundle.)

## Troubleshooting

- **Codex doesn't read AGENTS.md** — confirm Codex CLI version supports it. Some older versions used `~/.codex/instructions.md` instead. If so, append the same content to that file.
- **`/compile` prompt not recognized** — confirm `~/.codex/prompts/` is the correct directory for your Codex version. Some versions use `~/.codex/commands/` or a `prompts_dir` config in `~/.codex/config.toml`.
- **Codex doesn't follow the 9 steps in order** — Codex is generally good at following stepwise instructions when given file references. If you see drift, add: `"Be strict about following the 9 steps in order; do not skip or merge steps."` to the prompt file.
