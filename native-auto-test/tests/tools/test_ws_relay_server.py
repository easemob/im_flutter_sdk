import asyncio
from collections.abc import AsyncIterator
from dataclasses import dataclass
import logging
from pathlib import Path
import subprocess
import sys
from urllib.parse import quote

from packaging.requirements import Requirement
from packaging.version import Version
import pytest
import websockets
from websockets.exceptions import ConnectionClosedError

import src.tools.ws_relay_server as relay_server
from src.tools.ws_relay_server import TopicRelay, start_relay


@dataclass(frozen=True)
class RunningRelay:
    base_url: str
    relay: TopicRelay


@pytest.fixture
async def running_relay() -> AsyncIterator[RunningRelay]:
    server, relay = await start_relay(host="127.0.0.1", port=0)
    port = server.sockets[0].getsockname()[1]
    try:
        yield RunningRelay(
            base_url=f"ws://127.0.0.1:{port}/iov/websocket/dual",
            relay=relay,
        )
    finally:
        server.close()
        await server.wait_closed()


def _topic_url(running_relay: RunningRelay, topic: str) -> str:
    return f"{running_relay.base_url}?topic={quote(topic)}"


async def _wait_for_connection_counts(
    relay: TopicRelay,
    expected: dict[str, int],
    *,
    timeout: float = 1.0,
) -> None:
    deadline = asyncio.get_running_loop().time() + timeout
    while relay.connection_counts != expected:
        if asyncio.get_running_loop().time() >= deadline:
            pytest.fail(
                f"连接未在 {timeout}s 内收敛: "
                f"expected={expected}, actual={relay.connection_counts}"
            )
        await asyncio.sleep(0.01)


async def test_relay_forwards_text_to_other_client_on_same_topic(
    running_relay: RunningRelay,
) -> None:
    url = _topic_url(running_relay, "device-a")
    async with websockets.connect(url) as sender, websockets.connect(url) as receiver:
        await sender.send("hello")

        assert await asyncio.wait_for(receiver.recv(), timeout=1.0) == "hello"


async def test_relay_preserves_binary_frames(running_relay: RunningRelay) -> None:
    url = _topic_url(running_relay, "device-a")
    payload = b"\x00\x01\xff"
    async with websockets.connect(url) as sender, websockets.connect(url) as receiver:
        await sender.send(payload)

        assert await asyncio.wait_for(receiver.recv(), timeout=1.0) == payload


async def test_relay_does_not_echo_to_sender(running_relay: RunningRelay) -> None:
    url = _topic_url(running_relay, "device-a")
    async with websockets.connect(url) as sender, websockets.connect(url) as receiver:
        await sender.send("no-echo")
        assert await asyncio.wait_for(receiver.recv(), timeout=1.0) == "no-echo"

        with pytest.raises(asyncio.TimeoutError):
            await asyncio.wait_for(sender.recv(), timeout=0.1)


async def test_relay_isolates_different_topics(running_relay: RunningRelay) -> None:
    topic_a = _topic_url(running_relay, "device-a")
    topic_b = _topic_url(running_relay, "device-b")
    async with (
        websockets.connect(topic_a) as sender,
        websockets.connect(topic_a) as receiver,
        websockets.connect(topic_b) as isolated,
    ):
        await sender.send("topic-a-only")
        assert await asyncio.wait_for(receiver.recv(), timeout=1.0) == "topic-a-only"

        with pytest.raises(asyncio.TimeoutError):
            await asyncio.wait_for(isolated.recv(), timeout=0.1)


@pytest.mark.parametrize(
    ("path_and_query", "reason_fragment"),
    [
        ("/wrong?topic=device-a", "path"),
        ("/iov/websocket/dual", "topic"),
        ("/iov/websocket/dual?topic=%20%20", "topic"),
    ],
)
async def test_relay_rejects_invalid_path_or_topic(
    running_relay: RunningRelay,
    path_and_query: str,
    reason_fragment: str,
) -> None:
    origin = running_relay.base_url.split("/iov/websocket/dual", maxsplit=1)[0]
    async with websockets.connect(f"{origin}{path_and_query}") as client:
        with pytest.raises(ConnectionClosedError) as exc_info:
            await client.recv()

    assert exc_info.value.rcvd is not None
    assert exc_info.value.rcvd.code == 1008
    assert reason_fragment in exc_info.value.rcvd.reason.lower()


async def test_relay_removes_empty_topic_after_disconnect(
    running_relay: RunningRelay,
) -> None:
    url = _topic_url(running_relay, "cleanup")
    async with websockets.connect(url):
        await _wait_for_connection_counts(running_relay.relay, {"cleanup": 1})

    await _wait_for_connection_counts(running_relay.relay, {})


async def test_relay_logs_do_not_include_text_or_binary_payloads(
    running_relay: RunningRelay,
    caplog: pytest.LogCaptureFixture,
) -> None:
    url = _topic_url(running_relay, "payload-log-check")
    text_secret = "SENSITIVE-TEXT-7f16e0"
    binary_secret = b"SENSITIVE-BINARY-9b42d1"

    caplog.set_level(logging.INFO, logger="ws-relay")
    async with websockets.connect(url) as sender, websockets.connect(url) as receiver:
        await sender.send(text_secret)
        assert await asyncio.wait_for(receiver.recv(), timeout=1.0) == text_secret
        await sender.send(binary_secret)
        assert await asyncio.wait_for(receiver.recv(), timeout=1.0) == binary_secret

    assert text_secret not in caplog.text
    assert binary_secret.decode("ascii") not in caplog.text
    assert repr(binary_secret) not in caplog.text


def test_requirements_exclude_versions_without_legacy_websocket_api() -> None:
    requirements_file = Path(__file__).resolve().parents[2] / "requirements.txt"
    websocket_requirement = next(
        Requirement(line)
        for line in requirements_file.read_text(encoding="utf-8").splitlines()
        if line.strip().lower().startswith("websockets")
    )

    assert Version("11.0") in websocket_requirement.specifier
    assert Version("16.0") in websocket_requirement.specifier
    assert Version("17.0") not in websocket_requirement.specifier


@pytest.mark.parametrize(
    ("args", "error_fragment"),
    [
        (["--host", "bad host"], "host must not contain whitespace"),
        (["--port", "0"], "port must be between 1 and 65535"),
        (["--path", "/bad path"], "path must not contain whitespace"),
        (["--path", "/bad?query=1"], "path must not contain query or fragment"),
    ],
)
def test_relay_cli_rejects_invalid_runtime_before_starting_listener(
    args: list[str],
    error_fragment: str,
) -> None:
    process = subprocess.Popen(
        [sys.executable, str(Path(relay_server.__file__).resolve()), *args],
        cwd=Path(__file__).resolve().parents[2],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        stdout, stderr = process.communicate(timeout=0.5)
    except subprocess.TimeoutExpired:
        process.terminate()
        stdout, stderr = process.communicate(timeout=3)

    assert process.returncode == 2, stdout + stderr
    assert error_fragment in stderr
