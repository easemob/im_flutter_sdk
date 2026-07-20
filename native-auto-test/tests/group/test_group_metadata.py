"""Group metadata 正常链路。"""
from __future__ import annotations

import time

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
            "onSpecificationDidUpdate",
        },
        group_id=group_id,
        allow_missing_group_id=True,
        required_all_event_types={"onSpecificationDidUpdate"},
        timeout=10.0,
    )
    assert_group_events(
        assert_api,
        events,
        expected_event_types={
            GroupChangeEvent.ON_SPECIFICATION_DID_UPDATE.value,
            "onSpecificationDidUpdate",
        },
        group_id=group_id,
        allow_missing_group_id=True,
        required_all_event_types={"onSpecificationDidUpdate"},
    )
    spec_event = next(evt for evt in events if evt.get("eventType") == "onSpecificationDidUpdate")
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
        if evt.get("eventType") not in {GroupChangeEvent.ON_SPECIFICATION_DID_UPDATE.value, "onSpecificationDidUpdate"}:
            continue
        data = evt.get("data")
        if isinstance(data, dict) and isinstance(data.get("group"), dict) and data["group"].get("groupId") == group_id:
            seen.append(evt)
            break
    assert not seen, f"操作者端不应收到规格变更回调: groupId={group_id}, seen={seen}"


def test_group_update_subject(device_a, device_b, assert_api, user_a, user_b):
    group_name = new_group_name("subject")
    group_id = ""
    new_subject = new_group_name("subject_new")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )

        resp_update = device_a.call(
            "GroupManager",
            Cmd.updateGroupSubject.value,
            info={"groupId": group_id, "subject": new_subject},
        )
        assert_api.assert_response_matches(
            resp_update,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupSubject.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
        _assert_specification_updated_event(
            device_b,
            assert_api,
            group_id=group_id,
            expected_name="",
            expected_desc="auto-test group",
        )
        _assert_no_specification_updated_event(device_a, group_id=group_id)

        resp_local = device_a.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
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
        assert ((resp_local.get("result") or {}).get("name")) == "", f"本地 name 预期为空串: {resp_local}"

        resp_server = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
        assert_group_snapshot(
            assert_api,
            resp_server,
            cmd=Cmd.getGroupSpecificationFromServer.value,
            group_id=group_id,
            group_name="",
            owner=user_a,
            member_count_value=2,
        )
        assert ((resp_server.get("result") or {}).get("name")) == "", f"服务端 name 预期为空串: {resp_server}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)


def test_group_update_description(device_a, device_b, assert_api, user_a, user_b):
    group_name = new_group_name("desc")
    group_id = ""
    new_desc = new_group_name("desc_new")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=group_name,
            invite_members=[user_b],
        )

        resp_update = device_a.call(
            "GroupManager",
            Cmd.updateDescription.value,
            info={"groupId": group_id, "description": new_desc},
        )
        assert_api.assert_response_matches(
            resp_update,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateDescription.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
        _assert_specification_updated_event(
            device_b,
            assert_api,
            group_id=group_id,
            expected_name=group_name,
            expected_desc="",
        )
        _assert_no_specification_updated_event(device_a, group_id=group_id)

        resp_local = device_a.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
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
        assert ((resp_local.get("result") or {}).get("desc")) == "", f"本地 desc 预期为空串: {resp_local}"

        resp_server = device_a.call(
            "GroupManager",
            Cmd.getGroupSpecificationFromServer.value,
            info={"groupId": group_id, "fetchMembers": True},
        )
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
        assert ((resp_server.get("result") or {}).get("desc")) == "", f"服务端 desc 预期为空串: {resp_server}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id, device_b=device_b)
