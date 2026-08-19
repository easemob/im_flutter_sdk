"""好友申请离线链路：接收方/申请方重新登录后的事件与关系状态。"""
from __future__ import annotations

import time
import uuid

import pytest

from src import Cmd
from src.sdk_api.event_keys import ContactChangeEvent
from src.test_flow.offline_test_flow import (
    login_account_devices,
    logout_account_devices,
    restore_account_devices,
    set_accept_invitation_always,
)
from tests.allure_helpers import _allure_step


pytestmark = [
    pytest.mark.client,
    pytest.mark.contact,
    pytest.mark.topology("account_a_to_account_b"),
]


def _device_name(device) -> str:
    return getattr(device, "_device", "device")


def _unique_devices(primary, extras=()):
    devices = [] if primary is None else [primary]
    for device in extras:
        if device is not None and all(device is not existing for existing in devices):
            devices.append(device)
    return tuple(devices)


def _wait_contact_absent(devices, target: str, *, timeout: float = 8.0) -> None:
    """等待删除事件落入 5.0 各端本地联系人 DB；最终断言仍由用例完成。"""
    deadline = time.monotonic() + timeout
    while True:
        absent = True
        for device in devices:
            try:
                response = device.call(
                    "ContactManager",
                    Cmd.getAllContactsFromDB.value,
                    info={},
                )
                contacts = response.get("result")
                if not isinstance(contacts, list) or target in contacts:
                    absent = False
            except Exception:
                absent = False
        if absent or time.monotonic() >= deadline:
            return
        time.sleep(0.25)


def _cleanup_relation(
    device_a,
    device_b,
    user_a: str,
    user_b: str,
    *,
    account_a_devices=(),
    account_b_devices=(),
) -> None:
    account_a = _unique_devices(device_a, account_a_devices)
    account_b = _unique_devices(device_b, account_b_devices)
    for device in account_a:
        target = user_b
        try:
            device.call(
                "ContactManager",
                Cmd.deleteContact.value,
                info={"userId": target, "keepConversation": True},
            )
        except Exception:
            pass
        try:
            device.call(
                "ContactManager",
                Cmd.removeUserFromBlockList.value,
                info={"userId": target},
            )
        except Exception:
            pass
    for device in account_b:
        target = user_a
        try:
            device.call(
                "ContactManager",
                Cmd.deleteContact.value,
                info={"userId": target, "keepConversation": True},
            )
        except Exception:
            pass
        try:
            device.call(
                "ContactManager",
                Cmd.removeUserFromBlockList.value,
                info={"userId": target},
            )
        except Exception:
            pass
    for device in (*account_a, *account_b):
        device.drain_events(timeout=0.5)
    _wait_contact_absent(account_a, user_b)
    _wait_contact_absent(account_b, user_a)


def _restore_case_state(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    account_a_devices=(),
    account_b_devices=(),
) -> None:
    account_a = _unique_devices(device_a, account_a_devices)
    account_b = _unique_devices(device_b, account_b_devices)
    restore_account_devices(account_a, user_id=user_a)
    restore_account_devices(account_b, user_id=user_b)
    _set_accept_invitation_always(account_b, assert_api, enabled=False)
    _cleanup_relation(
        device_a,
        device_b,
        user_a,
        user_b,
        account_a_devices=account_a_devices,
        account_b_devices=account_b_devices,
    )


def _set_accept_invitation_always(devices, assert_api, enabled: bool) -> None:
    for device in devices:
        set_accept_invitation_always(
            device,
            assert_api,
            device_name=_device_name(device),
            enabled=enabled,
        )


def _assert_contact_response(
    assert_api,
    response: dict,
    *,
    cmd: str,
    device_name: str,
    result,
) -> None:
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ContactManager",
            "cmd": cmd,
            "device": device_name,
            "result": result,
        },
        ignore_keys={"sequence"},
    )


