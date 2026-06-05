from __future__ import annotations

from src import Cmd
from tests.chat._utils import build_text


def test_chat_fetch_reaction_list_invalid_msg_id(device_a, assert_api):
    """fetchReactionList 传入不存在的 msgId 列表；先断言信封。"""
    # Flutter 端签名要求 chatType 必填；请求体键名为 msgIds。
    info = {"msgIds": ["__invalid_msg_id__"], "chatType": 0}
    resp = device_a.call("ChatManager", Cmd.fetchReactionList.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionList.value,
            "device": "deviceA",
            "result": {"__invalid_msg_id__": []},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_list_empty_msg_ids(device_a, assert_api):
    """fetchReactionList 传入空 msgIds；应返回参数错误。"""
    info = {"msgIds": [], "chatType": 0}
    resp = device_a.call("ChatManager", Cmd.fetchReactionList.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionList.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "'messageIdList' can not be null"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_list_invalid_chat_type(device_a, assert_api):
    """fetchReactionList 传入非法 chatType；当前实现返回空 reaction 列表映射。"""
    info = {"msgIds": ["__invalid_msg_id__"], "chatType": -1}
    resp = device_a.call("ChatManager", Cmd.fetchReactionList.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionList.value,
            "device": "deviceA",
            "result": {"__invalid_msg_id__": []},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_invalid(device_a, assert_api):
    """fetchReactionDetail 使用无效 msgId/reaction；先校验信封。"""
    # 原生 wrapper 将 pageSize 按必填读取（Android: getInt），缺失会直接抛参错。
    info = {"msgId": "__invalid_msg_id__", "reaction": "👍", "pageSize": 20}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"cursor": "", "list": []},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_invalid_page_size(device_a, device_b, assert_api, user_a, user_b):
    """fetchReactionDetail 非法 pageSize（-1）；应返回参数错误。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    _ = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_a, user_b, "reaction-detail-invalid-page-size"),
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    info = {"msgId": real_id, "reaction": "👍", "pageSize": -1}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"code": 303, "description": "Unknown server error"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_empty_reaction(device_a, device_b, assert_api, user_a, user_b):
    """fetchReactionDetail 传入空 reaction；应返回参数错误。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    _ = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_a, user_b, "reaction-detail-empty-reaction"),
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    info = {"msgId": real_id, "reaction": "", "pageSize": 20}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "'reaction' can not be null"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_fetch_reaction_detail_oversize_page_size(device_a, device_b, assert_api, user_a, user_b):
    """fetchReactionDetail 过大 pageSize（1000）；应返回稳定结果结构。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    _ = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_a, user_b, "reaction-detail-oversize-page-size"),
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    info = {"msgId": real_id, "reaction": "👍", "pageSize": 1000}
    resp = device_a.call("ChatManager", Cmd.fetchReactionDetail.value, info=info)
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.fetchReactionDetail.value,
            "device": "deviceA",
            "result": {"code": 110, "description": "Limit exceeds the maximum quantity limit"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_add_reaction_duplicate_reaction(device_a, device_b, assert_api, user_a, user_b):
    """addReaction 重复添加同一 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    _ = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_a, user_b, "reaction-duplicate"),
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    resp_add_first = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "👍", "msgId": real_id})
    resp_add_second = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "👍", "msgId": real_id})
    assert_api.assert_response_matches(
        resp_add_first,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )
    assert_api.assert_response_matches(
        resp_add_second,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": {"code": 1301, "description": "the user is already operation this message"},
        },
        ignore_keys={"sequence"},
    )


def test_chat_remove_reaction_not_exists_reaction(device_a, device_b, assert_api, user_a, user_b):
    """removeReaction 删除不存在的 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    _ = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_a, user_b, "reaction-remove-not-exists"),
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    resp = device_a.call("ChatManager", Cmd.removeReaction.value, info={"reaction": "👍", "msgId": real_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.removeReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_chat_remove_reaction_invalid_msg_id(device_a, assert_api):
    """removeReaction 使用无效 msgId；按不存在语义冻结。"""
    resp = device_a.call("ChatManager", Cmd.removeReaction.value, info={"reaction": "👍", "msgId": "__invalid_msg_id__"})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.removeReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_chat_add_reaction_too_long_reaction(device_a, device_b, assert_api, user_a, user_b):
    """addReaction 超长 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    _ = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_a, user_b, "reaction-too-long"),
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    resp_128 = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "a" * 128, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_128,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )

    resp_256 = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "b" * 256, "msgId": real_id})
    assert_api.assert_response_matches(
        resp_256,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": {"code": 302, "description": "this message is creating reaction, please try again."},
        },
        ignore_keys={"sequence"},
    )


def test_chat_add_reaction_special_char_reaction(device_a, device_b, assert_api, user_a, user_b):
    """addReaction 特殊字符 reaction；按被测端实际语义冻结。"""
    try:
        device_a.drain_events()
        device_b.drain_events()
    except Exception:
        pass

    _ = device_a.call(
        "ChatManager",
        Cmd.sendMessage.value,
        info=build_text(user_a, user_b, "reaction-special-char"),
    )
    evt_success = device_a.receive_message(match_event_type=Cmd.onMessageSuccess.value, timeout=20.0)
    real_id = (((evt_success or {}).get("data") or {}).get("msg") or {}).get("msgId")
    assert real_id, f"missing real msgId from onMessageSuccess: {evt_success!r}"

    resp = device_a.call("ChatManager", Cmd.addReaction.value, info={"reaction": "\n\t", "msgId": real_id})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ChatManager",
            "cmd": Cmd.addReaction.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )
