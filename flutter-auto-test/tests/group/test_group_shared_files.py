"""Group 共享文件（正常 + 异常）。"""
from __future__ import annotations

from pathlib import Path

import pytest

from src import Cmd
from tests.group.group_helpers import create_group, destroy_group, new_group_name


pytestmark = [pytest.mark.client, pytest.mark.group]


_NONEXISTENT_GROUP_ID = "nonexistent_group_999999"


def test_group_upload_shared_file_current_invalid_file_behavior(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("shared_file_upload"),
            invite_members=[],
        )

        tmp_file = Path("/private/tmp/group_shared_upload_auto.txt")
        tmp_file.write_text("group-shared-file-content", encoding="utf-8")

        resp_upload = device_a.call(
            "GroupManager",
            Cmd.uploadGroupSharedFile.value,
            info={"groupId": group_id, "filePath": str(tmp_file)},
        )
        assert_api.assert_error(resp_upload, code=401, description="Invalid file")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)


def test_group_upload_shared_file_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.uploadGroupSharedFile.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "filePath": "/private/tmp/x.txt"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_download_shared_file_nonexistent_group_current_behavior(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.downloadGroupSharedFile.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "fileId": "1", "savePath": "/private/tmp"},
    )
    assert_api.assert_response_matches(
        resp,
        expected={
            "manager": "GroupManager",
            "cmd": Cmd.downloadGroupSharedFile.value,
            "device": "deviceA",
            "result": True,
        },
        ignore_keys={"sequence"},
    )


def test_group_remove_shared_file_nonexistent_group(device_a, assert_api):
    resp = device_a.call(
        "GroupManager",
        Cmd.removeGroupSharedFile.value,
        info={"groupId": _NONEXISTENT_GROUP_ID, "fileId": "1"},
    )
    assert_api.assert_error(resp, code=600, description="do not find this group")


def test_group_upload_shared_file_invalid_path(device_a, assert_api, user_a):
    group_id = ""
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("shared_file_invalid"),
            invite_members=[],
        )
        resp = device_a.call(
            "GroupManager",
            Cmd.uploadGroupSharedFile.value,
            info={"groupId": group_id, "filePath": "/private/tmp/this_file_should_not_exist_123456789.txt"},
        )
        assert_api.assert_error(resp, code=401, description="Invalid file")
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