def _add_contact_offline(
    device_a,
    assert_api,
    *,
    user_b: str,
    reason: str,
) -> None:
    response = device_a.call(
        "ContactManager",
        Cmd.addContact.value,
        info={"userId": user_b, "reason": reason},
    )
    _assert_contact_response(
        assert_api,
        response,
        cmd=Cmd.addContact.value,
        device_name=_device_name(device_a),
        result=user_b,
    )


def _assert_contact_event(
    assert_api,
    event: dict,
    *,
    event_type: str,
    user_id: str,
    reason: str | None = None,
) -> None:
    data = {"userId": user_id}
    if reason is not None:
        data["reason"] = reason
    assert_api.assert_response_matches(
        event,
        expected={
            "type": "event",
            "eventType": event_type,
            "data": data,
        },
        ignore_keys={"timestamp", "sequence"},
    )


def _assert_contact_event_on_devices(
    devices,
    assert_api,
    *,
    event_type: str,
    user_id: str,
    reason: str | None = None,
) -> None:
    for device in _unique_devices(None, devices):
        event = device.receive_message(
            match_event_type=event_type,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            event,
            event_type=event_type,
            user_id=user_id,
            reason=reason,
        )


def _assert_contacts(
    device,
    assert_api,
    *,
    device_name: str,
    target_user: str,
    expected_present: bool,
) -> None:
    """校验目标好友关系，不把其他历史联系人当成本用例结果。"""
    deadline = time.monotonic() + 10.0
    response = device.call("ContactManager", Cmd.getAllContactsFromDB.value, info={})
    contacts = response.get("result")
    while (
        not isinstance(contacts, list)
        or (target_user in contacts) is not expected_present
    ) and time.monotonic() < deadline:
        time.sleep(0.25)
        response = device.call("ContactManager", Cmd.getAllContactsFromDB.value, info={})
        contacts = response.get("result")
    assert_api.assert_response_matches(
        response,
        expected={
            "manager": "ContactManager",
            "cmd": Cmd.getAllContactsFromDB.value,
            "device": device_name,
        },
        ignore_keys={"sequence"},
    )
    assert isinstance(contacts, list), (
        f"getAllContactsFromDB.result 应为 list，实际 {contacts!r}"
    )
    actual_present = target_user in contacts
    assert actual_present is expected_present, (
        "联系人关系状态不符合预期: "
        f"target={target_user!r}, expected_present={expected_present}, "
        f"actual_contacts={contacts!r}"
    )


def _assert_contacts_on_devices(
    devices,
    assert_api,
    *,
    target_user: str,
    expected_present: bool,
) -> None:
    for device in _unique_devices(None, devices):
        _assert_contacts(
            device,
            assert_api,
            device_name=_device_name(device),
            target_user=target_user,
            expected_present=expected_present,
        )


def _prepare_offline_invitation(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    reason: str,
    account_a_devices=(),
    account_b_devices=(),
) -> dict:
    account_a = _unique_devices(device_a, account_a_devices)
    account_b = _unique_devices(device_b, account_b_devices)
    _cleanup_relation(
        device_a,
        device_b,
        user_a,
        user_b,
        account_a_devices=account_a_devices,
        account_b_devices=account_b_devices,
    )
    _set_accept_invitation_always(account_b, assert_api, enabled=False)
    logout_account_devices(account_b, assert_api)
    _add_contact_offline(device_a, assert_api, user_b=user_b, reason=reason)
    login_account_devices(account_b, assert_api, user_id=user_b)
    _assert_contact_event_on_devices(
        account_b,
        assert_api,
        event_type=ContactChangeEvent.INVITED.value,
        user_id=user_a,
        reason=reason,
    )
    return True


