"""
联系人（好友）模块用例，对应 contact_manager.dart：添加好友、接受邀请、获取好友列表。
场景：deviceA 添加 deviceB 为好友，B 同意后校验 A、B 的好友列表（用户由 conftest 创建，teardown 删除）。
"""
from __future__ import annotations

import json
from contextlib import nullcontext

import pytest

from src import Cmd, ne
from src.rest_api.contact_api import get_user_contacts
from src.test_flow import ContactTestFlow
from src.sdk_api.event_keys import ContactChangeEvent


def _allure_step(name: str):
    try:
        import allure

        return allure.step(name)
    except ImportError:
        return nullcontext()


pytestmark = [pytest.mark.client, pytest.mark.contact]

# 异常用例：不存在于环信的用户 ID
USER_NONEXISTENT = "nonexistent_contact_user_xyz_999"

# 备注边界：256 字符，含特殊字符
_REMARK_SPECIAL_CORE = r'''!@#$%^&*()_+-=[]{}|;':\",./<>?`~中文\t\n\r'''
REMARK_SPECIAL_101 = ((_REMARK_SPECIAL_CORE * 20)[:101])
assert len(REMARK_SPECIAL_101) == 101


def _cleanup_friend_and_block(device_a, device_b, user_a: str, user_b: str) -> None:
    for device, target in ((device_a, user_b), (device_b, user_a)):
        try:
            device.call("ContactManager", Cmd.deleteContact.value, info={"userId": target, "keepConversation": True})
            device.drain_events(timeout=0.5)
        except Exception:
            pass
    try:
        device_a.call("ContactManager", Cmd.removeUserFromBlockList.value, info={"userId": user_b})
    except Exception:
        pass


# ---------- addContact ----------


def test_contact_add_nonexistent_user(device_a, assert_api):
    """addContact：目标用户不存在，预期失败（顶层 error）。"""
    with _allure_step("添加不存在用户并验证用户不存在错误"):
        resp = device_a.call(
            "ContactManager",
            Cmd.addContact.value,
            info={"userId": USER_NONEXISTENT, "reason": "hello"},
        )
        assert_api.assert_error(resp, code=204, description="User does not exist")


def test_contact_add_empty_user_id(device_a, assert_api):
    """addContact：userId 为空字符串，预期参数非法类错误。"""
    with _allure_step("使用空用户 ID 添加好友并验证参数错误"):
        resp = device_a.call(
            "ContactManager",
            Cmd.addContact.value,
            info={"userId": "", "reason": "hello"},
        )
        assert_api.assert_error(resp, code=101, description="User ID is invalid")


def test_contact_add_self(device_a, assert_api, user_a):
    """addContact：不能添加自己为好友，预期失败。"""
    with _allure_step("添加自己为好友并验证参数错误"):
        resp = device_a.call(
            "ContactManager",
            Cmd.addContact.value,
            info={"userId": user_a, "reason": "self"},
        )
        assert_api.assert_error(resp, code=101, description="User ID is invalid")


# ---------- deleteContact ----------


def test_contact_delete_contact_not_friend(device_a, assert_api, user_b):
    """deleteContact：对方非好友（未建立好友关系），预期失败。"""
    with _allure_step("删除非好友并验证当前返回语义"):
        resp = device_a.call(
            "ContactManager",
            Cmd.deleteContact.value,
            info={"userId": user_b, "keepConversation": True},
        )
        assert_api.assert_response_matches(
            resp,
            expected={"manager": "ContactManager", "cmd": Cmd.deleteContact.value, "device": "{{device}}",
                      "result": "{{userId}}"},
            context={"userId": user_b, "device": device_a.device_name},
            ignore_keys={"sequence"},
        )


def test_contact_delete_contact_nonexistent_user(device_a, assert_api):
    """deleteContact：目标用户不存在，预期失败。"""
    with _allure_step("删除不存在用户并验证用户不存在错误"):
        resp = device_a.call(
            "ContactManager",
            Cmd.deleteContact.value,
            info={"userId": USER_NONEXISTENT, "keepConversation": True},
        )
        assert_api.assert_error(resp, code=204, description="User does not exist")


