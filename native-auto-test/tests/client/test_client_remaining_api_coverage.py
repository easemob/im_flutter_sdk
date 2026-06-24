"""
Client 剩余 API 覆盖用例。

本文件优先补充不会破坏当前 session 登录态的查询类和配置类方法。
所有预期返回值先通过 discovery 从真实模拟器响应确认，再在严格模式下冻结。
"""
from __future__ import annotations

import pytest

from src import Cmd


pytestmark = [pytest.mark.client]


def test_client_connection_state_queries(device_a, assert_api):
    """isConnected / isLoggedInBefore：已登录 session 下查询连接态和历史登录态，均应返回 true。"""
    connected_resp = device_a.call("Client", Cmd.isConnected.value, info={})
    assert_api.assert_response_matches(
        connected_resp,
        expected={
            "manager": "Client",
            "cmd": Cmd.isConnected.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )

    login_before_resp = device_a.call("Client", Cmd.isLoggedInBefore.value, info={})
    assert_api.assert_response_matches(
        login_before_resp,
        expected={
            "manager": "Client",
            "cmd": Cmd.isLoggedInBefore.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_client_current_token_and_device_id(device_a, assert_api):
    """getToken / getCurrentDeviceId：已登录 session 下获取 token 和当前设备信息，校验关键字段非空。"""
    token_resp = device_a.call("Client", Cmd.getToken.value, info={})
    assert_api.assert_response_matches(
        token_resp,
        expected={
            "manager": "Client",
            "cmd": Cmd.getToken.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    assert isinstance(token_resp.get("result"), str)
    assert token_resp["result"], "getToken 应返回非空 token 字符串"

    device_id_resp = device_a.call("Client", Cmd.getCurrentDeviceId.value, info={})
    assert_api.assert_response_matches(
        device_id_resp,
        expected={
            "manager": "Client",
            "cmd": Cmd.getCurrentDeviceId.value,
            "device": "deviceA",
            "result": {"resource": "", "deviceName": ""},
        },
        ignore_keys={"sequence", "deviceUUID"},
    )
    device_info = device_id_resp.get("result")
    assert isinstance(device_info, dict)
    assert isinstance(device_info.get("deviceUUID"), str)
    assert device_info["deviceUUID"], "getCurrentDeviceId 应返回非空 deviceUUID"


def test_client_compress_logs_returns_path(device_a, assert_api):
    """compressLogs：压缩本地日志，校验返回压缩文件路径字符串。"""
    resp = device_a.call("Client", Cmd.compressLogs.value, info={})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "Client",
            "cmd": Cmd.compressLogs.value,
            "device": "deviceA",
        },
        ignore_keys={"sequence", "result"},
    )
    assert isinstance(resp.get("result"), str)
    assert resp["result"], "compressLogs 应返回非空路径字符串"


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
        (Cmd.updateRequireAckSetting.value, {"requireAck": True}),
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
    resp = device_a.call("Client", cmd, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "Client",
            "cmd": cmd,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.parametrize(
    ("cmd", "info", "expected_result"),
    [
        # renewToken：空 token 边界，不改变当前密码登录态。
        (
            Cmd.renewToken.value,
            {"agora_token": ""},
            {"code": 104, "description": "New token is invalid"},
        ),
        # changeAppKey：已登录状态下修改 appKey 的非法状态边界。
        (
            Cmd.changeAppKey.value,
            {"appKey": ""},
            {"code": 110, "description": "appkey is null or empty"},
        ),
        # getLoggedInDevicesFromServer/fetchLoggedInDevices：错误账号密码边界。
        (
            Cmd.getLoggedInDevicesFromServer.value,
            {"userId": "__invalid_user__", "password": "__invalid_pwd__", "isPwd": True},
            {"code": 204, "description": "User does not exist"},
        ),
        # kickDevice：错误账号密码与空 resource 边界，不影响当前设备。
        (
            Cmd.kickDevice.value,
            {
                "userId": "__invalid_user__",
                "password": "__invalid_pwd__",
                "resource": "",
                "isPwd": True,
            },
            {"code": 205, "description": "Invalid parameter"},
        ),
        # kickAllDevices：错误账号密码边界，不影响当前设备。
        (
            Cmd.kickAllDevices.value,
            {"userId": "__invalid_user__", "password": "__invalid_pwd__", "isPwd": True},
            {"code": 204, "description": "User does not exist"},
        ),
    ],
)
def test_client_session_sensitive_api_boundaries(device_a, assert_api, cmd, info, expected_result):
    """renew/changeAppKey/device-kick 类方法：使用不会破坏当前 session 的边界入参冻结真实错误返回。"""
    resp = device_a.call("Client", cmd, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "Client",
            "cmd": cmd,
            "device": "deviceA",
            "result": expected_result,
        },
        ignore_keys={"sequence"},
    )
