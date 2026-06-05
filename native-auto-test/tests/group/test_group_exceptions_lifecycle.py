"""Group lifecycle 异常用例（strict）。"""
from __future__ import annotations

import os
import pytest

from src import Cmd
from src.tools.response_match import ne


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


def test_group_create_group_empty_name(device_a, assert_api, user_a):
    resp = device_a.call(
        "GroupManager",
        Cmd.createGroup.value,
        info={
            "groupName": "",
            "desc": "auto-test group",
            "inviteMembers": [],
            "inviteReason": "auto-case",
            "options": {
                "style": 0,
                "maxCount": 200,
                "inviteNeedConfirm": False,
                "ext": "auto-ext",
            },
        },
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.createGroup.value,
            "device": "deviceA",
            "result": {
                "owner": user_a,
                "ext": "auto-ext",
                "permissionType": 2,
                "isAllMemberMuted": False,
                "adminList": [],
                "avatarUrl": "",
                "groupId": ne(""),
                "memberCount": 1,
                "isMemberOnly": True,
                "muteList": [],
                "isMemberAllowToInvite": False,
                "messageBlocked": False,
                "memberList": [],
                "blockList": [],
                "name": "",
                "maxUserCount": 200,
                "isDisabled": False,
                "desc": "auto-test group",
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )
    gid = ((resp.get("result") or {}).get("groupId")) if isinstance(resp.get("result"), dict) else None
    assert isinstance(gid, str) and gid, f"createGroup 空群名返回应包含可销毁的 groupId: {resp}"
    # 清理由该异常场景产生的群，避免污染环境
    resp_destroy = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": gid})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.destroyGroup.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.parametrize(
    ("case_name", "overrides"),
    [
        (
            "avatar_url_empty",
            {"avatarUrl": ""},
        ),
        (
            "desc_empty",
            {"desc": ""},
        ),
        (
            "invite_members_empty",
            {"inviteMembers": []},
        ),
        (
            "invite_reason_empty",
            {"inviteReason": ""},
        ),
        (
            "options_ext_empty",
            {"options": {"style": 0, "maxCount": 200, "inviteNeedConfirm": False, "ext": ""}},
        ),
    ],
)
def test_group_create_group_optional_fields_empty(device_a, assert_api, user_a, case_name, overrides):
    base_info = {
        "groupName": f"cg_optional_{case_name}",
        "desc": "auto-test group",
        "inviteMembers": [],
        "inviteReason": "auto-case",
        "options": {
            "style": 0,
            "maxCount": 200,
            "inviteNeedConfirm": False,
            "ext": "auto-ext",
        },
    }
    for key, value in overrides.items():
        base_info[key] = value

    resp = device_a.call("GroupManager", Cmd.createGroup.value, info=base_info)
    result = resp.get("result") if isinstance(resp.get("result"), dict) else {}
    expected_desc = base_info["desc"]
    expected_ext = base_info["options"]["ext"]
    expected_avatar = base_info.get("avatarUrl", "")
    expected_member_count = 1 + len(base_info["inviteMembers"])

    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.createGroup.value,
            "device": "deviceA",
            "result": {
                "owner": user_a,
                "ext": expected_ext,
                "permissionType": 2,
                "isAllMemberMuted": False,
                "adminList": [],
                "avatarUrl": expected_avatar,
                "groupId": ne(""),
                "memberCount": expected_member_count,
                "isMemberOnly": True,
                "muteList": [],
                "isMemberAllowToInvite": False,
                "messageBlocked": False,
                "memberList": [],
                "blockList": [],
                "name": base_info["groupName"],
                "maxUserCount": 200,
                "isDisabled": False,
                "desc": expected_desc,
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )

    gid = result.get("groupId")
    assert isinstance(gid, str) and gid, f"{case_name}: createGroup 返回中未获取到 groupId: {resp}"
    resp_destroy = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": gid})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.destroyGroup.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_group_create_group_max_count_less_than_invite_members(device_a, assert_api, user_b, user_c):
    resp = device_a.call(
        "GroupManager",
        Cmd.createGroup.value,
        info={
            "groupName": "cg_maxcount_lt_invites",
            "desc": "auto-test group",
            "inviteMembers": [user_b, user_c],
            "inviteReason": "auto-case",
            "options": {
                "style": 0,
                "maxCount": 1,
                "inviteNeedConfirm": False,
                "ext": "auto-ext",
            },
        },
    )
    assert_api.assert_error(resp, code=604, description="The group member capacity is reached")


