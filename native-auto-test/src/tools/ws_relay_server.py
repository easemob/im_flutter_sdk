"""Local topic-based WebSocket relay for Flutter SDK E2E control traffic."""

from __future__ import annotations

import argparse
import asyncio
import logging
from typing import Dict, Optional, Sequence, Set, Tuple, Union
from urllib.parse import parse_qs, urlsplit

from websockets.exceptions import ConnectionClosed
from websockets.legacy.server import (
    WebSocketServer,
    WebSocketServerProtocol,
    serve,
)

DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 4000
DEFAULT_PATH = "/iov/websocket/dual"

Frame = Union[str, bytes]

_LOGGER = logging.getLogger("ws-relay")


def _normalize_host(host: str) -> str:
    if not host:
        raise ValueError("host must not be empty")
    if any(char.isspace() for char in host):
        raise ValueError("host must not contain whitespace")
    return host


def _normalize_path(path: str) -> str:
    if not path.startswith("/"):
        raise ValueError("path must start with '/'")
    if any(char.isspace() for char in path):
        raise ValueError("path must not contain whitespace")
    parsed = urlsplit(path)
    if parsed.query or parsed.fragment:
        raise ValueError("path must not contain query or fragment")
    return parsed.path


def _topic_from_request_path(request_path: str, expected_path: str) -> str:
    parsed = urlsplit(request_path)
    if parsed.path != expected_path:
        raise ValueError("invalid path")
    topics = parse_qs(parsed.query, keep_blank_values=True).get("topic", [])
    if len(topics) != 1 or not topics[0].strip():
        raise ValueError("missing or empty topic")
    return topics[0].strip()


class TopicRelay:
    """Broadcast frames to other connections subscribed to the same topic."""

    def __init__(self, path: str = DEFAULT_PATH):
        self._path = _normalize_path(path)
        self._connections: Dict[str, Set[WebSocketServerProtocol]] = {}

    @property
    def connection_counts(self) -> Dict[str, int]:
        return {
            topic: len(connections)
            for topic, connections in self._connections.items()
            if connections
        }

    def _remove(self, topic: str, websocket: WebSocketServerProtocol) -> None:
        connections = self._connections.get(topic)
        if connections is None:
            return
        connections.discard(websocket)
        if not connections:
            self._connections.pop(topic, None)

    async def _broadcast(
        self,
        topic: str,
        sender: WebSocketServerProtocol,
        frame: Frame,
    ) -> None:
        recipients = tuple(self._connections.get(topic, set()) - {sender})
        failed: list[WebSocketServerProtocol] = []
        for recipient in recipients:
            try:
                await recipient.send(frame)
            except ConnectionClosed:
                failed.append(recipient)
        for recipient in failed:
            self._remove(topic, recipient)

    async def handle(
        self,
        websocket: WebSocketServerProtocol,
    ) -> None:
        try:
            topic = _topic_from_request_path(websocket.path, self._path)
        except ValueError as exc:
            await websocket.close(code=1008, reason=str(exc))
            return

        connections = self._connections.setdefault(topic, set())
        connections.add(websocket)
        _LOGGER.info(
            "client connected topic=%s connections=%d",
            topic,
            len(connections),
        )
        try:
            async for frame in websocket:
                await self._broadcast(topic, websocket, frame)
        except ConnectionClosed:
            pass
        finally:
            self._remove(topic, websocket)
            _LOGGER.info(
                "client disconnected topic=%s connections=%d",
                topic,
                self.connection_counts.get(topic, 0),
            )


async def start_relay(
    host: str = DEFAULT_HOST,
    port: int = DEFAULT_PORT,
    path: str = DEFAULT_PATH,
) -> Tuple[WebSocketServer, TopicRelay]:
    """Start a relay server. Port 0 is accepted for isolated tests."""
    if not 0 <= port <= 65535:
        raise ValueError("port must be between 0 and 65535")
    host = _normalize_host(host)
    path = _normalize_path(path)
    relay = TopicRelay(path=path)
    server = await serve(relay.handle, host, port)
    return server, relay


def _cli_port(value: str) -> int:
    try:
        port = int(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("port must be an integer") from exc
    if not 1 <= port <= 65535:
        raise argparse.ArgumentTypeError("port must be between 1 and 65535")
    return port


def _cli_host(value: str) -> str:
    try:
        return _normalize_host(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(str(exc)) from exc


def _cli_path(value: str) -> str:
    try:
        return _normalize_path(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(str(exc)) from exc


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Run the local topic-based WebSocket relay for Flutter E2E tests."
    )
    parser.add_argument("--host", type=_cli_host, default=DEFAULT_HOST)
    parser.add_argument("--port", type=_cli_port, default=DEFAULT_PORT)
    parser.add_argument("--path", type=_cli_path, default=DEFAULT_PATH)
    return parser


async def _run_until_cancelled(host: str, port: int, path: str) -> None:
    server, _ = await start_relay(host=host, port=port, path=path)
    _LOGGER.info("listening on ws://%s:%d%s", host, port, _normalize_path(path))
    try:
        await asyncio.Future()
    finally:
        server.close()
        await server.wait_closed()


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    logging.basicConfig(level=logging.INFO, format="[%(name)s] %(message)s")
    try:
        asyncio.run(
            _run_until_cancelled(
                host=args.host,
                port=args.port,
                path=args.path,
            )
        )
    except KeyboardInterrupt:
        _LOGGER.info("stopped")
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
