# formal-doc-compiler-skill

Turn a folder of mixed source materials into a polished formal document.

Built for the work pattern where you have 10–30 files of varying type and importance — meeting notes, technical write-ups, client requirements, planning drafts, audio transcripts — and you need to produce **one** authoritative long-form document grounded in those materials. Tender / RFP technical requirements, proposals, white papers, research briefs, project summaries, board memos.

Runs across multiple agent clients: Claude (Cowork & Code), OpenAI Codex CLI, Google Antigravity IDE, and any generic LLM agent with file access.

---

## Hand this repo to an agent and say "install it"

The repo is built so that any modern LLM agent with file-system access can install it without you having to know which platform you're on.

In your agent client of choice, paste this:

```
Please install this skill bundle:
https://github.com/sunfeihu007/formal-doc-compiler-skill

Follow the instructions in AGENT-INSTALL.md.
```

The agent will:

1. Detect which client it's running in (Cowork / Claude Code / Codex / Antigravity / other)
2. Read the matching `adapters/<client>.md`
3. Either run `install/install-<client>.sh` or follow the steps manually
4. Verify the install
5. Tell you what to try next

If you'd rather install by hand, see "Manual install" below.

---

## What's in this bundle

| Component | Purpose |
|---|---|
| `instructions/compile.md` | The 9-step workflow itself — scope clarification, file triage, parsing, synthesis, outline, drafting, compliance check, visual sampling, delivery |
| `instructions/archive.md` | Save a delivered document as a few-shot example for future runs |
| `instructions/file-triage.md` | L1 / L2 / L3 / L4 reading tiers for source folders |
| `instructions/compliance-check.md` | Wordlist-based forbidden-term scanner |
| `instructions/cn-formal-style.md` | Chinese formal-document typography (黑体 / 宋体 / 2-char indent / 一-二-三 numbering) |
| `references/` | Extended notes each instruction links to |
| `scripts/scan.py` | The compliance scanner (Python) |
| `templates/wordlist-starter.yaml` | Empty wordlist with category scaffolding |
| `adapters/` | One file per agent client describing exactly how to wire the bundle in |
| `install/` | Shell scripts that automate what the adapters describe |
| `dist/` | Prebuilt `.plugin` file for Claude Cowork / Claude Code |

---

## Supported clients

| Client | Adapter | Install script | Notes |
|---|---|---|---|
| **Claude Cowork** (desktop) | `adapters/claude-cowork.md` | `install/install-claude-cowork.sh` | Uses prebuilt `.plugin` file |
| **Claude Code** (CLI) | `adapters/claude-code.md` | `install/install-claude-code.sh` | Uses `claude plugin install` |
| **OpenAI Codex CLI** | `adapters/codex.md` | `install/install-codex.sh` | Wires into `~/.codex/AGENTS.md` + `~/.codex/prompts/` |
| **Google Antigravity** | `adapters/antigravity.md` | `install/install-antigravity.sh` | Appends to Antigravity rules file |
| **Anything else** | `adapters/generic.md` | `install/install-generic.sh` | Drops the bundle into `~/agent-skills/`, you wire the client |

---

## Manual install (when you know what you're doing)

```bash
# Auto-detect client
bash install/install.sh

# Force client
bash install/install.sh codex
bash install/install.sh claude-code
bash install/install.sh antigravity
bash install/install.sh generic
```

For Cowork, the script just tells you where the `.plugin` file is; you double-click or use Cowork's plugin UI.

---

## Conventions

- **Bundle install location** — `~/agent-skills/formal-doc-compiler-skill/` for non-Cowork clients. Cowork uses its own managed plugin directory.
- **Compliance wordlists** — live with the project at `<project>/.compliance/wordlist.yaml`. Start empty (`templates/wordlist-starter.yaml`), grow over time.
- **Few-shot example archive** — three tiers, highest priority that exists:
  1. `<project>/.compile-deliverables/` — per-project
  2. `<project>/../.compile-deliverables/` — team / customer scope
  3. `~/.formal-doc-compiler-skill/deliverables/` — personal global library

  See `references/archive-locations.md` for the resolution algorithm.

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
6. Load format — Reads anthropic-skills:docx + cn-formal-style.md
7. Draft — Generates a ~700-line Node.js script; runs it; iterates on quote issues
8. Verify — Compliance: 59 terms checked, 0 hits. Format: schema OK. Visual: page 1 + page 5 rasterized, looks right.
9. Deliver — Moves docx to working folder. Surfaces it. Reports: 36 pages, 21k words.

Agent then offers: archive this as a few-shot? extend chapter X?
```

---

## Requirements

- **Python 3.10+** with: `pyyaml python-docx python-pptx openpyxl` and `pdftotext` (Poppler)
- **Node.js 18+** with `npm install docx` (per project, for .docx generation)
- **LibreOffice** for PDF conversion / visual verification (any recent version)

The install scripts try to install Python deps for you.

---

## License

MIT. See `LICENSE`.

---

## Versioning

The bundle and the prebuilt Cowork plugin version independently:

- Bundle version: see `VERSION` (currently `0.3.0`)
- Cowork plugin version: see `dist/formal-doc-compiler-skill-<x.y.z>.plugin` filename (currently `0.2.0`)

Changelog in `CHANGELOG.md`.

---

## Contributing back

If you build an adapter for a new client, drop the file under `adapters/`, add an install script under `install/`, register the client name in `install/install.sh`'s `detect_client()` and `usage()`, and update this README's "Supported clients" table.
