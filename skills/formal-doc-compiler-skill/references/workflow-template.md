# Workflow template

Copy-pasteable task list for clients that have a task-list / progress mechanism (Claude Code & Cowork: TaskCreate; other clients: whatever step-tracking they offer, or a plain checklist in your reply). Adapt verbs to the specific deliverable.

## The standard tasks

```
1. 锚定角色 / 受众 / 语气
2. 锁定范围与详略（结构化提问一轮）
3. 文件分级（L1/L2/L3/L4）
4. 解析源材料
5. 综合事实 + 设计大纲
6. 大纲确认（用户过目，秒级改向的检查点）
7. 加载输出格式参考（docx / xlsx / pptx）
8. 撰写正文（内容 JSON + 渲染脚本分离）
9. 三层校验（合规 / 格式 / 视觉）
10. 交付
```

## When to add tasks

- **>15 source files** — split 解析 into "L1 解析", "L2 解析", "L3 扫读"
- **Multiple output formats** — split 撰写 per format
- **High-stakes deliverable (legal, regulatory)** — add an "外部专家送审" task between 校验 and 交付
- **Recurring deliverable** — add a final task to archive the deliverable for few-shot reuse

## When to collapse tasks

- **<3 source files** — collapse 文件分级 + 解析 into a single "读取并理解材料" task
- **Single-page summary** — collapse 设计大纲 + 大纲确认 + 撰写 into "撰写"
- **Internal-only, low-formality** — skip the compliance sub-check inside 三层校验

## Naming convention

Use Chinese verbs in imperative form for visibility in the user's task panel. Active form (the verb used while the task is running) should be a short progressive: 锚定 → 锚定中, 解析 → 解析中.
