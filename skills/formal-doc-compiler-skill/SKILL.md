---
name: formal-doc-compiler-skill
description: "Compile a polished formal document from a folder of mixed source materials. Use whenever the user asks to write a tender / RFP / bid technical requirements document, bid response (应标方案 / 投标响应 / 逐条应答), proposal, white paper, research brief, project summary, board memo, or other long-form formal document grounded in attached files. Trigger phrases include '基于这些文件写一份招标要求 / 应标方案 / 方案 / 报告 / 白皮书 / 总结', 'compile a document from these sources', 'turn this folder into a formal document', 'write X based on Y materials', 'draft Y from the materials in this folder'. The workflow drives nine steps: scope clarification, file triage, parsing, synthesis, outline, drafting, compliance check (plus requirement traceability for response documents), visual sampling, delivery."
---

# Compile a formal document from multi-source materials

## When this skill fires

The user has a folder (or attached set) of source materials and wants a single polished long-form document grounded in those materials. Common surface forms:

- Tender / RFP technical requirements documents
- Proposals, solution write-ups, statements of work
- White papers, research briefs, market studies
- Project summaries, board memos, executive read-aheads
- Internal reviews compiled from interviews / notes / docs

If the user just wants a quick summary, a single-file analysis, or a chat reply — this skill is overkill. Decline gracefully and answer in chat.

## A note on paths

`${BUNDLE_ROOT}` means the directory this bundle is installed in. In Claude Code / Cowork plugin installs that is `${CLAUDE_PLUGIN_ROOT}`; in other clients it is wherever the bundle was placed (default `~/agent-skills/formal-doc-compiler-skill/`). Paths like `references/...` are relative to this skill's own directory.

## Operating principles

