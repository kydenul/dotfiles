# Rex for Mac 通过 SSH 隧道连接 DevCloud

在 Mac 上用 Rex for Mac 原生连接远程 Linux（DevCloud）上的 Rex server。
iOA 拦截了 Tailscale，所以不走官方推荐的 Tailscale，而是用 SSH 转发 server 的 Unix socket。

---

## 1. 架构

```
Rex for Mac ──► ~/.ssh/rex-devcloud.sock ══ ssh -N -L ══► DevCloud:/run/user/0/rex/server.sock ──► rex server (root)
               (launchd agent 维持隧道)                    (systemd 用户服务 + linger)
```

为什么转发 socket，而不是给 server 开一个 TCP 监听：

- server 不监听任何网络端口，也不需要 `--allow-anonymous`（官方文档称其 "super dangerous"）
- sshd 以 root 身份打开 socket，Rex 看到的是 `you: uid 0 over unix`，身份明确
- 认证完全交给 SSH 密钥
- Mac 本地 socket 放在 `~/.ssh/`（0700）下，只有当前用户能访问；换成回环 TCP 端口的话，本机任何进程都能连
- 需要 2026-10-29 及以后的 Rex for Mac 或 CLI，更早的版本不支持把 Unix socket 当作远程主机

## 2. 远程端（DevCloud，TencentOS Server 4，root）

### 安装

`install.sh` 不认识 TencentOS（`ID=tencentos`，`ID_LIKE` 里没有 rhel），会直接退出。
需要手动添加 RPM 源：

```sh
cat > /etc/yum.repos.d/rex.repo <<'EOF'
[rex]
name=Rex (preview)
baseurl=https://pkgs.superlogical.com/rex/rpm/preview/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://pkgs.superlogical.com/rex/keys/rex.asc
EOF
dnf install -y rex
```

> ⚠️ 写 `.repo` 文件时**行首不能有空白**。从终端复制时容易带进缩进，dnf 会报
> `failed loading '/etc/yum.repos.d/rex.repo', skipping`，然后提示找不到 `rex` 包。
> 用 `cat -A` 检查。

GPG 密钥指纹：`E032 B88A E0C2 79B9 EA9B DF27 C003 6366 6EE2 9BCE`
（Superlogical Package Signing）。

### 常驻服务

不用包里自带的 `rex.service`：它以 `rex` 账户运行，会话里拿不到 root 权限。
改为 root 的 systemd **用户**服务 `~/.config/systemd/user/rex.service`：

```ini
[Unit]
Description=Rex personal server

[Service]
ExecStart=/usr/bin/rex server run --listen %t/rex/server.sock
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=default.target
```

```sh
loginctl enable-linger root      # 必须：开机就启动用户级 systemd，退出登录后 /run/user/0 也不会被删
systemctl --user daemon-reload
systemctl --user enable --now rex
```

`--listen %t/rex/server.sock` 把 socket 路径固定在 `/run/user/0/rex/server.sock`，
防止以后默认路径变化导致隧道失效。

## 3. Mac 端

```sh
bash ~/.dotfiles/script/rex-tunnel-agent.sh install    # 默认连 ~/.ssh/config 里的 DevCloud
bash ~/.dotfiles/script/rex-tunnel-agent.sh status
bash ~/.dotfiles/script/rex-tunnel-agent.sh logs
```

- Rex for Mac：**Add Remote Host…**，填 `/Users/kyden/.ssh/rex-devcloud.sock`
- CLI：`rex -S unix://$HOME/.ssh/rex-devcloud.sock ls`
- 连其他主机：`REX_TUNNEL_HOST=K-Claw bash ... install`。每台主机有独立的 agent 和 socket
- 日志：`~/Library/Logs/rex-tunnel/<host>.log`

## 4. 自启动

| 端    | 机制                                                            | 效果                                            |
| ----- | --------------------------------------------------------------- | ----------------------------------------------- |
| Linux | `Linger=yes` + `WantedBy=default.target` + `Restart=on-failure` | 开机自动启动，不需要有人登录；崩溃后 5 秒内重启 |
| Mac   | launchd agent `RunAtLoad` + `KeepAlive`                         | 登录 macOS 后自动开隧道；ssh 退出后约 10 秒重连 |

