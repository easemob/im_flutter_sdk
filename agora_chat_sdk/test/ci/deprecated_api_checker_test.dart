import 'package:flutter_test/flutter_test.dart';

import '../../tool/ci/deprecated_api_checker.dart';

/// Excerpts below are copied verbatim from real build logs (javac with
/// `-Xlint:deprecation`, clang with `-Wdeprecated-declarations` in an
/// xcodebuild `-quiet` log), including the noise lines that must not match.
const String _androidLog = '''
> Task :agora_chat_sdk_android:compileDebugJavaWithJavac
/home/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_android/android/src/main/java/com/easemob/agora_chat_sdk/ChatManagerWrapper.java:502: warning: [deprecation] downloadAttachment(EMMessage) in EMChatManager has been deprecated
/home/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_android/android/src/main/java/com/easemob/agora_chat_sdk/ChatManagerWrapper.java:545: warning: [deprecation] downloadThumbnail(EMMessage) in EMChatManager has been deprecated
/home/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_android/android/src/main/java/com/easemob/agora_chat_sdk/ChatManagerWrapper.java:588: warning: [deprecation] downloadAttachment(EMMessage) in EMChatManager has been deprecated
/home/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_android/android/src/main/java/com/easemob/agora_chat_sdk/EMHelper.java:878: warning: [deprecation] setThumbnailSecret(String) in EMImageMessageBody has been deprecated
/home/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_android/android/src/main/java/com/easemob/agora_chat_sdk/EMHelper.java:1567: warning: [deprecation] setFrom(String) in EMFetchMessageOption has been deprecated
warning: unknown enum constant AnnotationRetention.BINARY
  reason: class file for kotlin.annotation.AnnotationRetention not found
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
''';

const String _iosLog = '''
/Users/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/agora_chat_sdk_ios/ChatroomHelper.m:23:29: warning: 'muteList' is deprecated: Use muteMembers instead [-Wdeprecated-declarations]
/Users/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/agora_chat_sdk_ios/FetchServerMessagesOptionHelper.m:18:13: warning: 'from' is deprecated: Use fromIds instead [-Wdeprecated-declarations]
/Users/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/agora_chat_sdk_ios/PushManagerWrapper.m:193:65: warning: incompatible pointer types sending 'NSString *' to parameter of type 'NSData * _Nonnull' [-Wincompatible-pointer-types]
warning: Building targets in manual order is deprecated - check "Parallelize build for command-line builds" in the project editor
/Users/runner/work/agora_chat_sdk/agora_chat_sdk/agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/agora_chat_sdk_ios/SilentModeHelper.m:1:1: warning: 'legacyFlag' is deprecated [-Wdeprecated-declarations]
/Users/runner/workbench/ios/Pods/HyphenateChat/HyphenateChat.xcframework/ios-arm64/EMClient.h:12:1: warning: 'podsOnly' is deprecated [-Wdeprecated-declarations]
''';

