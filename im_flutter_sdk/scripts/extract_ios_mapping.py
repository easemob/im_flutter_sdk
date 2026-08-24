#!/usr/bin/env python3
"""生成 iOS 5.0 原生 API/事件 与协议名（MethodKeys.h）的映射文件。

输入：
  - docs/native-api/5.0/ios-api.json : iOS 5.0 原生基线（extract_native_api.py 产物）
  - im_flutter_sdk_ios/ios/Classes/MethodKeys.h : 协议名常量

输出：
  - native-auto-test/config/api_matrix/ios_mapping.yaml

协议名与 Android 对齐（以 Android 为准）；原生名是 iOS 自己的（delegate 风格）。
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / "docs/native-api/5.0/ios-api.json"
METHOD_KEYS_H = ROOT / "im_flutter_sdk_ios/ios/Classes/MethodKeys.h"
OUT = ROOT / "native-auto-test/config/api_matrix/ios_mapping.yaml"

# iOS 原生接口 -> 协议 Manager 名
MANAGER_MAP = {
    "IEMClient": "Client",
    "IEMChatManager": "ChatManager",
    "IEMContactManager": "ContactManager",
    "IEMGroupManager": "GroupManager",
    "IEMChatroomManager": "ChatRoomManager",
    "IEMThreadManager": "ChatThreadManager",
    "IEMUserInfoManager": "UserInfoManager",
    "IEMPresenceManager": "PresenceManager",
    "IEMPushManager": "PushManager",
    "IEMConversation": "ConversationManager",
}


def protocol_constants() -> set[str]:
    """MethodKeys.h 的协议名（常量值）"""
    out = set()
    for m in re.finditer(r'static NSString \*const \w+ = @"([^"]+)"', METHOD_KEYS_H.read_text()):
        out.add(m.group(1))
    return out


def native_symbols() -> dict[str, dict]:
    """iOS 原生：delegate 事件 + 接口 API"""
    d = json.loads(API_JSON.read_text())
    events: dict[str, list[str]] = {}   # delegate 协议 -> 方法
    apis: dict[str, list[str]] = {}     # 接口 -> 方法
    for s in d["symbols"]:
        if s.get("kind") != "objective-c.method":
            continue
        path = str(s.get("pathComponents", ""))
        title = s.get("title", "")
        # delegate 事件
        if "Delegate" in path:
            parts = s.get("pathComponents", [])
            proto = next((p for p in parts if "Delegate" in p), path)
            events.setdefault(proto, []).append(title)
        # 接口 API
        for iface, mgr in MANAGER_MAP.items():
            if iface in path:
                apis.setdefault(mgr, []).append(title)
                break
    return {"events": events, "apis": apis}


def selector_base(name: str) -> str:
    """Objective-C 方法名去参数冒号：deleteConversation:isDeleteMessages: -> deleteConversation"""
    return name.split(":")[0] if ":" in name else name


def main() -> None:
    protos = protocol_constants()
    sym = native_symbols()

    lines = []
    lines.append("platform: ios")
    lines.append("base_version: 5.0.0")
    lines.append("# 生成: im_flutter_sdk/scripts/extract_ios_mapping.py")
    lines.append("# 协议名与 Android 对齐（以 Android 为准）；原生名为 iOS 5.0 基线")
    lines.append("")

    # ---- API 映射 ----
    lines.append("apis:")
    paired = set()
    for mgr, methods in sorted(sym["apis"].items()):
        for title in sorted(set(methods)):
            base = selector_base(title)
            if base in protos:
                lines.append(f"  - manager: {mgr}")
                lines.append(f"    native: {title}")
                lines.append(f"    protocol: {base}")
                lines.append(f"    mapping: {'identical' if base == title else 'strip_params'}")
                paired.add(base)
            else:
                lines.append(f"  - manager: {mgr}")
                lines.append(f"    native: {title}")
                lines.append(f"    protocol: null")
                lines.append("    mapping: unknown")

    # 协议名有、iOS 原生无对应
    all_native = {selector_base(t) for ms in sym["apis"].values() for t in ms}
    for p in sorted(protos - paired - all_native):
        if p.startswith("on"):
            continue  # 事件协议名在 events 段处理
        lines.append("  # 协议名存在但 iOS 接口无对应（待确认）:")
        break
    for p in sorted(protos - paired - all_native):
        if not p.startswith("on"):
            lines.append(f"  - manager: null")
            lines.append(f"    native: null")
            lines.append(f"    protocol: {p}")
            lines.append("    mapping: unpaired_protocol")

    # ---- 事件映射（delegate）----
    lines.append("")
    lines.append("events:")
    for proto, methods in sorted(sym["events"].items()):
        for title in sorted(set(methods)):
            base = selector_base(title)
            if base in protos:
                lines.append(f"  - delegate: {proto}")
                lines.append(f"    native: {title}")
                lines.append(f"    protocol: {base}")
                lines.append(f"    mapping: {'identical' if base == title else 'strip_params'}")
            else:
                lines.append(f"  - delegate: {proto}")
                lines.append(f"    native: {title}")
                lines.append(f"    protocol: null")
                lines.append("    mapping: unforwarded_or_renamed")

    OUT.write_text("\n".join(lines) + "\n")
    print(f"写入 {OUT}")
    print(f"  API: {sum(1 for l in lines if l.strip().startswith('- manager:'))} 条")
    print(f"  事件: {sum(1 for l in lines if l.strip().startswith('- delegate:'))} 条")


if __name__ == "__main__":
    main()
