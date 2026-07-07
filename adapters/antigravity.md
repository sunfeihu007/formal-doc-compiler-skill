# Adapter — Google Antigravity (IDE)

Antigravity is an IDE-style agent. Its primary extension points are:

1. **Rules / system prompt files** (project-level or workspace-level)
2. **Workspace-level scripts and configs**

The bundle works through (1). The install script does all of it:

```bash
bash install/install-antigravity.sh
```

## Install (manual)

### Step 1 — Place the bundle

```bash
mkdir -p ~/agent-skills
cp -R <current-bundle-location> ~/agent-skills/formal-doc-compiler-skill
```

### Step 2 — Add to Antigravity rules

Antigravity reads rules from one of these locations (depending on version):

- `~/.config/antigravity/rules.md` (global)
- `~/Library/Application Support/Antigravity/rules.md` (macOS, global)
- `.antigravity/rules.md` (project-level)

Pick the global location for cross-project use. Append the block produced by `install/common.sh`'s `emit_rules_block` (same block the Codex adapter uses — it points the agent at `skills/formal-doc-compiler-skill/SKILL.md` and the sub-procedures).

### Step 3 — Install Python dependencies

Same order of preference as the Codex adapter: `pip3 install --user …`, falling back to a venv at `~/.formal-doc-compiler-skill/venv`. Don't reach for `--break-system-packages` first.

### Step 4 — Project-level overrides (optional)

Per-project rules can override or extend the global. For projects with specific requirements (different wordlist, different doc style), drop a `.antigravity/rules.md` in the project root that points at project-specific files.

## Verification

1. Open a new conversation in Antigravity.
2. Ask: "do you have access to a formal-doc-compiler-skill skill?" — Antigravity should describe the workflow based on the rules block.
3. Test by running a small compile task with 2–3 sample files.

## Uninstall

```bash
bash install/uninstall.sh
```

## Troubleshooting

- **"Antigravity ignores the rules"** — check which version you're on. Newer versions of agent IDEs sometimes change config paths. Search `~/Library/Application Support/Antigravity/` or your XDG config dir for an existing `rules.md` or `.config` and append there.
- **"The workflow runs but skips steps"** — IDE-based agents sometimes get distracted by IDE chrome (file watchers, lint output) mid-workflow. Add `"Treat the 9 steps as a closed loop; ignore unrelated file events"` to the rules block.
- **"Archive can't write"** — the IDE may be running in a sandboxed context. Make sure `<CWD>/.compile-deliverables/` is writable. If the IDE sandboxes the home dir, switch to project-level archive only.
