---
name: git-commit
description: 提交信息规范（gitmoji + conventional commits，中文描述）。创建 git 提交或撰写提交信息时使用。
---

# 提交信息规范

完整的 emoji 对照表见 `/commit` 命令（`~/.dotfiles/agents/commands/commit.md`）。

## 格式

```
<emoji> <type>(<scope>)!: <描述>

<正文：为什么改、怎么改、影响（可选）>
```

- `scope` 可选，写模块 / 子项目名（`gateway`、`portal`、`config`、`deps` …）。
- `!` 表示破坏性变更（如 `♻️ refactor(config)!: …`），正文写明迁移方式。
- 描述用中文，一句话说清楚结果，不加句号；第一行不超过 72 个字符。
- 正文写动机和关键决策（例：「上游返回空体时 result 为 "null"，读取 parsed.error 抛 TypeError 致整页错误；先判空并补测试。」）。
- 不要加 AI 生成说明、`Co-Authored-By` 等 footer。

## 常用 emoji + type

| emoji   | type        | 用途                  |
| ------- | ----------- | --------------------- |
| ✨      | feat        | 新功能                |
| 🐛      | fix         | 修 bug                |
| 🩹      | fix         | 非关键的小修补        |
| 🔒️      | fix         | 安全问题              |
| ♻️      | refactor    | 重构                  |
| 🚚      | refactor    | 移动 / 重命名         |
| ⚡️      | perf        | 性能                  |
| 📝      | docs        | 文档                  |
| 💄 / 🎨 | style       | 样式 / 代码结构与格式 |
| ✅      | test        | 测试                  |
| 🔧      | chore       | 构建、配置、脚本      |
| 📌 / ⬆️ | chore(deps) | 锁定 / 升级依赖       |

## 拆分

- 一次提交只做一件事；功能、重构、文档、依赖升级混在一起时拆成多个提交。
- 提交前 lint / build / test 必须通过，不用 `--no-verify` 绕过钩子。
