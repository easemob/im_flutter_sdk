"""ChatRoom 回调事件用例。"""
from __future__ import annotations

import uuid

import pytest

from src import Cmd, ChatRoomEvent
from tests.chatroom.chatroom_helpers import collect_chatroom_events, create_chatroom_or_skip, safe_delete_chatroom
from tests.chatroom.test_chatroom_management_basics import _assert_success_envelope, _join_chatroom_as_b


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat4_23_0]


def _first_chatroom_event(device, *, room_id: str, event_types: set[str], timeout: float = 10.0) -> dict:
    events = collect_chatroom_events(
        device,
        expected_event_types=event_types,
        chatroom_id=room_id,
        timeout=timeout,
    )
    return events[0]


def _event_data(evt: dict) -> dict:
    data = evt.get("data")
    assert isinstance(data, dict), f"聊天室回调 data 应为 dict: {evt}"
    return data


def _members_from_allow_list_event(data: dict) -> list:
    members = data.get("members")
    if members is None:
        members = data.get("whitelist")
    assert isinstance(members, list), f"白名单回调 members/whitelist 应为 list: {data}"
    return members


def _join_chatroom_as_b_and_wait_ready(device_b, assert_api, room_id: str) -> None:
    _join_chatroom_as_b(device_b, assert_api, room_id)
    _first_chatroom_event(
        device_b,
        room_id=room_id,
        event_types={ChatRoomEvent.ON_MEMBER_JOINED.value, "onMemberJoinedFromChatRoom"},
    )


