# Agora Chat SDK Project Introduction
1. Developed using a federated plugin approach, supporting both Android and iOS platforms.
2. The SDK README is available at [README](agora_chat_sdk/README.md).

## Package version

The current release is `2.0.0`. The four Dart packages (`agora_chat_sdk`, `agora_chat_sdk_interface`, `agora_chat_sdk_android`, and `agora_chat_sdk_ios`) and the iOS podspec use this version.

`2.0.0` is a valid Dart/Flutter package version: `1.4.0` is the base version and `+1` is build metadata. It is a stable version. Pub includes build metadata in version ordering, so `1.4.0 < 2.0.0 < 1.4.1`; a dependency on `^1.4.1` does not accept this release. CocoaPods also accepts the `2.0.0` podspec version.

To select this exact release, use `agora_chat_sdk: 2.0.0`; use `agora_chat_sdk: ^2.0.0` to allow later compatible versions below `2.0.0`.

References: [Dart pubspec version](https://dart.dev/tools/pub/pubspec#version), [Pub version semantics](https://pub.dev/packages/pub_semver#semantics), and [release notes](agora_chat_sdk/CHANGELOG.md).
