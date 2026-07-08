# formal-doc-compiler-skill · 方案撰写技能

把一个装满杂乱源材料的文件夹，编译成一份可交付的正式文档。

适用的工作场景：你手头有 10–30 个类型、重要性各不相同的文件——会议纪要、技术说明、客户需求、规划草稿、录音转写——需要产出**一份**以这些材料为依据的权威长文档。典型交付物：招标/RFP 技术需求书、方案书、白皮书、研究简报、项目总结、董事会备忘录。

跨客户端可用：Claude Code（CLI）、Claude Cowork（桌面版）、OpenAI Codex CLI、Trae（字节 AI IDE）、Google Antigravity、任何支持导入 Claude 格式 `.plugin` 文件的第三方客户端，以及任何有文件访问能力的通用 LLM Agent。

---

## 核心能力

- **9 步编译工作流**：锁定范围（含可选篇幅目标）→ 文件分级 → 解析 → 综合 → 大纲（含用户确认检查点）→ 撰写 → 分层校验（合规/格式/视觉，应标类加需求追溯共四层）→ 交付
- **L1–L4 文件分级**：不把上下文浪费在低信号文件上
- **合规扫描器**：按项目词表扫描违禁词（第三方品牌、竞品、具体模型名、硬性指标、日期等），大小写/全半角不敏感，支持正则
- **双向需求追溯（应标专用）**：覆盖校验（招标条款逐条有响应，输出未覆盖条款表）+ 超承诺校验（方案承诺逐条有依据，输出无依据承诺表，并核查范围排除等保护性条款未被误删）+ 逐条响应表引用完整性（每轮修改后复查）；多源冲突时强制指定权威依据文件；页数目标验证（soffice→pdfinfo，含 docx-js 目录域在 LibreOffice 下渲染为空的占页预留）
- **中文公文排版**：黑体标题、宋体正文、首行缩进两字符、（一）（二）（三）条款编号，docx-js 参数与辅助函数直接可用
- **Few-shot 归档库**：交付过的好文档存档为结构参考，越用越懂你的行文习惯
- **内容与代码分离**：正文放 JSON 数据文件，生成脚本只负责渲染——全角引号转义 bug 从根上消失

---

## 各客户端安装方法

### Claude Code（CLI）

本仓库本身就是一个 Claude 插件 + marketplace，两条命令从 GitHub 直接安装：

```bash
claude plugin marketplace add sunfeihu007/formal-doc-compiler-skill
claude plugin install formal-doc-compiler-skill@formal-doc-compiler
```

验证：`claude plugin list` 应出现 `formal-doc-compiler-skill`；新会话里输入 `/compile`。

CLI 版本太旧或受限环境？克隆后运行 `bash install/install-claude-code.sh`，脚本会自动降级到 `~/.claude/skills/` 目录安装。详见 [adapters/claude-code.md](adapters/claude-code.md)。

### Claude Cowork（桌面版）

```bash
git clone https://github.com/sunfeihu007/formal-doc-compiler-skill
cd formal-doc-compiler-skill
bash install/install-claude-cowork.sh
```

脚本会给出 `dist/formal-doc-compiler-skill-<版本>.plugin` 的位置；在 Cowork 里打开该文件，点击卡片上的 **Save plugin** 即可。详见 [adapters/claude-cowork.md](adapters/claude-cowork.md)。

### OpenAI Codex CLI

```bash
git clone https://github.com/sunfeihu007/formal-doc-compiler-skill
cd formal-doc-compiler-skill
bash install/install-codex.sh
```

脚本会把工作流接入 `~/.codex/AGENTS.md`，并安装 `/compile`、`/archive` 两个 prompt。详见 [adapters/codex.md](adapters/codex.md)。

### Trae（字节 AI IDE）

```bash
git clone https://github.com/sunfeihu007/formal-doc-compiler-skill
cd 你的工作项目目录
bash <克隆路径>/install/install-trae.sh
```

脚本会把 bundle 放到 `~/agent-skills/`，并把规则块写入当前项目的 `.trae/rules/project_rules.md`；同时打印一份同样的规则块，粘到 Trae → 设置 → 规则 → 用户规则（user_rules.md）里即可对所有项目生效。详见 [adapters/trae.md](adapters/trae.md)。

### 只支持导入插件的第三方客户端

任何能导入 Claude 格式 `.plugin` 文件（zip：`.claude-plugin/plugin.json` + `skills/` + `commands/`）的客户端：

```bash
bash build.sh        # 生成 dist/formal-doc-compiler-skill-<版本>.plugin
```

然后用客户端自己的插件导入方式（导入/打开/拖拽）加载该文件。详见 [adapters/plugin-file.md](adapters/plugin-file.md)。

### Google Antigravity

```bash
bash install/install-antigravity.sh    # 追加到 Antigravity 的 rules 文件
```

详见 [adapters/antigravity.md](adapters/antigravity.md)。

### 其他任意客户端

```bash
bash install/install.sh        # 自动探测客户端；探测到多个会让你选
# 或者
bash install/install-generic.sh   # 放置 bundle 并打印接线用的规则块
```