def _establish_friendship(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    account_a_devices=(),
    account_b_devices=(),
) -> None:
    account_a = _unique_devices(device_a, account_a_devices)
    account_b = _unique_devices(device_b, account_b_devices)
    _cleanup_relation(
        device_a,
        device_b,
        user_a,
        user_b,
        account_a_devices=account_a_devices,
        account_b_devices=account_b_devices,
    )
    _set_accept_invitation_always(account_b, assert_api, enabled=False)
    reason = f"offline-delete-friend-{uuid.uuid4().hex[:8]}"
    add = device_a.call(
        "ContactManager",
        Cmd.addContact.value,
        info={"userId": user_b, "reason": reason},
    )
    _assert_contact_response(
        assert_api,
        add,
        cmd=Cmd.addContact.value,
        device_name=_device_name(device_a),
        result=user_b,
    )
    _assert_contact_event_on_devices(
        account_b,
        assert_api,
        event_type=ContactChangeEvent.INVITED.value,
        user_id=user_a,
        reason=reason,
    )
    accepted = device_b.call(
        "ContactManager",
        Cmd.acceptInvitation.value,
        info={"userId": user_a},
    )
    _assert_contact_response(
        assert_api,
        accepted,
        cmd=Cmd.acceptInvitation.value,
        device_name=_device_name(device_b),
        result=user_a,
    )
    _assert_contact_event_on_devices(
        account_b, assert_api,
        event_type=ContactChangeEvent.CONTACT_ADD.value,
        user_id=user_a,
    )
    _assert_contact_event_on_devices(
        account_a, assert_api,
        event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
        user_id=user_b,
    )
    _assert_contact_event_on_devices(
        account_a, assert_api,
        event_type=ContactChangeEvent.CONTACT_ADD.value,
        user_id=user_b,
    )
    _assert_contacts_on_devices(account_a, assert_api, target_user=user_b, expected_present=True)
    _assert_contacts_on_devices(account_b, assert_api, target_user=user_a, expected_present=True)
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)


def test_contact_offline_invitation_received_after_login(
    topology,
    assert_api,
):
    """B 先离线，A 发起申请；B 登录收到邀请，但双方仍不是好友。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    account_a_devices = topology.sender_devices
    account_b_devices = topology.recipient_devices
    reason = f"offline-invite-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：让接收账号全部端点离线并发送好友申请"):
            _prepare_offline_invitation(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                reason=reason,
                account_a_devices=account_a_devices,
                account_b_devices=account_b_devices,
            )
        with _allure_step("接收账号逐端登录并验证离线好友申请已消费"):
            _assert_contacts_on_devices(account_a_devices, assert_api, target_user=user_b, expected_present=False)
            _assert_contacts_on_devices(account_b_devices, assert_api, target_user=user_a, expected_present=False)
    finally:
        _restore_case_state(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            account_a_devices=account_a_devices,
            account_b_devices=account_b_devices,
        )


def test_contact_offline_invitation_accept_after_login(
    topology,
    assert_api,
):
    """B 登录收到离线申请后同意，A 收到接受与联系人新增事件。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    account_a_devices = topology.sender_devices
    account_b_devices = topology.recipient_devices
    reason = f"offline-accept-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：发送好友申请并让接收账号恢复全部端点"):
            _prepare_offline_invitation(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                reason=reason,
                account_a_devices=account_a_devices,
                account_b_devices=account_b_devices,
            )
        with _allure_step("接收账号动作端同意好友申请并验证响应"):
            response = device_b.call(
                "ContactManager",
                Cmd.acceptInvitation.value,
                info={"userId": user_a},
            )
            _assert_contact_response(
                assert_api,
                response,
                cmd=Cmd.acceptInvitation.value,
                device_name=_device_name(device_b),
                result=user_a,
            )
        with _allure_step("验证双方全部在线端收到好友关系变更并完成本地同步"):
            _assert_contact_event_on_devices(
                account_b_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_ADD.value,
                user_id=user_a,
            )
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
                user_id=user_b,
            )
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_ADD.value,
                user_id=user_b,
            )
            _assert_contacts_on_devices(account_a_devices, assert_api, target_user=user_b, expected_present=True)
            _assert_contacts_on_devices(account_b_devices, assert_api, target_user=user_a, expected_present=True)
    finally:
        _restore_case_state(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            account_a_devices=account_a_devices,
            account_b_devices=account_b_devices,
        )


