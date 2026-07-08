from __future__ import annotations

import time
import uuid

from src import Cmd, ChatRoomEvent
from src.tools.response_match import gt
import pytest
from src.rest_api.chatroom_api import create_chat_room, delete_chat_room


def new_chatroom_name(prefix: str = "chatroom") -> str:
    return f"{prefix}_{int(time.time() * 1000)}"


def new_chatroom_desc(prefix: str = "desc") -> str:
    return f"{prefix}_{uuid.uuid4().hex[:8]}"


def extract_chatroom_id(resp: dict) -> str:
    result = resp.get("result")
    if isinstance(result, dict):
        for key in ("roomId", "id", "chatRoomId"):
            value = result.get(key)
            if isinstance(value, str) and value:
                return value
    return ""


def _assert_event_envelope(assert_api, evt: dict, event_type: str) -> None:
    assert_api.assert_response_matches(
        evt,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": {},
        },
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
    )


def collect_chatroom_events(
    device,
    *,
    expected_event_types: set[str],
    chatroom_id: str | None = None,
    timeout: float = 10.0,
    require_event: bool = True,
) -> list[dict]:
    deadline = time.monotonic() + timeout
    events: list[dict] = []
    while time.monotonic() < deadline:
        evt = device.receive_message(timeout=min(1.0, max(0.1, deadline - time.monotonic())))
        if not isinstance(evt, dict):
            continue
        if evt.get("type") != "event":
            continue
        event_type = evt.get("eventType")
        if event_type not in expected_event_types:
            continue
        if chatroom_id is not None:
            data = evt.get("data")
            if not isinstance(data, dict):
                continue
            room = data.get("room")
            nested_room_id = room.get("roomId") if isinstance(room, dict) else None
            if (
                data.get("roomId") not in (None, chatroom_id)
                and data.get("chatRoomId") not in (None, chatroom_id)
                and nested_room_id not in (None, chatroom_id)
            ):
                continue
        events.append(evt)
    if require_event and expected_event_types and not events:
        raise AssertionError(f"未收到聊天室回调: expected={sorted(expected_event_types)}")
    return events


def assert_chatroom_event(
    assert_api,
    evt: dict,
    *,
    event_type: str,
    room_id: str | None = None,
    participant: str | None = None,
    ext: str | None = None,
) -> None:
    expected = {
        "type": "event",
        "eventType": event_type,
        "data": {},
    }
    if room_id:
        payload = {"roomId": room_id}
        if participant is not None:
            payload["participant"] = participant
        if ext is not None:
            payload["ext"] = ext
        expected["data"] = payload
    assert_api.assert_response_matches(
        evt,
        expected=expected,
        ignore_keys={"timestamp", "sequence", "serverTime", "localTime"},
    )


def chatroom_manager_call(device, cmd: str, info: dict | None = None, *, manager: str = "ChatRoomManager"):
    return device.call(manager, cmd, info=info or {})


def assert_join_chatroom_response(assert_api, resp: dict, *, device: str, room_id: str) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.joinChatRoom.value,
            "device": device,
            "result": {
                "roomId": room_id,
                "memberCount": gt(0),
                "isAllMemberMuted": False,
                "isInWhitelist": False,
            },
        },
        ignore_keys={
            "sequence",
            "owner",
            "maxUsers",
            "permissionType",
            "adminList",
            "muteList",
            "muteExpireTimestamp",
            "memberList",
            "blockList",
            "name",
            "desc",
            "announcement",
            "createTimestamp",
        },
    )


def create_chatroom_or_skip(*, owner: str, name_prefix: str = "chatroom", desc_prefix: str = "desc") -> tuple[str, str]:
    """
    通过 REST 创建聊天室。
    - 若当前 token 不具备聊天室权限（如 401 unauthorized），直接 skip，避免环境阻塞导致用例误报失败。
    """
    room_name = new_chatroom_name(name_prefix)
    try:
        created = create_chat_room(
            room_name=room_name,
            owner=owner,
            members=[owner],
            max_users=200,
            admin_members=[owner],
        )
    except RuntimeError as e:
        msg = str(e)
        if "HTTP 401" in msg or "unauthorized" in msg.lower():
            pytest.skip(f"REST token 无聊天室创建权限，跳过该用例: {msg}")
        raise

    room_id = ""
    if isinstance(created, dict):
        room_id = str(created.get("roomId") or created.get("id") or "")
        if not room_id:
            data = created.get("data")
            if isinstance(data, dict):
                room_id = str(data.get("roomId") or data.get("id") or "")
    assert room_id, f"REST 创建聊天室未返回 roomId: {created!r}"
    return room_id, room_name


def safe_delete_chatroom(room_id: str) -> None:
    try:
        delete_chat_room(room_id)
    except Exception:
        pass
