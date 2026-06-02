# Workflow template

Copy-pasteable TaskCreate task list. Adapt verbs to the specific deliverable.

## The 9 standard tasks

```
1. 锚定角色 / 受众 / 语气
2. 锁定范围与详略(AskUserQuestion 一轮)
3. 文件分级(L1/L2/L3/L4)
4. 解析源材料
5. 综合事实 + 设计大纲
6. 加载输出格式 skill(docx / xlsx / pptx)
7. 撰写正文
8. 三层校验(合规 / 格式 / 视觉)
9. 交付
```

## When to add tasks

- **>15 source files** — split task 4 into "L1 解析", "L2 解析", "L3 扫读"
- **Multiple output formats** — split task 7 per format
- **High-stakes deliverable (legal, regulatory)** — add an "外部专家送审" task between 8 and 9
- **Recurring deliverable** — add a final task to `/archive` for few-shot reuse

## When to collapse tasks

- **<3 source files** — collapse tasks 3 + 4 into a single "读取并理解材料" task
- **Single-page summary** — collapse tasks 5 + 7 into "撰写"
- **Internal-only, low-formality** — skip task 8's compliance sub-check

## Naming convention

Use Chinese verbs in imperative form for visibility in the user's task panel. Active form (the verb used while the task is running) should be a short progressive: 锚定 → 锚定中, 解析 → 解析中.
