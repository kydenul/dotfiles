# 复用 tclaude 网关给原生 Claude Code

把 `tclaude` 的本地网关代理出来，供原生 `claude` / cc-switch 使用。

> ⚠️ **先读这个**：本方案把公司内部 AI 额度（`copilot.tencent.com`，iOA SSO 鉴权、按 credits 计费）
> 转给通用客户端使用。`product.json` 里 `telemetry.report.standard.enabled: true`，用量是上报的。
> 技术上完全可行且已验证，但**是否符合内部使用政策请自行确认**。

---

## 1. 原理

`tclaude` 不是独立产品，而是 **官方 Claude Code + 一层壳**：

```
/opt/homebrew/lib/node_modules/@tencent/tclaude/
├── package.json     → 依赖 "@anthropic-ai/claude-code": "2.1.154"
├── product.json     → 覆写端点 / 模型 / 鉴权方式
└── dist/tclaude.js  → 壳逻辑（4MB webpack bundle）
```

`product.json` 声明了上游：

```json
{
  "endpoint": "https://copilot.tencent.com",
  "authentication": {
    "attributes": {
      "usernameHeader": "X-User-Id",
      "tokenHeader": "Authorization",
      "tokenType": "bearerToken",
      "prefixPath": "/plugin"
    }
  }
}
```

真正的机制在 bundle 里的 `GatewayProxyServerImpl` 与 `EnvPreparerInterceptor`。
后者反混淆后的核心是三行：

```js
en.env.ANTHROPIC_BASE_URL = ec.url; // http://127.0.0.1:<port>
en.env.ANTHROPIC_AUTH_TOKEN = "placeholder"; // 占位符，真 token 由 daemon 注入
en.env.CLAUDE_CONFIG_DIR = es; // ~/.tclaude
```

启动流程：

```
tclaude
  │
  ├─ 1. daemonManager.ensureRunning()
  │      └─ spawn: node tclaude __tclaude_daemon   (detached, unref)
  │            env: TCLAUDE_DAEMON_PORT=<port>
  │            └─ GatewayProxyServer.listen(port, "127.0.0.1")
  │
  └─ 2. 拉起真正的 claude-code，注入上面三个环境变量
           │
           ▼
     claude-code ──HTTP(Anthropic 协议)──▶ 127.0.0.1:<port>
                                              │
                                              │ 注入 Authorization: Bearer <真 token>
                                              │       X-User-Id: <uid>
                                              ▼
                                    https://copilot.tencent.com/plugin
```

**关键点：`ANTHROPIC_AUTH_TOKEN` 的值就是字符串 `"placeholder"`。**
鉴权完全在 daemon 内部完成，客户端不需要任何凭证——这是代理可被复用的根本原因。

## 2. Daemon 契约

从 bundle 中提取的常量（模块 `50092`）：

| 项           | 值                                                                 |
| ------------ | ------------------------------------------------------------------ |
| 内部启动参数 | `__tclaude_daemon`                                                 |
| 端口环境变量 | `TCLAUDE_DAEMON_PORT`（**必需**，缺失则 daemon 抛错退出）          |
| 健康检查     | `GET /__tclaude/health` → `{"ok":true,"pid":N,"version":"x"}`      |
| 停止         | `POST /__tclaude/stop`                                             |
| 元数据       | `~/.tclaude/daemon.json`（pid / port / url / version / startedAt） |
| 端口缓存     | `~/.tclaude/daemon.port`                                           |
| 启动锁       | `~/.tclaude/locks/daemon.lock`                                     |

端口分配逻辑（`acquirePort`）：

```js
let en = await this.metadataStore.readPort(); // 先读 daemon.port
if (en)
  try {
    return await this.probePort(en);
  } catch (en) {}
let ei = await this.probePort(0); // 失败则让 OS 随机分配
await this.metadataStore.writePort(ei); // 并写回 daemon.port
```

所以端口是**尽力保持稳定，但不保证**。本机 `daemon.port` = `51247`，已稳定两个月未变。
**脚本必须动态读取 `daemon.json`，不要硬编码端口。**

## 3. 验证记录

`/v1/models`（本地 handler，无需鉴权即可读）：

```
claude-opus-5[1m]         claude-opus-4-8[1m]        claude-sonnet-5[1m]
claude-kimi-k3[1m]        claude-glm-5.2[1m]         claude-deepseek-v4-pro[1m]
claude-deepseek-v4-flash[1m]                         claude-hy3
```

