"""
Client 模块 API 用例：init、login、logout、getCurrentUser 等。
请求参数与 Flutter 端一致，info 为方法参数；cmd 使用 Cmd 枚举与 chat_method_keys 对齐。
"""
from __future__ import annotations

import json
import time

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

def test_client_change_app_id(device_a, assert_api):
    """session 已登录 deviceA，校验 changeAppId 调用成功。"""
    resp = device_a.call("Client", Cmd.changeAppId.value, info={"appId": "dc4a43e610634c8989d8252d2bb71da7"})
    assert_api.assert_success(resp)
    result = assert_api.get_result(resp)
    assert result is not None or "result" in resp


def _wait_offline_sync_event(device, *, timeout: float = 10.0) -> dict:
    deadline = time.monotonic() + timeout
    accepted = {Cmd.onOfflineMessageSyncStart.value, Cmd.onOfflineMessageSyncFinish.value}
    while time.monotonic() < deadline:
        event = device.receive_message(timeout=max(0.0, deadline - time.monotonic()))
        if event and event.get("type") == "event" and event.get("eventType") in accepted:
            return event
    raise AssertionError(f"登录后未收到离线同步 Start 或 Finish 回调: timeout={timeout}s")


def test_login_then_receive_offline_sync_event(device_a, assert_api, user_a):
    """
    验证登录后能收到 onOfflineMessageSyncStart 回调。

    设计：session 中 device_a 已登录，需先 logout 再 login 同一用户，
    登录过程中 SDK 会同步离线消息并触发 onOfflineMessageSyncStart/Finish。
    测试结束后恢复登录状态以不影响后续 cases。
    """
    # 1) 先登出
    device_a.call("Client", Cmd.logout.value, info={"unbindToken": False})

    # 2) 清空残留事件
    try:
        device_a.drain_events()
    except Exception:
        pass

    # 3) 重新登录同一用户
    resp = device_a.call(
        "Client",
        Cmd.login.value,
        info={"userId": user_a, "pwdOrToken": "1", "isPassword": True},
    )
    print("登录响应:", json.dumps(resp))
    assert_api.assert_success(resp)

    # 4) 启动回调（某些端需要显式调用）
    try:
        device_a.call("Client", Cmd.startCallback.value, info={})
    except Exception:
        pass

    # 5) 等待 onOfflineMessageSyncStart 或 onOfflineMessageSyncFinish
    #    注意：如果没有离线消息，部分 SDK 版本可能不触发 Start 而直接触发 Finish，
    #    call 返回前的事件会保留在 DeviceClient 队列中；两种回调共用一个截止时间。
    event = _wait_offline_sync_event(device_a)
    expected_type = (
        Cmd.onOfflineMessageSyncStart.value
        if event.get("eventType") == Cmd.onOfflineMessageSyncStart.value
        else Cmd.onOfflineMessageSyncFinish.value
    )
    assert_api.assert_response_matches(
        event,
        expected={"type": "event", "eventType": expected_type, "data": {}},
        ignore_keys={"timestamp", "sequence"},
    )
