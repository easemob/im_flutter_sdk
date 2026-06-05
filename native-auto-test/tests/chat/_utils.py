from __future__ import annotations

import time
from typing import Any


def now_ms() -> int:
    return int(time.time() * 1000)


def build_text(from_user: str, to_user: str, content: str, chat_type: int = 0) -> dict:
    """与被测端 MessageHelper.fromJson 对齐的最小可用文本消息 JSON。"""
    return {
        "from": from_user,
        "to": to_user,
        "chatType": chat_type,
        "direction": 0,
        "body": {"type": 0, "content": content},
        "hasReadAck": False,
        "needGroupAck": False,
        "isThread": False,
        "deliverOnlineOnly": False,
    }


def find_first(obj: Any, key: str) -> Any | None:
    if isinstance(obj, dict):
        if key in obj:
            return obj[key]
        for v in obj.values():
            r = find_first(v, key)
            if r is not None:
                return r
    elif isinstance(obj, (list, tuple)):
        for it in obj:
            r = find_first(it, key)
            if r is not None:
                return r
    return None