@pytest.mark.topology("account_a_to_account_b")
def test_friend_add_accept_and_list(topology, assert_api):
    """
    发送账号添加接收账号为好友（申请回调接收账号全部在线端收到），接收端同意后
    发送端收到同意回调，分别获取双方好友列表，最后发送端删除好友。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    action_recipient = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    _cleanup_friend_and_block(sender, action_recipient, user_a, user_b)
    # 1. 发送端添加接收账号为好友（ContactManager.addContact）
    with _allure_step(f"{sender.device_name} 向 {user_b} 发送好友申请"):
        resp_add = sender.call(
            "ContactManager",
            Cmd.addContact.value,
            info={"userId": user_b, "reason": "hello"},
        )
    assert_api.assert_success(resp_add)
    print("登录响应:", json.dumps(resp_add))
    assert_api.assert_response_matches(
        resp_add,
        expected={"manager": "ContactManager", "cmd": Cmd.addContact.value, "device": "{{device}}", "result": "{{userId}}"},
        context={"userId": user_b, "device": sender.device_name},
        ignore_keys={"sequence"},
    )
    # 1.1 接收账号全部在线端收到好友申请回调
    for recipient in recipients:
        with _allure_step(f"接收账号端 {recipient.device_name} 收到好友申请回调（INVITED）"):
            resp_invite = recipient.receive_message(
                match_event_type=ContactChangeEvent.INVITED.value,
                timeout=10.0,
            )
            assert resp_invite is not None, f"{recipient.device_name} 未收到好友邀请回调"
            assert_api.assert_response_matches(
                resp_invite,
                expected={
                    "type": "event",
                    "eventType": ContactChangeEvent.INVITED.value,
                    "data": {"userId": "{{userId}}", "reason": "hello"},
                },
                context={"userId": user_a},
                ignore_keys={"timestamp", "sequence"},
            )
    # 2. 接收账号动作端同意好友申请
    with _allure_step(f"{action_recipient.device_name} 同意好友申请（acceptInvitation）"):
        resp_accept = action_recipient.call(
            "ContactManager",
            Cmd.acceptInvitation.value,
            info={"userId": user_a},
        )
    assert_api.assert_success(resp_accept)
    # 2.1 发送端收到同意回调
    with _allure_step(f"{sender.device_name} 收到同意回调（INVITATION_ACCEPTED）"):
        resp_accepted = sender.receive_message(
            match_event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
            timeout=10.0,
        )
    assert_api.assert_response_matches(
        resp_accepted,
        expected={
            "type": "event",
            "eventType": ContactChangeEvent.INVITATION_ACCEPTED.value,
            "data": {"userId": "{{userId}}"},
        },
        context={"userId": user_b},
        ignore_keys={"timestamp"},
    )
    # 2.2 发送端收到 CONTACT_ADD 回调
    resp_contact_add_a = sender.receive_message(
        match_event_type=ContactChangeEvent.CONTACT_ADD.value,
        timeout=10.0,
    )
    assert_api.assert_response_matches(
        resp_contact_add_a,
        expected={
            "type": "event",
            "eventType": ContactChangeEvent.CONTACT_ADD.value,
            "data": {"userId": "{{userId}}"},
        },
        context={"userId": user_b},
        ignore_keys={"timestamp"},
    )
    # 3. 发送端获取好友列表
    resp_list_a = sender.call(
        "ContactManager",
        Cmd.getAllContactsFromDB.value,
        info={},
    )
    assert_api.assert_success(resp_list_a)
    assert_api.assert_response_matches(
        resp_list_a,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.getAllContactsFromDB.value,
            "device": sender.device_name,
            "result": [user_b],
        },
        ignore_keys={"sequence"},
    )
    # 4. 接收账号动作端获取好友列表
    resp_list_b = action_recipient.call(
        "ContactManager",
        Cmd.getAllContactsFromDB.value,
        info={},
    )
    assert_api.assert_success(resp_list_b)
    assert user_a in assert_api.get_result(resp_list_b), f"B 好友列表未包含 A: {resp_list_b}"
    # 5. 发送端删除好友
    with _allure_step(f"{sender.device_name} 删除好友 {user_b}"):
        result = sender.call(
            "ContactManager",
            Cmd.deleteContact.value,
            info={"userId": user_b, "keepConversation": True},
        )
    assert_api.assert_success(result)
    # 5.1 发送端收到 CONTACT_DELETE 回调
    resp_contact_delete_a = sender.receive_message(
        match_event_type=ContactChangeEvent.CONTACT_DELETE.value,
        timeout=10.0,
    )
    assert_api.assert_response_matches(
        resp_contact_delete_a,
        expected={
            "type": "event",
            "eventType": ContactChangeEvent.CONTACT_DELETE.value,
            "data": {"userId": "{{userId}}"},
        },
        context={"userId": user_b},
        ignore_keys={"timestamp"},
    )


@pytest.mark.topology("account_a_to_account_b")
def test_friend_add_decline_and_verify_not_friends(topology, assert_api):
    """
    发送账号添加接收账号为好友（申请回调接收账号全部在线端收到），接收端拒绝后
    发送端收到拒绝回调；双方好友列表均不应包含对方。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    action_recipient = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    _cleanup_friend_and_block(sender, action_recipient, user_a, user_b)
    # 1. 发送端添加接收账号为好友
    with _allure_step(f"{sender.device_name} 向 {user_b} 发送好友申请"):
        resp_add = sender.call(
            "ContactManager",
            Cmd.addContact.value,
            info={"userId": user_b, "reason": "decline_flow"},
        )
    assert_api.assert_success(resp_add)
    assert_api.assert_response_matches(
        resp_add,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.addContact.value,
            "device": "{{device}}",
            "result": "{{userId}}",
        },
        context={"userId": user_b, "device": sender.device_name},
        ignore_keys={"sequence"},
    )
    # 2. 接收账号全部在线端收到好友邀请
    for recipient in recipients:
        with _allure_step(f"接收账号端 {recipient.device_name} 收到好友申请回调（INVITED）"):
            resp_invite = recipient.receive_message(
                match_event_type=ContactChangeEvent.INVITED.value,
                timeout=10.0,
            )
            assert resp_invite is not None, f"{recipient.device_name} 未收到好友邀请回调"
            assert_api.assert_response_matches(
                resp_invite,
                expected={
                    "type": "event",
                    "eventType": ContactChangeEvent.INVITED.value,
                    "data": {"userId": "{{userId}}", "reason": "decline_flow"},
                },
                context={"userId": user_a},
                ignore_keys={"timestamp", "sequence"},
            )
    # 3. 接收账号动作端拒绝好友申请
    with _allure_step(f"{action_recipient.device_name} 拒绝好友申请（declineInvitation）"):
        resp_decline = action_recipient.call(
            "ContactManager",
            Cmd.declineInvitation.value,
            info={"userId": user_a},
        )
    assert_api.assert_success(resp_decline)
    # 4. 发送端收到好友请求被拒绝回调
    with _allure_step(f"{sender.device_name} 收到拒绝回调（INVITATION_DECLINED）"):
        resp_declined = sender.receive_message(
            match_event_type=ContactChangeEvent.INVITATION_DECLINED.value,
            timeout=10.0,
        )
    assert resp_declined is not None, "发送端未收到 onFriendRequestDeclined 回调"
    assert_api.assert_response_matches(
        resp_declined,
        expected={
            "type": "event",
            "eventType": ContactChangeEvent.INVITATION_DECLINED.value,
            "data": {"userId": "{{userId}}"},
        },
        context={"userId": user_b},
        ignore_keys={"timestamp", "sequence"},
    )
    # 5. 双方好友列表均不应包含对方（未成为好友）
    resp_list_a = sender.call(
        "ContactManager",
        Cmd.getAllContactsFromDB.value,
        info={},
    )
    assert_api.assert_success(resp_list_a)
    assert user_b not in assert_api.get_result(resp_list_a), f"A 好友列表不应包含 B: {resp_list_a}"

    resp_list_b = action_recipient.call(
        "ContactManager",
        Cmd.getAllContactsFromDB.value,
        info={},
    )
    assert_api.assert_success(resp_list_b)
    assert user_a not in assert_api.get_result(resp_list_b), f"B 好友列表不应包含 A: {resp_list_b}"


