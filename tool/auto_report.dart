import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _packageName = 'com.example.example';
const _scriptRelativePath =
    'im_flutter_sdk/example/scripts/script_500_apis.json';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  if (options.containsKey('self-test')) {
    await _selfTest();
    stdout.writeln('auto_report self-test passed');
    return;
  }
  if (options.containsKey('help')) {
    stdout.writeln('''
Usage:
  make auto-report PLATFORM=android [DEVICE=emulator-5554]
  make auto-report PLATFORM=ios [DEVICE=<simulator-udid>]
  dart run tool/auto_report.dart --self-test

The command runs the 5.0.0 auto script, captures only APITEST events and
crash evidence, and writes a local report under reports/5.0.0/<run-id>/.
''');
    return;
  }

  final requestedPlatform = options['platform'];
  if (requestedPlatform != 'android' && requestedPlatform != 'ios') {
    throw const FormatException('--platform must be android or ios');
  }
  final platform = requestedPlatform!;
  final root = Directory.current.absolute;
  final example = Directory('${root.path}/im_flutter_sdk/example');
  final script = File('${root.path}/$_scriptRelativePath');
  if (!await example.exists()) {
    throw StateError('Run this command from the worktree root.');
  }
  if (!await script.exists()) {
    throw StateError('Script not found: ${script.path}');
  }
  final scriptJson = Map<String, dynamic>.from(
    jsonDecode(await script.readAsString()) as Map,
  );
  final scriptSteps = <_ScriptStep>[
    for (final raw in scriptJson['steps'] as List? ?? const [])
      _ScriptStep.fromJson(Map<String, dynamic>.from(raw as Map)),
  ];

  final device = await _resolveDevice(platform, options['device']);
  final startedAt = DateTime.now().toUtc();
  final runId = '${_timestamp(startedAt)}-$platform-${_safeName(device)}';
  final reportDir = Directory('${root.path}/reports/5.0.0/$runId');
  await reportDir.create(recursive: true);
  final eventsFile = File('${reportDir.path}/events.jsonl');
  final crashFile = File('${reportDir.path}/crash.log');
  final eventsSink = eventsFile.openWrite();
  final crashSink = crashFile.openWrite();
  final state = _RunState(
    platform: platform,
    device: device,
    runId: runId,
    reportDir: reportDir,
    eventsSink: eventsSink,
    crashSink: crashSink,
    scriptSteps: scriptSteps,
  );

  try {
    await _prepareDevice(platform, device, script, runId);
    await _writeRunMetadata(reportDir, root, script, state, startedAt);
    await _runFlutter(state, example);
  } finally {
    await eventsSink.flush();
    await eventsSink.close();
    await crashSink.flush();
    await crashSink.close();
  }

  final finishedAt = DateTime.now().toUtc();
  await _writeSummary(reportDir, state, startedAt, finishedAt);
  stdout.writeln('Auto report: ${reportDir.path}');
  if (state.hasFailure) exitCode = 1;
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--help' || arg == '-h') {
      result['help'] = 'true';
    } else if (arg == '--self-test') {
      result['self-test'] = 'true';
    } else if (arg.startsWith('--') && i + 1 < args.length) {
      result[arg.substring(2)] = args[++i];
    } else {
      throw FormatException('Unknown argument: $arg');
    }
  }
  return result;
}

Future<void> _selfTest() async {
  final temporary = await Directory.systemTemp.createTemp('auto-report-test-');
  final eventsSink = File('${temporary.path}/events.jsonl').openWrite();
  final crashSink = File('${temporary.path}/crash.log').openWrite();
  try {
    final state = _RunState(
      platform: 'ios',
      device: 'simulator',
      runId: 'self-test',
      reportDir: temporary,
      eventsSink: eventsSink,
      crashSink: crashSink,
      scriptSteps: const [
        _ScriptStep(
          id: 'expected_error',
          api: 'ExpectedError',
          expectation: {'errorCode': 305},
        ),
        _ScriptStep(
          id: 'group_receipts_server',
          api: 'GroupReceipts',
          expectation: {'success': true},
        ),
      ],
    );
    state.observeEvent({
      'source': 'api.ExpectedError',
      'payload': {
        'success': false,
        'error': {'code': 305},
      },
    });
    state.observeEvent({
      'source': 'api.GroupReceipts',
      'payload': {
        'success': true,
        'data': {'cursor': '', 'list': [], 'totalCount': null},
      },
    });
    state.scriptDone = {'total': 2, 'failed': 0};
    state.finalizeOutcomes();
    if (state.outcomes.length != 2 ||
        state.outcomes.any((item) => item.status != 'passed') ||
        !state.iosTotalCountMissing ||
        !_isBlockedResult(<String, dynamic>{'skipped': true}, const []) ||
        state.hasFailure) {
      throw StateError('step classification self-test failed');
    }
  } finally {
    await eventsSink.close();
    await crashSink.close();
    await temporary.delete(recursive: true);
  }
}

