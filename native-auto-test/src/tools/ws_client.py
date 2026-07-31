"""
WebSocket 客户端：连接与 Flutter demo 相同的 WS 服务，按 topic 收发请求/响应。
请求格式与 Flutter 端一致：manager, cmd, info, id/sequence，可选 type/objId/device。
支持两种模式：1) 请求/响应 request()；2) 纯接收主动下发的消息 MessageListener。
"""
from __future__ import annotations

import asyncio
import json
import inspect
import queue
import threading
import time
import urllib.parse
import uuid
from collections import deque
from typing import Any

import websockets
from websockets.legacy.client import WebSocketClientProtocol

from .config import (
    get_connect_timeout,
    get_response_timeout,
    get_ws_base_url,
    get_topic,
)


_CONNECT_SUPPORTS_PROXY = "proxy" in inspect.signature(websockets.connect).parameters
_MANAGED_TRANSPORT_FIELDS = {
    "type",
    "protocolVersion",
    "runId",
    "caseId",
    "requestId",
    "targetRunnerId",
    "runnerId",
    "success",
}
_MANAGED_EVENT_TRANSPORT_FIELDS = {
    "runId",
    "eventId",
    "runnerId",
    "device",
    "platform",
    "sdkVersion",
}


def _ws_connect(url: str, **kwargs: Any):
    """Connect directly to the configured relay instead of inheriting OS proxies."""
    if _CONNECT_SUPPORTS_PROXY:
        kwargs["proxy"] = None
    return websockets.connect(url, **kwargs)

# ---- Debug flags (WS layer only) ----
import os

class _WSFlags:
    def __init__(self, dump: bool = False, relax: bool = False, sniff_seconds: int = 15):
        self.dump_events = dump
        self.relax_event_match = relax
        self.sniff_seconds = sniff_seconds

def _get_debug_flags() -> "_WSFlags":
    try:
        from .config import load_config
        cfg = load_config() or {}
        ws = (cfg.get("websocket") or {})
        dbg = (ws.get("debug") or {})
        dump = bool(int(os.getenv("WS_DEBUG", "0"))) or bool(dbg.get("dump_events", False))
        relax = bool(int(os.getenv("WS_RELAX", "0"))) or bool(dbg.get("relax_event_match", False))
        sniff_seconds = int(dbg.get("sniff_seconds", 15))
        return _WSFlags(dump, relax, sniff_seconds)
    except Exception:
        dump = bool(int(os.getenv("WS_DEBUG", "0")))
        relax = bool(int(os.getenv("WS_RELAX", "0")))
        return _WSFlags(dump, relax, 15)


def _build_ws_url(
    topic: str | None = None,
    device: str | None = None,
    *,
    base_url: str | None = None,
    use_topic: bool = True,
) -> str:
    t = topic or get_topic(device)
    base = (base_url or get_ws_base_url()).rstrip("/")
    if not use_topic:
        return base
    return f"{base}?topic={urllib.parse.quote(t)}"


def _is_response_message(msg: dict[str, Any], request_id: Any, request_sequence: Any) -> bool:
    """判断是否为当前请求的响应（含 result 或 error），而非事件等。"""
    if not isinstance(msg, dict):
        return False
    # 事件消息：type == 'event'，不当作请求响应
    if msg.get("type") == "event":
        return False
    # 中转服务会把原始请求回显给同一 topic 的订阅者，并附带一个
    # 默认 result（常见为 code=300）。原始请求仍保留 info；Flutter
    # 桥接的真正响应不会携带 info。忽略该回显，继续等待真实回包。
    if "info" in msg:
        return False
    # 当前 relay 对请求回显时还会丢掉 info，并固定补上
    # {code: 300, description: "Server is unreachable"}。该包早于设备的
    # 真实执行结果到达，不能结束当前 call。
    result = msg.get("result")
    if (
        isinstance(result, dict)
        and result.get("code") == 300
        and result.get("description") == "Server is unreachable"
    ):
        return False
    # 必须是响应包：包含 result 或 error，避免请求回显被误当作响应
    if "result" not in msg and "error" not in msg:
        return False
    # 响应需能对上 id 或 sequence
    rid = msg.get("id") or msg.get("sequence")
    if rid is not None and (rid == request_id or rid == request_sequence):
        return True
    # 无 id 时若只有一条响应也可接受（单请求场景）
    if request_id is None and request_sequence is None:
        return "result" in msg or "error" in msg
    return False


