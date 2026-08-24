#!/usr/bin/env python3
"""从 API Matrix + APK 自动生成 Artifact Manifest。

用法：
    python scripts/generate_manifests.py [--platform android]
    python scripts/generate_manifests.py --version 4.23.0   # 只生成指定版本

数据来源（避免手写导致三方不一致）：
  - capabilities    ← api_matrix/{platform}.yaml 对应版本的 API 集合
  - artifactSha256  ← 对 APK 文件实际计算
  - nativeSdkSha256 ← 对原生 SDK jar 实际计算（从 flavor 依赖推断）
  - wrapperCommit   ← git rev-parse HEAD
"""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "config"
MANIFEST_DIR = CONFIG / "artifact_manifests"
PROJECT_ROOT = ROOT.parent
FLUTTER_TEST = PROJECT_ROOT / "im_flutter_test"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git_rev(short: bool = True) -> str:
    cmd = ["git", "rev-parse", "HEAD"]
    if short:
        cmd.append("--short")
    try:
        return subprocess.run(
            cmd, cwd=PROJECT_ROOT, capture_output=True, text=True, check=True
        ).stdout.strip()
    except Exception:
        return ""


def flavor_to_version(flavor: str) -> str:
    """sdk423 → 4.23.0"""
    digits = flavor.removeprefix("sdk")
    if len(digits) < 2:
        raise ValueError(f"unexpected flavor: {flavor}")
    return f"{digits[0]}.{digits[1:]}."


def _vkey(value: str) -> tuple[int, ...]:
    parts: list[int] = []
    for part in value.split("."):
        digits = "".join(char for char in part if char.isdigit())
        parts.append(int(digits or 0))
    return tuple(parts)


def native_sdk_sha256(version: str, flavor: str) -> str:
    """原生 SDK jar 的 sha256。优先从 im_flutter_sdk_android 的 libs 推断，
    找不到则返回空字符串（由环境校验兜底）。"""
    candidates = [
        FLUTTER_TEST / "android" / "app" / "libs" / f"hyphenatechat_{version}.jar",
        PROJECT_ROOT / "im_flutter_sdk_android" / "android" / "libs" / "easemob-sdk" / "libs" / f"hyphenatechat_{version}.jar",
    ]
    for path in candidates:
        if path.is_file():
            return sha256(path)
    # 兜底：搜 im_flutter_sdk_android 下所有 jar，取版本匹配的
    for jar in (PROJECT_ROOT / "im_flutter_sdk_android" / "android" / "libs").rglob("*.jar"):
        if version in jar.name:
            return sha256(jar)
    return ""


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate artifact manifests")
    parser.add_argument("--platform", default="android", choices=["android"])
    parser.add_argument("--version", default="", help="只生成指定版本，如 4.23.0")
    args = parser.parse_args()

    platform = args.platform
    artifacts_yaml = CONFIG / "artifacts.yaml"
    if not artifacts_yaml.is_file():
        print(f"[manifest] artifacts.yaml not found: {artifacts_yaml}")
        return 1
    raw = yaml.safe_load(artifacts_yaml.read_text(encoding="utf-8")) or {}
    versions = (raw.get("artifacts") or {}).get(platform) or {}

    wrapper_commit = git_rev(short=False)

    generated = []
    for version, item in versions.items():
        if args.version and version != args.version:
            continue
        # 版本对应的 API Matrix：正式基线用 {platform}.yaml，
        # 历史版本用 {platform}_legacy.yaml。
        matrix_candidates = [
            CONFIG / "api_matrix" / f"{platform}.yaml",
            CONFIG / "api_matrix" / f"{platform}_legacy.yaml",
        ]
        base_apis: set[str] = set()
        matrix_version = version
        for mp in matrix_candidates:
            if not mp.is_file():
                continue
            m = yaml.safe_load(mp.read_text(encoding="utf-8")) or {}
            base = m.get("base") or {}
            if str(base.get("version")) == version:
                base_apis = set(base.get("apis") or [])
                matrix_version = version
                break
            # 匹配 versions 增量表里的版本
            if version in (m.get("versions") or {}):
                base_apis = set(base.get("apis") or [])
                for v, delta in (m.get("versions") or {}).items():
                    if _vkey(v) > _vkey(version):
                        break
                    base_apis.update(delta.get("added") or [])
                    base_apis.difference_update(delta.get("removed") or [])
                    base_apis.update((delta.get("changed") or {}).keys())
                matrix_version = version
                break
        if not base_apis:
            print(f"[manifest] no API Matrix covers {version}, "
                  f"checked {[str(p) for p in matrix_candidates]}")
            continue

        apk_path = Path(str(item["path"]))
        if not apk_path.is_absolute():
            apk_path = (CONFIG / apk_path).resolve()
        if not apk_path.is_file():
            print(f"[manifest] skip {version}: APK not found {apk_path}")
            continue

        artifact_sha = sha256(apk_path)
        manifest_path = MANIFEST_DIR / f"{platform}-{version}.json"
        # 保留现有 Manifest 里未从 Matrix/构建推导的字段（appVersion 等）
        existing: dict = {}
        if manifest_path.is_file():
            try:
                existing = json.loads(manifest_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                existing = {}

        manifest = {
            "artifactId": f"{platform}-{version}-{artifact_sha[:7]}",
            "platform": platform,
            "sdkVersion": version,
            "appVersion": existing.get("appVersion", "1.0.0"),
            "wrapperCommit": existing.get("wrapperCommit") or wrapper_commit,
            "nativeSdkSha256": existing.get("nativeSdkSha256")
            or native_sdk_sha256(version, str(item.get("flavor") or "")),
            "artifactSha256": artifact_sha,
            "capabilities": sorted(base_apis),
        }
        manifest_path.write_text(
            json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        generated.append((version, manifest_path.name, artifact_sha[:12]))
        print(f"[manifest] generated {manifest_path.name} "
              f"(APK={artifact_sha[:12]}…, caps={len(base_apis)})")

    if not generated:
        print("[manifest] nothing generated")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
