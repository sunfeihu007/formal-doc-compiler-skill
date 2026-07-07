# Red flags — common ways this workflow drifts

Catch these early. Each is a moment where the next agent step is likely to be wrong.

## Drift signals during clarification (Step 2)

- **More than one round of clarification questions.** If you find yourself wanting a second round, you are over-clarifying. Make a default and ask the user to correct it. (The Step 5.5 outline confirmation is a checkpoint, not a clarification round — it doesn't count.)
- **Question that conditions on data the user doesn't have yet.** Don't ask "should chapter 5 cover the 2024 figures?" if the user hasn't told you whether 2024 figures exist. Triage first.

## Drift signals during triage (Step 3)

- **Every file rated L1.** Triage failed. Force yourself to pick the single most-important file as L1 and downgrade others.
- **No L1 file at all.** You probably misread the user's intent. Ask which file is the primary basis.

## Drift signals during parsing (Step 4)

- **One bash result returns >40k characters.** Outsource to a subagent. Do not paste the result.
- **Same file parsed twice in the conversation.** Cache the distillate in your own thinking and reuse it.

## Drift signals during synthesis (Step 5)

- **Outline saved into the user's working folder.** The outline belongs in the scratchpad (`outline.md`), not among the user's files. Only the final deliverable lands in the working folder.
- **Starting to draft without showing the user the outline.** Step 5.5 exists because outline edits cost seconds and chapter rewrites cost hours. Skip it only for short documents or an explicitly hands-off run.
- **Outline has >12 top-level chapters.** Too much. Consolidate.
- **Outline depth doesn't match the Step 2 depth setting.** Re-read Step 2's answer before drafting.

## Drift signals during drafting (Step 7)

- **Trying to write a 700-line document directly.** Generate via script (Node.js + docx, or Python + openpyxl). Writing huge files directly fails on quote-escaping and Unicode normalization.
- **Document text embedded in the generation script.** Content belongs in JSON data files; the script only renders. Embedded Chinese text in JS string literals is where the quote-collapse bugs come from.
- **Hard-coding any specific brand / product / model / metric number that the user did not explicitly authorize.** Use the compliance wordlist as the default reference for what to avoid.

## Drift signals during verification (Step 8)

- **Skipping any of the three layers.** All three or the workflow fails. Be especially careful not to skip the visual layer.
- **Compliance scan hits, you decide they're "fine".** They are never fine. Either fix the document or update the wordlist with the user's explicit approval. Never silently accept.

## Drift signals during delivery (Step 9)

- **Reply > 200 words of summary.** The user has the document. Stop describing it. Offer next moves.
- **Forgetting to surface the deliverable.** Use your client's file-presentation mechanism (Cowork: `present_files`; CLI clients: state the absolute path). A document the user can't find wasn't delivered.
- **Leaving the build script / intermediate artifacts in the user's working folder.** Clean up. Only the final document goes there.