async def _request_async(
    manager: str,
    cmd: str,
    info: dict[str, Any] | None = None,
    *,
    request_id: Any = None,
    sequence: int | None = None,
    device: str | None = None,
    topic: str | None = None,
    type_: int | None = None,
    obj_id: int | None = None,
) -> dict[str, Any]:
    url = _build_ws_url(topic=topic, device=device)
    timeout_connect = get_connect_timeout()
    timeout_response = get_response_timeout()
    if request_id is None and sequence is None:
        request_id = uuid.uuid4().hex

    req: dict[str, Any] = {
        "manager": manager,
        "cmd": cmd,
        "info": info if info is not None else {},
    }
    if request_id is not None:
        req["id"] = request_id
    if sequence is not None:
        req["sequence"] = sequence
    if type_ is not None:
        req["type"] = type_
    if obj_id is not None:
        req["objId"] = obj_id
    if device is not None:
        req["device"] = device

    async with _ws_connect(
        url,
        open_timeout=timeout_connect,
        close_timeout=5,
    ) as ws:
        await ws.send(json.dumps(req))
        while True:
            try:
                raw = await asyncio.wait_for(ws.recv(), timeout=timeout_response)
            except asyncio.TimeoutError:
                raise TimeoutError(
                    f"Wait response timeout (cmd={cmd}, id={request_id}, sequence={sequence})"
                ) from None
            data = json.loads(raw)
            if _is_response_message(data, request_id, sequence):
                return data
            # 其他消息（如事件）可在此记录或忽略，继续等响应
            continue


async def _request_and_wait_event_async(
    manager: str,
    cmd: str,
    info: dict[str, Any] | None = None,
    *,
    event_type: str,
    event_timeout: float = 10.0,
    request_id: Any = None,
    sequence: int | None = None,
    device: str | None = None,
    topic: str | None = None,
    type_: int | None = None,
    obj_id: int | None = None,
) -> tuple[dict[str, Any], dict[str, Any] | None]:
    """发请求，等响应，再在同一连接上等待指定 eventType 的回调；返回 (响应, 事件消息或 None)。"""
    url = _build_ws_url(topic=topic, device=device)
    timeout_connect = get_connect_timeout()
    timeout_response = get_response_timeout()
    if request_id is None and sequence is None:
        request_id = uuid.uuid4().hex

    req: dict[str, Any] = {
        "manager": manager,
        "cmd": cmd,
        "info": info if info is not None else {},
    }
    if request_id is not None:
        req["id"] = request_id
    if sequence is not None:
        req["sequence"] = sequence
    if type_ is not None:
        req["type"] = type_
    if obj_id is not None:
        req["objId"] = obj_id
    if device is not None:
        req["device"] = device

    response: dict[str, Any] | None = None
    event_msg: dict[str, Any] | None = None

    async with _ws_connect(
        url,
        open_timeout=timeout_connect,
        close_timeout=5,
    ) as ws:
        await ws.send(json.dumps(req))
        while response is None:
            try:
                raw = await asyncio.wait_for(ws.recv(), timeout=timeout_response)
            except asyncio.TimeoutError:
                raise TimeoutError(
                    f"Wait response timeout (cmd={cmd}, id={request_id}, sequence={sequence})"
                ) from None
            data = json.loads(raw)
            if _is_response_message(data, request_id, sequence):
                response = data
                break
        while event_msg is None:
            try:
                raw = await asyncio.wait_for(ws.recv(), timeout=event_timeout)
            except asyncio.TimeoutError:
                break
            try:
                data = json.loads(raw)
            except Exception:
                continue
            if isinstance(data, dict) and data.get("type") == "event" and data.get("eventType") == event_type:
                event_msg = data
                break
    return (response, event_msg)


