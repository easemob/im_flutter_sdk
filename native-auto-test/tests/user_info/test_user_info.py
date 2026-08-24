"""
用户属性（UserInfoManager）模块用例：
- updateUserInfo（updateOwnUserInfo / updateOwnUserInfoWithType）：设置/修改当前用户自己的属性信息
- fetchUserInfoById（fetchUserInfoById / fetchUserInfoByIdWithType）：获取指定用户属性
- fetchOwnInfo：获取当前登录用户自己的属性信息
"""
from __future__ import annotations

import json

import pytest

from src import Cmd
from tests.allure_helpers import _allure_step


pytestmark = [pytest.mark.client]

# assert_response_matches 的 expected 若写成 result: resp.get("result")，预期与 actual 在 result
# 上完全一致，无法发现「实际多出字段」。应对关心的字段写显式 dict（含 userId 等）。

# userInfoType / userInfoTypes 与原生 SDK 一致：0 NICKNAME, 1 AVATAR_URL, 2 EMAIL, 3 PHONE,
# 4 GENDER, 5 SIGN, 6 BIRTH, 100 EXT

# fetchUserInfoById* 返回 Map<userId, EMUserInfo>；仅校验 userId 时，其余 EMUserInfo 字段放入 ignore_keys
_USER_INFO_FETCH_BY_ID_IGNORE_KEYS = frozenset({
    "sequence",
    "ext",
    "avatarUrl",
    "phone",
    "birth",
    "nickName",
    "sign",
    "gender",
    "mail",
})

# 需在 result[userId] 中断言 nickName/sign/mail 时，勿把上述字段放入 ignore（否则会跳过值比对）
_USER_INFO_FETCH_BY_ID_STRICT_IGNORE_KEYS = frozenset({
    "sequence",
    "ext",
    "avatarUrl",
    "phone",
    "birth",
    "gender",
})

# updateOwnUserInfoWithType 需断言本次写入的 nickName，故不把 nickName 放入 ignore
_USER_INFO_UPDATE_WITH_TYPE_IGNORE_KEYS = frozenset({
    "sequence",
    "ext",
    "avatarUrl",
    "phone",
    "birth",
    "sign",
    "gender",
    "mail",
})

def test_user_info_update_own_set_and_modify(device_a, assert_api, user_a):
    """updateOwnUserInfo：先设置再修改当前用户属性。"""
    with _allure_step("设置当前用户昵称、签名和性别并验证结果"):
        resp_set = device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={"nickName": "nick-init", "sign": "sign-init", "gender": 1,"mail":"aa"},
        )
        assert_api.assert_response_matches(
            resp_set,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.updateOwnUserInfo.value,
                "device": "deviceA",
                "result": {
                    "nickName": "nick-init",
                    "sign": "sign-init",
                    "gender": 1,
                    "mail":"aa",
                    "userId": user_a,
                },
            },
            ignore_keys={"sequence", "ext", "avatarUrl", "phone", "birth", "gender"},
        )

    with _allure_step("修改当前用户昵称和签名并验证更新结果"):
        resp_modify = device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={"nickName": "nick-mod", "sign": "sign-mod"},
        )
        assert_api.assert_response_matches(
            resp_modify,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.updateOwnUserInfo.value,
                "device": "deviceA",
                "result": {
                    "nickName": "nick-mod",
                    "sign": "sign-mod",
                    "userId": user_a,
                },
            },
        # 仅更新 nick/sign 时服务端返回的 gender 可能与首次设置不一致，不作为本步断言
        ignore_keys={"sequence", "ext", "avatarUrl", "phone", "birth"},
    )

    # 更新接口返回对象在 Android/iOS 上的字段形态不同；最终资料必须通过查询结果验证。
    resp_fetch = device_a.call(
        "UserInfoManager",
        Cmd.fetchUserInfoById.value,
        info={"userIds": [user_a]},
    )
    assert_api.assert_response_matches(
        resp_fetch,
        expected={
            "manager": "UserInfoManager",
            "cmd": Cmd.fetchUserInfoById.value,
            "device": "deviceA",
            "result": {
                user_a: {
                    "userId": user_a,
                    "nickName": "nick-mod",
                    "sign": "sign-mod",
                    "mail": "aa",
                },
            },
        },
        ignore_keys=_USER_INFO_FETCH_BY_ID_STRICT_IGNORE_KEYS,
    )


