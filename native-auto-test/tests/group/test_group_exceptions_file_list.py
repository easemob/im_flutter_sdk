"""Group 共享文件列表异常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


@pytest.mark.parametrize(
    "page_num,page_size",
    [
        (1, 20),
        (0, 20),
        (1, 0),
    ],
)

def test_group_get_group_file_list_from_server_nonexistent_group(
    device_a,
    assert_api,
    page_num,
    page_size,
):
    with _allure_step("A 查询群共享文件列表"):
        resp = device_a.call(
            "GroupManager",
            Cmd.getGroupFileListFromServer.value,
            info={"groupId": _NONEXISTENT_GROUP_ID, "pageNum": page_num, "pageSize": page_size},
        )
    with _allure_step("验证查询群共享文件列表返回的错误码与错误文案"):
        assert_api.assert_error(resp, code=600, description="do not find this group")