把打印出的规则块粘进客户端的"自定义指令 / 系统提示词"配置即可。没有本地文件能力的客户端见 [adapters/generic.md](adapters/generic.md) 的降级方案（直接粘贴 SKILL.md 或走 GitHub raw URL）。

### 最省事的方式：让 Agent 自己装

把下面这段话直接发给你的 AI 客户端：

```
请安装这个技能包：
https://github.com/sunfeihu007/formal-doc-compiler-skill

按 AGENT-INSTALL.md 里的说明操作。
```

Agent 会自己判断运行在哪个客户端里、读对应的 `adapters/<client>.md`、执行安装并验证。

---

## 用法

```
/compile ./tender-materials/ tender
```

或者直接说："基于这个文件夹里的材料，写一份招标技术需求书"。

一次典型运行：

```
1. 锚定    —— 确认输出语言、目标读者（上下文已明确则跳过）
2. 锁范围  —— 一轮提问：哪些章节、详略如何
3. 分级    —— 14 个输入文件排出 L1/L2/L3/L4 阅读计划
4. 解析    —— python-docx / pdftotext 并行解析 L1/L2 文件
5. 综合    —— 读取归档的 few-shot 范例，拟出 11 章大纲
   ↳ 大纲每章一行给你过目："第七章并进第六章" —— 秒改
6. 载入格式 —— docx 格式参考 + 中文公文排版参数
7. 撰写    —— 章节内容写成 JSON 数据文件 + 一个渲染脚本，运行生成
8. 校验    —— 合规：59 个词条 0 命中；格式：schema 通过；视觉：目录页+表格页渲染抽查
9. 交付    —— 成品移入工作目录，汇报：36 页，2.1 万字
```

交付后可 `/archive` 把这份文档存进 few-shot 库，供下次同类任务参考。

### 合规词表

词表放在项目里：`<项目>/.compliance/wordlist.yaml`（从 `templates/wordlist-starter.yaml` 复制起步）。词条默认按字面匹配（大小写、全半角不敏感）；正则用 `regex:` 前缀显式声明。注意不要在 CJK 字符旁用 `\b`（会静默漏报）。

```yaml
categories:
  third_party_brands:
    suggested_replacement: "某主流行情工具"
    terms:
      - Wind            # 字面匹配，wind / WIND / Ｗｉｎｄ 都能抓到
  hard_metrics:
    suggested_replacement: "以实施方案共同评估为准"
    terms:
      - "regex:\\d+\\s*并发"
```

---

## 仓库结构

仓库根目录**就是** Claude 插件——`skills/` 与 `commands/` 是所有客户端共用的唯一内容源，不存在会漂移的第二份拷贝。

| 组件 | 用途 |
|---|---|
| `skills/formal-doc-compiler-skill/` | 9 步主工作流 |
| `skills/file-triage/` | L1–L4 文件分级规则 |
| `skills/compliance-check/` | 违禁词扫描流程（黑名单方向） |
| `skills/requirement-traceability/` | 应标文档双向需求追溯（覆盖 + 超承诺 + 响应表引用） |
| `skills/cn-formal-style/` | 中文公文排版参数与 docx-js 辅助函数 |
| `commands/compile.md` · `commands/archive.md` | `/compile`、`/archive` 入口 |
| `skills/*/references/` | 各技能按需加载的深度参考 |
| `scripts/scan.py` | 合规扫描器（含测试：`python3 -m pytest tests/`） |
| `templates/wordlist-starter.yaml` | 空白词表脚手架 |
| `.claude-plugin/` | 插件 + marketplace 清单（Claude Code 直接从 GitHub 装） |
| `adapters/` | 每个客户端一份的接入说明 |
| `install/` | 自动化安装脚本（`install.sh` 为总入口） |
| `build.sh` | 从源码构建 `dist/*.plugin`（同步版本号、校验 frontmatter） |

---

## 环境要求

- **Python 3.10+**：`pyyaml python-docx python-pptx openpyxl`，以及 `pdftotext`（Poppler）
- **Node.js 18+**：`npm install docx`（按项目、生成 .docx 时装）
- **LibreOffice**：PDF 转换 / 视觉校验用

安装脚本会自动装 Python 依赖：先试 `pip --user`，系统 Python 受管则建 venv（`~/.formal-doc-compiler-skill/venv`），**不会**使用 `--break-system-packages`。

---

## 开发

- 改内容：直接编辑 `skills/*/SKILL.md` / `commands/*.md`——只有这一份
- 重新打包插件：`bash build.sh`
- 扫描器测试：`python3 -m pytest tests/`
- 新客户端适配：在 `adapters/` 加一份说明 + `install/` 加脚本 + 在 `install.sh` 的 `detect_clients()` 注册 + 更新本 README

版本号只有一个：`VERSION`（当前 `0.4.0`），`build.sh` 自动同步进插件清单。变更记录见 [CHANGELOG.md](CHANGELOG.md)。

## 许可

MIT，见 `LICENSE`。
