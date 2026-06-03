# Adapter — Claude Code (CLI)

Claude Code uses the same plugin format as Cowork. You have two install routes.

## Path A — install via `claude` CLI

If a prebuilt `.plugin` file is available:

```bash
claude plugin install <bundle-root>/dist/formal-doc-compiler-skill-0.2.0.plugin
```

The Claude Code CLI handles unpacking and registration. Confirm with:

```bash
claude plugin list
```

`formal-doc-compiler-skill` should appear with version `0.2.0`.

## Path B — symlink for live development

If the user wants to edit the bundle and have changes take effect immediately:

```bash
# Make sure the plugin layout exists (build it from the bundle if not)
# Then symlink it into Claude Code's plugin directory
BUNDLE_ROOT=<bundle-root>
mkdir -p ~/.claude/plugins
ln -s "$BUNDLE_ROOT" ~/.claude/plugins/formal-doc-compiler-skill
```

Note: this assumes the bundle root itself follows Claude Code's plugin layout. The bundle has both — a top-level `instructions/` for client-neutral use, AND it can be built into the Cowork plugin layout via `adapters/claude-cowork.md` Path C. For Claude Code, the simplest is to use Path A's installer; symlinking the raw bundle won't register skills unless you also build a `.claude-plugin/plugin.json` and `skills/*/SKILL.md` layout.

## Path C — start from raw bundle (advanced)

If only the raw bundle is available, build the plugin layout first using the steps in `adapters/claude-cowork.md` Path C, then install via Path A above.

## Verification

```bash
claude plugin list
# Expected: formal-doc-compiler-skill@0.2.0
```

In an interactive session:
```
> /compile --help
```

Should show the command's argument hints.

## Uninstall

```bash
claude plugin uninstall formal-doc-compiler-skill
```

or remove the symlink:

```bash
rm ~/.claude/plugins/formal-doc-compiler-skill
```

## Troubleshooting

- **`claude plugin install` errors with "invalid manifest"** — the `.plugin` file isn't a valid zip with the expected layout. Use Path C to rebuild.
- **`/compile` recognized but workflow doesn't trigger** — make sure the working directory has source files. The skill checks file count before activating its main workflow.
- **`python3` errors during compliance scan** — install dependencies:
  ```bash
  pip install pyyaml python-docx python-pptx openpyxl --break-system-packages
  ```