@pytest.mark.parametrize(
    ("case_name", "overrides", "expect_error"),
    [
        ("group_name_space_only", {"groupName": " "}, None),
        (
            "group_name_too_long_256",
            {"groupName": "g" * 256},
            {"code": 300, "description": "Server is unreachable"},
        ),
        (
            "group_name_too_long_512",
            {"groupName": "g" * 512},
            {"code": 300, "description": "Server is unreachable"},
        ),
        ("group_name_control_chars", {"groupName": "cg_ctrl_\x01\x02"}, None),
        ("avatar_url_not_url", {"avatarUrl": "abc"}, None),
        ("avatar_url_ftp_protocol", {"avatarUrl": "ftp://example.com/group-avatar.png"}, None),
        (
            "avatar_url_too_long",
            {"avatarUrl": "https://example.com/" + ("a" * 2048)},
            {"code": 110, "description": "avatar length is too big"},
        ),
    ],
)
def test_group_create_group_name_and_avatar_abnormal_inputs(
    device_a, assert_api, user_a, case_name, overrides, expect_error
):
    base_info = {
        "groupName": f"cg_abnormal_{case_name}",
        "desc": "auto-test group",
        "inviteMembers": [],
        "inviteReason": "auto-case",
        "options": {
            "style": 0,
            "maxCount": 200,
            "inviteNeedConfirm": False,
            "ext": "auto-ext",
        },
    }
    for key, value in overrides.items():
        base_info[key] = value

    resp = device_a.call("GroupManager", Cmd.createGroup.value, info=base_info)
    if expect_error is not None:
        assert_api.assert_error(resp, code=expect_error["code"], description=expect_error["description"])
        return

    result = resp.get("result") if isinstance(resp.get("result"), dict) else {}
    expected_name = base_info["groupName"]
    expected_avatar = base_info.get("avatarUrl", "")

    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.createGroup.value,
            "device": "deviceA",
            "result": {
                "owner": user_a,
                "ext": "auto-ext",
                "permissionType": 2,
                "isAllMemberMuted": False,
                "adminList": [],
                "avatarUrl": expected_avatar,
                "groupId": ne(""),
                "memberCount": 1,
                "isMemberOnly": True,
                "muteList": [],
                "isMemberAllowToInvite": False,
                "messageBlocked": False,
                "memberList": [],
                "blockList": [],
                "name": expected_name,
                "maxUserCount": 200,
                "isDisabled": False,
                "desc": "auto-test group",
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )

    gid = result.get("groupId")
    assert isinstance(gid, str) and gid, f"{case_name}: createGroup 返回中未获取到 groupId: {resp}"
    resp_destroy = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": gid})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.destroyGroup.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.parametrize(
    ("case_name", "overrides", "expect_error"),
    [
        ("desc_too_long_513", {"desc": "d" * 513}, None),
        ("invite_reason_too_long_1025", {"inviteReason": "r" * 1025}, None),
        ("options_ext_too_long_1025", {"options": {"style": 0, "maxCount": 200, "inviteNeedConfirm": False, "ext": "e" * 1025}}, None),
        (
            "options_max_count_zero",
            {"options": {"style": 0, "maxCount": 0, "inviteNeedConfirm": False, "ext": "auto-ext"}},
            {"code": 110, "description": "maxUsers should be greater than 0"},
        ),
        (
            "options_max_count_negative",
            {"options": {"style": 0, "maxCount": -1, "inviteNeedConfirm": False, "ext": "auto-ext"}},
            {"code": 110, "description": "maxUsers should be greater than 0"},
        ),
        ("options_style_out_of_range", {"options": {"style": 99, "maxCount": 200, "inviteNeedConfirm": False, "ext": "auto-ext"}}, None),
    ],
)
def test_group_create_group_desc_reason_options_abnormal_inputs(
    device_a, assert_api, user_a, case_name, overrides, expect_error
):
    discovering = os.getenv("CASES_DISCOVER", "0") in ("1", "true", "True")
    base_info = {
        "groupName": f"cg_abnormal_{case_name}",
        "desc": "auto-test group",
        "inviteMembers": [],
        "inviteReason": "auto-case",
        "options": {
            "style": 0,
            "maxCount": 200,
            "inviteNeedConfirm": False,
            "ext": "auto-ext",
        },
    }
    for key, value in overrides.items():
        base_info[key] = value

    resp = device_a.call("GroupManager", Cmd.createGroup.value, info=base_info)
    result = resp.get("result") if isinstance(resp.get("result"), dict) else {}
    is_error = isinstance(result, dict) and "code" in result and "description" in result

    if expect_error is not None:
        assert_api.assert_error(resp, code=expect_error["code"], description=expect_error["description"])
        return

    if is_error:
        if discovering:
            print(f"[DISCOVER][{case_name}] createGroup error response: {resp}")
            return
        pytest.fail(f"{case_name}: 未冻结的错误响应，请先 discovery 后补 strict 断言: {resp}")

    expected_desc = base_info["desc"]
    expected_ext = base_info["options"]["ext"]
    expected_member_count = 1 + len(base_info["inviteMembers"])

    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.createGroup.value,
            "device": "deviceA",
            "result": {
                "owner": user_a,
                "ext": expected_ext,
                "permissionType": 2,
                "isAllMemberMuted": False,
                "adminList": [],
                "avatarUrl": "",
                "groupId": ne(""),
                "memberCount": expected_member_count,
                "isMemberOnly": True,
                "muteList": [],
                "isMemberAllowToInvite": False,
                "messageBlocked": False,
                "memberList": [],
                "blockList": [],
                "name": base_info["groupName"],
                "maxUserCount": base_info["options"]["maxCount"],
                "isDisabled": False,
                "desc": expected_desc,
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )

    gid = result.get("groupId")
    assert isinstance(gid, str) and gid, f"{case_name}: createGroup 返回中未获取到 groupId: {resp}"
    resp_destroy = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": gid})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.destroyGroup.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.parametrize(
    ("case_name", "invite_members", "expect_error"),
    [
        ("invite_members_duplicate_user", ["{{user_b}}", "{{user_b}}"], None),
        (
            "invite_members_contains_nonexistent_user",
            ["{{user_b}}", "nonexistent_user_99999"],
            {"code": 600, "description": "doesn't exist!"},
        ),
    ],
)
def test_group_create_group_invite_members_abnormal_inputs(
    device_a, assert_api, user_a, user_b, case_name, invite_members, expect_error
):
    discovering = os.getenv("CASES_DISCOVER", "0") in ("1", "true", "True")
    resolved_invite_members = [user_b if x == "{{user_b}}" else x for x in invite_members]
    info = {
        "groupName": f"cg_abnormal_{case_name}",
        "desc": "auto-test group",
        "inviteMembers": resolved_invite_members,
        "inviteReason": "auto-case",
        "options": {
            "style": 0,
            "maxCount": 200,
            "inviteNeedConfirm": False,
            "ext": "auto-ext",
        },
    }

    resp = device_a.call("GroupManager", Cmd.createGroup.value, info=info)
    result = resp.get("result") if isinstance(resp.get("result"), dict) else {}
    is_error = isinstance(result, dict) and "code" in result and "description" in result

    if expect_error is not None:
        assert_api.assert_error(resp, code=expect_error["code"], description=expect_error["description"])
        return

    if is_error:
        if discovering:
            print(f"[DISCOVER][{case_name}] createGroup error response: {resp}")
            return
        pytest.fail(f"{case_name}: 未冻结的错误响应，请先 discovery 后补 strict 断言: {resp}")

    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.createGroup.value,
            "device": "deviceA",
            "result": {
                "owner": user_a,
                "ext": "auto-ext",
                "permissionType": 2,
                "isAllMemberMuted": False,
                "adminList": [],
                "avatarUrl": "",
                "groupId": ne(""),
                "memberCount": 1 + len(set(resolved_invite_members)),
                "isMemberOnly": True,
                "muteList": [],
                "isMemberAllowToInvite": False,
                "messageBlocked": False,
                "memberList": [],
                "blockList": [],
                "name": info["groupName"],
                "maxUserCount": 200,
                "isDisabled": False,
                "desc": "auto-test group",
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )

    gid = result.get("groupId")
    assert isinstance(gid, str) and gid, f"{case_name}: createGroup 返回中未获取到 groupId: {resp}"
    resp_destroy = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": gid})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.destroyGroup.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


