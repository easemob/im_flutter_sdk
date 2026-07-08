from __future__ import annotations

import uuid

import pytest

from src import Cmd, ne
from tests.chatroom.chatroom_helpers import assert_join_chatroom_response, create_chatroom_or_skip, safe_delete_chatroom


pytestmark = [pytest.mark.client, pytest.mark.chatroom, pytest.mark.agorachat4_23_0]


def _assert_success_envelope(assert_api, resp: dict, *, cmd: str, device: str) -> None:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": cmd,
            "device": device,
            "result": ne("__missing__"),
        },
        ignore_keys={"sequence"},
    )


def test_chatroom_update_and_fetch_announcement_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="announcement", desc_prefix="announcement")
    announcement = f"notice-{uuid.uuid4().hex[:8]}"
    try:
        update_resp = device_a.call(
            "ChatRoomManager",
            Cmd.updateChatRoomAnnouncement.value,
            info={"roomId": room_id, "announcement": announcement},
        )
        _assert_success_envelope(
            assert_api,
            update_resp,
            cmd=Cmd.updateChatRoomAnnouncement.value,
            device="deviceA",
        )

        fetch_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomAnnouncement.value,
            info={"roomId": room_id},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomAnnouncement.value,
                "device": "deviceA",
                "result": announcement,
            },
            ignore_keys={"sequence"},
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_add_fetch_remove_white_list_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="whitelist", desc_prefix="whitelist")
    try:
        join_resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
        assert_join_chatroom_response(assert_api, join_resp, device="deviceB", room_id=room_id)

        add_resp = device_a.call(
            "ChatRoomManager",
            Cmd.addMembersToChatRoomWhiteList.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(
            assert_api,
            add_resp,
            cmd=Cmd.addMembersToChatRoomWhiteList.value,
            device="deviceA",
        )

        fetch_after_add = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomWhiteListFromServer.value,
            info={"roomId": room_id},
        )
        assert_api.assert_response_matches(
            fetch_after_add,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomWhiteListFromServer.value,
                "device": "deviceA",
                "result": ne(None),
            },
            ignore_keys={"sequence"},
        )
        white_list = fetch_after_add.get("result")
        assert isinstance(white_list, list), f"fetchChatRoomWhiteListFromServer result 应为 list: {fetch_after_add}"
        assert user_b in white_list, f"白名单缺少已添加成员: user_b={user_b}, white_list={white_list}"

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

        fetch_after_remove = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomWhiteListFromServer.value,
            info={"roomId": room_id},
        )
        assert_api.assert_response_matches(
            fetch_after_remove,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomWhiteListFromServer.value,
                "device": "deviceA",
                "result": ne(None),
            },
            ignore_keys={"sequence"},
        )
        white_list_after_remove = fetch_after_remove.get("result")
        assert isinstance(white_list_after_remove, list), (
            f"fetchChatRoomWhiteListFromServer result 应为 list: {fetch_after_remove}"
        )
        assert user_b not in white_list_after_remove, (
            f"白名单移除后仍包含成员: user_b={user_b}, white_list={white_list_after_remove}"
        )
    finally:
        safe_delete_chatroom(room_id)


def _join_chatroom_as_b(device_b, assert_api, room_id: str) -> None:
    join_resp = device_b.call("ChatRoomManager", Cmd.joinChatRoom.value, info={"roomId": room_id})
    assert_join_chatroom_response(assert_api, join_resp, device="deviceB", room_id=room_id)


def _assert_list_response(assert_api, resp: dict, *, cmd: str, device: str) -> list:
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatRoomManager",
            "cmd": cmd,
            "device": device,
            "result": ne(None),
        },
        ignore_keys={"sequence"},
    )
    result = resp.get("result")
    assert isinstance(result, list), f"{cmd} result 应为 list: {resp}"
    return result


