"""离线业务 cases 共用的登录态编排。

这里只处理 Client 会话生命周期；好友、消息和事件业务断言必须留在对应模块 case 中。
"""
from __future__ import annotations

import time

from src import Cmd


_RESTORE_CONNECT_TIMEOUT = 10.0
_RESTORE_CONNECT_POLL_INTERVAL = 0.25


def device_name(device) -> str:
    """Return the configured runner/device name without assuming a topology role."""
    return getattr(device, "device_name", None) or getattr(device, "_device", "device")


def unique_devices(devices) -> tuple:
    """Deduplicate topology endpoints while preserving topology order."""
    result = []
    for device in devices:
        if device is not None and not any(device is existing for existing in result):
            result.append(device)
    return tuple(result)


def logout_account_devices(devices, assert_api) -> None:
    """Log out every endpoint belonging to one account before an offline action."""
    for device in unique_devices(devices):
        logout_for_offline(device, assert_api, device_name=device_name(device))


def login_account_devices(devices, assert_api, *, user_id: str) -> None:
    """登录一个账号的全部 endpoint，并保留各 endpoint 的离线事件。"""
    for device in unique_devices(devices):
        login_preserving_offline_events(
            device,
            assert_api,
            device_name=device_name(device),
            user_id=user_id,
        )


def restore_account_devices(devices, *, user_id: str) -> None:
    """Best-effort restore of every endpoint belonging to one account."""
    for device in unique_devices(devices):
        restore_user_login(device, user_id=user_id)


def _assert_client_response(assert_api, response: dict, *, cmd: str,
                            device_name: str, result) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "Client",
            "cmd": cmd,
            "device": device_name,
            "result": result,
        },
        ignore_keys={"sequence"},
    )


def logout_for_offline(device, assert_api, *, device_name: str) -> None:
    """清理陈旧事件后退出登录，同时保留当前 WebSocket 连接。"""
    device.drain_events(timeout=0.5)
    response = device.call(
        "Client",
        Cmd.logout.value,
        info={"unbindToken": False},
    )
    _assert_client_response(
        assert_api,
        response,
        cmd=Cmd.logout.value,
        device_name=device_name,
        result=True,
    )
    device.drain_events(timeout=0.5)


def login_preserving_offline_events(
    device,
    assert_api,
    *,
    device_name: str,
    user_id: str,
    password: str = "1",
) -> None:
    """登录并启动回调；登录后的离线事件必须留在队列中供 case 断言。

    测试环境 5.0 服务端拒绝密码直登（202），统一先 REST 换 token 再登录。
    """
    from src.rest_api.user_api import fetch_user_token

    token = fetch_user_token(user_id, password).get("access_token", "")
    response = device.call(
        "Client",
        Cmd.login.value,
        info={
            "userId": user_id,
            "pwdOrToken": token,
            "isPassword": False,
        },
    )
    _assert_client_response(
        assert_api,
        response,
        cmd=Cmd.login.value,
        device_name=device_name,
        result=user_id,
    )
    callback = device.call("Client", Cmd.startCallback.value, info={})
    _assert_client_response(
        assert_api,
        callback,
        cmd=Cmd.startCallback.value,
        device_name=device_name,
        result=None,
    )


def restore_user_login(device, *, user_id: str, password: str = "1") -> None:
    """供 finally 使用：恢复指定用户并等待 SDK 异步连接完成。"""
    last_error: Exception | None = None
    deadline = time.monotonic() + _RESTORE_CONNECT_TIMEOUT
    for attempt in range(2):
        if time.monotonic() >= deadline:
            break
        try:
            current_response = device.call("Client", Cmd.getCurrentUser.value, info={})
            current_user = current_response.get("result")
            connected_response = device.call("Client", Cmd.isConnected.value, info={})
            connected = connected_response.get("result") is True

            # 正常路径不重复登录；只有用户不对或 SDK 已断开时才恢复登录。
            if current_user != user_id or not connected:
                if isinstance(current_user, str) and current_user:
                    try:
                        device.call(
                            "Client",
                            Cmd.logout.value,
                            info={"unbindToken": False},
                        )
                    except Exception:
                        pass
                from src.rest_api.user_api import fetch_user_token

                token = fetch_user_token(user_id, password).get("access_token", "")
                login_response = device.call(
                    "Client",
                    Cmd.login.value,
                    info={
                        "userId": user_id,
                        "pwdOrToken": token,
                        "isPassword": False,
                    },
                )
                if not login_response.get("result"):
                    raise RuntimeError(
                        f"restore login returned unsuccessful response: {login_response}"
                    )

            device.call("Client", Cmd.startCallback.value, info={})
            final_connected = None
            while time.monotonic() < deadline:
                final_connected = device.call("Client", Cmd.isConnected.value, info={})
                if final_connected.get("result") is True:
                    device.drain_events(timeout=0.5)
                    return
                time.sleep(
                    min(
                        _RESTORE_CONNECT_POLL_INTERVAL,
                        max(0.0, deadline - time.monotonic()),
                    )
                )
            raise RuntimeError(
                f"restore login did not restore SDK connection within "
                f"{_RESTORE_CONNECT_TIMEOUT:.1f}s: {final_connected}"
            )
        except Exception as error:
            last_error = error
            if attempt == 0 and time.monotonic() < deadline:
                time.sleep(min(0.5, max(0.0, deadline - time.monotonic())))

    raise RuntimeError(
        f"failed to restore offline test device login: device={device_name(device)}, "
        f"user={user_id}, error={last_error}"
    ) from last_error


def set_accept_invitation_always(
    device,
    assert_api,
    *,
    device_name: str,
    enabled: bool,
) -> None:
    """显式设置好友邀请自动接受模式，避免 case 顺序影响离线邀请语义。"""
    # Web 5.0 没有 Client.acceptInvitationAlways；Web 好友申请始终走
    # ContactManager.acceptInvitation，不能让这个移动端配置阻断离线 Case。
    runner_info = getattr(device, "runner_info", None) or {}
    if runner_info.get("platform") == "web":
        return

    response = device.call(
        "Client",
        Cmd.updateAcceptInvitationAlways.value,
        info={"acceptInvitationAlways": enabled},
    )
    _assert_client_response(
        assert_api,
        response,
        cmd=Cmd.updateAcceptInvitationAlways.value,
        device_name=device_name,
        result=None,
    )
