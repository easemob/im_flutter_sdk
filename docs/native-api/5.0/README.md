# Hyphenate 原生 SDK 5.0 API 基线

本目录只根据 Android 5.0.0 JAR/厂商 API 文档以及 iOS 5.0.0 XCFramework 生成，未读取或复用当前 Flutter wrapper。后续 Dart、Android wrapper 和 iOS wrapper 的 API 适配应以此目录为原生基准。

## 提取结果

| 平台 | 版本 | 公开边界 | 类型/符号数量 |
|---|---:|---|---:|
| Android | 5.0.0 | 厂商 API 文档中的公开类型；签名取自 JAR | 101 个类型，1513 个成员 |
| iOS | 5.0.0 | `HyphenateChat.framework/Headers` 全部公开头文件 | 72 个头文件，1175 个符号 |

Android 类型组成：59 个类、16 个接口、26 个枚举。

## 文件

- `android-api.json`：Android 机器可读类型、声明和成员签名。
- `android-public-api.txt`：Android 便于人工搜索和审查的完整公共签名。
- `ios-api.json`：iOS 机器可读符号、声明、来源头文件和关系。
- `ios-public-api.txt`：iOS 按头文件分组的公共声明。
- `manifest.json`：版本、输入哈希和数量，用于验证基线没有漂移。

## iOS 符号组成

| 符号类型 | 数量 |
|---|---:|
| `objective-c.class` | 51 |
| `objective-c.enum` | 34 |
| `objective-c.enum.case` | 304 |
| `objective-c.macro` | 10 |
| `objective-c.method` | 414 |
| `objective-c.property` | 332 |
| `objective-c.protocol` | 20 |
| `objective-c.type.method` | 10 |

## 重新生成

```bash
python3 im_flutter_sdk/scripts/extract_native_api.py \
  --android-jar /path/to/hyphenatechat_5.0.0.jar \
  --android-doc /path/to/hyphenate-api-doc.zip \
  --ios-framework /path/to/HyphenateChat.xcframework \
  --output docs/native-api/5.0
```

Android API 文档压缩包内部项目名仍显示 `hyphenate_SDK4.0`，但其项目版本、JAR 中 `EMClient.VERSION` 以及文件版本均为 5.0.0；本基线以实际版本字段和输入哈希校验。
