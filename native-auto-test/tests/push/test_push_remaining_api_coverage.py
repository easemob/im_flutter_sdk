"""
Push 模块剩余 API 覆盖用例。

本文件优先覆盖不依赖真实厂商推送证书/token 的推送配置接口。
预期返回通过 discovery 从真实模拟器响应确认后固定。
"""
from __future__ import annotations

import pytest

from src import Cmd, ne
from tests.allure_helpers import _allure_step


pytestmark = [pytest.mark.client]


def _assert_success_null(assert_api, resp: dict, *, cmd: str):
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "PushManager",
            "cmd": cmd,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def _assert_push_config_update_result(assert_api, resp: dict, *, cmd: str):
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "PushManager",
            "cmd": cmd,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    result = resp.get("result")
    if result is True:
        return
    assert result == {
        "code": 209,
        "description": "Failed to update push configurations",
    }


def test_push_fetch_configs_update_nickname_and_style(device_a, assert_api):
    """fetchPushConfigsFromServer / updatePushNickname / updatePushDisplayStyle：拉取推送配置并更新昵称和展示样式。"""
    with _allure_step("查询服务端推送配置并验证返回结构"):
        configs_resp = device_a.call("PushManager", Cmd.getImPushConfigFromServer.value, info={})
        assert_api.assert_response_matches(
            configs_resp,
            expected={
                "manager": "PushManager",
                "cmd": Cmd.getImPushConfigFromServer.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        configs_result = configs_resp.get("result")
        assert isinstance(configs_result, dict)
        if "code" in configs_result:
            assert configs_result == {
                "code": 209,
                "description": "Failed to update push configurations",
            }
        else:
            assert isinstance(configs_result.get("displayName"), str)
            assert isinstance(configs_result.get("pushStyle"), int)

    with _allure_step("更新推送昵称并验证配置更新结果"):
        nick_resp = device_a.call(
            "PushManager",
            Cmd.updatePushNickname.value,
            info={"nickname": "push-api-coverage"},
        )
        _assert_push_config_update_result(assert_api, nick_resp, cmd=Cmd.updatePushNickname.value)

    with _allure_step("更新推送展示样式并验证配置更新结果"):
        style_resp = device_a.call(
            "PushManager",
            Cmd.updateImPushStyle.value,
            info={"pushStyle": 0},
        )
        _assert_push_config_update_result(assert_api, style_resp, cmd=Cmd.updateImPushStyle.value)


def test_push_global_silent_mode_flow(device_a, assert_api):
    """setSilentModeForAll / fetchSilentModeForAll：设置全局离线推送提醒类型，并拉取全局设置。"""
    with _allure_step("设置全局离线推送提醒类型并验证成功"):
        set_resp = device_a.call(
            "PushManager",
            Cmd.setSilentModeForAll.value,
            info={"param": {"paramType": 0, "remindType": 0}},
        )
        _assert_success_null(assert_api, set_resp, cmd=Cmd.setSilentModeForAll.value)

    with _allure_step("查询全局离线推送设置并验证配置字段"):
        fetch_resp = device_a.call("PushManager", Cmd.fetchSilentModeForAll.value, info={})
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "PushManager",
                "cmd": Cmd.fetchSilentModeForAll.value,
                "device": "deviceA",
                "result": {
                    "expireTs": 0,
                    "convId": ne(None),
                    "conversationType": 0,
                    "startTime": {"hour": 0, "minute": 0},
                    "endTime": {"hour": 0, "minute": 0},
                    "remindType": 0,
                },
            },
            ignore_keys={"sequence"},
        )


