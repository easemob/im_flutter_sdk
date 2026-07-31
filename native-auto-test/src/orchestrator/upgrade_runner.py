from __future__ import annotations

import json
import time
import uuid
from dataclasses import dataclass
from typing import Any, Protocol

from .android_device import AndroidDevice
from .config import Artifact, RoleSpec


class DeviceChannel(Protocol):
    def call(
        self,
        manager: str,
        cmd: str,
        info: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> dict[str, Any]: ...

    def wait_for_hello(
        self,
        *,
        expected_sdk_version: str | None = None,
        expected_runner_id: str | None = None,
        expected_device_name: str | None = None,
        expected_platform: str | None = None,
        timeout: float = 120,
    ) -> dict[str, Any]: ...

    def clear_runner_info(self) -> None: ...


@dataclass(frozen=True)
class UpgradeResult:
    old_version: str
    new_version: str
    old_snapshot: dict[str, Any]
    new_snapshot: dict[str, Any]
    install_output: str
    hello: dict[str, Any]
    post_upgrade_sync: dict[str, Any]

    def to_dict(self) -> dict[str, Any]:
        return {
            "oldVersion": self.old_version,
            "newVersion": self.new_version,
            "oldSnapshot": self.old_snapshot,
            "newSnapshot": self.new_snapshot,
            "installOutput": self.install_output,
            "hello": self.hello,
            "postUpgradeSync": self.post_upgrade_sync,
        }


class UpgradeRunner:
    def __init__(
        self,
        *,
        device: AndroidDevice,
        channel: DeviceChannel,
        role: RoleSpec,
        old_artifact: Artifact,
        new_artifact: Artifact,
        topic: str,
        web_socket_base_url: str,
        startup_timeout: float,
        user_id: str,
        password: str,
        run_id: str = "",
        managed_web_socket: bool = False,
    ) -> None:
        self.device = device
        self.channel = channel
        self.role = role
        self.old_artifact = old_artifact
        self.new_artifact = new_artifact
        self.topic = topic
        self.web_socket_base_url = web_socket_base_url
        self.startup_timeout = startup_timeout
        self.user_id = user_id
        self.password = password
        self.run_id = run_id
        self.managed_web_socket = managed_web_socket

    def run_message_retention(self, marker: str | None = None) -> UpgradeResult:
        value = marker or f"upgrade-{uuid.uuid4().hex}"
        create_response = self.channel.call(
            "TestControl",
            "createUpgradeMessage",
            info={"marker": value, "conversationId": "phase1-upgrade"},
        )
        old_snapshot = _result(create_response)
        if not old_snapshot.get("exists"):
            raise AssertionError(
                f"old SDK did not persist upgrade message: {json.dumps(old_snapshot)}"
            )

        self.channel.clear_runner_info()
        install_output = self.device.install(self.new_artifact, replace=True)
        # Android may restore the old task briefly after `adb install -r`
        # returns. Let the package-update transition finish before the explicit
        # force-stop/start so the new runner extras win deterministically.
        time.sleep(3)
        self.device.launch(
            self.new_artifact,
            runner_id=self.role.runner_id,
            device_name=self.role.device_name,
            topic=self.topic,
            web_socket_base_url=self.web_socket_base_url,
            run_id=self.run_id,
            logical_device=self.role.role,
            artifact_id=self.new_artifact.artifact_id,
            wrapper_commit=self.new_artifact.wrapper_commit,
            native_sdk_sha256=self.new_artifact.native_sdk_sha256,
            managed_web_socket=self.managed_web_socket,
        )
        hello = self.channel.wait_for_hello(
            expected_sdk_version=self.new_artifact.sdk_version,
            expected_runner_id=self.role.runner_id,
            expected_device_name=self.role.device_name,
            expected_platform=self.role.platform,
            timeout=self.startup_timeout,
        )
        login_response = self.channel.call(
            "Client",
            "login",
            info={
                "userId": self.user_id,
                "pwdOrToken": self.password,
                "isPassword": True,
            },
        )
        login_result = login_response.get("result")
        if login_result != self.user_id:
            raise AssertionError(
                f"login after upgrade failed: {json.dumps(login_response)}"
            )
        new_snapshot = _result(
            self.channel.call(
                "TestControl",
                "exportUpgradeSnapshot",
                info={"marker": value},
            )
        )
        if not new_snapshot.get("exists"):
            raise AssertionError(
                f"message was lost after upgrade: {json.dumps(new_snapshot)}"
            )
        if new_snapshot.get("messageId") != value:
            raise AssertionError(
                f"message id changed after upgrade: {json.dumps(new_snapshot)}"
            )
        # P0-07 requires more than opening the local DB: after network recovery,
        # prove that the upgraded SDK can complete one real server operation.
        post_upgrade_sync = self.channel.call(
            "ContactManager",
            "getAllContactsFromServer",
            info={},
        )
        sync_result = post_upgrade_sync.get("result")
        if not isinstance(sync_result, list):
            raise AssertionError(
                "post-upgrade online sync failed: "
                f"{json.dumps(post_upgrade_sync)}"
            )
        return UpgradeResult(
            old_version=self.old_artifact.sdk_version,
            new_version=self.new_artifact.sdk_version,
            old_snapshot=old_snapshot,
            new_snapshot=new_snapshot,
            install_output=install_output,
            hello=hello,
            post_upgrade_sync=post_upgrade_sync,
        )


def _result(response: dict[str, Any]) -> dict[str, Any]:
    value = response.get("result")
    if not isinstance(value, dict):
        raise AssertionError(f"expected result object, got: {response}")
    return value