@pytest.mark.parametrize(
    ("case_name", "field", "value", "expect_error"),
    [
        ("group_name_tabs", "groupName", "\tgroup\tname\t", None),
        ("group_name_mixed_symbols", "groupName", "group-name_!@#$%^&*()[]{}", None),
        ("desc_space_only", "desc", " ", None),
        ("desc_multiline", "desc", "line1\nline2\nline3", None),
        ("desc_symbols", "desc", "desc_!@#$%^&*()[]{}<>?/\\|", None),
        ("invite_reason_space_only", "inviteReason", " ", None),
        ("invite_reason_multiline", "inviteReason", "reason line1\nreason line2", None),
        ("invite_reason_symbols", "inviteReason", "reason_!@#$%^&*()[]{}<>?/\\|", None),
    ],
)
def test_group_create_group_text_fields_additional_inputs(
    device_a, assert_api, user_a, case_name, field, value, expect_error
):
    base_info = {
        "groupName": f"cg_text_{case_name}",
        "desc": "auto-test group",
        "inviteMembers": [],
        "inviteReason": "auto-case",
        "options": {
            "style": 0,
            "maxCount": 200,
            "inviteNeedConfirm": False,
            "ext": "auto-ext",
        },
    }
    base_info[field] = value

    resp = device_a.call("GroupManager", Cmd.createGroup.value, info=base_info)
    if expect_error is not None:
        assert_api.assert_error(resp, code=expect_error["code"], description=expect_error["description"])
        return

    expected_name = base_info["groupName"]
    expected_desc = base_info["desc"]
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.createGroup.value,
            "device": "deviceA",
            "result": {
                "owner": user_a,
                "ext": "auto-ext",
                "permissionType": 2,
                "isAllMemberMuted": False,
                "adminList": [],
                "avatarUrl": "",
                "groupId": ne(""),
                "memberCount": 1,
                "isMemberOnly": True,
                "muteList": [],
                "isMemberAllowToInvite": False,
                "messageBlocked": False,
                "memberList": [],
                "blockList": [],
                "name": expected_name,
                "maxUserCount": 200,
                "isDisabled": False,
                "desc": expected_desc,
                "announcement": "",
            },
        },
        ignore_keys={"sequence"},
    )

    result = resp.get("result") if isinstance(resp.get("result"), dict) else {}
    gid = result.get("groupId")
    assert isinstance(gid, str) and gid, f"{case_name}: createGroup 返回中未获取到 groupId: {resp}"
    resp_destroy = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": gid})
    assert_api.assert_response_matches(
        resp_destroy,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.destroyGroup.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_group_destroy_group_nonexistent(device_a, assert_api):
    resp = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": _NONEXISTENT_GROUP_ID})
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_destroy_group_empty_group_id(device_a, assert_api):
    resp = device_a.call("GroupManager", Cmd.destroyGroup.value, info={"groupId": ""})
    assert_api.assert_error(resp, code=600, description="Group ID is invalid")


def test_group_get_group_with_id_nonexistent(device_a, assert_api):
    resp = device_a.call("GroupManager", Cmd.getGroupWithId.value, info={"groupId": _NONEXISTENT_GROUP_ID})
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.getGroupWithId.value,
            "device": "deviceA",
            "result": None,
        },
        ignore_keys={"sequence"},
    )


def test_group_get_group_from_server_nonexistent(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.getGroupSpecificationFromServer.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "fetchMembers": True},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")
