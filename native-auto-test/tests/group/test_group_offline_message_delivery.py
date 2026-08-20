"""群聊消息在 SDK logout/login 窗口内的离线投递与最终状态。"""
from __future__ import annotations

import os
import time
import uuid

import pytest
from tests.group.allure_helpers import _allure_step

from src import Cmd, gt
from tests.group.group_helpers import create_group, new_group_name
from tests.chat._utils import swt_to_send
from tests.group.group_offline_helpers import (
    assert_call_result,
    device_name,
    login_group_account_devices,
    logout_group_account_devices,
    restore_group_users,
    safe_destroy_group,
)


pytestmark = [
    pytest.mark.client,
    pytest.mark.group,
    pytest.mark.agorachat1_4_0,
    pytest.mark.topology("account_a_to_account_b"),
]


_TEXT_DYNAMIC_KEYS = {
    "timestamp",
    "sequence",
    "serverTime",
    "localTime",
    "broadcast",
    "onlineState",
    "targetLanguages",
    "translations",
}


def _drain_devices(*devices) -> None:
    for device in devices:
        device.drain_events(timeout=0.5)


def _message(
    *,
    msg_id: str,
    from_user: str,
    group_id: str,
    direction: int,
    status: int,
    has_read: bool,
    content: str,
    need_read_receipt: bool = False,
) -> dict:
    return {
        "msgId": msg_id,
        "from": from_user,
        "to": group_id,
        "convId": group_id,
        "chatType": 1,
        "direction": direction,
        "status": status,
        "hasRead": has_read,
        # 5.0：hasReadAck/needGroupAck 无此字段；hasDeliverAck 未设 flag 恒 False
        "hasDeliverAck": False,
        "needReadReceipt": need_read_receipt,
        "isThread": False,
        "isContentReplaced": False,
        "deliverOnlineOnly": False,
        "body": {"type": 0, "content": content},
    }


def _wait_success(device, *, temp_id: str, timeout: float = 60.0) -> dict:
    deadline = time.monotonic() + timeout
    seen: list[dict] = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessageSuccess.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        if str(((event or {}).get("data") or {}).get("msgId")) == str(temp_id):
            return event
    raise AssertionError(
        f"未收到目标 onMessageSuccess: tempId={temp_id}, events={seen}"
    )


def _wait_message_event(
    device,
    event_type: str,
    *,
    real_id: str,
    timeout: float = 60.0,
) -> dict:
    deadline = time.monotonic() + timeout
    seen: list[dict] = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=event_type,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        messages = (((event or {}).get("data") or {}).get("messages")) or []
        if any(
            isinstance(message, dict)
            and str(message.get("msgId")) == str(real_id)
            for message in messages
        ):
            return event
    raise AssertionError(
        f"未收到目标 {event_type}: msgId={real_id}, events={seen}"
    )


def _wait_recall_info(device, *, real_id: str, timeout: float = 60.0) -> dict:
    deadline = time.monotonic() + timeout
    seen: list[dict] = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessagesRecalledInfo.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        infos = (((event or {}).get("data") or {}).get("infos")) or []
        if any(
            isinstance(info, dict)
            and str(info.get("recallMsgId")) == str(real_id)
            for info in infos
        ):
            return event
    raise AssertionError(
        f"未收到目标 onMessagesRecalledInfo: msgId={real_id}, events={seen}"
    )


def _wait_message_absent(device, *, real_id: str, timeout: float = 5.0) -> dict:
    """撤回事件到达后，等待本地消息删除完成；超时仍保留最后响应供断言报错。"""
    deadline = time.monotonic() + timeout
    last_response = None
    while time.monotonic() < deadline:
        last_response = device.call(
            "ChatManager",
            Cmd.getMessage.value,
            info={"msgId": real_id},
        )
        result = last_response.get("result")
        if result is None or result == {}:
            return last_response
        time.sleep(0.5)
    return last_response or {
        "manager": "ChatManager",
        "cmd": Cmd.getMessage.value,
        "device": device_name(device),
        "result": None,
    }