`/v1/messages` 首次请求失败，daemon 日志给出确切原因：

```
[Error] [tclaude] X-Claude-Code-Session-Id is required
        [GatewayProxyServer] forward failed for POST /v1/messages
```

补上该 header 后成功返回 SSE 流：

```bash
curl -s -X POST http://127.0.0.1:51247/v1/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer placeholder" \
  -H "anthropic-version: 2023-06-01" \
  -H "X-Claude-Code-Session-Id: 11111111-2222-3333-4444-555555555555" \
  -d '{"model":"claude-haiku-4-5","max_tokens":32,
       "messages":[{"role":"user","content":"Reply with exactly: PROXY_OK"}]}'
# → event: content_block_delta  {"text":"PROXY_OK",...}
```

原生 `claude` 二进制（2.1.235）本身就带 `X-Claude-Code-Session-Id`（grep 命中 5 处），
因此**零改造兼容**。端到端验证：

```bash
ANTHROPIC_BASE_URL=http://127.0.0.1:51247 \
ANTHROPIC_AUTH_TOKEN=placeholder \
ANTHROPIC_MODEL=claude-haiku-4-5 \
CLAUDE_CONFIG_DIR=/tmp/cc-proxy-test-1 \
claude -p "Reply with exactly: NATIVE_CLAUDE_VIA_TCLAUDE_OK"
# → NATIVE_CLAUDE_VIA_TCLAUDE_OK
```

## 4. 接入 cc-switch

cc-switch（v3.20.0，`~/.cc-switch/cc-switch.db`）的 provider 存储结构极简：

```sql
sqlite> select id, app_type, settings_config from providers;
claude-official|claude|{"env":{}}
```

切换 provider 的本质就是把 `settings_config.env` 写进 `~/.claude/settings.json`。
所以在 CC Switch 里新建一个 Claude provider，配置填：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:51247",
    "ANTHROPIC_AUTH_TOKEN": "placeholder",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-8[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-6[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4-5"
  }
}
```

端口若变化，用 `tclaude-proxy sync-ccswitch` 自动同步（见下）。

### cc-switch 自带的代理层

数据库里还有 `proxy_config` 表，说明 cc-switch **自己也有**一套本地代理，
默认监听 `127.0.0.1:15721`，带故障转移 / 熔断 / 成本统计：

```
proxy_enabled=0  listen_port=15721  auto_failover_enabled=0
max_retries=6    circuit_failure_threshold=8   pricing_model_source=response
```

当前 `settings.json` 里 `enableLocalProxy: false`，关着。若开启则形成两层代理：

```
claude → 15721 (cc-switch) → 51247 (tclaude) → copilot.tencent.com
```

好处是能拿到 token 用量与成本统计（`proxy_request_logs` 表，目前为空）。
代价是多一跳、多一个故障点。建议先跑通单层再考虑。

## 5. 操作步骤

### 前置：PATH

`.zshrc` 里已加入（新开 shell 生效，或 `source ~/.zshrc`）：

```bash
export PATH="$HOME/.dotfiles/script:$PATH"
```

之后 `tclaude-proxy` / `tclaude-proxy-agent.sh` 可直接调用，无需全路径。

### 前置：确认 daemon 活着

daemon 由 `tclaude` 启动时拉起。若从没跑过 `tclaude`，先跑一次让它起来：

```bash
tclaude-proxy status      # healthy 就行
tclaude-proxy ensure      # 不 healthy 时用这个拉起
```

`ensure` 报错且提示未登录，则先 `tclaude login`。

### 步骤 1：拿到当前端口

```bash
tclaude-proxy url         # → http://127.0.0.1:51247
```

**不要凭记忆填端口**，每次都用这个命令取（原因见 §2）。

### 步骤 2：在 CC Switch 里新建 Claude provider

打开 CC Switch → Claude 分类 → 新增供应商，配置填：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:51247",
    "ANTHROPIC_AUTH_TOKEN": "placeholder",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-8[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-6[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4-5"
  }
}
```

`ANTHROPIC_BASE_URL` 换成步骤 1 的实际输出。名字建议叫 `tclaude-gateway`，
一眼能看出走的是内部网关。

> `ANTHROPIC_AUTH_TOKEN` 填 `placeholder` 就行，**这不是密钥**。
> 真 token 由 daemon 注入，客户端不需要任何凭证（见 §1）。