# ---------- acceptInvitation ----------


def test_contact_accept_invitation_without_pending(device_b, assert_api, user_c):
    """acceptInvitation：无待处理邀请时同意某用户。"""
    with _allure_step("无待处理邀请时同意好友申请并验证返回语义"):
        resp = device_b.call(
            "ContactManager",
            Cmd.acceptInvitation.value,
            info={"userId": user_c},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "cmd": Cmd.acceptInvitation.value,
                "device": "{{device}}",
                "manager": "ContactManager",
                "result": "{{userId}}",
                "sequence": "{{sequence}}",
            },
            context={"userId": user_c, "device": device_b.device_name},
            ignore_keys={"sequence"},
        )
    with _allure_step("查询目标用户好友关系并验证列表为空"):
        contacts = get_user_contacts(user_c)
        items = contacts if isinstance(contacts, list) else contacts.get("data", [])
        assert isinstance(items, list), f"好友列表应为 list，实际 {type(items).__name__}: {items!r}"
        assert len(items) == 0, f"好友列表应为空，实际 {items!r}"


# ---------- declineInvitation ----------


def test_contact_decline_invitation_without_pending(device_b, assert_api):
    """
    declineInvitation：对方从未发起邀请（不存在用户 / 无待处理邀请）时拒绝，按服务端实际响应断言。
    """
    with _allure_step("无待处理邀请时拒绝好友申请并验证返回语义"):
        resp = device_b.call(
            "ContactManager",
            Cmd.declineInvitation.value,
            info={"userId": USER_NONEXISTENT},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.declineInvitation.value,
                "device": "{{device}}",
                "result": "{{userId}}",
            },
            context={"userId": USER_NONEXISTENT, "device": device_b.device_name},
            ignore_keys={"sequence"},
        )


