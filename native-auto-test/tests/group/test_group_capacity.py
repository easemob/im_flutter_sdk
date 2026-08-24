"""Group 容量执行场景的无设备契约测试。"""
from __future__ import annotations

import importlib
import importlib.util

import pytest


def _capacity_module():
    """加载容量场景模块；缺失时给出可读的 TDD 失败。"""
    module_name = "src.tools.group_capacity"
    assert importlib.util.find_spec(module_name) is not None, "容量场景模块尚未实现"
    return importlib.import_module(module_name)


def test_group_capacity_defaults_to_200_and_accepts_3100_override():
    """防止默认群容量漂移，或扩容场景没有将常规建群容量切换为 3100。"""
    capacity = _capacity_module()
    original_value = capacity.get_group_create_max_count()
    capacity.reset_group_create_max_count()
    try:
        assert capacity.get_group_create_max_count() == 200

        capacity.configure_group_create_max_count(3100)

        assert capacity.get_group_create_max_count() == 3100
    finally:
        capacity.configure_group_create_max_count(original_value)


@pytest.mark.parametrize("value", [0, -1])
def test_group_capacity_rejects_non_positive_values(value: int):
    """防止错误的运行参数创建无效容量群并污染真实测试环境。"""
    capacity = _capacity_module()

    with pytest.raises(ValueError, match="positive"):
        capacity.configure_group_create_max_count(value)


def test_group_options_use_active_capacity_unless_boundary_value_is_explicit():
    """防止 3100 场景漏传给建群请求，或覆盖 maxCount=2 的容量边界用例。"""
    capacity = _capacity_module()
    from tests.group.group_helpers import build_group_options

    original_value = capacity.get_group_create_max_count()
    capacity.configure_group_create_max_count(3100)
    try:
        assert build_group_options() == {
            "style": 0,
            "maxCount": 3100,
            "inviteNeedConfirm": False,
            "ext": "auto-ext",
        }
        assert build_group_options(style=3, max_count=2) == {
            "style": 3,
            "maxCount": 2,
            "inviteNeedConfirm": False,
            "ext": "auto-ext",
        }
    finally:
        capacity.configure_group_create_max_count(original_value)


def test_group_snapshot_default_uses_active_capacity():
    """防止未传 max_user_count_value 的群快照断言在 3100 场景退回 200。"""
    capacity = _capacity_module()
    from tests.group.group_helpers import assert_group_snapshot

    class CapturingAssertions:
        expected: dict | None = None

        def assert_response_matches(self, response, *, expected, ignore_keys):
            self.expected = expected

    original_value = capacity.get_group_create_max_count()
    capacity.configure_group_create_max_count(3100)
    try:
        assertions = CapturingAssertions()
        assert_group_snapshot(
            assertions,
            {},
            cmd="getGroupSpecificationFromServer",
            group_id="group-id",
            group_name="group-name",
            owner="owner",
        )
        assert assertions.expected is not None
        assert assertions.expected["result"]["maxUserCount"] == 3100
    finally:
        capacity.configure_group_create_max_count(original_value)
