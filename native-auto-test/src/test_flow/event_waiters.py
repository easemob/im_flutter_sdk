"""统一的事件等待原语。

Case 只负责业务前置和字段断言；消息事件的等待、跨事件累计和多端计数在这里统一处理。
同一个 msgId 不去重：多设备送达回执可能合法地重复出现。
"""
from __future__ import annotations

import time
from typing import Any, Callable


def wait_for_event(
    device,
    event_type: str,
    *,
    predicate: Callable[[dict[str, Any]], bool] | None = None,
    timeout: float = 30.0,
) -> dict[str, Any]:
    """等待一个满足条件的事件；不匹配事件继续留在等待流程中。"""
    deadline = time.monotonic() + timeout
    seen: list[dict[str, Any]] = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if not event:
            continue
        seen.append(event)
        if predicate is None or predicate(event):
            return event
    raise AssertionError(
        f"未收到目标事件: eventType={event_type}, timeout={timeout}, seen={seen}"
    )


def wait_for_message_occurrences(
    device,
    event_type: str,
    *,
    real_id: str,
    content: str | None = None,
    body_type: int | None = None,
    expected_message_count: int = 1,
    timeout: float = 30.0,
) -> dict[str, Any] | list[dict[str, Any]]:
    """按 msgId 收集消息出现次数，支持一个事件多条或多个事件各一条。

    ``expected_message_count`` 是出现次数，不是去重后的 msgId 数量。
    传入设备列表时，每个 endpoint 独立等待并返回一个事件。
    """
    if isinstance(device, (tuple, list)):
        return [
            wait_for_message_occurrences(
                endpoint,
                event_type,
                real_id=real_id,
                content=content,
                body_type=body_type,
                expected_message_count=expected_message_count,
                timeout=timeout,
            )
            for endpoint in device
        ]

    if expected_message_count < 1:
        raise ValueError("expected_message_count 必须大于 0")

    deadline = time.monotonic() + timeout
    seen: list[dict[str, Any]] = []
    matched: list[dict[str, Any]] = []
    first_event: dict[str, Any] | None = None
    last_event: dict[str, Any] | None = None

    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if not event:
            continue
        seen.append(event)
        first_event = first_event or event
        last_event = event
        messages = ((event.get("data") or {}).get("messages") or [])
        for message in messages:
            if not isinstance(message, dict):
                continue
            if str(message.get("msgId")) != str(real_id):
                continue
            body = message.get("body") or {}
            if content is not None and body.get("content") != content:
                continue
            if body_type is not None and body.get("type") != body_type:
                continue
            matched.append(message)

        if len(matched) >= expected_message_count:
            source = first_event or last_event or {}
            return {
                "type": source.get("type", "event"),
                "eventType": source.get("eventType", event_type),
                "data": {"messages": matched},
                "timestamp": (last_event or source).get("timestamp"),
            }

    raise AssertionError(
        f"未收到足够的目标消息事件: eventType={event_type}, msgId={real_id}, "
        f"expected={expected_message_count}, actual={len(matched)}, seen={seen}"
    )


def wait_for_text_event(
    device,
    event_type: str,
    *,
    content: str,
    real_id: str | None = None,
    timeout: float = 30.0,
) -> tuple[dict[str, Any], dict[str, Any]]:
    """统一等待文本发送成功或接收事件，并返回事件和匹配消息。

    发送成功场景同时观察 ``onMessageError``，这样参数/服务端拒绝不会伪装成
    “没有收到 onMessageSuccess”。
    """
    deadline = time.monotonic() + timeout
    seen: list[dict[str, Any]] = []
    observe_all = event_type == "onMessageSuccess"
    while time.monotonic() < deadline:
        wait_timeout = min(2.0, max(0.1, deadline - time.monotonic()))
        if observe_all:
            event = device.receive_message(timeout=wait_timeout)
        else:
            event = device.receive_message(
                match_event_type=event_type,
                timeout=wait_timeout,
            )
        if not event:
            continue
        seen.append(event)
        actual_event_type = event.get("eventType")
        if observe_all and actual_event_type == "onMessageError":
            error = (event.get("data") or {}).get("error")
            raise AssertionError(
                f"发送文本未成功，收到 onMessageError: content={content!r}, error={error}, event={event}"
            )
        if actual_event_type != event_type:
            continue
        data = event.get("data") or {}
        candidates = []
        if isinstance(data.get("msg"), dict):
            candidates.append(data["msg"])
        candidates.extend(item for item in (data.get("messages") or []) if isinstance(item, dict))
        for message in candidates:
            if real_id is not None and str(message.get("msgId")) != str(real_id):
                continue
            if (message.get("body") or {}).get("content") != content:
                continue
            return event, message
    raise AssertionError(
        f"未收到目标文本事件: eventType={event_type}, content={content!r}, seen={seen}"
    )
