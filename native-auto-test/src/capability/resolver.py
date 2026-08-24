from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any

import yaml


class CapabilityState(str, Enum):
    SUPPORTED = "supported"
    UNSUPPORTED = "unsupported"
    UNKNOWN = "unknown"
    CONFLICT = "conflict"


class UnsupportedCapability(RuntimeError):
    pass


class CapabilityConfigurationError(RuntimeError):
    pass


@dataclass(frozen=True)
class CapabilityDecision:
    api: str
    platform: str
    sdk_version: str
    state: CapabilityState
    reason: str
    matrix_supported: bool | None
    runner_reported: bool

    def to_dict(self) -> dict[str, Any]:
        return {
            "api": self.api,
            "platform": self.platform,
            "sdkVersion": self.sdk_version,
            "state": self.state.value,
            "reason": self.reason,
            "matrixSupported": self.matrix_supported,
            "runnerReported": self.runner_reported,
        }


class ApiMatrix:
    def __init__(
        self,
        *,
        platform: str,
        base_version: str,
        base_apis: set[str],
        versions: dict[str, dict[str, set[str]]],
    ) -> None:
        self.platform = platform
        self.base_version = base_version
        self.base_apis = base_apis
        self.versions = versions

    @classmethod
    def load(cls, path: str | Path) -> "ApiMatrix":
        source = Path(path)
        raw = yaml.safe_load(source.read_text(encoding="utf-8")) or {}
        inherited = raw.get("inherits")
        if inherited:
            parent = cls.load(source.parent / str(inherited))
            raw = {"platform": raw.get("platform") or parent.platform,
                   "base": {"version": parent.base_version, "apis": sorted(parent.base_apis)},
                   "versions": raw.get("versions") or parent.versions}
        base = raw.get("base") or {}
        versions: dict[str, dict[str, set[str]]] = {}
        for version, delta in (raw.get("versions") or {}).items():
            item = delta or {}
            versions[str(version)] = {
                "added": set(item.get("added") or []),
                "removed": set(item.get("removed") or []),
                "changed": set((item.get("changed") or {}).keys()),
            }
        return cls(
            platform=str(raw.get("platform") or ""),
            base_version=str(base.get("version") or ""),
            base_apis=set(base.get("apis") or []),
            versions=versions,
        )

    def apis_for(self, sdk_version: str) -> set[str] | None:
        if sdk_version == self.base_version:
            return set(self.base_apis)
        if sdk_version not in self.versions:
            return None
        apis = set(self.base_apis)
        for version in sorted(self.versions, key=_version_key):
            if _version_key(version) > _version_key(sdk_version):
                break
            delta = self.versions[version]
            apis.update(delta["added"])
            apis.difference_update(delta["removed"])
            # "changed" remains supported; its codec/adapter is version-specific.
            apis.update(delta["changed"])
        return apis


class CapabilityResolver:
    def __init__(self, matrix: ApiMatrix | dict[str, ApiMatrix]) -> None:
        self.matrices = {matrix.platform: matrix} if isinstance(matrix, ApiMatrix) else matrix

    def matrix_for(self, platform: str) -> ApiMatrix | None:
        return self.matrices.get(platform)

    def resolve(
        self,
        runner_info: dict[str, Any],
        manager: str,
        cmd: str,
    ) -> CapabilityDecision:
        api = f"{manager}.{cmd}"
        platform = str(runner_info.get("platform") or "")
        sdk_version = str(runner_info.get("sdkVersion") or "")
        # Runner 未上报 capabilities 字段时视为委托 API Matrix，不再做
        # reported 与 Matrix 的交叉比对；上报了（含空列表）则按实际能力比对。
        delegates = (
            "capabilities" not in runner_info
            or runner_info["capabilities"] is None
        )
        reported = (
            False
            if delegates
            else api in set(runner_info["capabilities"])
        )

        matrix = self.matrix_for(platform)
        if matrix is None:
            return CapabilityDecision(
                api,
                platform,
                sdk_version,
                CapabilityState.UNKNOWN,
                f"no API Matrix for platform={platform!r}",
                None,
                reported,
            )
        expected = matrix.apis_for(sdk_version)
        if expected is None:
            return CapabilityDecision(
                api,
                platform,
                sdk_version,
                CapabilityState.UNKNOWN,
                f"sdkVersion={sdk_version!r} is absent from API Matrix",
                None,
                reported,
            )
        matrix_supported = api in expected
        if not delegates and matrix_supported != reported:
            return CapabilityDecision(
                api,
                platform,
                sdk_version,
                CapabilityState.CONFLICT,
                "Runner hello capabilities conflict with API Matrix",
                matrix_supported,
                reported,
            )
        if not matrix_supported:
            return CapabilityDecision(
                api,
                platform,
                sdk_version,
                CapabilityState.UNSUPPORTED,
                f"{api} is not supported on {platform} SDK {sdk_version}",
                False,
                False,
            )
        return CapabilityDecision(
            api,
            platform,
            sdk_version,
            CapabilityState.SUPPORTED,
            f"{api} is supported on {platform} SDK {sdk_version}",
            True,
            True,
        )

    def require(
        self,
        runner_info: dict[str, Any],
        manager: str,
        cmd: str,
    ) -> CapabilityDecision:
        decision = self.resolve(runner_info, manager, cmd)
        if decision.state is CapabilityState.UNSUPPORTED:
            raise UnsupportedCapability(decision.reason)
        if decision.state in {CapabilityState.UNKNOWN, CapabilityState.CONFLICT}:
            raise CapabilityConfigurationError(decision.reason)
        return decision


def _version_key(value: str) -> tuple[int, ...]:
    parts: list[int] = []
    for part in value.split("."):
        digits = "".join(char for char in part if char.isdigit())
        parts.append(int(digits or 0))
    return tuple(parts)