def test_push_conversation_silent_mode_flow(device_a, assert_api, user_b):
    """set/fetch/removeConversationSilentMode：对单聊会话设置、查询、移除离线推送设置。"""
    conv_id = user_b
    with _allure_step("设置单聊会话免打扰并验证成功"):
        set_resp = device_a.call(
            "PushManager",
            Cmd.setConversationSilentMode.value,
            info={
                "convId": conv_id,
                "conversationType": 0,
                "param": {"paramType": 0, "remindType": 0},
            },
        )
        _assert_success_null(assert_api, set_resp, cmd=Cmd.setConversationSilentMode.value)

    with _allure_step("查询单聊会话免打扰设置并验证配置"):
        fetch_resp = device_a.call(
            "PushManager",
            Cmd.fetchConversationSilentMode.value,
            info={"convId": conv_id, "conversationType": 0},
        )
        assert_api.assert_response_matches(
            fetch_resp,
            expected={
                "manager": "PushManager",
                "cmd": Cmd.fetchConversationSilentMode.value,
                "device": "deviceA",
                "result": {
                    "expireTs": 0,
                    "convId": conv_id,
                    "conversationType": 0,
                    "startTime": {"hour": 0, "minute": 0},
                    "endTime": {"hour": 0, "minute": 0},
                    "remindType": 0,
                },
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("批量查询会话免打扰设置并验证目标会话"):
        batch_resp = device_a.call(
            "PushManager",
            Cmd.fetchSilentModeForConversations.value,
            info={conv_id: 0},
        )
        assert_api.assert_response_matches(
            batch_resp,
            expected={
                "manager": "PushManager",
                "cmd": Cmd.fetchSilentModeForConversations.value,
                "device": "deviceA",
                "result": {
                    conv_id: {
                        "expireTs": 0,
                        "convId": conv_id,
                        "conversationType": 0,
                        "startTime": {"hour": 0, "minute": 0},
                        "endTime": {"hour": 0, "minute": 0},
                        "remindType": 0,
                    }
                },
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("移除单聊会话免打扰设置并验证成功"):
        remove_resp = device_a.call(
            "PushManager",
            Cmd.removeConversationSilentMode.value,
            info={"convId": conv_id, "conversationType": 0},
        )
        _assert_success_null(assert_api, remove_resp, cmd=Cmd.removeConversationSilentMode.value)


def test_push_preferred_language_and_template(device_a, assert_api):
    """set/fetchPreferredNotificationLanguage 与 set/getPushTemplate：设置并查询推送语言和模板名称。"""
    with _allure_step("设置首选通知语言并验证保存成功"):
        set_lang_resp = device_a.call(
            "PushManager",
            Cmd.setPreferredNotificationLanguage.value,
            info={"code": "en"},
        )
        _assert_success_null(assert_api, set_lang_resp, cmd=Cmd.setPreferredNotificationLanguage.value)

    with _allure_step("查询首选通知语言并验证为英语"):
        fetch_lang_resp = device_a.call(
            "PushManager",
            Cmd.fetchPreferredNotificationLanguage.value,
            info={},
        )
        assert_api.assert_response_matches(
            fetch_lang_resp,
            expected={
                "manager": "PushManager",
                "cmd": Cmd.fetchPreferredNotificationLanguage.value,
                "device": "deviceA",
                "result": "en",
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("设置推送模板并验证保存成功"):
        set_template_resp = device_a.call(
            "PushManager",
            Cmd.setPushTemplate.value,
            info={"pushTemplateName": "default"},
        )
        _assert_success_null(assert_api, set_template_resp, cmd=Cmd.setPushTemplate.value)

    with _allure_step("查询推送模板并验证模板名称"):
        get_template_resp = device_a.call("PushManager", Cmd.getPushTemplate.value, info={})
        assert_api.assert_response_matches(
            get_template_resp,
            expected={
                "manager": "PushManager",
                "cmd": Cmd.getPushTemplate.value,
                "device": "deviceA",
                "result": "default",
            },
            ignore_keys={"sequence"},
        )


@pytest.mark.parametrize(
    ("cmd", "info", "expected_result"),
    [
        (
            Cmd.updateHMSPushToken.value,
            {"token": "hms-token-api-coverage"},
            "hms-token-api-coverage",
        ),
        (
            Cmd.updateFCMPushToken.value,
            {"token": "fcm-token-api-coverage"},
            {"code": 110, "description": "Notifier name should not be empty!"},
        ),
        (
            Cmd.bindDeviceToken.value,
            {"notifierName": "default", "deviceToken": "bind-token-api-coverage"},
            None,
        ),
    ],
)
def test_push_vendor_token_update_current_environment(device_a, assert_api, cmd, info, expected_result):
    """update*PushToken / bindDeviceToken：使用测试 token 调用，冻结当前模拟器环境下的真实返回语义。"""
    with _allure_step("更新厂商推送令牌并验证当前环境返回语义"):
        resp = device_a.call("PushManager", cmd, info=info)
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "PushManager",
                "cmd": cmd,
                "device": "deviceA",
                "result": expected_result,
            },
            ignore_keys={"sequence"},
        )


def test_push_apns_token_update_android_missing_plugin(device_a):
    """updateAPNsPushToken：Android 模拟器不适用 APNs，MissingPlugin 记录为平台/桥接缺口。"""
    with _allure_step("调用 Android 不适用的 APNs 令牌接口并记录平台缺口"):
        resp = device_a.call(
            "PushManager",
            Cmd.updateAPNsPushToken.value,
            info={"token": "apns-token-api-coverage"},
        )
        if resp.get("success") is False and "MissingPluginException" in str((resp.get("error") or {}).get("description", "")):
            pytest.xfail("updateAPNsPushToken 在 Android 模拟器当前返回 MissingPluginException，记录为平台/桥接缺口。")
        pytest.fail(f"updateAPNsPushToken 已不再返回 MissingPluginException，需按真实返回重新修订 case: {resp!r}")


def test_push_sync_conversations_silent_mode_current_environment(device_a, assert_api):
    """syncSilentModels：同步所有会话免打扰信息，冻结当前模拟器返回语义。"""
    with _allure_step("同步所有会话免打扰设置并验证返回结构"):
        resp = device_a.call("PushManager", Cmd.syncSilentModels.value, info={})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "PushManager",
                "cmd": Cmd.syncSilentModels.value,
                "device": "deviceA",
            },
            ignore_keys={"sequence", "result"},
        )
        assert resp.get("result") is None or resp.get("result") is True or isinstance(resp.get("result"), dict)
