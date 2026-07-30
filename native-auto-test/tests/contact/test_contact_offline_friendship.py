"""好友申请离线链路：接收方/申请方重新登录后的事件与关系状态。"""
from __future__ import annotations

import uuid

import pytest

from src import Cmd
from src.sdk_api.event_keys import ContactChangeEvent
from src.test_flow.offline_test_flow import (
    login_preserving_offline_events,
    logout_for_offline,
    restore_user_login,
    set_accept_invitation_always,
)


pytestmark = [pytest.mark.client, pytest.mark.contact]


def _cleanup_relation(device_a, device_b, user_a: str, user_b: str) -> None:
    for device, target in ((device_a, user_b), (device_b, user_a)):
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
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)


def _restore_case_state(
    device_a,
    device_b,
    *,
    user_a: str,
    user_b: str,
) -> None:
    restore_user_login(device_a, user_id=user_a)
    restore_user_login(device_b, user_id=user_b)
    try:
        device_b.call(
            "Client",
            Cmd.updateAcceptInvitationAlways.value,
            info={"acceptInvitationAlways": False},
        )
    except Exception:
        pass
    _cleanup_relation(device_a, device_b, user_a, user_b)


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
        device_name="deviceA",
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


def _assert_contacts(
    device,
    assert_api,
    *,
    device_name: str,
    expected: list[str],
) -> None:
    response = device.call(
        "ContactManager",
        Cmd.getAllContactsFromServer.value,
        info={},
    )
    _assert_contact_response(
        assert_api,
        response,
        cmd=Cmd.getAllContactsFromServer.value,
        device_name=device_name,
        result=expected,
    )


def _prepare_offline_invitation(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
    reason: str,
) -> dict:
    _cleanup_relation(device_a, device_b, user_a, user_b)
    set_accept_invitation_always(
        device_b,
        assert_api,
        device_name="deviceB",
        enabled=False,
    )
    logout_for_offline(device_b, assert_api, device_name="deviceB")
    _add_contact_offline(device_a, assert_api, user_b=user_b, reason=reason)
    login_preserving_offline_events(
        device_b,
        assert_api,
        device_name="deviceB",
        user_id=user_b,
    )
    invited = device_b.receive_message(
        match_event_type=ContactChangeEvent.INVITED.value,
        timeout=20.0,
    )
    assert invited is not None, "B 重新登录后未收到离线好友申请"
    _assert_contact_event(
        assert_api,
        invited,
        event_type=ContactChangeEvent.INVITED.value,
        user_id=user_a,
        reason=reason,
    )
    return invited


def _establish_friendship(
    device_a,
    device_b,
    assert_api,
    *,
    user_a: str,
    user_b: str,
) -> None:
    _cleanup_relation(device_a, device_b, user_a, user_b)
    set_accept_invitation_always(
        device_b,
        assert_api,
        device_name="deviceB",
        enabled=False,
    )
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
        device_name="deviceA",
        result=user_b,
    )
    invited = device_b.receive_message(
        match_event_type=ContactChangeEvent.INVITED.value,
        timeout=20.0,
    )
    _assert_contact_event(
        assert_api,
        invited,
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
        device_name="deviceB",
        result=user_a,
    )
    added_on_b = device_b.receive_message(
        match_event_type=ContactChangeEvent.CONTACT_ADD.value,
        timeout=20.0,
    )
    _assert_contact_event(
        assert_api,
        added_on_b,
        event_type=ContactChangeEvent.CONTACT_ADD.value,
        user_id=user_a,
    )
    accepted_on_a = device_a.receive_message(
        match_event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
        timeout=20.0,
    )
    _assert_contact_event(
        assert_api,
        accepted_on_a,
        event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
        user_id=user_b,
    )
    added_on_a = device_a.receive_message(
        match_event_type=ContactChangeEvent.CONTACT_ADD.value,
        timeout=20.0,
    )
    _assert_contact_event(
        assert_api,
        added_on_a,
        event_type=ContactChangeEvent.CONTACT_ADD.value,
        user_id=user_b,
    )
    _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[user_b])
    _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[user_a])
    device_a.drain_events(timeout=0.5)
    device_b.drain_events(timeout=0.5)


