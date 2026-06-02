# compile — multi-source document compilation workflow

You compile a polished formal document from a folder of mixed source materials. Common deliverables: tender / RFP technical requirements documents, proposals, white papers, research briefs, project summaries, board memos.

## When to use this

The user has a folder (or attached set) of source materials and wants a single polished long-form document grounded in those materials. If they want a quick summary, a single-file analysis, or a chat reply — this is overkill. Decline gracefully and answer in chat.

Trigger phrases: "基于这些文件写一份招标要求 / 方案 / 报告 / 白皮书 / 总结", "compile a document from these sources", "turn this folder into a formal document", "write X based on Y materials", "draft Y from the materials in this folder".

## Operating principles

1. **Lock variance early.** Two questions decide most of the document: *scope* (what's in / out) and *depth* (which sections are heavy vs. light). Resolve both before reading a single file.
2. **Triage before reading.** Many input folders contain 10–30 files. Reading all of them is wasteful. Use `${BUNDLE_ROOT}/instructions/file-triage.md` to assign L1–L4 tiers.
3. **Outsource long context to subagents.** When a single file or single tool result is >40k characters, spawn a subagent that slices it and returns only the structured distillate.
4. **Format learned from the format skill.** When the deliverable is .docx / .xlsx / .pptx / .pdf, read the corresponding format documentation *after* research is complete.
5. **Three-layer verification before delivery.** Content (compliance wordlist), format (schema validation), visual (render & sample). Never deliver without all three.
6. **Fail in the sandbox.** Iterate inside a scratchpad. Only the final clean deliverable lands in the user's working folder.

## The 9-step workflow

### Step 1 — Anchor role, audience, tone

Skim conversation history and memory for role / audience / voice. If anything material is missing (target reader, language register, output language), ask in one round.

### Step 2 — Lock scope and depth

Ask one round, 2–3 questions max:

- **Scope** — which sections are in / out
- **Depth** — which sections are detailed vs. summary
- **Output format** — .docx (default for formal documents), .md, .xlsx, .pptx, .pdf

Do not ask for things you can infer from the user's initial message or from memory.

### Step 3 — Triage the source materials

Apply the rules in `${BUNDLE_ROOT}/instructions/file-triage.md`. Produce a 4-tier table. Show the table to the user only if there are >8 files; otherwise just proceed.

### Step 4 — Parse the source materials

Use the parsing toolchain in `${BUNDLE_ROOT}/references/parsing-toolkit.md`. Run multiple parses in parallel where the files are independent. For each file produce:

- A structured representation (paragraphs + tables + metadata)
- A short distillate of high-signal facts (numbers, quotes, named constraints)

Long results (>40k chars from one parse) → outsource to a subagent that returns only the distillate.

### Step 5 — Synthesize and design the outline

Before writing the outline, scan the deliverable archive for relevant few-shot examples:

1. Check, in priority order, each of these `INDEX.md` files (skip ones that don't exist):
   - `<CWD>/.compile-deliverables/INDEX.md` (project tier)
   - `<CWD>/../.compile-deliverables/INDEX.md` (team / client tier)
   - `~/.compile-from-sources/deliverables/INDEX.md` (global tier)
2. Pick 1–2 rows whose `Doc type` (and ideally `Domain` / `Language`) match the current task.
3. Read the matched entries' `.meta.yaml` files for the `chapters` list, `notable` notes, and `lessons`.
4. Optionally Read the matched document itself for spot-check.

See `${BUNDLE_ROOT}/references/archive-locations.md` for the full path-resolution algorithm.

Then internally consolidate the distillates into:

- A list of facts the document must cite verbatim (numbers, quotes, exact phrasing of client demands)
- A list of constraints (forbidden terms, mandatory terms, structural conventions)
- A chapter/section outline marked with **detailed** vs. **summary** per the Step 2 depth setting, biased by the few-shot examples

The outline lives in your thinking, not on disk.

### Step 6 — Load the format skill

If the deliverable is .docx, .xlsx, .pptx, or .pdf — read the format reference now.

For Chinese formal documents, also read `${BUNDLE_ROOT}/instructions/cn-formal-style.md` for typography parameters.

### Step 7 — Draft

For long documents, write a generation script (Node.js with `docx` library for .docx, Python with `openpyxl` for .xlsx, etc.) that contains both the content data and the formatting. Run it. Iterate on errors in the sandbox.

For shorter documents (<2,000 words) write the file directly.

### Step 8 — Three-layer verification

Run all three. Do not skip any.

- **Content** — invoke `${BUNDLE_ROOT}/instructions/compliance-check.md` against the project's compliance wordlist. Resolve every hit before proceeding.
- **Format** — run the format validator. Resolve every error.
- **Visual** — render to PDF, rasterize 1–2 pages, view as image to eyeball layout.

### Step 9 — Deliver

Move the final file from the scratchpad to the user's working folder. Surface it to the user (via whatever delivery mechanism the client supports). Reply with a concise summary (<200 words):

- Total length (pages / words)
- Section structure (one-line per chapter)
- Compliance scan result (X terms checked, 0 hits)
- Any deliberate trade-offs the user should know about

Then offer 1–2 follow-up moves: tweak a section, add a missing chapter, run archive to save as a few-shot example.

## When in doubt

- If the user gave fewer than three source files, this workflow is probably the wrong tool. Write directly.
- If the user only wants a portion of a deliverable (e.g. "just the executive summary"), still run the 9-step workflow but with a tight outline.
- If scope is genuinely ambiguous after one round of questions, default to the smaller scope and offer to expand.

## Related references

- `${BUNDLE_ROOT}/references/workflow-template.md` — copy-pasteable task list for the 9 steps
- `${BUNDLE_ROOT}/references/red-flags.md` — common ways this workflow can drift and how to catch them
- `${BUNDLE_ROOT}/references/parsing-toolkit.md` — exact commands to parse .docx, .pdf, .pptx, .xlsx, .md
- `${BUNDLE_ROOT}/references/archive-locations.md` — path-resolution rules for the deliverable archive
