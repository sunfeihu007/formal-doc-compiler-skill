---
name: file-triage
description: "Sort a folder of mixed source materials into a four-tier (L1 / L2 / L3 / L4) reading plan before drafting any document. Use whenever the input is more than a handful of files and reading them all would waste context. Tier definitions: L1 = primary basis the deliverable must cite, L2 = key requirements / scope, L3 = supplementary planning / drafts, L4 = peripheral notes / nice-to-have. Output is a small Markdown table the parent workflow uses to decide what to read fully, selectively, scan, or skip. Pairs with formal-doc-compiler-skill but works standalone."
---

# Triage a folder of source materials

## Why this exists

A typical input folder for a tender / proposal / research brief contains 10–30 files. Reading all of them in full wastes context, slows the run, and pollutes synthesis with low-signal text. Triage is the cheap discipline that prevents this.

This produces a 4-tier reading plan in one pass. The parent workflow then parses only the files that warrant attention.

## The four tiers

| Tier | Meaning | Reading strategy |
|------|---------|------------------|
| **L1** | Primary technical / policy basis. The deliverable must cite this verbatim. Usually 1–3 files. | Full read. Use the parsing toolkit. Capture every section and table. |
| **L2** | Key requirements & scope. Client's stated needs, decisions, constraints. Usually 2–5 files. | Full read. Distill into a list of facts, quotes, constraints. |
| **L3** | Supplementary planning, the user's own drafts, third-party reference plans. Usually 2–5 files. | Selective read — table of contents + chapters that touch L1/L2 themes. |
| **L4** | Peripheral notes, internal chat logs, irrelevant attachments, decorations. | Scan first 200 lines or skip entirely. |

## Triage signals

Use the user's own labels first. If the user said "this is the main technical basis" or "this is the client's requirement document", that file is L1 or L2 directly. Do not second-guess.

When the user gave no labels, infer from:

- **Filename language**. "总结", "建设说明", "技术架构", "需求纪要" usually signal L1/L2. "汇报", "会议", "讨论" signal L2/L3. "提示词", "AGENTS.md", "README" signal L4.
- **File size**. Very small files (< 5 KB) are usually L4. Very large files (> 100 pages) are either L1 (a primary technical document) or L4 (an archive dump) — open the first page to decide.
- **Modification date**. The most recently edited files are usually higher tier — they reflect the current state of the project.
- **Recipient**. Files prepared *for the client* (proposal decks, demos) tend to be L1/L2. Files prepared *for internal team* (chat logs, status updates) tend to be L3/L4.

## Procedure

1. List the folder. Record filenames, sizes, modification dates.
2. Apply the user's explicit labels — assign tiers directly.
3. For unlabeled files, apply the triage signals above.
4. Emit a tier table (Markdown) with one row per file. Include the **reading strategy** for each.
5. If the folder has more than 8 files, show the table to the user before parsing. If 8 or fewer, proceed silently.

## Output format

```
| Tier | File | Reading strategy |
|------|------|------------------|
| L1   | xx.docx | Full read |
| L2   | xx.pdf  | Full read |
| L3   | xx.pptx | Selective |
| L4   | xx.md   | Skip |
```

Keep file paths relative to the source folder.

## When triage is wrong

If the eventual draft has gaps the user flags, the most common cause is "an L3 file was actually L2." Promote it and re-parse that file in full.

Conversely, if the draft is bloated with irrelevant detail, the cause is "an L4 file was read as L2." Be willing to demote and re-synthesize.

## Detailed references

- `references/triage-heuristics.md` — extended worked examples and edge cases
