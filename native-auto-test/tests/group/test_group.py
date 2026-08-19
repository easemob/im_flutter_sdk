"""Group 历史复现用例（保留）。

说明：
- 主体正常/异常用例已拆分到：
  - test_group_lifecycle.py
  - test_group_members.py
  - test_group_metadata.py
  - test_group_exceptions_*.py
"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import (
    assert_group_members_exact,
    assert_group_snapshot,
    create_group,
    destroy_group,
    member_count,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]



def test_group_member_count_local_then_server_sync(device_a, device_b, assert_api, user_a, user_b, user_c):
    """
    复现流程：
    1) 邀请别人入群（addMembers）
    2) getGroupWithId（本地）读取人数
    3) getGroupSpecificationFromServer（服务端）读取人数
    4) 再次 getGroupWithId（本地）读取人数，验证与服务端一致

    说明：
    - 若本地人数与服务端人数不一致，则判定“复现到问题”；
    - 若未出现不一致，则该环境下未复现，使用 skip 标记。
    """
    group_name = new_group_name("count_sync")
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=group_name,
                invite_members=[user_b],
            )

        with _allure_step("A 添加群成员"):
            resp_add = device_a.call(
                "GroupManager",
                Cmd.addMembers.value,
                info={"groupId": group_id, "members": [user_c], "welcome": "count-sync-case"},
            )
        with _allure_step("验证 添加群成员返回的关键字段"):
            assert_api.assert_response_matches(
                resp_add,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.addMembers.value,
                    "device": "deviceA",
                    "result": True,
                },
                ignore_keys={"sequence"},
            )

        with _allure_step("A 查询本地群详情"):
            resp_local_before = device_a.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_local_before,
                cmd=Cmd.getGroupWithId.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=None,
            )
        local_before_count = member_count(resp_local_before)

        with _allure_step("A 查询服务端群详情"):
            resp_server = device_a.call(
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
                member_count_value=3,
            )
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert member_count(resp_server) == 3, f"服务端成员数量预期 3: {resp_server}"
        with _allure_step("验证查询服务端群详情返回的关键字段"):
            assert_group_members_exact(resp_server, [user_b, user_c], err_prefix="服务端拉取后")
        server_count = member_count(resp_server)

        with _allure_step("A 查询本地群详情"):
            resp_local_after = device_a.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": group_id})
        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert_group_snapshot(
                assert_api,
                resp_local_after,
                cmd=Cmd.getGroupWithId.value,
                group_id=group_id,
                group_name=group_name,
                owner=user_a,
                member_count_value=3,
            )
        local_after_count = member_count(resp_local_after)
        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert local_after_count == 3, f"服务端拉取后本地成员数量预期 3: {resp_local_after}"

        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert local_after_count == server_count, (
                "从服务端拉取后，本地人数未与服务端对齐: "
                f"local_after={local_after_count}, server={server_count}"
            )

        if local_before_count == server_count:
            pytest.skip(
                f"本次未复现“本地人数不正确”问题: local_before={local_before_count}, server={server_count}"
            )

        with _allure_step("验证查询本地群详情返回的关键字段"):
            assert local_before_count != server_count, (
                f"预期复现本地与服务端人数不一致，但未复现: local_before={local_before_count}, server={server_count}"
            )
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id, device_b=device_b)