- `ServerAliveInterval 15` × `ServerAliveCountMax 3`：断网约 45 秒后 ssh 判定连接已死并退出，再由 launchd 重连。
- 云主机重启后：server 会恢复会话布局（tab、分屏、名字），但**正在运行的程序会被结束**，回滚历史也不会恢复。
- 隧道不依赖 Rex for Mac 应用本身。如果希望 Rex 窗口也开机自动打开，要在 **系统设置 → 通用 → 登录项** 里手动加上。

## 5. 异常情况与处理

### 5.1 手动执行了 `rex server stop`，server 没有自动回来

`Restart=on-failure` 只在崩溃时重启，主动停止属于正常退出，不会触发重启。

```sh
systemctl --user start rex
```

### 5.2 出现了不受 systemd 管理的 server

现象：`rex ls` 是空的、会话"消失"了，或者 `systemctl --user start rex` 启动失败。

原因：server 停止后，在云主机上执行任何 `rex` 命令（如 `rex ls`），都会在同一个 socket 上
**自动拉起一个临时的个人 server**，它不归 systemd 管。

```sh
systemctl --user status rex     # 对比 MainPID 与 rex server status 显示的 pid
rex server stop                 # 停掉临时 server
systemctl --user start rex      # 交回给 systemd
```

想彻底杜绝这种情况，可以在 root 的 shell 配置里设置 `REX_AUTOSTART=0`。

### 5.3 `dnf upgrade` 升级了 rex，但版本没变

RPM 包只会重启系统级的 `rex.service`，不会重启 root 的用户级服务，所以 server 会一直运行旧版本。

```sh
rex server status | grep version
systemctl --user restart rex    # 选空闲时执行：正在运行的程序会被结束，布局会恢复
```

### 5.4 隧道一直重连失败

先看日志：

```sh
bash ~/.dotfiles/script/rex-tunnel-agent.sh logs
```

| 日志 / 现象                                      | 原因                                                                                                                 | 处理                                                    |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `Permission denied` / `passphrase`               | launchd 无法交互输入密码。当前密钥 `id_rsa_kydenul` 没有密码，也不依赖 ssh-agent；如果以后换了密钥或加了密码就会出现 | 换回无密码的密钥，或者配置 ssh-agent 并在登录时加载密钥 |
| `Connection timed out`                           | iOA 未连接，或者网络断了                                                                                             | 恢复网络后会自动重连                                    |
| `forwarding ... failed` / `ExitOnForwardFailure` | 远程 socket 不存在，server 没在运行                                                                                  | 按 5.1 / 5.2 处理远程端                                 |
| socket 存在，但 `status` 显示连不上 server       | 同上                                                                                                                 | 同上                                                    |

修改 ssh 配置或者换了主机之后，重新执行 `install`（会先卸载再加载 plist）。

### 5.5 `/run/user/0` 被删除，server 失联

现象：退出 SSH 后，下次 `rex ls` 是空的，隧道也报 socket 不存在。

原因：没有开启 linger。root 最后一个登录会话退出时，systemd-logind 会删除 `/run/user/0`。

```sh
loginctl show-user root -p Linger   # 应该是 Linger=yes
loginctl enable-linger root
```

## 6. 备选方案（不推荐）

- **Tailscale**：官方推荐，Rex 内置 tsnet（`rex server start --tailscale`），但在 iOA 环境下不可用。
- **回环 TCP + `--allow-anonymous`**：`rex server start --extra-listen 127.0.0.1:7297 --allow-anonymous`，
  再用 `ssh -L 7297:127.0.0.1:7297` 转发。能用，但这台机器上的所有本地用户都能连，
  而且 Rex 无法识别调用者身份。转发 socket 的方案在各方面都更好。
- **SSH 登录后在远程直接运行 `rex`**：类似 tmux，不需要任何配置，但用不上 Rex for Mac 的原生体验。

官方在规划用 SSH 作为传输方式（`ssh://` 远程主机，社区 feature request "SSH remote hosts integration"）。
等它上线后，可以去掉这个 launchd 隧道。
