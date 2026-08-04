from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
import threading
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlencode

from .config import Artifact, RoleSpec


class WebBrowserError(RuntimeError):
    pass


class _QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:
        return None


class WebBrowserDevice:
    """Chrome-hosted Web SDK Runner, one isolated profile per logical device."""

    def __init__(self, role: RoleSpec, *, startup_timeout: float, app_key: str) -> None:
        self.role = role
        self.startup_timeout = startup_timeout
        self.app_key = app_key
        self.browser = self._find_browser(role.browser)
        self.serial: str | None = None
        self._process: subprocess.Popen[bytes] | None = None
        self._server: ThreadingHTTPServer | None = None
        self._thread: threading.Thread | None = None
        self._profile_dir: Path | None = None

    def ensure_started(self) -> str:
        if not self.browser:
            raise WebBrowserError(
                "Chrome is not available; set NATIVE_TEST_CHROME or device.browser"
            )
        self.serial = f"chrome:{self.role.role}"
        return self.serial

    def install(self, artifact: Artifact, *, replace: bool = True) -> str:
        del replace
        if not artifact.path.is_dir() or not (artifact.path / "index.html").is_file():
            raise WebBrowserError(
                f"Web Runner artifact is missing: {artifact.path}; run pytest --build first"
            )
        if not (artifact.path / "runner.js").is_file():
            raise WebBrowserError(
                f"Web Runner bundle is missing: {artifact.path / 'runner.js'}; run pytest --build first"
            )
        self._serve(artifact.path)
        return str(artifact.path)

    def prepare_web_socket_url(self, value: str) -> str:
        return value

    def launch(
        self,
        artifact: Artifact,
        *,
        runner_id: str,
        device_name: str,
        topic: str,
        web_socket_base_url: str,
        run_id: str = "",
        logical_device: str = "",
        artifact_id: str = "",
        wrapper_commit: str = "",
        native_sdk_sha256: str = "",
        managed_web_socket: bool = False,
    ) -> str:
        del artifact, managed_web_socket
        if not self._server or not self.browser:
            raise WebBrowserError("browser runner has not been installed")
        self._profile_dir = Path(tempfile.mkdtemp(prefix=f"im-web-{logical_device}-"))
        query = urlencode(
            {
                "runnerId": runner_id,
                "deviceName": device_name,
                "topic": topic,
                "webSocketBaseUrl": web_socket_base_url,
                "runId": run_id,
                "logicalDevice": logical_device,
                "artifactId": artifact_id,
                "wrapperCommit": wrapper_commit,
                "nativeSdkSha256": native_sdk_sha256,
                "appKey": self.app_key,
            }
        )
        url = f"http://127.0.0.1:{self._server.server_port}/index.html?{query}"
        self._process = subprocess.Popen(
            [
                self.browser,
                f"--user-data-dir={self._profile_dir}",
                "--no-first-run",
                "--no-default-browser-check",
                "--new-window",
                url,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return url

    def stop_emulator(self) -> None:
        if self._process and self._process.poll() is None:
            self._process.terminate()
        self._process = None
        if self._server:
            self._server.shutdown()
            self._server.server_close()
        self._server = None
        self._thread = None

    def set_network_enabled(self, enabled: bool) -> str:
        raise WebBrowserError(
            f"browser network control is not implemented (requested enabled={enabled})"
        )

    def _serve(self, root: Path) -> None:
        handler = lambda *args, **kwargs: _QuietHandler(*args, directory=str(root), **kwargs)
        self._server = ThreadingHTTPServer(("127.0.0.1", 0), handler)
        self._thread = threading.Thread(target=self._server.serve_forever, daemon=True)
        self._thread.start()

    @staticmethod
    def _find_browser(configured: str | None) -> str | None:
        candidates = [
            configured,
            os.getenv("NATIVE_TEST_CHROME"),
            shutil.which("google-chrome"),
            shutil.which("chromium"),
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        ]
        return next((value for value in candidates if value and Path(value).exists()), None)
