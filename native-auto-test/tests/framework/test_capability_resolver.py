from __future__ import annotations

from pathlib import Path

import pytest

from src.capability import (
    ApiMatrix,
    CapabilityConfigurationError,
    CapabilityResolver,
    CapabilityState,
    UnsupportedCapability,
)


ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / "config/api_matrix/android_legacy.yaml"


def _runner(version: str, capabilities: list[str]):
    return {
        "platform": "android",
        "sdkVersion": version,
        "capabilities": capabilities,
    }


def test_added_api_is_unsupported_on_410_and_supported_on_414():
    resolver = CapabilityResolver(ApiMatrix.load(MATRIX))
    api = "GroupManager.fetchGroupMembersInfo"

    old = resolver.resolve(_runner("4.10.0", []), "GroupManager", "fetchGroupMembersInfo")
    new = resolver.resolve(_runner("4.14.0", [api]), "GroupManager", "fetchGroupMembersInfo")

    assert old.state is CapabilityState.UNSUPPORTED
    assert new.state is CapabilityState.SUPPORTED
    with pytest.raises(UnsupportedCapability):
        resolver.require(_runner("4.10.0", []), "GroupManager", "fetchGroupMembersInfo")


def test_missing_version_is_configuration_error_not_skip():
    resolver = CapabilityResolver(ApiMatrix.load(MATRIX))

    with pytest.raises(CapabilityConfigurationError):
        resolver.require(_runner("9.9.9", []), "Client", "login")


def test_runner_matrix_conflict_is_configuration_error():
    resolver = CapabilityResolver(ApiMatrix.load(MATRIX))

    decision = resolver.resolve(
        _runner("4.10.0", ["GroupManager.fetchGroupMembersInfo"]),
        "GroupManager",
        "fetchGroupMembersInfo",
    )

    assert decision.state is CapabilityState.CONFLICT
    with pytest.raises(CapabilityConfigurationError):
        resolver.require(
            _runner("4.10.0", ["GroupManager.fetchGroupMembersInfo"]),
            "GroupManager",
            "fetchGroupMembersInfo",
        )
