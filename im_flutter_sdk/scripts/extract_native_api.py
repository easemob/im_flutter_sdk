#!/usr/bin/env python3
"""Extract a wrapper-independent Hyphenate native API baseline.

Android's documented type list defines the public surface; javap supplies the
actual binary declarations. iOS public headers define the public surface;
Apple Clang's extract-api mode supplies the declarations and relationships.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import plistlib
import re
import shutil
import subprocess
import tempfile
import urllib.parse
import zipfile
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


SCRIPT_VERSION = 1


def fail(message: str) -> None:
    raise SystemExit(message)


def run(command: list[str], *, capture_stderr: bool = True) -> str:
    result = subprocess.run(
        command,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE if capture_stderr else None,
    )
    if result.returncode != 0:
        details = result.stderr or result.stdout
        fail(f"Command failed ({result.returncode}): {' '.join(command)}\n{details}")
    return result.stdout


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def sha256_files(paths: list[Path]) -> str:
    digest = hashlib.sha256()
    for path in sorted(paths, key=lambda item: item.name):
        digest.update(path.name.encode("utf-8"))
        digest.update(b"\0")
        with path.open("rb") as stream:
            while chunk := stream.read(1024 * 1024):
                digest.update(chunk)
        digest.update(b"\0")
    return digest.hexdigest()


def write_text(path: Path, value: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding="utf-8")


def write_json(path: Path, value: Any) -> None:
    write_text(path, json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def jar_class_names(jar_path: Path) -> set[str]:
    with zipfile.ZipFile(jar_path) as archive:
        return {
            name.removesuffix(".class").replace("/", ".")
            for name in archive.namelist()
            if name.endswith(".class")
        }


def documented_android_types(doc_path: Path) -> list[dict[str, str]]:
    types: dict[str, dict[str, str]] = {}
    page_pattern = re.compile(r"^(?:class|interface|enum)com_.+\.html$")
    title_pattern = re.compile(
        r"<title>[^:]*:\s*(?P<name>[^<]+?)(?:类|接口|枚举)[^<]*</title>"
    )

    with zipfile.ZipFile(doc_path) as archive:
        for entry in archive.namelist():
            filename = Path(entry).name
            if not page_pattern.match(filename) or filename.endswith("-members.html"):
                continue
            page = archive.read(entry).decode("utf-8", errors="replace")
            match = title_pattern.search(page)
            if not match:
                continue
            source_name = html.unescape(match.group("name")).strip()
            source_name = re.sub(r"\s*<\s*T\s*>\s*模板$", "", source_name).strip()
            page_kind = (
                "interface"
                if filename.startswith("interface")
                else "enum"
                if filename.startswith("enum")
                else "class"
            )
            types[source_name] = {
                "sourceName": source_name,
                "documentationKind": page_kind,
                "documentationPage": entry,
            }
    return [types[name] for name in sorted(types)]


def source_to_binary_name(source_name: str, classes: set[str]) -> str | None:
    if source_name in classes:
        return source_name
    parts = source_name.split(".")
    for boundary in range(len(parts) - 1, 0, -1):
        candidate = ".".join(parts[:boundary]) + "$" + "$".join(parts[boundary:])
        if candidate in classes:
            return candidate
    return None


def parse_javap_output(output: str) -> tuple[str, list[str]]:
    lines = [line.rstrip() for line in output.splitlines() if line.strip()]
    declaration_index = next(
        (
            index
            for index, line in enumerate(lines)
            if line.endswith("{")
            and re.search(r"\b(class|interface|enum|record)\b", line)
        ),
        None,
    )
    if declaration_index is None:
        fail(f"Unable to parse javap output:\n{output}")
    declaration = lines[declaration_index].strip()
    members = [
        line.strip()
        for line in lines[declaration_index + 1 :]
        if line.startswith("  ") and line.strip() not in {"}", "static {};"}
    ]
    return declaration, members


def extract_android(jar_path: Path, doc_path: Path, javap: Path) -> dict[str, Any]:
    classes = jar_class_names(jar_path)
    documented_types = documented_android_types(doc_path)
    unresolved: list[str] = []
    extracted: list[dict[str, Any]] = []

    for item in documented_types:
        source_name = item["sourceName"]
        binary_name = source_to_binary_name(source_name, classes)
        if binary_name is None:
            unresolved.append(source_name)
            continue
        output = run(
            [
                str(javap),
                "-classpath",
                str(jar_path),
                "-public",
                "-constants",
                binary_name,
            ]
        )
        declaration, members = parse_javap_output(output)
        extracted.append(
            {
                **item,
                "binaryName": binary_name,
                "declaration": declaration,
                "members": members,
            }
        )

    if unresolved:
        fail("Android documented types missing from JAR: " + ", ".join(unresolved))

    version_output = run(
        [str(javap), "-classpath", str(jar_path), "-public", "-constants", "com.hyphenate.chat.EMClient"]
    )
    version_match = re.search(r'VERSION\s*=\s*"([^"]+)"', version_output)
    version = version_match.group(1) if version_match else "unknown"
    return {
        "schemaVersion": 1,
        "platform": "android",
        "sdkVersion": version,
        "source": {
            "jar": jar_path.name,
            "jarSha256": sha256(jar_path),
            "documentation": doc_path.name,
            "documentationSha256": sha256(doc_path),
            "publicBoundary": "Vendor API documentation type list",
            "signatureSource": "javap -public -constants",
        },
        "types": extracted,
    }


def resolve_ios_framework(path: Path) -> Path:
    if path.suffix == ".framework":
        return path
    if path.suffix != ".xcframework":
        fail(f"Expected .framework or .xcframework, got: {path}")
    candidates = sorted(path.glob("*simulator*/HyphenateChat.framework"))
    if not candidates:
        fail(f"No simulator HyphenateChat.framework slice found in {path}")
    return candidates[0]


def extract_ios(framework_input: Path) -> dict[str, Any]:
    framework = resolve_ios_framework(framework_input)
    headers_dir = framework / "Headers"
    headers = sorted(headers_dir.glob("*.h"))
    if not headers:
        fail(f"No public headers found in {headers_dir}")

    info_path = framework / "Info.plist"
    with info_path.open("rb") as stream:
        info = plistlib.load(stream)
    version = str(info.get("CFBundleShortVersionString", "unknown"))

    xcrun = shutil.which("xcrun")
    if not xcrun:
        fail("xcrun is required to extract the iOS API")
    sdk_path = run([xcrun, "--sdk", "iphonesimulator", "--show-sdk-path"]).strip()
    clang = run([xcrun, "--sdk", "iphonesimulator", "--find", "clang"]).strip()

    with tempfile.TemporaryDirectory(prefix="hyphenate-api-") as temp_dir:
        symbol_graph = Path(temp_dir) / "HyphenateChat.symbols.json"
        command = [
            clang,
            "-extract-api",
            "--pretty-sgf",
            "-target",
            "arm64-apple-ios10.0-simulator",
            "-isysroot",
            sdk_path,
            "-F",
            str(framework.parent),
            "-fno-modules",
            "-x",
            "objective-c-header",
            *[str(header) for header in headers],
            "-o",
            str(symbol_graph),
            "-Wno-nullability-completeness",
            "-Wno-objc-property-no-attribute",
        ]
        run(command)
        graph = json.loads(symbol_graph.read_text(encoding="utf-8"))

    symbols: list[dict[str, Any]] = []
    for symbol in graph.get("symbols", []):
        uri = symbol.get("location", {}).get("uri", "")
        parsed_uri = urllib.parse.urlparse(uri)
        header = Path(urllib.parse.unquote(parsed_uri.path)).name if uri else None
        declaration = "".join(
            fragment.get("spelling", "")
            for fragment in symbol.get("declarationFragments", [])
        )
        symbols.append(
            {
                "identifier": symbol.get("identifier", {}).get("precise"),
                "kind": symbol.get("kind", {}).get("identifier"),
                "title": symbol.get("names", {}).get("title"),
                "pathComponents": symbol.get("pathComponents", []),
                "declaration": declaration,
                "header": header,
                "line": symbol.get("location", {}).get("position", {}).get("line", 0) + 1,
                "accessLevel": symbol.get("accessLevel"),
                "availability": symbol.get("availability", []),
            }
        )
    symbols.sort(key=lambda item: (item["header"] or "", item["line"], item["title"] or ""))

    return {
        "schemaVersion": 1,
        "platform": "ios",
        "sdkVersion": version,
        "source": {
            "framework": framework_input.name,
            "frameworkInfoPlistSha256": sha256(info_path),
            "frameworkBinarySha256": sha256(framework / "HyphenateChat"),
            "publicHeadersSha256": sha256_files(headers),
            "publicBoundary": "All headers in HyphenateChat.framework/Headers",
            "signatureSource": "Apple Clang -extract-api",
        },
        "headers": [header.name for header in headers],
        "symbols": symbols,
        "relationships": graph.get("relationships", []),
    }


def android_text(api: dict[str, Any]) -> str:
    lines = [
        f"Hyphenate Android SDK {api['sdkVersion']} public API",
        "Boundary: vendor-documented types; signatures: JAR public binary declarations",
        "",
    ]
    for item in api["types"]:
        lines.extend(
            [
                f"## {item['sourceName']}",
                item["declaration"],
                *[f"  {member}" for member in item["members"]],
                "}",
                "",
            ]
        )
    return "\n".join(lines)


def ios_text(api: dict[str, Any]) -> str:
    by_header: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for symbol in api["symbols"]:
        by_header[symbol["header"] or "(unknown)"].append(symbol)
    lines = [
        f"Hyphenate iOS SDK {api['sdkVersion']} public API",
        "Boundary: framework public headers; signatures: Apple Clang API symbols",
        "",
    ]
    for header in sorted(by_header):
        lines.append(f"## {header}")
        for symbol in by_header[header]:
            declaration = symbol["declaration"] or symbol["title"] or ""
            lines.append(f"[{symbol['kind']}] {declaration}")
        lines.append("")
    return "\n".join(lines)


def build_readme(android: dict[str, Any], ios: dict[str, Any]) -> str:
    android_members = sum(len(item["members"]) for item in android["types"])
    android_kinds = Counter(item["documentationKind"] for item in android["types"])
    ios_kinds = Counter(symbol["kind"] for symbol in ios["symbols"])
    kind_lines = "\n".join(
        f"| `{kind}` | {count} |" for kind, count in sorted(ios_kinds.items())
    )
    return f"""# Hyphenate 原生 SDK 5.0 API 基线

