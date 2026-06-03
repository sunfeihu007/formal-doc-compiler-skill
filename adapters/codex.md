# Adapter — OpenAI Codex CLI

Codex doesn't have a plugin system per se. It has three extension mechanisms you can use:

1. **`~/.codex/AGENTS.md`** — global system prompt, read on every Codex session
2. **`~/.codex/prompts/*.md`** — custom prompts you can invoke by name
3. **MCP servers** — heavier-weight tool registration (not needed for this bundle)

This adapter wires the bundle into mechanisms 1 and 2.

## Install

### Step 1 — Place the bundle in a stable location

```bash
mkdir -p ~/agent-skills
# If the user already has the bundle locally (e.g., git clone), move it here:
mv <current-bundle-location> ~/agent-skills/formal-doc-compiler-skill

# Or clone fresh from GitHub:
# git clone https://github.com/<owner>/formal-doc-compiler-skill ~/agent-skills/formal-doc-compiler-skill
```

Set `BUNDLE_ROOT`:

```bash
echo 'export BUNDLE_ROOT=~/agent-skills/formal-doc-compiler-skill' >> ~/.zshrc  # or ~/.bashrc
```

### Step 2 — Append to `~/.codex/AGENTS.md`

Codex reads `AGENTS.md` files for system-level instructions. Append (do not overwrite):

```bash
mkdir -p ~/.codex
cat >> ~/.codex/AGENTS.md <<'EOF'

# === formal-doc-compiler-skill skill bundle ===

When the user asks to compile a formal document from source materials —
tender / RFP / 招标要求 / 方案 / 报告 / 白皮书 / proposal / white paper /
research brief / project summary — follow the 9-step workflow in:

  ~/agent-skills/formal-doc-compiler-skill/instructions/compile.md

Sub-procedures (read on demand):
- File triage:           ~/agent-skills/formal-doc-compiler-skill/instructions/file-triage.md
- Compliance scan:       ~/agent-skills/formal-doc-compiler-skill/instructions/compliance-check.md
- Chinese typography:    ~/agent-skills/formal-doc-compiler-skill/instructions/cn-formal-style.md
- Archive deliverable:   ~/agent-skills/formal-doc-compiler-skill/instructions/archive.md

Scanner script: ~/agent-skills/formal-doc-compiler-skill/scripts/scan.py
Wordlist template: ~/agent-skills/formal-doc-compiler-skill/templates/wordlist-starter.yaml

Within any of those files, resolve ${BUNDLE_ROOT} to
~/agent-skills/formal-doc-compiler-skill/

# === end formal-doc-compiler-skill ===
EOF
```

### Step 3 — Add slash commands via `~/.codex/prompts/`

This lets the user type `/compile` and `/archive` (per Codex prompt conventions):

```bash
mkdir -p ~/.codex/prompts

cat > ~/.codex/prompts/compile.md <<'EOF'
Read ~/agent-skills/formal-doc-compiler-skill/instructions/compile.md and follow
it step by step.

If the user passed arguments after the command, treat them as:
- First arg: source folder path
- Second arg: doc type (tender / proposal / whitepaper / brief / summary)

Within the workflow, resolve ${BUNDLE_ROOT} to
~/agent-skills/formal-doc-compiler-skill/
EOF

cat > ~/.codex/prompts/archive.md <<'EOF'
Read ~/agent-skills/formal-doc-compiler-skill/instructions/archive.md and follow
it step by step.

If the user passed a file path argument, use that as the deliverable to
archive. Otherwise look for the most recent deliverable in the conversation.

Within the workflow, resolve ${BUNDLE_ROOT} to
~/agent-skills/formal-doc-compiler-skill/
EOF
```

### Step 4 — Install Python dependencies

The compliance scanner needs:

```bash
pip3 install pyyaml python-docx python-pptx openpyxl --break-system-packages
```

For drafting .docx documents, you'll also want Node.js with the docx library — install on demand, not at bundle install time:

```bash
# (only when first .docx generation is needed, in the project dir)
npm init -y && npm install docx
```

## Verification

Start a new Codex session and verify:

1. Run any chat. Codex's first system prompt should now contain the formal-doc-compiler-skill block from `AGENTS.md`. (You can confirm by asking Codex: "Do you know how to compile a formal document from source materials?")
2. Try the prompt: `/compile`. Codex should read `instructions/compile.md` and begin the workflow.
3. Run: `python3 ~/agent-skills/formal-doc-compiler-skill/scripts/scan.py --help`. Should print argparse help.

## Uninstall

```bash
# Remove the AGENTS.md block (open the file and delete between the === markers)
$EDITOR ~/.codex/AGENTS.md

# Remove the prompts
rm ~/.codex/prompts/compile.md ~/.codex/prompts/archive.md

# Remove the bundle
rm -rf ~/agent-skills/formal-doc-compiler-skill
```

## Troubleshooting

- **Codex doesn't read AGENTS.md** — confirm Codex CLI version supports it. Some older versions used `~/.codex/instructions.md` instead. If so, append the same content to that file.
- **`/compile` prompt not recognized** — confirm `~/.codex/prompts/` is the correct directory for your Codex version. Some versions use `~/.codex/commands/` or a `prompts_dir` config in `~/.codex/config.toml`.
- **Codex doesn't follow the 9 steps in order** — Codex is generally good at following stepwise instructions when given file references. If you see drift, add: `"Be strict about following the 9 steps in order; do not skip or merge steps."` to the prompt file.
