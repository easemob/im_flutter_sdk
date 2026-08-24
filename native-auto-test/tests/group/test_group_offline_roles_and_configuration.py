"""群角色、群配置和群资源在 SDK logout/login 窗口内的最终一致性。"""
from __future__ import annotations

import json
import os
import time
import uuid

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import assert_group_snapshot, create_group, new_group_name
from tests.group.group_offline_helpers import (
    assert_call_result,
    device_name,
    login_group_account_devices,
    logout_group_account_devices,
    restore_group_users,
    safe_destroy_group,
    wait_group_event,
)


pytestmark = [
    pytest.mark.client,
    pytest.mark.group,
    pytest.mark.agorachat1_4_0,
    pytest.mark.topology("account_a_to_account_b"),
]

_SHARED_FILE_NAME = "bigPic.jpg"
_SHARED_FILE_SIZE = 8_498_372
_SHARED_FILE_EVENT_NAME = "{b62:2K2xJO0GzQsyk3}"


def _assert_group_event(
    device,
    assert_api,
    *,
    event_type: str,
    group_id: str,
    data: dict,
) -> None:
    devices = device if isinstance(device, (tuple, list)) else (device,)
    for endpoint in devices:
        event = wait_group_event(
            endpoint,
            event_type=event_type,
            group_id=group_id,
            timeout=30.0,
        )
        assert_api.assert_response_matches(
            event,
            expected={"type": "event", "eventType": event_type, "data": data},
            ignore_keys={"timestamp", "sequence"},
        )


def _create_config_group(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    name_prefix: str,
) -> tuple[str, str]:
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)
    group_name = new_group_name(name_prefix)
    group_id, _ = create_group(
        device_a,
        assert_api,
        owner=user_a,
        group_name=group_name,
        invite_members=[user_b],
    )
    time.sleep(float(os.getenv("GROUP_OFFLINE_CONFIG_SETTLE_SECONDS", "3")))
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)
    return group_id, group_name


def _relogin_b(devices, assert_api, *, user_b: str) -> None:
    login_group_account_devices(devices, assert_api, user_id=user_b)


def _restore_case(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    group_id: str,
    sender_devices=(),
    recipient_devices=(),
) -> None:
    restore_group_users(
        device_a,
        device_b,
        assert_api,
        user_a=user_a,
        user_b=user_b,
        sender_devices=sender_devices,
        recipient_devices=recipient_devices,
    )
    safe_destroy_group(device_a, group_id)


def _project_group(response: dict) -> dict:
    group = response.get("result") or {}
    assert isinstance(group, dict), f"群对象 result 不是 dict: {response}"
    return {
        "manager": response.get("manager"),
        "cmd": response.get("cmd"),
        "device": response.get("device"),
        "result": {
            "groupId": group.get("groupId"),
            "owner": group.get("owner"),
            "permissionType": group.get("permissionType"),
            "memberCount": group.get("memberCount"),
            "adminList": group.get("adminList"),
        },
    }


def _assert_group_projection(
    assert_api,
    response: dict,
    *,
    cmd: str,
    device_name: str,
    group_id: str,
    owner: str,
    permission_type: int,
    member_count: int,
    admin_list: list[str],
) -> None:
    assert_api.assert_response_matches(
        _project_group(response),
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": device_name,
            "result": {
                "groupId": group_id,
                "owner": owner,
                "permissionType": permission_type,
                # 5.0 快照无 memberCount（成员单独拉取）
                "adminList": admin_list,
            },
        },
    )


def _assert_local_group_snapshots(
    devices,
    assert_api,
    *,
    group_id: str,
    group_name: str,
    owner: str,
    admin_list_value: list[str],
    permission_type: int,
) -> None:
    """本地群快照按 endpoint 校验；服务端快照由调用方单独查询一次。"""
    for endpoint in devices:
        local = endpoint.call(
            "GroupManager",
            Cmd.getGroupWithId.value,
            info={"groupId": group_id},
        )
        assert_group_snapshot(
            assert_api,
            local,
            cmd=Cmd.getGroupWithId.value,
            group_id=group_id,
            group_name=group_name,
            owner=owner,
            admin_list_value=admin_list_value,
            permission_type=permission_type,
            device=device_name(endpoint),
        )


def _server_group(device, *, group_id: str) -> dict:
    return device.call(
        "GroupManager",
        Cmd.getGroupSpecificationFromServer.value,
        info={"groupId": group_id},
    )


