from __future__ import annotations

import json

import pytest


pytestmark = [pytest.mark.phase1, pytest.mark.upgrade]


def test_message_data_after_410_to_414_upgrade(upgrade_runner):
    """MVP mechanism proof; production version deltas start at Android 4.23."""
    result = upgrade_runner.run_message_retention()

    assert result.old_version == "4.10.0"
    assert result.new_version == "4.14.0"
    assert result.old_snapshot["exists"] is True
    assert result.new_snapshot["exists"] is True
    assert result.new_snapshot["messageId"] == result.old_snapshot["marker"]
    assert isinstance(result.post_upgrade_sync["result"], list)

    try:
        import allure

        allure.attach(
            json.dumps(result.to_dict(), ensure_ascii=False, indent=2),
            "覆盖安装结果",
            allure.attachment_type.JSON,
        )
    except ImportError:
        pass
