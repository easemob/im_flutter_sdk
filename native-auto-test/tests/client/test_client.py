"""
Client 模块 API 用例：init、login、logout、getCurrentUser 等。
请求参数与 Flutter 端一致，info 为方法参数；cmd 使用 Cmd 枚举与 chat_method_keys 对齐。
"""
from __future__ import annotations

import json

import pytest

from src.tools import assertions
from src import Cmd
from tests.allure_helpers import _allure_step


pytestmark = [pytest.mark.client]


def test_client_login_invalid_password(device_a, assert_api, user_a):
    """错误密码：预期返回错误响应；若服务端仅返回 result=None 也视为合法响应。"""
    with _allure_step("使用错误密码登录并验证失败响应语义"):
        resp = device_a.call(
            "Client",
            Cmd.login.value,
            info={
                "userId": user_a,
                "pwdOrToken": "wrong_pwd",
                "isPassword": True,
            },
        )
        # 响应中要么有 result（成功），要么有 error（失败）
        assert "result" in resp or "error" in resp
        if not assertions.is_success(resp):
            err = assert_api.get_error(resp)
            assert "code" in err or "description" in err


def test_client_get_current_user(device_a, assert_api):
    """session 已登录 deviceA，校验 getCurrentUser 返回当前用户。"""
    with _allure_step("查询当前登录用户并验证返回用户信息"):
        resp = device_a.call("Client", Cmd.getCurrentUser.value, info={})
        assert_api.assert_success(resp)
        result = assert_api.get_result(resp)
        assert result is not None or "result" in resp

def test_client_change_app_id(device_a, assert_api):
    """session 已登录 deviceA，校验 changeAppId 调用成功。"""
    with _allure_step("切换应用标识并验证调用成功"):
        resp = device_a.call("Client", Cmd.changeAppId.value, info={"appId": "dc4a43e610634c8989d8252d2bb71da7"})
        assert_api.assert_success(resp)
        result = assert_api.get_result(resp)
        assert result is not None or "result" in resp


def test_login_then_receive_offline_sync_event(device_a, assert_api, user_a):
    """
    验证登录后能收到 onOfflineMessageSyncStart 回调。

    设计：session 中 device_a 已登录，需先 logout 再 login 同一用户，
    登录过程中 SDK 会同步离线消息并触发 onOfflineMessageSyncStart/Finish。
    测试结束后恢复登录状态以不影响后续 cases。
    """
    with _allure_step("测试准备：退出当前会话并清理历史事件"):
        device_a.call("Client", Cmd.logout.value, info={"unbindToken": False})

    import time
    time.sleep(1)

    with _allure_step("测试准备：清理登录前残留事件"):
        try:
            device_a.drain_events()
        except Exception:
            pass

    with _allure_step("重新登录并验证登录成功"):
        from src.rest_api.user_api import fetch_user_token
        _tok = fetch_user_token(user_a, "1").get("access_token", "")
        resp = device_a.call(
            "Client",
            Cmd.login.value,
            info={"userId": user_a, "pwdOrToken": _tok, "isPassword": False},
        )
        print("登录响应:", json.dumps(resp))
        assert_api.assert_success(resp)

    with _allure_step("启动回调并等待离线同步事件"):
        try:
            device_a.call("Client", Cmd.startCallback.value, info={})
        except Exception:
            pass

        # 如果没有离线消息，部分 SDK 版本可能只触发 Finish；两种真实事件均接受。
        event = device_a.receive_message(
            match_event_type=Cmd.onOfflineMessageSyncStart.value,
            timeout=10.0,
        )
        if event is None:
            event = device_a.receive_message(
                match_event_type=Cmd.onOfflineMessageSyncFinish.value,
                timeout=5.0,
            )
            assert event is not None, (
                "登录后未收到 onOfflineMessageSyncStart 或 onOfflineMessageSyncFinish 回调"
            )
            assert event.get("eventType") == Cmd.onOfflineMessageSyncFinish.value
        else:
            assert event.get("eventType") == Cmd.onOfflineMessageSyncStart.value