### 步骤 3：切过去并验证

在 CC Switch 里点选该 provider，然后：

```bash
tclaude-proxy doctor
```

六项全绿即可用。第 6 项会检查 `~/.claude/settings.json` 是否真的指向了当前端口
——这是确认 CC Switch 写入成功的最快方式。

### 日常使用

```bash
claude                    # 正常用，走内部网关
tclaude-proxy status      # 出问题先看这个
tclaude-proxy doctor      # 完整体检
```

### 端口漂移后的修复

`claude` 突然连不上，先查端口是否变了：

```bash
tclaude-proxy sync-ccswitch          # 只预览，会告诉你差异
tclaude-proxy sync-ccswitch --apply  # 确认后写入 ~/.claude/settings.json
```

`--apply` 会顺手备份到 `settings.json.bak`。注意它改的是 `~/.claude/settings.json`，
**CC Switch 里存的 provider 配置仍是旧端口**，下次切换会覆盖回去
——所以端口变了之后，记得回 CC Switch 把 provider 里的 URL 也改掉。

### 其它用法

```bash
eval "$(tclaude-proxy env)"   # 只给当前 shell 导出，不碰任何配置文件
```

### 可选：装 launchd 守护

不装也能用，代价是 daemon 挂掉后要手动 `tclaude-proxy ensure`。要装：

```bash
tclaude-proxy-agent.sh install     # 开机自启 + 每 5 分钟检查
tclaude-proxy-agent.sh status
tclaude-proxy-agent.sh logs
tclaude-proxy-agent.sh uninstall   # 卸载，不影响 daemon 本身
```

## 6. 坑与限制

**① daemon 生命周期不由你控制。**
它由 `tclaude` 启动时 `ensureRunning()` 拉起。若你只用原生 `claude` 而从不跑 `tclaude`，
daemon 挂掉后无人重启 → 这正是 `tclaude-proxy-agent.sh` 存在的理由。

**② 端口可能变化。** 见 §2。始终从 `daemon.json` 读取。
`tclaude-proxy sync-ccswitch` 会在端口漂移后重写配置。

**③ 401 会触发强制登出。** 转发层：

```js
401 === ea.status && this.handleSessionExpiry();
//   → userSessionProvider.logout()
//   → "Session expired. Please re-run the command to sign in again."
```

上游返回 401 时 daemon 会主动清掉本地登录态，需重新 `tclaude login`。
**守护脚本不能靠重启解决这个问题**——重启后依然未登录。故 `doctor` 会区分
"daemon 挂了"（可自动修）与"登录态失效"（必须人工 `tclaude login`）。

**④ `X-Claude-Code-Session-Id` 必需。** 原生 claude 自带；但自己写 curl / SDK 调用时必须补上，
否则一律 `{"error":{"message":"Failed to reach upstream gateway","type":"upstream_error"}}`
——这个错误信息**具有误导性**，真实原因只在 `~/.tclaude/logs/<date>/*.log` 里。

**⑤ tcodex 当前跑不通。** `~/.tcodex` 配置目录还在（`model = "deepseek-v4-flash-ioa"`），
但 CLI 已卸载：`/opt/homebrew/lib/node_modules/@tencent/` 下只剩 `tclaude`，`which tcodex` 无结果。
且 codex 走 OpenAI Responses 协议，与 Anthropic 协议不通，**不能共用此 daemon**。
要代理 codex 需重装 CLI 并另做协议转换。

**⑥ 重启 daemon 会中断正在运行的会话。** 包括通过该 daemon 运行的 Claude Code 自身。
`restart` 前先确认没有活跃会话。

## 7. 参考

| 路径                                                           | 说明                                      |
| -------------------------------------------------------------- | ----------------------------------------- |
| `/opt/homebrew/lib/node_modules/@tencent/tclaude/product.json` | 端点、模型表、鉴权配置                    |
| `~/.tclaude/daemon.json`                                       | 当前 daemon pid / port / url              |
| `~/.tclaude/logs/<date>/*.log`                                 | daemon 日志（转发失败的真实原因在这里）   |
| `~/.cc-switch/cc-switch.db`                                    | cc-switch provider / proxy 配置（SQLite） |
| `~/.cc-switch/settings.json`                                   | `enableLocalProxy` 等开关                 |
