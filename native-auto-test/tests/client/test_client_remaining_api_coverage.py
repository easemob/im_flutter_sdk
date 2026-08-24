"""
Client 剩余 API 覆盖用例。

本文件优先补充不会破坏当前 session 登录态的查询类和配置类方法。
所有预期返回值先通过 discovery 从真实模拟器响应确认，再在严格模式下冻结。
"""
from __future__ import annotations

import pytest

from src import Cmd
from src.tools.config import get_sdk_app_key
from tests.allure_helpers import _allure_step


pytestmark = [pytest.mark.client]


def test_client_connection_state_queries(device_a, assert_api):
    """isConnected / isLoggedInBefore：已登录 session 下查询连接态和历史登录态，均应返回 true。"""
    with _allure_step("查询连接状态并验证当前连接正常"):
        connected_resp = device_a.call("Client", Cmd.isConnected.value, info={})
        assert_api.assert_response_matches(
            connected_resp,
            expected={
                "manager": "Client",
                "cmd": Cmd.isConnected.value,
                "device": device_a.device_name,
                "result": True,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("查询历史登录状态并验证登录记录存在"):
        login_before_resp = device_a.call("Client", Cmd.isLoggedInBefore.value, info={})
        assert_api.assert_response_matches(
            login_before_resp,
            expected={
                "manager": "Client",
                "cmd": Cmd.isLoggedInBefore.value,
                "device": device_a.device_name,
                "result": True,
            },
            ignore_keys={"sequence"},
        )


def test_client_init_repeated_call_idempotent(device_a, assert_api):
    """init：SDK 已初始化后重复调用，验证原生幂等返回 result=null，不改变当前登录态。"""
    with _allure_step("重复初始化客户端并验证幂等返回"):
        app_key = get_sdk_app_key()
        assert app_key, "config.yaml sdk_options.app_key 不能为空"
        resp = device_a.call(
            "Client",
            Cmd.init.value,
            info={"appKey": app_key, "debugModel": True},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "Client",
                "cmd": Cmd.init.value,
                "device": device_a.device_name,
                "result": None,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("验证重复初始化未清空当前登录用户"):
        current_user_resp = device_a.call("Client", Cmd.getCurrentUser.value, info={})
        assert_api.assert_response_matches(
            current_user_resp,
            expected={
                "manager": "Client",
                "cmd": Cmd.getCurrentUser.value,
                "device": device_a.device_name,
            },
            ignore_keys={"sequence", "result"},
        )
        assert current_user_resp.get("result"), "重复 init 后当前登录用户不应被清空"


def test_client_current_token_and_device_id(device_a, assert_api):
    """getToken / getCurrentDeviceId：已登录 session 下获取 token 和当前设备信息，校验关键字段非空。"""
    with _allure_step("读取当前登录令牌并验证非空"):
        token_resp = device_a.call("Client", Cmd.getToken.value, info={})
        assert_api.assert_response_matches(
            token_resp,
            expected={
                "manager": "Client",
                "cmd": Cmd.getToken.value,
                "device": device_a.device_name,
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(token_resp.get("result"), str)
        assert token_resp["result"], "getToken 应返回非空 token 字符串"

    with _allure_step("读取当前设备信息并验证返回结构非空"):
        device_id_resp = device_a.call("Client", Cmd.getCurrentDeviceId.value, info={})
        assert_api.assert_response_matches(
            device_id_resp,
            expected={
                "manager": "Client",
                "cmd": Cmd.getCurrentDeviceId.value,
                "device": device_a.device_name,
            },
            ignore_keys={"sequence", "resource", "deviceName", "deviceUUID", "hid", "os", "os-version"},
        )
        device_info = device_id_resp.get("result")
        assert isinstance(device_info, dict)
        assert device_info, "getCurrentDeviceId 应返回非空设备信息"


def test_client_compress_logs_returns_path(device_a, assert_api):
    """compressLogs：压缩本地日志，校验返回压缩文件路径字符串。"""
    with _allure_step("压缩客户端日志并验证返回文件路径"):
        resp = device_a.call("Client", Cmd.compressLogs.value, info={})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "Client",
                "cmd": Cmd.compressLogs.value,
                "device": device_a.device_name,
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(resp.get("result"), str)
        assert resp["result"], "compressLogs 应返回非空路径字符串"


@pytest.mark.skip(reason="5.0 移除客户端 createAccount（残留，注册走 REST）")
def test_client_create_account_empty_user_boundary(device_a, assert_api):
    """createAccount：空 userId/password 边界，冻结真实模拟器参数校验错误，不创建新账号。"""
    with _allure_step("使用空账号参数创建账号并验证参数错误"):
        resp = device_a.call(
            "Client",
            Cmd.createAccount.value,
            info={"userId": "", "password": ""},
        )
        assert_api.assert_error(resp, code=205, description="illegal user name")


@pytest.mark.parametrize(
    ("cmd", "info"),
    [
        (Cmd.updateUsingHttpsOnlySetting.value, {"usingHttpsOnly": False}),
        (Cmd.updateLoginExtensionInfo.value, {"extension": "client-api-coverage"}),
        (
            Cmd.updateDeleteMessagesWhenLeaveGroupSetting.value,
            {"deleteMessagesWhenLeaveGroup": True},
        ),
        (
            Cmd.updateDeleteMessageWhenLeaveRoomSetting.value,
            {"deleteMessageWhenLeaveRoom": True},
        ),
        (Cmd.updateRoomOwnerCanLeaveSetting.value, {"roomOwnerCanLeave": True}),
        (
            Cmd.updateAutoAcceptGroupInvitationSetting.value,
            {"autoAcceptGroupInvitation": True},
        ),
        (Cmd.updateAcceptInvitationAlways.value, {"acceptInvitationAlways": True}),
        (
            Cmd.updateAutoDownloadAttachmentThumbnailSetting.value,
            {"autoDownloadThumbnail": True},
        ),
        (Cmd.updateDeliveryAckSetting.value, {"requireDeliveryAck": True}),
        (
            Cmd.updateSortMessageByServerTimeSetting.value,
            {"sortMessageByServerTime": True},
        ),
        (
            Cmd.updateMessagesReceiveCallbackIncludeSendSetting.value,
            {"includeSend": True},
        ),
        (Cmd.updateRegradeMessagesSetting.value, {"isRead": True}),
    ],
)
def test_client_update_runtime_setting_success(device_a, assert_api, cmd, info):
    """update*Setting：逐项更新运行时配置，冻结真实模拟器返回 result=null 的成功语义。"""
    with _allure_step("更新客户端运行时配置并验证设置成功"):
        resp = device_a.call("Client", cmd, info=info)
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "Client",
                "cmd": cmd,
                "device": device_a.device_name,
                "result": None,
            },
            ignore_keys={"sequence"},
        )


@pytest.mark.parametrize(
    ("cmd", "info", "expected_result"),
    [
        # renewToken：空 token 边界；Android/iOS 文案大小写和标点不同，只断言 code。
        (
            Cmd.renewToken.value,
            {"agora_token": ""},
            {"code": 104},
        ),
        # changeAppKey：已登录状态下修改 appKey 的非法状态边界。
        (
            Cmd.changeAppKey.value,
            {"appKey": ""},
            {"code": 110},
        ),
        # getLoggedInDevicesFromServer/fetchLoggedInDevices：无效 token 边界。
        (
            Cmd.getLoggedInDevicesFromServer.value,
            {"userId": "__invalid_user__", "token": "__invalid_token__"},
            {"code": 204, "description": "User does not exist"},
        ),
        # kickDevice：错误账号/token 与空 resource 边界，不影响当前设备。
        (
            Cmd.kickDevice.value,
            {
                "userId": "__invalid_user__",
                "token": "__invalid_token__",
                "resource": "",
            },
            {"code": 205, "description": "Invalid parameter"},
        ),
        # kickAllDevices：无效 token 边界，不影响当前设备。
        (
            Cmd.kickAllDevices.value,
            {"userId": "__invalid_user__", "token": "__invalid_token__"},
            {"code": 204, "description": "User does not exist"},
        ),
        # loginWithAgoraToken：非法账号与空 token 边界，不应切换当前密码登录态。
        (
            Cmd.loginWithAgoraToken.value,
            {"userId": "__invalid_user__", "agora_token": ""},
            {"code": 110, "description": "username or token is null or empty!"},
        ),
    ],
)
def test_client_session_sensitive_api_boundaries(device_a, assert_api, cmd, info, expected_result):
    """renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回。"""
    with _allure_step("执行会话敏感接口边界参数并验证错误语义"):
        resp = device_a.call("Client", cmd, info=info)
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "Client",
                "cmd": cmd,
                "device": device_a.device_name,
                "result": expected_result,
            },
            ignore_keys={"sequence"},
        )
