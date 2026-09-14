"""
Chat tests shared fixtures & marks.
自动为 chat 模块用例建立好友关系，避免各文件重复样板。
"""
from __future__ import annotations
from src.tools.case_timing import seconds as timing_seconds, pause as timing_pause

import os
import time
import pytest

from src import Cmd

pytestmark = [pytest.mark.client, pytest.mark.chat]


@pytest.fixture(autouse=True)
def ensure_friends(device_a, device_b, assert_api, user_a, user_b):
    discovering = os.getenv("CASES_DISCOVER", "0") in ("1", "true", "True")

    def _call_with_retry(device, manager: str, cmd: str, info: dict | None = None, *, attempts: int = 3):
        last_exc = None
        for idx in range(attempts):
            try:
                return device.call(manager, cmd, info=info or {})
            except TimeoutError as exc:
                last_exc = exc
                if idx + 1 < attempts:
                    time.sleep(timing_seconds('retry.backoff', module='chat'))
        raise last_exc

    def _contact_list(device):
        return _call_with_retry(device, "ContactManager", Cmd.getAllContactsFromServer.value, {})

    def _friend_ready(timeout: float = None) -> tuple[bool, list[tuple[dict, dict]]]:
        timeout = timing_seconds('timeout.friend_ready', module='chat') if timeout is None else timeout
        deadline = time.monotonic() + timeout
        seen = []
        while time.monotonic() < deadline:
            contacts_a = _contact_list(device_a)
            contacts_b = _contact_list(device_b)
            seen.append((contacts_a, contacts_b))
            if user_b in (contacts_a.get("result") or []) and user_a in (contacts_b.get("result") or []):
                return True, seen
            time.sleep(timing_seconds('poll.server_state', module='chat'))
        return False, seen

    ready, seen_contacts = _friend_ready(timeout=timing_seconds('timeout.friend_probe', module='chat'))
    if ready:
        return

    try:
        resp_add = device_a.call("ContactManager", Cmd.addContact.value, info={"userId": user_b, "reason": "chat-setup"})
    except TimeoutError:
        ready, seen_contacts = _friend_ready(timeout=timing_seconds('timeout.friend_recovery', module='chat'))
        if ready:
            return
        raise
    # 某些情况下上一条请求的响应可能延迟返回到本次调用（例如 Client.logout），做一次轻量重试
    if resp_add.get("cmd") != Cmd.addContact.value:
        resp_add = device_a.call("ContactManager", Cmd.addContact.value, info={"userId": user_b, "reason": "chat-setup"})
    add_res = resp_add.get("result")
    if isinstance(add_res, str):
        # 首次添加成功
        assert_api.assert_response_matches(
            resp_add,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.addContact.value,
                "device": "deviceA",
                "result": "{{userB}}",
            },
            context={"userB": user_b},
            ignore_keys={"sequence"},
        )
        if not discovering:
            device_b.receive_message(match_event_type="onContactInvited", timeout=timing_seconds('timeout.friend_invitation', module='chat'))
        timing_pause('step.interval', module='chat')
        resp_accept = device_b.call("ContactManager", Cmd.acceptInvitation.value, info={"userId": user_a})
        acc_res = resp_accept.get("result")
        if isinstance(acc_res, str):
            assert_api.assert_response_matches(
                resp_accept,
                expected={
                    "manager": "ContactManager",
                    "cmd": Cmd.acceptInvitation.value,
                    "device": "deviceB",
                    "result": "{{userA}}",
                },
                context={"userA": user_a},
                ignore_keys={"sequence"},
            )
        else:
            # 某些集成端返回对象或其他占位，收紧为信封 + 存在 result
            assert_api.assert_response_matches(
                resp_accept,
                expected={
                    "manager": "ContactManager",
                    "cmd": Cmd.acceptInvitation.value,
                    "device": "deviceB",
                    "result": acc_res,
                },
                ignore_keys={"sequence"},
            )
    else:
        assert resp_add.get("manager") == "ContactManager" and resp_add.get("cmd") == Cmd.addContact.value
        ready, seen_contacts = _friend_ready(timeout=timing_seconds('timeout.friend_ready', module='chat'))
        assert ready, (
            "chat 用例前置好友关系未建立，不能继续执行依赖好友关系的消息链路: "
            f"addContact={resp_add}, contacts={seen_contacts[-3:]}"
        )
    ready, seen_contacts = _friend_ready(timeout=timing_seconds('timeout.friend_ready', module='chat'))
    assert ready, (
        "chat 用例前置好友关系未完成双端服务端可见，不能继续执行依赖好友关系的消息链路: "
        f"contacts={seen_contacts[-3:]}"
    )
    time.sleep(timing_seconds('settle.slow', module='chat'))
