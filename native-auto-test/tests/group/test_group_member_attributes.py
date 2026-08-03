"""Group 成员属性 API 正常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def test_group_set_and_fetch_member_attributes_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    attrs = {"k1": "v1", "level": "gold"}
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("member_attr"),
            invite_members=[user_b],
        )

        resp_set = device_b.call(
            "GroupManager",
            Cmd.setMemberAttributesFromGroup.value,
            info={"groupId": group_id, "attributes": attrs},
        )
        assert_api.assert_response_matches(
            resp_set,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.setMemberAttributesFromGroup.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        attr_events = collect_group_events(
            device_a,
            expected_event_types={
                GroupChangeEvent.ON_ATTRIBUTES_CHANGED_OF_MEMBER.value,
                "onGroupAttributesChangedOfMember",
                "onGroupAttributesChangedOfMember",
            },
            group_id=group_id,
            required_all_event_types={"onGroupAttributesChangedOfMember"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            attr_events,
            expected_event_types={
                GroupChangeEvent.ON_ATTRIBUTES_CHANGED_OF_MEMBER.value,
                "onGroupAttributesChangedOfMember",
                "onGroupAttributesChangedOfMember",
            },
            group_id=group_id,
            required_all_event_types={"onGroupAttributesChangedOfMember"},
            expected_member=user_b,
        )

        resp_fetch_single = device_b.call(
            "GroupManager",
            Cmd.fetchMemberAttributesFromGroup.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_fetch_single,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.fetchMemberAttributesFromGroup.value,
                "device": "deviceB",
            },
            ignore_keys={"sequence", "result"},
        )
        result_single = resp_fetch_single.get("result")
        assert isinstance(result_single, dict), f"fetchMemberAttributesFromGroup result 非 dict: {resp_fetch_single}"
        for k, v in attrs.items():
            assert result_single.get(k) == v, f"fetchMemberAttributesFromGroup 属性不匹配 key={k}: {resp_fetch_single}"

        resp_fetch_multi = device_a.call(
            "GroupManager",
            Cmd.fetchMembersAttributesFromGroup.value,
            info={"groupId": group_id, "userIds": [user_b]},
        )
        assert_api.assert_response_matches(
            resp_fetch_multi,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.fetchMembersAttributesFromGroup.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        result_multi = resp_fetch_multi.get("result")
        assert isinstance(result_multi, dict), f"fetchMembersAttributesFromGroup result 非 dict: {resp_fetch_multi}"
        assert user_b in result_multi, f"fetchMembersAttributesFromGroup 未包含目标成员: {resp_fetch_multi}"
        user_attrs = result_multi.get(user_b)
        assert isinstance(user_attrs, dict), f"成员属性值非 dict: {resp_fetch_multi}"
        for k, v in attrs.items():
            assert user_attrs.get(k) == v, f"fetchMembersAttributesFromGroup 属性不匹配 key={k}: {resp_fetch_multi}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
