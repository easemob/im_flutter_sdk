"""Group 入群申请与邀请处理（正常 + 异常）。"""
from __future__ import annotations

import pytest

from src import Cmd, GroupChangeEvent
from tests.group.group_helpers import (
    assert_group_events,
    collect_group_events,
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
_NONEXISTENT_USER = "nonexistent_user_999999"


def test_group_request_to_join_and_accept_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("public_need_approval"),
            invite_members=[],
            style=2,
        )

        resp_request = device_b.call(
            "GroupManager",
            Cmd.requestToJoinPublicGroup.value,
            info={"groupId": group_id, "reason": "auto-apply-accept"},
        )
        assert_api.assert_response_matches(
            resp_request,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.requestToJoinPublicGroup.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        owner_request_events = collect_group_events(
            device_a,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onRequestToJoinReceivedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onRequestToJoinReceivedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_request_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onRequestToJoinReceivedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onRequestToJoinReceivedFromGroup"},
            expected_member=user_b,
        )

        resp_accept = device_a.call(
            "GroupManager",
            Cmd.acceptJoinApplication.value,
            info={"groupId": group_id, "userId": user_b},
        )
        assert_api.assert_response_matches(
            resp_accept,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.acceptJoinApplication.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        applicant_accept_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED.value,
                GroupChangeEvent.ON_MEMBER_JOINED.value,
                "onGroupRequestToJoinAccepted",
                "onRequestToJoinAcceptedFromGroup",
                "onMemberJoinedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onRequestToJoinAcceptedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            applicant_accept_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_ACCEPTED.value,
                GroupChangeEvent.ON_MEMBER_JOINED.value,
                "onGroupRequestToJoinAccepted",
                "onRequestToJoinAcceptedFromGroup",
                "onMemberJoinedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onRequestToJoinAcceptedFromGroup"},
            expected_member=user_b,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_request_to_join_and_decline_success(device_a, device_b, assert_api, user_a, user_b):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("public_need_decline"),
            invite_members=[],
            style=2,
        )

        resp_request = device_b.call(
            "GroupManager",
            Cmd.requestToJoinPublicGroup.value,
            info={"groupId": group_id, "reason": "auto-apply-decline"},
        )
        assert_api.assert_response_matches(
            resp_request,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.requestToJoinPublicGroup.value,
                "device": "deviceB",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        owner_request_events = collect_group_events(
            device_a,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onRequestToJoinReceivedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onRequestToJoinReceivedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            owner_request_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_RECEIVED.value,
                "onGroupRequestToJoinReceived",
                "onRequestToJoinReceivedFromGroup",
            },
            group_id=group_id,
            required_all_event_types={"onRequestToJoinReceivedFromGroup"},
            expected_member=user_b,
        )

        resp_decline = device_a.call(
            "GroupManager",
            Cmd.declineJoinApplication.value,
            info={"groupId": group_id, "userId": user_b, "reason": "auto-reject"},
        )
        assert_api.assert_response_matches(
            resp_decline,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.declineJoinApplication.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        applicant_decline_events = collect_group_events(
            device_b,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED.value,
                "onGroupRequestToJoinDeclined",
                "onRequestToJoinDeclinedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onRequestToJoinDeclinedFromGroup"},
            timeout=10.0,
        )
        assert_group_events(
            assert_api,
            applicant_decline_events,
            expected_event_types={
                GroupChangeEvent.ON_REQUEST_TO_JOIN_DECLINED.value,
                "onGroupRequestToJoinDeclined",
                "onRequestToJoinDeclinedFromGroup",
            },
            group_id=group_id,
            allow_missing_group_id=True,
            required_all_event_types={"onRequestToJoinDeclinedFromGroup"},
            expected_member=user_b,
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_request_to_join_public_group_nonexistent_group(device_b, assert_api):
    resp = device_b.call(
        "GroupManager",
        Cmd.requestToJoinPublicGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "reason": "auto-reason"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_accept_join_application_nonexistent_group(device_a, assert_api, user_b):
    resp = device_a.call(
        "GroupManager",
        Cmd.acceptJoinApplication.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "userId": user_b},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_decline_join_application_nonexistent_group(device_a, assert_api, user_b):
    resp = device_a.call(
        "GroupManager",
        Cmd.declineJoinApplication.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "userId": user_b, "reason": "auto-reject"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_accept_join_application_nonexistent_user(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("accept_nonexist_user"),
            invite_members=[],
            style=2,
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.acceptJoinApplication.value,
            info={"groupId": group_id, "userId": _NONEXISTENT_USER},
        )
        assert_api.assert_error(resp, code=600, description="doesn't exist")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_accept_invitation_from_group_without_pending_invite(device_b, assert_api):
    resp = device_b.call(
        "GroupManager",
        Cmd.acceptInvitationFromGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "inviter": "owner_x"},
    )
    assert_api.assert_error(resp, code=600, description="does not exist")


def test_group_decline_invitation_from_group_without_pending_invite(device_b, assert_api):
    resp = device_b.call(
        "GroupManager",
        Cmd.declineInvitationFromGroup.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "inviter": "owner_x", "reason": "auto-reject"},
    )
    assert_api.assert_error(resp, code=600, description="does not exist")
