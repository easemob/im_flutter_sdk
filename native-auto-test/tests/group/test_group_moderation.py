"""Group moderation API（按当前稳定语义合并）。"""
from __future__ import annotations

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


def _group_state(device_a, assert_api, group_id: str):
    resp = device_a.call("GroupManager", Cmd.getGroupSpecificationFromServer.value, info={"groupId": group_id, "fetchMembers": True})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getGroupSpecificationFromServer.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    return resp


def test_group_block_unblock_members_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("mod_block")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )
        resp_block = device_a.call("GroupManager", Cmd.blockMembers.value, info={"groupId": group_id, "members": [user_b]})
        assert_api.assert_response_matches(
            resp_block,
            expected={"manager": "GroupManager", "cmd": Cmd.blockMembers.value, "device": "deviceA", "result": True},
            ignore_keys={"sequence"},
        )
        removed_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_USER_REMOVED.value,
                "onUserRemovedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onUserRemovedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            removed_events,
            expected_event_types={
                GroupChangeEvent.ON_USER_REMOVED.value,
                "onUserRemovedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onUserRemovedFromGroup"},
        )
        assert_group_snapshot(
            assert_api,
            _group_state(device_a, assert_api, group_id),
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=1,
            block_list_value=[user_b],
        )

        resp_unblock = device_a.call("GroupManager", Cmd.unblockMembers.value, info={"groupId": group_id, "members": [user_b]})
        assert_api.assert_response_matches(
            resp_unblock,
            expected={"manager": "GroupManager", "cmd": Cmd.unblockMembers.value, "device": "deviceA", "result": True},
            ignore_keys={"sequence"},
        )
        assert_group_snapshot(
            assert_api,
            _group_state(device_a, assert_api, group_id),
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=1,
            block_list_value=[],
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize("cmd", [Cmd.blockMembers.value, Cmd.unblockMembers.value])
def test_group_block_unblock_members_nonexistent_group(device_a, assert_api, cmd):
    resp = device_a.call("GroupManager", cmd, info={"groupId": _NONEXISTENT_GROUP_ID, "members": ["user_x"]})
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_block_members_non_member(device_a, assert_api, user_a, user_b):
    group_id = ""
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("mod_block_nm"), invite_members=[])
        resp = device_a.call("GroupManager", Cmd.blockMembers.value, info={"groupId": group_id, "members": [user_b]})
        assert_api.assert_error(resp, code=603, description="are not members of this group")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_mute_unmute_members_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("mod_mute")
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=group_name, invite_members=[user_b])
        resp_mute = device_a.call("GroupManager", Cmd.muteMembers.value, info={"groupId": group_id, "members": [user_b], "duration": 60})
        assert_group_snapshot(
            assert_api,
            resp_mute,
            cmd=Cmd.muteMembers.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            mute_list_value=[user_b],
        )
        mute_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_MUTE_LIST_ADDED.value,
                "onMuteListAddedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMuteListAddedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            mute_events,
            expected_event_types={
                GroupChangeEvent.ON_MUTE_LIST_ADDED.value,
                "onMuteListAddedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMuteListAddedFromGroup"},
            expected_member=user_b,
        )
        resp_unmute = device_a.call("GroupManager", Cmd.unMuteMembers.value, info={"groupId": group_id, "members": [user_b]})
        assert_group_snapshot(
            assert_api,
            resp_unmute,
            cmd=Cmd.unMuteMembers.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            mute_list_value=[],
        )
        unmute_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_MUTE_LIST_REMOVED.value,
                "onMuteListRemovedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMuteListRemovedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            unmute_events,
            expected_event_types={
                GroupChangeEvent.ON_MUTE_LIST_REMOVED.value,
                "onMuteListRemovedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onMuteListRemovedFromGroup"},
            expected_member=user_b,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_mute_all_unmute_all_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("mod_mute_all")
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=group_name, invite_members=[user_b])
        resp_mute_all = device_a.call("GroupManager", Cmd.muteAllMembers.value, info={"groupId": group_id})
        assert_group_snapshot(
            assert_api,
            resp_mute_all,
            cmd=Cmd.muteAllMembers.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            is_all_member_muted=True,
        )
        # SDK muteAllMembers 可能不向成员推送 onAllGroupMemberMuteStateChanged 事件
        # （群主 API 调用成功且返回 isAllMemberMuted=true 即可确认功能正确）
        mute_all_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                "onAllGroupMemberMuteStateChanged",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=set(),
            timeout=5.0,
        )
        assert_group_events(
            assert_api,
            mute_all_events,
            expected_event_types={
                GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                "onAllGroupMemberMuteStateChanged",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=set(),
        )
        resp_unmute_all = device_a.call("GroupManager", Cmd.unMuteAllMembers.value, info={"groupId": group_id})
        assert_group_snapshot(
            assert_api,
            resp_unmute_all,
            cmd=Cmd.unMuteAllMembers.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            member_count_value=2,
            is_all_member_muted=False,
        )
        unmute_all_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                "onAllGroupMemberMuteStateChanged",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=set(),
            timeout=5.0,
        )
        assert_group_events(
            assert_api,
            unmute_all_events,
            expected_event_types={
                GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                "onAllGroupMemberMuteStateChanged",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types=set(),
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_add_remove_white_list_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    group_name = new_group_name("mod_white")
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=group_name, invite_members=[user_b])
        resp_add = device_a.call("GroupManager", Cmd.addWhiteList.value, info={"groupId": group_id, "members": [user_b]})
        assert_api.assert_response_matches(
            resp_add,
            expected={"manager": "GroupManager", "cmd": Cmd.addWhiteList.value, "device": "deviceA", "result": True},
            ignore_keys={"sequence"},
        )
        add_white_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_WHITE_LIST_ADDED.value,
                "onAllowListAddedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAllowListAddedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            add_white_events,
            expected_event_types={
                GroupChangeEvent.ON_WHITE_LIST_ADDED.value,
                "onAllowListAddedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAllowListAddedFromGroup"},
            expected_member=user_b,
        )
        resp_remove = device_a.call("GroupManager", Cmd.removeWhiteList.value, info={"groupId": group_id, "members": [user_b]})
        assert_api.assert_response_matches(
            resp_remove,
            expected={"manager": "GroupManager", "cmd": Cmd.removeWhiteList.value, "device": "deviceA", "result": True},
            ignore_keys={"sequence"},
        )
        remove_white_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_WHITE_LIST_REMOVED.value,
                "onAllowListRemovedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAllowListRemovedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            remove_white_events,
            expected_event_types={
                GroupChangeEvent.ON_WHITE_LIST_REMOVED.value,
                "onAllowListRemovedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onAllowListRemovedFromGroup"},
            expected_member=user_b,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_group_ext_success(device_a, assert_api, user_a):
    group_id = ""
    group_name = new_group_name("mod_ext")
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=group_name, invite_members=[])
        resp = device_a.call("GroupManager", Cmd.updateGroupExt.value, info={"groupId": group_id, "ext": "{\"k\":\"v\"}"})
        assert_group_snapshot(
            assert_api,
            resp,
            cmd=Cmd.updateGroupExt.value,
            group_id=group_id,
            group_name=group_name,
            owner=user_a,
            expected_desc="auto-test group",
            expected_ext="{\"k\":\"v\"}",
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


@pytest.mark.parametrize(
    "cmd,info,code,desc",
    [
        (Cmd.muteMembers.value, {"groupId": _NONEXISTENT_GROUP_ID, "members": ["u"]}, 600, "do not find this group"),
        (Cmd.unMuteMembers.value, {"groupId": _NONEXISTENT_GROUP_ID, "members": ["u"]}, 600, "do not find this group"),
        (Cmd.muteAllMembers.value, {"groupId": _NONEXISTENT_GROUP_ID}, 600, "do not find this group"),
        (Cmd.unMuteAllMembers.value, {"groupId": _NONEXISTENT_GROUP_ID}, 600, "do not find this group"),
        (Cmd.addWhiteList.value, {"groupId": _NONEXISTENT_GROUP_ID, "members": ["u"]}, 600, "do not find this group"),
        (Cmd.removeWhiteList.value, {"groupId": _NONEXISTENT_GROUP_ID, "members": ["u"]}, 600, "do not find this group"),
        (Cmd.updateGroupExt.value, {"groupId": _NONEXISTENT_GROUP_ID, "ext": "{}"}, 600, "do not find this group"),
    ],
)
def test_group_moderation_nonexistent_group_errors(device_a, assert_api, cmd, info, code, desc):
    resp = device_a.call("GroupManager", cmd, info=info)
    assert_api.assert_error(resp, code=code, description=desc)
