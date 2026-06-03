# Changelog

## 0.3.0 — 2026-06-02

Repackaged as a cross-client bundle. The same instructions and scripts now drive Claude Cowork, Claude Code, OpenAI Codex CLI, Google Antigravity, and a generic fallback.

### Added

- `AGENT-INSTALL.md` — meta-install instructions any LLM agent can follow from the repo URL
- `adapters/` — five client-specific adapters with explicit install steps
- `install/` — shell scripts that automate each adapter (`install.sh` is the dispatcher, with auto-detection)
- `instructions/` — client-neutral versions of the previous SKILL.md files (no frontmatter, paths use `${BUNDLE_ROOT}`)
- `references/`, `scripts/`, `templates/` — flattened to top level so they're easy to reference from any client
- `dist/formal-doc-compiler-skill-0.2.0.plugin` — prebuilt Cowork plugin, kept in the repo for one-click install

### Changed

- The bundle layout decouples content from packaging. Content lives in `instructions/`; the Cowork `.plugin` is a build artifact in `dist/`.

### Migration from 0.2.0 (Cowork plugin only)

Existing Cowork installs continue to work. The bundle is a superset: you get the same skills inside Cowork, plus the option to use them from other clients.

## 0.2.0 — 2026-05-29 (Cowork plugin)

Fixed `/archive` to write to user-writable archive locations rather than the read-only plugin install dir. Three-tier path resolution (project / team / global).

## 0.1.0 — 2026-05-29 (Cowork plugin)

Initial Cowork plugin release.

- 9-step compile workflow
- `/compile` and `/archive` commands
- file-triage, compliance-check, cn-formal-style skills
- Starter wordlist template
