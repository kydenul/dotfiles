---
name: go-style
description: Go 编码规范（格式、错误处理、资源与并发、日志级别）。编写或修改 Go 代码时使用。
paths: "**/*.go"
---

# Go 编码规范

以项目的 `.golangci.yaml` 为准；没有时按以下默认。

## 格式与签名

- 行宽 120；格式化用 `gofumpt`，提交前 lint 必须干净。
- `context.Context` 作首个参数，`error` 作最后返回值；不要把 ctx 存进 struct。
- 禁止裸 `return`；用 `any` 不用 `interface{}`；禁止空白导入（`_` 注册驱动等除外）。
- 函数 ≤ 150 行 / 100 语句，圈复杂度 ≤ 24；超了就拆。

## 错误

- 错误必须处理，类型断言要检查 ok；用 `%w` wrap，比较用 `errors.Is/As`。
- 哨兵错误以 `Err` 前缀命名，error 类型以 `Error` 后缀命名。
- 检查了 `err != nil` 就不要返回 nil 或另一个 nil 错误。

## 资源与并发

- HTTP 请求必须带 ctx（`NewRequestWithContext`）；关闭 `resp.Body`、`sql.Rows`、`sql.Stmt`，并检查 `rows.Err()`。
- 不要在循环里累积 `context.WithValue`；不用非继承来的 context。
- 后台 goroutine 不在 `net/http` 的 panic 兜底范围内，必须自行 recover 并释放其持有的锁 / 资源。
- 别用 ctx 取消去打断 Redis `XREAD BLOCK` 等阻塞读：go-redis 会销毁被打断的连接。

## 日志

- `error` 级只留给需改配置 / 代码才能恢复的启动期问题；请求级失败一律 `warn` + 完整字段，失败率交给指标告警。
- 排查细节用 `debug` 级（配合热更日志级别），不要靠「加日志—重新部署」。
- `//nolint` 必须指明具体 linter 并写明原因。
