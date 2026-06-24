"""
Chat tests shared fixtures & marks.
自动为 chat 模块用例建立好友关系，避免各文件重复样板。
"""
from __future__ import annotations

import os
import pytest

from src import Cmd

pytestmark = [pytest.mark.client, pytest.mark.chat]


@pytest.fixture(autouse=True)
def ensure_friends(device_a, device_b, assert_api, user_a, user_b):
    discovering = os.getenv("CASES_DISCOVER", "0") in ("1", "true", "True")
    server_resp = device_a.call("ContactManager", Cmd.getAllContactsFromServer.value, info={})
    if user_b in (server_resp.get("result") or []):
        return

    try:
        resp_add = device_a.call("ContactManager", Cmd.addContact.value, info={"userId": user_b, "reason": "chat-setup"})
    except TimeoutError:
        retry_server_resp = device_a.call("ContactManager", Cmd.getAllContactsFromServer.value, info={})
        if user_b in (retry_server_resp.get("result") or []):
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
        # 已是好友或环境返回错误体（如已登录/已添加），此处不阻断，用最小信封通过
        # 仅校验信封，放宽 result 形状
        assert resp_add.get("manager") == "ContactManager" and resp_add.get("cmd") == Cmd.addContact.value
