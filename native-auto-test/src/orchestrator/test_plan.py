from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


DEVICE_ROLE_NAMES = frozenset(
    {
        "device_a",
        "device_a_sec",
        "device_b",
        "device_b_sec",
        "device_c",
        "device_c_sec",
    }
)

FIXTURE_DEVICE_REQUIREMENTS = {
    "upgrade_runner": frozenset({"device_a"}),
    "api_device_a": frozenset({"device_a"}),
    "api_device_b": frozenset({"device_b"}),
    "listener_a": frozenset({"device_a"}),
    "listener_b": frozenset({"device_b"}),
    # chat 模块 autouse：无论 Case 声明什么，都要建立好友关系（双设备）
    "ensure_friends": frozenset({"device_a", "device_b"}),
}


@dataclass(frozen=True)
class ExecutionPlan:
    required_roles: frozenset[str]

    @classmethod
    def from_direct_fixtures(
        cls,
        fixture_sets: Iterable[Iterable[str]],
        *,
        required_role_sets: Iterable[Iterable[str]] = (),
    ) -> "ExecutionPlan":
        roles: set[str] = set()
        for fixture_names in fixture_sets:
            names = set(fixture_names)
            roles.update(DEVICE_ROLE_NAMES.intersection(names))
            for fixture_name in names:
                roles.update(
                    FIXTURE_DEVICE_REQUIREMENTS.get(fixture_name, ())
                )
        for required_roles in required_role_sets:
            roles.update(required_roles)
        return cls(frozenset(roles))

    @staticmethod
    def case_type(fixture_names: Iterable[str]) -> str:
        roles = set(fixture_names).intersection(DEVICE_ROLE_NAMES)
        if len(roles) <= 1:
            return "single_device"
        account_letters = {
            role.removeprefix("device_").split("_", 1)[0]
            for role in roles
        }
        same_account_multi = any(
            f"device_{letter}" in roles
            and f"device_{letter}_sec" in roles
            for letter in account_letters
        )
        cross_account = len(account_letters) > 1
        if same_account_multi and cross_account:
            return "combined_multi_device"
        if same_account_multi:
            return "same_account_multi_device"
        return "cross_account_multi_device"
