#!/usr/bin/env python3
"""Show recent gateway and agent logs with credential values removed."""

from collections import deque
from datetime import date
from pathlib import Path
import re
import sys


def redact(line):
    line = re.sub(r'(?i)(\bBearer\s+)[^\s"\x27,}]+', r'\1[REDACTED]', line)
    line = re.sub(r'(?i)(\b(?:Authorization|Proxy-Authorization|Cookie|Set-Cookie|x-api-key)\s*:\s*).*',
                  r'\1[REDACTED]', line)
    fields = "token|access_token|refresh_token|apiKey|api_key|experimental_bearer_token|authorization|proxy-authorization|cookie|set-cookie|x-api-key"
    for quote in ('"', "'"):
        line = re.sub(rf'(?i)({quote}(?:{fields}){quote}\s*:\s*{quote})[^{quote}\n]*({quote})',
                      r'\1[REDACTED]\2', line)
    return re.sub(r'(?i)(\b(?:token|access_token|refresh_token|api_key|experimental_bearer_token)\s*=\s*)(?:"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s,}]+)',
                  r'\1[REDACTED]', line)


def show_logs():
    root = Path.home() / ".tclaude"
    day = date.today().isoformat()
    daemon_dir = root / "logs/tclaude" / day
    if not daemon_dir.is_dir():
        daemon_dir = root / "logs" / day
    groups = [
        ("agent logs", [root / "logs/agent/agent.log", root / "logs/agent/agent.err.log"]),
        ("tclaude daemon logs (today)", sorted(daemon_dir.glob("*.log"))),
        ("tcodex gateway logs", [root / "tcli/tcodex-proxy/gateway.log"]),
    ]
    for title, paths in groups:
        print(f"\n━━━ {title} ━━━\n")
        found = False
        for path in paths:
            try:
                with path.open(errors="replace") as stream:
                    lines = deque(stream, maxlen=30)
            except FileNotFoundError:
                continue
            if not lines:
                continue
            found = True
            print(f"── {path} ──")
            for line in lines:
                print(redact(line.rstrip("\n")))
        if not found:
            print("[INFO] no log output yet")


if __name__ == "__main__":
    try:
        show_logs()
    except OSError as error:
        print("[ERR] " + str(error), file=sys.stderr)
        sys.exit(1)
