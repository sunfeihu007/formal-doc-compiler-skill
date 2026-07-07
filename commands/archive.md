---
description: "Archive a completed deliverable as a reusable few-shot example for future compile runs"
argument-hint: "[file-path]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "AskUserQuestion"]
---

# /archive — preserve a deliverable as a few-shot example

Save a finished deliverable into a writable archive location, where future compile runs read it as a structural reference.

## When to use this

After delivering any formal document via the compile workflow, if the user wants to add it to their few-shot library. Or when the user explicitly says "archive this" / "save this as an example" / "归档这份".

## Procedure

1. **Identify the deliverable.** If the user passed a file path as the argument, use it. Otherwise look for the most recent file delivered in this conversation, or ask which file to archive.

2. **Resolve the archive root.** See `../skills/formal-doc-compiler-skill/references/archive-locations.md` for the full algorithm. The three tiers:

   | Tier | Root | When to use |
   |------|------|-------------|
   | Project | `<CWD>/.compile-deliverables/` | Per-project — strongest isolation. **Default.** |
   | Team / client | `<CWD>/../.compile-deliverables/` | Multiple projects share one customer; archive once at the customer level. |
   | Global | `~/.formal-doc-compiler-skill/deliverables/` | Personal cross-project library. |

   If a **project or team** archive directory already exists, use the higher-priority one — the user has decided for this project. If neither exists, this is the first archive **for this project**: ask once which tier to use (default: project). The global directory existing does *not* skip this question — it only means "global library" is one of the choices.

   **Do not write to the bundle install directory** (`${CLAUDE_PLUGIN_ROOT}` or equivalent). It may be read-only or a git checkout the user doesn't want polluted.

3. **Ask one round of metadata questions** (or infer from the conversation):
   - **Document type** — tender / proposal / whitepaper / brief / summary / other
   - **Domain** — finance, banking, healthcare, government, tech, etc. (one tag)
   - **Why it's a good example** — one sentence the writer should know when picking few-shot references

4. **Copy the deliverable** to `<archive-root>/<doc-type>/<YYYY-MM-DD>-<slug>.<ext>`. Slug derives from the doc title in kebab-case, redacted of any client-specific names if the user flags external sensitivity.

5. **Write a sidecar** `<same-name>.meta.yaml`:

   ```yaml
   archived_at: "YYYY-MM-DD"
   doc_type: tender
   domain: banking
   sub_domain: internal-audit       # optional
   language: zh-CN
   output_format: docx
   length_pages: 36
   length_words: 21000
   chapters:
     - 第一章 项目概述
     - 第二章 总体建设要求
     - ...
   notable: |
     What's special about this deliverable — for future few-shot selection.
   lessons:                          # optional but valuable
     - "key writing pattern learned"
   compliance_wordlist: "../../.compliance/wordlist.yaml"  # if applicable
   generation:                       # optional
     method: "node + docx-js"
     format_reference_used: "cn-formal-style"
   ```

6. **Update the index** `<archive-root>/INDEX.md` with one row referencing the new entry. Keep INDEX.md sorted by `doc_type` then date descending. If INDEX.md doesn't exist yet, create it with the standard header (see `archive-locations.md`).

7. **Redaction prompt** for externally-sensitive content. If the deliverable contains client-specific names or PII the user doesn't want archived, prompt before saving. Always default to redacted slugs rather than raw client names in filenames.

## Why this exists

Few-shot examples are the highest-signal way to keep a compile run consistent with your team's house style. The `formal-doc-compiler-skill` workflow scans every reachable `INDEX.md` (project + team + global) during Step 5 outline design and loads 1–2 matching entries as structural references.

Over time the archive becomes a library that encodes your team's writing conventions without anyone having to write a style guide.

## Argument examples

- `/archive` — archive the most recent delivered document
- `/archive ./output/quarterly-review.docx` — archive a specific file

## Detailed references

- `../skills/formal-doc-compiler-skill/references/archive-locations.md` — complete path-resolution algorithm and INDEX.md format
