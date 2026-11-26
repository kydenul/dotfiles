#!/usr/bin/env python3
"""Manage TCodex's process-scoped gateway and export its catalog to Pi."""

import argparse
import fcntl
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import tomllib
from urllib.parse import urlparse
import urllib.request
import uuid


STATE_DIR = Path.home() / ".tclaude/tcli/tcodex-proxy"
STATE_PATH = STATE_DIR / "metadata.json"
SOCKET_PATH = STATE_DIR / "app-server.sock"
MODELS_PATH = Path(os.environ.get("PI_CODING_AGENT_DIR", str(Path.home() / ".pi/agent"))) / "models.json"


def process_table():
    return subprocess.check_output(["ps", "-axo", "pid=,ppid=,args="], text=True)


def discover(root_pid):
    processes = {}
    for line in process_table().splitlines():
        parts = line.strip().split(None, 2)
        if len(parts) == 3 and parts[0].isdigit() and parts[1].isdigit():
            processes[int(parts[0])] = (int(parts[1]), parts[2])
    descendants = {root_pid}
    while True:
        children = {pid for pid, (ppid, _) in processes.items() if ppid in descendants}
        if children <= descendants:
            break
        descendants.update(children)
    for pid in sorted(descendants):
        command = processes.get(pid, (0, ""))[1]
        if not command or Path(command.split()[0]).name != "codex":
            continue
        match = re.search(r"model_providers\.tencent=(\{.*?\})", command)
        if not match:
            continue
        try:
            provider = tomllib.loads("provider=" + match.group(1))["provider"]
        except ValueError:
            raise ValueError("cannot parse TCodex gateway configuration") from None
        url = provider.get("base_url", "")
        token = provider.get("experimental_bearer_token", "")
        parsed = urlparse(url)
        if parsed.scheme != "http" or parsed.hostname != "127.0.0.1" or not parsed.port:
            raise ValueError("TCodex gateway must use an HTTP loopback address")
        if not token:
            raise ValueError("TCodex gateway has no local bearer token")
        return {"pid": root_pid, "childPid": pid, "url": url, "token": token}
    return None


def write_state(path, state):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".metadata-")
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump(state, stream)
            stream.write("\n")
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def current_state():
    pid = managed_pid()
    return discover(pid) if pid is not None else None


def managed_pid():
    if not STATE_PATH.exists():
        return None
    try:
        pid = int(json.loads(STATE_PATH.read_text())["pid"])
    except (ValueError, KeyError, TypeError):
        raise ValueError("TCodex proxy metadata is invalid") from None
    for line in process_table().splitlines():
        parts = line.strip().split(None, 2)
        if len(parts) == 3 and parts[0] == str(pid):
            if "unix://" + str(SOCKET_PATH) in parts[2] and "tcodex" in parts[2]:
                return pid
    return None


def group_alive(pid):
    groups = subprocess.check_output(["ps", "-axo", "pgid=,stat="], text=True)
    return any(parts[0] == str(pid) and not parts[1].startswith("Z")
               for line in groups.splitlines() if len(parts := line.split()) == 2)


def stop_managed(pid):
    # Only our detached process group is eligible. Never signal an interactive
    # TCodex process or a PID reused by a different process.
    if managed_pid() != pid or os.getpgid(pid) != pid:
        raise ValueError("cannot verify ownership of the TCodex process group")
    os.killpg(pid, signal.SIGTERM)
    for _ in range(20):
        if not group_alive(pid):
            return
        time.sleep(0.1)
    # The group remains owned even after the wrapper exits while children live.
    # A live group cannot have its ID reused by another process group.
    if group_alive(pid):
        os.killpg(pid, signal.SIGKILL)
    for _ in range(20):
        if not group_alive(pid):
            return
        time.sleep(0.1)
    raise ValueError("TCodex process group did not stop")


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, fp, code, msg, headers, new_url):
        raise ValueError("TCodex catalog redirects are forbidden")


def catalog(state):
    request = urllib.request.Request(state["url"] + "/v1/models", headers={
        "Authorization": "Bearer " + state["token"],
    })
    # Never route loopback credentials through an HTTP_PROXY setting.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())
    with opener.open(request, timeout=10) as response:
        models = json.load(response).get("models")
    if not isinstance(models, list) or not models:
        raise ValueError("TCodex gateway returned an empty or invalid catalog")
    return models