本目录只根据 Android 5.0.0 JAR/厂商 API 文档以及 iOS 5.0.0 XCFramework 生成，未读取或复用当前 Flutter wrapper。后续 Dart、Android wrapper 和 iOS wrapper 的 API 适配应以此目录为原生基准。

## 提取结果

| 平台 | 版本 | 公开边界 | 类型/符号数量 |
|---|---:|---|---:|
| Android | {android['sdkVersion']} | 厂商 API 文档中的公开类型；签名取自 JAR | {len(android['types'])} 个类型，{android_members} 个成员 |
| iOS | {ios['sdkVersion']} | `HyphenateChat.framework/Headers` 全部公开头文件 | {len(ios['headers'])} 个头文件，{len(ios['symbols'])} 个符号 |

Android 类型组成：{android_kinds.get('class', 0)} 个类、{android_kinds.get('interface', 0)} 个接口、{android_kinds.get('enum', 0)} 个枚举。

## 文件

- `android-api.json`：Android 机器可读类型、声明和成员签名。
- `android-public-api.txt`：Android 便于人工搜索和审查的完整公共签名。
- `ios-api.json`：iOS 机器可读符号、声明、来源头文件和关系。
- `ios-public-api.txt`：iOS 按头文件分组的公共声明。
- `manifest.json`：版本、输入哈希和数量，用于验证基线没有漂移。

