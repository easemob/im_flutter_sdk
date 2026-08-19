from __future__ import annotations

import json

import pytest
from tests.allure_helpers import _allure_step


pytestmark = [pytest.mark.phase1, pytest.mark.upgrade]


def test_message_data_after_423_to_500_upgrade(upgrade_runner):
    """Android 4.23 → 5.0 覆盖安装（同 application_id）：验证升级后消息数据保留。"""
    with _allure_step("执行 4.23 到 5.0 覆盖升级并验证消息数据保留"):
        result = upgrade_runner.run_message_retention()

        assert result.old_version == "4.23.0"
        assert result.new_version == "5.0.0"
        assert result.old_snapshot["exists"] is True
        assert result.new_snapshot["exists"] is True
        assert result.new_snapshot["messageId"] == result.old_snapshot["marker"]
        # post-upgrade 服务端操作成功：fetchHistoryMessages 返回 cursor/list 结构
        sync = result.post_upgrade_sync["result"]
        assert isinstance(sync, dict) and isinstance(sync.get("list"), list)

    try:
        import allure

        allure.attach(
            json.dumps(result.to_dict(), ensure_ascii=False, indent=2),
            "覆盖安装结果",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass
