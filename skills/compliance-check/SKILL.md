---
name: compliance-check
description: "Scan a generated document against a project-specific compliance wordlist for forbidden terms — third-party brand names, competitor products, specific model names, specific quantitative metrics (concurrency numbers, latency, percentages), specific dates, and any other content the document must avoid. Use after drafting any externally-sent document (tender, RFP, proposal, contract, press release, board memo). Reads the wordlist from the project's working folder, runs a scan, and reports every hit with surrounding context so the writer can revise. Wordlists live as YAML in the project — `.compliance/wordlist.yaml` — and grow over time."
---

# Compliance check — forbidden-term scanner

## When this fires

After drafting any document that goes outside your organization (or has compliance/regulatory exposure). Common triggers:

- "Run a compliance check on this draft"
- "Are there any forbidden terms in the document?"
- "Check the document against our wordlist"
- Implicit: end of Step 8 in the `formal-doc-compiler-skill` workflow

Internal-only memos and quick chat replies do not need this.

**Scope note:** this skill is a *blacklist* — it answers "did we say something we must not say." For bid-response documents (应标/投标响应) it is necessary but not sufficient: the opposite failure directions (漏应答 — a tender clause nobody responded to; 超承诺 — a commitment no clause asked for) are covered by the `requirement-traceability` skill. Run both for response documents.

## What it does

1. Resolves the project's compliance wordlist (default location: `.compliance/wordlist.yaml` in the working folder; alternate locations explained below).
2. Extracts text from the deliverable (`.docx`, `.pdf`, `.pptx`, `.xlsx`, `.md`, `.txt`, `.html`).
3. Scans for every word/phrase in the wordlist. Literal terms match case-insensitively and width-insensitively (full-width `ＧＬＭ` matches `GLM`); regex terms are marked explicitly with a `regex:` prefix.
4. Reports every hit with 30 characters of context on each side, grouped by category.
5. Suggests fixes — generic replacement phrasing from the wordlist when present.

## Run the scan

```bash
python3 ${BUNDLE_ROOT}/scripts/scan.py \
    --doc path/to/draft.docx \
    --wordlist .compliance/wordlist.yaml
```

Each non-summary stdout line is a JSON object with `category`, `term`, `matched`, `context`, `suggested_replacement`. The final line has `summary: true` plus counts. Invalid regex terms are reported as `warning` lines instead of crashing the scan — fix them in the wordlist.

Requires `pyyaml` (plus `python-docx` / `python-pptx` / `openpyxl` for those formats). If missing, see "Python dependencies" below.

## Wordlist format

```yaml
# .compliance/wordlist.yaml
categories:
  third_party_brands:
    description: "Brand names from other vendors that should not appear in our outbound docs."
    suggested_replacement: "a leading <category> tool"
    terms:
      - Wind          # literal — matches wind / WIND / Ｗｉｎｄ too
      - C++           # literal — regex metacharacters are safe in literals

  specific_models:
    description: "Specific AI/ML model names that lock the doc to a vendor."
    suggested_replacement: "mainstream large language model"
    terms:
      - GLM
      - Qwen

  hard_metrics:
    description: "Specific numeric performance claims that should be deferred to the implementation plan."
    suggested_replacement: "to be evaluated jointly during implementation"
    terms:
      - "regex:\\d+\\s*并发"
      - "regex:\\d+(\\.\\d+)?\\s*(秒|毫秒|ms)"
```

Rules:

- A term is **literal** unless it starts with `regex:`. Literal terms are matched case-insensitively and NFKC-normalized (full-width/half-width folded). Regex metacharacters in literals are safe — `C++` matches the literal string `C++`.
- **Never use `\b` adjacent to CJK text.** Python treats CJK characters as word characters, so `\d+秒\b` silently fails to match "响应时间3秒内". Write the pattern without the boundary (`\d+\s*秒`) or use explicit lookarounds like `(?<!\d)`.
- Regex terms are matched case-insensitively against NFKC-normalized text as well.

Wordlists start empty (`${BUNDLE_ROOT}/templates/wordlist-starter.yaml`) and grow over time. Each finished project should contribute the terms it ended up catching.

## Project conventions

By default the scanner looks for `.compliance/wordlist.yaml` in the current working folder. You can override with `--wordlist`:

- `.compliance/wordlist.yaml` — project default
- `.compliance/wordlist.<project>.yaml` — per-project variant
- `~/.compliance/global.yaml` — personal global list (rare; usually project-local is better)

Always commit project wordlists to the repo. The wordlist *is* the documented compliance policy.

## Procedure

1. Locate the wordlist. If none exists, ask the user whether to (a) start with a fresh empty wordlist (copy from `${BUNDLE_ROOT}/templates/wordlist-starter.yaml`), (b) seed from a previous project, or (c) skip compliance scanning.
2. Run the scan.
3. Report hits in a Markdown table grouped by category.
4. If hits > 0: do not deliver. Either revise the draft, or — only with explicit user approval — update the wordlist to exempt the term and re-scan.

## Output format

```
| Category | Term | Context | Suggested replacement |
|----------|------|---------|----------------------|
| third_party_brands | Wind | ...风格参考自 Wind 平台... | "a leading market-data tool" |
| hard_metrics | regex:\d+\s*并发 | ...支持 1800 并发使用... | "to be evaluated jointly" |
```

When there are zero hits, reply with a single line: `OK — 0 hits across <N> terms.`

## Python dependencies

The scanner needs `pyyaml`, and `python-docx` / `python-pptx` / `openpyxl` for the corresponding formats. Install order of preference:

```bash
pip3 install --user pyyaml python-docx python-pptx openpyxl
```

If your Python is externally managed (Homebrew / Debian) and refuses, use a dedicated venv instead:

```bash
python3 -m venv ~/.formal-doc-compiler-skill/venv
~/.formal-doc-compiler-skill/venv/bin/pip install pyyaml python-docx python-pptx openpyxl
# then run the scanner with that interpreter:
~/.formal-doc-compiler-skill/venv/bin/python ${BUNDLE_ROOT}/scripts/scan.py ...
```

Only fall back to `--break-system-packages` as a last resort, and say so to the user.

## Maintaining the wordlist

The wordlist is a living document. After every project:

- Add the specific terms you ended up needing to catch.
- Add regex patterns for category-shaped problems.
- Periodically prune terms that no longer apply.

A wordlist of 30–50 well-chosen terms covers the vast majority of compliance failures. Larger lists become noisy.

## Detailed references

- `${BUNDLE_ROOT}/templates/wordlist-starter.yaml` — empty starter
- `references/scan-script.md` — script usage and output format
- `references/extract-text.md` — text-extraction recipes per format
- `${BUNDLE_ROOT}/scripts/scan.py` — the scanner itself