def test_contact_offline_invitation_received_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 先离线，A 发起申请；B 登录收到邀请，但双方仍不是好友。"""
    reason = f"offline-invite-{uuid.uuid4().hex[:8]}"
    try:
        _prepare_offline_invitation(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            reason=reason,
        )
        _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[])
        _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[])
    finally:
        _restore_case_state(device_a, device_b, user_a=user_a, user_b=user_b)


def test_contact_offline_invitation_accept_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 登录收到离线申请后同意，A 收到接受与联系人新增事件。"""
    reason = f"offline-accept-{uuid.uuid4().hex[:8]}"
    try:
        _prepare_offline_invitation(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            reason=reason,
        )
        response = device_b.call(
            "ContactManager",
            Cmd.acceptInvitation.value,
            info={"userId": user_a},
        )
        _assert_contact_response(
            assert_api,
            response,
            cmd=Cmd.acceptInvitation.value,
            device_name="deviceB",
            result=user_a,
        )
        added_on_b = device_b.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_ADD.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            added_on_b,
            event_type=ContactChangeEvent.CONTACT_ADD.value,
            user_id=user_a,
        )
        accepted = device_a.receive_message(
            match_event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            accepted,
            event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
            user_id=user_b,
        )
        added = device_a.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_ADD.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            added,
            event_type=ContactChangeEvent.CONTACT_ADD.value,
            user_id=user_b,
        )
        _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[user_b])
        _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[user_a])
    finally:
        _restore_case_state(device_a, device_b, user_a=user_a, user_b=user_b)


def test_contact_offline_invitation_decline_after_login(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 登录收到离线申请后拒绝，A 收到拒绝事件且双方保持非好友。"""
    reason = f"offline-decline-{uuid.uuid4().hex[:8]}"
    try:
        _prepare_offline_invitation(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            reason=reason,
        )
        response = device_b.call(
            "ContactManager",
            Cmd.declineInvitation.value,
            info={"userId": user_a},
        )
        _assert_contact_response(
            assert_api,
            response,
            cmd=Cmd.declineInvitation.value,
            device_name="deviceB",
            result=user_a,
        )
        declined = device_a.receive_message(
            match_event_type=ContactChangeEvent.INVITATION_DECLINED.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            declined,
            event_type=ContactChangeEvent.INVITATION_DECLINED.value,
            user_id=user_b,
        )
        _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[])
        _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[])
    finally:
        _restore_case_state(device_a, device_b, user_a=user_a, user_b=user_b)


def test_contact_offline_requester_receives_accept_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 收到申请后让 A 离线；B 同意，A 重登收到离线接受结果。"""
    reason = f"offline-requester-accept-{uuid.uuid4().hex[:8]}"
    try:
        _prepare_offline_invitation(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            reason=reason,
        )
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        response = device_b.call(
            "ContactManager",
            Cmd.acceptInvitation.value,
            info={"userId": user_a},
        )
        _assert_contact_response(
            assert_api,
            response,
            cmd=Cmd.acceptInvitation.value,
            device_name="deviceB",
            result=user_a,
        )
        added_on_b = device_b.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_ADD.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            added_on_b,
            event_type=ContactChangeEvent.CONTACT_ADD.value,
            user_id=user_a,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        accepted = device_a.receive_message(
            match_event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            accepted,
            event_type=ContactChangeEvent.INVITATION_ACCEPTED.value,
            user_id=user_b,
        )
        added = device_a.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_ADD.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            added,
            event_type=ContactChangeEvent.CONTACT_ADD.value,
            user_id=user_b,
        )
        _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[user_b])
        _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[user_a])
    finally:
        _restore_case_state(device_a, device_b, user_a=user_a, user_b=user_b)


