from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from tests.chat._utils import build_text
from tests.chat.test_chat_recall_and_message_read_ack import _send_typed

pytestmark = [pytest.mark.client, pytest.mark.chat]


def _wait_text_event(device, event_type, *, content, timeout=30.0):
    deadline = time.monotonic() + timeout
    seen = []
    while time.monotonic() < deadline:
        event = device.receive_message(match_event_type=event_type, timeout=2)
        if event:
            seen.append(event)
        if event_type == Cmd.onMessageSuccess.value:
            message = ((event or {}).get("data") or {}).get("msg") or {}
            if (message.get("body") or {}).get("content") == content:
                return event, message
            continue
        for message in (((event or {}).get("data") or {}).get("messages") or []):
            if isinstance(message, dict) and (message.get("body") or {}).get("content") == content:
                return event, message
    pytest.fail(f"未收到文本消息事件: eventType={event_type}, content={content!r}, seen={seen}")


def _assert_text_event(assert_api, event_type, message, *, msg_id, user_a, user_b,
                       content, direction, conv_id, has_read, has_deliver_ack):
    assert_api.assert_response_matches(
        {"type": "event", "eventType": event_type, "data": {"messages": [message]}},
        expected={"type": "event", "eventType": event_type, "data": {"messages": [{
            "msgId": msg_id, "from": user_a, "to": user_b, "convId": conv_id,
            "chatType": 0, "direction": direction, "status": 2,
            "hasRead": has_read, "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "deliverOnlineOnly": False,
            "body": {"type": 0, "content": content, "translations": {}},
        }]}},
        ignore_keys={"timestamp", "sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "targetLanguages"},
    )


def _send_text(device_a, device_b, assert_api, user_a, user_b, content):
    device_a.drain_events()
    device_b.drain_events()
    response = device_a.call("ChatManager", Cmd.sendMessage.value, info=build_text(user_a, user_b, content))
    temp_id = ((response.get("result") or {}).get("msgId"))
    assert temp_id, response
    assert_api.assert_response_matches(
        response,
        expected={"manager": "ChatManager", "cmd": Cmd.sendMessage.value, "device": "deviceA", "result": {
            "msgId": temp_id, "from": user_a, "to": user_b, "convId": user_b,
            "chatType": 0, "direction": 0, "status": 0, "hasRead": True,
            "needReadReceipt": False, "isThread": False, "isContentReplaced": False,
            "body": {"type": 0, "content": content},
        }},
        ignore_keys={"sequence", "localTime", "serverTime", "broadcast", "onlineState",
                     "deliverOnlineOnly", "targetLanguages", "translations"},
    )
    _, sent = _wait_text_event(device_a, Cmd.onMessageSuccess.value, content=content)
    real_id = sent.get("msgId")
    _assert_text_event(
        assert_api, Cmd.onMessageSuccess.value, sent, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=0, conv_id=user_b, has_read=True, has_deliver_ack=None,
    )
    _, received = _wait_text_event(device_b, Cmd.onMessagesReceived.value, content=content)
    _assert_text_event(
        assert_api, Cmd.onMessagesReceived.value, received, msg_id=real_id, user_a=user_a, user_b=user_b,
        content=content, direction=1, conv_id=user_a, has_read=False, has_deliver_ack=None,
    )
    return sent


def _fetch(device_a, user_b, *, options, cursor="", page_size=20):
    return device_a.call(
        "ChatManager", Cmd.fetchHistoryMessagesByOptions.value,
        info={"convId": user_b, "type": 0, "pageSize": page_size, "cursor": cursor, "options": options},
    )


def _target_projection(response, target_ids):
    return [
        {"msgId": str(message.get("msgId")), "type": (message.get("body") or {}).get("type"),
         "content": (message.get("body") or {}).get("content"),
         "event": (message.get("body") or {}).get("event")}
        for message in ((response.get("result") or {}).get("list") or [])
        if isinstance(message, dict) and str(message.get("msgId")) in target_ids
    ]


def test_chat_history_filters_direction_time_and_message_types(device_a, device_b, assert_api, user_a, user_b):
    device_a.drain_events()
    device_b.drain_events()
    cleanup = device_a.call(
        "ChatManager", Cmd.deleteRemoteConversation.value,
        info={"convId": user_b, "conversationType": 0, "isDeleteRemoteMessage": True},
    )
    assert_api.assert_response_matches(
        cleanup,
        expected={"manager": "ChatManager", "cmd": Cmd.deleteRemoteConversation.value,
                  "device": "deviceA", "result": None},
        ignore_keys={"sequence"},
    )
    # deleteRemoteConversation 的同步响应早于服务端删除真正完成；立即发送会
    # 与仍在执行的删除竞争，导致第一条新消息偶发被一并清掉。
    time.sleep(5)
    text_content = f"history-filter-text-{uuid.uuid4().hex[:6]}"
    text = _send_text(device_a, device_b, assert_api, user_a, user_b, text_content)
    time.sleep(1)
    custom_event = f"history-filter-custom-{uuid.uuid4().hex[:6]}"
    _, custom_success, _, custom_id = _send_typed(
        device_a, device_b, assert_api, user_a, user_b, "custom",
        {"event": custom_event, "params": {"filter": "history"}},
    )
    text_id = str(text["msgId"])
    custom_id = str(custom_id)
    target_ids = {text_id, custom_id}
    custom_message = ((custom_success.get("data") or {}).get("msg") or {})
    text_ts = int(text["serverTime"])
    custom_ts = int(custom_message["serverTime"])
    middle_ts = (text_ts + custom_ts) // 2
    base = {"needSave": False, "startTs": -1, "endTs": -1}

    # 发送成功回调早于漫游存储完成，尤其是 custom 消息。先等服务端的 UP
    # 查询能同时看见两条目标消息，再验证 DOWN 与过滤规则，避免把存储延迟
    # 误判成 direction 行为。
    archive_deadline = time.monotonic() + 60
    archive_response = None
    while time.monotonic() < archive_deadline:
        archive_response = _fetch(
            device_a, user_b,
            options={**base, "direction": 0, "msgTypes": [0, 7]},
            page_size=50,
        )
        archived_ids = {
            item["msgId"] for item in _target_projection(archive_response, target_ids)
        }
        if archived_ids == target_ids:
            break
        time.sleep(2)
    assert archive_response is not None and archived_ids == target_ids, (
        f"目标消息未在超时前进入漫游存储: response={archive_response}"
    )

    down_options = {**base, "direction": 1}
    down_cursor = ""
    down_found = set()
    seen_cursors = set()
    for _ in range(50):
        down_response = _fetch(
            device_a, user_b, options=down_options, cursor=down_cursor, page_size=50,
        )
        down_found.update(
            item["msgId"] for item in _target_projection(down_response, target_ids)
        )
        if down_found == target_ids:
            break
        next_cursor = str((down_response.get("result") or {}).get("cursor") or "")
        if not next_cursor or next_cursor in seen_cursors:
            break
        seen_cursors.add(next_cursor)
        down_cursor = next_cursor
    assert down_found == target_ids, (
        f"direction-down 未遍历到目标消息: found={down_found}, targets={target_ids}, "
        f"cursor={down_cursor}"
    )

    cases = [
        ("end-before-custom", {**base, "direction": 0, "startTs": 0, "endTs": middle_ts}, {text_id}),
        ("start-after-text", {**base, "direction": 0, "startTs": middle_ts, "endTs": -1}, {custom_id}),
        ("image-only", {**base, "direction": 0, "msgTypes": [1]}, set()),
        ("text-and-image", {**base, "direction": 0, "msgTypes": [0, 1]}, {text_id}),
        ("custom-only", {**base, "direction": 0, "msgTypes": [7]}, {custom_id}),
        ("text-and-custom", {**base, "direction": 0, "msgTypes": [0, 7]}, {text_id, custom_id}),
    ]
    for name, options, expected_ids in cases:
        response = _fetch(device_a, user_b, options=options)
        projection = _target_projection(response, target_ids)
        actual_ids = {item["msgId"] for item in projection}
        assert actual_ids == expected_ids, f"{name}: response={response}, projection={projection}"
        for item in projection:
            if item["msgId"] == text_id:
                assert item == {"msgId": text_id, "type": 0, "content": text_content, "event": None}
            elif item["msgId"] == custom_id:
                assert item == {"msgId": custom_id, "type": 7, "content": None, "event": custom_event}
        assert_api.assert_response_matches(
            {"manager": response.get("manager"), "cmd": response.get("cmd"), "device": response.get("device"),
             "result": {"targetIds": sorted(actual_ids)}},
            expected={"manager": "ChatManager", "cmd": Cmd.fetchHistoryMessagesByOptions.value,
                      "device": "deviceA", "result": {"targetIds": sorted(expected_ids)}},
            ignore_keys={"sequence"},
        )
