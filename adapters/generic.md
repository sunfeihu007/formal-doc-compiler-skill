# Adapter — Generic fallback

Use this when:

- The client is an agent system not listed in any other adapter
- The client has *no* persistent config (every session is fresh)
- The client lacks file-system access

First check: **does the client accept Claude-format plugin files?** Many third-party clients do — if so, use `adapters/plugin-file.md` instead; it's a one-step install.

Otherwise, the generic approach is to inject the workflow into the client's persistent instructions or the conversation context.

## Path A — client has file-system access

If the client can read local files (most modern agent clients can):

1. Place the bundle:
   ```bash
   bash install/install-generic.sh
   # → ~/agent-skills/formal-doc-compiler-skill, prints the instructions block
   ```
2. Find the client's "custom instructions" / "system prompt" / "persistent context" config. Paste the block the script printed (it points the agent at `skills/formal-doc-compiler-skill/SKILL.md` and the sub-procedure files).
3. Done. The client will read the files on demand.

## Path B — client has no persistent config but accepts long context

For each session, paste this as the first user message:

```
I have a workflow I'd like you to follow when I ask to compile a formal document
from source materials. Here's the workflow — please load it into context and use
it when I ask you to compile a document.

[paste contents of skills/formal-doc-compiler-skill/SKILL.md here]
```

Optionally include sub-procedures:
```
For sub-procedures, here are the supporting instructions:
- File triage: [paste skills/file-triage/SKILL.md]
- Compliance scan: [paste skills/compliance-check/SKILL.md]
- Archive: [paste commands/archive.md]
- Chinese typography: [paste skills/cn-formal-style/SKILL.md]
```

Total: ~10,000 tokens of context per session. Acceptable for modern long-context models. (The YAML frontmatter at the top of each file is harmless — the agent will skip it.)

## Path C — client has no file-system AND no long context

Limited functionality only. You can still:

- Walk through the 9 steps manually by giving the agent one step at a time from `skills/formal-doc-compiler-skill/SKILL.md`
- Run the compliance scanner outside the agent (just `python3 scripts/scan.py`)
- Maintain wordlists and archives by hand

This is a degraded experience. Recommend the user switch to a more capable client.

## Path D — read directly from GitHub raw URL

If the bundle is published on GitHub and the agent can fetch URLs, point it at the raw markdown files:

```
Workflow URL:
https://raw.githubusercontent.com/sunfeihu007/formal-doc-compiler-skill/main/skills/formal-doc-compiler-skill/SKILL.md

Sub-procedure URLs:
https://raw.githubusercontent.com/sunfeihu007/formal-doc-compiler-skill/main/skills/file-triage/SKILL.md
... (etc.)
```

The agent fetches them on demand. No local install needed. The trade-off is that the scanner and templates require local files — so wordlist scanning won't work in this mode unless the agent can also fetch and locally save `scripts/scan.py` and run Python.

## Verification

Whatever path you used, verify by:

1. Asking the agent: "do you know the 9-step compile workflow?" — it should describe scope clarification, triage, parsing, synthesis, outline (+ confirmation), drafting, compliance, visual sample, delivery.
2. Running a small compile task with 2–3 sample files.

## When to switch to a real adapter

If you find yourself doing the same generic-fallback bootstrap repeatedly with the same client, that client deserves its own adapter file. Patterns to look for:

- Does the client accept Claude-format `.plugin` files? → point users at `adapters/plugin-file.md`
- Does the client have a config file the bundle could append to?
- Does the client have a "commands" or "shortcuts" feature?
- Does the client run in a working directory the bundle could place files in?

If yes to any, write a `adapters/<client>.md` based on the existing examples (Codex / Antigravity) and contribute it back to the bundle.
