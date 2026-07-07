# Scan script

The scanner lives at `${BUNDLE_ROOT}/scripts/scan.py` — that file is the single source of truth; this note only documents usage and output. Requires `pyyaml` (see the SKILL.md "Python dependencies" section for install guidance).

## Usage

```bash
python3 ${BUNDLE_ROOT}/scripts/scan.py \
    --doc path/to/draft.docx \
    --wordlist .compliance/wordlist.yaml
```

`--doc` may be given multiple times to scan several files in one run.

## Matching semantics

- **Literal terms** (everything without a `regex:` prefix) are matched case-insensitively and NFKC-normalized — `Wind` catches `wind`, `WIND`, and full-width `Ｗｉｎｄ`. Regex metacharacters in literals are safe: `C++` matches the literal string `C++`.
- **Regex terms** start with `regex:` in the wordlist, e.g. `- "regex:\\d+\\s*并发"`. Also case-insensitive against NFKC-normalized text.
- **Invalid regex terms** don't crash the scan — they're reported as `warning` JSON lines so you can fix the wordlist.
- Avoid `\b` adjacent to CJK characters: Python counts CJK as word characters, so `\d+秒\b` silently fails on "3秒内".

## Supported document formats

`.docx` (paragraphs + tables), `.pdf` (via `pdftotext -layout`), `.pptx` (all text frames), `.xlsx` (all cell values), `.md` / `.txt` / `.html` (raw text). Unsupported extensions produce a clean JSON error, not a traceback.

## Interpreting output

Each non-summary line is a JSON object:

```json
{"category": "third_party_brands", "term": "Wind", "matched": "wind", "context": "...风格参考自 wind 平台...", "suggested_replacement": "a leading market-data tool"}
```

Warning lines (bad wordlist entries) look like:

```json
{"warning": true, "category": "hard_metrics", "term": "regex:([bad", "error": "missing ), unterminated subpattern at position 0"}
```

The final summary line has `summary: true` plus counts:

```json
{"summary": true, "hits": 2, "warnings": 0, "terms_checked": 59, "docs": ["draft.docx"]}
```

Parse and present hits as a table grouped by category. Use the summary to decide whether to proceed (`hits == 0`) or block delivery (`hits > 0`). Treat `warnings > 0` as a wordlist bug to fix before trusting the scan.
