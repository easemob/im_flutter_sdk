"""离线业务 cases 共用的登录态编排。

这里只处理 Client 会话生命周期；好友、消息和事件业务断言必须留在对应模块 case 中。
"""
from __future__ import annotations

from src import Cmd


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
    """供 finally 使用：尽力恢复指定用户登录，不覆盖 case 的原始异常。"""
    try:
        current_response = device.call("Client", Cmd.getCurrentUser.value, info={})
        current_user = current_response.get("result")
        if current_user != user_id:
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
            device.call(
                "Client",
                Cmd.login.value,
                info={
                    "userId": user_id,
                    "pwdOrToken": token,
                    "isPassword": False,
                },
            )
        device.call("Client", Cmd.startCallback.value, info={})
        device.drain_events(timeout=0.5)
    except Exception:
        pass


def set_accept_invitation_always(
    device,
    assert_api,
    *,
    device_name: str,
    enabled: bool,
) -> None:
    """显式设置好友邀请自动接受模式，避免 case 顺序影响离线邀请语义。"""
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

