#!/usr/bin/env python3
"""生成 Android 原生 API/事件 与协议名（MethodKey/wrapper 转发名）的映射文件。

输入：
  - docs/native-api/<ver>/android-api.json  : javap 提取的原生类型/成员（extract_native_api.py 产物）
  - im_flutter_sdk_android/android/src/main/java/.../MethodKey.java : 协议名常量
  - im_flutter_sdk_android/android/src/base500/java/.../Wrapper*.java : wrapper 注册/事件转发

输出：
  - native-auto-test/config/api_matrix/android_mapping.yaml

用途：5.x 升级时，javap diff 原生 → 查本文件定位协议名 → 决定 wrapper 改动。
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]  # im_flutter_sdk/
keys_value: dict[str, str] = {}  # MethodKey 常量名 -> 值（wrapper_event_pairs 使用）
METHOD_KEY = ROOT / "im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/MethodKey.java"
WRAPPER_DIR = ROOT / "im_flutter_sdk_android/android/src/base500/java/com/easemob/im_flutter_sdk"
API_JSON = ROOT / "docs/native-api/5.0/android-api.json"
OUT = ROOT / "native-auto-test/config/api_matrix/android_mapping.yaml"

# 原生 manager 类 -> Flutter Manager 名
MANAGER_MAP = {
    "com.hyphenate.chat.EMClient": "Client",
    "com.hyphenate.chat.EMChatManager": "ChatManager",
    "com.hyphenate.chat.EMContactManager": "ContactManager",
    "com.hyphenate.chat.EMGroupManager": "GroupManager",
    "com.hyphenate.chat.EMChatRoomManager": "ChatRoomManager",
    "com.hyphenate.chat.EMPushManager": "PushManager",
    "com.hyphenate.chat.EMUserInfoManager": "UserInfoManager",
    "com.hyphenate.chat.EMPresenceManager": "PresenceManager",
    "com.hyphenate.chat.EMChatThreadManager": "ChatThreadManager",
    "com.hyphenate.chat.EMConversationManager": "ConversationManager",
}

KEY_RE = re.compile(r'static final String (\w+) = "([^"]+)"')
REGISTER_RE = re.compile(r"register\(MethodKey\.(\w+), this::(\w+)\)")
INVOKE_RE = re.compile(r"invokeMethod\(MethodKey\.(\w+),")
TYPE_RE = re.compile(r'data\.put\("type", "([^"]+)"\)')

# 统一通道名（事件 type 的载体，不是事件本身）
CHANNEL_EVENTS = {"onContactChanged", "onGroupChanged", "onChatRoomChanged"}


def method_key_constants() -> dict[str, str]:
    """MethodKey.java 常量: 常量名 -> 值（协议名）"""
    out = {}
    for m in KEY_RE.finditer(METHOD_KEY.read_text()):
        out[m.group(1)] = m.group(2)
    return out


def wrapper_registers() -> dict[str, tuple[str, str]]:
    """wrapper register: 协议名(值) -> (wrapper 类, wrapper 方法名)。

    注意：register(MethodKey.X, this::Y) 中 Y 可能 ≠ X 的值（如
    ConversationWrapper 的 remindType 对应 conversationRemindType），
    所以 key 用 MethodKey 常量对应的协议名值，不是 wrapper 方法名。
    """
    keys = method_key_constants()
    out = {}
    for f in sorted(WRAPPER_DIR.glob("*Wrapper.java")):
        text = f.read_text()
        for m in REGISTER_RE.finditer(text):
            const_name = m.group(1)
            proto = keys.get(const_name, const_name)
            out[proto] = (f.stem, m.group(2))
    return out


def wrapper_events() -> set[str]:
    """wrapper 转发的事件协议名: invokeMethod(MethodKey.onXxx) 的值 + type 值"""
    out = set()
    for f in WRAPPER_DIR.glob("*.java"):
        text = f.read_text()
        for m in INVOKE_RE.finditer(text):
            out.add(m.group(1))  # 常量名（与值通常一致，后续用 keys 映射）
        for m in TYPE_RE.finditer(text):
            out.add(m.group(1))
    return out


def wrapper_event_pairs() -> dict[str, set[str]]:
    """从 wrapper 源码提取「原生回调方法名 -> 转发协议名集合」映射。

    同一原生回调名（如 onAdminAdded）在 Group/ChatRoom 等不同 Listener 里
    可能转发不同协议名，故保留集合。
    规则：`public void onXxx(...)`（实现原生 Listener 接口）方法体内，
    向前扫描 12 行内的第一个 MethodKey.onYyy 或 type 值作为协议名。
    """
    pairs: dict[str, set[str]] = {}
    for f in sorted(WRAPPER_DIR.glob("*.java")):
        text = f.read_text()
        lines = text.split("\n")
        for i, line in enumerate(lines):
            m = re.match(r"\s*public void (on\w+)\(", line)
            if not m:
                continue
            native = m.group(1)
            protos: set[str] = set()
            for j in range(i + 1, min(i + 13, len(lines))):
                seg = lines[j]
                for km in re.finditer(r"MethodKey\.(on\w+)", seg):
                    v = keys_value.get(km.group(1), km.group(1))
                    if v not in CHANNEL_EVENTS:
                        protos.add(v)
                for tm in re.finditer(r'data\.put\("type", "(on\w+)"\)', seg):
                    protos.add(tm.group(1))
            if protos:
                pairs.setdefault(native, set()).update(protos)
    return pairs


def native_apis() -> dict[str, list[str]]:
    """原生 API: Manager 名 -> 方法名列表（去 async 前缀的候选）"""
    d = json.loads(API_JSON.read_text())
    out = {}
    for t in d["types"]:
        manager = MANAGER_MAP.get(t["sourceName"])
        if not manager:
            continue
        methods = []
        for m in t["members"]:
            m = m.strip()
            if not m.startswith("public") or "(" not in m:
                continue
            name = m.split("(")[0].split()[-1]
            if name.startswith("_") or "." in name or "$" in name:
                continue
            methods.append(name)
        out[manager] = methods
    return out


def native_events() -> dict[str, list[str]]:
    """原生事件: Listener 接口名 -> 回调方法名"""
    d = json.loads(API_JSON.read_text())
    out = {}
    for t in d["types"]:
        name = t["sourceName"]
        if not name.endswith("Listener"):
            continue
        methods = []
        for m in t["members"]:
            m = m.strip()
            if "(" not in m or not m.endswith(");"):
                continue
            name_m = m.split("(")[0].split()[-1]
            if name_m.startswith("on"):
                methods.append(name_m)
        if methods:
            out[name] = methods
    return out


def extract_method_body(lines: list[str], start: int) -> list[str]:
    """从方法签名行开始，括号平衡提取方法体。"""
    depth = 0
    for i in range(start, len(lines)):
        for ch in lines[i]:
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    return lines[start:i + 1]
    return lines[start:]


# 链式访问器（EMClient 的 getter / manager getter / Java 通用），不是业务调用
ACCESSOR_METHODS = {
    "getInstance", "getOptions", "getChatConfig", "getToken",
    "chatManager", "contactManager", "groupManager", "chatRoomManager", "chatroomManager",
    "pushManager", "userInfoManager", "presenceManager", "chatThreadManager",
    "conversationManager", "messageManager", "getCurrentUserManager",
    "toString", "equals", "hashCode", "clone", "getClass", "values", "valueOf",
    "getDisplayStyle", "getMessageStatusCallback", "setMessageStatusCallback",
    "getReadAckCount", "getGroupAckCount", "setLocalTime", "getMsgId",
    "getChatConfigPrivate", "isAutoLogin", "isSdkInited", "isDatabaseOpened",
    "isFCMAvailable", "isLoggedIn", "getSyncManager", "getPushManager",
    "getOptionsManager",
}


def is_listener_api(name: str) -> bool:
    """监听器注册/移除类原生方法（wrapper 内部注册，协议层不暴露）。"""
    return "Listener" in name or "setContactListener" == name


def native_names_all() -> set[str]:
    """原生方法全集：manager API + EMOptions 配置 setter + 其他配置类。"""
    out = set()
    for methods in native_apis().values():
        out.update(methods)
    # EMOptions 的 setter（update*Setting 协议调用它们）
    import json as _json
    d = _json.loads(API_JSON.read_text())
    for t in d["types"]:
        if t["sourceName"] in (
            "com.hyphenate.chat.EMOptions",
            "com.hyphenate.chat.EMClient",
        ):
            for m in t["members"]:
                mm = m.strip()
                if mm.startswith("public") and "(" in mm:
                    name = mm.split("(")[0].split()[-1]
                    if not name.startswith("_"):
                        out.add(name)
    return out


def wrapper_native_calls() -> dict[str, set[str]]:
    """从 wrapper 方法体提取「wrapper 方法名 -> 调用的原生方法名集合」。

    匹配依据：方法体内 .xxx( 的调用名 ∈ javap 原生方法集合。
    """
    native_names = native_names_all()
    out: dict[str, set[str]] = {}
    for f in sorted(WRAPPER_DIR.glob("*Wrapper.java")):
        lines = f.read_text().split("\n")
        for i, line in enumerate(lines):
            # 方法签名可能跨行（如 `void x(...)\n throws E {`），只匹配方法名开头
            m = re.match(r"\s*(?:private|protected|public)\s+\S+\s+(\w+)\(", line)
            if not m:
                continue
            meth = m.group(1)
            body = extract_method_body(lines, i)
            found = set()
            for seg in body:
                for call in re.finditer(r"\.(\w+)\(", seg):
                    name = call.group(1)
                    if name in native_names and name not in ACCESSOR_METHODS:
                        found.add(name)
            if found:
                out.setdefault(meth, set()).update(found)
    return out


def strip_async(name: str) -> str:
    """去掉 async 前缀并转小写首字母：asyncAddReaction -> addReaction"""
    if name.startswith("async") and len(name) > 5:
        return name[5].lower() + name[6:]
    return name


def main() -> None:
    global keys_value
    keys_value = method_key_constants()
    keys = keys_value
    registers = wrapper_registers()
    wrapper_evt = wrapper_events()
    evt_pairs = wrapper_event_pairs()
    native_api = native_apis()
    native_evt = native_events()

    lines = []
    lines.append("platform: android")
    lines.append(f"base_version: 5.0.0")
    lines.append("# 生成: im_flutter_sdk/scripts/extract_api_mapping.py")
    lines.append("# 用途: 升级时 javap diff 原生名 -> 查 protocol 定位 wrapper 改动")
    lines.append("")

    # ---- API 映射 ----
    lines.append("apis:")
    # 优先：wrapper 方法体提取的原生调用（最准确，覆盖改名）
    native_calls = wrapper_native_calls()
    # 协议名 -> (wrapper类, wrapper方法名) -> 原生调用名集合
    proto_to_natives: dict[str, set[str]] = {}
    for proto, (cls, meth) in registers.items():
        natives = native_calls.get(meth, set())
        # 兜底：去 async 同名
        if not natives:
            cand = strip_async(proto) if proto.startswith("async") else proto
            if cand != proto:
                natives.add(cand)
        proto_to_natives[proto] = natives

    # 原生 manager 名 -> 协议 manager 名（去 EM 前缀）
    mgr_map = {v: k for k, v in MANAGER_MAP.items()}

    # 输出：以协议名为基准
    done_native = set()
    # wrapper 类名 -> 协议 manager 名
    WRAPPER_TO_MANAGER = {
        "ClientWrapper": "Client",
        "ChatManagerWrapper": "ChatManager",
        "ContactManagerWrapper": "ContactManager",
        "GroupManagerWrapper": "GroupManager",
        "ChatRoomManagerWrapper": "ChatRoomManager",
        "PushManagerWrapper": "PushManager",
        "UserInfoManagerWrapper": "UserInfoManager",
        "PresenceManagerWrapper": "PresenceManager",
        "ChatThreadManagerWrapper": "ChatThreadManager",
        "ConversationWrapper": "ConversationManager",
        "MessageWrapper": "MessageManager",
    }

    for proto in sorted(proto_to_natives):
        natives = proto_to_natives[proto]
        # wrapper 类归属 manager
        cls = registers[proto][0]
        manager = WRAPPER_TO_MANAGER.get(cls, cls.replace("Wrapper", ""))
        if not natives:
            lines.append(f"  - manager: {manager}")
            lines.append(f"    native: null")
            lines.append(f"    protocol: {proto}")
            lines.append("    mapping: unimplemented_or_unknown")
        for nat in sorted(natives):
            done_native.add(nat)
            done_native.add(strip_async(nat))  # asyncXxx 与 Xxx 同步版视为同一 API
            done_native.add("async" + nat[0].upper() + nat[1:])  # 反向：Xxx -> asyncXxx
            mapping = "identical" if nat == proto else ("strip_async" if strip_async(nat) == proto else "derived")
            lines.append(f"  - manager: {manager}")
            lines.append(f"    native: {nat}")
            lines.append(f"    protocol: {proto}")
            lines.append(f"    mapping: {mapping}")

    # 原生有、协议层未实现
    unclassified_api = []
    listener_apis = []
    for manager, methods in native_api.items():
        for native in sorted(set(methods)):
            if native in done_native or native in ACCESSOR_METHODS:
                continue
            if is_listener_api(native):
                listener_apis.append((manager, native))
            else:
                unclassified_api.append((manager, native))
    if listener_apis:
        lines.append("")
        lines.append("  # 原生监听器注册/移除方法（wrapper 内部注册，协议层不暴露）:")
        for manager, native in sorted(listener_apis):
            lines.append(f"  - manager: {manager}")
            lines.append(f"    native: {native}")
            lines.append(f"    protocol: null")
            lines.append("    mapping: listener_api")
    if unclassified_api:
        lines.append("")
        lines.append("  # 原生 API 未在协议层实现（mapping=unknown 待人工确认：改名 or 未实现）:")
        for manager, native in sorted(unclassified_api):
            lines.append(f"  - manager: {manager}")
            lines.append(f"    native: {native}")
            lines.append(f"    protocol: null")
            lines.append("    mapping: unknown")

    # ---- 事件映射 ----
    lines.append("")
    lines.append("events:")
    all_paired: set[str] = set()
    for listener, methods in native_evt.items():
        for native in sorted(set(methods)):
            protos = evt_pairs.get(native)
            if protos:
                all_paired |= protos
                for proto in sorted(protos):
                    lines.append(f"  - listener: {listener}")
                    lines.append(f"    native: {native}")
                    lines.append(f"    protocol: {proto}")
                    lines.append(f"    mapping: {'identical' if native == proto else 'renamed'}")
            else:
                lines.append(f"  - listener: {listener}")
                lines.append(f"    native: {native}")
                lines.append(f"    protocol: null")
                lines.append("    mapping: unforwarded")

    # 协议有、原生无（自研增量）：wrapper 转发的协议名，不在「原生回调→协议」配对里，也不在原生名集合里
    lines.append("  # 协议名存在但原生无对应（自研增量/协议层自定义）:")
    native_all = {m for ms in native_evt.values() for m in ms}
    all_protocols = set(all_paired) | {keys.get(c, c) for c in wrapper_evt if c.startswith("on")}
    for p in sorted(all_protocols - all_paired - native_all):
        lines.append(f"  - listener: null")
        lines.append(f"    native: null")
        lines.append(f"    protocol: {p}")
        lines.append("    mapping: custom")

    OUT.write_text("\n".join(lines) + "\n")
    print(f"写入 {OUT}")
    print(f"  API 自动配对: {sum(1 for l in lines if l.strip().startswith('- manager:'))}")
    print(f"  事件原生项: {sum(1 for l in lines if l.strip().startswith('- listener:'))}")


if __name__ == "__main__":
    main()
