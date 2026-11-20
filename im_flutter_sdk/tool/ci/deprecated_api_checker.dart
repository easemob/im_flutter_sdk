import 'dart:convert';

// Parses native build logs for wrapper code that still calls deprecated
// HyphenateChat APIs.
//
// Both platforms compile the wrapper sources against the native SDK, so the
// compiler reports every deprecated API the wrapper still calls. The scan
// drives a clean build per platform, keeps the build log, and this file turns
// that log into findings.
//
// The log must come from a *fresh* compile: an incremental build skips the
// unchanged sources and therefore re-emits none of their warnings. Callers own
// that premise (see DeprecatedApiScanResult.skippedCompile for the one case
// that can be detected from the log itself).

/// Native platform whose build log is parsed.
enum DeprecatedApiPlatform {
  /// Java wrapper: `im_flutter_sdk_android/android/src/main/java`.
  android('im_flutter_sdk_android/android/src/main/java/'),

  /// Objective-C wrapper: `im_flutter_sdk_ios/ios`.
  ios('im_flutter_sdk_ios/ios/');

  const DeprecatedApiPlatform(this.sourceMarker);

  /// Path fragment identifying this platform's wrapper sources.
  ///
  /// Warnings are kept only for files containing it, which drops the native
  /// SDK itself (CocoaPods, pub cache), the example app and every other
  /// third-party dependency without having to enumerate them.
  final String sourceMarker;
}

/// One call to a deprecated native API, as reported by the compiler.
final class DeprecatedApiFinding {
  const DeprecatedApiFinding({
    required this.file,
    required this.line,
    required this.api,
    this.declaringClass = '',
    this.reason = '',
  });

  /// Path relative to [DeprecatedApiPlatform.sourceMarker], so the report reads
  /// the same on a local machine and on a CI runner.
  final String file;

  /// 1-based line number of the call site.
  final int line;

  /// Deprecated member, e.g. `downloadAttachment(EMMessage)` or `muteList`.
  final String api;

  /// Java: the class declaring [api] (`EMChatManager`); empty on iOS.
  final String declaringClass;

  /// Objective-C: the compiler replacement hint (`Use muteMembers instead`);
  /// empty when clang printed none.
  final String reason;

  /// `path:line`, the location to open when fixing the finding.
  String get location => '$file:$line';

  Map<String, Object?> toJson() => <String, Object?>{
        'file': file,
        'line': line,
        'api': api,
        if (declaringClass.isNotEmpty) 'declaringClass': declaringClass,
        if (reason.isNotEmpty) 'reason': reason,
      };

  @override
  bool operator ==(Object other) =>
      other is DeprecatedApiFinding &&
      other.file == file &&
      other.line == line &&
      other.api == api &&
      other.declaringClass == declaringClass &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(file, line, api, declaringClass, reason);

  @override
  String toString() => '$location $api';
}

/// Findings parsed from one platform's build log.
final class DeprecatedApiScanResult {
  const DeprecatedApiScanResult({
    required this.platform,
    required this.findings,
    required this.skippedCompile,
  });

  final DeprecatedApiPlatform platform;

  /// Deduplicated, sorted by file then line.
  final List<DeprecatedApiFinding> findings;

  /// The log shows Gradle reused an earlier compilation (`UP-TO-DATE`,
  /// `FROM-CACHE`, `NO-SOURCE`), so javac emitted no warnings at all: an empty
  /// finding list would be meaningless. Callers must treat this as a failed
  /// scan instead of a clean result.
  final bool skippedCompile;
}

/// Parses a whole Android or iOS build log into deprecated API findings.
DeprecatedApiScanResult parseDeprecatedApiLog(
  String log, {
  required DeprecatedApiPlatform platform,
}) {
  final findings = <String, DeprecatedApiFinding>{};

  for (final rawLine in const LineSplitter().convert(log)) {
    // Flutter prints captured child output as trace lines when the build runs
    // with `--verbose`, which prefixes them with `[        ] ` / `[+12 ms] `.
    final line = _stripTracePrefix(rawLine);
    if (line.isEmpty) {
      continue;
    }

    final match = switch (platform) {
      DeprecatedApiPlatform.android => _javacWarning.firstMatch(line),
      DeprecatedApiPlatform.ios => _clangWarning.firstMatch(line),
    };
    if (match == null) {
      continue;
    }

    final file = match.namedGroup('file')!;
    final markerIndex = file.indexOf(platform.sourceMarker);
    if (markerIndex < 0) {
      continue;
    }

    // Each platform's pattern carries its own extra group, and reading a group
    // a pattern does not define throws.
    final finding = DeprecatedApiFinding(
      file: file.substring(markerIndex),
      line: int.parse(match.namedGroup('line')!),
      api: match.namedGroup('api')!,
      declaringClass: switch (platform) {
        DeprecatedApiPlatform.android => match.namedGroup('declaringClass')!,
        DeprecatedApiPlatform.ios => '',
      },
      reason: switch (platform) {
        DeprecatedApiPlatform.android => '',
        DeprecatedApiPlatform.ios => match.namedGroup('reason') ?? '',
      },
    );
    findings.putIfAbsent(finding.toString(), () => finding);
  }

  final sorted = findings.values.toList()
    ..sort((a, b) {
      final byFile = a.file.compareTo(b.file);
      if (byFile != 0) {
        return byFile;
      }
      final byLine = a.line.compareTo(b.line);
      return byLine != 0 ? byLine : a.api.compareTo(b.api);
    });

  return DeprecatedApiScanResult(
    platform: platform,
    findings: sorted,
    skippedCompile: _skippedJavaCompile.hasMatch(log),
  );
}

