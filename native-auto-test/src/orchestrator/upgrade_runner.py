from __future__ import annotations

import json
import time
import uuid
from dataclasses import dataclass
from typing import Any, Protocol

from .android_device import AndroidDevice
from .config import Artifact, RoleSpec
from ..rest_api.user_api import fetch_user_token


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

        def _launch_and_login(artifact, *, expect_sdk_version: str) -> dict[str, Any]:
            self.device.launch(
                artifact,
                runner_id=self.role.runner_id,
                device_name=self.role.device_name,
                topic=self.topic,
                web_socket_base_url=self.web_socket_base_url,
                run_id=self.run_id,
                logical_device=self.role.role,
                artifact_id=artifact.artifact_id,
                wrapper_commit=artifact.wrapper_commit,
                native_sdk_sha256=artifact.native_sdk_sha256,
                managed_web_socket=self.managed_web_socket,
            )
            hello = self.channel.wait_for_hello(
                expected_sdk_version=expect_sdk_version,
                expected_runner_id=self.role.runner_id,
                expected_device_name=self.role.device_name,
                expected_platform=self.role.platform,
                timeout=self.startup_timeout,
            )
            token = fetch_user_token(self.user_id, self.password).get("access_token", "")
            # 覆盖安装后新 App 的 WS runner 注册有波动（kill → 重连 → 注册），
            # "Runner is not registered" 时等 2s 重试，直到注册稳定。
            login_response = {}
            for attempt in range(5):
                login_response = self.channel.call(
                    "Client",
                    "login",
                    info={
                        "userId": self.user_id,
                        "pwdOrToken": token,
                        "isPassword": False,
                    },
                )
                if "Runner is not registered" in str(login_response):
                    time.sleep(2)
                    continue
                break
            if login_response.get("result") != self.user_id:
                raise AssertionError(
                    f"login failed: {json.dumps(login_response)}"
                )
            return hello

        # ① 先装 4.23 旧 App + 启动 + 登录（真实"旧版本写数据"前提）
        self.device.install(self.old_artifact, replace=True)
        time.sleep(3)
        _launch_and_login(self.old_artifact, expect_sdk_version=self.old_artifact.sdk_version)

        # ② 4.23 写标记消息（本地 DB 持久化 marker）
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

        # ③ 覆盖安装 5.0 + 启动 + 登录
        self.channel.clear_runner_info()
        install_output = self.device.install(self.new_artifact, replace=True)
        # Android may restore the old task briefly after `adb install -r`
        # returns. Let the package-update transition finish before the explicit
        # force-stop/start so the new runner extras win deterministically.
        time.sleep(3)
        hello = _launch_and_login(self.new_artifact, expect_sdk_version=self.new_artifact.sdk_version)
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
        # 用 fetchHistoryMessages 拉升级前保存消息的会话历史（两端矩阵都有，且同时验证消息保留）
        post_upgrade_sync = self.channel.call(
            "ChatManager",
            "fetchHistoryMessages",
            info={"convId": "phase1-upgrade", "type": 0, "pageSize": 20, "startMsgId": "", "direction": 0},
        )
        sync_result = post_upgrade_sync.get("result")
        if not isinstance(sync_result, dict) or not isinstance(sync_result.get("list"), list):
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
