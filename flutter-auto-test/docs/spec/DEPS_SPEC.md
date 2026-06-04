---
name: im-sdk-deps-spec
version: 1.0
applies_to: Android + iOS example under im_flutter_sdk
source_of_truth: scripts/update_hyphenate.sh
---

**HyphenateChat 4.19.1 Upgrade & Build Spec**

- Goal
  - Bump SDK to HyphenateChat 4.19.1 on both Android and iOS, rebuild the example apps, and verify integration.

- Preconditions
  - macOS with Xcode 15+ and CocoaPods
  - JDK 17 installed at `/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home`
  - Flutter toolchain installed (for the example app build steps)

- One‑shot command (Recommended)
  - `cd im_flutter_sdk && HY_CHAT_VERSION=4.19.1 ./scripts/update_hyphenate.sh all --build`
  - What it does:
    - Android: set `io.hyphenate:hyphenate-chat:4.19.1` and build example (`assembleDebug`) with JDK 17
    - iOS: set `s.dependency 'HyphenateChat','4.19.1'`, `pod install`, and build example for iOS Simulator

- Manual steps (if needed)
  - Android
    - Edit `im_flutter_sdk_android/android/build.gradle` and set:
      - `implementation 'io.hyphenate:hyphenate-chat:4.19.1'`
    - Ensure Gradle uses JDK 17 (`JAVA_HOME` → JDK 17), then build example:
      - `cd example/android && ./gradlew assembleDebug`
  - iOS
    - Edit `im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec` and set:
      - `s.dependency 'HyphenateChat','4.19.1'`
    - `cd example/ios && pod install`
    - Build: `xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'generic/platform=iOS Simulator' build`

- Verification checklist
  - Android file: `im_flutter_sdk_android/android/build.gradle` contains `io.hyphenate:hyphenate-chat:4.19.1`
  - iOS file: `im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec` contains `s.dependency 'HyphenateChat','4.19.1'`
  - Android build finishes with `BUILD SUCCESSFUL` and produces a debug APK
  - iOS CocoaPods output includes `Installing HyphenateChat (4.19.1)` and Xcode build succeeds

- Known pitfalls
  - Error: “Android Gradle plugin requires Java 17 to run” → ensure `JAVA_HOME` points to JDK 17 before building
  - CocoaPods warnings about master specs repo can be ignored or cleaned with `pod repo remove master`

