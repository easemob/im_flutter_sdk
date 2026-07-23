"""
Chat tests shared fixtures & marks.
自动为 chat 模块用例建立好友关系，避免各文件重复样板。
"""
from __future__ import annotations

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
                    time.sleep(1.0)
        raise last_exc

    def _contact_list(device):
        return _call_with_retry(device, "ContactManager", Cmd.getAllContactsFromServer.value, {})

    def _friend_ready(timeout: float = 30.0) -> tuple[bool, list[tuple[dict, dict]]]:
        deadline = time.monotonic() + timeout
        seen = []
        while time.monotonic() < deadline:
            contacts_a = _contact_list(device_a)
            contacts_b = _contact_list(device_b)
            seen.append((contacts_a, contacts_b))
            if user_b in (contacts_a.get("result") or []) and user_a in (contacts_b.get("result") or []):
                return True, seen
            time.sleep(2.0)
        return False, seen

    ready, seen_contacts = _friend_ready(timeout=6.0)
    if ready:
        return

    try:
        resp_add = device_a.call("ContactManager", Cmd.addContact.value, info={"userId": user_b, "reason": "chat-setup"})
    except TimeoutError:
        ready, seen_contacts = _friend_ready(timeout=10.0)
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
            device_b.receive_message(match_event_type="onContactInvited", timeout=5.0)
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
        ready, seen_contacts = _friend_ready(timeout=30.0)
        assert ready, (
            "chat 用例前置好友关系未建立，不能继续执行依赖好友关系的消息链路: "
            f"addContact={resp_add}, contacts={seen_contacts[-3:]}"
        )
    ready, seen_contacts = _friend_ready(timeout=30.0)
    assert ready, (
        "chat 用例前置好友关系未完成双端服务端可见，不能继续执行依赖好友关系的消息链路: "
        f"contacts={seen_contacts[-3:]}"
    )
    time.sleep(float(os.getenv("CHAT_FRIEND_SETTLE_SECONDS", "15")))
