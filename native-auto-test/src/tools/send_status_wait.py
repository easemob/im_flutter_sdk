"""Send-status diagnostics without retrying or relaxing success assertions."""
import time

import pytest


def wait_send_success(device, *, temp_id, predicate=None, timeout=60.0):
    """Return the original success event; report only safe diagnostic fields.

    Filtered receives preserve unrelated events in the WS client's buffer.
    Error events correlate by the original local ID, not the server-assigned ID.
    """
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        for event_type in ("onMessageError", "onMessageSuccess"):
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                break
            event = device.receive_message(
                match_event_type=event_type, timeout=min(0.5, remaining)
            )
            if not event:
                continue
            data = event.get("data") or {}
            if str(data.get("msgId")) != str(temp_id):
                continue
            msg = data.get("msg") or {}
            error = data.get("error") or {}
            # Do not dump bodies, attachment secrets, or arbitrary error text.
            summary = {"eventType": event_type, "status": msg.get("status"),
                       "code": error.get("code")}
            seen.append(summary)
            if event_type == "onMessageError":
                pytest.fail(f"发送失败: tempId={temp_id}, diagnostic={summary}")
            if predicate is None or predicate(event):
                return event
    pytest.fail(
        f"未收到满足断言的 onMessageSuccess: tempId={temp_id}; "
        f"匹配的 success/error 诊断={seen[-10:]}"
    )
