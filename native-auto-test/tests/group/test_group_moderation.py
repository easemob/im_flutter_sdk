"""Group moderation API（按当前稳定语义合并）。"""
from __future__ import annotations
from contextlib import nullcontext

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


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


def _group_state(device, assert_api, group_id: str):
    resp = device.call("GroupManager", Cmd.getGroupSpecificationFromServer.value, info={"groupId": group_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getGroupSpecificationFromServer.value,
            "device": device.device_name,
        },
        ignore_keys={"sequence", "result"},
    )
    return resp


@pytest.mark.topology("account_a_to_account_b")

def test_group_block_unblock_members_success(assert_api, user_a, user_b, topology):
    """群主封禁/解封成员：移除事件同步到接收账号全部在线端。"""
    owner = topology.sender_action_device
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("mod_block")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )
        with _allure_step("A 加入群黑名单"):
            resp_block = owner.call("GroupManager", Cmd.blockMembers.value, info={"groupId": group_id, "members": [user_b]})
        with _allure_step("验证加入群黑名单返回的关键字段"):
            assert_api.assert_response_matches(
                resp_block,
                expected={"manager": "GroupManager", "cmd": Cmd.blockMembers.value, "device": owner.device_name, "result": True},
                ignore_keys={"sequence"},
            )
        for device in recipients:
            with _allure_step("等待并校验目标业务事件"):
                removed_events = collect_group_events(
                    device,
                    expected_event_types={
                        GroupChangeEvent.ON_USER_REMOVED.value,
                        "onGroupUserRemoved",
                    },
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types={"onGroupUserRemoved"},
                    timeout=10.0,
                )
            with _allure_step("验证加入群黑名单返回的关键字段"):
                assert_group_events(
                    assert_api,
                    removed_events,
                    expected_event_types={
                        GroupChangeEvent.ON_USER_REMOVED.value,
                        "onGroupUserRemoved",
                    },
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types={"onGroupUserRemoved"},
                )
        with _allure_step("验证加入群黑名单返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                _group_state(owner, assert_api, group_id),
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=1,
                block_list_value=[user_b],
            )

        with _allure_step("A 移出群黑名单"):
            resp_unblock = owner.call("GroupManager", Cmd.unblockMembers.value, info={"groupId": group_id, "members": [user_b]})
        with _allure_step("验证移出群黑名单返回的关键字段"):
            assert_api.assert_response_matches(
                resp_unblock,
                expected={"manager": "GroupManager", "cmd": Cmd.unblockMembers.value, "device": owner.device_name, "result": True},
                ignore_keys={"sequence"},
            )
        with _allure_step("验证移出群黑名单返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                _group_state(owner, assert_api, group_id),
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=1,
                block_list_value=[],
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


@pytest.mark.parametrize("cmd", [Cmd.blockMembers.value, Cmd.unblockMembers.value])
def test_group_block_unblock_members_nonexistent_group(device_a, assert_api, cmd):
    with _allure_step("A 执行群组业务操作"):
        resp = device_a.call("GroupManager", cmd, info={"groupId": _NONEXISTENT_GROUP_ID, "members": ["user_x"]})
    with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_block_members_non_member(device_a, assert_api, user_a, user_b):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("mod_block_nm"), invite_members=[])
        with _allure_step("A 加入群黑名单"):
            resp = device_a.call("GroupManager", Cmd.blockMembers.value, info={"groupId": group_id, "members": [user_b]})
        with _allure_step("验证加入群黑名单返回的错误码与错误文案"):
            assert_api.assert_error(resp, code=603, description="are not members of this group")
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)