def test_contact_offline_requester_receives_decline_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 收到申请后让 A 离线；B 拒绝，A 重登收到离线拒绝结果。"""
    reason = f"offline-requester-decline-{uuid.uuid4().hex[:8]}"
    try:
        _prepare_offline_invitation(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
            reason=reason,
        )
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        response = device_b.call(
            "ContactManager",
            Cmd.declineInvitation.value,
            info={"userId": user_a},
        )
        _assert_contact_response(
            assert_api,
            response,
            cmd=Cmd.declineInvitation.value,
            device_name="deviceB",
            result=user_a,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        declined = device_a.receive_message(
            match_event_type=ContactChangeEvent.INVITATION_DECLINED.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            declined,
            event_type=ContactChangeEvent.INVITATION_DECLINED.value,
            user_id=user_b,
        )
        _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[])
        _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[])
    finally:
        _restore_case_state(device_a, device_b, user_a=user_a, user_b=user_b)


def test_contact_offline_recipient_receives_delete_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """B 离线期间 A 删除好友；B 重登收到删除事件且双方关系清空。"""
    try:
        _establish_friendship(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
        )
        logout_for_offline(device_b, assert_api, device_name="deviceB")
        deleted = device_a.call(
            "ContactManager",
            Cmd.deleteContact.value,
            info={"userId": user_b, "keepConversation": True},
        )
        _assert_contact_response(
            assert_api,
            deleted,
            cmd=Cmd.deleteContact.value,
            device_name="deviceA",
            result=user_b,
        )
        deleted_on_a = device_a.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_DELETE.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            deleted_on_a,
            event_type=ContactChangeEvent.CONTACT_DELETE.value,
            user_id=user_b,
        )
        login_preserving_offline_events(
            device_b,
            assert_api,
            device_name="deviceB",
            user_id=user_b,
        )
        deleted_on_b = device_b.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_DELETE.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            deleted_on_b,
            event_type=ContactChangeEvent.CONTACT_DELETE.value,
            user_id=user_a,
        )
        _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[])
        _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[])
    finally:
        _restore_case_state(device_a, device_b, user_a=user_a, user_b=user_b)


def test_contact_offline_requester_receives_peer_delete_after_relogin(
    device_a,
    device_b,
    assert_api,
    user_a,
    user_b,
):
    """A 离线期间 B 删除好友；A 重登收到删除事件且双方关系清空。"""
    try:
        _establish_friendship(
            device_a,
            device_b,
            assert_api,
            user_a=user_a,
            user_b=user_b,
        )
        logout_for_offline(device_a, assert_api, device_name="deviceA")
        deleted = device_b.call(
            "ContactManager",
            Cmd.deleteContact.value,
            info={"userId": user_a, "keepConversation": True},
        )
        _assert_contact_response(
            assert_api,
            deleted,
            cmd=Cmd.deleteContact.value,
            device_name="deviceB",
            result=user_a,
        )
        deleted_on_b = device_b.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_DELETE.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            deleted_on_b,
            event_type=ContactChangeEvent.CONTACT_DELETE.value,
            user_id=user_a,
        )
        login_preserving_offline_events(
            device_a,
            assert_api,
            device_name="deviceA",
            user_id=user_a,
        )
        deleted_on_a = device_a.receive_message(
            match_event_type=ContactChangeEvent.CONTACT_DELETE.value,
            timeout=20.0,
        )
        _assert_contact_event(
            assert_api,
            deleted_on_a,
            event_type=ContactChangeEvent.CONTACT_DELETE.value,
            user_id=user_b,
        )
        _assert_contacts(device_a, assert_api, device_name="deviceA", expected=[])
        _assert_contacts(device_b, assert_api, device_name="deviceB", expected=[])
    finally:
        _restore_case_state(device_a, device_b, user_a=user_a, user_b=user_b)
