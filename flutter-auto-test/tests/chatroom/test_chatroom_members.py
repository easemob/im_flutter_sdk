from __future__ import annotations

import pytest

from src import Cmd
from tests.chatroom.chatroom_helpers import (
    assert_chatroom_event,
    collect_chatroom_events,
    create_chatroom_or_skip,
    safe_delete_chatroom,
)


pytestmark = [pytest.mark.client, pytest.mark.chatroom]


def test_chatroom_join_public_chatroom_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="join", desc_prefix="join")
    try:
        resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.joinChatRoom.value,
                "device": "deviceB",
                "result": 1,
            },
            ignore_keys={"sequence"},
        )
        events = collect_chatroom_events(
            device_b,
            expected_event_types={"onMemberJoinedFromChatRoom"},
            chatroom_id=room_id,
            timeout=10.0,
        )
        for evt in events:
            assert_chatroom_event(
                assert_api,
                evt,
                event_type="onMemberJoinedFromChatRoom",
                room_id=room_id,
                participant=user_a,
                ext="",
            )
    finally:
        safe_delete_chatroom(room_id)
