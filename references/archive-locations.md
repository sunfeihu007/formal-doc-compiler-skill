# Archive locations — full path-resolution algorithm

## Why not `${CLAUDE_PLUGIN_ROOT}/deliverables/`

The plugin install directory is typically read-only after Cowork installs it. Writing archives there will fail with permission errors and lose the deliverable. The archive must go to a user-writable location.

## Three tiers, picked by priority

| Priority | Tier | Root path | Best for |
|----------|------|-----------|----------|
| 1 (highest) | Project | `<CWD>/.compile-deliverables/` | Each project keeps its own archive. Strongest isolation. Best when the project has client-confidential structure. |
| 2 | Team / client | `<CWD>/../.compile-deliverables/` | Multiple projects under one customer or one workstream share an archive. The parent folder commonly represents the customer (e.g., `兴业/`) or the practice area. |
| 3 | Global | `~/.formal-doc-compiler-skill/deliverables/` | Cross-project personal library. Best when you handle a wide variety of unrelated work and want every past deliverable available as a possible reference. |

## Resolution at write time (`/archive`)

```
def resolve_archive_root(cwd):
    project = cwd / ".compile-deliverables"
    team    = cwd.parent / ".compile-deliverables"
    global_ = Path.home() / ".formal-doc-compiler-skill" / "deliverables"

    # 1. If any of these directories already exists, the user has decided. Pick the highest-priority existing one.
    for candidate in (project, team, global_):
        if candidate.exists() and candidate.is_dir():
            return candidate

    # 2. None exists — this is the first /archive of the project. Ask via AskUserQuestion.
    #    Default to project tier (priority 1).
    return ask_user_with_default(project)
```

The first `/archive` per project asks once; subsequent archives reuse the existing directory automatically.

## Resolution at read time (`/compile` Step 5)

When the main workflow looks for few-shot examples, it should **read all three tiers** that exist, in priority order. Merge their INDEX.md entries before choosing references.

```
def collect_indices(cwd):
    indices = []
    for candidate in (
        cwd / ".compile-deliverables" / "INDEX.md",
        cwd.parent / ".compile-deliverables" / "INDEX.md",
        Path.home() / ".formal-doc-compiler-skill" / "deliverables" / "INDEX.md",
    ):
        if candidate.exists():
            indices.append((candidate, parse_index(candidate)))
    return indices
```

When two tiers contain an entry for the same `<doc-type>`, prefer the higher-priority tier (project beats team beats global). Same doc-type, different slugs: include both, project ranked higher.

## INDEX.md format

Each tier's INDEX.md follows this shape. Keep it short — one row per archived deliverable.

```markdown
# Compile-from-sources deliverable index

| Doc type | Date | Title slug | Domain | Language | Pages | Notable |
|----------|------|------------|--------|----------|-------|---------|
| tender | 2026-05-29 | bank-audit-agent | banking | zh-CN | 36 | One-line description. |
| brief  | 2026-04-12 | q2-launch       | tech    | en-US | 8  | Short executive brief example. |
```

Sort by `Doc type` then `Date` descending. The `Notable` column should be terse enough that the workflow can scan many rows quickly.

## Directory shape inside each tier

```
<archive-root>/
├── INDEX.md
├── tender/
│   ├── 2026-05-29-bank-audit-agent.docx
│   ├── 2026-05-29-bank-audit-agent.meta.yaml
│   └── ...
├── brief/
│   ├── ...
├── proposal/
│   └── ...
```

`<doc-type>` subdirectory is required — keeps the archive scannable even at hundreds of deliverables. Slug `<YYYY-MM-DD>-<short-title>` keeps things chronological inside each type.

## When to migrate tiers

- **Project → team** — when you find yourself archiving the same kind of document for the same customer across multiple sub-projects. Move the project's `.compile-deliverables/` up one level, merge INDEX.md.
- **Team → global** — when you change role / company and want to take the corpus with you. Move to `~/.formal-doc-compiler-skill/deliverables/`.
- **Pruning** — periodically remove deliverables older than 18 months that haven't been referenced (track this manually for now).

## Redaction guidance

When archiving deliverables that contain client-specific content:

- **Slug** — never include raw client names. Use `<industry>-<doc-purpose>` (e.g., `bank-audit-agent` not `xingye-audit-agent`).
- **Meta `notable` / `lessons`** — describe the structural patterns, not the client situation.
- **The docx itself** — leave as-is unless the user flags external sensitivity. If they do, archive a redacted copy.

This keeps the archive useful as a structural reference without leaking customer detail across projects.
