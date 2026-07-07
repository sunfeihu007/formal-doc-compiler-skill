# formal-doc-compiler-skill

Turn a folder of mixed source materials into a polished formal document.

Built for the work pattern where you have 10–30 files of varying type and importance — meeting notes, technical write-ups, client requirements, planning drafts, audio transcripts — and you need to produce **one** authoritative long-form document grounded in those materials. Tender / RFP technical requirements, proposals, white papers, research briefs, project summaries, board memos.

Runs across multiple agent clients: Claude Code (CLI), Claude Cowork (desktop), OpenAI Codex CLI, Google Antigravity IDE, any third-party client that imports Claude-format `.plugin` files, and any generic LLM agent with file access.

---

## Quick install

**Claude Code** — the repo is itself a plugin + marketplace:

```bash
claude plugin marketplace add sunfeihu007/formal-doc-compiler-skill
claude plugin install formal-doc-compiler-skill@formal-doc-compiler
```

**Everything else** — clone and run the dispatcher:

```bash
git clone https://github.com/sunfeihu007/formal-doc-compiler-skill
cd formal-doc-compiler-skill
bash install/install.sh          # auto-detects; asks if several clients found
```

**Plugin-only third-party clients** — import the packaged plugin file:

```bash
bash build.sh                    # → dist/formal-doc-compiler-skill-<version>.plugin
# then import that file with your client's plugin mechanism
```

---

## Hand this repo to an agent and say "install it"

Any modern LLM agent with file-system access can install this without you knowing which platform you're on. In your agent client of choice, paste:

```
Please install this skill bundle:
https://github.com/sunfeihu007/formal-doc-compiler-skill

Follow the instructions in AGENT-INSTALL.md.
```

The agent will detect which client it's running in, read the matching `adapters/<client>.md`, run or replicate `install/install-<client>.sh`, verify, and tell you what to try next.

---

## What's in this bundle

The repo root **is** the Claude plugin — `skills/` and `commands/` are the single source of truth for all clients. There is no separate "instructions" copy to drift out of sync.

| Component | Purpose |
|---|---|
| `skills/formal-doc-compiler-skill/` | The 9-step workflow — scope clarification, file triage, parsing, synthesis, outline (+ user confirmation), drafting, compliance check, visual sampling, delivery |
| `skills/file-triage/` | L1 / L2 / L3 / L4 reading tiers for source folders |
| `skills/compliance-check/` | Wordlist-based forbidden-term scanner |
| `skills/cn-formal-style/` | Chinese formal-document typography (黑体 / 宋体 / 2-char indent / 一-二-三 numbering) |
| `commands/compile.md`, `commands/archive.md` | `/compile` and `/archive` entry points |
| `skills/*/references/` | Extended notes each skill links to, read on demand |
| `scripts/scan.py` | The compliance scanner (Python; tested — `python3 -m pytest tests/`) |
| `templates/wordlist-starter.yaml` | Empty wordlist with category scaffolding |
| `.claude-plugin/` | Plugin + marketplace manifests (Claude Code installs straight from GitHub) |
| `adapters/` | One file per agent client describing exactly how to wire the bundle in |
| `install/` | Shell scripts that automate what the adapters describe |
| `build.sh` | Builds `dist/formal-doc-compiler-skill-<version>.plugin` from source |
| `dist/` | The built `.plugin` file for Cowork / plugin-only clients |

---

## Supported clients

| Client | Adapter | Install | Notes |
|---|---|---|---|
| **Claude Code** (CLI) | `adapters/claude-code.md` | `install/install-claude-code.sh` | Plugin marketplace; falls back to `~/.claude/skills/` |
| **Claude Cowork** (desktop) | `adapters/claude-cowork.md` | `install/install-claude-cowork.sh` | `.plugin` file, built by `build.sh` |
| **OpenAI Codex CLI** | `adapters/codex.md` | `install/install-codex.sh` | Wires into `~/.codex/AGENTS.md` + `~/.codex/prompts/` |
| **Google Antigravity** | `adapters/antigravity.md` | `install/install-antigravity.sh` | Appends to Antigravity rules file |
| **Plugin-only clients** | `adapters/plugin-file.md` | `install/install-plugin-file.sh` | Any client that imports Claude-format `.plugin` files |
| **Anything else** | `adapters/generic.md` | `install/install-generic.sh` | Drops the bundle into `~/agent-skills/`, prints the wiring block |

---

## Conventions

- **Bundle install location** — `~/agent-skills/formal-doc-compiler-skill/` for non-plugin clients. Claude Code / Cowork use their managed plugin directories; `${BUNDLE_ROOT}` in the skill files means whichever of these applies.
- **Compliance wordlists** — live with the project at `<project>/.compliance/wordlist.yaml`. Start empty (`templates/wordlist-starter.yaml`), grow over time. Terms are literal (case- and width-insensitive) unless prefixed with `regex:`.
- **Few-shot example archive** — three tiers; project and team archives take precedence, and the first archive in a new project always asks:
  1. `<project>/.compile-deliverables/` — per-project
  2. `<project>/../.compile-deliverables/` — team / customer scope
  3. `~/.formal-doc-compiler-skill/deliverables/` — personal global library

  See `skills/formal-doc-compiler-skill/references/archive-locations.md` for the resolution algorithm.

---

## Workflow snapshot

What a compile run looks like end-to-end:

```
User: /compile ./tender-materials/ tender

Agent:
1. Anchor — Confirms output language, target reader (skipped — clear from context)
2. Lock scope — Asks 2 questions: which sections, what depth
3. Triage — Builds an L1/L2/L3/L4 table from 14 input files
4. Parse — Runs python-docx / pdftotext on L1/L2 files in parallel
5. Synthesize — Reads the project's archived few-shot examples; outlines 11 chapters
   ↳ Shows the outline, one line per chapter. User: "chapter 7 merge into 6". Done in seconds.
6. Load format — Reads the docx format reference + cn-formal-style
7. Draft — Writes chapter content as JSON data files + one render script; runs it
8. Verify — Compliance: 59 terms checked, 0 hits. Format: schema OK. Visual: TOC + table page rasterized, looks right.
9. Deliver — Moves docx to working folder. Surfaces it. Reports: 36 pages, 21k words.

Agent then offers: archive this as a few-shot? extend chapter X?
```

---

## Requirements

- **Python 3.10+** with: `pyyaml python-docx python-pptx openpyxl` and `pdftotext` (Poppler)
- **Node.js 18+** with `npm install docx` (per project, for .docx generation)
- **LibreOffice** for PDF conversion / visual verification (any recent version)

The install scripts install Python deps for you — `pip --user` first, venv at `~/.formal-doc-compiler-skill/venv` if your Python is externally managed. They never use `--break-system-packages`.

---

## Developing

- Content changes: edit `skills/*/SKILL.md` / `commands/*.md` — they're the only copy.
- Rebuild the plugin file: `bash build.sh` (syncs versions from `VERSION`, checks frontmatter, zips to `dist/`).
- Scanner tests: `python3 -m pytest tests/`.

## License

MIT. See `LICENSE`.

## Versioning

One version for everything: `VERSION` (currently `0.4.0`). `build.sh` stamps it into the plugin manifests. Changelog in `CHANGELOG.md`.

## Contributing back

If you build an adapter for a new client, drop the file under `adapters/`, add an install script under `install/`, register the client name in `install/install.sh`'s `detect_clients()` and `usage()`, and update this README's "Supported clients" table.
