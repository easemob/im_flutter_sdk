"""Group metadata 异常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"
SUBJECT_TOO_LONG = "s" * 1025
DESC_TOO_LONG = "d" * 4097


def test_group_update_subject_empty(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_subject"), invite_members=[])
        resp = device_a.call("GroupManager", Cmd.updateGroupSubject.value, info={"groupId": group_id, "subject": ""})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupSubject.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_subject_too_long(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_subject_len"), invite_members=[])
        resp = device_a.call(
            "GroupManager",
            Cmd.updateGroupSubject.value,
            info={"groupId": group_id, "subject": SUBJECT_TOO_LONG},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupSubject.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_description_empty(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_desc"), invite_members=[])
        resp = device_a.call("GroupManager", Cmd.updateDescription.value, info={"groupId": group_id, "description": ""})
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateDescription.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_description_too_long(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(device_a, assert_api, owner=user_a, group_name=new_group_name("ex_desc_len"), invite_members=[])
        resp = device_a.call(
            "GroupManager",
            Cmd.updateDescription.value,
            info={"groupId": group_id, "description": DESC_TOO_LONG},
        )
        assert_api.assert_response_matches(
            resp,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateDescription.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_update_subject_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.updateGroupSubject.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "subject": "new_subject"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_update_description_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.updateDescription.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "description": "new_desc"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")
