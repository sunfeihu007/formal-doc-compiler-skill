# Adapter — Google Antigravity (IDE)

Antigravity is an IDE-style agent. Its primary extension points are:

1. **Rules / system prompt files** (project-level or workspace-level)
2. **Workspace-level scripts and configs**

The bundle mostly works through (1).

## Install

### Step 1 — Place the bundle

```bash
mkdir -p ~/agent-skills
mv <current-bundle-location> ~/agent-skills/compile-from-sources
```

### Step 2 — Add to Antigravity rules

Antigravity reads rules from one of these locations (depending on version):

- `~/.config/antigravity/rules.md` (global)
- `~/Library/Application Support/Antigravity/rules.md` (macOS, global)
- `.antigravity/rules.md` (project-level)

Pick the global location for cross-project use. Append:

```markdown

# === compile-from-sources skill bundle ===

When the user asks to compile a formal document from source materials
(tender / RFP / 招标要求 / 方案 / 报告 / 白皮书 / proposal / white paper
/ research brief / project summary), follow the 9-step workflow in
~/agent-skills/compile-from-sources/instructions/compile.md.

Sub-procedures (read on demand):
- File triage:           ~/agent-skills/compile-from-sources/instructions/file-triage.md
- Compliance scan:       ~/agent-skills/compile-from-sources/instructions/compliance-check.md
- Chinese typography:    ~/agent-skills/compile-from-sources/instructions/cn-formal-style.md
- Archive deliverable:   ~/agent-skills/compile-from-sources/instructions/archive.md

Scanner: ~/agent-skills/compile-from-sources/scripts/scan.py
Wordlist template: ~/agent-skills/compile-from-sources/templates/wordlist-starter.yaml

Resolve ${BUNDLE_ROOT} to ~/agent-skills/compile-from-sources/

# === end compile-from-sources ===
```

### Step 3 — Install Python dependencies

Same as Codex:

```bash
pip3 install pyyaml python-docx python-pptx openpyxl --break-system-packages
```

### Step 4 — Project-level overrides (optional)

Per-project rules can override or extend the global. For projects with specific requirements (different wordlist, different doc style), drop a `.antigravity/rules.md` in the project root that points at project-specific files.

## Verification

1. Open a new conversation in Antigravity.
2. Ask: "do you have access to a compile-from-sources skill?" — Antigravity should describe the workflow based on the rules block.
3. Test by running a small compile task with 2–3 sample files.

## Uninstall

```bash
# Remove the rules block (edit out the section between === markers)
$EDITOR ~/.config/antigravity/rules.md  # or the path that matched

# Remove the bundle
rm -rf ~/agent-skills/compile-from-sources
```

## Troubleshooting

- **"Antigravity ignores the rules"** — check which version you're on. Newer versions of agent IDEs sometimes change config paths. Search `~/Library/Application Support/Antigravity/` or your XDG config dir for an existing `rules.md` or `.config` and append there.
- **"The workflow runs but skips steps"** — IDE-based agents sometimes get distracted by IDE chrome (file watchers, lint output) mid-workflow. Add `"Treat the 9 steps as a closed loop; ignore unrelated file events"` to the rules block.
- **"Archive can't write"** — the IDE may be running in a sandboxed context. Make sure `<CWD>/.compile-deliverables/` is writable. If the IDE sandboxes the home dir, switch to project-level archive only.
