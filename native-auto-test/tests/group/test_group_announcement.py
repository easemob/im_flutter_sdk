"""Group announcement API 正常用例（strict）。"""
from __future__ import annotations

import pytest

from src import Cmd
from tests.group.group_helpers import (
    create_group,
    destroy_group,
    new_group_name,
)


pytestmark = [pytest.mark.client, pytest.mark.group]


def test_group_update_and_get_announcement_success(device_a, device_b, assert_api, user_a):
    group_id = ""
    announcement = new_group_name("announce")
    try:
        group_id, _ = create_group(
            device_a,
            assert_api,
            owner=user_a,
            group_name=new_group_name("announce_group"),
            invite_members=[],
        )

        resp_update = device_a.call(
            "GroupManager",
            Cmd.updateGroupAnnouncement.value,
            info={"groupId": group_id, "announcement": announcement},
        )
        assert_api.assert_response_matches(
            resp_update,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.updateGroupAnnouncement.value,
                "device": "deviceA",
                "result": None,
            },
            ignore_keys={"sequence"},
        )

        resp_get = device_a.call(
            "GroupManager",
            Cmd.getGroupAnnouncementFromServer.value,
            info={"groupId": group_id},
        )
        assert_api.assert_response_matches(
            resp_get,
            expected={
                "manager": "GroupManager",
                "cmd": Cmd.getGroupAnnouncementFromServer.value,
                "device": "deviceA",
                "result": announcement,
            },
            ignore_keys={"sequence"},
        )
    finally:
        if group_id:
            destroy_group(device_a, assert_api, group_id)