def request(
    manager: str,
    cmd: str,
    info: dict[str, Any] | None = None,
    *,
    request_id: Any = None,
    sequence: int | None = None,
    device: str | None = None,
    topic: str | None = None,
    type_: int | None = None,
    obj_id: int | None = None,
) -> dict[str, Any]:
    """同步调用：发送请求并返回响应（与 Flutter 端协议一致）。"""
    return asyncio.run(
        _request_async(
            manager=manager,
            cmd=cmd,
            info=info,
            request_id=request_id,
            sequence=sequence,
            device=device,
            topic=topic,
            type_=type_,
            obj_id=obj_id,
        )
    )


def request_and_wait_for_event(
    manager: str,
    cmd: str,
    info: dict[str, Any] | None = None,
    *,
    event_type: str,
    event_timeout: float = 10.0,
    request_id: Any = None,
    sequence: int | None = None,
    device: str | None = None,
    topic: str | None = None,
    type_: int | None = None,
    obj_id: int | None = None,
) -> tuple[dict[str, Any], dict[str, Any] | None]:
    """同步：发请求并等待指定 eventType 的回调，返回 (响应, 事件消息或 None)。"""
    return asyncio.run(
        _request_and_wait_event_async(
            manager=manager,
            cmd=cmd,
            info=info,
            event_type=event_type,
            event_timeout=event_timeout,
            request_id=request_id,
            sequence=sequence,
            device=device,
            topic=topic,
            type_=type_,
            obj_id=obj_id,
        )
    )


def _message_matches(
    msg: dict[str, Any],
    match_cmd: str | None,
    match_event_type: str | None,
    *, relax: bool = False,
) -> bool:
    """判断消息是否满足 cmd 或 eventType 过滤条件。"""
    if not isinstance(msg, dict):
        return False
    if match_cmd is not None and msg.get("cmd") != match_cmd:
        return False
    if match_event_type is not None:
        if relax and msg.get("type") == "event":
            return True
        if msg.get("type") != "event" or msg.get("eventType") != match_event_type:
            return False
    return True


class MessageListener:
    """
    纯接收模式：连接后只收不发，用于获取服务端主动下发的消息（响应或事件）。
    - 后台线程持续收包入队。
    - receive_message(match_cmd=..., match_event_type=..., timeout=...) 取第一条匹配的消息。
    - 不匹配的消息会进入缓冲（有上限），满时丢弃最旧的一条，避免内存无限增长。
    - buffer_maxlen：缓冲条数上限，默认 2000；queue_maxsize：接收队列上限，默认 5000，满时新消息丢弃。
    """

    def __init__(
        self,
        topic: str | None = None,
        device: str | None = None,
        *,
        buffer_maxlen: int = 2000,
        queue_maxsize: int = 5000,
        debug: bool = False,
    ):
        self._topic = topic or get_topic(device)
        self._device = device
        self._url = _build_ws_url(topic=self._topic, device=self._device)
        self._queue: queue.Queue[dict[str, Any]] = queue.Queue(maxsize=queue_maxsize)
        self._buffer: deque[dict[str, Any]] = deque(maxlen=buffer_maxlen)
        self._stopped = threading.Event()
        flags = _get_debug_flags()
        self._debug = debug or flags.dump_events
        self._relax = flags.relax_event_match
        self._thread: threading.Thread | None = None
        self._ws: WebSocketClientProtocol | None = None

    def _recv_loop_async(self) -> None:
        async def run() -> None:
            try:
                async with _ws_connect(
                    self._url,
                    open_timeout=get_connect_timeout(),
                    close_timeout=5,
                ) as ws:
                    self._ws = ws
                    while not self._stopped.is_set():
                        try:
                            raw = await asyncio.wait_for(ws.recv(), timeout=1.0)
                        except asyncio.TimeoutError:
                            continue
                        except Exception:
                            break
                        try:
                            data = json.loads(raw)
                            if self._debug:
                                try:
                                    print(f"[WS-DUMP][{self._topic}] {json.dumps(data, ensure_ascii=False)}")
                                except Exception:
                                    print(f"[WS-DUMP][{self._topic}] <non-json>")
                            try:
                                self._queue.put_nowait(data)
                            except queue.Full:
                                pass  # 队列满时丢弃本条，避免 recv 线程长期阻塞
                        except Exception:
                            pass
            finally:
                self._ws = None

        asyncio.run(run())

    def start(self) -> None:
        """启动后台接收线程。"""
        if self._thread is not None and self._thread.is_alive():
            return
        self._stopped.clear()
        self._thread = threading.Thread(target=self._recv_loop_async, daemon=True)
        self._thread.start()
        # 稍等连接建立
        time.sleep(0.5)

    def receive_message(
        self,
        *,
        match_cmd: str | None = None,
        match_event_type: str | None = None,
        timeout: float = 10.0,
    ) -> dict[str, Any] | None:
        """
        取第一条匹配的消息；超时返回 None。
        - match_cmd: 仅接受 cmd 等于该值的响应消息。
        - match_event_type: 仅接受 type==event 且 eventType 等于该值的事件。
        - 两者可只设一个；都不设则返回队列/缓冲中的任意一条。
        - 未匹配消息进入有界缓冲（见 buffer_maxlen），满时自动丢弃最旧的，不会异常或无限增长。
        """
        deadline = time.monotonic() + timeout
        have_filter = match_cmd is not None or match_event_type is not None

        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return None
            # 1) 先看缓冲里是否有匹配
            n = len(self._buffer)
            for _ in range(n):
                m = self._buffer.popleft()
                if _message_matches(m, match_cmd, match_event_type, relax=self._relax):
                    return m
                self._buffer.append(m)
            if (not have_filter or self._relax) and self._buffer:
                return self._buffer.popleft()
            # 2) 从队列取
            try:
                m = self._queue.get(timeout=min(remaining, 1.0))
            except queue.Empty:
                continue
            if _message_matches(m, match_cmd, match_event_type, relax=self._relax):
                return m
            self._buffer.append(m)

    def drain_buffer(self) -> list[dict[str, Any]]:
        """取出当前缓冲中的全部消息（不阻塞），并清空缓冲。"""
        out: list[dict[str, Any]] = []
        while self._buffer:
            out.append(self._buffer.popleft())
        return out

    def stop(self) -> None:
        """停止接收并关闭连接。"""
        self._stopped.set()
        if self._thread is not None:
            self._thread.join(timeout=3.0)
            self._thread = None
        self._ws = None

    @property
    def is_running(self) -> bool:
        return self._thread is not None and self._thread.is_alive()


class DeviceConnection:
    """
    单连接双工：同一 WebSocket 上既发请求-等响应，又收服务端推送。
    保证「B 同意后 A 收到的 onFriendRequestAccepted」与「A 发 addContact」走同一条连接，避免收不到回调。
    """

    def __init__(
        self,
        topic: str | None = None,
        device: str | None = None,
        *,
        base_url: str | None = None,
        run_id: str | None = None,
        target_runner_id: str | None = None,
        buffer_maxlen: int = 2000,
        queue_maxsize: int = 5000,
    ):
        self._managed = bool(run_id and target_runner_id)
        self._topic = "" if self._managed else (topic or get_topic(device))
        self._device = device
        self._run_id = run_id
        self._target_runner_id = target_runner_id
        self._case_id = "session"
        self._event_cursor = 0
        self._latest_event_id = 0
        self._last_transport_response: dict[str, Any] | None = None
        self._last_transport_event: dict[str, Any] | None = None
        self._url = _build_ws_url(
            topic=self._topic,
            device=self._device,
            base_url=base_url,
            use_topic=not self._managed,
        )
        self._buffer_maxlen = buffer_maxlen
        self._queue_maxsize = queue_maxsize
        self._recv_queue: queue.Queue[dict[str, Any]] = queue.Queue(maxsize=queue_maxsize)
        self._send_queue: queue.Queue[tuple[dict[str, Any], int]] = queue.Queue()
        self._pending: dict[int, tuple[queue.Queue[dict[str, Any]], str, str]] = {}
        self._sequence = 0
        self._lock = threading.Lock()
        self._stopped = threading.Event()
        self._thread: threading.Thread | None = None
        self._event_buffer: deque[dict[str, Any]] = deque(maxlen=buffer_maxlen)
        self._runner_info: dict[str, Any] | None = None
        self._runner_condition = threading.Condition()
        self._connection_error: Exception | None = None
        # Debug/relax flags at WS layer
        try:
            flags = _get_debug_flags()
            self._relax = bool(flags.relax_event_match)
            self._debug_dump = bool(flags.dump_events)
        except Exception:
            self._relax = False
            self._debug_dump = False

    def _run_async_loop(self) -> None:
        async def run() -> None:
            try:
                async with _ws_connect(
                    self._url,
                    open_timeout=get_connect_timeout(),
                    close_timeout=5,
                ) as ws:
                    if self._managed:
                        await ws.send(
                            json.dumps(
                                {
                                    "type": "controllerHello",
                                    "protocolVersion": 1,
                                    "runId": self._run_id,
                                    "targetRunnerId": self._target_runner_id,
                                }
                            )
                        )
                    loop = asyncio.get_event_loop()
                    response_timeout = get_response_timeout()

                    async def recv_loop() -> None:
                        while not self._stopped.is_set():
                            try:
                                raw = await asyncio.wait_for(ws.recv(), timeout=1.0)
                            except asyncio.TimeoutError:
                                continue
                            except Exception:
                                break
                            try:
                                data = json.loads(raw)
                                is_hello = isinstance(data, dict) and (
                                    data.get("type") == "hello"
                                    or (
                                        data.get("type") == "event"
                                        and data.get("eventType") == "runnerHello"
                                    )
                                )
                                if is_hello:
                                    hello = data.get("data") if data.get("eventType") == "runnerHello" else data
                                    if not isinstance(hello, dict):
                                        continue
                                    with self._runner_condition:
                                        self._runner_info = hello
                                        self._runner_condition.notify_all()
                                    continue
                                try:
                                    dbg = self._debug_dump
                                except Exception:
                                    dbg = False
                                if dbg:
                                    try:
                                        print(f"[WS-DUMP][{self._topic}] {json.dumps(data, ensure_ascii=False)}")
                                    except Exception:
                                        print(f"[WS-DUMP][{self._topic}] <non-json>")
                                if data.get("type") == "event":
                                    try:
                                        self._latest_event_id = max(
                                            self._latest_event_id,
                                            int(data.get("eventId") or 0),
                                        )
                                    except (TypeError, ValueError):
                                        pass
                                seq = data.get("id") if data.get("id") is not None else data.get("sequence")
                                if (
                                    seq is not None
                                    and seq in self._pending
                                    and _is_response_message(data, request_id=seq, request_sequence=None)
                                ):
                                    with self._lock:
                                        pending = self._pending.pop(seq, None)
                                    if pending is not None:
                                        q, expect_manager, expect_cmd = pending
                                        if (
                                            ("manager" in data and data.get("manager") != expect_manager)
                                            or ("cmd" in data and data.get("cmd") != expect_cmd)
                                        ):
                                            # sequence 撞车或旧连接回包串入：放回事件队列，不作为当前 call 响应
                                            try:
                                                self._recv_queue.put_nowait(data)
                                            except queue.Full:
                                                pass
                                            continue
                                        try:
                                            q.put_nowait(data)
                                        except Exception:
                                            pass
                                else:
                                    try:
                                        self._recv_queue.put_nowait(data)
                                    except queue.Full:
                                        pass
                            except Exception:
                                pass

                    def get_send() -> tuple[dict[str, Any], int] | None:
                        try:
                            return self._send_queue.get(timeout=1.0)
                        except queue.Empty:
                            return None

                    async def send_loop() -> None:
                        while not self._stopped.is_set():
                            result = await loop.run_in_executor(None, get_send)
                            if result is None:
                                continue
                            req, seq = result
                            try:
                                await ws.send(json.dumps(req))
                            except Exception:
                                with self._lock:
                                    self._pending.pop(seq, None)
                                break

                    await asyncio.gather(
                        asyncio.create_task(recv_loop()),
                        asyncio.create_task(send_loop()),
                    )
            except Exception as error:
                with self._runner_condition:
                    self._connection_error = error
                    self._runner_condition.notify_all()
            finally:
                with self._lock:
                    for q in self._pending.values():
                        try:
                            q.put_nowait({})
                        except Exception:
                            pass
                    self._pending.clear()

        asyncio.run(run())

    def start(self) -> None:
        if self._thread is not None and self._thread.is_alive():
            return
        self._stopped.clear()
        self._sequence = 0
        self._thread = threading.Thread(target=self._run_async_loop, daemon=True)
        self._thread.start()
        time.sleep(0.5)

    def call(
        self,
        manager: str,
        cmd: str,
        info: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> dict[str, Any]:
        self.start()
        self._sequence += 1
        seq = self._sequence
        req: dict[str, Any] = {
            "manager": manager,
            "cmd": cmd,
            "info": info or {},
            "id": uuid.uuid4().hex,
            "sequence": seq,
            **kwargs,
        }
        if self._managed:
            req.update(
                {
                    "type": "request",
                    "protocolVersion": 1,
                    "runId": self._run_id,
                    "caseId": self._case_id,
                    "requestId": req["id"],
                    "targetRunnerId": self._target_runner_id,
                }
            )
        if self._device is not None:
            req["device"] = self._device
        resp_q: queue.Queue[dict[str, Any]] = queue.Queue(maxsize=1)
        request_key = req["id"]
        with self._lock:
            self._pending[request_key] = (resp_q, manager, cmd)
        self._send_queue.put((req, seq))
        try:
            out = resp_q.get(timeout=get_response_timeout())
        except queue.Empty:
            with self._lock:
                self._pending.pop(request_key, None)
            raise TimeoutError(f"Wait response timeout (cmd={cmd}, id={request_key}, sequence={seq})") from None
        if not out:
            raise RuntimeError("Connection closed")
        self._last_transport_response = dict(out)
        if self._managed:
            return {
                key: value
                for key, value in out.items()
                if key not in _MANAGED_TRANSPORT_FIELDS
            }
        return out

    def receive_message(
        self,
        *,
        match_cmd: str | None = None,
        match_event_type: str | None = None,
        timeout: float = 10.0,
    ) -> dict[str, Any] | None:
        deadline = time.monotonic() + timeout
        have_filter = match_cmd is not None or match_event_type is not None
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return None
            # 1) 先看 event_buffer 里是否有匹配
            n = len(self._event_buffer)
            for _ in range(n):
                m = self._event_buffer.popleft()
                if self._is_historical_event(m):
                    continue
                if _message_matches(m, match_cmd, match_event_type, relax=self._relax):
                    return self._return_event(m)
                self._event_buffer.append(m)
            if (not have_filter or self._relax) and self._event_buffer:
                return self._event_buffer.popleft()
            # 2) 从 recv 队列取
            try:
                m = self._recv_queue.get(timeout=min(remaining, 1.0))
            except queue.Empty:
                continue
            if self._is_historical_event(m):
                continue
            if _message_matches(m, match_cmd, match_event_type, relax=self._relax):
                return self._return_event(m)
            self._event_buffer.append(m)

    def _return_event(self, message: dict[str, Any]) -> dict[str, Any]:
        self._last_transport_event = dict(message)
        if not self._managed:
            return message
        return {
            key: value
            for key, value in message.items()
            if key not in _MANAGED_EVENT_TRANSPORT_FIELDS
        }

    def begin_case(self, case_id: str) -> int:
        """Start an isolated event view without deleting SDK or queued data."""
        self._case_id = case_id
        self._event_cursor = self._latest_event_id
        return self._event_cursor

    def end_case(self) -> None:
        self._case_id = "session"

    def _is_historical_event(self, message: dict[str, Any]) -> bool:
        if message.get("type") != "event" or message.get("eventId") is None:
            return False
        try:
            return int(message["eventId"]) <= self._event_cursor
        except (TypeError, ValueError):
            return False

    def drain_events(self, timeout: float = 2.0) -> None:
        """清空当前连接上积压的推送/响应，避免影响后续 receive_message。登录后调用。"""
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                self._recv_queue.get(timeout=0.2)
            except queue.Empty:
                pass
        self._event_buffer.clear()

    def wait_for_hello(
        self,
        *,
        expected_sdk_version: str | None = None,
        expected_runner_id: str | None = None,
        expected_device_name: str | None = None,
        expected_platform: str | None = None,
        timeout: float = 120.0,
    ) -> dict[str, Any]:
        deadline = time.monotonic() + timeout
        with self._runner_condition:
            while True:
                info = self._runner_info
                matches = info is not None and all(
                    expected is None or str(info.get(key)) == str(expected)
                    for key, expected in (
                        ("sdkVersion", expected_sdk_version),
                        ("runnerId", expected_runner_id),
                        ("deviceName", expected_device_name),
                        ("platform", expected_platform),
                    )
                )
                if matches:
                    return dict(info)
                if self._connection_error is not None:
                    raise RuntimeError(
                        f"WebSocket environment error (device={self._device}): "
                        f"{self._connection_error}"
                    ) from self._connection_error
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    expectation = (
                        f"sdkVersion={expected_sdk_version}, "
                        f"runnerId={expected_runner_id}, "
                        f"deviceName={expected_device_name}, "
                        f"platform={expected_platform}"
                    )
                    raise TimeoutError(
                        f"Wait runner hello timeout (device={self._device}, {expectation}, "
                        f"lastHello={info})"
                    )
                self._runner_condition.wait(timeout=min(remaining, 1.0))

    def clear_runner_info(self) -> None:
        with self._runner_condition:
            self._runner_info = None

    @property
    def runner_info(self) -> dict[str, Any] | None:
        with self._runner_condition:
            return dict(self._runner_info) if self._runner_info is not None else None

    @property
    def last_transport_response(self) -> dict[str, Any] | None:
        value = self._last_transport_response
        return dict(value) if value is not None else None

    @property
    def last_transport_event(self) -> dict[str, Any] | None:
        value = self._last_transport_event
        return dict(value) if value is not None else None

    def stop(self) -> None:
        self._stopped.set()
        if self._thread is not None:
            self._thread.join(timeout=5.0)
            self._thread = None

    @property
    def topic(self) -> str:
        return self._topic

    @property
    def device(self) -> str | None:
        return self._device


class SDKWebSocketClient:
    """
    可复用的 WebSocket 客户端，同一连接上可发多条请求（按 sequence 区分响应）。
    适用于多步用例或需要保持长连接的场景。
    """

    def __init__(
        self,
        topic: str | None = None,
        device: str | None = None,
    ):
        self._topic = topic or get_topic(device)
        self._device = device
        self._url = _build_ws_url(topic=self._topic, device=None)
        self._ws: WebSocketClientProtocol | None = None
        self._sequence = 0
        self._pending: dict[int, asyncio.Future] = {}

    async def connect(self) -> None:
        if self._ws is not None and self._ws.open:
            return
        self._ws = await _ws_connect(
            self._url,
            open_timeout=get_connect_timeout(),
            close_timeout=5,
        )
        self._receive_task = asyncio.create_task(self._receive_loop())

    async def _receive_loop(self) -> None:
        if self._ws is None:
            return
        try:
            async for raw in self._ws:
                try:
                    data = json.loads(raw)
                except Exception:
                    continue
                seq = data.get("id") if data.get("id") is not None else data.get("sequence")
                if (
                    seq is not None
                    and seq in self._pending
                    and _is_response_message(data, request_id=seq, request_sequence=None)
                ):
                    self._pending.pop(seq).set_result(data)
        except asyncio.CancelledError:
            pass
        except Exception:
            for fut in self._pending.values():
                if not fut.done():
                    fut.cancel()
            self._pending.clear()

    async def call(
        self,
        manager: str,
        cmd: str,
        info: dict[str, Any] | None = None,
        **extra: Any,
    ) -> dict[str, Any]:
        await self.connect()
        assert self._ws is not None and self._ws.open
        self._sequence += 1
        seq = self._sequence
        req: dict[str, Any] = {
            "manager": manager,
            "cmd": cmd,
            "info": info or {},
            "id": uuid.uuid4().hex,
            "sequence": seq,
            **extra,
        }
        if self._device is not None:
            req["device"] = self._device
        fut: asyncio.Future[dict[str, Any]] = asyncio.get_running_loop().create_future()
        request_key = req["id"]
        self._pending[request_key] = fut
        await self._ws.send(json.dumps(req))
        try:
            return await asyncio.wait_for(fut, timeout=get_response_timeout())
        except asyncio.TimeoutError:
            self._pending.pop(request_key, None)
            raise TimeoutError(f"Wait response timeout (cmd={cmd}, id={request_key}, sequence={seq})") from None

    async def close(self) -> None:
        if hasattr(self, "_receive_task"):
            self._receive_task.cancel()
            try:
                await self._receive_task
            except asyncio.CancelledError:
                pass
        if self._ws is not None:
            await self._ws.close()
            self._ws = None
        self._pending.clear()