def test_user_info_update_own_with_type_nickname(device_a, assert_api, user_a):
    """updateOwnUserInfoWithType：按类型更新昵称（0 = NICKNAME）。"""
    with _allure_step("按昵称类型更新当前用户昵称并验证结果"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfoWithType.value,
            info={"userInfoType": 0, "userInfoValue": "nick-by-type"},
        )

        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.updateOwnUserInfoWithType.value,
                "device": "deviceA",
            },
            # Android 原生返回的是当前完整用户资料 JSON 字符串；其中 mail、gender、sign
            # 可能来自前序用例状态，本 case 只负责验证昵称更新。
            ignore_keys={"sequence", "result"},
        )

        result = resp.get("result")
        assert isinstance(result, str), f"updateOwnUserInfoWithType.result 应为 JSON 字符串: {resp}"
        try:
            result_data = json.loads(result)
        except json.JSONDecodeError as exc:
            raise AssertionError(f"updateOwnUserInfoWithType.result 不是有效 JSON: {resp}") from exc
        assert result_data.get("nickname") == "nick-by-type", (
            f"updateOwnUserInfoWithType 未更新昵称: expected='nick-by-type', actual={result_data}"
        )


def test_user_info_update_then_fetch_user_info_by_id(device_a, assert_api, user_a):
    """先 updateOwnUserInfo，再用 fetchUserInfoById 拉当前用户（全量字段，与 fetchOwnInfo 语义等价）。"""
    with _allure_step("设置用于查询验证的用户资料"):
        device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={
                "nickName": "nick-then-bid",
                "sign": "sign-then-bid",
                "mail": "mail-then-bid@example.com",
            },
        )
    with _allure_step("按用户 ID 查询资料并验证全部字段"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoById.value,
            info={"userIds": [user_a]},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoById.value,
                "device": "deviceA",
                "result": {
                    user_a: {
                        "userId": user_a,
                        "nickName": "nick-then-bid",
                        "sign": "sign-then-bid",
                        "mail": "mail-then-bid@example.com",
                    },
                },
            },
            ignore_keys=_USER_INFO_FETCH_BY_ID_STRICT_IGNORE_KEYS,
        )


def test_user_info_update_then_fetch_own_info(device_a, assert_api, user_a):
    """fetchOwnInfo：更新当前用户属性后拉取自己的用户属性。"""
    with _allure_step("设置用于查询的当前用户资料"):
        device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={
                "nickName": "nick-own-info",
                "sign": "sign-own-info",
                "mail": "mail-own-info@example.com",
            },
        )
    with _allure_step("查询当前用户资料并验证属性"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.fetchOwnInfo.value,
            info={},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchOwnInfo.value,
                "device": "deviceA",
                "result": {
                    "userId": user_a,
                    "nickName": "nick-own-info",
                    "sign": "sign-own-info",
                    "mail": "mail-own-info@example.com",
                },
            },
            ignore_keys={"sequence", "gender", "avatarUrl", "phone", "birth", "ext"},
        )


def test_user_info_update_then_fetch_user_info_by_id_with_type(device_a, assert_api, user_a):
    """先 updateOwnUserInfo，再用 fetchUserInfoByIdWithType 按类型拉取（仅 nick + sign；按类型返回时未必含 mail）。"""
    with _allure_step("设置按类型查询所需的用户资料"):
        device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={
                "nickName": "nick-then-wit",
                "sign": "sign-then-wit",
                "mail": "mail-then-wit@example.com",
            },
        )
    with _allure_step("按资料类型查询用户并验证昵称和签名"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoByIdWithType.value,
            info={
                "userIds": [user_a],
                "userInfoTypes": [0, 5],
            },
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoByIdWithType.value,
                "device": "deviceA",
                "result": {
                    user_a: {
                        "userId": user_a,
                        "nickName": "nick-then-wit",
                        "sign": "sign-then-wit",
                    },
                },
            },
            ignore_keys=_USER_INFO_FETCH_BY_ID_STRICT_IGNORE_KEYS
            | frozenset({"mail"}),
        )


