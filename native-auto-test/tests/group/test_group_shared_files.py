"""Group 共享文件（群主/管理员正常链路 + 异常）。"""
from __future__ import annotations
from contextlib import nullcontext

import pytest

from src import Cmd
from tests.group.group_helpers import (
    assert_group_events,
    assert_no_group_event,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
_SHARED_FILE_NAME = "bigPic.jpg"
_SHARED_FILE_SIZE = 8_498_372


def _consume_direct_invite_events(
    owner_device,
    member_device,
    assert_api,
    *,
    group_id: str,
    owner: str,
    member: str,
) -> None:
    member_events = collect_group_events(
        member_device,
        expected_event_types={"onGroupAutoAcceptInvitation"},
        group_id=group_id,
        required_all_event_types={"onGroupAutoAcceptInvitation"},
        timeout=10.0,
    )
    assert_api.assert_response_matches(
        member_events[0],
        expected={
            "type": "event",
            "eventType": "onGroupAutoAcceptInvitation",
            "data": {"groupId": group_id, "inviter": owner, "inviteMessage": ""},
        },
        ignore_keys={"timestamp", "sequence"},
    )

    owner_event_types = {"onGroupMembersJoined", "onGroupMemberJoined"}
    owner_events = collect_group_events(
        owner_device,
        expected_event_types=owner_event_types,
        group_id=group_id,
        required_all_event_types=owner_event_types,
        timeout=10.0,
    )
    assert_group_events(
        assert_api,
        owner_events,
        expected_event_types=owner_event_types,
        group_id=group_id,
        required_all_event_types=owner_event_types,
        expected_member=member,
    )


def _assert_shared_file_added_event(
    assert_api,
    event: dict,
    *,
    group_id: str,
    owner: str,
) -> dict:
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": "onGroupSharedFileAdded",
            "data": {
                "groupId": group_id,
                "sharedFile": {
                    "owner": owner,
                    "fileSize": _SHARED_FILE_SIZE,
                },
            },
        },
        ignore_keys={"timestamp", "sequence", "fileId", "name", "createTime"},
    )
    shared_file = event["data"]["sharedFile"]
    file_id = shared_file.get("fileId")
    file_name = shared_file.get("name")
    create_time = shared_file.get("createTime")
    assert isinstance(file_id, str) and file_id, f"新增共享文件事件缺少动态 fileId: {event}"
    assert (
        isinstance(file_name, str)
        and file_name.startswith("{b62:")
        and file_name.endswith("}")
        and len(file_name) > len("{b62:}")
    ), f"新增共享文件事件 name 不符合真实服务端编码格式: {event}"
    assert isinstance(create_time, int) and create_time > 0, f"新增共享文件事件 createTime 非法: {event}"
    return shared_file


def _assert_file_list_matches_event(
    device,
    assert_api,
    *,
    device_name: str,
    group_id: str,
    expected_file: dict,
) -> None:
    expected_list_file = dict(expected_file)
    expected_list_file["name"] = _SHARED_FILE_NAME
    resp_list = device.call(
        "GroupManager",
        Cmd.getGroupFileListFromServer.value,
        info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
    )
    assert_api.assert_response_matches(
        resp_list,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getGroupFileListFromServer.value,
            "device": device_name,
            "result": [expected_list_file],
        },
        ignore_keys={"sequence"},
    )


