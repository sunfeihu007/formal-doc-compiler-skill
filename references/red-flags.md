# Red flags — common ways this workflow drifts

Catch these early. Each is a moment where the next agent step is likely to be wrong.

## Drift signals during clarification (Step 2)

- **More than one round of AskUserQuestion.** If you find yourself wanting a second round, you are over-clarifying. Make a default and ask the user to correct it.
- **Question that conditions on data the user doesn't have yet.** Don't ask "should chapter 5 cover the 2024 figures?" if the user hasn't told you whether 2024 figures exist. Triage first.

## Drift signals during triage (Step 3)

- **Every file rated L1.** Triage failed. Force yourself to pick the single most-important file as L1 and downgrade others.
- **No L1 file at all.** You probably misread the user's intent. Ask which file is the primary basis.

## Drift signals during parsing (Step 4)

- **One bash result returns >40k characters.** Outsource to a subagent. Do not paste the result.
- **Same file parsed twice in the conversation.** Cache the distillate in your own thinking and reuse it.

## Drift signals during synthesis (Step 5)

- **Writing an outline document to disk.** The outline lives in your thinking, not in a file. Writing it down adds I/O without adding signal.
- **Outline has >12 top-level chapters.** Too much. Consolidate.
- **Outline depth doesn't match the Step 2 depth setting.** Re-read Step 2's answer before drafting.

## Drift signals during drafting (Step 7)

- **Trying to Write a 700-line document directly.** Generate via script (Node.js + docx, or Python + openpyxl). Writing huge files directly fails on quote-escaping and Unicode normalization.
- **Hard-coding any specific brand / product / model / metric number that the user did not explicitly authorize.** Use the compliance wordlist as the default reference for what to avoid.

## Drift signals during verification (Step 8)

- **Skipping any of the three layers.** All three or the workflow fails. Be especially careful not to skip the visual layer.
- **Compliance scan hits, you decide they're "fine".** They are never fine. Either fix the document or update the wordlist with the user's explicit approval. Never silently accept.

## Drift signals during delivery (Step 9)

- **Reply > 200 words of summary.** The user has the document. Stop describing it. Offer next moves.
- **Forgetting to call `present_files`.** Without this, the user can't open the deliverable on macOS.
- **Leaving the build script / intermediate artifacts in the user's working folder.** Clean up. Only the final document goes there.