def _wait_content_changed(device, *, real_id: str, timeout: float = 60.0) -> dict:
    deadline = time.monotonic() + timeout
    seen: list[dict] = []
    while time.monotonic() < deadline:
        event = device.receive_message(
            match_event_type=Cmd.onMessageContentChanged.value,
            timeout=min(2.0, max(0.1, deadline - time.monotonic())),
        )
        if event:
            seen.append(event)
        message = ((event or {}).get("data") or {}).get("message") or {}
        if str(message.get("msgId")) == str(real_id):
            return event
    raise AssertionError(
        f"未收到目标 onMessageContentChanged: msgId={real_id}, events={seen}"
    )


def _send_text(
    device_a,
    assert_api,
    *,
    user_a: str,
    group_id: str,
    content: str,
) -> str:
    response = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=swt_to_send({
            "type": "txt",
            "payload": {"targetId": group_id, "content": content},
            "chatType": 1,
        }),
    )
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert isinstance(temp_id, str) and temp_id, (
        f"群文本发送响应缺少临时 msgId: {response}"
    )
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.sendMessage.value,
            "device": "deviceA",
            "result": _message(
                msg_id=temp_id,
                from_user=user_a,
                group_id=group_id,
                direction=0,
                status=1,
                has_read=True,
                content=content,
            ),
        },
        # 5.0 发送响应 status 属响应时刻快照（不锁，事件锁 2）
        ignore_keys=_TEXT_DYNAMIC_KEYS | {"result.status"},
    )
    success = _wait_success(device_a, temp_id=temp_id)
    success_message = ((success.get("data") or {}).get("msg")) or {}
    real_id = success_message.get("msgId")
    assert isinstance(real_id, str) and real_id, (
        f"群文本成功事件缺少真实 msgId: {success}"
    )
    assert_api.assert_response_matches(
        success,
        expected={
            "type": "event",
            "eventType": Cmd.onMessageSuccess.value,
            "data": {
                "msgId": temp_id,
                "msg": _message(
                    msg_id=real_id,
                    from_user=user_a,
                    group_id=group_id,
                    direction=0,
                    status=2,
                    has_read=True,
                    content=content,
                ),
            },
        },
        ignore_keys=_TEXT_DYNAMIC_KEYS,
    )
    return real_id


def _assert_received_texts(
    assert_api,
    event: dict,
    *,
    user_a: str,
    group_id: str,
    messages: list[tuple[str, str]],
    need_read_receipt: bool = False,
) -> None:
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": Cmd.onMessagesReceived.value,
            "data": {
                "messages": [
                    _message(
                        msg_id=real_id,
                        from_user=user_a,
                        group_id=group_id,
                        direction=1,
                        status=2,
                        has_read=False,
                        content=content,
                        need_read_receipt=need_read_receipt,
                    )
                    for real_id, content in messages
                ]
            },
        },
        ignore_keys=_TEXT_DYNAMIC_KEYS,
    )


def _create_message_group(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    name_prefix: str,
    sender_devices=(),
    recipient_devices=(),
) -> tuple[str, str]:
    sender_devices = tuple(sender_devices) or (device_a,)
    recipient_devices = tuple(recipient_devices) or (device_b,)
    _drain_devices(*sender_devices, *recipient_devices)
    group_name = new_group_name(name_prefix)
    group_id, _ = create_group(
        device_a,
        assert_api,
        owner=user_a,
        group_name=group_name,
        invite_members=[user_b],
    )
    time.sleep(float(os.getenv("GROUP_MESSAGE_MEMBER_SETTLE_SECONDS", "5")))
    _drain_devices(*sender_devices, *recipient_devices)
    return group_id, group_name


def _restore_message_case(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    group_id: str,
    sender_devices=(),
    recipient_devices=(),
) -> None:
    restore_group_users(
        device_a,
        device_b,
        assert_api,
        user_a=user_a,
        user_b=user_b,
        sender_devices=sender_devices,
        recipient_devices=recipient_devices,
    )
    safe_destroy_group(device_a, group_id)



