import importlib.util
import fcntl
import json
import os
from pathlib import Path
import tempfile
import subprocess
import select
import sys
import unittest
from unittest.mock import patch
from unittest.mock import Mock


MODULE_PATH = Path(__file__).with_name("tclaude-proxy-tcodex.py")


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
        shell = MODULE_PATH.with_name("tclaude-proxy").read_text()
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
                claude = subprocess.Popen([sys.executable, "-c", instrument+'\nexec('+repr(writer)+')', str(path), "http://127.0.0.1:4000", "placeholder", "1", "tclaude", "test-session", "claude-test", "", "", ""], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                code = f'import importlib.util; s=importlib.util.spec_from_file_location("proxy",{str(MODULE_PATH)!r}); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); m.sync_file({str(path)!r},{{"baseUrl":"http://127.0.0.1:5000","models":[]}},True)'
                codex = subprocess.Popen([sys.executable, "-c", instrument+'\n'+code], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
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


if __name__ == "__main__":
    unittest.main()