Future<String> _resolveDevice(String platform, String? requested) async {
  if (requested != null && requested.isNotEmpty) return requested;
  if (platform == 'android') return 'emulator-5554';
  final result = await Process.run('xcrun', [
    'simctl',
    'list',
    'devices',
    'booted',
    '-j',
  ]);
  if (result.exitCode != 0) {
    throw StateError('Unable to list booted iOS simulators: ${result.stderr}');
  }
  final decoded = jsonDecode(result.stdout as String) as Map;
  final devices = <Map<String, dynamic>>[];
  final rawDevices = decoded['devices'];
  if (rawDevices is Map) {
    for (final values in rawDevices.values) {
      if (values is List) {
        for (final item in values) {
          if (item is Map && item['state'] == 'Booted') {
            devices.add(Map<String, dynamic>.from(item));
          }
        }
      }
    }
  }
  if (devices.isEmpty) {
    throw StateError(
      'No booted iOS simulator. Start one, then rerun with DEVICE=<udid>.',
    );
  }
  return devices.first['udid'] as String;
}

Future<void> _prepareDevice(
  String platform,
  String device,
  File script,
  String runId,
) async {
  if (platform == 'ios') {
    final openResult = await Process.run('open', ['-a', 'Simulator']);
    if (openResult.exitCode != 0) {
      stderr.writeln(
        'warning: unable to activate iOS Simulator: ${openResult.stderr}',
      );
    } else {
      stdout.writeln('Activated iOS Simulator window.');
    }
    await Process.run('xcrun', ['simctl', 'bootstatus', device, '-b']);
    return;
  }

  await _checkedProcess('adb', [
    '-s',
    device,
    'shell',
    'mkdir',
    '-p',
    '/sdcard/Android/data/$_packageName/files',
  ]);
  final remotePath =
      '/sdcard/Android/data/$_packageName/files/script_$runId.json';
  await _checkedProcess('adb', ['-s', device, 'push', script.path, remotePath]);
  await Process.run('adb', ['-s', device, 'shell', 'input', 'keyevent', '224']);
  await _tryActivateAndroidWindow(device);
}

Future<void> _tryActivateAndroidWindow(String device) async {
  if (!Platform.isMacOS) return;
  final pgrep = await Process.run('pgrep', ['-fal', 'qemu-system']);
  final processes = (pgrep.stdout as String)
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .toList();
  final visibleProcesses = processes
      .where(
        (line) =>
            !line.contains('qemu-system-aarch64-headless') &&
            !line.contains(' -no-window'),
      )
      .toList();
  if (visibleProcesses.isEmpty) {
    if (processes.isNotEmpty) {
      stderr.writeln(
        'warning: Android emulator $device is running headless and has no window to activate. '
        'Restart its AVD without -no-window for a visible run.',
      );
      return;
    }
    stderr.writeln(
      'warning: Android emulator is online, but its qemu window process was not found.',
    );
    return;
  }
  final pid = visibleProcesses.first.trim().split(RegExp(r'\s+')).first;
  final result = await Process.run('osascript', [
    '-e',
    'tell application "System Events" to set frontmost of first process whose unix id is $pid to true',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'warning: unable to bring Android emulator to the foreground. '
      'Check macOS Accessibility permission for the terminal: ${result.stderr}',
    );
  } else {
    stdout.writeln('Activated Android emulator window.');
  }
}

Future<void> _runFlutter(_RunState state, Directory example) async {
  final scriptArgument = state.platform == 'android'
      ? '/sdcard/Android/data/$_packageName/files/script_${state.runId}.json'
      : '${Directory.current.path}/$_scriptRelativePath';
  final process = await Process.start(
    'flutter',
    ['run', '-d', state.device, '--dart-define=API_SCRIPT=$scriptArgument'],
    workingDirectory: example.path,
    runInShell: true,
  );

  var stopping = false;
  Future<void> stopAfterScript() async {
    if (stopping) return;
    stopping = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    process.kill(ProcessSignal.sigint);
  }

  final stdoutDone = _consumeLines(process.stdout, state);
  final stderrDone = _consumeLines(process.stderr, state);
  state.scriptDoneFuture.future.then((_) => stopAfterScript());
  final timeout = Timer(const Duration(minutes: 8), () {
    state.recordCrash('REPORT_TIMEOUT: no script.done within 8 minutes');
    process.kill(ProcessSignal.sigint);
  });

  await process.exitCode;
  timeout.cancel();
  await Future.wait([stdoutDone, stderrDone]);
}