def test_group_offline_text_message_received_after_login(
    topology,
    assert_api,
):
    """B 离线时 A 发群文本；B 重登收到同一真实 msgId 和群会话正文。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    content = f"group-offline-text-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_message_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_text",
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("执行群消息动作并验证发送/接收链路"):
            real_id = _send_text(
                device_a,
                assert_api,
                user_a=user_a,
                group_id=group_id,
                content=content,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("等待并关联目标业务事件"):
                received = _wait_message_event(
                    endpoint,
                    Cmd.onMessagesReceived.value,
                    real_id=real_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_received_texts(
                    assert_api,
                    received,
                    user_a=user_a,
                    group_id=group_id,
                    messages=[(real_id, content)],
                )
    finally:
        _restore_message_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_multiple_text_messages_and_conversation_state(
    topology,
    assert_api,
):
    """B 离线积压三条群文本；重登验证完整集合、未读数 3 和最新消息。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    contents = [
        f"group-offline-batch-{index}-{uuid.uuid4().hex[:6]}"
        for index in range(3)
    ]
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_message_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_batch",
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("执行群消息动作并验证发送/接收链路"):
            sent = [
                (
                    _send_text(
                        device_a,
                        assert_api,
                        user_a=user_a,
                        group_id=group_id,
                        content=content,
                    ),
                    content,
                )
                for content in contents
            ]
        expected_by_id = dict(sent)
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)

        for endpoint in recipient_devices:
            deadline = time.monotonic() + 60.0
            seen_ids: set[str] = set()
            raw_events: list[dict] = []
            while seen_ids != set(expected_by_id) and time.monotonic() < deadline:
                event = endpoint.receive_message(
                    match_event_type=Cmd.onMessagesReceived.value,
                    timeout=min(2.0, max(0.1, deadline - time.monotonic())),
                )
                if not event:
                    continue
                event_messages = (((event.get("data") or {}).get("messages")) or [])
                target_ids = [
                    str(message.get("msgId"))
                    for message in event_messages
                    if isinstance(message, dict)
                    and str(message.get("msgId")) in expected_by_id
                ]
                if not target_ids:
                    continue
                with _allure_step("验证本用例的关键业务结果"):
                    assert len(target_ids) == len(event_messages), (
                        f"离线群文本事件混入非目标消息: event={event}"
                    )
                ordered = [(msg_id, expected_by_id[msg_id]) for msg_id in target_ids]
                with _allure_step("验证群业务状态、事件与关键字段"):
                    _assert_received_texts(
                        assert_api,
                        event,
                        user_a=user_a,
                        group_id=group_id,
                        messages=ordered,
                    )
                raw_events.append(event)
                seen_ids.update(target_ids)
            with _allure_step("验证本用例的关键业务结果"):
                assert seen_ids == set(expected_by_id), (
                    f"{device_name(endpoint)} 未收到全部离线群文本: expected={set(expected_by_id)}, "
                    f"actual={seen_ids}, events={raw_events}"
                )

        latest_id, latest_content = sent[-1]
        latest_message = _message(
            msg_id=latest_id,
            from_user=user_a,
            group_id=group_id,
            direction=1,
            status=2,
            has_read=False,
            content=latest_content,
        )
        latest_message.pop("deliverOnlineOnly")
        for endpoint in recipient_devices:
            with _allure_step("动作端 执行本用例业务操作"):
                unread = endpoint.call(
                    "ConversationManager",
                    Cmd.getUnreadMsgCount.value,
                    info={"convId": group_id, "type": 1},
                )
            with _allure_step("验证执行本用例业务操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    unread,
                    manager="ConversationManager",
                    cmd=Cmd.getUnreadMsgCount.value,
                    device_name=device_name(endpoint),
                    result=3,
                )
            with _allure_step("动作端 执行本用例业务操作"):
                latest = endpoint.call(
                    "ConversationManager",
                    Cmd.getLatestMessage.value,
                    info={"convId": group_id, "type": 1},
                )
            with _allure_step("验证执行本用例业务操作返回的响应 result 与关键字段"):
                assert_api.assert_response_matches(
                    latest,
                    expected={
                        "manager": "ConversationManager",
                        "cmd": Cmd.getLatestMessage.value,
                        "device": device_name(endpoint),
                        "result": latest_message,
                    },
                    ignore_keys=_TEXT_DYNAMIC_KEYS,
                )
    finally:
        _restore_message_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_cmd_deliver_online_only_not_received_after_login(
    topology,
    assert_api,
):
    """B 离线时群 CMD 设置 deliverOnlineOnly=true；重登无旧事件且本地无消息。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    action = f"group-online-only-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_message_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_online_only",
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 发送群消息"):
            response = device_a.call(
                "ChatManager",
                Cmd.sendMessage.value,
                info=swt_to_send({
                    "type": "cmd",
                    "payload": {
                        "targetId": group_id,
                        "action": action,
                        "deliverOnlineOnly": True,
                    },
                    "chatType": 1,
                }),
            )
        temp_id = ((response.get("result") or {}).get("msgId"))
        with _allure_step("验证发送群消息返回的关键字段"):
            assert isinstance(temp_id, str) and temp_id, (
                f"群 online-only CMD 缺少临时 msgId: {response}"
            )
        cmd_message = {
            "msgId": temp_id,
            "from": user_a,
            "to": group_id,
            "convId": group_id,
            "chatType": 1,
            "direction": 0,
            "status": 1,
            "hasRead": True,
            # 5.0：hasReadAck/needGroupAck 无；hasDeliverAck 未设 flag 恒 False
            "hasDeliverAck": False,
            "needReadReceipt": False,
            "isThread": False,
            "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 6, "action": action, "deliverOnlineOnly": True},
        }
        with _allure_step("验证发送群消息返回的关键字段"):
            assert_api.assert_response_matches(
                response,
                expected={
                    "manager": "ChatManager",
                    "cmd": Cmd.sendMessage.value,
                    "device": device_name(device_a),
                    "result": cmd_message,
                },
                # 5.0 发送响应 status 属响应时刻快照（不锁，事件锁 2）
                ignore_keys=_TEXT_DYNAMIC_KEYS | {"result.status"},
            )
        with _allure_step("等待并关联目标业务事件"):
            success = _wait_success(device_a, temp_id=temp_id)
        success_message = ((success.get("data") or {}).get("msg")) or {}
        real_id = success_message.get("msgId")
        with _allure_step("验证发送群消息返回的关键字段"):
            assert isinstance(real_id, str) and real_id, (
                f"群 online-only CMD 缺少真实 msgId: {success}"
            )
        with _allure_step("验证发送群消息返回的关键字段"):
            assert_api.assert_response_matches(
                success,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessageSuccess.value,
                    "data": {
                        "msgId": temp_id,
                        "msg": {**cmd_message, "msgId": real_id, "status": 2},
                    },
                },
                ignore_keys=_TEXT_DYNAMIC_KEYS,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            deadline = time.monotonic() + 5.0
            seen_target: list[dict] = []
            while time.monotonic() < deadline:
                event = endpoint.receive_message(
                    match_event_type=Cmd.onCmdMessagesReceived.value,
                    timeout=min(1.0, max(0.1, deadline - time.monotonic())),
                )
                messages = (((event or {}).get("data") or {}).get("messages")) or []
                if any(
                    isinstance(message, dict)
                    and str(message.get("msgId")) == str(real_id)
                    for message in messages
                ):
                    seen_target.append(event)
            with _allure_step("验证发送群消息返回的关键字段"):
                assert seen_target == [], (
                    f"{device_name(endpoint)} deliverOnlineOnly 群 CMD 不应离线投递: {seen_target}"
                )
            with _allure_step("等待本地撤回消息删除完成"):
                local = _wait_message_absent(endpoint, real_id=real_id)
            with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    local,
                    manager="ChatManager",
                    cmd=Cmd.getMessage.value,
                    device_name=device_name(endpoint),
                    result=None,
                )
    finally:
        _restore_message_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_sender_reads_ack_count_after_relogin(
    topology,
    assert_api,
):
    """B 收到群消息后在 A 离线期间发送 read ACK；A 重登最终查询 count=1。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    content = f"group-offline-ack-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_message_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_ack",
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("A 发送群消息"):
            response = device_a.call(
                "ChatManager",
                Cmd.sendMessage.value,
                info={
                    "from": user_a,
                    "to": group_id,
                    "chatType": 1,
                    "direction": 0,
                    "body": {"type": 0, "content": content},
                    "needReadReceipt": True,
                    "isThread": False,
                    "deliverOnlineOnly": False,
                },
            )
        temp_id = ((response.get("result") or {}).get("msgId"))
        with _allure_step("验证发送群消息返回的关键字段"):
            assert isinstance(temp_id, str) and temp_id, (
                f"群 ACK 消息发送响应缺少临时 msgId: {response}"
            )
        ack_response_message = _message(
            msg_id=temp_id,
            from_user=user_a,
            group_id=group_id,
            direction=0,
            status=0,
            has_read=True,
            content=content,
            need_read_receipt=True,
        )
        ack_response_message.pop("deliverOnlineOnly")
        with _allure_step("验证发送群消息返回的关键字段"):
            assert_api.assert_response_matches(
                response,
                expected={
                    "manager": "ChatManager",
                    "cmd": Cmd.sendMessage.value,
                    "device": device_name(device_a),
                    "result": ack_response_message,
                },
                # 5.0 发送响应 status 属响应时刻快照（不锁，事件锁 2）
                ignore_keys=_TEXT_DYNAMIC_KEYS | {"result.status"},
            )
        with _allure_step("等待并关联目标业务事件"):
            success = _wait_success(device_a, temp_id=temp_id)
        real_id = (((success.get("data") or {}).get("msg")) or {}).get("msgId")
        with _allure_step("验证发送群消息返回的关键字段"):
            assert isinstance(real_id, str) and real_id, (
                f"群 ACK 消息成功事件缺少真实 msgId: {success}"
            )
        with _allure_step("验证发送群消息返回的关键字段"):
            assert_api.assert_response_matches(
                success,
                expected={
                    "type": "event",
                    "eventType": Cmd.onMessageSuccess.value,
                    "data": {
                        "msgId": temp_id,
                        "msg": _message(
                            msg_id=real_id,
                            from_user=user_a,
                            group_id=group_id,
                            direction=0,
                            status=2,
                            has_read=True,
                            content=content,
                            need_read_receipt=True,
                        ),
                    },
                },
                ignore_keys=_TEXT_DYNAMIC_KEYS,
            )
        for endpoint in recipient_devices:
            with _allure_step("等待并关联目标业务事件"):
                received = _wait_message_event(
                    endpoint,
                    Cmd.onMessagesReceived.value,
                    real_id=real_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_received_texts(
                    assert_api,
                    received,
                    user_a=user_a,
                    group_id=group_id,
                    messages=[(real_id, content)],
                    need_read_receipt=True,
                )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(sender_devices, assert_api)
        with _allure_step("B 发送群已读回执"):
            ack = device_b.call(
                "ChatManager",
                Cmd.ackGroupMessageRead.value,
                info={"msgId": real_id, "group_id": group_id, "content": "read"},
            )
        with _allure_step("验证发送群已读回执返回的关键字段"):
            assert_call_result(
                assert_api,
                ack,
                manager="ChatManager",
                cmd=Cmd.ackGroupMessageRead.value,
                device_name=device_name(device_b),
                result=True,
            )
        time.sleep(float(os.getenv("GROUP_OFFLINE_ACK_SERVER_SETTLE_SECONDS", "2")))
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(sender_devices, assert_api, user_id=user_a)
        for endpoint in sender_devices:
            # Android SDK 重登后不会仅靠离线同步刷新本地 EMMessage.groupAckCount；
            # 先用服务端群回执同步 API 刷新该消息，再断言每个发送端的 count。
            with _allure_step("动作端 执行群消息操作"):
                endpoint.call(
                    "ChatManager",
                    Cmd.asyncFetchGroupAcks.value,
                    info={
                        "msgId": real_id,
                        "group_id": group_id,
                        "pageSize": 20,
                        "ack_id": "",
                    },
                )
            count = {}
            poll_attempts = int(os.getenv("GROUP_OFFLINE_ACK_COUNT_POLL_ATTEMPTS", "10"))
            for attempt in range(poll_attempts):
                with _allure_step("动作端 执行本用例业务操作"):
                    count = endpoint.call(
                        "MessageManager",
                        Cmd.groupAckCount.value,
                        info={"msgId": real_id},
                    )
                if count.get("result") == 1:
                    break
                if attempt < poll_attempts - 1:
                    time.sleep(1.0)
            with _allure_step("验证执行本用例业务操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    count,
                    manager="MessageManager",
                    cmd=Cmd.groupAckCount.value,
                    device_name=device_name(endpoint),
                    result=1,
                )
    finally:
        _restore_message_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_message_recalled_before_first_recipient_login(
    topology,
    assert_api,
):
    """B 首次接收前 A 撤回群文本；B 重登验证撤回回放和本地最终删除。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    content = f"group-offline-pre-recall-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_message_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_pre_recall",
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("执行群消息动作并验证发送/接收链路"):
            real_id = _send_text(
                device_a,
                assert_api,
                user_a=user_a,
                group_id=group_id,
                content=content,
            )
        with _allure_step("A 执行群消息操作"):
            recall = device_a.call(
                "ChatManager",
                Cmd.recallMessage.value,
                info={"msgId": real_id},
            )
        with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
            assert_call_result(
                assert_api,
                recall,
                manager="ChatManager",
                cmd=Cmd.recallMessage.value,
                device_name=device_name(device_a),
                result=True,
            )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("等待并关联目标业务事件"):
                recalled_info = _wait_recall_info(endpoint, real_id=real_id)
            with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
                assert_api.assert_response_matches(
                    recalled_info,
                    expected={
                        "type": "event",
                        "eventType": Cmd.onMessagesRecalledInfo.value,
                        "data": {
                            "infos": [
                                {
                                    "recallBy": user_a,
                                    "recallMsgId": real_id,
                                    "convId": group_id,
                                    "ext": "",
                                }
                            ]
                        },
                    },
                    ignore_keys={"timestamp", "sequence"},
                )
            # 5.0 无 onMessagesRecalled（唯一撤回事件 onMessagesRecalledInfo，已在上方断言）
            with _allure_step("等待本地撤回消息删除完成"):
                local = _wait_message_absent(endpoint, real_id=real_id)
            with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    local,
                    manager="ChatManager",
                    cmd=Cmd.getMessage.value,
                    device_name=device_name(endpoint),
                    result=None,
                )
    finally:
        _restore_message_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_recipient_receives_recall_after_relogin(
    topology,
    assert_api,
):
    """B 已收群文本后离线，A 撤回；B 重登验证撤回事件和本地最终删除。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    content = f"group-offline-post-recall-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_message_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_post_recall",
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("执行群消息动作并验证发送/接收链路"):
            real_id = _send_text(
                device_a,
                assert_api,
                user_a=user_a,
                group_id=group_id,
                content=content,
            )
        for endpoint in recipient_devices:
            with _allure_step("等待并关联目标业务事件"):
                received = _wait_message_event(
                    endpoint,
                    Cmd.onMessagesReceived.value,
                    real_id=real_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_received_texts(
                    assert_api,
                    received,
                    user_a=user_a,
                    group_id=group_id,
                    messages=[(real_id, content)],
                )
        device_b.drain_events(timeout=0.5)
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 执行群消息操作"):
            recall = device_a.call(
                "ChatManager",
                Cmd.recallMessage.value,
                info={"msgId": real_id},
            )
        with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
            assert_call_result(
                assert_api,
                recall,
                manager="ChatManager",
                cmd=Cmd.recallMessage.value,
                device_name=device_name(device_a),
                result=True,
            )
        received_message = _message(
            msg_id=real_id,
            from_user=user_a,
            group_id=group_id,
            direction=1,
            status=2,
            has_read=False,
            content=content,
        )
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("等待并关联目标业务事件"):
                recalled_info = _wait_recall_info(endpoint, real_id=real_id)
            with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
                assert_api.assert_response_matches(
                    recalled_info,
                    expected={
                        "type": "event",
                        "eventType": Cmd.onMessagesRecalledInfo.value,
                        "data": {
                            "infos": [
                                {
                                    "recallBy": user_a,
                                    "recallMsgId": real_id,
                                    "convId": group_id,
                                    "msg": received_message,
                                    "ext": "",
                                }
                            ]
                        },
                    },
                    ignore_keys=_TEXT_DYNAMIC_KEYS,
                )
            # 5.0 无 onMessagesRecalled（唯一撤回事件 onMessagesRecalledInfo，已在上方断言）
            with _allure_step("动作端 执行群消息操作"):
                local = endpoint.call(
                    "ChatManager",
                    Cmd.getMessage.value,
                    info={"msgId": real_id},
                )
            with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
                assert_call_result(
                    assert_api,
                    local,
                    manager="ChatManager",
                    cmd=Cmd.getMessage.value,
                    device_name=device_name(endpoint),
                    result=None,
                )
    finally:
        _restore_message_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )


def test_group_offline_recipient_receives_content_change_after_relogin(
    topology,
    assert_api,
):
    """B 已收群文本后离线，A 修改正文；B 重登验证修改事件和本地最终正文。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    sender_devices = topology.sender_devices
    recipient_devices = topology.recipient_devices
    user_a = topology.sender_user
    user_b = topology.recipient_user
    group_id = ""
    marker = uuid.uuid4().hex[:8]
    old_content = f"group-offline-modify-old-{marker}"
    new_content = f"group-offline-modify-new-{marker}"
    try:
        with _allure_step("测试准备：创建测试群并建立成员前置"):
            group_id, _ = _create_message_group(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                name_prefix="offline_group_modify",
                sender_devices=sender_devices,
                recipient_devices=recipient_devices,
            )
        with _allure_step("执行群消息动作并验证发送/接收链路"):
            real_id = _send_text(
                device_a,
                assert_api,
                user_a=user_a,
                group_id=group_id,
                content=old_content,
            )
        for endpoint in recipient_devices:
            with _allure_step("等待并关联目标业务事件"):
                received = _wait_message_event(
                    endpoint,
                    Cmd.onMessagesReceived.value,
                    real_id=real_id,
                )
            with _allure_step("验证群业务状态、事件与关键字段"):
                _assert_received_texts(
                    assert_api,
                    received,
                    user_a=user_a,
                    group_id=group_id,
                    messages=[(real_id, old_content)],
                )
        time.sleep(5.0)
        device_b.drain_events(timeout=0.5)
        with _allure_step("测试准备：切换账号设备在线状态"):
            logout_group_account_devices(recipient_devices, assert_api)
        with _allure_step("A 执行群消息操作"):
            modify = device_a.call(
                "ChatManager",
                Cmd.modifyMessage.value,
                info={
                    "msgId": real_id,
                    "msgBody": {"type": 0, "content": new_content},
                },
            )
        sender_message = _message(
            msg_id=real_id,
            from_user=user_a,
            group_id=group_id,
            direction=0,
            status=2,
            has_read=True,
            content=new_content,
        )
        sender_message["body"] = {
            "type": 0,
            "content": new_content,
            "operatorId": user_a,
            "operatorTime": gt(0),
            "operatorCount": gt(0),
        }
        sender_message.pop("deliverOnlineOnly")
        with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
            assert_api.assert_response_matches(
                modify,
                expected={
                    "manager": "ChatManager",
                    "cmd": Cmd.modifyMessage.value,
                    "device": device_name(device_a),
                    "result": sender_message,
                },
                ignore_keys=_TEXT_DYNAMIC_KEYS,
            )
        final_message = _message(
            msg_id=real_id,
            from_user=user_a,
            group_id=group_id,
            direction=1,
            status=2,
            has_read=False,
            content=new_content,
        )
        local_message = dict(final_message)
        local_message["body"] = {
            "type": 0,
            "content": new_content,
            "operatorId": user_a,
            "operatorTime": gt(0),
            "operatorCount": gt(0),
        }
        local_message.pop("deliverOnlineOnly")
        with _allure_step("测试准备：切换账号设备在线状态"):
            login_group_account_devices(recipient_devices, assert_api, user_id=user_b)
        for endpoint in recipient_devices:
            with _allure_step("等待并关联目标业务事件"):
                changed = _wait_content_changed(endpoint, real_id=real_id)
            with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
                assert_api.assert_response_matches(
                    changed,
                    expected={
                        "type": "event",
                        "eventType": Cmd.onMessageContentChanged.value,
                        "data": {
                            "message": final_message,
                            "operatorId": user_a,
                            "operationTime": gt(0),
                        },
                    },
                    ignore_keys=_TEXT_DYNAMIC_KEYS,
                )
            with _allure_step("动作端 执行群消息操作"):
                local = endpoint.call(
                    "ChatManager",
                    Cmd.getMessage.value,
                    info={"msgId": real_id},
                )
            with _allure_step("验证执行群消息操作返回的响应 result 与关键字段"):
                assert_api.assert_response_matches(
                    local,
                    expected={
                        "manager": "ChatManager",
                        "cmd": Cmd.getMessage.value,
                        "device": device_name(endpoint),
                        "result": local_message,
                    },
                    ignore_keys=_TEXT_DYNAMIC_KEYS,
                )
    finally:
        _restore_message_case(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            group_id=group_id,
            sender_devices=sender_devices,
            recipient_devices=recipient_devices,
        )