# ---------- setContactRemark / getContact ----------


def test_contact_remark_set_success(device_a, device_b, assert_api, user_a, user_b):
    """
    A 添加 B、B 同意后，A 调用 setContactRemark 并严格验证 5.0 原生成功响应。

    Android 5.0 的 getContact 是本地 fetchContactFromLocal，实测不会把
    asyncSetContactRemark 写入的备注作为可读回值，因此本用例不把本地回读
    当作 setContactRemark 成功的必要条件；本地备注回读另记为 5.0 语义差异。
    """
    with _allure_step("测试准备：建立好友关系"):
        flow = ContactTestFlow(assert_api)
        flow.establish_friends(device_a, device_b, user_a, user_b, reason="remark_normal")
    remark_text = "同事-B备注"
    with _allure_step("A 设置好友备注并验证请求成功"):
        response = device_a.call(
            "ContactManager",
            Cmd.setContactRemark.value,
            info={"userId": user_b, "remark": remark_text},
        )
        assert_api.assert_response_matches(
            response,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.setContactRemark.value,
                "device": "{{device}}",
                "result": None,
            },
            context={"device": device_a.device_name},
            ignore_keys={"sequence"},
        )
    with _allure_step("测试后置：删除好友关系"):
        flow.delete_friend(device_a, user_b)


