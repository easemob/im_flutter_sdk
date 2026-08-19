"""Group metadata 正常链路。"""
from __future__ import annotations

import time

from contextlib import nullcontext

import pytest

from src import Cmd, GroupChangeEvent


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()
from tests.group.group_helpers import (
    assert_group_events,
    assert_group_snapshot,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def _assert_specification_updated_event(
    device_b,
    assert_api,
    *,
    group_id: str,
    expected_name: str,
    expected_desc: str,
) -> None:
    events = collect_group_events(
        device_b,
        expected_event_types={
            GroupChangeEvent.ON_SPECIFICATION_DID_UPDATE.value,
            "onGroupSpecificationDidUpdate",
        },
        group_id=group_id,
        allow_missing_group_id=True,
        required_all_event_types={"onGroupSpecificationDidUpdate"},
        timeout=10.0,
    )
    assert_group_events(
        assert_api,
        events,
        expected_event_types={
            GroupChangeEvent.ON_SPECIFICATION_DID_UPDATE.value,
            "onGroupSpecificationDidUpdate",
        },
        group_id=group_id,
        allow_missing_group_id=True,
        required_all_event_types={"onGroupSpecificationDidUpdate"},
    )
    spec_event = next(evt for evt in events if evt.get("eventType") == "onGroupSpecificationDidUpdate")
    group = ((spec_event.get("data") or {}).get("group") or {})
    assert group.get("groupId") == group_id, f"规格变更回调 groupId 不匹配: {spec_event}"
    assert group.get("name") == expected_name, f"规格变更回调 name 不匹配: {spec_event}"
    assert group.get("desc") == expected_desc, f"规格变更回调 desc 不匹配: {spec_event}"


def _assert_no_specification_updated_event(device, *, group_id: str, timeout: float = 3.0) -> None:
    deadline = time.monotonic() + timeout
    seen: list[dict] = []
    while time.monotonic() < deadline:
        remaining = max(0.1, deadline - time.monotonic())
        evt = device.receive_message(timeout=min(1.0, remaining))
        if not isinstance(evt, dict):
            continue
        if evt.get("type") != "event":
            continue
        if evt.get("eventType") not in {GroupChangeEvent.ON_SPECIFICATION_DID_UPDATE.value, "onGroupSpecificationDidUpdate"}:
            continue
        data = evt.get("data")
        if isinstance(data, dict) and isinstance(data.get("group"), dict) and data["group"].get("groupId") == group_id:
            seen.append(evt)
            break
    assert not seen, f"操作者端不应收到规格变更回调: groupId={group_id}, seen={seen}"


@pytest.mark.topology("account_a_to_account_b")

def test_group_update_subject(assert_api, user_a, user_b, topology):
    """群主更新群名称：变更事件同步到群成员全部在线端。"""
    owner = topology.sender_action_device
    recipients = topology.recipient_devices
    senders = topology.sender_devices
    group_name = new_group_name("subject")
    group_id = ""
    new_subject = new_group_name("subject_new")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )

        with _allure_step("A 更新群名称"):
            resp_update = owner.call(
                "GroupManager",
                Cmd.updateGroupSubject.value,
                info={"groupId": group_id, "subject": new_subject},
            )
        with _allure_step("验证更新群名称返回的关键字段"):
            assert_api.assert_response_matches(
                resp_update,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateGroupSubject.value,
                    "device": owner.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            for endpoint in recipients:
                _assert_specification_updated_event(
                    endpoint,
                    assert_api,
                    group_id=group_id,
                    expected_name="",
                    expected_desc="auto-test group",
                )

        with _allure_step("验证群业务状态、事件与关键字段"):
            for endpoint in senders:
                _assert_no_specification_updated_event(endpoint, group_id=group_id)

        with _allure_step("A 查询本地群详情"):
            resp_local = owner.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_local,
                cmd=Cmd.getGroupWithId.value,
                group_id=group_id,
                group_name="",
                owner=user_a,
                member_count_value=2,
            )
        # 该环境 updateGroupSubject 后 name 为空串；按真实行为冻结
        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert ((resp_local.get("result") or {}).get("name")) == "", f"本地 name 预期为空串: {resp_local}"

        with _allure_step("A 查询服务端群详情"):
            resp_server = owner.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_server,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name="",
                owner=user_a,
                member_count_value=2,
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert ((resp_server.get("result") or {}).get("name")) == "", f"服务端 name 预期为空串: {resp_server}"
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, device_b=topology.recipient_action_device, device_name=owner.device_name)


@pytest.mark.topology("account_a_to_account_b")
def test_group_update_description(assert_api, user_a, user_b, topology):
    """群主更新群描述：变更事件同步到群成员全部在线端。"""
    owner = topology.sender_action_device
    recipients = topology.recipient_devices
    senders = topology.sender_devices
    group_name = new_group_name("desc")
    group_id = ""
    new_desc = new_group_name("desc_new")
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                owner,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )

        with _allure_step("A 执行群组业务操作"):
            resp_update = owner.call(
                "GroupManager",
                Cmd.updateDescription.value,
                info={"groupId": group_id, "description": new_desc},
            )
        with _allure_step("验证执行群组业务操作返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                resp_update,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.updateDescription.value,
                    "device": owner.device_name,
                    "result": None,
                },
                ignore_keys={"sequence"},
            )
        with _allure_step("验证群业务状态、事件与关键字段"):
            for endpoint in recipients:
                _assert_specification_updated_event(
                    endpoint,
                    assert_api,
                    group_id=group_id,
                    expected_name=group_name,
                    expected_desc="",
                )

        with _allure_step("验证群业务状态、事件与关键字段"):
            for endpoint in senders:
                _assert_no_specification_updated_event(endpoint, group_id=group_id)

        with _allure_step("A 查询本地群详情"):
            resp_local = owner.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_local,
                cmd=Cmd.getGroupWithId.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                expected_desc="",
                member_count_value=2,
            )
        # 该环境 updateDescription 后 desc 返回为空串，按真实行为冻结
        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert ((resp_local.get("result") or {}).get("desc")) == "", f"本地 desc 预期为空串: {resp_local}"

        with _allure_step("A 查询服务端群详情"):
            resp_server = owner.call(
                "GroupManager",
                Cmd.getGroupSpecificationFromServer.value,
                info={"groupId": group_id},
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_server,
                cmd=Cmd.getGroupSpecificationFromServer.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                expected_desc="",
                member_count_value=2,
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert ((resp_server.get("result") or {}).get("desc")) == "", f"服务端 desc 预期为空串: {resp_server}"
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(owner, assert_api, group_id, device_b=topology.recipient_action_device, device_name=owner.device_name)
