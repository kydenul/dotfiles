# 本地 Llama.cpp

## 命令速查

```bash
# 安装 / 升级 llama.cpp
brew install llama.cpp
brew update && brew upgrade llama.cpp

# 安装 Hugging Face CLI 并下载 GGUF
brew install hf
hf download unsloth/Qwen3.8-27B-GGUF --include "*UD-Q4_K_XL*" --local-dir ~/llm-models/Qwen3.8-27B-GGUF

# 提高 GPU 可用内存(可选,重启失效)
sudo sysctl iogpu.wired_limit_mb=40960

# 启动服务
llama-server -m ~/llm-models/Qwen3.8-27B-GGUF/Qwen3.8-27B-UD-Q4_K_XL.gguf \
  --alias qwen3.8-27b-local --host 127.0.0.1 --port 8080 \
  -ngl 999 -fa on -c 131072 --jinja --no-mmproj \
  --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.0

# 验证
curl http://127.0.0.1:8080/v1/models

# 安装并运行 Pi
npm install -g @earendil-works/pi-coding-agent
pi
```

## Install

llama.cpp

```bash
brew install llama.cpp
llama-server --version   # 验证安装
```

Huggingface 命令行工具 hf

```bash
brew install hf
hf --help   # 验证安装
```

## Usage

Qwen3.8-27B-GGUF

```bash
hf download unsloth/Qwen3.8-27B-GGUF \
  --include "*UD-Q4_K_XL*" \
  --local-dir ~/llm-models/Qwen3.8-27B-GGUF
```

验证检查

```bash
ls -lh ~/llm-models/Qwen3.8-27B-GGUF
```

## 启动 llama-server

```bash
llama-server \
  -m ~/llm-models/Qwen3.8-27B-GGUF/Qwen3.8-27B-UD-Q4_K_XL.gguf \
  --alias qwen3.8-27b-local \
  --host 127.0.0.1 --port 8080 \
  -ngl 999 \
  -fa on \
  -c 131072 \
  --jinja \
  --no-mmproj \
  --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.0
```

| 参数                                             | 作用                                                                           |
| :----------------------------------------------- | :----------------------------------------------------------------------------- |
| `-m`                                             | 模型文件路径                                                                   |
| `--alias`                                        | 给模型起短名字，在 Pi 配置中引用                                               |
| `--host 127.0.0.1`                               | 仅本机访问(安全默认值,不要随意改成 0.0.0.0)                                    |
| `--port 8080`                                    | 服务端口                                                                       |
| `-ngl 999`                                       | 所有层放到 GPU(Metal)                                                          |
| `-fa on`                                         | 开启 Flash Attention,省内存并提速                                              |
| `-c 131072`                                      | 上下文长度。Agent 会塞入大量文件与工具输出,不要用小上下文;内存紧张时降到 65536 |
| `--jinja`                                        | 使用模型自带聊天模板,工具调用依赖它                                            |
| `--no-mmproj`                                    | 不加载视觉投影文件,节省内存(需要看图时去掉并指定 --mmproj)                     |
| `--temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.0` | 官方推荐的思考模式采样参数                                                     |

### Validation

```bash
# 查看模型列表
curl http://127.0.0.1:8080/v1/models

# 测试对话
> curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3.8-27b-local","messages":[{"role":"user","content":"用一句话介绍你自己"}]}'
> {"choices":[{"finish_reason":"stop","index":0,"message":{"role":"assistant","content":"我是通义千问（Qwen），由阿里巴巴通义实验室开发的大语言模型，可以陪你聊天、写作、编程和分析问题。","reasoning_content":"用户要求“用一句话介绍你自己”。需要用中文一句话回答。可以简短说明我是通义千问，由阿里巴巴通义实验室开发的大语言模型，能回答问题、写文字、编程等。保持一句。\n"}}],"created":1791604162,"model":"qwen3.8-27b-local","system_fingerprint":"b11429-d81235049","object":"chat.completion","usage":{"completion_tokens":77,"prompt_tokens":56,"total_tokens":133,"prompt_tokens_details":{"cached_tokens":0}},"id":"chatcmpl-Nv8xdQOsSoCJpU3RTprow13ZdxuVTBDT","timings":{"cache_n":0,"prompt_n":56,"prompt_ms":1986.236,"prompt_per_token_ms":35.4685,"prompt_per_second":28.1940313235688,"predicted_n":77,"predicted_ms":6332.614,"predicted_per_token_ms":83.32386842105262,"predicted_per_second":12.001363102188135}}
```

> 浏览器访问 [http://127.0.0.1:8080](http://127.0.0.1:8080) 可看到内置 Web UI

## Pi-Agent 配置示例

~/.pi/agent/models.json

```json
{
  "providers": {
    "llama-cpp": {
      "baseUrl": "http://localhost:8080/v1",
      "api": "openai-completions",
      "apiKey": "none",
      "models": [{ "id": "qwen3.8-27b-local" }]
    }
  }
}
```

要点:

- `baseUrl` 必须包含 `/v1`。
- `id` 要与 llama-server 的 `--alias` 一致(或用 curl .../v1/models 查看实际名称)。
- 如果你启动时加载了视觉投影文件(去掉 `--no-mmproj` 并指定 `--mmproj`),可在模型条目中加入 "input": ["text", "image"]。
