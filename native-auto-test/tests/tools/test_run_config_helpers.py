"""run.sh 配置解析/桥接渲染 helper 测试（不启模拟器、不联网）。"""
from __future__ import annotations

import os
import subprocess
from pathlib import Path

HELPERS = (
    Path(__file__).resolve().parents[2]
    / "skills"
    / "im-flutter-run"
    / "scripts"
    / "config_helpers.sh"
)


def _run(script: str, **env_overrides: str) -> subprocess.CompletedProcess:
    env = dict(os.environ)
    env.pop("IM_TEST_CONFIG", None)
    env.pop("IM_BRIDGE_CONFIG", None)
    env.update(env_overrides)
    return subprocess.run(
        ["bash", "-c", script],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
    )


def _source() -> str:
    return f"set -euo pipefail\nsource {HELPERS!s}\n"


def test_resolve_prefers_cli(tmp_path: Path) -> None:
    cli_env = tmp_path / "cli-env.yaml"
    cli_env.write_text("app: {}\n", encoding="utf-8")
    cli_bridge = tmp_path / "cli-bridge.yaml"
    cli_bridge.write_text("websocket: {}\n", encoding="utf-8")
    env_override = tmp_path / "env-override.yaml"
    env_override.write_text("app: {}\n", encoding="utf-8")

    proc = _run(
        _source()
        + f'resolve_config_files "{tmp_path}" "{cli_env}" "{cli_bridge}"\n'
        + 'printf "%s\\n%s\\n" "$ENV_CONFIG" "$BRIDGE_CONFIG"\n',
        IM_TEST_CONFIG=str(env_override),
    )
    assert proc.returncode == 0, proc.stderr
    lines = proc.stdout.strip().splitlines()
    assert lines[0] == str(cli_env.resolve())
    assert lines[1] == str(cli_bridge.resolve())


def test_resolve_uses_env_override_when_no_cli(tmp_path: Path) -> None:
    env_override = tmp_path / "env-override.yaml"
    env_override.write_text("app: {}\n", encoding="utf-8")
    bridge_override = tmp_path / "bridge-override.yaml"
    bridge_override.write_text("websocket: {}\n", encoding="utf-8")

    proc = _run(
        _source()
        + f'resolve_config_files "{tmp_path}" "" ""\n'
        + 'printf "%s\\n%s\\n" "$ENV_CONFIG" "$BRIDGE_CONFIG"\n',
        IM_TEST_CONFIG=str(env_override),
        IM_BRIDGE_CONFIG=str(bridge_override),
    )
    assert proc.returncode == 0, proc.stderr
    lines = proc.stdout.strip().splitlines()
    assert lines[0] == str(env_override.resolve())
    assert lines[1] == str(bridge_override.resolve())


def test_resolve_uses_repo_defaults(tmp_path: Path) -> None:
    (tmp_path / "config").mkdir()
    env_default = tmp_path / "config" / "config.yaml"
    env_default.write_text("app: {}\n", encoding="utf-8")
    bridge_default = tmp_path / "config" / "bridge.yaml"
    bridge_default.write_text("websocket: {}\n", encoding="utf-8")

    proc = _run(
        _source()
        + f'resolve_config_files "{tmp_path}" "" ""\n'
        + 'printf "%s\\n%s\\n" "$ENV_CONFIG" "$BRIDGE_CONFIG"\n'
    )
    assert proc.returncode == 0, proc.stderr
    lines = proc.stdout.strip().splitlines()
    assert lines[0] == str(env_default.resolve())
    assert lines[1] == str(bridge_default.resolve())


def test_resolve_missing_env_fails(tmp_path: Path) -> None:
    proc = _run(
        _source()
        + f'resolve_config_files "{tmp_path}" "{tmp_path / "missing.yaml"}" ""\n'
    )
    assert proc.returncode != 0
    assert "环境配置文件不存在" in proc.stderr


def test_resolve_missing_bridge_fails(tmp_path: Path) -> None:
    env_file = tmp_path / "env.yaml"
    env_file.write_text("app: {}\n", encoding="utf-8")
    proc = _run(
        _source()
        + f'resolve_config_files "{tmp_path}" "{env_file}" "{tmp_path / "missing-bridge.yaml"}"\n'
    )
    assert proc.returncode != 0
    assert "桥接配置文件不存在" in proc.stderr


def test_render_lane_bridge_rewrites_only_port(tmp_path: Path) -> None:
    src = tmp_path / "bridge.yaml"
    src.write_text(
        "\n".join(
            [
                'websocket:',
                '  base_url: "ws://127.0.0.1:4000/iov/websocket/dual"',
                '  default_topic: "adc"',
                'topics:',
                '  deviceA: adc',
                '',
            ]
        ),
        encoding="utf-8",
    )
    dst = tmp_path / "lane.yaml"
    proc = _run(
        _source() + f'render_lane_bridge "{src}" "{dst}" "40102"\n'
    )
    assert proc.returncode == 0, proc.stderr
    text = dst.read_text(encoding="utf-8")
    assert "ws://127.0.0.1:40102/iov/websocket/dual" in text
    assert '"adc"' in text
    assert "deviceA: adc" in text


def test_render_lane_bridge_unquoted(tmp_path: Path) -> None:
    src = tmp_path / "bridge.yaml"
    src.write_text(
        "websocket:\n  base_url: ws://127.0.0.1:4000/iov/websocket/dual\n",
        encoding="utf-8",
    )
    dst = tmp_path / "lane.yaml"
    proc = _run(_source() + f'render_lane_bridge "{src}" "{dst}" "40107"\n')
    assert proc.returncode == 0, proc.stderr
    assert "ws://127.0.0.1:40107/iov/websocket/dual" in dst.read_text(encoding="utf-8")