void main() {
  group('parseDeprecatedApiLog', () {
    test('parses javac deprecation warnings and drops other compiler noise',
        () {
      final result = parseDeprecatedApiLog(
        _androidLog,
        platform: DeprecatedApiPlatform.android,
      );

      expect(result.skippedCompile, isFalse);
      expect(
        result.findings.map((finding) => finding.toJson()).toList(),
        <Map<String, Object?>>[
          <String, Object?>{
            'file': 'agora_chat_sdk_android/android/src/main/java/com/easemob/'
                'agora_chat_sdk/ChatManagerWrapper.java',
            'line': 502,
            'api': 'downloadAttachment(EMMessage)',
            'declaringClass': 'EMChatManager',
          },
          <String, Object?>{
            'file': 'agora_chat_sdk_android/android/src/main/java/com/easemob/'
                'agora_chat_sdk/ChatManagerWrapper.java',
            'line': 545,
            'api': 'downloadThumbnail(EMMessage)',
            'declaringClass': 'EMChatManager',
          },
          <String, Object?>{
            'file': 'agora_chat_sdk_android/android/src/main/java/com/easemob/'
                'agora_chat_sdk/ChatManagerWrapper.java',
            'line': 588,
            'api': 'downloadAttachment(EMMessage)',
            'declaringClass': 'EMChatManager',
          },
          <String, Object?>{
            'file': 'agora_chat_sdk_android/android/src/main/java/com/easemob/'
                'agora_chat_sdk/EMHelper.java',
            'line': 878,
            'api': 'setThumbnailSecret(String)',
            'declaringClass': 'EMImageMessageBody',
          },
          <String, Object?>{
            'file': 'agora_chat_sdk_android/android/src/main/java/com/easemob/'
                'agora_chat_sdk/EMHelper.java',
            'line': 1567,
            'api': 'setFrom(String)',
            'declaringClass': 'EMFetchMessageOption',
          },
        ],
      );
    });

    test(
        'parses clang deprecation warnings with and without a replacement hint',
        () {
      final result = parseDeprecatedApiLog(
        _iosLog,
        platform: DeprecatedApiPlatform.ios,
      );

      expect(
        result.findings.map((finding) => finding.toString()).toList(),
        <String>[
          'agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/agora_chat_sdk_ios/'
              'ChatroomHelper.m:23 muteList',
          'agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/agora_chat_sdk_ios/'
              'FetchServerMessagesOptionHelper.m:18 from',
          'agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/agora_chat_sdk_ios/'
              'SilentModeHelper.m:1 legacyFlag',
        ],
      );
      expect(result.findings.first.reason, 'Use muteMembers instead');
      expect(result.findings.last.reason, isEmpty);
      expect(
        result.findings.last.toJson(),
        <String, Object?>{
          'file': 'agora_chat_sdk_ios/ios/agora_chat_sdk_ios/Sources/'
              'agora_chat_sdk_ios/SilentModeHelper.m',
          'line': 1,
          'api': 'legacyFlag',
        },
      );
    });

    test('keeps wrapper warnings inside a Flutter --verbose trace', () {
      final result = parseDeprecatedApiLog(
        '[        ] /Users/runner/agora_chat_sdk_ios/ios/agora_chat_sdk_ios/'
        'Sources/agora_chat_sdk_ios/ChatroomHelper.m:23:29: warning: '
        "'muteList' is deprecated: Use muteMembers instead "
        '[-Wdeprecated-declarations]\n'
        '[+120 ms]             note: first deprecated in iOS 5.0\n',
        platform: DeprecatedApiPlatform.ios,
      );

      expect(result.findings.single.location, endsWith('ChatroomHelper.m:23'));
    });

    test('deduplicates a warning repeated by several compiler invocations', () {
      final repeated =
          '${_iosLog.split('\n').first}\n${_iosLog.split('\n').first}\n';

      final result = parseDeprecatedApiLog(
        repeated,
        platform: DeprecatedApiPlatform.ios,
      );

      expect(result.findings, hasLength(1));
    });

    test('reports a reused Gradle compile instead of an empty result', () {
      final result = parseDeprecatedApiLog(
        '> Task :agora_chat_sdk_android:compileDebugJavaWithJavac UP-TO-DATE\n'
        'BUILD SUCCESSFUL in 3s\n',
        platform: DeprecatedApiPlatform.android,
      );

      expect(result.findings, isEmpty);
      expect(result.skippedCompile, isTrue);
    });

    test('reports a build-cache hit as a reused compile', () {
      final result = parseDeprecatedApiLog(
        '> Task :agora_chat_sdk_android:compileDebugJavaWithJavac FROM-CACHE\n',
        platform: DeprecatedApiPlatform.android,
      );

      expect(result.skippedCompile, isTrue);
    });

    test('accepts an empty log', () {
      final result = parseDeprecatedApiLog(
        '',
        platform: DeprecatedApiPlatform.android,
      );

      expect(result.findings, isEmpty);
      expect(result.skippedCompile, isFalse);
    });
  });

  group('renderDeprecatedApiMarkdown', () {
    test('summarises both platforms and lists the call sites', () {
      final report = renderDeprecatedApiMarkdown(
        <DeprecatedApiScanResult>[
          parseDeprecatedApiLog(
            _androidLog,
            platform: DeprecatedApiPlatform.android,
          ),
          parseDeprecatedApiLog(_iosLog, platform: DeprecatedApiPlatform.ios),
        ],
        generatedAt: '2026-09-21 15:00:00',
      );

      expect(report, contains('生成时间：2026-09-21 15:00:00'));
      expect(report, contains('| android | 5 |'));
      expect(report, contains('| ios | 3 |'));
      expect(report, contains('| 合计 | 8 |'));
      expect(
        report,
        contains(
          '### `agora_chat_sdk_android/android/src/main/java/com/easemob/'
          'agora_chat_sdk/ChatManagerWrapper.java:502`',
        ),
      );
      expect(report, contains('- API：`downloadAttachment(EMMessage)`'));
      expect(report, contains('- 声明于：`EMChatManager`'));
      expect(report, contains('- 替代：Use muteMembers instead'));
    });

    test('names the platform that was not scanned', () {
      final report = renderDeprecatedApiMarkdown(
        <DeprecatedApiScanResult>[
          parseDeprecatedApiLog(
            _iosLog,
            platform: DeprecatedApiPlatform.ios,
          ),
        ],
        generatedAt: '2026-09-21 15:00:00',
      );

      expect(report, contains('未扫描平台：android'));
    });

    test('renders an empty result explicitly', () {
      final report = renderDeprecatedApiMarkdown(
        <DeprecatedApiScanResult>[
          parseDeprecatedApiLog(
            '',
            platform: DeprecatedApiPlatform.ios,
          ),
        ],
        generatedAt: '2026-09-21 15:00:00',
      );

      expect(report, contains('未发现废弃 API 调用。'));
    });
  });
}
