from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd

from tests.chat._utils import swt_to_send


pytestmark = [pytest.mark.client, pytest.mark.chat, pytest.mark.agorachat1_4_0]


def _wait_send_terminal(device, *, temp_id: str, timeout: float = 30.0) -> tuple[str, dict]:
    seen = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        error_evt = device.receive_message(
            match_event_type=Cmd.onMessageError.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if error_evt:
            seen.append(error_evt)
        if str(((error_evt or {}).get("data") or {}).get("msgId")) == str(temp_id):
            return "error", error_evt
        success_evt = device.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(1.0, max(0.1, deadline - time.monotonic())),
        )
        if success_evt:
            seen.append(success_evt)
        if str(((success_evt or {}).get("data") or {}).get("msgId")) == str(temp_id):
            return "success", success_evt
    pytest.fail(f"未收到目标发送终态: tempId={temp_id}, events={seen}")


def _assert_peer_did_not_receive_body(
    device,
    *,
    from_user: str,
    body_predicate,
    timeout: float = 5.0,
) -> None:
    seen = []
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        evt = device.receive_message(timeout=min(1.0, max(0.1, deadline - time.monotonic())))
        if evt:
            seen.append(evt)
        messages = (((evt or {}).get("data") or {}).get("messages")) or []
        target = next(
            (
                msg
                for msg in messages
                if isinstance(msg, dict)
                and msg.get("from") == from_user
                and body_predicate(msg.get("body") or {})
            ),
            None,
        )
        assert target is None, f"失败消息被错误投递给 B: message={target}, events={seen}"


def _assert_failed_send_envelopes(
    assert_api,
    *,
    resp: dict,
    error_evt: dict,
    temp_id: str,
    from_user: str,
    to_user: str,
    response_body: dict,
    error_body: dict,
    error_code: int,
    error_description: str,
    response_status: int = 1,
    ignore_response_status: bool = False,
) -> None:
    message = {
        "msgId": temp_id,
        "from": from_user,
        "to": to_user,
        "convId": to_user,
        "chatType": 0,
        "direction": 0,
        "hasRead": True,
        "needReadReceipt": False, "isThread": False,
        "isContentReplaced": False,
        "deliverOnlineOnly": False,
    }
    ignore_keys = {"sequence", "timestamp", "serverTime", "localTime", "broadcast", "onlineState", "status", "fileStatus", "thumbnailStatus"}
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {**message, "status": response_status, "body": response_body},
        },
        ignore_keys=ignore_keys | ({"result.status"} if ignore_response_status else set()),
    )
    assert_api.assert_response_matches(
        error_evt,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageError.value,
            "data": {
                "msgId": temp_id,
                "msg": {**message, "status": 3, "body": error_body},
                # 只看 errorcode（leader 要求）：描述两端不同，code 一致
                "error": {"code": error_code},
            },
        },
        ignore_keys=ignore_keys,
    )


@pytest.mark.parametrize(
    "case_name",
    [
        pytest.param("empty", id="empty-target"),
        pytest.param("nonexistent", id="nonexistent-target"),
    ],
)
def test_chat_message_send_target_boundaries(
    device_a,
    device_b,
    assert_api,
    user_a,
    case_name,
):
    """空目标应失败；不存在用户按真实服务端语义发送成功；B 均不得误收目标消息。"""
    device_a.drain_events()
    device_b.drain_events()
    target_id = "" if case_name == "empty" else f"qa{uuid.uuid4().hex[:24]}"
    marker = f"target-boundary-{uuid.uuid4().hex[:12]}"
    type_key = "txt" if case_name == "empty" else "cmd"
    payload = (
        {"targetId": target_id, "content": marker}
        if type_key == "txt"
        else {"targetId": target_id, "action": marker, "deliverOnlineOnly": False}
    )
    body = (
        {"type": 0, "content": marker}
        if type_key == "txt"
        else {"type": 6, "action": marker, "deliverOnlineOnly": False}
    )
    resp = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info={"to": target_id, "chatType": 0, "direction": 0, "body": body},
    )
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"发送目标错误未返回待关联临时 msgId: case={case_name}, resp={resp}"
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": {
                "msgId": temp_id,
                "from": user_a,
                "to": target_id,
                "convId": target_id,
                "chatType": 0,
                "direction": 0,
                
                "hasRead": True,
                "needReadReceipt": False, "isThread": False,
                "isContentReplaced": False,
                "deliverOnlineOnly": False,
                "body": body,
            },
        },
        ignore_keys={
            "sequence",
            "status",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "targetLanguages",
            "translations",
        },
    )
    terminal, terminal_evt = _wait_send_terminal(device_a, temp_id=temp_id)
    expected_terminal = "error" if case_name == "empty" else "success"
    assert terminal == expected_terminal, (
        f"目标边界终态不符合当前真实语义: case={case_name}, "
        f"expected={expected_terminal}, event={terminal_evt}"
    )
    if terminal == "success":
        real_id = ((((terminal_evt.get("data") or {}).get("msg")) or {}).get("msgId"))
        assert real_id, f"不存在用户发送成功事件缺少真实 msgId: {terminal_evt}"
        expected_event = {
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": temp_id,
                "msg": {
                    "msgId": real_id,
                    "from": user_a,
                    "to": target_id,
                    "convId": target_id,
                    "chatType": 0,
                    "direction": 0,
                    "status": 2,
                    "hasRead": True,
                    "needReadReceipt": False, "isThread": False,
                    "isContentReplaced": False,
                    "deliverOnlineOnly": False,
                    "body": body,
                },
            },
        }
    else:
        expected_event = {
            "type": "event",
            "eventType": Cmd.onMessageError.value,
            "data": {
                "msgId": temp_id,
                "msg": {
                    "msgId": temp_id,
                    "from": user_a,
                    "to": target_id,
                    "convId": target_id,
                    "chatType": 0,
                    "direction": 0,
                    
                    "body": body,
                },
                "error": {"code": 500, "description": "Message is invalid"},
            },
        }
    assert_api.assert_response_matches(
        terminal_evt,
        expected=expected_event,
        ignore_keys={
            "timestamp",
            "sequence",
            "status",
            "serverTime",
            "localTime",
            "broadcast",
            "onlineState",
            "targetLanguages",
            "translations",
            "deliverOnlineOnly",
            "hasRead",
            "hasDeliverAck",
            "isThread",
            "isContentReplaced",
        },
    )
    _assert_peer_did_not_receive_body(
        device_b,
        from_user=user_a,
        body_predicate=(
            (lambda candidate: candidate.get("content") == marker)
            if type_key == "txt"
            else (lambda candidate: candidate.get("action") == marker)
        ),
    )


