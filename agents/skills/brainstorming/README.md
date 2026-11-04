# brainstorming

从 [obra/superpowers](https://github.com/obra/superpowers/tree/main/skills/brainstorming) 单独移植的 brainstorming skill（MIT）。
在动手前先读项目、一次问一个问题弄清用户要什么和为什么、给出 2-3 个方案让用户选、写设计文档并获批，
然后交给 `planning-and-task-breakdown` 拆任务。

**来源：** `obra/superpowers@22f0b46`（2026-11-03）

## 与上游的差异

只改了文档，`scripts/` 与上游逐字节一致。

| 文件 | 改动 | 原因 |
|---|---|---|
| `SKILL.md` | description 重写：新功能/较大改动、头脑风暴/出点子、理清需求、讨论方案、写 spec/PRD 时触发，排除小改动、bug 修复、配置微调 | 上游的 "MUST use before any creative work" 是配合 `using-superpowers` 的 SessionStart hook 写的，单装时过宽；同类的 `interview-me` / `idea-refine` / `spec-driven-development` 已删除，由本 skill 统一负责 |
| `SKILL.md` | 正文新增 4 段：无人值守（CI/循环任务）时不开对话、只列阻塞项；用户要点子时先给约 5 个不同方向再收敛（Red Flags 表同步放宽）；要 spec/PRD 时补构建/运行/测试方式和边界；实现中改了决策就同步更新设计文档 | 承接被删 skill 的独有场景：interview-me 的非交互约束、idea-refine 的发散出点子、spec-driven-development 的 SPEC 内容和"保持文档最新" |
| `SKILL.md` | `superpowers:writing-plans` → `planning-and-task-breakdown`（2 处） | 单装时上游的下一步 skill 不存在，HARD-GATE 会走进死胡同 |
| `SKILL.md` | 设计文档路径 `docs/superpowers/specs/` → `docs/specs/`，且不自动 commit | 去掉品牌路径；commit 只在用户要求时做 |
| `visual-companion.md` | 说明 `scripts/` 要用 skill 目录的绝对路径调用；删掉 Codex / Gemini CLI / Copilot CLI / Windows 的启动说明 | shell 的 cwd 是用户项目而不是 skill 目录；只用 Claude Code 和 Pi |

可视化伴侣仍会在项目里建 `.superpowers/brainstorm/`（脚本未改名，方便与上游 diff），浏览器页头会加载 primeradiant.com 的 logo。

## 同步上游

```bash
git clone --depth 1 https://github.com/obra/superpowers.git /tmp/superpowers
diff -ru /tmp/superpowers/skills/brainstorming ~/.dotfiles/agents/skills/brainstorming
```

`scripts/` 可直接覆盖；`SKILL.md` 和 `visual-companion.md` 需要按上表手动合并，然后更新本文件的来源 commit。
