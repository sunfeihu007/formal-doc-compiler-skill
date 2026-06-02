# Triage heuristics — extended notes

## Edge cases

### A "summary" file that is actually the primary basis

Files named "总结", "汇总", "说明" sound like L4 (after-the-fact write-ups) but are often L1 in technical projects — the engineer's own write-up of what was built. Open the file. If it contains technical architecture, data schemas, processing pipelines — promote to L1.

### A long PPT that is actually L4

Multi-megabyte PPT files with hundreds of slides are usually internal training material or sales decks. Unless the user pointed at it as a basis, treat as L3 or L4. Don't parse 100 slides without reason.

### Multiple files with overlapping content

Common in projects where the same content was re-summarized for different audiences. Pick one as L1/L2 (usually the latest or the most structured), and demote the rest one tier. Don't double-count facts.

### Audio transcripts vs. meeting minutes

If both an audio transcript ("录音.pdf") and a clean meeting minute ("纪要.pdf") exist for the same meeting, the minute is higher tier. The transcript is L4 unless there's a specific quote or detail the minute misses.

### Files the user wrote vs. files the client wrote

Default: client files are higher tier than your own files. The client's words are the source of authority for what they want. Your own files reflect what you proposed — important, but second-order.

## Worked examples

### Example 1: Tender for a bank's AI system

Folder contains:

```
- 客户需求纪要.pdf                          (8 pages)
- 项目建设说明.docx                          (40 pages, your team wrote)
- 客户AI规划草稿.docx                        (20 pages, client wrote)
- 客户内部汇报.pptx                          (200 slides)
- 5次会议录音转写.pdf × 5
- AGENTS.md
- README.md
```

Triage:

- L1: 项目建设说明.docx (your technical basis — the user pointed at it)
- L1: 客户需求纪要.pdf (client's stated demands)
- L2: 客户AI规划草稿.docx (client's own thinking, supplementary)
- L3: 客户内部汇报.pptx (open ToC slide, skip body unless you find gaps)
- L4: 会议录音转写 × 5 (use minutes; only consult transcript on specific gaps)
- L4: AGENTS.md, README.md (skip)

### Example 2: Quarterly business review

Folder contains:

```
- Q3-finance-dashboard.xlsx
- Q3-board-deck-v4-FINAL.pptx
- weekly-sync-notes/ × 12
- competitive-research.pdf
- customer-interviews/ × 8
```

Triage:

- L1: Q3-board-deck-v4-FINAL.pptx (the official record, near-final)
- L1: Q3-finance-dashboard.xlsx (numeric ground truth)
- L2: customer-interviews/ × 8 (direct VoC — high signal)
- L3: competitive-research.pdf
- L4: weekly-sync-notes/ × 12 (scan filenames, only open if you see "decision")

### Example 3: Research brief on a regulatory change

Folder contains:

```
- regulation-2024-12.pdf                    (the regulation itself)
- legal-team-summary.docx
- precedent-cases.pdf × 5
- internal-impact-memo.docx
- press-coverage/ × 30 articles
```

Triage:

- L1: regulation-2024-12.pdf (the primary instrument)
- L1: legal-team-summary.docx (authoritative interpretation)
- L2: precedent-cases.pdf × 5 (full read for context)
- L2: internal-impact-memo.docx
- L4: press-coverage/ × 30 (skip; only open if the user explicitly asks "what's the public reaction")
