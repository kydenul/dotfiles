---
name: testing-conventions
description: 测试规范（一个源文件一个测试文件、测试内容、运行方式、覆盖率门禁、提交前检查）。编写或修改测试，或提交前验证改动时使用。
paths: "**/*_test.go, **/*.test.ts, **/*.test.tsx"
---

# 测试规范

## 一个源文件一个测试文件

- `a.go` ↔ `a_test.go`（前端 `a.ts` ↔ `a.test.ts`）严格一一对应；禁止按类别拆文件（`a_stress_test.go`、`a_integration_test.go`、`a_lifecycle_test.go` 等）。
- 单元、集成、边界、并发、压力、benchmark 测试都写在同一个文件里，用函数名后缀区分：`TestOffline_AlreadyOfflineConflict`（边界）、`TestXxx_TrueConcurrency`（并发）、`TestXxx_HighN`（压力）。
- 加测试前先找已有的 `a_test.go`，有就追加，没有才新建；发现一个源文件对应多个测试文件时合并（`git mv` 主文件后追加其余内容，去重 import / helper，再编译验证）。
- 例外：每个源文件允许再有**一个** `package x_test` 外部测试文件（`ExampleXxx` / 黑盒用例），因为合并进内部包会产生 import cycle；`Config` 内联在主源文件时允许一个 `config_test.go`。

## 写什么测试

- 修 bug 先写能复现的回归测试，再修。
- 配置示例 / 入库 yaml 要有测试守护能被严格解码（字段改名漏改示例会直接失败）。
- 有输出格式的（生成代码、序列化结果）用 golden 文件锁定；跨实现的契约（如 Memory / Gorm 两种 Store）用同一套契约测试覆盖。
- 依赖真实外部服务的联调测试用环境变量开关（如 `XXX_LIVE=1`），默认跳过。

## 怎么跑

- 单个测试：`go test -v -run TestName ./path/to/pkg`；全量用 `-count=1` 禁用缓存。
- 集成测试用 build tag（`-tags integration`）隔离，跑在真实容器（MySQL / Redis）上；多个包共用同一个库时加 `-p 1` 串行，避免互相干扰。
- 覆盖率门禁 ≥ 80%；只启动装配的包（`cmd/<svc>`）从分母中排除。

## 提交前

- 提交前 `lint` / `build` / `test` 必须全部通过（仓库有 `.githooks` 时用 `make install-hooks` 或 `git config core.hooksPath .githooks` 启用）；不要用 `--no-verify` 绕过。
- 改到有集成测试守护的代码时必须在本地跑一遍集成测试；没跑的要在汇报里明说。
- 不得为了让测试通过而跳过、删除测试或削弱断言。
