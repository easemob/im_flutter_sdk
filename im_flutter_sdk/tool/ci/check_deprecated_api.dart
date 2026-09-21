import 'dart:convert';
import 'dart:io';

import 'deprecated_api_checker.dart';

/// Turns native build logs into the deprecated API report.
///
/// Usage:
///
/// ```sh
/// dart tool/ci/check_deprecated_api.dart --out-dir=DIR \
///   [--android-raw-log=FILE] [--ios-raw-log=FILE]
/// ```
///
/// Writes one JSON report per given log plus the merged markdown report beside
/// it, and prints a summary. Findings alone never fail the command (the report
/// is informational); a missing log or an incremental build does.
void main(List<String> arguments) {
  final options = _Options.parse(arguments);
  if (options == null) {
    stderr.writeln(_usage);
    exit(2);
  }

  final logs = <DeprecatedApiPlatform, File>{
    if (options.androidRawLog != null)
      DeprecatedApiPlatform.android: options.androidRawLog!,
    if (options.iosRawLog != null)
      DeprecatedApiPlatform.ios: options.iosRawLog!,
  };
  if (logs.isEmpty) {
    stderr.writeln('No build log given.\n\n$_usage');
    exit(2);
  }

  for (final entry in logs.entries) {
    final file = entry.value;
    if (!file.existsSync() || file.lengthSync() == 0) {
      stderr.writeln(
        'Build log for ${entry.key.name} is missing or empty: ${file.path}',
      );
      exit(2);
    }
  }

  final outputDirectory = Directory(options.outputDirectory);
  outputDirectory.createSync(recursive: true);
  final generatedAt = _timestamp(DateTime.now());
  final results = <DeprecatedApiScanResult>[];
  var skipped = false;

  for (final entry in logs.entries) {
    final result = parseDeprecatedApiLog(
      entry.value.readAsStringSync(),
      platform: entry.key,
    );
    results.add(result);
    skipped |= result.skippedCompile;

    final jsonFile = File(
      '${outputDirectory.path}/${entry.key.name}-deprecated-api.json',
    );
    jsonFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
            'platform': entry.key.name,
            'generatedAt': generatedAt,
            'rawLog': entry.value.path,
            'skippedCompile': result.skippedCompile,
            'findings': [
              for (final finding in result.findings) finding.toJson(),
            ],
          })}\n',
    );

    stdout.writeln(
      '${entry.key.name}: ${result.findings.length} deprecated API call(s) '
      '-> ${jsonFile.path}',
    );
    if (result.skippedCompile) {
      stderr.writeln(
        'The ${entry.key.name} log shows a reused compile (UP-TO-DATE / '
        'FROM-CACHE / NO-SOURCE), so warnings were not re-emitted. Re-run the '
        'scan after a clean build.',
      );
    }
  }

  final reportFile = File(
    '${outputDirectory.path}/native-deprecated-api.md',
  );
  reportFile.writeAsStringSync(
    renderDeprecatedApiMarkdown(results, generatedAt: generatedAt),
  );
  stdout.writeln('Report: ${reportFile.path}');

  if (skipped) {
    exit(1);
  }
}

String _timestamp(DateTime now) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${now.year}-${two(now.month)}-${two(now.day)} '
      '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
}

const String _usage =
    'Usage: dart tool/ci/check_deprecated_api.dart --out-dir=<dir> '
    '[--android-raw-log=<file>] [--ios-raw-log=<file>]';

final class _Options {
  const _Options({
    required this.outputDirectory,
    required this.androidRawLog,
    required this.iosRawLog,
  });

  static _Options? parse(List<String> arguments) {
    String? outputDirectory;
    File? androidRawLog;
    File? iosRawLog;

    for (final argument in arguments) {
      if (argument.startsWith('--out-dir=')) {
        outputDirectory = argument.substring('--out-dir='.length);
      } else if (argument.startsWith('--android-raw-log=')) {
        androidRawLog = File(argument.substring('--android-raw-log='.length));
      } else if (argument.startsWith('--ios-raw-log=')) {
        iosRawLog = File(argument.substring('--ios-raw-log='.length));
      } else {
        return null;
      }
    }

    if (outputDirectory == null || outputDirectory.isEmpty) {
      return null;
    }
    return _Options(
      outputDirectory: outputDirectory,
      androidRawLog: androidRawLog,
      iosRawLog: iosRawLog,
    );
  }

  final String outputDirectory;
  final File? androidRawLog;
  final File? iosRawLog;
}