def test_contact_remark_empty_string(device_a, device_b, assert_api, user_a, user_b):
    """成为好友后将备注设为空字符串。"""
    with _allure_step("测试准备：建立好友关系"):
        flow = ContactTestFlow(assert_api)
        flow.establish_friends(device_a, device_b, user_a, user_b, reason="remark_empty")
    remark_text = ""
    with _allure_step("A 设置空好友备注并验证请求成功"):
        response = device_a.call(
            "ContactManager",
            Cmd.setContactRemark.value,
            info={"userId": user_b, "remark": remark_text},
        )
        assert_api.assert_response_matches(
            response,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.setContactRemark.value,
                "device": "{{device}}",
                "result": None,
            },
            context={"device": device_a.device_name},
            ignore_keys={"sequence"},
        )
    with _allure_step("查询好友资料并验证备注为空"):
        content_resp = device_a.call(
            "ContactManager",
            Cmd.getContact.value,
            info={"userId": user_b},
        )
        assert_api.assert_response_matches(
            content_resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getContact.value,
                "device": "{{device}}",
                "result": {"userId": "{{userId}}", "remark": "{{remark}}"},
            },
            context={"device": device_a.device_name, "userId": user_b, "remark": remark_text},
            ignore_keys={"sequence"},
        )
    with _allure_step("测试后置：删除好友关系"):
        flow.delete_friend(device_a, user_b)


def test_contact_remark_special_chars_length_101(device_a, device_b, assert_api, user_a, user_b):
    """备注为 101 长度且含特殊字符。"""
    with _allure_step("测试准备：建立好友关系"):
        flow = ContactTestFlow(assert_api)
        flow.establish_friends(device_a, device_b, user_a, user_b, reason="remark_101")
    with _allure_step("设置超长特殊字符备注并验证长度错误"):
        assert_api.assert_error(
            device_a.call(
                "ContactManager",
                Cmd.setContactRemark.value,
                info={"userId": user_b, "remark": REMARK_SPECIAL_101},
            ),
            code=4,
            description="remark length must less than 100",
        )
    with _allure_step("测试后置：删除好友关系"):
        flow.delete_friend(device_a, user_b)


@pytest.mark.skip(reason="5.0 getContact 为本地拉取（fetchContactFromLocal），本地 EMContact 不携带 remark（恒空）—— 备注保留/失效语义无法通过 getContact 验证；需服务端拉取 API（如有）")
def test_contact_remark_not_preserved_after_delete_and_readd(device_a, device_b, assert_api, user_a, user_b):
    """
    A 删除 B 后再次添加并同意，先前备注一般不应保留（以服务端为准；此处断言与旧备注不同或为空）。
    """
    old = "持久化备注-删除后应失效"
    flow = ContactTestFlow(assert_api)
    flow.establish_friends(device_a, device_b, user_a, user_b, reason="remark_readd")
    resp_set = device_a.call(
        "ContactManager",
        Cmd.setContactRemark.value,
        info={"userId": user_b, "remark": old},
    )
    assert_api.assert_response_matches(
        resp_set,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.setContactRemark.value,
            "device": "{{device}}",
            "result": None,
        },
        context={"device": device_a.device_name},
        ignore_keys={"sequence"},
    )
    content_after_set = device_a.call(
        "ContactManager",
        Cmd.getContact.value,
        info={"userId": user_b},
    )
    assert_api.assert_response_matches(
        content_after_set,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.getContact.value,
            "device": "{{device}}",
            "result": {"userId": "{{userId}}", "remark": "{{remark}}"},
        },
        context={"device": device_a.device_name, "userId": user_b, "remark": old},
        ignore_keys={"sequence"},
    )
    flow.delete_friend(device_a, user_b)

    flow.establish_friends(device_a, device_b, user_a, user_b, reason="remark_readd_2")
    content_after_readd = device_a.call(
        "ContactManager",
        Cmd.getContact.value,
        info={"userId": user_b},
    )
    assert_api.assert_response_matches(
        content_after_readd,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.getContact.value,
            "device": "{{device}}",
            "result": {"userId": "{{userId}}", "remark": ne(old)},
        },
        context={"device": device_a.device_name, "userId": user_b},
        ignore_keys={"sequence"},
    )
    flow.delete_friend(device_a, user_b)


def test_contact_set_contact_remark_non_friend(device_a, assert_api):
    """setContactRemark：对非好友设置备注，预期失败。"""
    with _allure_step("为非好友设置备注并验证好友关系错误"):
        resp = device_a.call(
            "ContactManager",
            Cmd.setContactRemark.value,
            info={"userId": USER_NONEXISTENT, "remark": "x"},
        )
        assert_api.assert_error(
            resp,
            code=221,
            description="updateRemark | they are not friends, please add as a friend first.",
        )


