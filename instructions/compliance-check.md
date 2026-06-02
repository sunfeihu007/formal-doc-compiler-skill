# compliance-check — forbidden-term scanner

## When to use this

After drafting any document that goes outside your organization (or has compliance/regulatory exposure). Common triggers:

- "Run a compliance check on this draft"
- "Are there any forbidden terms in the document?"
- "Check the document against our wordlist"
- Implicit: end of Step 8 in the compile workflow

Internal-only memos and quick chat replies do not need this.

## What it does

1. Resolves the project's compliance wordlist (default location: `.compliance/wordlist.yaml` in the working folder; alternate locations explained below).
2. Extracts text from the deliverable (`.docx`, `.pdf`, `.pptx`, `.md`, `.txt`).
3. Scans for every word/phrase in the wordlist, both literal matches and regex matches.
4. Reports every hit with 30 characters of context on each side, grouped by category.
5. Suggests fixes — generic replacement phrasing from the wordlist when present.

## Run the scan

```bash
python3 ${BUNDLE_ROOT}/scripts/scan.py \
    --doc path/to/draft.docx \
    --wordlist .compliance/wordlist.yaml
```

Each non-summary stdout line is a JSON object with `category`, `term`, `matched`, `context`, `suggested_replacement`. The final line has `summary: true` plus counts.

If `pyyaml` isn't installed: `pip install pyyaml --break-system-packages` once.

## Wordlist format

```yaml
# .compliance/wordlist.yaml
categories:
  third_party_brands:
    description: "Brand names from other vendors that should not appear in our outbound docs."
    suggested_replacement: "a leading <category> tool"
    terms:
      - Wind
      - Alice

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
      - "\\b\\d+\\s*concurrency\\b"   # regex
      - "\\b\\d+(\\.\\d+)?\\s*(秒|ms)\\b"
```

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
| hard_metrics | 1800并发 | ...支持 1800 并发使用... | "to be evaluated jointly" |
```

When there are zero hits, reply with a single line: `OK — 0 hits across <N> terms.`

## Maintaining the wordlist

The wordlist is a living document. After every project:

- Add the specific terms you ended up needing to catch.
- Add regex patterns for category-shaped problems.
- Periodically prune terms that no longer apply.

A wordlist of 30–50 well-chosen terms covers the vast majority of compliance failures. Larger lists become noisy.

## Related references

- `${BUNDLE_ROOT}/templates/wordlist-starter.yaml` — empty starter
- `${BUNDLE_ROOT}/references/scan-script.md` — script internals
- `${BUNDLE_ROOT}/references/extract-text.md` — text-extraction recipes per format
- `${BUNDLE_ROOT}/scripts/scan.py` — the scanner itself
