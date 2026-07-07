---
name: requirement-traceability
description: "Bidirectional requirement traceability for bid-response / tender-response documents (应标方案、投标响应、逐条应答). Use whenever the deliverable must respond to an authoritative requirements document — a tender / RFP / 招标文件 / 需求书. Two directions, both mandatory: coverage (every clause in the tender is responded to somewhere in the draft — output an uncovered-clauses table) and over-promise (every commitment in the draft is backed by a tender clause — output an unbacked-promises table; also verify protective scope-exclusion clauses weren't deleted). Includes the response-table cross-reference rule: documents containing a 逐条响应表 must re-verify referenced sections after every revision round. Ordinary technical proposals with no tender to respond to do NOT need this — use compliance-check alone."
---

# Requirement traceability — bidirectional response verification

## When this fires

The deliverable is a **response document**: an 应标方案 / 投标响应 / 逐条应答 / any document whose job is to answer an authoritative requirements document (招标文件, RFP, 需求书, 邀标函). Typical triggers:

- "写一份应标方案 / 投标文件 / 响应文件"
- "检查响应覆盖 / 有没有漏应答"
- Implicit: Step 8 of the `formal-doc-compiler-skill` workflow when the doc type is response-class

**Ordinary technical proposals do not need this.** If there is no external requirements document the draft must answer to, skip this skill entirely — `compliance-check` (the blacklist scan) is enough.

## Why blacklist scanning isn't enough here

`compliance-check` answers "did we say something we must not say." Response documents fail in two *opposite* directions that a blacklist can't see:

1. **漏应答** — a tender clause nobody responded to. Evaluators score clause-by-clause; one uncovered mandatory clause can invalidate the bid.
2. **超承诺** — the draft promises things the tender never asked for (7×24 hotline, periodic inspection reports, free migration of a legacy system…). Every unbacked promise is free contractual liability. The same failure mode includes *deleting protective clauses* (范围排除, boundary statements) during revision — silently expanding your obligations.

## Inputs

- **The authoritative requirements document.** Exactly one file must be designated as authoritative (done in Step 2 of the compile workflow). If multiple source files state conflicting requirements (e.g. 需求书 says the client provides the database, 报价函 says you must deploy it), do not pick silently — stop and ask the user which document wins.
- **The current draft** (any revision round, not just the first).

## Procedure

### 1 — Extract the clause checklist (once, at parse time)

From the authoritative document, extract every requirement clause into a scratchpad file `requirements.md`:

```markdown
| # | 条款位置 | 条款摘要 | 强制性 |
|---|---------|---------|--------|
| R1 | 第三章 2.1 | 系统需支持单点登录对接行内统一认证 | 必须（"应"） |
| R2 | 第三章 2.4 | 提供不少于 2 次现场培训 | 必须（带★） |
| R3 | 附件二 | 建议支持国产化数据库 | 建议（"宜"） |
```

Mandatory-strength markers to catch: ★ / ▲ symbols, "必须 / 应 / 不得 / 须", versus "宜 / 建议 / 可". Keep clause wording close to verbatim — the mapping in step 2 depends on it.

This file is the traceability baseline for **all** later rounds. Do not regenerate it from memory; re-read it.

### 2 — Coverage check (tender → draft)

For each clause in `requirements.md`, find the draft section that responds to it. Output the gaps:

```markdown
### 未覆盖条款
| # | 条款摘要 | 强制性 | 建议处理 |
|---|---------|--------|---------|
| R7 | 提供源代码托管方案 | 必须 | 新增 5.3 节响应，或与用户确认是否偏离 |
```

A mandatory clause with no response **blocks delivery** — same severity as a compliance hit. Advisory clauses ("宜") go in the table too, marked as user's call.

Also flag **weakened answers**: the clause says 须/应 but the draft responds with 尽量 / 配合 / 支持 without committing. Weakened wording does not reduce the obligation — it just reads as evasive to evaluators. List these next to uncovered clauses, severity one notch lower.

### 3 — Over-promise check (draft → tender)

Scan the draft for commitment-shaped statements and verify each maps back to a clause. Pattern signals worth flagging for semantic review (not a mechanical list — judge each in context):

- Service levels: 7×24 / 全天候 / X 小时内响应 / X 小时内到场 / 驻场
- Recurring obligations: 定期巡检 / 定期报告 / 每月 / 每季度
- Absolutes: 免费 / 无限 / 不限量 / 终身 / 永久 / 全部承担
- Scope creep: 整合 / 迁移 / 改造 existing systems the tender didn't mention
- Warranty: 质保 X 年 beyond the tender's requirement
- **Either-of upgrades**: the clause says "A 或 B" and the draft promises A **and** B. Possibly a deliberate scoring differentiator — surface it so the user chooses consciously, don't auto-cut.
- **Unconditioned resource-dependent claims**: capabilities that depend on client-provided resources (高可用 / 多副本 / 容灾 on the client's servers) promised without a conditioning phrase like "在招标人提供资源满足的前提下".

```markdown
### 无对应要求的承诺
| 位置 | 承诺内容 | 招标依据 | 建议处理 |
|------|---------|---------|---------|
| 6.2 节 | 7×24 热线支持 | 无（招标只要求 5×8） | 降为 5×8，或经用户确认保留 |
```

Also verify **protective clauses survived revision**: if an earlier round contained scope exclusions / boundary statements / assumptions (范围排除、边界声明、前提假设), confirm they still exist in the current draft. A deleted exclusion is an implicit new promise.

Each finding is resolved one of two ways only: revise the draft, or the user explicitly approves keeping it. Never silently accept.

### 4 — Response-table cross-reference check (every round)

If the document contains a 逐条响应表 (clause-by-clause response table), then **after every revision round** verify that every section/paragraph the table references still exists and still says what the table claims. Deleting a paragraph that a response-table row points at is the classic silent failure — the table keeps asserting a response that is no longer in the document.

This check re-runs on *every* edit, not just the first draft. It is cheap (minutes) and the failure it catches is disqualifying.

Practical recipe for any revision round: extract both versions to plain text (`pandoc -t plain --wrap=none old.docx / new.docx`) and `diff` them first — the diff localizes every check in this skill to what actually changed, and surfaces silent deletions the user didn't mention.

### 5 — Report

Output both tables (未覆盖条款 / 无依据承诺) plus the cross-reference result. Zero findings: one line — `追溯 OK — N 条条款全覆盖，无超范围承诺，响应表引用完整。`

## Relationship to the compile workflow

- Step 2 designates the authoritative document (and resolves source conflicts).
- Step 4 extracts `requirements.md` while parsing the authoritative file.
- Step 8 runs this skill as the second of **four** verification layers for response docs: compliance (blacklist) → traceability (this skill) → format → visual.
- Any unresolved finding blocks Step 9 delivery.