def test_contact_get_block_list_from_server_returns_list(device_a, assert_api):
    """getBlockListFromServer：从服务器拉黑名单，result 为列表（可为空）。"""
    with _allure_step("查询服务端黑名单并验证返回列表"):
        resp = device_a.call(
            "ContactManager",
            Cmd.getBlockListFromServer.value,
            info={},
        )
        # 校验信封字段，避免使用 actual 的 result 自证；随后单独断言类型为 list。
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getBlockListFromServer.value,
                "device": device_a.device_name,
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(resp.get("result"), list), "getBlockListFromServer should return a list (possibly empty)."


def test_contact_fetch_all_fetch_page_fetch_ids_get_local_lists(
    device_a, device_b, assert_api, user_a, user_b
):
    """
    加好友并设置备注后：getAllContactsFromDB 本地读取；
    再验证 fetchAllContacts（本地好友）、getContact、getAllContacts（本地）。
    5.0 移除 fetchContacts 分页拉取（残留），不再覆盖。
    """
    with _allure_step("测试准备：建立好友关系并设置备注"):
        flow = ContactTestFlow(assert_api)
        flow.establish_friends(device_a, device_b, user_a, user_b, reason="fetch_contacts_api")
    remark_for_fetch = "fetch-remark-校验"

    with _allure_step("A 设置好友备注并验证成功"):
        resp_set_remark = device_a.call(
            "ContactManager",
            Cmd.setContactRemark.value,
            info={"userId": user_b, "remark": remark_for_fetch},
        )
        assert_api.assert_response_matches(
            resp_set_remark,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.setContactRemark.value,
                "device": device_a.device_name,
                "result": None,
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("读取本地联系人 ID 列表并验证包含 B"):
        resp_sync = device_a.call(
            "ContactManager",
            Cmd.getAllContactsFromDB.value,
            info={},
        )
        assert_api.assert_response_matches(
            resp_sync,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getAllContactsFromDB.value,
                "device": device_a.device_name,
                "result": [user_b],
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("读取本地全部联系人并验证 B 存在"):
        resp_fetch_all = device_a.call(
            "ContactManager",
            Cmd.fetchAllContacts.value,
            info={},
        )
        assert_api.assert_response_matches(
            resp_fetch_all,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.fetchAllContacts.value,
                "device": device_a.device_name,
                "result": [{"userId": user_b}],
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("读取单个联系人并验证备注"):
        resp_get_one = device_a.call(
            "ContactManager",
            Cmd.getContact.value,
            info={"userId": user_b},
        )
        assert_api.assert_response_matches(
            resp_get_one,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getContact.value,
                "device": device_a.device_name,
                "result": {"userId": user_b},
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("读取全部本地联系人对象并验证 B 存在"):
        resp_all_local = device_a.call(
            "ContactManager",
            Cmd.getAllContacts.value,
            info={},
        )
        assert_api.assert_response_matches(
            resp_all_local,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getAllContacts.value,
                "device": device_a.device_name,
                "result": [{"userId": user_b}],
            },
            ignore_keys={"sequence"},
        )

    with _allure_step("测试后置：删除好友关系"):
        flow.delete_friend(device_a, user_b)


@pytest.mark.skip(reason="5.0 移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）")
def test_contact_fetch_all_contact_ids(device_a, assert_api):
    resp = device_a.call("ContactManager", Cmd.fetchAllContactIds.value, info={})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.fetchAllContactIds.value,
            "device": device_a.device_name,
            "result": [],
        },
        ignore_keys={"sequence", "result"},
    )
    assert isinstance(resp.get("result"), list), f"fetchAllContactIds result 应为 list: {resp!r}"


def test_contact_get_all_contact_ids(device_a, assert_api):
    with _allure_step("读取全部联系人 ID 并验证返回列表"):
        resp = device_a.call("ContactManager", Cmd.getAllContactIds.value, info={})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getAllContactIds.value,
                "device": device_a.device_name,
                "result": [],
            },
            ignore_keys={"sequence", "result"},
        )
        assert isinstance(resp.get("result"), list), f"getAllContactIds result 应为 list: {resp!r}"