def _assert_string_list(
    device,
    assert_api,
    *,
    device_name: str,
    cmd: str,
    info: dict,
    expected: list[str],
) -> None:
    response = device.call("GroupManager", cmd, info=info)
    result = response.get("result")
    value = result
    if result == {}:
        value = []
    elif isinstance(result, dict) and "list" in result:
        value = result.get("list")
    assert isinstance(value, list), f"{cmd} result/list 不是 list: {response}"
    members: list[str] = []
    for item in value:
        if isinstance(item, str):
            members.append(item)
            continue
        assert isinstance(item, dict), f"{cmd} 成员项不是 str/dict: {item!r}"
        member = next(
            (
                item.get(key)
                for key in ("member", "userId", "username", "owner")
                if isinstance(item.get(key), str)
            ),
            None,
        )
        assert isinstance(member, str), f"{cmd} 无可识别成员字段: {item!r}"
        members.append(member)
    assert_api.assert_response_matches(
        {
            "manager": response.get("manager"),
            "cmd": response.get("cmd"),
            "device": response.get("device"),
            "result": sorted(members),
        },
        expected={
            "manager": "GroupManager",
            "cmd": cmd,
            "device": device_name,
            "result": sorted(expected),
        },
    )



def test_group_offline_admin_add_remove_final_state(
    topology,
    assert_api,
):
    """B 离线期间被设为/移出管理员；每次重登均验证本地角色和服务端 adminList。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_admin",
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 添加群管理员"):
            added = device_a.call(
                "GroupManager",
                Cmd.addAdmin.value,
                info={"groupId": group_id, "admin": user_b},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_projection(
                assert_api,
                added,
                cmd=Cmd.addAdmin.value,
                device_name=device_name(device_a),
                group_id=group_id,
                owner=user_a,
                permission_type=2,
                member_count=2,
                admin_list=[user_b],
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupAdminAdded",
                group_id=group_id,
                # 5.0 wrapper 事件字段 administrator
                data={"groupId": group_id, "administrator": user_b},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_local_group_snapshots(
                recipient_devices,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                admin_list_value=[user_b],
                permission_type=1,
            )
        server_added = _server_group(device_b, group_id=group_id)
        with _allure_step("验证 添加群管理员返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                server_added,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                admin_list_value=[user_b],
                permission_type=1,
                device=device_name(device_b),
            )

        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 移除群管理员"):
            removed = device_a.call(
                "GroupManager",
                Cmd.removeAdmin.value,
                info={"groupId": group_id, "admin": user_b},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_projection(
                assert_api,
                removed,
                cmd=Cmd.removeAdmin.value,
                device_name=device_name(device_a),
                group_id=group_id,
                owner=user_a,
                permission_type=2,
                member_count=2,
                admin_list=[],
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupAdminRemoved",
                group_id=group_id,
                # 5.0 wrapper 事件字段 administrator
                data={"groupId": group_id, "administrator": user_b},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_local_group_snapshots(
                recipient_devices,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                admin_list_value=[],
                permission_type=0,
            )
        server_removed = _server_group(device_b, group_id=group_id)
        with _allure_step("验证 移除群管理员返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                server_removed,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                admin_list_value=[],
                permission_type=0,
                device=device_name(device_b),
            )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_owner_transfer_final_state(
    topology,
    assert_api,
):
    """B 离线期间接任群主；重登后本地和服务端 owner/permissionType 均为新群主。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_owner",
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 转让群主"):
            transferred = device_a.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": user_b},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_projection(
                assert_api,
                transferred,
                cmd=Cmd.updateGroupOwner.value,
                device_name=device_name(device_a),
                group_id=group_id,
                owner=user_b,
                permission_type=0,
                member_count=2,
                admin_list=[],
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupOwnerChanged",
                group_id=group_id,
                data={"groupId": group_id, "newOwner": user_b, "oldOwner": user_a},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_local_group_snapshots(
                recipient_devices,
                assert_api,
                group_id=group_id,
                group_name=group_name,
                owner=user_b,
                admin_list_value=[],
                permission_type=2,
            )
        server = _server_group(device_b, group_id=group_id)
        with _allure_step("验证转让群主返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                server,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_b,
                permission_type=2,
                device=device_name(device_b),
            )
        with _allure_step("B 转让群主"):
            owner_back = device_b.call(
                "GroupManager",
                Cmd.updateGroupOwner.value,
                info={"groupId": group_id, "owner": user_a},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_projection(
                assert_api,
                owner_back,
                cmd=Cmd.updateGroupOwner.value,
                device_name=device_name(device_b),
                group_id=group_id,
                owner=user_a,
                permission_type=0,
                member_count=2,
                admin_list=[],
            )
    finally:
        with _allure_step("测试后置：测试准备：切换账号设备在线状态"):
            restore_group_users(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试后置：销毁测试群并恢复环境"):
            safe_destroy_group(device_a, group_id)
        with _allure_step("测试后置：销毁测试群并恢复环境"):
            safe_destroy_group(device_b, group_id)


@pytest.mark.parametrize("field", ["name", "desc", "avatarUrl", "ext"])
def test_group_offline_metadata_final_state(
    topology,
    assert_api,
    field,
):
    """B 离线期间更新名称/描述/头像/扩展；重登后按真实服务端字段验收。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix=f"offline_meta_{field}",
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        marker = uuid.uuid4().hex[:8]
        if field == "name":
            cmd = Cmd.updateGroupSubject.value
            info = {"groupId": group_id, "subject": f"offline-name-{marker}"}
            expected_value = ""
        elif field == "desc":
            cmd = Cmd.updateDescription.value
            info = {"groupId": group_id, "description": f"offline-desc-{marker}"}
            expected_value = ""
        elif field == "avatarUrl":
            cmd = Cmd.updateGroupAvatar.value
            expected_value = f"https://example.com/offline-group/{marker}.png"
            info = {"groupId": group_id, "avatarUrl": expected_value}
        else:
            cmd = Cmd.updateGroupExt.value
            expected_value = json.dumps({"offline": marker}, separators=(",", ":"))
            info = {"groupId": group_id, "ext": expected_value}

        with _allure_step("A 执行群组业务操作"):
            updated = device_a.call("GroupManager", cmd, info=info)
        if field in {"name", "desc"}:
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    updated,
                    manager="GroupManager",
                    cmd=cmd,
                    device_name=device_name(device_a),
                    result=None,
                )
        else:
            updated_group = updated.get("result") or {}
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_api.assert_response_matches(
                    {
                        "manager": updated.get("manager"),
                        "cmd": updated.get("cmd"),
                        "device": updated.get("device"),
                        "result": {
                            "groupId": updated_group.get("groupId"),
                            field: updated_group.get(field),
                        },
                    },
                    expected={
                        "manager": "GroupManager",
                        "cmd": cmd,
                        "device": "deviceA",
                        "result": {"groupId": group_id, field: expected_value},
                    },
                )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        event_group = {
            "groupId": group_id,
            "name": "" if field == "name" else group_name,
            "avatarUrl": expected_value if field == "avatarUrl" else "",
            "desc": "" if field == "desc" else "auto-test group",
            "owner": user_a,
            "announcement": "",
            # 5.0 事件/快照无 memberCount
            "messageBlocked": False,
            "isDisabled": False,
            "isAllMemberMuted": False,
            "permissionType": 0,
        }
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupSpecificationDidUpdate",
                group_id=group_id,
                data={"group": event_group},
            )
        server = _server_group(device_b, group_id=group_id)
        result = server.get("result") or {}
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                {
                    "manager": server.get("manager"),
                    "cmd": server.get("cmd"),
                    "device": server.get("device"),
                    "result": {"groupId": result.get("groupId"), field: result.get(field)},
                },
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.getGroupSpecificationFromServer.value,
                    "device": "deviceB",
                    "result": {"groupId": group_id, field: expected_value},
                },
            )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_announcement_final_state(
    topology,
    assert_api,
):
    """B 离线期间 A 更新公告；B 重登从公告查询 API 得到同一动态值。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_announcement",
            )
        announcement = f"offline-announcement-{uuid.uuid4().hex[:8]}"
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 更新群公告"):
            updated = device_a.call(
                "GroupManager",
                Cmd.updateGroupAnnouncement.value,
                info={"groupId": group_id, "announcement": announcement},
            )
        with _allure_step("验证更新群公告返回的关键字段"):
            assert_call_result(
                assert_api,
                updated,
                manager="GroupManager",
                cmd=Cmd.updateGroupAnnouncement.value,
                device_name=device_name(device_a),
                result=None,
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupAnnouncementChanged",
                group_id=group_id,
                data={"groupId": group_id, "announcement": announcement},
            )
        for endpoint in recipient_devices:
            with _allure_step("动作端 查询群公告"):
                fetched = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupAnnouncementFromServer.value,
                    info={"groupId": group_id},
                )
            with _allure_step("验证查询群公告返回的关键字段"):
                assert_call_result(
                    assert_api,
                    fetched,
                    manager="GroupManager",
                    cmd=Cmd.getGroupAnnouncementFromServer.value,
                    device_name=device_name(endpoint),
                    result=announcement,
                )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_member_mute_unmute_final_state(
    topology,
    assert_api,
):
    """B 离线期间被禁言/解除禁言；每次重登均从服务端名单验证最终状态。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_mute",
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 禁言成员"):
            muted = device_a.call(
                "GroupManager",
                Cmd.muteMembers.value,
                info={"groupId": group_id, "members": [user_b], "duration": 60},
            )
        muted_group = muted.get("result") or {}
        with _allure_step("验证 禁言成员返回的关键字段"):
            assert_api.assert_response_matches(
                {
                    "manager": muted.get("manager"),
                    "cmd": muted.get("cmd"),
                    "device": muted.get("device"),
                    "result": {"groupId": muted_group.get("groupId"), "muteList": muted_group.get("muteList")},
                },
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.muteMembers.value,
                    "device": "deviceA",
                    "result": {"groupId": group_id, "muteList": [user_b]},
                },
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupMuteListAdded",
                group_id=group_id,
                data={
                    "groupId": group_id,
                    "mutes": [user_b],
                    "muteExpire": 4_638_873_600_000,
                },
            )
        muted_server = _server_group(device_b, group_id=group_id)
        muted_server_group = muted_server.get("result") or {}
        with _allure_step("验证 禁言成员返回的关键字段"):
            assert_api.assert_response_matches(
                {
                    "manager": muted_server.get("manager"),
                    "cmd": muted_server.get("cmd"),
                    "device": muted_server.get("device"),
                    "result": {
                        "groupId": muted_server_group.get("groupId"),
                        "muteList": muted_server_group.get("muteList"),
                    },
                },
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.getGroupSpecificationFromServer.value,
                    "device": "deviceB",
                    "result": {"groupId": group_id, "muteList": [user_b]},
                },
            )

        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 解除成员禁言"):
            unmuted = device_a.call(
                "GroupManager",
                Cmd.unMuteMembers.value,
                info={"groupId": group_id, "members": [user_b]},
            )
        unmuted_group = unmuted.get("result") or {}
        with _allure_step("验证解除成员禁言返回的关键字段"):
            assert_api.assert_response_matches(
                {
                    "manager": unmuted.get("manager"),
                    "cmd": unmuted.get("cmd"),
                    "device": unmuted.get("device"),
                    "result": {"groupId": unmuted_group.get("groupId"), "muteList": unmuted_group.get("muteList")},
                },
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.unMuteMembers.value,
                    "device": "deviceA",
                    "result": {"groupId": group_id, "muteList": []},
                },
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupMuteListRemoved",
                group_id=group_id,
                data={"groupId": group_id, "mutes": [user_b]},
            )
        unmuted_server = _server_group(device_b, group_id=group_id)
        unmuted_server_group = unmuted_server.get("result") or {}
        with _allure_step("验证解除成员禁言返回的关键字段"):
            assert_api.assert_response_matches(
                {
                    "manager": unmuted_server.get("manager"),
                    "cmd": unmuted_server.get("cmd"),
                    "device": unmuted_server.get("device"),
                    "result": {
                        "groupId": unmuted_server_group.get("groupId"),
                        "muteList": unmuted_server_group.get("muteList"),
                    },
                },
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.getGroupSpecificationFromServer.value,
                    "device": "deviceB",
                    "result": {"groupId": group_id, "muteList": []},
                },
            )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_mute_all_unmute_all_final_state(
    topology,
    assert_api,
):
    """B 离线期间全员禁言/解除；每次重登均查询 isAllMemberMuted。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    group_name = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, group_name = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_mute_all",
            )
        for cmd, expected_state in (
            (Cmd.muteAllMembers.value, True),
            (Cmd.unMuteAllMembers.value, False),
        ):
            with _allure_step("测试准备：切换账号设备在线状态"):
                logout_group_account_devices(recipient_devices, assert_api)
            with _allure_step("A 执行群组业务操作"):
                response = device_a.call("GroupManager", cmd, info={"groupId": group_id})
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_group_snapshot(
                    assert_api,
                    response,
                    cmd=cmd,
                    group_id=group_id,
                    group_name=group_name,
                    owner=user_a,
                        is_all_member_muted=expected_state,
                )
            _relogin_b(recipient_devices, assert_api, user_b=user_b)
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_group_event(
                    recipient_devices,
                    assert_api,
                    event_type="onGroupAllMemberMuteStateChanged",
                    group_id=group_id,
                    # 5.0 wrapper 事件字段 isMuted
                    data={"groupId": group_id, "isMuted": expected_state},
                )
            server = _server_group(device_b, group_id=group_id)
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_group_snapshot(
                    assert_api,
                    server,
                    cmd=Cmd.getGroupSpecificationFromServer.value,
                    group_id=group_id,
                    group_name=group_name,
                    owner=user_a,
                        is_all_member_muted=expected_state,
                    permission_type=0,
                    device=device_name(device_b),
                )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_allow_list_add_remove_final_state(
    topology,
    assert_api,
):
    """B 离线期间加入/移出白名单；每次重登均从服务端白名单验证。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_allow_list",
            )
        for cmd, expected_membership, expected_owner_list in (
            (Cmd.addWhiteList.value, True, [user_a, user_b]),
            (Cmd.removeWhiteList.value, False, [user_a]),
        ):
            with _allure_step("测试准备：切换账号设备在线状态"):
                logout_group_account_devices(recipient_devices, assert_api)
            with _allure_step("A 执行群组业务操作"):
                response = device_a.call(
                    "GroupManager", cmd, info={"groupId": group_id, "members": [user_b]}
                )
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    response,
                    manager="GroupManager",
                    cmd=cmd,
                    device_name=device_name(device_a),
                    result=True,
                )
            _relogin_b(recipient_devices, assert_api, user_b=user_b)

            event_type = (
                "onGroupWhiteListAdded"
                if expected_membership
                else "onGroupWhiteListRemoved"
            )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_group_event(
                    recipient_devices,
                    assert_api,
                    event_type=event_type,
                    group_id=group_id,
                    # 5.0 wrapper 事件字段 whitelist
                    data={"groupId": group_id, "whitelist": [user_b]},
                )

            for endpoint in recipient_devices:
                with _allure_step("动作端 查询白名单成员状态"):
                    membership = endpoint.call(
                        "GroupManager",
                        Cmd.isMemberInWhiteListFromServer.value,
                        info={"groupId": group_id},
                    )
                with _allure_step("验证查询白名单成员状态返回的关键字段"):
                    assert_call_result(
                        assert_api,
                        membership,
                        manager="GroupManager",
                        cmd=Cmd.isMemberInWhiteListFromServer.value,
                        device_name=device_name(endpoint),
                        result=expected_membership,
                    )
            for endpoint in sender_devices:
                with _allure_step("验证群业务状态、事件与关键字段"):
                    _assert_string_list(
                        endpoint,
                        assert_api,
                        device_name=device_name(endpoint),
                        cmd=Cmd.getGroupWhiteListFromServer.value,
                        info={"groupId": group_id},
                        expected=expected_owner_list,
                    )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_member_attributes_final_state(
    topology,
    assert_api,
):
    """A 离线期间 B 修改自己的群成员属性；A 重登后按成员 ID 查询到同一属性。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_member_attrs",
            )
        attrs = {"offlineRole": "member", "marker": uuid.uuid4().hex[:8]}
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(sender_devices, assert_api)
        with _allure_step("B 执行群组业务操作"):
            updated = device_b.call(
                "GroupManager",
                Cmd.setMemberAttributesFromGroup.value,
                info={"groupId": group_id, "attributes": attrs},
            )
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_call_result(
                assert_api,
                updated,
                manager="GroupManager",
                cmd=Cmd.setMemberAttributesFromGroup.value,
                device_name=device_name(device_b),
                result=None,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(sender_devices, assert_api, user_id=user_a)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                sender_devices,
                assert_api,
                event_type="onGroupAttributesChangedOfMember",
                group_id=group_id,
                data={
                    "groupId": group_id,
                    "userId": user_b,
                    "attributes": attrs,
                    "operatorId": user_b,
                },
            )
        for endpoint in sender_devices:
            with _allure_step("动作端 执行群组业务操作"):
                fetched = endpoint.call(
                    "GroupManager",
                    Cmd.fetchMembersAttributesFromGroup.value,
                    info={"groupId": group_id, "userIds": [user_b]},
                )
            with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    fetched,
                    manager="GroupManager",
                    cmd=Cmd.fetchMembersAttributesFromGroup.value,
                    device_name=device_name(endpoint),
                    result={user_b: attrs},
                )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_shared_file_upload_delete_final_state(
    topology,
    assert_api,
):
    """B 离线期间上传/删除共享文件；每次重登均从服务端文件列表验证终态。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_config_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_shared_file",
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 上传群共享文件"):
            uploaded = device_a.call(
                "GroupManager",
                Cmd.uploadGroupSharedFile.value,
                info={"groupId": group_id},
            )
        # 5.0 asyncUploadGroupSharedFile 回调 EMValueCallBack<EMMucSharedFile> → result 为 {fileId, fileName}
        uploaded_result = (uploaded.get("result") or {})
        with _allure_step("验证 上传群共享文件返回的关键字段"):
            assert isinstance(uploaded_result.get("fileId"), str) and uploaded_result["fileId"], (
                f"上传响应缺少 fileId: {uploaded}"
            )
        with _allure_step("A 查询群共享文件列表"):
            owner_list = device_a.call(
                "GroupManager",
                Cmd.getGroupFileListFromServer.value,
                info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
            )
        files = owner_list.get("result")
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert isinstance(files, list) and len(files) == 1, (
                f"上传后共享文件列表应只有目标文件: {owner_list}"
            )
        expected_file = files[0]
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert isinstance(expected_file, dict), f"共享文件项不是 dict: {owner_list}"
        file_id = expected_file.get("fileId")
        create_time = expected_file.get("createTime")
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert isinstance(file_id, str) and file_id, f"共享文件缺少 fileId: {owner_list}"
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert isinstance(create_time, int) and create_time > 0, (
                f"共享文件 createTime 非正整数: {owner_list}"
            )
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert_api.assert_response_matches(
                expected_file,
                expected={
                    "fileId": file_id,
                    "name": _SHARED_FILE_NAME,
                    "owner": user_a,
                    "createTime": create_time,
                    "fileSize": _SHARED_FILE_SIZE,
                },
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupSharedFileAdded",
                group_id=group_id,
                data={
                    "groupId": group_id,
                    "sharedFile": {
                        "fileId": file_id,
                        "name": _SHARED_FILE_EVENT_NAME,
                        "owner": user_a,
                        "createTime": create_time,
                        "fileSize": _SHARED_FILE_SIZE,
                    },
                },
            )
        for endpoint in recipient_devices:
            with _allure_step("动作端 查询群共享文件列表"):
                member_list = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupFileListFromServer.value,
                    info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
                )
            with _allure_step("验证查询群共享文件列表返回的关键字段"):
                assert_call_result(
                    assert_api,
                    member_list,
                    manager="GroupManager",
                    cmd=Cmd.getGroupFileListFromServer.value,
                    device_name=device_name(endpoint),
                    result=[expected_file],
                )

        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 执行群组业务操作"):
            deleted = device_a.call(
                "GroupManager",
                Cmd.removeGroupSharedFile.value,
                info={"groupId": group_id, "fileId": file_id},
            )
        with _allure_step("验证查询群共享文件列表返回的关键字段"):
            assert_call_result(
                assert_api,
                deleted,
                manager="GroupManager",
                cmd=Cmd.removeGroupSharedFile.value,
                device_name=device_name(device_a),
                result=True,
            )
        _relogin_b(recipient_devices, assert_api, user_b=user_b)
        with _allure_step("验证群业务状态、事件与关键字段"):
            _assert_group_event(
                recipient_devices,
                assert_api,
                event_type="onGroupSharedFileDeleted",
                group_id=group_id,
                data={"groupId": group_id, "fileId": file_id},
            )
        for endpoint in recipient_devices:
            with _allure_step("动作端 查询群共享文件列表"):
                empty = endpoint.call(
                    "GroupManager",
                    Cmd.getGroupFileListFromServer.value,
                    info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
                )
            with _allure_step("验证查询群共享文件列表返回的关键字段"):
                assert_call_result(
                    assert_api,
                    empty,
                    manager="GroupManager",
                    cmd=Cmd.getGroupFileListFromServer.value,
                    device_name=device_name(endpoint),
                    result=[],
                )
    finally:
        _restore_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )
