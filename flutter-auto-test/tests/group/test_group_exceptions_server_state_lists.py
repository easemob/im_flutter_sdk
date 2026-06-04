"""Group 服务端状态列表 API 异常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


@pytest.mark.parametrize(
    "cmd",
    [
        Cmd.getGroupBlockListFromServer.value,
        Cmd.getGroupMuteListFromServer.value,
        Cmd.getGroupWhiteListFromServer.value,
        Cmd.isMemberInWhiteListFromServer.value,
    ],
)
def test_group_server_state_list_nonexistent_group(device_a, assert_api, cmd):
    info = {"groupId": _NONEXISTENT_GROUP_ID}
    if cmd in (Cmd.getGroupBlockListFromServer.value, Cmd.getGroupMuteListFromServer.value):
        info.update({"pageNum": 1, "pageSize": 20})
    resp = device_a.call("GroupManager", cmd, info=info)
    assert_api.assert_error(resp, code=600, description="do not find this group")

