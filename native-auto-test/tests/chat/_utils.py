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
        "needReadReceipt": False,
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


def swt_to_send(info: dict) -> dict:
    """sendMessageWithType 的 info（type+payload）→ sendMessage 的消息 JSON（body 按类型转换）。

    注意：MessageBodyHelper.fromJson 对各 body 类型用 getInt/getString（必传字段），
    媒体类型需补全 fileStatus/fileSize/duration 等；deliverOnlineOnly 是消息级字段（body 外）。
    """
    type_key = info["type"]
    payload = info["payload"]
    to = payload["targetId"]
    chat_type = info.get("chatType", 0)
    if type_key == "txt":
        body = {"type": 0, "content": payload.get("content", "")}
        if payload.get("targetLanguages"):
            body["targetLanguages"] = list(payload["targetLanguages"])
    elif type_key == "cmd":
        body = {"type": 6, "action": payload.get("action", ""), "deliverOnlineOnly": payload.get("deliverOnlineOnly", False)}
    elif type_key == "file":
        body = {"type": 5, "localPath": payload.get("filePath", ""), "displayName": payload.get("displayName", ""),
                "remotePath": "", "secret": "", "fileStatus": 0, "fileSize": 0}
    elif type_key == "image":
        body = {"type": 1, "localPath": payload.get("filePath", ""), "displayName": payload.get("displayName", ""),
                "remotePath": "", "secret": "", "thumbnailLocalPath": payload.get("thumbnailLocalPath", ""),
                "thumbnailRemotePath": "", "thumbnailSecret": "", "thumbnailStatus": 0, "fileSize": 0,
                "width": 0, "height": 0, "sendOriginalImage": False, "isGif": False, "fileStatus": 0}
    elif type_key == "video":
        body = {"type": 2, "localPath": payload.get("filePath", ""), "duration": payload.get("duration", 0),
                "thumbnailRemotePath": "", "thumbnailLocalPath": payload.get("thumbnailLocalPath", ""),
                "thumbnailSecret": "", "thumbnailStatus": 0, "displayName": payload.get("displayName", ""),
                "remotePath": "", "secret": "", "fileSize": 0, "fileStatus": 0, "width": 0, "height": 0}
    elif type_key == "voice":
        body = {"type": 4, "localPath": payload.get("filePath", ""), "duration": payload.get("duration", 0),
                "fileStatus": 0, "displayName": payload.get("displayName", ""), "secret": "",
                "remotePath": "", "fileSize": 0}
    elif type_key == "location":
        body = {"type": 3, "latitude": payload.get("latitude", 0), "longitude": payload.get("longitude", 0),
                "address": payload.get("address", ""), "buildingName": payload.get("buildingName", "")}
    elif type_key == "custom":
        body = {"type": 7, "event": payload.get("event", ""), "params": payload.get("params", {})}
    elif type_key == "combine":
        body = {"type": 8, "title": payload.get("title", ""), "summary": payload.get("summary", ""),
                "compatibleText": payload.get("compatibleText", ""), "fileStatus": 0}
        if payload.get("msgIds"):
            body["messageList"] = list(payload["msgIds"])
    else:
        raise ValueError(f"unknown swt type: {type_key}")
    result = {"to": to, "chatType": chat_type, "direction": 0, "deliverOnlineOnly": False, "body": body}
    if info.get("needReadReceipt"):
        # 5.0 已读回执契约：消息需标记 isNeedReadReceipt=true 接收方才回执
        result["needReadReceipt"] = True
    return result