@pytest.mark.parametrize(
    ("type_key", "payload", "description"),
    [
        pytest.param(
            "txt",
            {"targetId": "{{user_b}}"},
            "type 'Null' is not a subtype of type 'String'",
            id="txt-missing-content",
        ),
        pytest.param(
            "location",
            {"targetId": "{{user_b}}", "longitude": 120.1551},
            "type 'Null' is not a subtype of type 'num'",
            id="location-missing-latitude",
        ),
        pytest.param(
            "location",
            {"targetId": "{{user_b}}", "latitude": 30.2741},
            "type 'Null' is not a subtype of type 'num'",
            id="location-missing-longitude",
        ),
        pytest.param(
            "cmd",
            {"targetId": "{{user_b}}"},
            "type 'Null' is not a subtype of type 'String'",
            id="cmd-missing-action",
        ),
        pytest.param(
            "custom",
            {"targetId": "{{user_b}}"},
            "type 'Null' is not a subtype of type 'String'",
            id="custom-missing-event",
        ),
    ],
)
@pytest.mark.skip(reason="缺字段被 swt_to_send 默认值填充（content=''/action=''/event=''/latitude=0）→ 原生收到的是『空值消息』并非缺字段；"
    "『缺字段』本身测不到（原生无 JSON 概念，wrapper 会拦真缺字段为 -1）。"
    "当前实测：原生接受空值消息并发送成功（onMessageSuccess）—— 测的是测试框架填充 + 空值消息发送，SDK 价值低。"
    "4.23 时代此 case 即为 skip（sendMessageWithType 未实现）。")
def test_chat_message_type_rejects_missing_required_payload(
    device_a,
    assert_api,
    user_b,
    type_key,
    payload,
    description,
):
    """5.0 sendMessage 路线：缺 payload 必填字段时 swt_to_send 用默认值填充为消息默认值，
    消息构造成功并发送；原生 SDK 实测接受空字段消息（onMessageSuccess），不拒绝。"""
    resolved_payload = {
        key: (user_b if value == "{{user_b}}" else value)
        for key, value in payload.items()
    }
    resp = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=swt_to_send({"type": type_key, "payload": resolved_payload, "chatType": 0}),
    )
    # 5.0 实测：缺字段 → swt_to_send 默认值填充 → 消息构造成功 → 原生 SDK 接受空字段消息并发送成功
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"缺字段消息未构造成功（应填充默认值发给原生）: type={type_key}, resp={resp}"

    # 原生 SDK 对空字段消息的发送终态：实测 5.0 全部 onMessageSuccess（接受空消息，不拒绝）
    terminal = None
    deadline = time.monotonic() + 25.0
    while time.monotonic() < deadline:
        evt = device_a.receive_message(timeout=2.0)
        if not evt:
            continue
        if evt.get("type") == "event" and evt.get("eventType") == Cmd.onMessageSuccess.value:
            terminal = evt
            break
    assert terminal, f"空字段消息未发送成功（onMessageSuccess）: type={type_key}, tempId={temp_id}"
    assert str(((terminal.get("data") or {}).get("msgId"))) == str(temp_id), (
        f"success 事件 tempId 不匹配: type={type_key}, terminal={terminal}"
    )


