---
description: "Compile a polished formal document from a folder of source materials"
argument-hint: "[folder-path] [doc-type]"
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "TaskCreate", "TaskUpdate", "TaskList", "AskUserQuestion"]
---

# /compile — drive the source-to-document workflow

This command is the entry point for the `formal-doc-compiler-skill` skill. Invoke it whenever the user wants to build a formal document grounded in a set of source files.

## What to do when this command fires

1. Invoke the `formal-doc-compiler-skill` skill — it owns the 9-step workflow. Do not re-implement the steps here.

2. If the user provided arguments after `/compile`, parse them:
   - First argument: source folder path. If absent, use the user's current working folder.
   - Second argument (optional): document type hint — `tender`, `proposal`, `whitepaper`, `brief`, `summary`. Use this to bias the clarification questions toward the right scope/depth defaults.

3. If no source folder was given and the working folder has no source files, ask once whether they want to point at a folder or attach files now.

4. Run the workflow per the skill. The skill knows when to invoke `file-triage`, `compliance-check`, and `cn-formal-style` as sub-skills.

5. At the end, surface the deliverable (Cowork: `present_files`; CLI clients: state the absolute path) and offer to run `/archive` to save it as a reusable few-shot example.

## Argument examples

- `/compile` — use current folder, ask for doc type
- `/compile ./tender-materials/` — use that folder, ask for doc type
- `/compile ./tender-materials/ tender` — use that folder, scope as tender
- `/compile . whitepaper` — current folder, scope as whitepaper

## Default behavior

If the user typed just `/compile` with no other context and no source files in the working folder, default to asking:

1. Where are the source materials? (folder path / upload / paste)
2. What kind of document do you need? (tender / proposal / whitepaper / brief / summary / other)
3. Output language? (中文 / English / both)

Two of these three are usually answerable from context — only ask what's actually unknown.