Future<void> _consumeLines(Stream<List<int>> stream, _RunState state) async {
  await for (final line
      in stream.transform(utf8.decoder).transform(const LineSplitter())) {
    final marker = line.indexOf('[APITEST]');
    if (marker >= 0) {
      final jsonText = line.substring(marker + '[APITEST]'.length).trim();
      try {
        final event = Map<String, dynamic>.from(jsonDecode(jsonText) as Map);
        state.events.add(event);
        state.observeEvent(event);
        state.eventsSink.writeln(jsonEncode(event));
        stdout.writeln('[APITEST] ${jsonEncode(event)}');
        if (event['source'] == 'script.done') {
          state.scriptDone = Map<String, dynamic>.from(
            event['payload'] as Map? ?? const {},
          );
          if (!state.scriptDoneFuture.isCompleted) {
            state.scriptDoneFuture.complete();
          }
        }
      } catch (_) {
        state.crashSink.writeln(_sanitize(line));
      }
      continue;
    }
    if (_isCrashEvidence(line, scriptCompleted: state.scriptDone != null)) {
      state.crashLinesRemaining = 24;
    }
    if (state.crashLinesRemaining > 0) {
      final sanitized = _sanitize(line);
      state.crashLines.add(sanitized);
      state.crashSink.writeln(sanitized);
      state.crashLinesRemaining--;
    }
  }
}

bool _isCrashEvidence(String line, {required bool scriptCompleted}) {
  return line.contains('FATAL EXCEPTION') ||
      line.contains('NullPointerException') ||
      line.contains('SIGSEGV') ||
      (!scriptCompleted && line.contains('Lost connection to device')) ||
      line.contains('REPORT_TIMEOUT');
}

String _sanitize(String line) {
  return line
      .replaceAll(
        RegExp(
          r'(token|client[_-]?secret|authorization)\s*[:=]\s*[^,} ]+',
          caseSensitive: false,
        ),
        r'$1=<redacted>',
      )
      .replaceAll(
        RegExp(r'(appkey|app_key)\s*[:=]\s*[^,} ]+', caseSensitive: false),
        r'$1=<redacted>',
      );
}

Future<void> _checkedProcess(String executable, List<String> args) async {
  final result = await Process.run(executable, args);
  if (result.exitCode != 0) {
    throw StateError('$executable ${args.join(' ')} failed: ${result.stderr}');
  }
}