def _upload_remove_and_assert_peer_events(
    operator_device,
    observer_devices,
    assert_api,
    *,
    operator_device_name: str,
    group_id: str,
    operator: str,
) -> None:
    resp_upload = operator_device.call(
        "GroupManager",
        Cmd.uploadGroupSharedFile.value,
        info={"groupId": group_id},
    )
    assert_api.assert_response_matches(
        resp_upload,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.uploadGroupSharedFile.value,
            "device": operator_device_name,
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    shared_file = None
    with _allure_step("owner 账号全部在线端收到共享文件新增事件（onGroupSharedFileAdded）"):
        for __d__ in observer_devices:
            added_events = collect_group_events(
                __d__,
                expected_event_types={"onGroupSharedFileAdded"},
                group_id=group_id,
                required_all_event_types={"onGroupSharedFileAdded"},
                timeout=20.0,
            )
            shared_file = _assert_shared_file_added_event(
                assert_api,
                added_events[0],
                group_id=group_id,
                owner=operator,
            )
    assert_no_group_event(
        operator_device,
        group_id=group_id,
        event_types={"onGroupSharedFileAdded"},
    )

    _assert_file_list_matches_event(
        operator_device,
        assert_api,
        device_name=operator_device_name,
        group_id=group_id,
        expected_file=shared_file,
    )

    file_id = shared_file["fileId"]
    resp_remove = operator_device.call(
        "GroupManager",
        Cmd.removeGroupSharedFile.value,
        info={"groupId": group_id, "fileId": file_id},
    )
    assert_api.assert_response_matches(
        resp_remove,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.removeGroupSharedFile.value,
            "device": operator_device_name,
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    with _allure_step("owner 账号全部在线端收到共享文件删除事件（onGroupSharedFileDeleted）"):
        for __d__ in observer_devices:
            deleted_events = collect_group_events(
                __d__,
                expected_event_types={"onGroupSharedFileDeleted"},
                group_id=group_id,
                required_all_event_types={"onGroupSharedFileDeleted"},
                timeout=10.0,
            )
            assert_api.assert_response_matches(
                deleted_events[0],
                expected={
                    "type": "event",
                    "eventType": "onGroupSharedFileDeleted",
                    "data": {"groupId": group_id, "fileId": file_id},
                },
                ignore_keys={"timestamp", "sequence"},
            )
    assert_no_group_event(
        operator_device,
        group_id=group_id,
        event_types={"onGroupSharedFileDeleted"},
    )

    resp_empty = operator_device.call(
        "GroupManager",
        Cmd.getGroupFileListFromServer.value,
        info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
    )
    assert_api.assert_response_matches(
        resp_empty,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getGroupFileListFromServer.value,
            "device": operator_device_name,
            "result": [],
        },
        ignore_keys={"sequence"},
    )


def test_group_owner_upload_remove_shared_file_notifies_member(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """
    前置：B 为群主、A 已入群；B 所在测试 App 已将默认素材准备为 Android 本地文件。
    步骤：B 不传 filePath 上传默认 bigPic.jpg；A 接收新增事件；B 拉取文件列表后按事件
    fileId 删除文件；A 接收删除事件；B 再次拉取列表。
    预期与断言：上传/删除均返回 true；新增事件中的名称符合真实 `{b62:...}` 服务端编码，
    列表中名称恢复为 `bigPic.jpg`，其 fileId、owner、createTime、真实字节数与事件完全关联；
    删除事件携带同一 fileId；最终列表为空；操作者 B 不收到新增/删除事件。
    """
    group_id = ""
    try:
        group_id, _ = create_group(
            device_b,
            assert_api,
            owner=user_b,
            group_name=new_group_name("owner_shared_file"),
            invite_members=[user_a],
            device_name="deviceB",
        )
        _consume_direct_invite_events(
            device_b,
            device_a,
            assert_api,
            group_id=group_id,
            owner=user_b,
            member=user_a,
        )
        _upload_remove_and_assert_peer_events(
            device_b,
            device_a,
            assert_api,
            operator_device_name="deviceB",
            group_id=group_id,
            operator=user_b,
        )
    finally:
        if group_id:
            destroy_group(
                device_b,
                assert_api,
                group_id,
                device_b=device_a,
                device_name="deviceB",
            )


@pytest.mark.topology("account_a_to_account_b")
def test_group_admin_upload_remove_shared_file_notifies_owner(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    topology,
):
    """管理员 B 上传/删除共享文件：新增/删除事件同步到 owner 账号（A）全部在线端；B 全端收管理员提升事件。"""
    senders = topology.sender_devices
    recipients = topology.recipient_devices
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("admin_shared_file"),
            invite_members=[user_b],
        )
        _consume_direct_invite_events(
            device_a,
            device_b,
            assert_api,
            group_id=group_id,
            owner=user_a,
            member=user_b,
        )

        resp_admin = device_a.call(
            "GroupManager",
            Cmd.addAdmin.value,
            info={"groupId": group_id, "admin": user_b},
        )
        assert_api.assert_response_matches(
            resp_admin,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.addAdmin.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        with _allure_step("B 账号全部在线端收到管理员提升事件（onGroupAdminAdded）"):
            for __d__ in recipients:
                admin_events = collect_group_events(
                    __d__,
                    expected_event_types={"onGroupAdminAdded"},
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminAdded"},
                    timeout=10.0,
                )
                assert_group_events(
                    assert_api,
                    admin_events,
                    expected_event_types={"onGroupAdminAdded"},
                    group_id=group_id,
                    required_all_event_types={"onGroupAdminAdded"},
                    expected_member=user_b,
                )
        with _allure_step("A 账号全部在线端不收到管理员提升事件"):
            for __d__ in senders:
                assert_no_group_event(
                    __d__,
                    group_id=group_id,
                    event_types={"onGroupAdminAdded"},
                )

        _upload_remove_and_assert_peer_events(
            device_b,
            senders,
            assert_api,
            operator_device_name="deviceB",
            group_id=group_id,
            operator=user_b,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_upload_shared_file_explicit_host_path_is_invalid(device_a, assert_api, user_a):
    """
    前置：A 为群主；传入的 `/private/tmp/...` 是 macOS 宿主机路径，不存在于 Android。
    步骤：A 显式传该路径调用 uploadGroupSharedFile；bridge 保留显式路径，不注入素材。
    预期与断言：Android SDK 返回真实错误 `401/Invalid file`，不将该错误当作正常上传结果。
    """
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("shared_file_host_path"),
            invite_members=[],
        )

        resp_upload = device_a.call(
            "GroupManager",
            Cmd.uploadGroupSharedFile.value,
            info={"groupId": group_id, "filePath": "/private/tmp/group_shared_upload_auto.txt"},
        )
        assert_api.assert_error(resp_upload, code=401, description="Invalid file")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_upload_shared_file_nonexistent_group(device_a, assert_api):
    """
    前置：使用固定不存在的 groupId 和显式 Android 不可读路径。
    步骤：A 调用 uploadGroupSharedFile。
    预期与断言：群不存在校验优先，真实返回 `600/do not find this group`。
    """
    resp = device_a.call(
        "GroupManager",
        Cmd.uploadGroupSharedFile.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "filePath": "/private/tmp/x.txt"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_download_shared_file_nonexistent_group_current_behavior(device_a, assert_api):
    """
    前置：使用固定不存在的 groupId/fileId 和宿主机保存路径。
    步骤：A 调用 downloadGroupSharedFile。
    预期与断言：当前 Android Wrapper 真实同步返回 `result=true`；本 case 仅冻结该现状。
    """
    resp = device_a.call(
        "GroupManager",
        Cmd.downloadGroupSharedFile.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "fileId": "1", "savePath": "/private/tmp"},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.downloadGroupSharedFile.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_group_remove_shared_file_nonexistent_group(device_a, assert_api):
    """
    前置：使用固定不存在的 groupId 和 fileId。
    步骤：A 调用 removeGroupSharedFile。
    预期与断言：真实返回 `600/do not find this group`。
    """
    resp = device_a.call(
        "GroupManager",
        Cmd.removeGroupSharedFile.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "fileId": "1"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_upload_shared_file_invalid_path(device_a, assert_api, user_a):
    """
    前置：A 为群主，显式设备路径在 Android 中不存在。
    步骤：A 调用 uploadGroupSharedFile。
    预期与断言：真实返回 `401/Invalid file`，且显式路径不会被 bridge 替换。
    """
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("shared_file_invalid"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.uploadGroupSharedFile.value,
            info={"groupId": group_id, "filePath": "/private/tmp/this_file_should_not_exist_123456789.txt"},
        )
        assert_api.assert_error(resp, code=401, description="Invalid file")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
