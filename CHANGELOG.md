# Changelog

## 0.4.0 — 2026-07-07

Single source of truth, working installs on every client, and scanner fixes.

### Fixed

- **Claude Code install actually works now.** `claude plugin install <file>` was never a valid invocation (the CLI only installs from marketplaces). The repo root is now a proper plugin with a marketplace manifest — install straight from GitHub with `claude plugin marketplace add sunfeihu007/formal-doc-compiler-skill`. The install script falls back to `~/.claude/skills/` when the CLI is unavailable.
- **Scanner: case-insensitive matching.** `Wind` now catches `wind` / `WIND` / full-width `Ｗｉｎｄ` (NFKC normalization).
- **Scanner: literal terms are literal.** `C++` / `Node.js` no longer get mis-parsed as regexes. Regex terms are now explicit with a `regex:` prefix in the wordlist.
- **Scanner: robustness.** Invalid regex terms produce `warning` JSON lines instead of tracebacks; `.xlsx` deliverables are supported; unsupported extensions produce clean JSON errors; docx headers/footers are scanned; `--doc` is repeatable. Test suite added (`tests/`).
- **Docs no longer teach `\b` next to CJK** — those patterns silently never match (`\d+秒\b` misses "3秒内"). Examples rewritten.
- **Archive first-run contradiction.** The global archive existing no longer silently swallows every new project's deliverables; the first archive per project always asks (project / team / global).
- **Cowork build recipe bugs.** The old embedded rebuild script produced placeholder frontmatter (`"See body for description."` — skills built that way never auto-triggered), wrote a literal `\n` into CONNECTORS.md, and referenced a nonexistent `plugin-template/`. Replaced by `build.sh`.

### Changed

- **Single content source.** `instructions/` is gone; `skills/*/SKILL.md` (with the trigger frontmatter) and `commands/*.md` are the only copy, used verbatim by every client. `references/` moved into `skills/*/references/`. The `.plugin` file is built from source by `build.sh` — content in the zip can no longer drift.
- **One version.** Bundle and plugin share `VERSION` (0.4.0); `build.sh` syncs the manifests. Install scripts glob `dist/*.plugin` instead of hardcoding a filename.
- **Client-neutral wording.** References no longer name Claude-only tools (`present_files`, `TaskCreate`, `AskUserQuestion`, `Agent(...)`); they describe capabilities, and adapters map them per client.
- **Workflow: outline checkpoint (Step 5.5).** The outline is saved to the scratchpad and shown to the user for a quick confirm before drafting.
- **Workflow: content/code separation (Step 7).** Document text goes in JSON data files; the generation script only renders. This eliminates the full-width-quote escaping bugs; the quote-fix recipe is demoted to a legacy-repair note.
- **Safer Python dependency install.** `pip --user` first, then a dedicated venv; never `--break-system-packages` by default.
- **Client detection asks instead of guessing** when several clients are present (the old order silently preferred Codex over Claude Code).

### Added

- `.claude-plugin/marketplace.json` — install from GitHub in two commands
- `adapters/plugin-file.md` + `install/install-plugin-file.sh` — third-party clients that import Claude-format `.plugin` files
- `build.sh` — source → `dist/*.plugin`, with version sync and frontmatter sanity check
- `install/common.sh` — shared rules-block emitter (Codex/Antigravity/generic now can't drift apart) and dependency installer
- `tests/test_scan.py` — scanner regression tests

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
