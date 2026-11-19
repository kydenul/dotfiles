---
name: go-service
description: Go 后端服务工程约定（复用 aura 组件、per-project 配置、可选组件降级、运维端口、可观测性）。新建或装配 Go 服务、修改 cmd/、aura.yaml 配置或 Makefile 时使用。
paths: "**/cmd/**, **/aura*.yaml, **/Makefile"
---

# Go 服务工程约定

## 复用公共组件

- 鉴权 / 限流 / 日志 / 链路 / 配置 / DB / Redis / CLS / cron / 出站 HTTP 优先用 `git.woa.com/kydenlu/aura/*`，不要在业务仓重复造轮子。
- 协议转码（gRPC↔HTTP）用 grpc-gateway 等适配库，不手写映射。
- 内网模块拉取依赖 `GOPROXY=goproxy.woa.com` + 内网 `GOSUMDB`；构建报 `parsing git.woa.com/...: XML syntax error` 时先查 `go env GOPROXY` 是否被重置。

## 配置（per-project）

- 每个 `cmd/<svc>/` 只放两份 yaml：`aura.yaml`（部署用，入库，各环境共用，差异项经 `${ENV}` 注入，文件头写环境变量对照表）+ `aura.local.yaml`（本地调试，gitignore，dev 时优先加载）。不按环境分叉文件。
- Go 配置结构放模块根 `config/`，不放 yaml；yaml 出现未知顶层键应加载失败（严格模式）。
- 可选组件（metrics / tracing / DB …）默认关，yaml 显式 `enabled: true` 才启用；可选依赖不可用时降级对应功能，不放大成整个服务不可用。
- 明确区分【热更生效】与【需重启】的配置项，并在文档中标注。

## 进程与可观测性

- 业务端口与运维端口（`/metrics` `/healthz` `/readyz` `/debug/pprof`）隔离。
- 日志 + 链路 + 指标三支柱，`trace_id` 自动注入日志字段，业务零埋点。
- 每个出站 HTTP client 都挂请求 / 响应 dump（debug 级、默认脱敏）。
- 根 `Makefile` 只做编排，编译 / 运行 / 单测下沉到各 `cmd/<svc>/Makefile`。
