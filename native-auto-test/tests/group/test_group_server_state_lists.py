"""Group 服务端状态列表 API 正常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


def _extract_string_list(result: object, *, api_name: str, resp: dict) -> list[str]:
    if result == {}:
        return []
    value = result
    if isinstance(result, dict):
        # 某些接口返回 {"cursor":"", "list":[...]}
        if "list" in result:
            value = result.get("list")
    assert isinstance(value, list), f"{api_name} result/list 不是 list: {resp}"

    out: list[str] = []
    for idx, item in enumerate(value):
        if isinstance(item, str):
            out.append(item)
            continue
        assert isinstance(item, dict), f"{api_name} list[{idx}] 不是 str/dict: {item!r}"
        member = None
        for key in ("member", "userId", "username", "owner"):
            v = item.get(key)
            if isinstance(v, str):
                member = v
                break
        assert member is not None, f"{api_name} list[{idx}] 无可识别成员字段: {item!r}"
        out.append(member)
    return out


def test_group_get_group_block_list_from_server_success(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("block_list"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.getGroupBlockListFromServer.value,
            info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupBlockListFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        blocked_users = _extract_string_list(
            resp.get("result"),
            api_name=Cmd.getGroupBlockListFromServer.value,
            resp=resp,
        )
        assert blocked_users == [], f"新建群 blockList 预期为空: {resp}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_get_group_mute_list_from_server_success(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("mute_list"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.getGroupMuteListFromServer.value,
            info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupMuteListFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        muted_users = _extract_string_list(
            resp.get("result"),
            api_name=Cmd.getGroupMuteListFromServer.value,
            resp=resp,
        )
        assert muted_users == [], f"新建群 muteList 预期为空: {resp}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_get_group_white_list_and_member_check_success(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("white_list"),
            invite_members=[],
        )
        resp_white = device_a.call(
            "GroupManager",
            Cmd.getGroupWhiteListFromServer.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_white,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupWhiteListFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        _extract_string_list(
            resp_white.get("result"),
            api_name=Cmd.getGroupWhiteListFromServer.value,
            resp=resp_white,
        )

        resp_check = device_a.call(
            "GroupManager",
            Cmd.isMemberInWhiteListFromServer.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_check,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.isMemberInWhiteListFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        result = resp_check.get("result")
        assert isinstance(result, bool), f"isMemberInWhiteListFromServer result 应为 bool: {resp_check}"
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
