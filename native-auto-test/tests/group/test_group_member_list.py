"""Group member list API 正常用例（strict）。"""
from __future__ import annotations

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group, pytest.mark.agorachat1_4_0]


def _extract_member_ids(result: object, *, resp: dict) -> set[str]:
    members = result
    if isinstance(result, dict):
        assert "list" in result, f"getGroupMemberListFromServer result(dict) 缺少 list: {resp}"
        members = result.get("list")
    assert isinstance(members, list), f"getGroupMemberListFromServer result/list 不是 list: {resp}"

    user_ids: set[str] = set()
    for idx, item in enumerate(members):
        if isinstance(item, str):
            assert item, f"memberList[{idx}] 为空字符串: {resp}"
            user_ids.add(item)
            continue
        assert isinstance(item, dict), f"memberList[{idx}] 不是 str/dict: {item!r}"
        candidate = None
        for k in ("member", "userId", "username", "owner", "userName"):
            v = item.get(k)
            if isinstance(v, str) and v:
                candidate = v
                break
        assert candidate is not None, f"memberList[{idx}] 无可识别成员字段: {item!r}"
        user_ids.add(candidate)
    return user_ids



def test_group_get_group_member_list_from_server_success(device_a, assert_api, user_a, user_b):
    group_id = ""
    try:
        with _allure_step("测试准备：创建测试群并建立业务前置"):
            group_id, _ = create_group(
                device_a,
                assert_api,
                owner=user_a,
                group_name=new_group_name("member_list"),
                invite_members=[user_b],
            )
        with _allure_step("A 查询服务端成员列表"):
            resp = device_a.call(
                "GroupManager",
                Cmd.getGroupMemberListFromServer.value,
                info={"groupId": group_id, "pageNum": 1, "pageSize": 20},
            )
        with _allure_step("验证查询服务端成员列表返回的关键字段"):
            assert_api.assert_response_matches(
                resp,
                expected={
                    "manager": "GroupManager",
                    "cmd": Cmd.getGroupMemberListFromServer.value,
                    "device": "deviceA",
                },
                ignore_keys={"sequence", "result"},
            )
        user_ids = _extract_member_ids(resp.get("result"), resp=resp)
        with _allure_step("验证查询服务端成员列表返回的关键字段"):
            assert user_b in user_ids, f"成员列表未包含受邀成员: member={user_b}, resp={resp}"
        # 当前端语义：该接口返回成员列表（不包含群主）
        with _allure_step("验证查询服务端成员列表返回的关键字段"):
            assert user_a not in user_ids, f"成员列表不应包含群主: owner={user_a}, resp={resp}"
    finally:
        if group_id:
            with _allure_step("测试后置：销毁测试群并恢复群状态"):
                destroy_group(device_a, assert_api, group_id)
