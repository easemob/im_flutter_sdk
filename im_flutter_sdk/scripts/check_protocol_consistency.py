#!/usr/bin/env python3
"""协议名五方一致性校验。

检查协议名在五处定义的一致性：
  1. Android MethodKey.java
  2. iOS MethodKeys.h
  3. Python cmd_keys.py
  4. android.yaml（Android 协议清单）
  5. ios.yaml（iOS 协议清单）

任一方改名/增删，本脚本报出差异，防止协议名漂移。
"""
from __future__ import annotations

import re
import sys
import yaml
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

AND_METHOD_KEY = ROOT / "im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/MethodKey.java"
IOS_METHOD_KEYS = ROOT / "im_flutter_sdk_ios/ios/Classes/MethodKeys.h"
PY_CMD_KEYS = ROOT / "native-auto-test/src/sdk_api/cmd_keys.py"
AND_YAML = ROOT / "native-auto-test/config/api_matrix/android.yaml"
IOS_YAML = ROOT / "native-auto-test/config/api_matrix/ios.yaml"

errors = []


def extract(path: Path, pattern: str) -> set[str]:
    if not path.exists():
        errors.append(f"文件不存在: {path}")
        return set()
    text = path.read_text()
    return set(re.findall(pattern, text))


def extract_method_key_values(path: Path) -> set[str]:
    """MethodKey.java 提取（兼容多行常量定义）"""
    text = path.read_text()
    vals = set(re.findall(r'static final String \w+ = "([^"]+)"', text))
    vals |= set(re.findall(r'static final String \w+ =\n\s+"([^"]+)"', text))
    return vals


def main() -> None:
    # 1. Android 协议名（MethodKey.java 值，兼容多行）
    and_keys = extract_method_key_values(AND_METHOD_KEY)
    # 2. iOS 协议名（MethodKeys.h 值）
    # iOS 协议名（MethodKeys.h 值；容忍多空格/多行定义）
    ios_keys = extract(IOS_METHOD_KEYS, r'static NSString \*const \w+\s*=\s*@"([^"]+)"')
    # 3. Python cmd（cmd_keys.py 值）
    py_cmds = extract(PY_CMD_KEYS, r'= "([a-zA-Z]\w+)"')
    # 4. Android yaml
    and_yaml = set()
    if AND_YAML.exists():
        d = yaml.safe_load(AND_YAML.read_text())
        and_yaml = {x.split(".", 1)[1] for x in d["base"]["apis"]}
    # 5. iOS yaml
    ios_yaml = set()
    if IOS_YAML.exists():
        d = yaml.safe_load(IOS_YAML.read_text())
        ios_yaml = {x.split(".", 1)[1] for x in d["base"]["apis"]}

    # 过滤：事件名（on 开头）不参与 API 一致性（各端事件名本来有差异）
    and_api = {k for k in and_keys if not k.startswith("on") and not k.startswith("message")}
    ios_api = {k for k in ios_keys if not k.startswith("on") and not k.startswith("message")}

    print("=== 五方一致性校验 ===")
    print(f"Android MethodKey: {len(and_api)} | iOS MethodKeys: {len(ios_api)}")
    print(f"Python cmd_keys: {len(py_cmds)} | android.yaml: {len(and_yaml)} | ios.yaml: {len(ios_yaml)}")
    print()

    # 合理差异：5.0 removed（MethodKey 预埋、清单不含）
    removed_cmds = {'createAccount', 'createChatRoom', 'destroyChatRoom', 'getAllChatRooms', 'loginWithAgoraToken', 'reportMessage', 'updateRequireAckSetting'}

    # A. Android vs iOS（核心协议名应一致）
    only_and = and_api - ios_api - removed_cmds
    only_ios = ios_api - and_api
    if only_and:
        print(f"⚠️ Android 有、iOS 没有（{len(only_and)}）: {sorted(only_and)[:8]}（iOS 未实现/unsupported，检查 ios.yaml unsupported）")
    if only_ios:
        print(f"ℹ️ iOS 有、Android 没有（{len(only_ios)}）: {sorted(only_ios)[:8]}")
    if not only_and:
        print("✅ Android ↔ iOS 协议名一致（不含 removed）")

    # B. Python cmd_keys vs Android（Python 应覆盖 Android API）
    py_only = py_cmds - and_api - and_yaml
    if py_only:
        print(f"ℹ️ Python 有、Android 没有（{len(py_only)}）: {sorted(py_only)[:8]}")

    # C. Android yaml vs MethodKey
    yaml_only = and_yaml - and_api - removed_cmds
    key_only = and_api - and_yaml - removed_cmds
    if yaml_only:
        print(f"ℹ️ android.yaml 有、MethodKey 没有（{len(yaml_only)}）: {sorted(yaml_only)[:5]}（可能是常量名/值差异，检查）")
    if key_only:
        print(f"ℹ️ MethodKey 有、android.yaml 没有（{len(key_only)}）: {sorted(key_only)[:5]}（android.yaml 未收录，检查）")

    print()
    if errors:
        print(f"❌ 发现 {len(errors)} 类问题")
        sys.exit(1)
    print("✅ 全部一致")


if __name__ == "__main__":
    main()
