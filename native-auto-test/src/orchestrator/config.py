from __future__ import annotations

import os
import re
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml


_ENV_PATTERN = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)(?::-([^}]*))?\}")


@dataclass(frozen=True)
class Artifact:
    platform: str
    sdk_version: str
    path: Path
    flavor: str
    application_id: str
    activity: str
    artifact_id: str = ""
    app_version: str = "1.0.0"
    wrapper_commit: str = ""
    native_sdk_sha256: str = ""
    capabilities: tuple[str, ...] = ()
    manifest_path: Path | None = None
    artifact_sha256: str = ""


@dataclass(frozen=True)
class RoleSpec:
    role: str
    device_name: str
    platform: str
    sdk_version: str
    runner_id: str
    account: str = ""
    avd: str | None = None
    serial: str | None = None
    browser: str | None = None


@dataclass(frozen=True)
class AccountSpec:
    slot: str
    provision: str = "rest"
    username: str = ""
    password: str = "1"


@dataclass(frozen=True)
class TopologySpec:
    """A named sender/recipient account grouping for one test family."""

    name: str
    sender_account: str
    recipient_account: str
    sender_action_device: str
    sender_devices: tuple[str, ...]
    recipient_action_device: str
    recipient_devices: tuple[str, ...]


@dataclass(frozen=True)
class Scenario:
    name: str
    startup_timeout: float
    reuse_runners: bool
    shutdown_on_finish: bool
    roles: dict[str, RoleSpec]
    accounts: dict[str, AccountSpec]
    topologies: dict[str, TopologySpec]
    hello_timeout: float = 30
    start_retry: int = 1
    keep_device_alive: bool = True
    start_emulators: bool = True
    web_app_key: str = ""


def load_scenario(path: str | Path) -> Scenario:
    source = Path(path).resolve()
    raw = _expand(yaml.safe_load(source.read_text(encoding="utf-8")) or {})
    roles: dict[str, RoleSpec] = {}
    accounts = {
        str(slot): AccountSpec(
            slot=str(slot),
            provision=str((item or {}).get("provision") or "rest"),
            username=str((item or {}).get("username") or ""),
            password=str((item or {}).get("password") or "1"),
        )
        for slot, item in (raw.get("accounts") or {}).items()
    }
    configured_roles = raw.get("devices") or raw.get("roles") or {}
    for role, item in configured_roles.items():
        role_name = str(role)
        device_name = str(
            item.get("device_name")
            or _legacy_device_name(role_name)
        )
        roles[str(role)] = RoleSpec(
            role=role_name,
            device_name=device_name,
            platform=str(item["platform"]),
            sdk_version=str(item["sdk_version"]),
            runner_id=str(item.get("runner_id") or device_name),
            account=str(item.get("account") or _default_account(role_name)),
            avd=_optional(item.get("avd")),
            serial=_optional(item.get("serial")),
            browser=_optional(item.get("browser")),
        )
    topologies = _load_topologies(raw.get("topologies"), roles)
    runner = raw.get("runner") or {}
    keep_device_alive = bool(
        runner.get(
            "keep_device_alive",
            not bool(raw.get("shutdown_on_finish", False)),
        )
    )
    return Scenario(
        name=str(raw.get("name") or source.stem),
        startup_timeout=float(
            runner.get("device_ready_timeout")
            or raw.get("startup_timeout")
            or 120
        ),
        reuse_runners=bool(raw.get("reuse_runners", True)),
        shutdown_on_finish=not keep_device_alive,
        roles=roles,
        accounts=accounts,
        topologies=topologies,
        hello_timeout=float(runner.get("hello_timeout") or 30),
        start_retry=int(runner.get("start_retry") or 1),
        keep_device_alive=keep_device_alive,
        start_emulators=bool(runner.get("start_emulators", True)),
        web_app_key=str(runner.get("web_app_key") or ""),
    )


def _load_topologies(
    raw_topologies: Any,
    roles: dict[str, RoleSpec],
) -> dict[str, TopologySpec]:
    topologies: dict[str, TopologySpec] = {}
    for name, item in (raw_topologies or {}).items():
        topology_name = str(name)
        data = item or {}
        sender = _topology_party(
            topology_name,
            "sender",
            data.get("sender"),
            roles,
        )
        recipient = _topology_party(
            topology_name,
            "recipient",
            data.get("recipient"),
            roles,
        )
        if sender["account"] == recipient["account"]:
            raise ValueError(
                f"Topology {topology_name!r} sender and recipient must use "
                "different accounts"
            )
        topologies[topology_name] = TopologySpec(
            name=topology_name,
            sender_account=sender["account"],
            recipient_account=recipient["account"],
            sender_action_device=sender["action_device"],
            sender_devices=sender["devices"],
            recipient_action_device=recipient["action_device"],
            recipient_devices=recipient["devices"],
        )
    return topologies