# ---------- fetchContacts（异常：文档 pageSize ∈ [1,50]）----------


@pytest.mark.skip(reason="5.0 移除分页拉联系人（fetchContacts 改为本地全量 asyncFetchAllContactsFromLocal，忽略 pageSize）—— pageSize 边界校验不存在，case 语义失效")
@pytest.mark.skip(reason="5.0 移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）")
def test_contact_fetch_contacts_page_size_zero(device_a, assert_api):
    """fetchContacts：pageSize 为 0（5.0 已移除分页，忽略 pageSize）。"""
    resp = device_a.call(
        "ContactManager",
        Cmd.fetchContacts.value,
        info={"cursor": "", "pageSize": 0},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.fetchContacts.value,
            "device": device_a.device_name,
            "result": {"cursor":"","list":[]},
        },
        ignore_keys={"sequence"},
    )

@pytest.mark.skip(reason="5.0 移除分页拉联系人（fetchContacts 本地全量，忽略 pageSize）—— 超出 50 的边界校验不存在")
@pytest.mark.skip(reason="5.0 移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）")
def test_contact_fetch_contacts_page_size_exceeds_50(device_a, assert_api):
    """fetchContacts：pageSize 大于 50（5.0 已移除分页，忽略 pageSize）。"""
    resp = device_a.call(
        "ContactManager",
        Cmd.fetchContacts.value,
        info={"cursor": "", "pageSize": 51},
    )
    assert_api.assert_error(
        resp,
        code=112,
        description="getContacts | page size more than max limit : 50",
    )


@pytest.mark.skip(reason="5.0 移除分页拉联系人（fetchContacts 本地全量，忽略 pageSize）—— 负数边界校验不存在")
@pytest.mark.skip(reason="5.0 移除 fetchContacts/fetchAllContactIds/getAllContactIds（残留，无分页拉联系人）")
def test_contact_fetch_contacts_page_size_negative(device_a, assert_api):
    """fetchContacts：pageSize 为负数（5.0 已移除分页，忽略 pageSize）。"""
    resp = device_a.call(
        "ContactManager",
        Cmd.fetchContacts.value,
        info={"cursor": "", "pageSize": -1},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.fetchContacts.value,
            "device": device_a.device_name,
            "result": {"cursor": "", "list": []},
        },
        ignore_keys={"sequence"},
    )




def test_contact_add_user_to_block_list_nonexistent(device_a, assert_api):
    """addUserToBlockList：拉黑不存在用户，预期失败。"""
    with _allure_step("将不存在用户加入黑名单并验证用户不存在错误"):
        resp = device_a.call(
            "ContactManager",
            Cmd.addUserToBlockList.value,
            info={"userId": USER_NONEXISTENT},
        )
        assert_api.assert_error(resp, code=204)