## iOS 符号组成

| 符号类型 | 数量 |
|---|---:|
{kind_lines}

## 重新生成

```bash
python3 im_flutter_sdk/scripts/extract_native_api.py \\
  --android-jar /path/to/hyphenatechat_5.0.0.jar \\
  --android-doc /path/to/hyphenate-api-doc.zip \\
  --ios-framework /path/to/HyphenateChat.xcframework \\
  --output docs/native-api/5.0
```

Android API 文档压缩包内部项目名仍显示 `hyphenate_SDK4.0`，但其项目版本、JAR 中 `EMClient.VERSION` 以及文件版本均为 5.0.0；本基线以实际版本字段和输入哈希校验。
"""


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--android-jar", required=True, type=Path)
    parser.add_argument("--android-doc", required=True, type=Path)
    parser.add_argument("--ios-framework", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument(
        "--javap",
        type=Path,
        default=Path("/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/javap"),
    )
    args = parser.parse_args()

    for input_path in (args.android_jar, args.android_doc, args.ios_framework, args.javap):
        if not input_path.exists():
            fail(f"Input does not exist: {input_path}")

    android = extract_android(args.android_jar, args.android_doc, args.javap)
    ios = extract_ios(args.ios_framework)
    if android["sdkVersion"] != "5.0.0" or ios["sdkVersion"] != "5.0.0":
        fail(
            "Expected Android and iOS SDK 5.0.0, got "
            f"Android {android['sdkVersion']} and iOS {ios['sdkVersion']}"
        )

    output = args.output
    output.mkdir(parents=True, exist_ok=True)
    write_json(output / "android-api.json", android)
    write_text(output / "android-public-api.txt", android_text(android))
    write_json(output / "ios-api.json", ios)
    write_text(output / "ios-public-api.txt", ios_text(ios))
    write_text(output / "README.md", build_readme(android, ios))

    manifest = {
        "schemaVersion": 1,
        "extractorVersion": SCRIPT_VERSION,
        "sdkVersion": "5.0.0",
        "inputs": {
            "androidJar": android["source"],
            "iosFramework": ios["source"],
        },
        "counts": {
            "androidTypes": len(android["types"]),
            "androidMembers": sum(len(item["members"]) for item in android["types"]),
            "iosHeaders": len(ios["headers"]),
            "iosSymbols": len(ios["symbols"]),
            "iosRelationships": len(ios["relationships"]),
        },
    }
    write_json(output / "manifest.json", manifest)

    print(
        f"Extracted Android {manifest['counts']['androidTypes']} types / "
        f"{manifest['counts']['androidMembers']} members and iOS "
        f"{manifest['counts']['iosSymbols']} symbols to {output}"
    )


if __name__ == "__main__":
    main()
