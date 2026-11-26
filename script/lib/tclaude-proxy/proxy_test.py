import importlib.util
from datetime import date
import fcntl
import json
import os
from pathlib import Path
import tempfile
import subprocess
import select
import shutil
import shlex
import plistlib
import sys
import unittest
import uuid
from unittest.mock import patch
from unittest.mock import Mock


MODULE_PATH = Path(__file__).with_name("tcodex.py")
PROXY_SCRIPT = Path(__file__).resolve().parents[2] / "tclaude-proxy"


class TCodexTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        spec = importlib.util.spec_from_file_location("tcodex_proxy", MODULE_PATH)
        cls.proxy = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.proxy)

    def test_discovers_only_managed_descendants_and_redacts_errors(self):
        processes = '\n'.join([
            '10 1 node /opt/homebrew/bin/tcodex',
            '11 10 /opt/homebrew/bin/tcodex-native',
            '12 11 codex -c model_providers.tencent={ name = "TCodex", base_url = "http://127.0.0.1:4000", experimental_bearer_token = "private-token", wire_api = "responses" } -c model_provider="tencent"',
            '20 1 codex -c model_providers.tencent={ base_url = "http://127.0.0.1:9999", experimental_bearer_token = "other-token" }',
        ])
        with patch.object(self.proxy, "process_table", return_value=processes):
            state = self.proxy.discover(10)
            self.assertEqual(state["url"], "http://127.0.0.1:4000")
            self.assertEqual(state["token"], "private-token")
            self.assertIsNone(self.proxy.discover(99))

    def test_rejects_remote_gateway(self):
        processes = '12 10 codex -c model_providers.tencent={ base_url = "https://remote.example", experimental_bearer_token = "secret" }'
        with patch.object(self.proxy, "process_table", return_value=processes):
            with self.assertRaisesRegex(ValueError, "loopback") as error:
                self.proxy.discover(10)
            self.assertNotIn("secret", str(error.exception))

    def test_provider_uses_live_metadata_and_dynamic_credentials(self):
        catalog = [{"slug": "gpt-test", "display_name": "GPT Test", "context_window": 272000,
                    "input_modalities": ["text", "image"],
                    "supported_reasoning_levels": [{"effort": "low"}, {"effort": "high"}, {"effort": "xhigh"}, {"effort": "max"}]}]
        provider = self.proxy.build_provider({"url": "http://127.0.0.1:4000", "token": "private-token"}, catalog)
        self.assertEqual(provider["api"], "openai-responses")
        self.assertEqual(provider["baseUrl"], "http://127.0.0.1:4000")
        self.assertTrue(provider["apiKey"].startswith("!"))
        self.assertNotIn("private-token", json.dumps(provider))
        model = provider["models"][0]
        self.assertEqual(model["contextWindow"], 272000)
        self.assertEqual(model["input"], ["text", "image"])
        self.assertEqual(model["thinkingLevelMap"]["xhigh"], "xhigh")
        self.assertIsNone(model["thinkingLevelMap"]["medium"])

    def test_sync_dry_run_backup_preservation_and_idempotence(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "models.json"
            original = {"providers": {"llama-cpp": {"baseUrl": "http://localhost:8080/v1"}}, "extra": True}
            path.write_text(json.dumps(original))
            provider = {"baseUrl": "http://127.0.0.1:4000", "models": [{"id": "gpt-test"}]}
            self.proxy.sync_file(path, provider, False)
            self.assertEqual(json.loads(path.read_text()), original)
            self.assertFalse(Path(str(path) + ".bak").exists())
            self.proxy.sync_file(path, provider, True)
            result = json.loads(path.read_text())
            self.assertEqual(result["providers"]["llama-cpp"], original["providers"]["llama-cpp"])
            self.assertEqual(result["providers"]["tcodex"], provider)
            self.assertTrue(result["extra"])
            self.assertEqual(json.loads(Path(str(path) + ".bak").read_text()), original)
            before = path.stat().st_mtime_ns
            self.proxy.sync_file(path, provider, True)
            self.assertEqual(path.stat().st_mtime_ns, before)

    def test_remote_provider_and_malformed_config_are_preserved(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "models.json"
            for content in ['{"providers":{"tcodex":{"baseUrl":"https://remote.example/127.0.0.1"}}}', '{"providers":[]}','invalid']:
                path.write_text(content)
                try:
                    self.proxy.sync_file(path, {"baseUrl": "http://127.0.0.1:4000"}, True)
                except ValueError:
                    pass
                self.assertEqual(path.read_text(), content)

    def test_state_is_private_and_written_atomically(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "state.json"
            self.proxy.write_state(path, {"token": "private-token"})
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)
            self.assertEqual(json.loads(path.read_text()), {"token": "private-token"})

    def test_status_and_token_discovery_do_not_write_state(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "state.json"
            path.write_text('{"pid":10}')
            with patch.object(self.proxy, "STATE_PATH", path), patch.object(self.proxy, "process_table", return_value=f'10 1 tcodex app-server --listen unix://{self.proxy.SOCKET_PATH}'), patch.object(self.proxy, "discover", return_value={"pid":10}), patch.object(self.proxy, "write_state") as write:
                self.assertEqual(self.proxy.current_state(), {"pid":10})
                write.assert_not_called()

    def test_reused_pid_is_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "state.json"
            path.write_text('{"pid":10}')
            with patch.object(self.proxy, "STATE_PATH", path), patch.object(self.proxy, "process_table", return_value='10 1 unrelated-process'):
                self.assertIsNone(self.proxy.current_state())
                self.assertIsNone(self.proxy.managed_pid())

    def test_stop_refuses_unowned_process(self):
        with patch.object(self.proxy, "managed_pid", return_value=20), patch.object(self.proxy.os, "killpg") as kill:
            with self.assertRaisesRegex(ValueError, "ownership"):
                self.proxy.stop_managed(10)
            kill.assert_not_called()

    def test_healthy_ensure_does_not_spawn(self):
        with tempfile.TemporaryDirectory() as folder:
            state = {"pid":10,"url":"http://127.0.0.1:4000"}
            with patch.object(self.proxy, "STATE_DIR", Path(folder)), patch.object(self.proxy, "MODELS_PATH", Path(folder)/"models.json"), patch.object(self.proxy, "current_state", return_value=state), patch.object(self.proxy, "catalog", return_value=[{"slug":"gpt-test"}]), patch.object(self.proxy.subprocess, "Popen") as spawn:
                self.assertEqual(self.proxy.ensure(), state)
                spawn.assert_not_called()

    def test_interrupted_startup_reuses_process(self):
        with tempfile.TemporaryDirectory() as folder:
            state = {"pid":10,"url":"http://127.0.0.1:4000","token":"private-token"}
            with patch.object(self.proxy, "STATE_DIR", Path(folder)), patch.object(self.proxy, "STATE_PATH", Path(folder)/"state.json"), patch.object(self.proxy, "MODELS_PATH", Path(folder)/"models.json"), patch.object(self.proxy, "current_state", return_value=None), patch.object(self.proxy, "managed_pid", return_value=10), patch.object(self.proxy, "discover", return_value=state), patch.object(self.proxy, "catalog", return_value=[{"slug":"gpt-test"}]), patch.object(self.proxy.shutil, "which", return_value="tcodex"), patch.object(self.proxy.subprocess, "Popen") as spawn:
                self.assertEqual(self.proxy.ensure(), state)
                spawn.assert_not_called()

    def test_unhealthy_gateway_is_stopped_before_restart(self):
        with tempfile.TemporaryDirectory() as folder:
            stale = {"pid":10,"url":"http://127.0.0.1:4000"}
            state = {"pid":20,"url":"http://127.0.0.1:5000","token":"private-token"}
            process = Mock(pid=20)
            process.poll.return_value = None
            with patch.object(self.proxy, "STATE_DIR", Path(folder)), patch.object(self.proxy, "STATE_PATH", Path(folder)/"state.json"), patch.object(self.proxy, "SOCKET_PATH", Path(folder)/"socket"), patch.object(self.proxy, "MODELS_PATH", Path(folder)/"models.json"), patch.object(self.proxy, "current_state", return_value=stale), patch.object(self.proxy, "managed_pid", side_effect=[None,20]), patch.object(self.proxy, "discover", return_value=state), patch.object(self.proxy, "catalog", side_effect=[OSError("unhealthy"),[{"slug":"gpt-test"}]]), patch.object(self.proxy.shutil, "which", return_value="tcodex"), patch.object(self.proxy.subprocess, "Popen", return_value=process), patch.object(self.proxy, "stop_managed") as stop:
                self.assertEqual(self.proxy.ensure(), state)
                stop.assert_called_once_with(10)

    def test_healthy_ensure_repairs_stale_port(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder)/"models.json"
            path.write_text('{"providers":{"tcodex":{"baseUrl":"http://127.0.0.1:3000"},"other":{"models":[]}}}')
            state = {"pid":10,"url":"http://127.0.0.1:4000"}
            with patch.object(self.proxy, "STATE_DIR", Path(folder)), patch.object(self.proxy, "MODELS_PATH", path), patch.object(self.proxy, "current_state", return_value=state), patch.object(self.proxy, "catalog", return_value=[{"slug":"gpt-test"}]), patch.object(self.proxy.subprocess, "Popen") as spawn:
                self.proxy.ensure()
                result = json.loads(path.read_text())["providers"]
                self.assertEqual(result["tcodex"]["baseUrl"], state["url"])
                self.assertIn("other", result)
                spawn.assert_not_called()

    def test_catalog_redirects_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "redirects"):
            self.proxy.NoRedirect().redirect_request(None, None, 302, "Found", {}, "https://remote.example")

    def test_shutdown_waits_for_children_after_wrapper_exits(self):
        with patch.object(self.proxy, "managed_pid", return_value=10), patch.object(self.proxy.os, "getpgid", return_value=10), patch.object(self.proxy.os, "killpg") as kill, patch.object(self.proxy, "group_alive", side_effect=[True]*21+[False]), patch.object(self.proxy.time, "sleep"):
            self.proxy.stop_managed(10)
            self.assertEqual([call.args[1] for call in kill.call_args_list], [self.proxy.signal.SIGTERM,self.proxy.signal.SIGKILL])

    def test_both_pi_writers_share_lock_and_preserve_providers(self):
        # Exercise tclaude's actual embedded writer alongside the Python helper.
        shell = MODULE_PATH.with_name("tclaude.sh").read_text()
        writer = shell.split('"$PI_EXCLUDE_MODELS" <<\'PY\'\n', 1)[1].split('\nPY', 1)[0]
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder)/"models.json"
            path.write_text('{"providers":{"other":{"models":[]}}}')
            instrument = f'''
import fcntl, builtins, io
original_flock = fcntl.flock
def tracked_flock(fd, operation):
    print("LOCK", flush=True)
    original_flock(fd, operation)
    print("ACQUIRED", flush=True)
fcntl.flock = tracked_flock
def tracked_open(original):
    def opened(file, mode="r", *args, **kwargs):
        if str(file) == {str(path)!r} and "r" in mode:
            print("READ", flush=True)
        return original(file, mode, *args, **kwargs)
    return opened
builtins.open = tracked_open(builtins.open)
io.open = tracked_open(io.open)
'''
            with Path(str(path)+".lock").open("a") as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                claude = subprocess.Popen([sys.executable, "-B", "-c", instrument+'\nexec('+repr(writer)+')', str(path), "http://127.0.0.1:4000", "placeholder", "1", "tclaude", "test-session", "claude-test", "", "", ""], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                code = f'import importlib.util; s=importlib.util.spec_from_file_location("proxy",{str(MODULE_PATH)!r}); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); m.sync_file({str(path)!r},{{"baseUrl":"http://127.0.0.1:5000","models":[]}},True)'
                codex = subprocess.Popen([sys.executable, "-B", "-c", instrument+'\n'+code], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                try:
                    for process in (claude, codex):
                        self.assertTrue(select.select([process.stdout], [], [], 5)[0], "writer never reached lock")
                        self.assertEqual(process.stdout.readline().strip(), "LOCK", "writer read config without acquiring lock")
                    for process in (claude, codex):
                        self.assertFalse(select.select([process.stdout], [], [], 0.1)[0], "writer passed held lock")
                finally:
                    fcntl.flock(lock, fcntl.LOCK_UN)
                    for process in (claude, codex):
                        _, error = process.communicate(timeout=10)
                        self.assertEqual(process.returncode, 0, error)
            self.assertEqual(set(json.loads(path.read_text())["providers"]), {"tclaude","tcodex","other"})


class ProxyCliTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.bin = self.home / "bin"
        self.bin.mkdir()
        for command in ("cat", "chmod", "date", "dirname", "grep", "head", "id", "ls", "mkdir", "rm", "sed", "tail"):
            (self.bin / command).symlink_to(shutil.which(command))
        (self.bin / "python3").symlink_to(sys.executable)
        self.env = {**os.environ, "HOME": str(self.home), "PATH": str(self.bin),
                    "PI_CODING_AGENT_DIR": str(self.home / "pi")}
        self.command("curl", 'echo \'{"ok":true}\'')
        self.command("tclaude", 'echo "$*" >> "$HOME/tclaude.calls"')
        self.command("brew", 'echo /opt/homebrew')
        self.command("launchctl", 'echo "$*" >> "$HOME/launchctl.calls"')
        self.script = PROXY_SCRIPT

    def command(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\nset -eu\n" + body + "\n")
        path.chmod(0o755)

    def run_cli(self, *args):
        return subprocess.run(["/bin/bash", str(self.script), *args], env=self.env,
                              capture_output=True, text=True, timeout=10)

    def test_tcodex_url_uses_migrated_helper(self):
        state_dir = self.home / ".tclaude/tcli/tcodex-proxy"
        state_dir.mkdir(parents=True)
        (state_dir / "metadata.json").write_text('{"pid":10}')
        self.command("ps", "cat <<'EOF'\n"
                     f"10 1 tcodex app-server --listen unix://{state_dir}/app-server.sock\n"
                     '11 10 codex -c model_providers.tencent={ base_url = "http://127.0.0.1:4000", experimental_bearer_token = "private-token" }\n'
                     "EOF")
        result = self.run_cli("url", "tcodex")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "http://127.0.0.1:4000")
        self.assertNotIn("private-token", result.stdout + result.stderr)

    def test_dynamic_request_id_command_runs_from_other_directory(self):
        spec = importlib.util.spec_from_file_location("tcodex_proxy", MODULE_PATH)
        proxy = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(proxy)
        command = proxy.helper_command("request-id")
        result = subprocess.run(shlex.split(command[1:]), cwd=self.home, env=self.env,
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(str(uuid.UUID(result.stdout.strip())), result.stdout.strip())

    def test_tclaude_metadata_commands_preserve_output(self):
        meta = self.home / ".tclaude/tcli/daemon/metadata.json"
        meta.parent.mkdir(parents=True)
        meta.write_text('{"url":"http://127.0.0.1:4000","port":4000,"pid":10}')
        for args, expected in [(("url",), "http://127.0.0.1:4000"),
                               (("port",), "4000"),
                               (("env",), 'export ANTHROPIC_BASE_URL="http://127.0.0.1:4000"\nexport ANTHROPIC_AUTH_TOKEN="placeholder"')]:
            result = self.run_cli(*args)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout.strip(), expected)

    def test_legacy_agent_entry_delegates_help_without_dependencies(self):
        (self.bin / "curl").unlink()
        (self.bin / "python3").unlink()
        result = subprocess.run(["/bin/bash", str(self.script.with_name("tclaude-proxy-agent.sh")), "--help"],
                                env=self.env, capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("tclaude-proxy agent install", result.stdout)

    def test_entry_works_from_path_containing_spaces(self):
        copied_script = self.home / "dotfiles copy/script"
        copied_script.mkdir(parents=True)
        shutil.copy2(self.script, copied_script / "tclaude-proxy")
        shutil.copytree(MODULE_PATH.parent, copied_script / "lib/tclaude-proxy")
        self.script = copied_script / "tclaude-proxy"
        result = self.run_cli("--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("tclaude-proxy start", result.stdout)

    def test_help_prioritizes_start_and_agent_commands(self):
        # Help must work even without gateway dependencies.
        (self.bin / "curl").unlink()
        (self.bin / "python3").unlink()
        result = self.run_cli("--help")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("tclaude-proxy start", result.stdout)
        self.assertIn("tclaude-proxy agent install", result.stdout)
        self.assertIn("tclaude-proxy logs", result.stdout)
        self.assertLess(result.stdout.index("start"), result.stdout.index("sync-ccswitch"))

    def test_start_and_ensure_share_gateway_behavior(self):
        meta = self.home / ".tclaude/tcli/daemon/metadata.json"
        meta.parent.mkdir(parents=True)
        meta.write_text('{"url":"http://127.0.0.1:4000","port":4000,"pid":10}')
        for args in [("start",), ("start", "tclaude"), ("ensure",), ("ensure", "tclaude")]:
            result = self.run_cli(*args)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("already healthy", result.stdout)
        self.assertFalse((self.home / "tclaude.calls").exists())
        self.assertNotEqual(self.run_cli("start", "unknown").returncode, 0)
        self.assertNotEqual(self.run_cli("start", "tclaude", "extra").returncode, 0)

    def test_agent_install_status_and_uninstall_preserve_launchd_contract(self):
        result = self.run_cli("agent", "install")
        self.assertEqual(result.returncode, 0, result.stderr)
        plist = self.home / "Library/LaunchAgents/com.kyden.tclaude-proxy.plist"
        self.assertIn('-//Apple//DTD PLIST 1.0//EN', plist.read_text())
        with plist.open("rb") as stream:
            job = plistlib.load(stream)
        self.assertEqual(job["Label"], "com.kyden.tclaude-proxy")
        self.assertEqual(job["ProgramArguments"], [str(self.script.resolve()), "ensure"])
        self.assertEqual(job["StartInterval"], 300)
        self.assertTrue(job["RunAtLoad"])
        self.assertTrue(job["AbandonProcessGroup"])
        self.assertEqual(job["EnvironmentVariables"]["HOME"], str(self.home))
        self.assertIn("agent status", result.stdout)
        self.assertEqual(self.run_cli("agent", "status").returncode, 0)
        self.assertNotEqual(self.run_cli("agent", "invalid").returncode, 0)
        self.assertNotEqual(self.run_cli("agent", "install", "extra").returncode, 0)
        result = self.run_cli("agent", "uninstall")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(plist.exists())
        self.assertFalse((self.home / "tclaude.calls").exists())
        calls = (self.home / "launchctl.calls").read_text()
        self.assertIn("bootstrap gui/", calls)
        self.assertIn("bootout gui/", calls)

    def test_logs_include_both_gateways_and_redact_credentials(self):
        paths = [self.home / ".tclaude/logs/agent/agent.log",
                 self.home / ".tclaude/logs/agent/agent.err.log",
                 self.home / ".tclaude/tcli/tcodex-proxy/gateway.log",
                 self.home / ".tclaude/logs/tclaude" / date.today().isoformat() / "gateway.log"]
        for index, path in enumerate(paths):
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(f'gateway-log-{index}\nAuthorization: Bearer private-value\nCookie: session=private-cookie\n{{"token":"private-token"}}\n')
        result = self.run_cli("logs")
        self.assertEqual(result.returncode, 0, result.stderr)
        for index in range(3):
            self.assertIn(f"gateway-log-{index}", result.stdout)
        for secret in ("private-value", "private-cookie", "private-token"):
            self.assertNotIn(secret, result.stdout)
        self.assertIn("[REDACTED]", result.stdout)

    def test_logs_redact_json_headers_and_gateway_assignments(self):
        path = self.home / ".tclaude/tcli/tcodex-proxy/gateway.log"
        path.parent.mkdir(parents=True)
        path.write_text('request headers {"Authorization":"Bearer json-secret","Cookie":"session=json-cookie","x-api-key":"json-key"}\n'
                        'experimental_bearer_token = "assignment-secret"\n'
                        'token=bare-secret\n'
                        "headers {'Cookie': 'session=dict-cookie', 'x-api-key': 'dict-key'}\n")
        result = self.run_cli("logs")
        self.assertEqual(result.returncode, 0, result.stderr)
        for secret in ("json-secret", "json-cookie", "json-key", "assignment-secret", "bare-secret", "dict-cookie", "dict-key"):
            self.assertNotIn(secret, result.stdout)
        self.assertIn("[REDACTED]", result.stdout)


if __name__ == "__main__":
    unittest.main()
