from __future__ import annotations

import asyncio
import json
import threading
import uuid
from collections import defaultdict
from typing import Any

from websockets.asyncio.server import ServerConnection, serve
from websockets.exceptions import ConnectionClosed


class ManagedWebSocketServerError(RuntimeError):
    pass


class ManagedWebSocketServer:
    """Session-scoped WS router owned by native-auto-test.

    Runner connections register with a Hello message. Controller connections
    subscribe to one target runner and send requests containing
    ``targetRunnerId``. Responses are routed to the originating controller;
    events are routed only to controllers subscribed to the emitting runner.
    """

    def __init__(
        self,
        *,
        host: str = "127.0.0.1",
        port: int = 0,
        run_id: str | None = None,
        startup_timeout: float = 10.0,
    ) -> None:
        self.host = host
        self.port = port
        self.run_id = run_id or f"run-{uuid.uuid4().hex[:12]}"
        self.startup_timeout = startup_timeout
        self._thread: threading.Thread | None = None
        self._loop: asyncio.AbstractEventLoop | None = None
        self._server: Any = None
        self._started = threading.Event()
        self._startup_error: BaseException | None = None
        self._runners: dict[tuple[str, str], ServerConnection] = {}
        self._runner_hellos: dict[tuple[str, str], dict[str, Any]] = {}
        self._runner_keys: dict[ServerConnection, tuple[str, str]] = {}
        self._controllers: dict[ServerConnection, tuple[str, str]] = {}
        self._subscribers: dict[tuple[str, str], set[ServerConnection]] = defaultdict(set)
        self._pending: dict[tuple[str, str], ServerConnection] = {}
        self._event_ids: dict[tuple[str, str], int] = defaultdict(int)

    @property
    def base_url(self) -> str:
        if not self._started.is_set() or not self.port:
            raise ManagedWebSocketServerError("managed WebSocket server is not started")
        return f"ws://{self.host}:{self.port}"

    def start(self) -> "ManagedWebSocketServer":
        if self._thread is not None and self._thread.is_alive():
            return self
        self._started.clear()
        self._startup_error = None
        self._thread = threading.Thread(
            target=self._run,
            name=f"managed-ws-{self.run_id}",
            daemon=True,
        )
        self._thread.start()
        if not self._started.wait(self.startup_timeout):
            raise ManagedWebSocketServerError(
                f"timed out starting managed WebSocket server after "
                f"{self.startup_timeout}s"
            )
        if self._startup_error is not None:
            raise ManagedWebSocketServerError(
                f"managed WebSocket server failed to start: {self._startup_error}"
            ) from self._startup_error
        print(
            f"[managed-ws] started url={self.base_url} runId={self.run_id}",
            flush=True,
        )
        return self

    def stop(self) -> None:
        loop = self._loop
        server = self._server
        if loop is not None and server is not None and loop.is_running():
            async def shutdown() -> None:
                server.close()
                await server.wait_closed()

            future = asyncio.run_coroutine_threadsafe(shutdown(), loop)
            try:
                future.result(timeout=5)
            except Exception:
                pass
            loop.call_soon_threadsafe(loop.stop)
        if self._thread is not None:
            self._thread.join(timeout=5)
        self._thread = None
        self._loop = None
        self._server = None
        self._started.clear()

    def _run(self) -> None:
        loop = asyncio.new_event_loop()
        self._loop = loop
        asyncio.set_event_loop(loop)

        async def start_server() -> None:
            self._server = await serve(
                self._handle,
                self.host,
                self.port,
                ping_interval=20,
                ping_timeout=20,
            )
            sockets = self._server.sockets
            if not sockets:
                raise ManagedWebSocketServerError("managed server has no bound socket")
            self.port = int(sockets[0].getsockname()[1])

        try:
            loop.run_until_complete(start_server())
            self._started.set()
            loop.run_forever()
        except BaseException as error:
            self._startup_error = error
            self._started.set()
        finally:
            pending = asyncio.all_tasks(loop)
            for task in pending:
                task.cancel()
            if pending:
                loop.run_until_complete(
                    asyncio.gather(*pending, return_exceptions=True)
                )
            loop.close()

    async def _handle(self, connection: ServerConnection) -> None:
        try:
            async for raw in connection:
                message = self._decode(raw)
                if message is None:
                    await self._send_error(connection, "Invalid JSON message")
                    continue
                await self._route(connection, message)
        except ConnectionClosed:
            pass
        finally:
            self._remove_connection(connection)

    async def _route(
        self,
        connection: ServerConnection,
        message: dict[str, Any],
    ) -> None:
        message_type = str(message.get("type") or "")
        if message_type == "controllerHello":
            key = self._register_controller(connection, message)
            hello = self._runner_hellos.get(key)
            if hello is not None:
                await connection.send(json.dumps(hello, ensure_ascii=False))
            return
        if self._is_runner_hello(message):
            hello = self._hello_payload(message)
            key = self._register_runner(connection, hello)
            normalized_hello = {"type": "hello", "protocolVersion": 1, **hello}
            self._runner_hellos[key] = normalized_hello
            await self._broadcast(
                self._subscribers.get(key, set()),
                normalized_hello,
            )
            return
        if connection in self._controllers or message_type == "request":
            await self._route_request(connection, message)
            return
        if connection in self._runner_keys:
            await self._route_runner_message(connection, message)
            return
        await self._send_error(
            connection,
            "Connection must send controllerHello or runner Hello first",
            request=message,
        )

    def _register_controller(
        self,
        connection: ServerConnection,
        message: dict[str, Any],
    ) -> tuple[str, str]:
        run_id = str(message.get("runId") or self.run_id)
        runner_id = str(message.get("targetRunnerId") or "")
        if run_id != self.run_id or not runner_id:
            raise ManagedWebSocketServerError(
                f"invalid controller registration: runId={run_id!r}, "
                f"targetRunnerId={runner_id!r}"
            )
        old = self._controllers.get(connection)
        if old is not None:
            self._subscribers[old].discard(connection)
        key = (run_id, runner_id)
        self._controllers[connection] = key
        self._subscribers[key].add(connection)
        return key

    def _register_runner(
        self,
        connection: ServerConnection,
        hello: dict[str, Any],
    ) -> tuple[str, str]:
        run_id = str(hello.get("runId") or self.run_id)
        runner_id = str(hello.get("runnerId") or "")
        if run_id != self.run_id or not runner_id:
            raise ManagedWebSocketServerError(
                f"invalid runner registration: runId={run_id!r}, "
                f"runnerId={runner_id!r}"
            )
        key = (run_id, runner_id)
        previous = self._runners.get(key)
        if previous is not None and previous is not connection:
            self._runner_keys.pop(previous, None)
        self._runners[key] = connection
        self._runner_keys[connection] = key
        print(
            "[managed-ws] runner registered "
            f"runId={run_id} runnerId={runner_id} "
            f"logicalDevice={hello.get('logicalDevice') or hello.get('deviceName')}",
            flush=True,
        )
        return key

    async def _route_request(
        self,
        connection: ServerConnection,
        message: dict[str, Any],
    ) -> None:
        registered = self._controllers.get(connection)
        run_id = str(message.get("runId") or (registered[0] if registered else self.run_id))
        runner_id = str(
            message.get("targetRunnerId")
            or (registered[1] if registered else "")
        )
        request_id = str(message.get("requestId") or message.get("id") or "")
        if run_id != self.run_id or not runner_id or not request_id:
            await self._send_error(
                connection,
                "Request requires runId, targetRunnerId and requestId",
                request=message,
            )
            return
        runner = self._runners.get((run_id, runner_id))
        if runner is None:
            await self._send_error(
                connection,
                f"Runner is not registered: {runner_id}",
                request=message,
            )
            return
        message["type"] = "request"
        message["protocolVersion"] = int(message.get("protocolVersion") or 1)
        message["runId"] = run_id
        message["requestId"] = request_id
        message["id"] = message.get("id") or request_id
        message["targetRunnerId"] = runner_id
        self._pending[(run_id, request_id)] = connection
        await runner.send(json.dumps(message, ensure_ascii=False))

    async def _route_runner_message(
        self,
        connection: ServerConnection,
        message: dict[str, Any],
    ) -> None:
        key = self._runner_keys[connection]
        run_id, runner_id = key
        message["runId"] = run_id
        message["runnerId"] = runner_id
        if message.get("type") == "event":
            self._event_ids[key] += 1
            message.setdefault("eventId", self._event_ids[key])
            await self._broadcast(self._subscribers.get(key, set()), message)
            return
        request_id = str(message.get("requestId") or message.get("id") or "")
        controller = self._pending.pop((run_id, request_id), None)
        if controller is not None:
            await controller.send(json.dumps(message, ensure_ascii=False))

    async def _send_error(
        self,
        connection: ServerConnection,
        description: str,
        *,
        request: dict[str, Any] | None = None,
    ) -> None:
        request = request or {}
        payload = {
            "type": "response",
            "protocolVersion": 1,
            "runId": str(request.get("runId") or self.run_id),
            "caseId": request.get("caseId"),
            "requestId": request.get("requestId") or request.get("id"),
            "id": request.get("id") or request.get("requestId"),
            "manager": request.get("manager"),
            "cmd": request.get("cmd"),
            "success": False,
            "error": {
                "code": -1,
                "description": description,
                "kind": "FrameworkError",
            },
        }
        await connection.send(json.dumps(payload, ensure_ascii=False))

    @staticmethod
    async def _broadcast(
        connections: set[ServerConnection],
        message: dict[str, Any],
    ) -> None:
        if not connections:
            return
        payload = json.dumps(message, ensure_ascii=False)
        await asyncio.gather(
            *(connection.send(payload) for connection in tuple(connections)),
            return_exceptions=True,
        )

    def _remove_connection(self, connection: ServerConnection) -> None:
        key = self._runner_keys.pop(connection, None)
        if key is not None and self._runners.get(key) is connection:
            self._runners.pop(key, None)
        subscribed = self._controllers.pop(connection, None)
        if subscribed is not None:
            self._subscribers[subscribed].discard(connection)
            if not self._subscribers[subscribed]:
                self._subscribers.pop(subscribed, None)
        stale = [
            pending_key
            for pending_key, controller in self._pending.items()
            if controller is connection
        ]
        for pending_key in stale:
            self._pending.pop(pending_key, None)

    @staticmethod
    def _decode(raw: Any) -> dict[str, Any] | None:
        try:
            decoded = json.loads(
                raw.decode("utf-8") if isinstance(raw, bytes) else str(raw)
            )
        except (TypeError, ValueError, UnicodeDecodeError):
            return None
        return dict(decoded) if isinstance(decoded, dict) else None

    @staticmethod
    def _is_runner_hello(message: dict[str, Any]) -> bool:
        return message.get("type") == "hello" or (
            message.get("type") == "event"
            and message.get("eventType") == "runnerHello"
        )

    @staticmethod
    def _hello_payload(message: dict[str, Any]) -> dict[str, Any]:
        if message.get("type") == "hello":
            return message
        data = message.get("data")
        return dict(data) if isinstance(data, dict) else {}