@pytest.mark.topology("account_a_to_account_b")
def test_contact_block_list_flow_then_unblock_restores_friend(
    topology, assert_api
):
    """
    多端拓扑：A 拉黑 B → A 全部端黑名单含 B、好友列表不含 B，B 全部端好友列表仍含 A；A 取消拉黑后好友恢复。
    """
    sender = topology.sender_action_device
    recipients = topology.recipient_devices
    owner_user = topology.sender_user
    member_user = topology.recipient_user

    _cleanup_friend_and_block(sender, topology.recipient_action_device, owner_user, member_user)
    flow = ContactTestFlow(assert_api)
    with _allure_step(f"{sender.device_name} 与 B 建立好友"):
        flow.establish_friends(sender, topology.recipient_action_device, owner_user, member_user, reason="blocklist_flow")
    with _allure_step(f"{sender.device_name} 拉黑 {member_user}"):
        flow.add_to_block_list(sender, member_user)

    with _allure_step("A 全部在线端黑名单均含 B（账号级服务端状态一致）"):
        for endpoint in topology.sender_devices:
            resp_block = flow.get_block_list(endpoint)
            assert_api.assert_success(resp_block)
            assert_api.assert_response_matches(
                resp_block,
                expected={
                    "manager": "ContactManager",
                    "cmd": Cmd.getBlockListFromServer.value,
                    "device": endpoint.device_name,
                    "result": [member_user],
                },
                ignore_keys={"sequence"},
            )
    with _allure_step("A 全部在线端好友列表均不含 B"):
        for endpoint in topology.sender_devices:
            resp_friends_a_blocked = flow.get_all_contacts_from_db(endpoint)
            assert_api.assert_success(resp_friends_a_blocked)
            assert_api.assert_response_matches(
                resp_friends_a_blocked,
                expected={
                    "manager": "ContactManager",
                    "cmd": Cmd.getAllContactsFromDB.value,
                    "device": endpoint.device_name,
                    "result": [member_user],
                },
                ignore_keys={"sequence"},
            )
    with _allure_step("B 全部在线端好友列表仍含 A"):
        for endpoint in recipients:
            resp_friends_b = flow.wait_for_all_contacts_from_db(endpoint, [owner_user])
            assert_api.assert_success(resp_friends_b)
            assert owner_user in assert_api.get_result(resp_friends_b), f"B 好友列表未包含 A: {resp_friends_b}"

    with _allure_step(f"{sender.device_name} 取消拉黑 {member_user}"):
        assert_api.assert_success(flow.remove_from_block_list(sender, member_user))

    with _allure_step("A 全部在线端好友列表恢复含 B"):
        for endpoint in topology.sender_devices:
            resp_friends_a_after = flow.get_all_contacts_from_db(endpoint)
            assert_api.assert_success(resp_friends_a_after)
            assert_api.assert_response_matches(
                resp_friends_a_after,
                expected={
                    "manager": "ContactManager",
                    "cmd": Cmd.getAllContactsFromDB.value,
                    "device": endpoint.device_name,
                    "result": [member_user],
                },
                ignore_keys={"sequence"},
            )

    flow.delete_friend(sender, member_user)



def test_contact_remove_from_block_list_when_not_blocked(
    device_a, device_b, assert_api, user_a, user_b
):
    """已是好友但未加入黑名单时调用 removeUserFromBlockList。"""
    with _allure_step("测试准备：清理关系并建立好友关系"):
        _cleanup_friend_and_block(device_a, device_b, user_a, user_b)
        flow = ContactTestFlow(assert_api)
        flow.establish_friends(device_a, device_b, user_a, user_b, reason="unblock_not_in_list")
    with _allure_step("查询黑名单并验证好友不在黑名单"):
        resp_bl = flow.get_block_list(device_a)
        assert_api.assert_success(resp_bl)
        assert_api.assert_response_matches(
            resp_bl,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.getBlockListFromServer.value,
                "device": device_a.device_name,
                "result": [],
            },
            ignore_keys={"sequence", "result"},
        )
        assert user_b not in assert_api.get_result(resp_bl)
    with _allure_step("移除未加入的黑名单成员并验证幂等成功"):
        assert_api.assert_success(flow.remove_from_block_list(device_a, user_b))
    with _allure_step("测试后置：删除好友关系"):
        flow.delete_friend(device_a, user_b)


def test_contact_remove_from_block_list_nonexistent_user(device_a, assert_api):
    """removeUserFromBlockList：目标用户不存在，服务端幂等返回成功（HTTP 200），result 为用户名。"""
    with _allure_step("移除不存在用户的黑名单关系并验证幂等返回"):
        resp = device_a.call(
            "ContactManager",
            Cmd.removeUserFromBlockList.value,
            info={"userId": USER_NONEXISTENT},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "ContactManager",
                "cmd": Cmd.removeUserFromBlockList.value,
                "device": device_a.device_name,
                "result": USER_NONEXISTENT,
            },
            ignore_keys={"sequence"},
        )