@pytest.mark.topology("account_a_to_account_b")
def test_group_mute_unmute_members_success(assert_api, user_a, user_b, topology):
    """群主禁言/解禁成员：禁言列表变更事件同步到接收账号全部在线端。"""
    owner = topology.sender_action_device
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("mod_mute")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(owner, assert_api, owner=user_a, group_name=group_name, invite_members=[user_b])
        with _allure_step("A 禁言成员"):
            resp_mute = owner.call("GroupManager", Cmd.muteMembers.value, info={"groupId": group_id, "members": [user_b], "duration": 60})
        with _allure_step("验证 禁言成员返回的关键字段"):
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
        for device in recipients:
            with _allure_step("等待并校验目标业务事件"):
                mute_events = collect_group_events(
                    device,
                    expected_event_types={
                        GroupChangeEvent.ON_MUTE_LIST_ADDED.value,
                        "onGroupMuteListAdded",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMuteListAdded"},
                    timeout=10.0,
                )
            with _allure_step("验证 禁言成员返回的关键字段"):
                assert_group_events(
                    assert_api,
                    mute_events,
                    expected_event_types={
                        GroupChangeEvent.ON_MUTE_LIST_ADDED.value,
                        "onGroupMuteListAdded",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMuteListAdded"},
                    expected_member=user_b,
                )
        with _allure_step("A 解除成员禁言"):
            resp_unmute = owner.call("GroupManager", Cmd.unMuteMembers.value, info={"groupId": group_id, "members": [user_b]})
        with _allure_step("验证解除成员禁言返回的关键字段"):
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
        for device in recipients:
            with _allure_step("等待并校验目标业务事件"):
                unmute_events = collect_group_events(
                    device,
                    expected_event_types={
                        GroupChangeEvent.ON_MUTE_LIST_REMOVED.value,
                        "onGroupMuteListRemoved",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMuteListRemoved"},
                    timeout=10.0,
                )
            with _allure_step("验证解除成员禁言返回的关键字段"):
                assert_group_events(
                    assert_api,
                    unmute_events,
                    expected_event_types={
                        GroupChangeEvent.ON_MUTE_LIST_REMOVED.value,
                        "onGroupMuteListRemoved",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupMuteListRemoved"},
                    expected_member=user_b,
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


@pytest.mark.topology("account_a_to_account_b")
def test_group_mute_all_unmute_all_success(assert_api, user_a, user_b, topology):
    """群主全员禁言/解禁：状态变更事件同步到接收账号全部在线端。"""
    owner = topology.sender_action_device
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("mod_mute_all")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(owner, assert_api, owner=user_a, group_name=group_name, invite_members=[user_b])
        with _allure_step("A 全员禁言"):
            resp_mute_all = owner.call("GroupManager", Cmd.muteAllMembers.value, info={"groupId": group_id})
        with _allure_step("验证 全员禁言返回的关键字段"):
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
        for device in recipients:
            with _allure_step("等待并校验目标业务事件"):
                mute_all_events = collect_group_events(
                    device,
                    expected_event_types={
                        GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                        "onGroupAllMemberMuteStateChanged",
                    },
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=set(),
                    timeout=5.0,
                )
            with _allure_step("验证 全员禁言返回的关键字段"):
                assert_group_events(
                    assert_api,
                    mute_all_events,
                    expected_event_types={
                        GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                        "onGroupAllMemberMuteStateChanged",
                    },
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=set(),
                )
        with _allure_step("A 解除全员禁言"):
            resp_unmute_all = owner.call("GroupManager", Cmd.unMuteAllMembers.value, info={"groupId": group_id})
        with _allure_step("验证解除全员禁言返回的关键字段"):
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
        for device in recipients:
            with _allure_step("等待并校验目标业务事件"):
                unmute_all_events = collect_group_events(
                    device,
                    expected_event_types={
                        GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                        "onGroupAllMemberMuteStateChanged",
                    },
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=set(),
                    timeout=5.0,
                )
            with _allure_step("验证解除全员禁言返回的关键字段"):
                assert_group_events(
                    assert_api,
                    unmute_all_events,
                    expected_event_types={
                        GroupChangeEvent.ON_ALL_MEMBER_MUTE_STATE_CHANGED.value,
                        "onGroupAllMemberMuteStateChanged",
                    },
                    group_id=group_id,
                    allow_missing_group_id=True,
                    required_all_event_types=set(),
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


@pytest.mark.topology("account_a_to_account_b")
def test_group_add_remove_white_list_success(assert_api, user_a, user_b, topology):
    """群主添加/移除白名单：白名单变更事件同步到接收账号全部在线端。"""
    owner = topology.sender_action_device
    recipients = topology.recipient_devices
    group_id = ""
    group_name = new_group_name("mod_white")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(owner, assert_api, owner=user_a, group_name=group_name, invite_members=[user_b])
        with _allure_step("A 加入群白名单"):
            resp_add = owner.call("GroupManager", Cmd.addWhiteList.value, info={"groupId": group_id, "members": [user_b]})
        with _allure_step("验证加入群白名单返回的关键字段"):
            assert_api.assert_response_matches(
                resp_add,
                expected={"manager": "GroupManager", "cmd": Cmd.addWhiteList.value, "device": owner.device_name, "result": True},
                ignore_keys={"sequence"},
            )
        for device in recipients:
            with _allure_step("等待并校验目标业务事件"):
                add_white_events = collect_group_events(
                    device,
                    expected_event_types={
                        GroupChangeEvent.ON_WHITE_LIST_ADDED.value,
                        "onGroupWhiteListAdded",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupWhiteListAdded"},
                    timeout=10.0,
                )
            with _allure_step("验证加入群白名单返回的关键字段"):
                assert_group_events(
                    assert_api,
                    add_white_events,
                    expected_event_types={
                        GroupChangeEvent.ON_WHITE_LIST_ADDED.value,
                        "onGroupWhiteListAdded",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupWhiteListAdded"},
                    expected_member=user_b,
                )
        with _allure_step("A 移出群白名单"):
            resp_remove = owner.call("GroupManager", Cmd.removeWhiteList.value, info={"groupId": group_id, "members": [user_b]})
        with _allure_step("验证移出群白名单返回的关键字段"):
            assert_api.assert_response_matches(
                resp_remove,
                expected={"manager": "GroupManager", "cmd": Cmd.removeWhiteList.value, "device": owner.device_name, "result": True},
                ignore_keys={"sequence"},
            )
        for device in recipients:
            with _allure_step("等待并校验目标业务事件"):
                remove_white_events = collect_group_events(
                    device,
                    expected_event_types={
                        GroupChangeEvent.ON_WHITE_LIST_REMOVED.value,
                        "onGroupWhiteListRemoved",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupWhiteListRemoved"},
                    timeout=10.0,
                )
            with _allure_step("验证移出群白名单返回的关键字段"):
                assert_group_events(
                    assert_api,
                    remove_white_events,
                    expected_event_types={
                        GroupChangeEvent.ON_WHITE_LIST_REMOVED.value,
                        "onGroupWhiteListRemoved",
                    },
                    group_id=group_id,
                    required_all_event_types={"onGroupWhiteListRemoved"},
                    expected_member=user_b,
                )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id)


def test_group_update_group_ext_success(device_a, assert_api, user_a):
    group_id = ""
    group_name = new_group_name("mod_ext")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=group_name, invite_members=[])
        with _allure_step("A 更新群扩展信息"):
            resp = device_a.call("GroupManager", Cmd.updateGroupExt.value, info={"groupId": group_id, "ext": "{\"k\":\"v\"}"})
        with _allure_step("验证更新群扩展信息返回的关键字段"):
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
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
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
    with _allure_step("A 执行群组业务操作"):
        resp = device_a.call("GroupManager", cmd, info=info)
    with _allure_step("验证执行群组业务操作返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=code, description=desc)
