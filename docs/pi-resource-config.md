# 用 `pi config` 交互式开关 pi 资源

pi 启动时会从 `~/.pi/agent/settings.json`（全局）和 `<project>/.pi/settings.json`（项目）里
的 `packages` / `extensions` / `skills` / `prompts` / `themes` 收集要加载的资源。想临时关掉
其中某一条（比如 `@gotgenes/pi-permission-system` 的扩展），不用手改 JSON，用内置 TUI 点掉即可。

---

## 1. 打开

```bash
pi config            # 从全局设置开始（~/.pi/agent/settings.json）
pi config --local    # 从项目覆盖开始（.pi/settings.json）
```

`pi config` 必须跑在真实终端里（它是 TUI）。进入后顶部标题是
`Global Resources` 或 `Project Local Resources`，**Tab 随时切换**这两个作用域。

项目域默认要求项目被信任：第一次会弹 trust 提示，可先跑
`pi config --local --approve` 或 `pi --approve` 跳过。

## 2. 界面结构

资源按来源分组，组标题形如：

```text
npm:@gotgenes/pi-permission-system (user)     ← 包资源，括号里是作用域
User (~/.pi/agent)                            ← 自动发现的个人资源
Project (.pi/)                                ← 项目内自动发现的资源
Built-in                                      ← pi 内置扩展
```

每组下面按类型分子组：`Extensions` / `Skills` / `Prompts` / `Themes`。条目名有两种形式：

- 扩展文件在 `extensions/` 目录下 → 只显示文件名
- 扩展在别的目录里 → 显示 `父目录/文件名`

所以 `@gotgenes/pi-permission-system:src` 这条，实际是被包 manifest
`pi.extensions: ["./src/index.ts"]` 声明的那个文件，显示成 `src/index.ts`。
`:src` 不是包名的一部分，是资源相对包根的路径前缀。

## 3. 键位

| 键 | 作用 |
|---|---|
| `↑` `↓` | 在条目间移动 |
| 直接打字 | 按名字/类型/路径过滤列表 |
| `space`（全局域） | 切换该条目的开 / 关 |
| `space`（项目域） | 在 `inherit` → `+`（强制载入） → `-`（强制不载入） 之间循环 |
| `Tab` | 全局 / 项目作用域互切 |
| `esc` | 关闭 |

**按下 `space` 就立刻写盘**，没有额外的“保存”确认步骤。关掉 TUI 不会回滚已做的改动。

## 4. 它写成了什么

### 全局域：条目被改成对象形式 + 排除 pattern

原来的字符串条目：

```json
"packages": [
  "npm:pi-subagents",
  "npm:@gotgenes/pi-permission-system"
]
```

关掉那条扩展后变成：

```json
"packages": [
  "npm:pi-subagents",
  {
    "source": "npm:@gotgenes/pi-permission-system",
    "extensions": ["-src/index.ts"]
  }
]
```

pattern 前缀的语义：

| 前缀 | 含义 |
|---|---|
| `-path` | 精确排除某个资源 |
| `+path` | 精确包含某个资源（覆盖排除） |
| `!glob` | glob 排除 |
| 无前缀 / `path` | 普通包含（受 glob 规则影响） |
| `extensions: []` | 该类型一条都不加载 |

过滤器只能收缩包自身 manifest 已声明的范围，不能凭空引入包没声明的资源。
重新开关同名 pattern 时，写入前会先剔除旧条目，所以不会堆出重复项。

若某个包的所有类型数组都被清空，`pi config` 会把对象折叠回原来的字符串形式。

### 项目域：写 `+`/`-` 覆盖，不动全局

项目重开同名包时默认是**替换**全局条目。若项目条目带 `"autoload": false`，它才退化成
叠加过滤（delta）：从空开始，只应用显式列出的 pattern。手写这种纯过滤式覆盖：

`.pi/settings.json`

```json
{
  "packages": [
    {
      "source": "npm:@gotgenes/pi-permission-system",
      "autoload": false,
      "extensions": ["-src/index.ts"]
    }
  ]
}
```

删掉这个文件 / 这条条目就恢复原样，这是最接近“暂时禁用”的做法。
`pi config --local` 里按 `space` 循环到的 `-` 就是等价效果。

## 5. 恢复

再按一次 `space` 即可。全局域会写成 `"+src/index.ts"`（显式启用），而不是删掉数组，
这仍然会让包保持对象形式。想彻底回到干净的字符串条目，直接删掉 `extensions` 字段：

```json
"packages": [
  "npm:@gotgenes/pi-permission-system"
]
```

## 6. 生效时机

配置在**会话启动**时读取，改完要重启当前会话（或重开 pi）才生效。已经跑着的会话里
扩展还在内存中，关不掉的。

验证：重启时启动列表不再列出该扩展；或直接看 `~/.pi/agent/settings.json` 写进去了什么。
`pi list` 只列包，不显示资源级开关状态。

## 7. 常见误区

- **扩展自己的配置不是开关**。`~/.pi/agent/extensions/pi-permission-system/config.json`
  管的是策略（`permission`、`yoloMode`、日志等）。改它不会让扩展停止加载。
- **“禁用扩展” ≠ “放宽策略”**。整条禁用后所有工具都不再受该扩展约束（包括它原本
  deny 的路径）；只想本轮少弹确认，改策略 / 切会话模式才是对的粒度。
- **想要一次性、不落盘**：`pi --no-extensions` 或 `-ne` 关掉全部扩展（含内置），
  没有“只排除某一个包”的命令行开关。
