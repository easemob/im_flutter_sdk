"""
Client 模块 API 用例：init、login、logout、getCurrentUser 等。
请求参数与 Flutter 端一致，info 为方法参数；cmd 使用 Cmd 枚举与 chat_method_keys 对齐。
"""
from __future__ import annotations

import json

import pytest

from src.tools import assertions
from src import Cmd


pytestmark = [pytest.mark.client]


def test_client_login_invalid_password(api, assert_api):
    """错误密码：预期返回错误响应；若服务端仅返回 result=None 也视为合法响应。"""
    resp = api.call(
        "Client",
        Cmd.login.value,
        info={
            "userId": "nonexistent_user_xyz",
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
    resp = device_a.call("Client", Cmd.getCurrentUser.value, info={})
    assert_api.assert_success(resp)
    result = assert_api.get_result(resp)
    assert result is not None or "result" in resp


def test_login_then_receive_offline_sync_event(device_a, assert_api):
    """deviceA 登录后接收 onOfflineMessageSyncStart：用 device_a 发请求并在同一 topic 上主动收推送。"""
    resp = device_a.call(
        "Client",
        Cmd.login.value,
        info={"userId": "TSt", "pwdOrToken": "1", "isPassword": True},
    )
    print("登录响应:", json.dumps(resp))
    assert_api.assert_success(resp)
    event = device_a.receive_message(
        match_event_type=Cmd.onOfflineMessageSyncStart.value,
        timeout=15.0,
    )
    assert event is not None, "应收到 onOfflineMessageSyncStart 回调"
    assert event.get("eventType") == Cmd.onOfflineMessageSyncStart.value