def test_contact_offline_invitation_decline_after_login(
    topology,
    assert_api,
):
    """B 登录收到离线申请后拒绝，A 收到拒绝事件且双方保持非好友。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    account_a_devices = topology.sender_devices
    account_b_devices = topology.recipient_devices
    reason = f"offline-decline-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：发送好友申请并让接收账号恢复全部端点"):
            _prepare_offline_invitation(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                reason=reason,
                account_a_devices=account_a_devices,
                account_b_devices=account_b_devices,
            )
        with _allure_step("接收账号动作端拒绝好友申请并验证响应"):
            response = device_b.call(
                "ContactManager",
                Cmd.declineInvitation.value,
                info={"userId": user_a},
            )
            _assert_contact_response(
                assert_api,
                response,
                cmd=Cmd.declineInvitation.value,
                device_name=_device_name(device_b),
                result=user_a,
            )
        with _allure_step("验证拒绝事件及双方全部端点的非好友状态"):
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.INVITATION_DECLINED.value,
                user_id=user_b,
            )
            _assert_contacts_on_devices(account_a_devices, assert_api, target_user=user_b, expected_present=False)
            _assert_contacts_on_devices(account_b_devices, assert_api, target_user=user_a, expected_present=False)
    finally:
        _restore_case_state(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            account_a_devices=account_a_devices,
            account_b_devices=account_b_devices,
        )


def test_contact_offline_requester_receives_accept_after_relogin(
    topology,
    assert_api,
):
    """B 收到申请后让 A 离线；B 同意，A 重登收到离线接受结果。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    account_a_devices = topology.sender_devices
    account_b_devices = topology.recipient_devices
    reason = f"offline-requester-accept-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：发送好友申请后让申请账号全部端点离线"):
            _prepare_offline_invitation(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                reason=reason,
                account_a_devices=account_a_devices,
                account_b_devices=account_b_devices,
            )
            logout_account_devices(account_a_devices, assert_api)
        with _allure_step("接收账号同意好友申请并验证动作端响应"):
            response = device_b.call(
                "ContactManager",
                Cmd.acceptInvitation.value,
                info={"userId": user_a},
            )
            _assert_contact_response(
                assert_api,
                response,
                cmd=Cmd.acceptInvitation.value,
                device_name=_device_name(device_b),
                result=user_a,
            )
            _assert_contact_event_on_devices(
                account_b_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_ADD.value,
                user_id=user_a,
            )
        with _allure_step("申请账号全部端点重新登录并验证离线接受事件与最终好友状态"):
            login_account_devices(account_a_devices, assert_api, user_id=user_a)
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
                user_id=user_b,
            )
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_ADD.value,
                user_id=user_b,
            )
            _assert_contacts_on_devices(account_a_devices, assert_api, target_user=user_b, expected_present=True)
            _assert_contacts_on_devices(account_b_devices, assert_api, target_user=user_a, expected_present=True)
    finally:
        _restore_case_state(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            account_a_devices=account_a_devices,
            account_b_devices=account_b_devices,
        )