/// Renders the markdown report written next to the JSON reports.
String renderDeprecatedApiMarkdown(
  List<DeprecatedApiScanResult> results, {
  required String generatedAt,
}) {
  final buffer = StringBuffer()
    ..writeln('# 废弃 API 扫描报告')
    ..writeln()
    ..writeln('生成时间：$generatedAt')
    ..writeln()
    ..writeln(
      '扫描范围：wrapper 源码（`im_flutter_sdk_android/android/src/main/java`、'
      '`im_flutter_sdk_ios/ios`），数据来自一次全新编译的构建日志。',
    )
    ..writeln()
    ..writeln('## 汇总')
    ..writeln()
    ..writeln('| 平台 | 废弃 API 调用 |')
    ..writeln('| --- | --- |');

  var total = 0;
  for (final result in results) {
    total += result.findings.length;
    buffer.writeln('| ${result.platform.name} | ${result.findings.length} |');
  }
  final missing = DeprecatedApiPlatform.values
      .where(
          (platform) => !results.any((result) => result.platform == platform))
      .map((platform) => platform.name)
      .toList();
  buffer
    ..writeln('| 合计 | $total |')
    ..writeln();

  if (missing.isNotEmpty) {
    buffer
      ..writeln('未扫描平台：${missing.join('、')}。')
      ..writeln();
  }

  for (final result in results) {
    buffer
      ..writeln('## ${result.platform.name}（${result.findings.length}）')
      ..writeln();
    if (result.findings.isEmpty) {
      buffer
        ..writeln('未发现废弃 API 调用。')
        ..writeln();
      continue;
    }
    for (final finding in result.findings) {
      buffer
        ..writeln('### `${finding.location}`')
        ..writeln()
        ..writeln('- API：`${finding.api}`');
      if (finding.declaringClass.isNotEmpty) {
        buffer.writeln('- 声明于：`${finding.declaringClass}`');
      }
      if (finding.reason.isNotEmpty) {
        buffer.writeln('- 替代：${finding.reason}');
      }
      buffer.writeln();
    }
  }

  return buffer.toString();
}

/// javac, `-Xlint:deprecation`:
/// `/abs/ChatManagerWrapper.java:502: warning: [deprecation] downloadAttachment(EMMessage) in EMChatManager has been deprecated`
final RegExp _javacWarning = RegExp(
  r'^(?<file>.+?\.java):(?<line>\d+): warning: \[deprecation\] '
  r'(?<api>.+?) in (?<declaringClass>.+?) has been deprecated$',
);

/// clang, `-Wdeprecated-declarations`:
/// `/abs/ChatroomHelper.m:23:29: warning: 'muteList' is deprecated: Use muteMembers instead [-Wdeprecated-declarations]`
final RegExp _clangWarning = RegExp(
  r"^(?<file>.+?\.[mh]):(?<line>\d+):(?<column>\d+): warning: "
  r"'(?<api>[^']+)' is deprecated(?:: (?<reason>.*?))? "
  r'\[-Wdeprecated-declarations\]$',
);

/// `[        ] ` / `[+123 ms] ` trace prefix added by the Flutter tool, and the
/// `\r` of CRLF logs.
final RegExp _tracePrefix = RegExp(r'^\[[^\]]*\]\s?');

/// Matches Gradle reporting a reused Java compile, the one incremental-build
/// case visible in the log itself. xcodebuild prints no equivalent, so the iOS
/// side relies on the scan always running `clean build`.
final RegExp _skippedJavaCompile = RegExp(
  r'^> Task :\S*(?:ompile)\w*JavaWithJavac[^\n]*\b(?:UP-TO-DATE|FROM-CACHE|NO-SOURCE)\b',
  multiLine: true,
);

String _stripTracePrefix(String line) =>
    line.replaceFirst(_tracePrefix, '').trimRight();
