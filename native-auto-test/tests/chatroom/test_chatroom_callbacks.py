"""ChatRoom 回调事件用例。"""
from __future__ import annotations

import uuid

import pytest

from src import Cmd, ChatRoomEvent
from tests.chatroom.chatroom_helpers import (
    _allure_step,
    assert_join_chatroom_response,
    collect_chatroom_events,
    create_chatroom_or_skip,
    safe_delete_chatroom,
)
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


def _join_chatroom_as_b_ready(device_b, assert_api, room_id: str) -> None:
    """加入聊天室并校验响应；加入方不保证收到自己的 member-joined 回调。"""
    _join_chatroom_as_b(device_b, assert_api, room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_admin_added_and_removed_callbacks(topology, assert_api):
    """
    多端拓扑：A 建聊天室并添加/移除 B 为管理员；事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device         # A 主端（建聊天室 + 操作）
    recipients = topology.recipient_devices         # B 主端 + B 副端（收事件）
    owner_user = topology.sender_user               # user_a（owner）
    member_user = topology.recipient_user           # user_b（被设 admin）

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_admin", desc_prefix="cb_admin")
    try:
        with _allure_step(f"B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b_ready(endpoint, assert_api, room_id)

        with _allure_step(f"{sender.device_name} 添加 {member_user} 为聊天室管理员"):
            add_resp = sender.call(
                "ChatRoomManager",
                Cmd.addChatRoomAdmin.value,
                info={"roomId": room_id, "admin": member_user},
            )
        with _allure_step("确认添加管理员请求已提交"):
            _assert_success_envelope(assert_api, add_resp, cmd=Cmd.addChatRoomAdmin.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到管理员添加事件"):
            for endpoint in recipients:
                add_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_ADMIN_ADDED.value, "onRoomAdminAdded"},
                )
                add_data = _event_data(add_evt)
                assert add_data.get("roomId") == room_id, f"管理员添加回调 roomId 不匹配: {add_evt}"
                assert add_data.get("admin") == member_user, f"管理员添加回调 admin 不匹配: {add_evt}"
        with _allure_step(f"{sender.device_name} 移除 {member_user} 的聊天室管理员"):
            remove_resp = sender.call(
                "ChatRoomManager",
                Cmd.removeChatRoomAdmin.value,
                info={"roomId": room_id, "admin": member_user},
            )
        with _allure_step("确认移除管理员请求已提交"):
            _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomAdmin.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到管理员移除事件"):
            for endpoint in recipients:
                remove_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_ADMIN_REMOVED.value, "onRoomAdminRemoved"},
                )
                remove_data = _event_data(remove_evt)
                assert remove_data.get("roomId") == room_id, f"管理员移除回调 roomId 不匹配: {remove_evt}"
                assert remove_data.get("admin") == member_user, f"管理员移除回调 admin 不匹配: {remove_evt}"
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_owner_changed_callback(topology, assert_api):
    """
    多端拓扑：A 将聊天室 owner 转让给 B；owner 变更事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_owner", desc_prefix="cb_owner")
    try:
        with _allure_step("B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b_ready(endpoint, assert_api, room_id)

        with _allure_step(f"{sender.device_name} 转让聊天室 owner 给 {member_user}"):
            change_resp = sender.call(
                "ChatRoomManager",
                Cmd.changeChatRoomOwner.value,
                info={"roomId": room_id, "newOwner": member_user},
            )
        with _allure_step("确认转让请求已提交"):
            _assert_success_envelope(assert_api, change_resp, cmd=Cmd.changeChatRoomOwner.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到 owner 变更事件"):
            for endpoint in recipients:
                evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_OWNER_CHANGED.value, "onRoomOwnerChanged"},
                )
                data = _event_data(evt)
                assert data.get("roomId") == room_id, f"owner 变更回调 roomId 不匹配: {evt}"
                assert data.get("newOwner") == member_user, f"owner 变更回调 newOwner 不匹配: {evt}"
                assert data.get("oldOwner") == owner_user, f"owner 变更回调 oldOwner 不匹配: {evt}"
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_all_member_mute_state_callbacks(topology, assert_api):
    """
    多端拓扑：A 全员禁言/解除；状态事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_mute_all", desc_prefix="cb_mute_all")
    try:
        with _allure_step("B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b(endpoint, assert_api, room_id)
        event_types = {ChatRoomEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value, "onRoomAllMemberMuteStateChanged"}

        with _allure_step(f"{sender.device_name} 全员禁言"):
            mute_resp = sender.call("ChatRoomManager", Cmd.muteAllChatRoomMembers.value, info={"roomId": room_id})
        with _allure_step("确认全员禁言请求已提交"):
            _assert_success_envelope(assert_api, mute_resp, cmd=Cmd.muteAllChatRoomMembers.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到全员禁言事件（状态 true）"):
            for endpoint in recipients:
                mute_evt = _first_chatroom_event(endpoint, room_id=room_id, event_types=event_types)
                mute_data = _event_data(mute_evt)
                assert mute_data.get("roomId") == room_id, f"全员禁言回调 roomId 不匹配: {mute_evt}"
                assert (mute_data.get("isAllMuted") if "isAllMuted" in mute_data else mute_data.get("isMuted")) is True, (
                    f"全员禁言回调状态应为 true: {mute_evt}"
                )
        with _allure_step(f"{sender.device_name} 解除全员禁言"):
            unmute_resp = sender.call("ChatRoomManager", Cmd.unMuteAllChatRoomMembers.value, info={"roomId": room_id})
        with _allure_step("确认解除全员禁言请求已提交"):
            _assert_success_envelope(assert_api, unmute_resp, cmd=Cmd.unMuteAllChatRoomMembers.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到解除全员禁言事件（状态 false）"):
            for endpoint in recipients:
                unmute_evt = _first_chatroom_event(endpoint, room_id=room_id, event_types=event_types)
                unmute_data = _event_data(unmute_evt)
                assert unmute_data.get("roomId") == room_id, f"解除全员禁言回调 roomId 不匹配: {unmute_evt}"
                assert (unmute_data.get("isAllMuted") if "isAllMuted" in unmute_data else unmute_data.get("isMuted")) is False, (
                    f"解除全员禁言回调状态应为 false: {unmute_evt}"
                )
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_attributes_updated_and_removed_callbacks(topology, assert_api):
    """
    多端拓扑：A 设置/删除聊天室属性；属性事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_attrs", desc_prefix="cb_attrs")
    attr_key = f"cb_attr_{uuid.uuid4().hex[:8]}"
    attr_value = f"value-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b(endpoint, assert_api, room_id)

        with _allure_step(f"{sender.device_name} 设置聊天室属性 {attr_key}"):
            set_resp = sender.call(
                "ChatRoomManager",
                Cmd.setChatRoomAttributes.value,
                info={
                    "roomId": room_id,
                    "attributes": {attr_key: attr_value},
                    "autoDelete": False,
                    "forced": True,
                },
            )
        with _allure_step("确认设置属性请求已提交"):
            _assert_success_envelope(assert_api, set_resp, cmd=Cmd.setChatRoomAttributes.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到属性更新事件"):
            for endpoint in recipients:
                updated_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_ATTRIBUTES_UPDATED.value, "onAttributesUpdated"},
                )
                updated_data = _event_data(updated_evt)
                assert updated_data.get("roomId") == room_id, f"属性更新回调 roomId 不匹配: {updated_evt}"
                assert updated_data.get("attributes", {}).get(attr_key) == attr_value, f"属性更新回调值不匹配: {updated_evt}"
                assert updated_data.get("from") == owner_user or updated_data.get("fromId") == owner_user, (
                    f"属性更新回调 from/fromId 不匹配: {updated_evt}"
                )
        with _allure_step(f"{sender.device_name} 删除聊天室属性 {attr_key}"):
            remove_resp = sender.call(
                "ChatRoomManager",
                Cmd.removeChatRoomAttributes.value,
                info={"roomId": room_id, "keys": [attr_key], "forced": True},
            )
        with _allure_step("确认删除属性请求已提交"):
            _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomAttributes.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到属性删除事件"):
            for endpoint in recipients:
                removed_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_ATTRIBUTES_REMOVED.value, "onRoomAttributesDidRemoved"},
                )
                removed_data = _event_data(removed_evt)
                removed_keys = removed_data.get("removedKeys") or removed_data.get("keys")
                assert removed_data.get("roomId") == room_id, f"属性删除回调 roomId 不匹配: {removed_evt}"
                assert isinstance(removed_keys, list), f"属性删除回调 removedKeys/keys 应为 list: {removed_evt}"
                assert attr_key in removed_keys, f"属性删除回调缺少删除 key: {removed_evt}"
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_announcement_changed_callback(topology, assert_api):
    """
    多端拓扑：A 更新聊天室公告；公告事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_announcement", desc_prefix="cb_announcement")
    announcement = f"notice-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b_ready(endpoint, assert_api, room_id)

        with _allure_step(f"{sender.device_name} 更新聊天室公告"):
            update_resp = sender.call(
                "ChatRoomManager",
                Cmd.updateChatRoomAnnouncement.value,
                info={"roomId": room_id, "announcement": announcement},
            )
        with _allure_step("确认更新公告请求已提交"):
            _assert_success_envelope(assert_api, update_resp, cmd=Cmd.updateChatRoomAnnouncement.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到公告变更事件"):
            for endpoint in recipients:
                evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_ANNOUNCEMENT_CHANGED.value, "onRoomAnnouncementChanged"},
                )
                data = _event_data(evt)
                assert data.get("roomId") == room_id, f"公告变更回调 roomId 不匹配: {evt}"
                assert data.get("announcement") == announcement, f"公告变更回调 announcement 不匹配: {evt}"
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_specification_changed_callback(topology, assert_api):
    """
    多端拓扑：A 修改聊天室 subject；规格变更事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_spec", desc_prefix="cb_spec")
    subject = f"spec-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b(endpoint, assert_api, room_id)

        with _allure_step(f"{sender.device_name} 修改聊天室 subject"):
            change_resp = sender.call(
                "ChatRoomManager",
                Cmd.changeChatRoomSubject.value,
                info={"roomId": room_id, "subject": subject},
            )
        with _allure_step("确认修改 subject 请求已提交"):
            _assert_success_envelope(assert_api, change_resp, cmd=Cmd.changeChatRoomSubject.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到规格变更事件"):
            for endpoint in recipients:
                evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_SPECIFICATION_CHANGED.value, "onRoomSpecificationChanged"},
                )
                data = _event_data(evt)
                room = data.get("room")
                assert isinstance(room, dict), f"规格变更回调 room 应为 dict: {evt}"
                assert room.get("roomId") == room_id, f"规格变更回调 roomId 不匹配: {evt}"
                assert room.get("name") == subject, f"规格变更回调 name 不匹配: {evt}"
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_allow_list_added_and_removed_callbacks(topology, assert_api):
    """
    多端拓扑：A 添加/移除 B 到白名单；白名单事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_allow", desc_prefix="cb_allow")
    try:
        with _allure_step("B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b(endpoint, assert_api, room_id)

        with _allure_step(f"{sender.device_name} 添加 {member_user} 到白名单"):
            add_resp = sender.call(
                "ChatRoomManager",
                Cmd.addMembersToChatRoomWhiteList.value,
                info={"roomId": room_id, "members": [member_user]},
            )
        with _allure_step("确认添加白名单请求已提交"):
            _assert_success_envelope(assert_api, add_resp, cmd=Cmd.addMembersToChatRoomWhiteList.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到白名单添加事件"):
            for endpoint in recipients:
                add_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_WHITE_LIST_ADDED.value, "onRoomWhiteListAdded"},
                )
                add_data = _event_data(add_evt)
                assert add_data.get("roomId") == room_id, f"白名单添加回调 roomId 不匹配: {add_evt}"
                assert member_user in _members_from_allow_list_event(add_data), f"白名单添加回调成员列表缺少 B: {add_evt}"
        with _allure_step(f"{sender.device_name} 从白名单移除 {member_user}"):
            remove_resp = sender.call(
                "ChatRoomManager",
                Cmd.removeMembersFromChatRoomWhiteList.value,
                info={"roomId": room_id, "members": [member_user]},
            )
        with _allure_step("确认移除白名单请求已提交"):
            _assert_success_envelope(
                assert_api,
                remove_resp,
                cmd=Cmd.removeMembersFromChatRoomWhiteList.value,
                device=sender.device_name,
            )
        with _allure_step("B 全部在线端收到白名单移除事件"):
            for endpoint in recipients:
                remove_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_WHITE_LIST_REMOVED.value, "onRoomWhiteListRemoved"},
                )
                remove_data = _event_data(remove_evt)
                assert remove_data.get("roomId") == room_id, f"白名单移除回调 roomId 不匹配: {remove_evt}"
                assert member_user in _members_from_allow_list_event(remove_data), f"白名单移除回调成员列表缺少 B: {remove_evt}"
    finally:
        safe_delete_chatroom(room_id)


@pytest.mark.topology("account_a_to_account_b")
def test_chatroom_mute_list_added_and_removed_callbacks(topology, assert_api):
    """
    多端拓扑：A 禁言/解除禁言 B；禁言事件同步到 B 全部在线端。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    room_id, _ = create_chatroom_or_skip(owner=owner_user, name_prefix="cb_mute", desc_prefix="cb_mute")
    try:
        with _allure_step("B 全部在线端加入聊天室"):
            for endpoint in recipients:
                _join_chatroom_as_b(endpoint, assert_api, room_id)

        with _allure_step(f"{sender.device_name} 禁言 {member_user}"):
            mute_resp = sender.call(
                "ChatRoomManager",
                Cmd.muteChatRoomMembers.value,
                info={"roomId": room_id, "muteMembers": [member_user], "duration": 60000},
            )
        with _allure_step("确认禁言请求已提交"):
            _assert_success_envelope(assert_api, mute_resp, cmd=Cmd.muteChatRoomMembers.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到禁言添加事件"):
            for endpoint in recipients:
                mute_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_MUTE_LIST_ADDED.value, "onRoomMuteListAdded"},
                )
                mute_data = _event_data(mute_evt)
                mutes = mute_data.get("mutes")
                assert mute_data.get("roomId") == room_id, f"禁言添加回调 roomId 不匹配: {mute_evt}"
                assert (isinstance(mutes, dict) and member_user in mutes) or (isinstance(mutes, list) and member_user in mutes), (
                    f"禁言添加回调 mutes 缺少 B: {mute_evt}"
                )
        with _allure_step(f"{sender.device_name} 解除 {member_user} 禁言"):
            unmute_resp = sender.call(
                "ChatRoomManager",
                Cmd.unMuteChatRoomMembers.value,
                info={"roomId": room_id, "unMuteMembers": [member_user]},
            )
        with _allure_step("确认解除禁言请求已提交"):
            _assert_success_envelope(assert_api, unmute_resp, cmd=Cmd.unMuteChatRoomMembers.value, device=sender.device_name)
        with _allure_step("B 全部在线端收到禁言移除事件"):
            for endpoint in recipients:
                unmute_evt = _first_chatroom_event(
                    endpoint,
                    room_id=room_id,
                    event_types={ChatRoomEvent.ON_MUTE_LIST_REMOVED.value, "onRoomMuteListRemoved"},
                )
                unmute_data = _event_data(unmute_evt)
                unmute_mutes = unmute_data.get("mutes")
                assert unmute_data.get("roomId") == room_id, f"禁言移除回调 roomId 不匹配: {unmute_evt}"
                assert isinstance(unmute_mutes, list), f"禁言移除回调 mutes 应为 list: {unmute_evt}"
                assert member_user in unmute_mutes, f"禁言移除回调 mutes 缺少 B: {unmute_evt}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_member_exited_callback(device_a, device_b, assert_api, user_a, user_b):
    """leaveChatRoom 触发成员主动退出回调，校验 roomId/participant。"""
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="cb_exit", desc_prefix="cb_exit")
    try:
        join_resp_a = device_a.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
        assert_join_chatroom_response(
            assert_api,
            join_resp_a,
            device="deviceA",
            room_id=room_id,
            is_in_whitelist=True,
        )
        _join_chatroom_as_b_ready(device_b, assert_api, room_id)

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
            event_types={ChatRoomEvent.ON_MEMBER_EXITED.value, "onRoomMemberExited"},
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
        _join_chatroom_as_b_ready(device_b, assert_api, room_id)

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeChatRoomMembers.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomMembers.value, device="deviceA")
        removed_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_REMOVED_FROM_CHAT_ROOM.value, "onRoomRemoved"},
        )
        removed_data = _event_data(removed_evt)
        assert removed_data.get("roomId") == room_id, f"成员被移除回调 roomId 不匹配: {removed_evt}"
        assert removed_data.get("participant") == user_b, f"成员被移除回调 participant 不匹配: {removed_evt}"
        # 原生 reason 为 int（0 是合法移除原因枚举值）—— 只断存在，不断言 truthy
        assert "reason" in removed_data, f"成员被移除回调缺少 reason 字段: {removed_evt}"

        _join_chatroom_as_b_ready(device_b, assert_api, room_id)
        # 5.0 客户端 destroyChatRoom 移除 → REST 服务端销毁（客户端仍应收到 onRoomDestroyed 事件）
        safe_delete_chatroom(room_id)
        destroyed_evt = _first_chatroom_event(
            device_b,
            room_id=room_id,
            event_types={ChatRoomEvent.ON_CHAT_ROOM_DESTROYED.value, "onRoomDestroyed"},
        )
        destroyed_data = _event_data(destroyed_evt)
        assert destroyed_data.get("roomId") == room_id, f"聊天室销毁回调 roomId 不匹配: {destroyed_evt}"
        assert destroyed_data.get("roomName") in ("", room_name), f"聊天室销毁回调 roomName 不匹配: {destroyed_evt}"
    finally:
        safe_delete_chatroom(room_id)
