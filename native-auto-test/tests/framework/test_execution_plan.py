from __future__ import annotations

from src.orchestrator import ExecutionPlan


def test_execution_plan_uses_direct_device_fixtures_only():
    plan = ExecutionPlan.from_direct_fixtures(
        [
            ("device_a", "assert_api"),
            ("device_a", "device_a_sec", "device_b"),
        ]
    )

    assert plan.required_roles == {
        "device_a",
        "device_a_sec",
        "device_b",
    }


def test_execution_plan_maps_upgrade_fixture_to_device_a():
    plan = ExecutionPlan.from_direct_fixtures([("upgrade_runner",)])

    assert plan.required_roles == {"device_a"}


def test_case_type_supports_three_required_topologies():
    assert ExecutionPlan.case_type(["device_a"]) == "single_device"
    assert (
        ExecutionPlan.case_type(["device_a", "device_a_sec"])
        == "same_account_multi_device"
    )
    assert (
        ExecutionPlan.case_type(["device_a", "device_b"])
        == "cross_account_multi_device"
    )
    assert (
        ExecutionPlan.case_type(["device_a", "device_a_sec", "device_b"])
        == "combined_multi_device"
    )
