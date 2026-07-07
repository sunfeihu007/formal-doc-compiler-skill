# AGENT-INSTALL — read this if a user pointed you at this repository and asked you to install it

You are an LLM agent. A user pointed you at this repository (or handed you its URL / a clone of it) and said something like "install this," "set this up," or "make this available." Your job is to figure out which client you're running in and execute the matching adapter.

This document is written FOR you, the agent. It assumes you have file-system access, can run shell commands, and can read other files in this repository.

---

## Step 1 — Identify the client

You are likely running in one of these clients. Pick the matching adapter:

| Client | Telltale signs | Adapter |
|---|---|---|
| **Claude Code** (CLI) | `claude` command in PATH, `~/.claude/` exists, no Cowork tools | `adapters/claude-code.md` |
| **Claude Cowork** (desktop app) | Cowork-specific tools (`mcp__cowork__*`), `~/Library/Application Support/Claude/` exists | `adapters/claude-cowork.md` |
| **OpenAI Codex CLI** | `codex` command in PATH, `~/.codex/` exists | `adapters/codex.md` |
| **Trae** (ByteDance IDE) | `.trae/` in project, or `~/Library/Application Support/Trae*/` exists | `adapters/trae.md` |
| **Google Antigravity** (IDE) | Antigravity IDE chrome / config dir under `~/Library/Application Support/Antigravity/` or `.antigravity/` in project | `adapters/antigravity.md` |
| **A client whose only extension mechanism is importing plugin files** | The client's docs/UI mention importing Claude-format plugins | `adapters/plugin-file.md` |
| **Anything else** | Default | `adapters/generic.md` |

**If more than one row matches** (e.g. the machine has both `claude` and `codex` installed), do not guess — ask the user one short question listing the matches. Tool names you were actually given beat directory existence: `mcp__cowork__*` tools mean Cowork even if `~/.codex` exists.

---

## Step 2 — Read the matching adapter and execute it

Each `adapters/<client>.md` is self-contained. It tells you:

- Where the bundle's files should live on disk
- Which client-specific config files need to be created or appended
- How to verify the install worked
- How to uninstall later

**Do not invent steps.** If the adapter says "copy X to `<some path>`," do exactly that. The paths and merge rules are specific to each client's extension system, and getting them wrong creates a half-installed setup that's hard to debug.

---

## Step 3 — Run an install script if available

`install/install.sh` is a top-level dispatcher. If the user is in a shell and you can run scripts, prefer:

```bash
bash install/install.sh <client>
```

It will call into the matching `install/install-<client>.sh`. The shell scripts do exactly the same things the markdown adapters describe, just in fewer turns.

Use the markdown adapters when:
- You don't have shell access
- The user wants you to walk them through each step
- Something failed in the script and you need to repair it manually

---

## Step 4 — Verify

After installing, ask the user to invoke `/compile` (or the client equivalent) and confirm:

- The workflow loads
- It can read source files in the user's working folder
- It can run the compliance scanner (`python3 ${BUNDLE_ROOT}/scripts/scan.py --help` should work)

If verification fails, read `adapters/<client>.md`'s "Troubleshooting" section.

---

## Step 5 — Tell the user what just happened

Reply with a short summary:

- The bundle is installed at `${BUNDLE_ROOT}` (give the actual resolved path)
- The client now recognizes these capabilities: compile, archive, file-triage, compliance-check, cn-formal-style
- The user can try it with: `<example invocation per client>`

Optionally, mention next steps:
- Build a project compliance wordlist at `.compliance/wordlist.yaml` (copy from `${BUNDLE_ROOT}/templates/wordlist-starter.yaml`)
- Run the workflow on a sample folder to confirm end-to-end

---

## What this bundle provides

A nine-step workflow that turns a folder of mixed source materials (.docx, .pdf, .pptx, .xlsx, .md) into a polished formal document — tender / RFP technical requirements, proposals, white papers, research briefs, project summaries, board memos.

The repo root is a Claude-format plugin, and `skills/` + `commands/` are the single source of truth for every client:

| Component | File | Purpose |
|---|---|---|
| **compile** | `skills/formal-doc-compiler-skill/SKILL.md` | The 9-step main workflow |
| **file-triage** | `skills/file-triage/SKILL.md` | L1 / L2 / L3 / L4 reading-tier rules |
| **compliance-check** | `skills/compliance-check/SKILL.md` | Wordlist scanner, calls `scripts/scan.py` |
| **cn-formal-style** | `skills/cn-formal-style/SKILL.md` | Chinese formal-document typography for .docx |
| **archive** | `commands/archive.md` | Save a deliverable as a few-shot example |

Each SKILL.md starts with YAML frontmatter (name + trigger description). Clients with a skill system use it for automatic triggering; for other clients it's inert metadata — skip it and read the body.

`skills/*/references/` holds the extended notes each skill links to.
`scripts/` holds executables (currently only `scan.py`; tests in `tests/`).
`templates/` holds starter files for project-level config.

---

## A note on `${BUNDLE_ROOT}`

Throughout the skills and references, `${BUNDLE_ROOT}` refers to wherever this bundle ended up on disk. The adapters set this:

- Claude Code / Cowork → the managed plugin directory (`${CLAUDE_PLUGIN_ROOT}`)
- Codex / Antigravity / generic → `~/agent-skills/formal-doc-compiler-skill/` (recommended default)
- Plugin-only clients → wherever the client unpacked the `.plugin` file

When you read a file inside the bundle, resolve `${BUNDLE_ROOT}` to the actual install location. Do not pass `${BUNDLE_ROOT}` literally to the file-system.

---

## If you can't install

Some agent clients are pure black-box (no file-system, no shell). For those, see `adapters/generic.md` — it covers the fallback of "paste the SKILL.md into the conversation context and invoke from there."

If the user is on such a client, set expectations: the workflow will work but you lose persistence of the wordlist, the few-shot library, and the scanner. They'll need to keep the bundle URL handy and re-bootstrap each session.