def test_chatroom_mute_fetch_unmute_member_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="mute", desc_prefix="mute")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        mute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.muteChatRoomMembers.value,
            info={"roomId": room_id, "muteMembers": [user_b], "duration": 60000},
        )
        _assert_success_envelope(assert_api, mute_resp, cmd=Cmd.muteChatRoomMembers.value, device="deviceA")

        mute_list_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomMuteList.value,
            info={"roomId": room_id, "pageNum": 1, "pageSize": 20},
        )
        mute_list = _assert_list_response(
            assert_api,
            mute_list_resp,
            cmd=Cmd.fetchChatRoomMuteList.value,
            device="deviceA",
        )
        assert user_b in mute_list, f"禁言列表缺少被禁言成员: user_b={user_b}, mute_list={mute_list}"

        unmute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.unMuteChatRoomMembers.value,
            info={"roomId": room_id, "unMuteMembers": [user_b]},
        )
        _assert_success_envelope(assert_api, unmute_resp, cmd=Cmd.unMuteChatRoomMembers.value, device="deviceA")

        mute_list_after_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomMuteList.value,
            info={"roomId": room_id, "pageNum": 1, "pageSize": 20},
        )
        mute_list_after = _assert_list_response(
            assert_api,
            mute_list_after_resp,
            cmd=Cmd.fetchChatRoomMuteList.value,
            device="deviceA",
        )
        assert user_b not in mute_list_after, f"解除禁言后列表仍包含成员: user_b={user_b}, mute_list={mute_list_after}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_block_fetch_unblock_member_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="block", desc_prefix="block")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        block_resp = device_a.call(
            "ChatRoomManager",
            Cmd.blockChatRoomMembers.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(assert_api, block_resp, cmd=Cmd.blockChatRoomMembers.value, device="deviceA")

        block_list_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomBlockList.value,
            info={"roomId": room_id, "pageNum": 1, "pageSize": 20},
        )
        block_list = _assert_list_response(
            assert_api,
            block_list_resp,
            cmd=Cmd.fetchChatRoomBlockList.value,
            device="deviceA",
        )
        assert user_b in block_list, f"黑名单缺少被加入成员: user_b={user_b}, block_list={block_list}"

        unblock_resp = device_a.call(
            "ChatRoomManager",
            Cmd.unBlockChatRoomMembers.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(assert_api, unblock_resp, cmd=Cmd.unBlockChatRoomMembers.value, device="deviceA")

        block_list_after_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomBlockList.value,
            info={"roomId": room_id, "pageNum": 1, "pageSize": 20},
        )
        block_list_after = _assert_list_response(
            assert_api,
            block_list_after_resp,
            cmd=Cmd.fetchChatRoomBlockList.value,
            device="deviceA",
        )
        assert user_b not in block_list_after, f"解除黑名单后列表仍包含成员: user_b={user_b}, block_list={block_list_after}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_change_subject_and_description_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="profile", desc_prefix="profile")
    new_subject = f"room-subject-{uuid.uuid4().hex[:8]}"
    new_description = f"room-description-{uuid.uuid4().hex[:8]}"
    try:
        subject_resp = device_a.call(
            "ChatRoomManager",
            Cmd.changeChatRoomSubject.value,
            info={"roomId": room_id, "subject": new_subject},
        )
        _assert_success_envelope(assert_api, subject_resp, cmd=Cmd.changeChatRoomSubject.value, device="deviceA")

        description_resp = device_a.call(
            "ChatRoomManager",
            Cmd.changeChatRoomDescription.value,
            info={"roomId": room_id, "description": new_description},
        )
        _assert_success_envelope(
            assert_api,
            description_resp,
            cmd=Cmd.changeChatRoomDescription.value,
            device="deviceA",
        )

        fetch_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomInfoFromServer.value,
            info={"roomId": room_id},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomInfoFromServer.value,
                "device": "deviceA",
                "result": {
                    "roomId": room_id,
                    "name": new_subject,
                    "desc": new_description,
                },
            },
            ignore_keys={
                "sequence",
                "owner",
                "maxUsers",
                "permissionType",
                "isAllMemberMuted",
                "adminList",
                "memberCount",
                "muteList",
                "muteExpireTimestamp",
                "createTimestamp",
                "memberList",
                "isInWhitelist",
                "blockList",
                "announcement",
            },
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_add_and_remove_admin_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="admin", desc_prefix="admin")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        add_resp = device_a.call(
            "ChatRoomManager",
            Cmd.addChatRoomAdmin.value,
            info={"roomId": room_id, "admin": user_b},
        )
        _assert_success_envelope(assert_api, add_resp, cmd=Cmd.addChatRoomAdmin.value, device="deviceA")

        fetch_after_add = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomInfoFromServer.value,
            info={"roomId": room_id},
        )
        admin_list = (fetch_after_add.get("result") or {}).get("adminList")
        assert isinstance(admin_list, list), f"adminList 应为 list: {fetch_after_add}"
        assert user_b in admin_list, f"添加管理员后 adminList 缺少成员: user_b={user_b}, adminList={admin_list}"

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeChatRoomAdmin.value,
            info={"roomId": room_id, "admin": user_b},
        )
        _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomAdmin.value, device="deviceA")

        fetch_after_remove = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomInfoFromServer.value,
            info={"roomId": room_id},
        )
        admin_list_after = (fetch_after_remove.get("result") or {}).get("adminList")
        assert isinstance(admin_list_after, list), f"adminList 应为 list: {fetch_after_remove}"
        assert user_b not in admin_list_after, (
            f"移除管理员后 adminList 仍包含成员: user_b={user_b}, adminList={admin_list_after}"
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_remove_member_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="kick", desc_prefix="kick")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeChatRoomMembers.value,
            info={"roomId": room_id, "members": [user_b]},
        )
        _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomMembers.value, device="deviceA")

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
                    "cursor": ne(None),
                    "list": ne(None),
                },
            },
            ignore_keys={"sequence"},
        )
        members = (members_resp.get("result") or {}).get("list")
        assert isinstance(members, list), f"fetchChatRoomMembers result.list 应为 list: {members_resp}"
        assert user_b not in members, f"踢出成员后成员列表仍包含该成员: user_b={user_b}, members={members}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_mute_and_unmute_all_members_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="mute_all", desc_prefix="mute_all")
    try:
        mute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.muteAllChatRoomMembers.value,
            info={"roomId": room_id},
        )
        _assert_success_envelope(assert_api, mute_resp, cmd=Cmd.muteAllChatRoomMembers.value, device="deviceA")

        fetch_after_mute = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomInfoFromServer.value,
            info={"roomId": room_id},
        )
        assert (fetch_after_mute.get("result") or {}).get("isAllMemberMuted") is True, (
            f"全员禁言后 isAllMemberMuted 未变为 true: {fetch_after_mute}"
        )

        unmute_resp = device_a.call(
            "ChatRoomManager",
            Cmd.unMuteAllChatRoomMembers.value,
            info={"roomId": room_id},
        )
        _assert_success_envelope(assert_api, unmute_resp, cmd=Cmd.unMuteAllChatRoomMembers.value, device="deviceA")

        fetch_after_unmute = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomInfoFromServer.value,
            info={"roomId": room_id},
        )
        assert (fetch_after_unmute.get("result") or {}).get("isAllMemberMuted") is False, (
            f"解除全员禁言后 isAllMemberMuted 未变为 false: {fetch_after_unmute}"
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_set_and_fetch_attributes_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="attrs", desc_prefix="attrs")
    attr_key = f"room_attr_{uuid.uuid4().hex[:8]}"
    attr_value = f"value-{uuid.uuid4().hex[:8]}"
    try:
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
        failures = set_resp.get("result")
        assert isinstance(failures, dict), f"setChatRoomAttributes result 应为失败 key map: {set_resp}"
        assert attr_key not in failures, f"设置聊天室属性失败: key={attr_key}, failures={failures}"

        fetch_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomAttributes.value,
            info={"roomId": room_id, "keys": [attr_key]},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomAttributes.value,
                "device": "deviceA",
                "result": {
                    attr_key: attr_value,
                },
            },
            ignore_keys={"sequence"},
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_fetch_all_attributes_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="attrs_all", desc_prefix="attrs_all")
    attr_key_1 = f"room_attr_all_1_{uuid.uuid4().hex[:8]}"
    attr_key_2 = f"room_attr_all_2_{uuid.uuid4().hex[:8]}"
    attributes = {
        attr_key_1: f"value-1-{uuid.uuid4().hex[:8]}",
        attr_key_2: f"value-2-{uuid.uuid4().hex[:8]}",
    }
    try:
        set_resp = device_a.call(
            "ChatRoomManager",
            Cmd.setChatRoomAttributes.value,
            info={
                "roomId": room_id,
                "attributes": attributes,
                "autoDelete": False,
                "forced": True,
            },
        )
        _assert_success_envelope(assert_api, set_resp, cmd=Cmd.setChatRoomAttributes.value, device="deviceA")
        failures = set_resp.get("result")
        assert isinstance(failures, dict), f"setChatRoomAttributes result 应为失败 key map: {set_resp}"
        assert not set(attributes).intersection(failures), f"设置聊天室属性失败: failures={failures}"

        fetch_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomAttributes.value,
            info={"roomId": room_id},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomAttributes.value,
                "device": "deviceA",
                "result": attributes,
            },
            ignore_keys={"sequence"},
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_fetch_attributes_by_partial_keys_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="attrs_partial", desc_prefix="attrs_partial")
    attr_key_1 = f"room_attr_partial_1_{uuid.uuid4().hex[:8]}"
    attr_key_2 = f"room_attr_partial_2_{uuid.uuid4().hex[:8]}"
    attributes = {
        attr_key_1: f"value-1-{uuid.uuid4().hex[:8]}",
        attr_key_2: f"value-2-{uuid.uuid4().hex[:8]}",
    }
    try:
        set_resp = device_a.call(
            "ChatRoomManager",
            Cmd.setChatRoomAttributes.value,
            info={
                "roomId": room_id,
                "attributes": attributes,
                "autoDelete": False,
                "forced": True,
            },
        )
        _assert_success_envelope(assert_api, set_resp, cmd=Cmd.setChatRoomAttributes.value, device="deviceA")
        failures = set_resp.get("result")
        assert isinstance(failures, dict), f"setChatRoomAttributes result 应为失败 key map: {set_resp}"
        assert not set(attributes).intersection(failures), f"设置聊天室属性失败: failures={failures}"

        fetch_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomAttributes.value,
            info={"roomId": room_id, "keys": [attr_key_1]},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomAttributes.value,
                "device": "deviceA",
                "result": {
                    attr_key_1: attributes[attr_key_1],
                },
            },
            ignore_keys={"sequence"},
        )
        fetched = fetch_resp.get("result")
        assert attr_key_2 not in fetched, f"按部分 key 拉取时返回了未请求的 key: fetched={fetched}"
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_update_attribute_overwrites_previous_value(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="attrs_update", desc_prefix="attrs_update")
    attr_key = f"room_attr_update_{uuid.uuid4().hex[:8]}"
    old_value = f"old-{uuid.uuid4().hex[:8]}"
    new_value = f"new-{uuid.uuid4().hex[:8]}"
    try:
        first_set_resp = device_a.call(
            "ChatRoomManager",
            Cmd.setChatRoomAttributes.value,
            info={
                "roomId": room_id,
                "attributes": {attr_key: old_value},
                "autoDelete": False,
                "forced": True,
            },
        )
        _assert_success_envelope(assert_api, first_set_resp, cmd=Cmd.setChatRoomAttributes.value, device="deviceA")

        second_set_resp = device_a.call(
            "ChatRoomManager",
            Cmd.setChatRoomAttributes.value,
            info={
                "roomId": room_id,
                "attributes": {attr_key: new_value},
                "autoDelete": False,
                "forced": True,
            },
        )
        _assert_success_envelope(assert_api, second_set_resp, cmd=Cmd.setChatRoomAttributes.value, device="deviceA")
        failures = second_set_resp.get("result")
        assert isinstance(failures, dict), f"setChatRoomAttributes result 应为失败 key map: {second_set_resp}"
        assert attr_key not in failures, f"覆盖更新聊天室属性失败: key={attr_key}, failures={failures}"

        fetch_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomAttributes.value,
            info={"roomId": room_id, "keys": [attr_key]},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomAttributes.value,
                "device": "deviceA",
                "result": {
                    attr_key: new_value,
                },
            },
            ignore_keys={"sequence"},
        )
        assert (fetch_resp.get("result") or {}).get(attr_key) != old_value, (
            f"聊天室属性覆盖更新后仍返回旧值: old={old_value}, resp={fetch_resp}"
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_change_owner_success(device_a, device_b, assert_api, user_a, user_b):
    room_id, room_name = create_chatroom_or_skip(owner=user_a, name_prefix="owner", desc_prefix="owner")
    try:
        _join_chatroom_as_b(device_b, assert_api, room_id)

        change_resp = device_a.call(
            "ChatRoomManager",
            Cmd.changeChatRoomOwner.value,
            info={"roomId": room_id, "newOwner": user_b},
        )
        assert_api.assert_response_matches(
            change_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.changeChatRoomOwner.value,
                "device": "deviceA",
                "result": {
                    "owner": user_b,
                    "maxUsers": 200,
                    "permissionType": 0,
                    "isAllMemberMuted": False,
                    "adminList": [],
                    "memberCount": 2,
                    "muteList": [],
                    "muteExpireTimestamp": -1,
                    "roomId": room_id,
                    "createTimestamp": 0,
                    "memberList": [user_a],
                    "isInWhitelist": False,
                    "blockList": [],
                    "name": room_name,
                    "desc": "nothing left here",
                    "announcement": "",
                },
            },
            ignore_keys={"sequence"},
        )
    finally:
        safe_delete_chatroom(room_id)