def ensure():
    STATE_DIR.mkdir(parents=True, exist_ok=True, mode=0o700)
    os.chmod(STATE_DIR, 0o700)
    with (STATE_DIR / "start.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state = current_state()
        if state:
            try:
                models = catalog(state)
            except (OSError, ValueError):
                print("         RESTART  unhealthy managed tcodex gateway")
                stop_managed(state["pid"])
            else:
                sync_file(MODELS_PATH, build_provider(state, models), True, existing_only=True)
                print("         OK  tcodex gateway at " + state["url"])
                return state
        if not shutil.which("tcodex"):
            raise ValueError("tcodex is not installed")
        # The wrapper owns the HTTP gateway for the lifetime of its child. An
        # idle app-server on a private Unix socket keeps both processes alive.
        pid = managed_pid()
        process = None
        if pid is None:
            if SOCKET_PATH.exists() or SOCKET_PATH.is_symlink():
                SOCKET_PATH.unlink()
            log_fd = os.open(STATE_DIR / "gateway.log", os.O_WRONLY | os.O_APPEND | os.O_CREAT, 0o600)
            with os.fdopen(log_fd, "a") as log:
                process = subprocess.Popen(
                    ["tcodex", "app-server", "--listen", "unix://" + str(SOCKET_PATH)],
                    stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                    start_new_session=True, env={**os.environ, "TCODEX_SKIP_UPDATE": "1"},
                )
            pid = process.pid
            # Persist ownership before waiting so an interrupted ensure can
            # recover the same process instead of spawning another gateway.
            write_state(STATE_PATH, {"pid": pid})
        for _ in range(60):
            if (process is not None and process.poll() is not None) or managed_pid() is None:
                raise ValueError("tcodex exited; inspect " + str(STATE_DIR / "gateway.log"))
            state = discover(pid)
            if state:
                models = catalog(state)
                write_state(STATE_PATH, state)
                print("         STARTED  tcodex gateway at " + state["url"])
                # After a restart, refresh an existing Pi provider's random port.
                sync_file(MODELS_PATH, build_provider(state, models), True, existing_only=True)
                return state
            time.sleep(0.5)
        stop_managed(pid)
        raise ValueError("tcodex gateway startup timed out; inspect " + str(STATE_DIR / "gateway.log"))


def helper_command(command):
    return "!" + shlex.join([sys.executable, str(Path(__file__).resolve()), command])


def build_provider(state, models):
    entries = []
    for model in models:
        model_id = model.get("slug")
        if not isinstance(model_id, str) or not model_id or "\n" in model_id:
            raise ValueError("TCodex catalog contains an invalid model ID")
        efforts = {level["effort"] for level in model.get("supported_reasoning_levels", [])}
        # Pi's extra levels are opt-in. Hide levels absent from this exact model.
        level_map = {level: ("none" if level == "off" else level)
                     if ("none" if level == "off" else level) in efforts else None
                     for level in ("off", "minimal", "low", "medium", "high", "xhigh", "max")}
        entries.append({
            "id": model_id, "name": model.get("display_name", model_id),
            "contextWindow": int(model.get("context_window", 128000)),
            "maxTokens": int(model.get("max_output_tokens", 16384)),
            "input": model.get("input_modalities", ["text"]),
            "reasoning": bool(efforts - {"none"}), "thinkingLevelMap": level_map,
        })
    return {
        "baseUrl": state["url"], "api": "openai-responses",
        "apiKey": helper_command("token"), "authHeader": True,
        "headers": {"session_id": "pi-tcodex-gateway",
                    "X-Conversation-Request-ID": helper_command("request-id")},
        "models": entries,
    }


def sync_file(path, provider, apply, existing_only=False):
    path = Path(path)
    if existing_only and not path.exists():
        return
    if not apply:
        return sync_file_unlocked(path, provider, False, existing_only)
    path.parent.mkdir(parents=True, exist_ok=True)
    # Shared with sync_pi_claude's writer in tclaude-proxy.
    with Path(str(path) + ".lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        return sync_file_unlocked(path, provider, True, existing_only)


def sync_file_unlocked(path, provider, apply, existing_only):
    path = Path(path)
    existed = path.exists()
    try:
        data = json.loads(path.read_text()) if existed else {"providers": {}}
    except ValueError:
        raise ValueError("Pi models.json is not valid JSON; leaving it unchanged") from None
    if not isinstance(data, dict) or not isinstance(data.setdefault("providers", {}), dict):
        raise ValueError("Pi models.json must contain a providers object")
    existing = data["providers"].get("tcodex")
    if existing_only and existing is None:
        return
    if existing is not None and not isinstance(existing, dict):
        raise ValueError("Pi tcodex provider must be an object")
    current = (existing or {}).get("baseUrl", "")
    if current and urlparse(current).hostname not in ("127.0.0.1", "localhost"):
        print("         SKIP  remote tcodex provider")
        return
    if existing == provider:
        print("         NOOP  tcodex provider already correct")
        return
    change = f"tcodex -> {provider['baseUrl']} ({len(provider.get('models', []))} models)"
    if not apply:
        print("         WOULD SET  " + change)
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    if existed:
        shutil.copy2(path, str(path) + ".bak")
    data["providers"]["tcodex"] = provider
    # The model file contains commands, never the gateway's bearer token.
    write_state(path, data)
    print("         UPDATED  " + change)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["ensure", "status", "url", "token", "request-id", "sync", "doctor"])
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    if args.command == "request-id":
        print(uuid.uuid4())
        return
    if args.command == "ensure":
        ensure()
        return
    state = ensure() if args.command == "sync" and args.apply else current_state()
    if not state:
        raise ValueError("TCodex proxy is not running; run tclaude-proxy ensure tcodex")
    if args.command == "token":
        print(state["token"])
    elif args.command == "url":
        print(state["url"])
    else:
        models = catalog(state)
        if args.command == "sync":
            sync_file(MODELS_PATH, build_provider(state, models), args.apply)
        else:
            print(f"         OK  tcodex at {state['url']} ({len(models)} models)")
            if args.command == "doctor":
                data = json.loads(MODELS_PATH.read_text())
                if data.get("providers", {}).get("tcodex") != build_provider(state, models):
                    raise ValueError("Pi tcodex configuration drifted; run tclaude-proxy sync-ccswitch pi --apply")
                print("         OK  Pi tcodex wiring and dynamic credentials")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print("         ERROR  " + str(error), file=sys.stderr)
        sys.exit(1)