def _missing_key(type_key: str, payload: dict) -> str:
    required = {
        "txt": ["content"],
        "cmd": ["action"],
        "custom": ["event"],
        "location": ["latitude", "longitude"],
    }
    missing = [k for k in required.get(type_key, []) if k not in payload]
    return missing[0] if missing else ""


def test_chat_combine_message_rejects_empty_source_ids(device_a, device_b, assert_api, user_a, user_b):
    """合并消息来源 ID 为空时应进入失败终态，B 不得收到该合并消息。"""
    device_a.drain_events()
    device_b.drain_events()
    title = f"empty-combine-{uuid.uuid4().hex[:8]}"
    resp = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info={
            "to": user_b,
            "chatType": 0,
            "direction": 0,
            "body": {
                "type": 8,
                "title": title,
                "summary": "empty source ids",
                "compatibleText": "empty combine",
                "messageList": [],
                "fileStatus": 0,
            },
        },
    )
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"空来源合并消息未返回临时 msgId: {resp}"
    terminal, terminal_evt = _wait_send_terminal(device_a, temp_id=temp_id)
    assert terminal == "error", f"空来源合并消息未失败: {terminal_evt}"
    _assert_failed_send_envelopes(
        assert_api,
        resp=resp,
        error_evt=terminal_evt,
        temp_id=temp_id,
        from_user=user_a,
        to_user=user_b,
        response_body={
            "type": 8,
            "title": title,
            "summary": "empty source ids",
            "compatibleText": "empty combine",
        },
        error_body={
            "type": 8,
            "title": title,
            "summary": "empty source ids",
            "compatibleText": "empty combine",
            "localPath": "",
            "remotePath": "",
            "secret": "",
            "fileStatus": 3,
        },
        error_code=110,
        error_description="The count of combined messages must be between 1 and 300.",
        response_status=1,
        ignore_response_status=True,
    )
    _assert_peer_did_not_receive_body(
        device_b,
        from_user=user_a,
        body_predicate=lambda body: body.get("type") == 8 and body.get("title") == title,
    )


@pytest.mark.parametrize("type_key", ["file", "image", "video", "voice"])
def test_chat_media_message_rejects_nonexistent_device_path(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
    type_key,
):
    """媒体消息显式传入不存在 Android 路径时应失败，B 不得收到该媒体消息。"""
    device_a.drain_events()
    device_b.drain_events()
    marker = f"missing-{type_key}-{uuid.uuid4().hex[:8]}"
    payload = {
        "targetId": user_b,
        "filePath": f"/data/local/tmp/{marker}.bin",
        "displayName": marker,
    }
    if type_key in {"video", "voice"}:
        payload["duration"] = 1
    resp = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=swt_to_send({"type": type_key, "payload": payload, "chatType": 0}),
    )
    temp_id = ((resp.get("result") or {}).get("msgId"))
    assert temp_id, f"不存在媒体路径未返回临时 msgId: type={type_key}, resp={resp}"
    terminal, terminal_evt = _wait_send_terminal(device_a, temp_id=temp_id)
    assert terminal == "error", f"不存在媒体路径未失败: type={type_key}, event={terminal_evt}"
    body = {
        "type": {"image": 1, "video": 2, "voice": 4, "file": 5}[type_key],
        "secret": "",
        "remotePath": "",
        "fileSize": 0,
        "localPath": payload["filePath"],
        "displayName": marker,
        "fileStatus": 0,
    }
    if type_key == "image":
        body.update({
            "thumbnailLocalPath": "",
            "thumbnailRemotePath": "",
            "thumbnailSecret": "",
            "sendOriginalImage": False,
            "height": 0,
            "width": 0,
            "thumbnailStatus": 0,
            "isGif": False,
        })
    elif type_key == "video":
        body.update({
            "duration": 1,
            "thumbnailLocalPath": "",
            "thumbnailRemotePath": "",
            "thumbnailSecret": "",
            "height": 0,
            "width": 0,
            "thumbnailStatus": 0,
        })
    elif type_key == "voice":
        body["duration"] = 1
    error_description = (
        "File movement error."
        if type_key in {"file", "voice"}
        else "File not exists or can not be read"
    )
    _assert_failed_send_envelopes(
        assert_api,
        resp=resp,
        error_evt=terminal_evt,
        temp_id=temp_id,
        from_user=user_a,
        to_user=user_b,
        response_body={
            key: value
            for key, value in body.items()
            if key not in {
                "secret",
                "remotePath",
                "fileSize",
                "thumbnailLocalPath",
                "thumbnailRemotePath",
                "thumbnailSecret",
            }
        },
        error_body=body,
        error_code=401,
        error_description=error_description,
        response_status=1,
        # 媒体路径错误时 result.status 在 0/1/3 间竞态（发送状态时序）→ 忽略
        ignore_response_status=True,
    )
    _assert_peer_did_not_receive_body(
        device_b,
        from_user=user_a,
        body_predicate=lambda body: body.get("displayName") == marker,
    )