1. **Lock variance early.** Two questions decide most of the document: *scope* (what's in / out) and *depth* (which sections are heavy vs. light). Resolve both before reading a single file.
2. **Triage before reading.** Many input folders contain 10–30 files. Reading all of them is wasteful. Use the `file-triage` skill (or read `${BUNDLE_ROOT}/skills/file-triage/SKILL.md`) to assign L1–L4 tiers, then read accordingly.
3. **Outsource long context to subagents.** When a single file or single tool result is >40k characters and your client can spawn subagents, have one slice the file and return only the structured distillate. Keep the main context clean. (No subagent support? Slice the file yourself and skim spans.)
4. **Format learned from the format reference.** When the deliverable is .docx / .xlsx / .pptx / .pdf, read the corresponding format documentation *after* research is complete, then build the file. Don't pre-load format references during research.
5. **Content and code stay separate.** For script-generated documents, content lives in a JSON data file; the generation script only renders. See Step 7.
6. **Layered verification before delivery.** Content (compliance wordlist), format (schema validation), visual (render & sample) — and for response-class documents, requirement traceability (coverage + over-promise). Never deliver with a layer skipped.
7. **Fail in the sandbox.** Iterate inside a scratchpad directory. Only the final clean deliverable lands in the user's working folder.

## The 9-step workflow

Step through the list in order. If your client has a task-list / progress mechanism, create one task per step and update status as you go so the user can watch progress. Use the verification step at the end as a hard gate.

### Step 1 — Anchor role, audience, tone — and document class

Skim conversation history and memory for role / audience / voice. If anything material is missing (target reader, language register, output language), ask in one round.

Also determine the **document class**, because it changes later steps:

- **Response-class** (应标方案 / 投标响应 / 逐条应答 — the document must answer an authoritative requirements file such as a 招标文件 / RFP / 需求书) → Step 2 designates the authoritative source, Step 4 extracts a clause checklist, Step 8 runs **four** verification layers (adds `requirement-traceability`).
- **Ordinary** (technical proposal, white paper, brief with no tender to answer) → the standard flow below; no traceability layer needed.

### Step 2 — Lock scope and depth

Ask one round, 2–4 questions max (use your client's structured-question mechanism if it has one):

- **Scope** — which sections are in / out
- **Depth** — which sections are detailed vs. summary
- **Output format** — .docx (default for formal documents), .md, .xlsx, .pptx, .pdf
- **Length target** (optional) — pages or word count. If the user states one ("15–20 页"), record it as a hard constraint: it drives the per-chapter budget in Step 5 and the page-count verification in Step 8. Don't ask if the user doesn't care.

For **response-class documents**, two more rules in this same round:

- **Designate the authoritative requirements document.** Exactly one source file is the baseline the draft must answer to.
- **Resolve source conflicts explicitly.** If two source files state conflicting requirements (e.g. 需求书 says the client provides the database, 报价函 says you must deploy it), never pick silently — ask the user which document wins. If a conflict only surfaces later during parsing, stop and ask then.

Do not ask for things you can infer from the user's initial message or from memory.

### Step 3 — Triage the source materials

Invoke the `file-triage` skill (or apply the rules in `${BUNDLE_ROOT}/skills/file-triage/SKILL.md` inline). Produce a 4-tier table. Show the table to the user only if there are >8 files; otherwise just proceed.

### Step 4 — Parse the source materials

Use the parsing toolchain in `references/parsing-toolkit.md`. Run multiple parses in parallel where the files are independent. For each file produce:

- A structured representation (paragraphs + tables + metadata)
- A short distillate of high-signal facts (numbers, quotes, named constraints)

Long results (>40k chars from one parse) → outsource to a subagent that returns only the distillate.

For **response-class documents**: while parsing the authoritative requirements file, extract the clause checklist into the scratchpad as `requirements.md` (format and mandatory-strength markers: see `${BUNDLE_ROOT}/skills/requirement-traceability/SKILL.md` § Procedure 1). This is the traceability baseline for every later revision round.

### Step 5 — Synthesize and design the outline

Before writing the outline, scan the deliverable archive for relevant few-shot examples:

1. Check, in priority order, each of these `INDEX.md` files (skip ones that don't exist):
   - `<CWD>/.compile-deliverables/INDEX.md` (project tier)
   - `<CWD>/../.compile-deliverables/INDEX.md` (team / client tier)
   - `~/.formal-doc-compiler-skill/deliverables/INDEX.md` (global tier)
2. Pick 1–2 rows whose `Doc type` (and ideally `Domain` / `Language`) match the current task.
3. Read the matched entries' `.meta.yaml` files for the `chapters` list, `notable` notes, and `lessons` — these are the strongest signal about how a similar deliverable should be structured.
4. Optionally read the matched document itself for spot-check.

See `references/archive-locations.md` for the full path-resolution algorithm.

Then consolidate the distillates into:

- A list of facts the document must cite verbatim (numbers, quotes, exact phrasing of client demands)
- A list of constraints (forbidden terms, mandatory terms, structural conventions)
- A chapter/section outline marked with **detailed** vs. **summary** per the Step 2 depth setting, biased by the few-shot examples' chapter structures

If Step 2 recorded a length target, distribute it across chapters in the outline (e.g. "18 页目标 ≈ 封面+目录 3 页、第一~三章各 2 页、第四章 5 页…"). A budget set now is cheap; cutting 8 pages after rendering is not.

Save the outline to the scratchpad (e.g. `outline.md`) — it survives context compaction and drives Step 7.

### Step 5.5 — Confirm the outline (checkpoint)

Before drafting, show the user the outline: one line per chapter, marked detailed / summary. Ask for a quick confirm-or-adjust. This is the cheapest moment to change direction — editing the outline takes seconds; rewriting three drafted chapters takes an hour. Skip this checkpoint only when the user explicitly asked for a fully hands-off run, or the deliverable is short (<2,000 words).

This is a checkpoint, not a clarification round — it does not count against the one-round budget of Step 2.

### Step 6 — Load the format reference

If the deliverable is .docx, .xlsx, .pptx, or .pdf — read the format documentation now (in Claude clients, the corresponding format skill, e.g. `anthropic-skills:docx`).

For Chinese formal documents, also read `${BUNDLE_ROOT}/skills/cn-formal-style/SKILL.md` for typography parameters.

### Step 7 — Draft

For long documents, generate via script — but keep content and code separate:

1. **Content** goes into one JSON data file per chapter (or one file total for medium docs) in the scratchpad: an array of typed blocks, e.g. `{"type": "h1" | "h2" | "p" | "req" | "table", ...}`. JSON has no problem with full-width Chinese quotes — this eliminates the string-escaping bugs that come from embedding Chinese text in JS string literals.
2. **The render script** (Node.js + `docx` for .docx, Python + `openpyxl` for .xlsx) reads the JSON and maps block types to the format helpers (for Chinese documents, the helpers in `cn-formal-style`). It contains no content.
3. Run the script. Iterate on errors in the sandbox. Content fixes edit the JSON; layout fixes edit the script — never both at once.

This also means a change to one chapter only touches that chapter's data file, and the content is diffable and reusable for other output formats.

For shorter documents (<2,000 words) write the file directly.

### Step 8 — Layered verification

Three layers for ordinary documents, **four for response-class**. Run all of them; do not skip any.

- **Content (blacklist)** — invoke the `compliance-check` skill (or `${BUNDLE_ROOT}/skills/compliance-check/SKILL.md`) against the project's compliance wordlist. Resolve every hit before proceeding.
- **Traceability (response-class only)** — invoke the `requirement-traceability` skill (or `${BUNDLE_ROOT}/skills/requirement-traceability/SKILL.md`) against `requirements.md`: coverage table (no uncovered mandatory clause), over-promise table (no commitment without a tender basis, protective clauses intact), and the response-table cross-reference check. **Re-run this layer after every revision round**, not just the first draft — the classic failure is a later edit deleting a paragraph the 逐条响应表 still references.
- **Format** — run the format validator for the output format. Resolve every error.
- **Visual** — render to PDF, rasterize 1–2 pages (prefer the pages most likely to break: dense tables, the table of contents), view as image to eyeball layout.

If Step 2 recorded a **length target**, the visual layer also verifies it:

```bash
soffice --headless --convert-to pdf output.docx
pdfinfo output.pdf | grep Pages
```

Over budget → tighten line spacing / trim the chapters marked "summary" and re-render; under budget → expand the "detailed" chapters. Two gotchas: docx-js's `TableOfContents` renders **empty** in LibreOffice, so reserve the pages the real TOC will occupy (≈1 page per 25–30 headings) when comparing against the target; and LibreOffice's pagination can differ from Word's by ±1 page — treat the count as approximate at the boundaries.

### Step 9 — Deliver

Move the final file from the scratchpad to the user's working folder. Surface it via your client's file-presentation mechanism (Cowork: `present_files`; CLI clients: state the absolute path). Reply with a concise summary (<200 words):

- Total length (pages / words) — against the Step 2 target if one was set
- Section structure (one-line per chapter)
- Compliance scan result (X terms checked, 0 hits) — plus, for response-class, the traceability result (N clauses covered, no unbacked promises)
- Any deliberate trade-offs the user should know about
- If the document contains a table of contents built from field codes (docx-js `TableOfContents`): remind the user to update fields after opening in Word (Ctrl+A → F9) — LibreOffice and fresh docx files show the TOC empty until then

Then offer 1–2 follow-up moves: tweak a section, add a missing chapter, run the `archive` procedure to save as a few-shot example.

## When in doubt

- If the user gave fewer than three source files, this workflow is probably the wrong tool. Write directly.
- If the user only wants a portion of a deliverable (e.g. "just the executive summary"), still run the 9-step workflow but with a tight outline.
- If scope is genuinely ambiguous after one round of questions, default to the smaller scope and offer to expand.

## Detailed references

- `references/workflow-template.md` — copy-pasteable task list for the 9 steps
- `references/red-flags.md` — common ways this workflow can drift and how to catch them
- `references/parsing-toolkit.md` — exact commands to parse .docx, .pdf, .pptx, .xlsx, .md
- `references/archive-locations.md` — path-resolution rules for the deliverable archive
