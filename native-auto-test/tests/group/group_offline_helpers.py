"""Group 离线专项共用的最小编排辅助。"""
from __future__ import annotations

import time
from collections.abc import Callable

from src import Cmd
from src.test_flow.offline_test_flow import (
    login_preserving_offline_events,
    logout_account_devices,
    restore_account_devices,
)
from tests.group.group_helpers import assert_group_snapshot


def assert_call_result(
    assert_api,
    response: dict,
    *,
    manager: str,
    cmd: str,
    device_name: str,
    result,
) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": manager,
            "cmd": cmd,
            "device": device_name,
            "result": result,
        },
        ignore_keys={"sequence"},
    )


def device_name(device) -> str:
    """返回 topology endpoint 的展示名，不依赖 deviceA/deviceB 字面角色。"""
    return getattr(device, "device_name", None) or getattr(device, "_device", "device")


def unique_devices(devices) -> tuple:
    """按 topology 顺序去重 endpoint。"""
    result = []
    for device in devices:
        if device is not None and not any(device is item for item in result):
            result.append(device)
    return tuple(result)


def login_group_account_devices(devices, assert_api, *, user_id: str) -> None:
    """按 endpoint 逐台恢复同一账号，并保留各端离线事件供用例读取。"""
    for device in unique_devices(devices):
        login_preserving_offline_events(
            device,
            assert_api,
            device_name=device_name(device),
            user_id=user_id,
        )


def logout_group_account_devices(devices, assert_api) -> None:
    """让同一账号的全部 endpoint 下线，形成真正的账号级离线窗口。"""
    logout_account_devices(unique_devices(devices), assert_api)


def set_auto_accept_group_invitation(
    device,
    assert_api,
    *,
    device_name: str,
    enabled: bool,
) -> None:
    response = device.call(
        "Client",
        Cmd.updateAutoAcceptGroupInvitationSetting.value,
        info={"autoAcceptGroupInvitation": enabled},
    )
    assert_call_result(
        assert_api,
        response,
        manager="Client",
        cmd=Cmd.updateAutoAcceptGroupInvitationSetting.value,
        device_name=device_name,
        result=None,
    )


def restore_group_users(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    restore_group_invitation_option: bool = False,
    sender_devices=(),
    recipient_devices=(),
) -> None:
    """finally 中恢复默认账号；不覆盖原始测试失败。"""
    sender_devices = unique_devices(sender_devices or (device_a,))
    recipient_devices = unique_devices(recipient_devices or (device_b,))
    restore_account_devices(sender_devices, user_id=user_a)
    restore_account_devices(recipient_devices, user_id=user_b)
    if restore_group_invitation_option:
        for device in recipient_devices:
            try:
                set_auto_accept_group_invitation(
                    device,
                    assert_api,
                    device_name=device_name(device),
                    enabled=True,
                )
            except Exception:
                pass
    for device in (*sender_devices, *recipient_devices):
        try:
            device.drain_events(timeout=0.5)
        except Exception:
            pass


def safe_destroy_group(device_a, group_id: str) -> None:
    """清理动态群；清理失败不能覆盖业务 case 的原始异常。"""
    if not group_id:
        return
    try:
        device_a.call(
            "GroupManager",
            Cmd.destroyGroup.value,
            info={"groupId": group_id},
        )
    except Exception:
        pass


def _event_group_id(event: dict) -> str | None:
    data = event.get("data") or {}
    if isinstance(data, dict):
        group_id = data.get("groupId")
        if isinstance(group_id, str):
            return group_id
        group = data.get("group")
        if isinstance(group, dict) and isinstance(group.get("groupId"), str):
            return group["groupId"]
    return None


def wait_group_event(
    device,
    *,
    event_type: str,
    group_id: str,
    predicate: Callable[[dict], bool] | None = None,
    timeout: float = 30.0,
) -> dict:
    """等待指定群事件；只过滤，不重组原始事件。"""
    deadline = time.monotonic() + timeout
    seen: list[dict] = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        if not event or _event_group_id(event) != group_id:
            continue
        if predicate is None or predicate(event):
            return event
    raise AssertionError(
        f"未收到目标群事件: eventType={event_type}, groupId={group_id}, events={seen}"
    )


def assert_joined_group_projection(
    device,
    assert_api,
    *,
    device_name: str,
    group_id: str,
    present: bool,
    owner: str | None = None,
    permission_type: int | None = None,
    member_count: int | None = None,
) -> None:
    """对本次动态 groupId 做本地和服务端 joined groups 目标投影。"""
    for cmd in (Cmd.getJoinedGroups.value,):  # 5.0 移除 getJoinedGroupsFromServer，改用本地 getJoinedGroups
        response = device.call("GroupManager", cmd, info={})
        result = response.get("result")
        assert isinstance(result, list), f"{cmd} result 不是 list: {response}"
        targets = [
            item
            for item in result
            if isinstance(item, dict) and item.get("groupId") == group_id
        ]
        target_projection = [
            {
                "groupId": item.get("groupId"),
                "owner": item.get("owner"),
                "permissionType": item.get("permissionType"),
                "memberCount": item.get("memberCount"),
            }
            for item in targets
        ]
        expected_projection = []
        if present:
            expected_projection = [
                {
                    "groupId": group_id,
                    "owner": owner,
                    "permissionType": permission_type,
                    "memberCount": member_count,
                }
            ]
        assert_api.assert_response_matches(
            {
                "manager": response.get("manager"),
                "cmd": response.get("cmd"),
                "device": response.get("device"),
                "result": target_projection,
            },
            expected={
                "manager": "GroupManager",
                "cmd": cmd,
                "device": device_name,
                "result": expected_projection,
            },
        )
        if not present:
            continue


def assert_local_group_permission(
    device,
    assert_api,
    *,
    device_name: str,
    group_id: str,
    group_name: str,
    owner: str,
    permission_type: int,
    member_count: int,
) -> None:
    response = device.call(
        "GroupManager",
        Cmd.getGroupWithId.value,
        info={"groupId": group_id},
    )
    assert_group_snapshot(
        assert_api,
        response,
        cmd=Cmd.getGroupWithId.value,
        group_id=group_id,
        group_name=group_name,
        owner=owner,
        member_count_value=member_count,
        permission_type=permission_type,
        device=device_name,
    )