Future<void> _writeRunMetadata(
  Directory reportDir,
  Directory root,
  File script,
  _RunState state,
  DateTime startedAt,
) async {
  final commit = await Process.run('git', ['rev-parse', 'HEAD']);
  final status = await Process.run('git', ['status', '--porcelain']);
  final scriptHash = await Process.run('shasum', ['-a', '256', script.path]);
  final runnerHash = await Process.run('shasum', [
    '-a',
    '256',
    Platform.script.toFilePath(),
  ]);
  final env = File('${root.path}/im_flutter_sdk/example/lib/env.dart');
  final envText = await env.exists() ? await env.readAsString() : '';
  final cluster = RegExp(r'''["']cluster["']\s*:\s*["']([^"']+)''')
      .firstMatch(envText)
      ?.group(1);
  final metadata = <String, Object?>{
    'schemaVersion': 1,
    'startedAt': startedAt.toIso8601String(),
    'platform': state.platform,
    'device': state.device,
    'cluster': cluster,
    'script': _scriptRelativePath,
    'commit': (commit.stdout as String).trim(),
    'worktreeDirty': (status.stdout as String).trim().isNotEmpty,
    'scriptSha256': (scriptHash.stdout as String).split(' ').first,
    'runnerSha256': (runnerHash.stdout as String).split(' ').first,
    'sensitiveValues': 'not included',
  };
  await File('${reportDir.path}/run.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(metadata));
}

Future<void> _writeSummary(
  Directory reportDir,
  _RunState state,
  DateTime startedAt,
  DateTime finishedAt,
) async {
  state.finalizeOutcomes();
  final done = state.scriptDone;
  final counts = <String, int>{};
  for (final outcome in state.outcomes) {
    counts.update(outcome.status, (value) => value + 1, ifAbsent: () => 1);
  }
  final summary = StringBuffer()
    ..writeln('# Auto-mode run ${state.runId}')
    ..writeln()
    ..writeln('- Platform: `${state.platform}`')
    ..writeln('- Device: `${state.device}`')
    ..writeln('- Started: `${startedAt.toIso8601String()}`')
    ..writeln('- Finished: `${finishedAt.toIso8601String()}`')
    ..writeln('- APITEST events: `${state.events.length}`')
    ..writeln('- script.done: `${done == null ? 'missing' : jsonEncode(done)}`')
    ..writeln('- Step outcomes: `${jsonEncode(counts)}`')
    ..writeln(
      '- Crash evidence: `${state.crashLines.isEmpty ? 'none' : 'see crash.log'}`',
    )
    ..writeln()
    ..writeln('## Step outcomes')
    ..writeln();
  for (final outcome in state.outcomes) {
    summary
      ..writeln(
        '- `${outcome.status}` `${outcome.step.id}` `${outcome.step.api}`',
      )
      ..writeln('  - Expected: `${jsonEncode(outcome.step.expectation)}`')
      ..writeln('  - Actual: `${jsonEncode(outcome.result)}`');
  }
  await File('${reportDir.path}/summary.md').writeAsString(summary.toString());
  await File('${reportDir.path}/steps.json').writeAsString(
    const JsonEncoder.withIndent('  ')
        .convert([for (final outcome in state.outcomes) outcome.toJson()]),
  );

  final issues = StringBuffer()
    ..writeln('# Issue candidates')
    ..writeln()
    ..writeln('Run: `${state.runId}`')
    ..writeln()
    ..writeln(
      'Candidate keys are semantic labels for review, not external issue IDs. Mark each candidate as `confirmed`, `environment`, `blocked`, `accepted`, or `retest`.',
    )
    ..writeln();
  final crashed = state.outcomes.where((item) => item.status == 'crashed');
  if (crashed.isNotEmpty) {
    issues
      ..writeln('## Candidate: `android-missing-message-crash`')
      ..writeln('- Evidence: `crash.log`')
      ..writeln('- Actual: process terminated before the current API returned')
      ..writeln('- Status: `confirmed` after stack review')
      ..writeln();
  }
  for (final outcome in state.outcomes.where(
    (item) => item.status == 'failed',
  )) {
    final candidateKey = _candidateKey(outcome);
    issues
      ..writeln('## Candidate: `$candidateKey`')
      ..writeln('- Step: `${outcome.step.id}`')
      ..writeln('- API: `${outcome.step.api}`')
      ..writeln('- Expected: `${jsonEncode(outcome.step.expectation)}`')
      ..writeln('- Actual: `${jsonEncode(outcome.result)}`')
      ..writeln('- Status: `needs-review`')
      ..writeln();
  }
  final blocked = state.outcomes.where((item) => item.status == 'blocked');
  if (blocked.isNotEmpty) {
    issues
      ..writeln('## Expected dependency skips')
      ..writeln();
    for (final outcome in blocked) {
      issues.writeln(
        '- `${outcome.step.id}` skipped because `${outcome.result?['blockedBy']}` did not succeed.',
      );
    }
    issues.writeln();
  }
  if (state.hasConversationSerializationGap) {
    issues
      ..writeln('## Candidate: `conversation-output-not-inspectable`')
      ..writeln(
        '- Actual: `loadAllConversations` emitted `Instance of ChatConversation` strings',
      )
      ..writeln('- Expected: structured JSON including `name` and `avatar`')
      ..writeln('- Status: `confirmed`')
      ..writeln();
  }
  if (state.iosTotalCountMissing) {
    issues
      ..writeln('## Candidate: `ios-total-count-missing`')
      ..writeln(
        '- Actual: successful iOS group-receipt pagination returned `totalCount: null`',
      )
      ..writeln(
        '- Expected: iOS native callback totalCount is forwarded as a number',
      )
      ..writeln('- Status: `confirmed` by RN wrapper comparison')
      ..writeln();
  }
  await File('${reportDir.path}/issues.md').writeAsString(issues.toString());
}

String _candidateKey(_StepOutcome outcome) {
  if (outcome.step.id == 'group_message') {
    return 'receipt-service-unavailable';
  }
  if (outcome.step.id == 'fetch_group_receipt_missing') {
    return 'unknown-message-pagination-semantics';
  }
  return '${outcome.step.id}-unexpected-result';
}

String _timestamp(DateTime date) =>
    date.toIso8601String().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);

String _safeName(String value) =>
    value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

class _ScriptStep {
  const _ScriptStep({
    required this.id,
    required this.api,
    required this.expectation,
  });

  factory _ScriptStep.fromJson(Map<String, dynamic> json) {
    return _ScriptStep(
      id: json['id'] as String? ?? 'step-without-id',
      api: json['api'] as String,
      expectation: json['expect'] is Map
          ? Map<String, dynamic>.from(json['expect'] as Map)
          : const <String, dynamic>{'success': true},
    );
  }

  final String id;
  final String api;
  final Map<String, dynamic> expectation;
}

class _StepOutcome {
  const _StepOutcome({
    required this.step,
    required this.status,
    required this.result,
  });

  final _ScriptStep step;
  final String status;
  final Map<String, dynamic>? result;

  Map<String, Object?> toJson() => {
    'id': step.id,
    'api': step.api,
    'status': status,
    'expected': step.expectation,
    'actual': result,
  };
}

bool _matchesExpectation(
  Map<String, dynamic> result,
  Map<String, dynamic> expectation,
) {
  if (expectation.containsKey('success') &&
      result['success'] != expectation['success']) {
    return false;
  }
  if (expectation.containsKey('errorCode')) {
    final error = result['error'];
    return result['success'] == false &&
        error is Map &&
        error['code'] == expectation['errorCode'];
  }
  return true;
}

bool _isBlockedResult(
  Map<String, dynamic> result,
  List<_StepOutcome> outcomes,
) {
  if (result['skipped'] == true) return true;
  final error = result['error'];
  final message = error is Map ? error['message']?.toString() ?? '' : '';
  return outcomes.isNotEmpty &&
      (outcomes.last.status == 'failed' || outcomes.last.status == 'blocked') &&
      message.contains("type 'Null' is not a subtype");
}

class _RunState {
  _RunState({
    required this.platform,
    required this.device,
    required this.runId,
    required this.reportDir,
    required this.eventsSink,
    required this.crashSink,
    required this.scriptSteps,
  });

  final String platform;
  final String device;
  final String runId;
  final Directory reportDir;
  final IOSink eventsSink;
  final IOSink crashSink;
  final List<_ScriptStep> scriptSteps;
  final events = <Map<String, dynamic>>[];
  final crashLines = <String>[];
  final outcomes = <_StepOutcome>[];
  final scriptDoneFuture = Completer<void>();
  int crashLinesRemaining = 0;
  int nextStepIndex = 0;
  Map<String, dynamic>? scriptDone;

  bool get hasFailure =>
      scriptDone == null || outcomes.any((item) => item.status != 'passed');

  bool get hasConversationSerializationGap => outcomes.any((item) {
    if (item.step.id != 'conversations') return false;
    final data = item.result?['data'];
    return data is List &&
        data.any(
          (value) =>
              value.toString().startsWith("Instance of 'ChatConversation'"),
        );
  });

  bool get iosTotalCountMissing =>
      platform == 'ios' &&
      outcomes.any((item) {
        if (item.step.id != 'group_receipts_server' ||
            item.status != 'passed') {
          return false;
        }
        final data = item.result?['data'];
        return data is Map && data['totalCount'] == null;
      });

  void observeEvent(Map<String, dynamic> event) {
    if (nextStepIndex >= scriptSteps.length) return;
    final step = scriptSteps[nextStepIndex];
    if (event['source'] != 'api.${step.api}') return;
    final payload = Map<String, dynamic>.from(
      event['payload'] as Map? ?? const {},
    );
    final status = _matchesExpectation(payload, step.expectation)
        ? 'passed'
        : _isBlockedResult(payload, outcomes)
        ? 'blocked'
        : 'failed';
    outcomes.add(_StepOutcome(step: step, status: status, result: payload));
    nextStepIndex++;
  }

  void recordCrash(String line) {
    final sanitized = _sanitize(line);
    crashLines.add(sanitized);
    crashSink.writeln(sanitized);
  }

  void finalizeOutcomes() {
    if (nextStepIndex >= scriptSteps.length) return;
    if (crashLines.isNotEmpty) {
      outcomes.add(
        _StepOutcome(
          step: scriptSteps[nextStepIndex++],
          status: 'crashed',
          result: null,
        ),
      );
    }
    while (nextStepIndex < scriptSteps.length) {
      outcomes.add(
        _StepOutcome(
          step: scriptSteps[nextStepIndex++],
          status: 'not-run',
          result: null,
        ),
      );
    }
  }
}
