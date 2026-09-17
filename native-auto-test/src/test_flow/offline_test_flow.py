"""离线业务 cases 共用的登录态编排。

这里只处理 Client 会话生命周期；好友、消息和事件业务断言必须留在对应模块 case 中。
"""
from __future__ import annotations

from src import Cmd
from src.tools.case_timing import pause, seconds, wait_until


def _current_user(device):
    """只读幂等探针；响应按请求 id 路由，不会消费离线事件队列。"""
    return device.call("Client", Cmd.getCurrentUser.value, info={}).get("result")


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


def logout_for_offline(device, assert_api, *, device_name: str, module: str) -> None:
    """清理陈旧事件后退出登录，同时保留当前 WebSocket 连接。"""
    device.drain_events(timeout=seconds('drain.offline', module=module))
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
    device.drain_events(timeout=seconds('drain.offline', module=module))
    wait_until(
        lambda: _current_user(device),
        lambda current: not (isinstance(current, str) and current),
        key='settle.offline', module=module,
        reason=f'{device_name} 退出后登录态未清空',
    )


def login_preserving_offline_events(
    device,
    assert_api,
    *,
    device_name: str,
    user_id: str,
    module: str,
    password: str = "1",
) -> None:
    """登录并启动回调；登录后的离线事件必须留在队列中供 case 断言。"""
    # 重登前保留固定等待：等的是服务端把对端离线期操作落库，本地没有只读探针。
    pause('settle.offline', module=module)
    response = device.call(
        "Client",
        Cmd.login.value,
        info={
            "userId": user_id,
            "pwdOrToken": password,
            "isPassword": True,
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
    wait_until(
        lambda: _current_user(device),
        lambda current: current == user_id,
        key='settle.offline', module=module,
        reason=f'{device_name} 重登后登录态未就绪',
    )


def restore_user_login(device, *, user_id: str, module: str, password: str = "1") -> None:
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
            device.call(
                "Client",
                Cmd.login.value,
                info={
                    "userId": user_id,
                    "pwdOrToken": password,
                    "isPassword": True,
                },
            )
        device.call("Client", Cmd.startCallback.value, info={})
        device.drain_events(timeout=seconds('drain.offline', module=module))
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

