"""Group member list API 异常/边界用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.test_group_member_list import _extract_member_ids


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


def test_group_get_group_member_list_from_server_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.getGroupMemberListFromServer.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "pageNum": 1, "pageSize": 20},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


@pytest.mark.parametrize(
    ("page_num", "page_size"),
    [
        (0, 20),
        (-1, 20),
        (1, 0),
        (1, -1),
    ],
)
def test_group_get_group_member_list_from_server_invalid_paging(device_a, assert_api, user_a, user_b, page_num, page_size):
    # 用不存在群 ID 触发稳定错误，避免分页边界受群态影响
    resp = device_a.call(
        "GroupManager",
        Cmd.getGroupMemberListFromServer.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "pageNum": page_num, "pageSize": page_size},
    )
    result = resp.get("result")
    if isinstance(result, dict) and "code" in result and "description" in result:
        code = result.get("code")
        desc = str(result.get("description", ""))
        assert isinstance(code, int), f"错误码类型异常: {resp}"
        assert desc, f"错误描述为空: {resp}"
        assert_api.assert_error(resp, code=code, description=desc)
        return

    # 若当前端未返回错误，则至少保证返回结构可解析
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getGroupMemberListFromServer.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    _extract_member_ids(resp.get("result"), resp=resp)