def test_contact_offline_requester_receives_decline_after_relogin(
    topology,
    assert_api,
):
    """B 收到申请后让 A 离线；B 拒绝，A 重登收到离线拒绝结果。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    account_a_devices = topology.sender_devices
    account_b_devices = topology.recipient_devices
    reason = f"offline-requester-decline-{uuid.uuid4().hex[:8]}"
    try:
        with _allure_step("测试准备：发送好友申请后让申请账号全部端点离线"):
            _prepare_offline_invitation(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                reason=reason,
                account_a_devices=account_a_devices,
                account_b_devices=account_b_devices,
            )
            logout_account_devices(account_a_devices, assert_api)
        with _allure_step("接收账号拒绝好友申请并验证动作端响应"):
            response = device_b.call(
                "ContactManager",
                Cmd.declineInvitation.value,
                info={"userId": user_a},
            )
            _assert_contact_response(
                assert_api,
                response,
                cmd=Cmd.declineInvitation.value,
                device_name=_device_name(device_b),
                result=user_a,
            )
        with _allure_step("申请账号全部端点重新登录并验证离线拒绝事件与最终状态"):
            login_account_devices(account_a_devices, assert_api, user_id=user_a)
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.INVITATION_DECLINED.value,
                user_id=user_b,
            )
            _assert_contacts_on_devices(account_a_devices, assert_api, target_user=user_b, expected_present=False)
            _assert_contacts_on_devices(account_b_devices, assert_api, target_user=user_a, expected_present=False)
    finally:
        _restore_case_state(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            account_a_devices=account_a_devices,
            account_b_devices=account_b_devices,
        )


def test_contact_offline_recipient_receives_delete_after_relogin(
    topology,
    assert_api,
):
    """B 离线期间 A 删除好友；B 重登收到删除事件且双方关系清空。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    account_a_devices = topology.sender_devices
    account_b_devices = topology.recipient_devices
    try:
        with _allure_step("测试准备：建立好友关系并让接收账号全部端点离线"):
            _establish_friendship(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                account_a_devices=account_a_devices,
                account_b_devices=account_b_devices,
            )
            logout_account_devices(account_b_devices, assert_api)
        with _allure_step("申请账号删除好友并验证本端删除事件"):
            deleted = device_a.call(
                "ContactManager",
                Cmd.deleteContact.value,
                info={"userId": user_b, "keepConversation": True},
            )
            _assert_contact_response(
                assert_api,
                deleted,
                cmd=Cmd.deleteContact.value,
                device_name=_device_name(device_a),
                result=user_b,
            )
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_DELETE.value,
                user_id=user_b,
            )
        with _allure_step("接收账号全部端点重新登录并验证离线删除事件与最终状态"):
            login_account_devices(account_b_devices, assert_api, user_id=user_b)
            _assert_contact_event_on_devices(
                account_b_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_DELETE.value,
                user_id=user_a,
            )
            _assert_contacts_on_devices(account_a_devices, assert_api, target_user=user_b, expected_present=False)
            _assert_contacts_on_devices(account_b_devices, assert_api, target_user=user_a, expected_present=False)
    finally:
        _restore_case_state(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            account_a_devices=account_a_devices,
            account_b_devices=account_b_devices,
        )


def test_contact_offline_requester_receives_peer_delete_after_relogin(
    topology,
    assert_api,
):
    """A 离线期间 B 删除好友；A 重登收到删除事件且双方关系清空。"""
    device_a = topology.sender_action_device
    device_b = topology.recipient_action_device
    user_a = topology.sender_user
    user_b = topology.recipient_user
    account_a_devices = topology.sender_devices
    account_b_devices = topology.recipient_devices
    try:
        with _allure_step("测试准备：建立好友关系并让申请账号全部端点离线"):
            _establish_friendship(
                device_a,
                device_b,
                assert_api,
                user_a=user_a,
                user_b=user_b,
                account_a_devices=account_a_devices,
                account_b_devices=account_b_devices,
            )
            logout_account_devices(account_a_devices, assert_api)
        with _allure_step("接收账号删除好友并验证本端删除事件"):
            deleted = device_b.call(
                "ContactManager",
                Cmd.deleteContact.value,
                info={"userId": user_a, "keepConversation": True},
            )
            _assert_contact_response(
                assert_api,
                deleted,
                cmd=Cmd.deleteContact.value,
                device_name=_device_name(device_b),
                result=user_a,
            )
            _assert_contact_event_on_devices(
                account_b_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_DELETE.value,
                user_id=user_a,
            )
        with _allure_step("申请账号全部端点重新登录并验证离线删除事件与最终状态"):
            login_account_devices(account_a_devices, assert_api, user_id=user_a)
            _assert_contact_event_on_devices(
                account_a_devices, assert_api,
                event_type=ContactChangeEvent.CONTACT_DELETE.value,
                user_id=user_b,
            )
            _assert_contacts_on_devices(account_a_devices, assert_api, target_user=user_b, expected_present=False)
            _assert_contacts_on_devices(account_b_devices, assert_api, target_user=user_a, expected_present=False)
    finally:
        _restore_case_state(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            account_a_devices=account_a_devices,
            account_b_devices=account_b_devices,
        )
