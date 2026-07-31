from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .config import Artifact, RoleSpec


class RunnerRegistrationError(RuntimeError):
    pass


@dataclass(frozen=True)
class RunnerBinding:
    role: RoleSpec
    artifact: Artifact
    serial: str
    hello: dict[str, Any]


class RunnerRegistry:
    def __init__(self) -> None:
        self._bindings: dict[str, RunnerBinding] = {}

    def register(
        self,
        *,
        role: RoleSpec,
        artifact: Artifact,
        serial: str,
        hello: dict[str, Any],
    ) -> RunnerBinding:
        expected = {
            "runnerId": role.runner_id,
            "deviceName": role.device_name,
            "logicalDevice": role.role,
            "platform": role.platform,
            "sdkVersion": role.sdk_version,
            "artifactId": artifact.artifact_id,
            "appVersion": artifact.app_version,
            "wrapperCommit": artifact.wrapper_commit,
            "nativeSdkSha256": artifact.native_sdk_sha256,
        }
        mismatches = {
            key: {"expected": value, "actual": hello.get(key)}
            for key, value in expected.items()
            if value and str(hello.get(key)) != str(value)
        }
        if artifact.capabilities:
            actual_capabilities = {
                str(value) for value in (hello.get("capabilities") or [])
            }
            expected_capabilities = set(artifact.capabilities)
            # When hello reports empty capabilities the Runner delegates
            # capability declaration to the artifact manifest / API Matrix.
            if actual_capabilities and actual_capabilities != expected_capabilities:
                mismatches["capabilities"] = {
                    "expected": sorted(expected_capabilities),
                    "actual": sorted(actual_capabilities),
                }
        if mismatches:
            raise RunnerRegistrationError(
                f"runner hello does not match scenario role={role.role}: {mismatches}"
            )
        for existing_role, existing in self._bindings.items():
            if existing_role == role.role:
                continue
            collisions = {}
            if existing.serial == serial:
                collisions["serial"] = serial
            for key in ("runnerId", "deviceName"):
                if str(existing.hello.get(key)) == str(hello.get(key)):
                    collisions[key] = hello.get(key)
            if collisions:
                raise RunnerRegistrationError(
                    "runner binding is not unique: "
                    f"role={role.role!r} conflicts with role={existing_role!r}: "
                    f"{collisions}"
                )
        binding = RunnerBinding(role, artifact, serial, hello)
        self._bindings[role.role] = binding
        return binding

    def get(self, role: str) -> RunnerBinding:
        try:
            return self._bindings[role]
        except KeyError as error:
            raise RunnerRegistrationError(f"role {role!r} is not registered") from error

    @property
    def bindings(self) -> dict[str, RunnerBinding]:
        return dict(self._bindings)
