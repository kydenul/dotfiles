---
name: db-container-security
description: 本地 MySQL / Redis 容器安全约定（必须设密码、端口只绑 127.0.0.1、标准启动命令）。启动或复用数据库容器、配置数据库密码、编写 docker-compose 或起容器的 Makefile 目标时使用。
paths: "**/docker-compose*.yml, **/docker-compose*.yaml, **/compose*.yaml"
---

# MySQL / Redis 容器安全约定

任何本地、联调、集成测试、排查用的数据库容器都必须满足：

- **必须设置密码**，禁止无密码启动（MySQL 禁止 `MYSQL_ALLOW_EMPTY_PASSWORD=yes`）。
- **端口只绑 `127.0.0.1`**：写 `-p 127.0.0.1:<host>:<container>`，不要写 `-p 6379:6379` / `-p 3306:3306`（后者绑 `0.0.0.0` 全网暴露）。
- 连接端的密码与容器设置的一致，经环境变量 / Makefile 变量传入，不写进可提交的业务配置。
- 用完清理：`docker stop <name> && docker rm <name>`。
- 组件单测优先用内存 mock（Redis 用 `miniredis.Run()`，MySQL 用 sqlite / sqlmock），只有联调、集成测试、排查数据时才起真实容器。

## 标准姿势

Redis（密码固定 `craftia-redis`）：

```bash
docker run -d --name craftia-redis-test \
  -p 127.0.0.1:6379:6379 \
  redis:7-alpine redis-server --requirepass craftia-redis
```

MySQL（root 密码固定 `craftia-mysql`）：

```bash
docker run -d --name craftia-mysql-test \
  -e MYSQL_ROOT_PASSWORD=craftia-mysql -e MYSQL_DATABASE=<db> \
  -p 127.0.0.1:3306:3306 \
  mysql:8.0
# DSN: root:craftia-mysql@tcp(127.0.0.1:3306)/<db>?charset=utf8mb4&parseTime=true&loc=Local
```

就绪探测用真实握手（`mysqladmin ping -h 127.0.0.1 -pcraftia-mysql` / `redis-cli -a craftia-redis ping`），并设超时，不要 grep 日志。

## 为什么

Redis 默认无认证并绑定 `0.0.0.0`，攻击者可未授权读写数据，以 root 运行时还能写入 SSH 公钥直连宿主机；无密码的 MySQL 暴露在网络上同样可被直接读写、拖库。设密码 + 只绑本机是基本安全底线。