def test_user_info_update_then_all_fetch_paths_in_one_flow(device_a, assert_api, user_a):
    """一次更新后：先 fetchUserInfoById（全量），再 fetchUserInfoByIdWithType（nick+sign），字段一致。"""
    with _allure_step("设置统一的用户资料用于多接口查询"):
        device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={
                "nickName": "nick-flow-all",
                "sign": "sign-flow-all",
                "mail": "mail-flow-all@example.com",
            },
        )
    expected_full = {
        "userId": user_a,
        "nickName": "nick-flow-all",
        "sign": "sign-flow-all",
        "mail": "mail-flow-all@example.com",
    }
    expected_partial = {
        "userId": user_a,
        "nickName": "nick-flow-all",
        "sign": "sign-flow-all",
    }
    with _allure_step("按用户 ID 查询全量资料并验证字段"):
        r_bid = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoById.value,
            info={"userIds": [user_a]},
        )
        assert_api.assert_response_matches(
            r_bid,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoById.value,
                "device": "deviceA",
                "result": {user_a: expected_full},
            },
            ignore_keys=_USER_INFO_FETCH_BY_ID_STRICT_IGNORE_KEYS,
        )
    with _allure_step("按资料类型查询并验证部分字段一致"):
        r_wit = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoByIdWithType.value,
            info={"userIds": [user_a], "userInfoTypes": [0, 5]},
        )
        assert_api.assert_response_matches(
            r_wit,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoByIdWithType.value,
                "device": "deviceA",
                "result": {user_a: expected_partial},
            },
            ignore_keys=_USER_INFO_FETCH_BY_ID_STRICT_IGNORE_KEYS
            | frozenset({"mail"}),
        )


def test_user_info_update_own_nickname_length_over_64(device_a, assert_api):
    """updateOwnUserInfo：昵称超过 2k长度，预期失败。"""
    with _allure_step("提交超长昵称并验证长度错误"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={"nickName": "n" * 2050},
        )
        assert_api.assert_error(resp, code=901, description="User info exceeds the data length")

def test_user_info_update_own_nickname_empty(device_a, assert_api, user_a):
    """updateOwnUserInfo：昵称为空"""
    with _allure_step("提交空昵称并验证空值处理结果"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.updateOwnUserInfo.value,
            info={"nickName": ""},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.updateOwnUserInfo.value,
                "device": "deviceA",
                "result": {
                    "userId": user_a,
                },
            },
            ignore_keys=_USER_INFO_UPDATE_WITH_TYPE_IGNORE_KEYS | frozenset({"nickName"}),
        )


def test_user_info_fetch_by_id_normal(device_a, assert_api, user_a, user_b):
    """fetchUserInfoById：获取指定用户（当前用户与另一用户）的属性。"""
    with _allure_step("查询两个用户的资料并验证用户标识"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoById.value,
            info={"userIds": [user_a, user_b]},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoById.value,
                "device": "deviceA",
                "result": {
                    user_a: {"userId": user_a},
                    user_b: {"userId": user_b},
                },
            },
            ignore_keys=_USER_INFO_FETCH_BY_ID_IGNORE_KEYS,
        )


def test_user_info_fetch_by_id_with_type_normal(device_a, assert_api, user_a, user_b):
    """fetchUserInfoByIdWithType：按属性类型拉取指定用户（nick + sign）。"""
    with _allure_step("按昵称和签名类型查询用户资料"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoByIdWithType.value,
            info={
                "userIds": [user_a, user_b],
                "userInfoTypes": [0, 5],
            },
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoByIdWithType.value,
                "device": "deviceA",
                "result": {
                    user_a: {"userId": user_a},
                    user_b: {"userId": user_b},
                },
            },
            ignore_keys=_USER_INFO_FETCH_BY_ID_IGNORE_KEYS,
        )


def test_user_info_fetch_by_id_empty_user_ids(device_a, assert_api):
    """fetchUserInfoById：userIds 为空列表。"""
    with _allure_step("使用空用户列表查询资料并验证参数错误"):
        resp = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoById.value,
            info={"userIds": []},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "UserInfoManager",
                "cmd": Cmd.fetchUserInfoById.value,
                "device": "deviceA",
                "result": {"code": 205, "description": "userIds is empty"}
            },
            ignore_keys={"sequence"},
        )


def test_user_info_fetch_by_id_user_ids_over_100(device_a, assert_api):
    """fetchUserInfoById：userIds 超过 100 个，预期失败。"""
    with _allure_step("使用超过上限的用户列表查询资料并验证数量错误"):
        user_ids = [f"uid_{i}" for i in range(101)]
        resp = device_a.call(
            "UserInfoManager",
            Cmd.fetchUserInfoById.value,
            info={"userIds": user_ids},
        )
        assert_api.assert_error(resp, code=900, description=" The maximum number of user IDs is exceeded.")