def _topology_party(
    topology_name: str,
    field: str,
    raw_party: Any,
    roles: dict[str, RoleSpec],
) -> dict[str, Any]:
    if not isinstance(raw_party, dict):
        raise ValueError(
            f"Topology {topology_name!r}.{field} must be a mapping"
        )
    account = str(raw_party.get("account") or "")
    if not account:
        raise ValueError(
            f"Topology {topology_name!r}.{field}.account is required"
        )
    account_devices = tuple(
        role_name
        for role_name, role in roles.items()
        if role.account == account
    )
    if not account_devices:
        raise ValueError(
            f"Topology {topology_name!r}.{field}.account={account!r} "
            "has no configured devices"
        )
    action_device = str(raw_party.get("action_device") or account_devices[0])
    if action_device not in account_devices:
        raise ValueError(
            f"Topology {topology_name!r}.{field}.action_device={action_device!r} "
            f"does not belong to account {account!r}"
        )
    # 基础投递默认只需一台动作发送端；接收账号默认覆盖全部在线端。
    # 发送方跨端同步 case 可显式设置 include_all_devices: true。
    include_all_devices = bool(
        raw_party.get("include_all_devices", field == "recipient")
    )
    devices = account_devices if include_all_devices else (action_device,)
    return {
        "account": account,
        "action_device": action_device,
        "devices": devices,
    }


def load_artifacts(path: str | Path) -> dict[tuple[str, str], Artifact]:
    source = Path(path).resolve()
    raw = _expand(yaml.safe_load(source.read_text(encoding="utf-8")) or {})
    output: dict[tuple[str, str], Artifact] = {}
    for platform, versions in (raw.get("artifacts") or {}).items():
        for version, item in (versions or {}).items():
            artifact_path = Path(str(item["path"]))
            if not artifact_path.is_absolute():
                artifact_path = (source.parent / artifact_path).resolve()
            manifest_path = None
            manifest: dict[str, Any] = {}
            if item.get("manifest"):
                manifest_path = Path(str(item["manifest"]))
                if not manifest_path.is_absolute():
                    manifest_path = (source.parent / manifest_path).resolve()
                if not manifest_path.is_file():
                    raise ValueError(
                        f"Artifact manifest does not exist: {manifest_path}"
                    )
                manifest = json.loads(
                    manifest_path.read_text(encoding="utf-8")
                )
            configured_platform = str(platform)
            configured_version = str(version)
            if manifest:
                for key, expected in (
                    ("platform", configured_platform),
                    ("sdkVersion", configured_version),
                ):
                    if str(manifest.get(key) or "") != expected:
                        raise ValueError(
                            f"Artifact manifest mismatch {key}: "
                            f"expected={expected!r}, actual={manifest.get(key)!r}"
                        )
            artifact = Artifact(
                platform=configured_platform,
                sdk_version=configured_version,
                path=artifact_path,
                flavor=str(item.get("flavor") or ""),
                application_id=str(item["application_id"]),
                activity=str(item.get("activity") or ""),
                artifact_id=str(
                    manifest.get("artifactId")
                    or item.get("artifact_id")
                    or f"{platform}-{version}-{item.get('flavor') or 'runner'}"
                ),
                app_version=str(
                    manifest.get("appVersion")
                    or item.get("app_version")
                    or "1.0.0"
                ),
                wrapper_commit=str(
                    manifest.get("wrapperCommit")
                    or item.get("wrapper_commit")
                    or ""
                ),
                native_sdk_sha256=str(
                    manifest.get("nativeSdkSha256")
                    or item.get("native_sdk_sha256")
                    or ""
                ),
                capabilities=tuple(
                    sorted(
                        str(value)
                        for value in (
                            manifest.get("capabilities")
                            or item.get("capabilities")
                            or []
                        )
                    )
                ),
                manifest_path=manifest_path,
                artifact_sha256=str(
                    manifest.get("artifactSha256")
                    or item.get("artifact_sha256")
                    or ""
                ),
            )
            output[(artifact.platform, artifact.sdk_version)] = artifact
    return output


def _expand(value: Any) -> Any:
    if isinstance(value, dict):
        return {key: _expand(item) for key, item in value.items()}
    if isinstance(value, list):
        return [_expand(item) for item in value]
    if not isinstance(value, str):
        return value

    def replace(match: re.Match[str]) -> str:
        name = match.group(1)
        fallback = match.group(2) or ""
        return os.getenv(name, fallback)

    return _ENV_PATTERN.sub(replace, value)


def _optional(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def _default_account(role: str) -> str:
    match = re.match(r"device_([a-z])", role)
    return f"account_{match.group(1)}" if match else role


def _legacy_device_name(role: str) -> str:
    suffix = role.removeprefix("device_")
    parts = suffix.split("_")
    return "device" + "".join(part.capitalize() for part in parts)
