# Adapter — Generic fallback

Use this when:

- The client is an agent system not listed in any other adapter
- The client has *no* persistent config (every session is fresh)
- The client lacks file-system access

The generic approach is to inject the workflow into the **conversation context** for each session.

## Path A — client has file-system access

If the client can Read local files (most modern agent clients can):

1. Place the bundle:
   ```bash
   mkdir -p ~/agent-skills
   mv <current-bundle-location> ~/agent-skills/formal-doc-compiler-skill
   ```
2. Find the client's "custom instructions" / "system prompt" / "persistent context" config. Append:
   ```
   When the user asks to compile a formal document from source materials, follow
   the workflow in ~/agent-skills/formal-doc-compiler-skill/instructions/compile.md.
   ```
3. Done. The client will Read the file on demand.

## Path B — client has no persistent config but accepts long context

For each session, paste this as the first user message:

```
I have a workflow I'd like you to follow when I ask to compile a formal document
from source materials. Here's the workflow — please load it into context and use
it when I ask you to compile a document.

[paste contents of instructions/compile.md here]
```

Optionally include sub-procedures:
```
For sub-procedures, here are the supporting instructions:
- File triage: [paste instructions/file-triage.md]
- Compliance scan: [paste instructions/compliance-check.md]
- Archive: [paste instructions/archive.md]
- Chinese typography: [paste instructions/cn-formal-style.md]
```

Total: ~10,000 tokens of context per session. Acceptable for modern long-context models.

## Path C — client has no file-system AND no long context

Limited functionality only. You can still:

- Walk through the 9 steps manually by giving the agent one step at a time from `instructions/compile.md`
- Run the compliance scanner outside the agent (just `python3 scripts/scan.py`)
- Maintain wordlists and archives by hand

This is a degraded experience. Recommend the user switch to a more capable client.

## Path D — read directly from GitHub raw URL

If the bundle is published on GitHub and the agent can fetch URLs, point it at the raw markdown files:

```
Workflow URL:
https://raw.githubusercontent.com/<owner>/<repo>/main/instructions/compile.md

Sub-procedure URLs:
https://raw.githubusercontent.com/<owner>/<repo>/main/instructions/file-triage.md
... (etc.)
```

The agent fetches them on demand. No local install needed. The trade-off is that the scanner and templates require local files — so wordlist scanning won't work in this mode unless the agent can also fetch and locally save `scripts/scan.py` and run Python.

## Verification

Whatever path you used, verify by:

1. Asking the agent: "do you know the 9-step compile workflow?" — it should describe scope clarification, triage, parsing, synthesis, outline, drafting, compliance, visual sample, delivery.
2. Running a small compile task with 2–3 sample files.

## When to switch to a real adapter

If you find yourself doing the same generic-fallback bootstrap repeatedly with the same client, that client deserves its own adapter file. Patterns to look for:

- Does the client have a config file the bundle could append to?
- Does the client have a "commands" or "shortcuts" feature?
- Does the client run in a working directory the bundle could place files in?

If yes to any, write a `adapters/<client>.md` based on the existing examples (Codex / Antigravity) and contribute it back to the bundle.