def test_chatroom_admin_added_and_removed_callbacks(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_admin", desc_prefix="cb_admin")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        add_resp = device_a.call(
            "ChatRoomManager",
            Cmd.addChatRoomAdmin.value,
            info={"roomId": room_id, "admin": user_b},
        )
        _assert_success_envelope(assert_api, add_resp, cmd=Cmd.addChatRoomAdmin.value, device="deviceA")
        add_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_ADMIN_ADDED.value, "onAdminAddedFromChatRoom"},
        )
        add_data = _event_data(add_evt)
        assert add_data.get("roomId") == room_id, f"管理员添加回调 roomId 不匹配: {add_evt}"
        assert add_data.get("admin") == user_b, f"管理员添加回调 admin 不匹配: {add_evt}"

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeChatRoomAdmin.value,
            info={"roomId": room_id, "admin": user_b},
        )
        _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomAdmin.value, device="deviceA")
        remove_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_ADMIN_REMOVED.value, "onAdminRemovedFromChatRoom"},
        )
        remove_data = _event_data(remove_evt)
        assert remove_data.get("roomId") == room_id, f"管理员移除回调 roomId 不匹配: {remove_evt}"
        assert remove_data.get("admin") == user_b, f"管理员移除回调 admin 不匹配: {remove_evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_owner_changed_callback(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_owner", desc_prefix="cb_owner")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        change_resp = device_a.call(
            "ChatRoomManager",
            Cmd.changeChatRoomOwner.value,
            info={"roomId": room_id, "newOwner": user_b},
        )
        _assert_success_envelope(assert_api, change_resp, cmd=Cmd.changeChatRoomOwner.value, device="deviceA")
        evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_OWNER_CHANGED.value, "onOwnerChangedFromChatRoom"},
        )
        data = _event_data(evt)
        assert data.get("roomId") == room_id, f"owner 变更回调 roomId 不匹配: {evt}"
        assert data.get("newOwner") == user_b, f"owner 变更回调 newOwner 不匹配: {evt}"
        assert data.get("oldOwner") == user_a, f"owner 变更回调 oldOwner 不匹配: {evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_all_member_mute_state_callbacks(device_a, device_b, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_mute_all", desc_prefix="cb_mute_all")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)
        event_types = {ChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value, "onAllChatRoomMemberMuteStateChanged"}

        mute_resp = device_a.call("ChatRoomManager", Cmd.muteAllChatRoomMembers.value, info={"roomId": room_id})
        _assert_success_envelope(assert_api, mute_resp, cmd=Cmd.muteAllChatRoomMembers.value, device="deviceA")
        mute_evt = _first_chatroom_event(device_b, room_id=room_id, event_types=event_types)
        mute_data = _event_data(mute_evt)
        assert mute_data.get("roomId") == room_id, f"全员禁言回调 roomId 不匹配: {mute_evt}"
        assert (mute_data.get("isAllMuted") if "isAllMuted" in mute_data else mute_data.get("isMuted")) is True, (
            f"全员禁言回调状态应为 true: {mute_evt}"
        )

        unmute_resp = device_a.call("ChatRoomManager", Cmd.unMuteAllChatRoomMembers.value, info={"roomId": room_id})
        _assert_success_envelope(assert_api, unmute_resp, cmd=Cmd.unMuteAllChatRoomMembers.value, device="deviceA")
        unmute_evt = _first_chatroom_event(device_b, room_id=room_id, event_types=event_types)
        unmute_data = _event_data(unmute_evt)
        assert unmute_data.get("roomId") == room_id, f"解除全员禁言回调 roomId 不匹配: {unmute_evt}"
        assert (unmute_data.get("isAllMuted") if "isAllMuted" in unmute_data else unmute_data.get("isMuted")) is False, (
            f"解除全员禁言回调状态应为 false: {unmute_evt}"
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_attributes_updated_and_removed_callbacks(device_a, device_b, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_attrs", desc_prefix="cb_attrs")
    attr_key = f"cb_attr_{uuid.uuid4().hex[:8]}"
    attr_value = f"value-{uuid.uuid4().hex[:8]}"
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        set_resp = device_a.call(
            "ChatRoomManager",
            Cmd.setChatRoomAttributes.value,
            info={
                "roomId": room_id,
                "attributes": {attr_key: attr_value},
                "autoDelete": False,
                "forced": True,
            },
        )
        _assert_success_envelope(assert_api, set_resp, cmd=Cmd.setChatRoomAttributes.value, device="deviceA")
        updated_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_ATTRIBUTES_UPDATED.value, "onAttributesUpdated"},
        )
        updated_data = _event_data(updated_evt)
        assert updated_data.get("roomId") == room_id, f"属性更新回调 roomId 不匹配: {updated_evt}"
        assert updated_data.get("attributes", {}).get(attr_key) == attr_value, f"属性更新回调值不匹配: {updated_evt}"
        assert updated_data.get("from") == user_a or updated_data.get("fromId") == user_a, (
            f"属性更新回调 from/fromId 不匹配: {updated_evt}"
        )

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeChatRoomAttributes.value,
            info={"roomId": room_id, "keys": [attr_key], "forced": True},
        )
        _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomAttributes.value, device="deviceA")
        removed_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_ATTRIBUTES_REMOVED.value, "onAttributesRemoved"},
        )
        removed_data = _event_data(removed_evt)
        removed_keys = removed_data.get("removedKeys") or removed_data.get("keys")
        assert removed_data.get("roomId") == room_id, f"属性删除回调 roomId 不匹配: {removed_evt}"
        assert isinstance(removed_keys, list), f"属性删除回调 removedKeys/keys 应为 list: {removed_evt}"
        assert attr_key in removed_keys, f"属性删除回调缺少删除 key: {removed_evt}"
        assert removed_data.get("from") == user_a or removed_data.get("fromId") == user_a, (
            f"属性删除回调 from/fromId 不匹配: {removed_evt}"
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_announcement_changed_callback(device_a, device_b, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_announcement", desc_prefix="cb_announcement")
    announcement = f"notice-{uuid.uuid4().hex[:8]}"
    try:
        _join_chatroom_as_b_and_wait_ready(device_b, assert_api, room_id)

        update_resp = device_a.call(
            "ChatRoomManager",
            Cmd.updateChatRoomAnnouncement.value,
            info={"roomId": room_id, "announcement": announcement},
        )
        _assert_success_envelope(assert_api, update_resp, cmd=Cmd.updateChatRoomAnnouncement.value, device="deviceA")
        evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_ANNOUNCEMENT_CHANGED.value, "onAnnouncementChangedFromChatRoom"},
        )
        data = _event_data(evt)
        assert data.get("roomId") == room_id, f"公告变更回调 roomId 不匹配: {evt}"
        assert data.get("announcement") == announcement, f"公告变更回调 announcement 不匹配: {evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_specification_changed_callback(device_a, device_b, assert_api, user_a):
    """changeChatRoomSubject 触发聊天室规格变更回调，校验 room 对象中的 roomId/name。"""
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_spec", desc_prefix="cb_spec")
    subject = f"spec-{uuid.uuid4().hex[:8]}"
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        change_resp = device_a.call(
            "ChatRoomManager",
            Cmd.changeChatRoomSubject.value,
            info={"roomId": room_id, "subject": subject},
        )
        _assert_success_envelope(assert_api, change_resp, cmd=Cmd.changeChatRoomSubject.value, device="deviceA")
        evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_SPECIFICATION_CHANGED.value, "onSpecificationChanged"},
        )
        data = _event_data(evt)
        room = data.get("room")
        assert isinstance(room, dict), f"规格变更回调 room 应为 dict: {evt}"
        assert room.get("roomId") == room_id, f"规格变更回调 roomId 不匹配: {evt}"
        assert room.get("name") == subject, f"规格变更回调 name 不匹配: {evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_allow_list_added_and_removed_callbacks(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_allow", desc_prefix="cb_allow")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        add_resp = device_a.call(
            "ChatRoomManager",
            Cmd.addMembersToChatRoomWhiteList.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(assert_api, add_resp, cmd=Cmd.addMembersToChatRoomWhiteList.value, device="deviceA")
        add_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_WHITE_LIST_ADDED.value, "onAllowListAddedFromChatRoom"},
        )
        add_data = _event_data(add_evt)
        assert add_data.get("roomId") == room_id, f"白名单添加回调 roomId 不匹配: {add_evt}"
        assert user_b in _members_from_allow_list_event(add_data), f"白名单添加回调成员列表缺少 B: {add_evt}"

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeMembersFromChatRoomWhiteList.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(
            assert_api,
            remove_resp,
            cmd=Cmd.removeMembersFromChatRoomWhiteList.value,
            device="deviceA",
        )
        remove_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_WHITE_LIST_REMOVED.value, "onAllowListRemovedFromChatRoom"},
        )
        remove_data = _event_data(remove_evt)
        assert remove_data.get("roomId") == room_id, f"白名单移除回调 roomId 不匹配: {remove_evt}"
        assert user_b in _members_from_allow_list_event(remove_data), f"白名单移除回调成员列表缺少 B: {remove_evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_mute_list_added_and_removed_callbacks(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="cb_mute", desc_prefix="cb_mute")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        mute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.muteChatRoomMembers.value,
            info={"roomId": room_id, "muteMembers": [user_b], "duration": 60000},
        )
        _assert_success_envelope(assert_api, mute_resp, cmd=Cmd.muteChatRoomMembers.value, device="deviceA")
        mute_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_MUTE_LIST_ADDED.value, "onMuteListAddedFromChatRoom"},
        )
        mute_data = _event_data(mute_evt)
        mutes = mute_data.get("mutes")
        assert mute_data.get("roomId") == room_id, f"禁言添加回调 roomId 不匹配: {mute_evt}"
        assert (isinstance(mutes, dict) and user_b in mutes) or (isinstance(mutes, list) and user_b in mutes), (
            f"禁言添加回调 mutes 缺少 B: {mute_evt}"
        )

        unmute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.unMuteChatRoomMembers.value,
            info={"roomId": room_id, "unMuteMembers": [user_b]},
        )
        _assert_success_envelope(assert_api, unmute_resp, cmd=Cmd.unMuteChatRoomMembers.value, device="deviceA")
        unmute_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_MUTE_LIST_REMOVED.value, "onMuteListRemovedFromChatRoom"},
        )
        unmute_data = _event_data(unmute_evt)
        unmute_mutes = unmute_data.get("mutes")
        assert unmute_data.get("roomId") == room_id, f"禁言移除回调 roomId 不匹配: {unmute_evt}"
        assert isinstance(unmute_mutes, list), f"禁言移除回调 mutes 应为 list: {unmute_evt}"
        assert user_b in unmute_mutes, f"禁言移除回调 mutes 缺少 B: {unmute_evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_member_exited_callback(device_a, device_b, assert_api, user_a, user_b):
    """leaveChatRoom 触发成员主动退出回调，校验 roomId/participant。"""
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="cb_exit", desc_prefix="cb_exit")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        leave_resp = device_b.call("ChatRoomManager", Cmd.leaveChatRoom.value, info={"roomId": room_id})
        assert_api.assert_response_matches(
            leave_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.leaveChatRoom.value,
                "device": "deviceB",
                "result": True,
            },
            ignore_keys={"sequence"},
        )
        evt = _first_chatroom_event(
            device_a,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_MEMBER_EXITED.value, "onMemberExitedFromChatRoom"},
        )
        data = _event_data(evt)
        assert data.get("roomId") == room_id, f"成员退出回调 roomId 不匹配: {evt}"
        assert data.get("participant") == user_b, f"成员退出回调 participant 不匹配: {evt}"
        assert data.get("roomName") in ("", room_name), f"成员退出回调 roomName 不匹配: {evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_removed_and_destroyed_callbacks(device_a, device_b, assert_api, user_a, user_b):
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="cb_remove", desc_prefix="cb_remove")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeChatRoomMembers.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomMembers.value, device="deviceA")
        removed_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM.value, "onRemovedFromChatRoom"},
        )
        removed_data = _event_data(removed_evt)
        assert removed_data.get("roomId") == room_id, f"成员被移除回调 roomId 不匹配: {removed_evt}"
        assert removed_data.get("participant") == user_b, f"成员被移除回调 participant 不匹配: {removed_evt}"
        assert removed_data.get("reason"), f"成员被移除回调 reason 不能为空: {removed_evt}"

        _join_chatroom_as_b(device_b, assert_api, room_id)
        destroy_resp = device_a.call("ChatRoomManager", Cmd.destroyChatRoom.value, info={"roomId": room_id})
        _assert_success_envelope(assert_api, destroy_resp, cmd=Cmd.destroyChatRoom.value, device="deviceA")
        destroyed_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_CHAT_ROOM_DESTROYED.value, "onChatRoomDestroyed"},
        )
        destroyed_data = _event_data(destroyed_evt)
        assert destroyed_data.get("roomId") == room_id, f"聊天室销毁回调 roomId 不匹配: {destroyed_evt}"
        assert destroyed_data.get("roomName") in ("", room_name), f"聊天室销毁回调 roomName 不匹配: {destroyed_evt}"
    finally:
        safe_delete_chatroom(room_id)