def test_chatroom_remove_attributes_success(device_a, assert_api, user_a):
    room_id, _ = create_chatroom_or_skip(owner=user_a, name_prefix="remove_attrs", desc_prefix="remove_attrs")
    attr_key = f"room_attr_remove_{uuid.uuid4().hex[:8]}"
    attr_value = f"value-{uuid.uuid4().hex[:8]}"
    try:
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

        remove_resp = device_a.call(
            "ChatRoomManager",
            Cmd.removeChatRoomAttributes.value,
            info={"roomId": room_id, "keys": [attr_key], "forced": True},
        )
        _assert_success_envelope(assert_api, remove_resp, cmd=Cmd.removeChatRoomAttributes.value, device="deviceA")
        failures = remove_resp.get("result")
        assert isinstance(failures, dict), f"removeChatRoomAttributes result 应为失败 key map: {remove_resp}"
        assert attr_key not in failures, f"删除聊天室属性失败: key={attr_key}, failures={failures}"

        fetch_resp = device_a.call(
            "ChatRoomManager",
            Cmd.fetchChatRoomAttributes.value,
            info={"roomId": room_id, "keys": [attr_key]},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "ChatRoomManager",
                "cmd": Cmd.fetchChatRoomAttributes.value,
                "device": "deviceA",
                "result": {},
            },
            ignore_keys={"sequence"},
        )
    finally:
        safe_delete_chatroom(room_id)
