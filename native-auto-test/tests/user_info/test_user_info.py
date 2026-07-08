"""
用户属性（UserInfoManager）模块用例：
- updateUserInfo（updateOwnUserInfo / updateOwnUserInfoWithType）：设置/修改当前用户自己的属性信息
- fetchUserInfoById（fetchUserInfoById / fetchUserInfoByIdWithType）：获取指定用户属性
- fetchOwnInfo：获取当前登录用户自己的属性信息
"""
from __future__ import annotations

import pytest

from src import Cmd


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
                "mail": "",
                "userId": user_a,
                "gender": 0,
            },
        },
        # 仅更新 nick/sign 时服务端返回的 gender 可能与首次设置不一致，不作为本步断言
        ignore_keys={"sequence", "ext", "avatarUrl", "phone", "birth"},
    )


def test_user_info_update_own_with_type_nickname(device_a, assert_api, user_a):
    """updateOwnUserInfoWithType：按类型更新昵称（0 = NICKNAME）。"""
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
            "result": '{"gender":"0","nickname":"nick-by-type","sign":"sign-mod"}',
        },
        ignore_keys={"sequence"},
    )


def test_user_info_update_then_fetch_user_info_by_id(device_a, assert_api, user_a):
    """先 updateOwnUserInfo，再用 fetchUserInfoById 拉当前用户（全量字段，与 fetchOwnInfo 语义等价）。"""
    device_a.call(
        "UserInfoManager",
        Cmd.updateOwnUserInfo.value,
        info={
            "nickName": "nick-then-bid",
            "sign": "sign-then-bid",
            "mail": "mail-then-bid@example.com",
        },
    )
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


def test_user_info_update_then_fetch_own_info(device_a, user_a):
    """fetchOwnInfo：当前原生通道未实现 direct cmd，MissingPlugin 记录为桥接缺口。"""
    device_a.call(
        "UserInfoManager",
        Cmd.updateOwnUserInfo.value,
        info={
            "nickName": "nick-own-info",
            "sign": "sign-own-info",
            "mail": "mail-own-info@example.com",
        },
    )
    resp = device_a.call(
        "UserInfoManager",
        Cmd.fetchOwnInfo.value,
        info={},
    )
    if resp.get("success") is False and "MissingPluginException" in str((resp.get("error") or {}).get("description", "")):
        pytest.xfail("fetchOwnInfo direct cmd 当前返回 MissingPluginException，记录为桥接缺口。")
    pytest.fail(f"fetchOwnInfo 已不再返回 MissingPluginException，需按真实返回重新修订 case: {resp!r}")


def test_user_info_update_then_fetch_user_info_by_id_with_type(device_a, assert_api, user_a):
    """先 updateOwnUserInfo，再用 fetchUserInfoByIdWithType 按类型拉取（仅 nick + sign；按类型返回时未必含 mail）。"""
    device_a.call(
        "UserInfoManager",
        Cmd.updateOwnUserInfo.value,
        info={
            "nickName": "nick-then-wit",
            "sign": "sign-then-wit",
            "mail": "mail-then-wit@example.com",
        },
    )
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
    resp = device_a.call(
        "UserInfoManager",
        Cmd.updateOwnUserInfo.value,
        info={"nickName": "n" * 2050},
    )
    assert_api.assert_error(resp, code=901, description="User info exceeds the data length")

def test_user_info_update_own_nickname_empty(device_a, assert_api, user_a):
    """updateOwnUserInfo：昵称为空"""
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
    user_ids = [f"uid_{i}" for i in range(101)]
    resp = device_a.call(
        "UserInfoManager",
        Cmd.fetchUserInfoById.value,
        info={"userIds": user_ids},
    )
    assert_api.assert_error(resp, code=900, description=" The maximum number of user IDs is exceeded.")
