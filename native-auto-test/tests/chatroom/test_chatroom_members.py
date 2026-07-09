from __future__ import annotations

import json

import pytest

from src import Cmd, gt
from tests.chatroom.chatroom_helpers import (
    assert_join_chatroom_response,
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
        assert_join_chatroom_response(assert_api, resp, device="deviceB", room_id=room_id)

        members_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomMembers.value,
            info={"roomId": room_id, "cursor": "", "pageSize": 20},
        )
        assert_api.assert_response_matches(
            members_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomMembers.value,
                "device": "deviceA",
                "result": {
                    "cursor": "",
                    "list": [user_b],
                },
            },
            ignore_keys={"sequence"},
        )
    finally:
        safe_delete_chatroom(room_id)


def _join_ext(joiner: str, receiver: str, name: str) -> str:
    return json.dumps(
        {
            "user_id": joiner,
            "user_name": name,
            "user_face": "http://mingxiang.xiaoxingyun.xin/20251014/llk68ee3bd85cf5f.png",
            "jointime": 1782116263,
            "user_type": "user",
            "live_id": 82419,
            "master_user_id": receiver,
            "isliveroom": 1,
            "is_prohibit_speak": 0,
        },
        ensure_ascii=False,
        separators=(",", ":"),
    )


def _assert_join_response(assert_api, resp: dict, *, device_name: str, room_id: str, result_shape: str) -> None:
    if result_shape == "int":
        expected_result = 1
        ignore_keys = {"sequence"}
    else:
        expected_result = {
            "roomId": room_id,
            "memberCount": gt(0),
            "isAllMemberMuted": False,
            "isInWhitelist": False,
        }
        ignore_keys = {
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
        }
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": Cmd.joinChatRoom.value,
            "device": device_name,
            "result": expected_result,
        },
        ignore_keys=ignore_keys,
    )


def _assert_joiner_ext_delivered_to_observer(
    assert_api,
    *,
    room_id: str,
    observer_device,
    observer_device_name: str,
    observer_join_result_shape: str,
    observer_user: str,
    joiner_device,
    joiner_device_name: str,
    joiner_result_shape: str,
    joiner_user: str,
    ext: str,
) -> None:
    # 一端先进入聊天室保持在线；目标事件在加入方携带 ext 后，从观察端事件队列里查找。
    observer_join_resp = observer_device.call(
        "ChatRoomManager",
        Cmd.joinChatRoom.value,
        info={"roomId": room_id},
    )
    _assert_join_response(
        assert_api,
        observer_join_resp,
        device_name=observer_device_name,
        room_id=room_id,
        result_shape=observer_join_result_shape,
    )

    # 加入方必须在 joinChatRoom 请求里携带 ext；观察方收到的 SDK 回调 ext 必须与该入参完全一致。
    join_resp = joiner_device.call(
        "ChatRoomManager",
        Cmd.joinChatRoom.value,
        info={"roomId": room_id, "ext": ext},
    )
    _assert_join_response(
        assert_api,
        join_resp,
        device_name=joiner_device_name,
        room_id=room_id,
        result_shape=joiner_result_shape,
    )
    # 严格语义：ext 必须经服务器广播给“其他在线成员”，因此通过条件限定为观察端 B 收到回调。
    # 加入方自身的事件仅作为诊断日志收集，不作为通过条件（SDK 通常不向加入方回投自己的加入回调）。
    deadline_events = []
    joiner_self_events = []
    matching_event = None
    for _ in range(12):
        observer_events = collect_chatroom_events(
            observer_device,
            expected_event_types={"onMemberJoinedFromChatRoom"},
            chatroom_id=room_id,
            timeout=0.5,
            require_event=False,
        )
        deadline_events.extend(
            {"device": observer_device_name, "event": evt}
            for evt in observer_events
        )
        for evt in observer_events:
            data = evt.get("data")
            if isinstance(data, dict) and data.get("participant") == joiner_user and data.get("ext") == ext:
                matching_event = evt
                break
        if matching_event is not None:
            break

        # 仅收集加入方自身事件用于失败诊断，不参与匹配判定。
        self_events = collect_chatroom_events(
            joiner_device,
            expected_event_types={"onMemberJoinedFromChatRoom"},
            chatroom_id=room_id,
            timeout=0.5,
            require_event=False,
        )
        joiner_self_events.extend(
            {"device": joiner_device_name, "event": evt}
            for evt in self_events
        )

    assert matching_event is not None, (
        f"观察端 {observer_device_name}({observer_user}) 未收到加入方 {joiner_user} 携带 ext 的成员加入回调: "
        f"observer_events={deadline_events!r}, "
        f"joiner_self_events(仅诊断)={joiner_self_events!r}"
    )
    assert_chatroom_event(
        assert_api,
        matching_event,
        event_type="onMemberJoinedFromChatRoom",
        room_id=room_id,
        participant=joiner_user,
        ext=ext,
    )


def test_chatroom_join_with_ext_member_joined_callback(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    user_c,
):
    """joinChatRoom：加入方携带头像/昵称等 ext，观察端（其他在线成员）收到同一个成员加入回调 ext。"""
    # 用 user_c 建房，避免 A/B 任一方作为 REST 初始成员污染“真实加入”语义。
    room_id, _ = create_chatroom_or_skip(owner=user_c, name_prefix="join_ext", desc_prefix="join_ext")
    try:
        _assert_joiner_ext_delivered_to_observer(
            assert_api,
            room_id=room_id,
            observer_device=device_b,
            observer_device_name="deviceB",
            observer_join_result_shape="room",
            observer_user=user_b,
            joiner_device=device_a,
            joiner_device_name="deviceA",
            joiner_result_shape="room",
            joiner_user=user_a,
            ext=_join_ext(user_a, user_b, "聊天室加入用户A"),
        )
    finally:
        safe_delete_chatroom(room_id)
