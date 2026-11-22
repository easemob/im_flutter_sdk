import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../im_flutter_sdk/example/lib/auto/step_expectation.dart';

const _packageName = 'com.example.example';
const _reportsRelativePath = 'artifacts/single';
const _stdoutPrefix = '[APITEST]';
const _markerPrefix = '[APITEST';
const _positiveScriptRelativePath =
    'testing/single/cases/script_1.16.0_apis_positive.json';
const _negativeScriptRelativePath =
    'testing/single/cases/script_1.16.0_apis_negative.json';
const _defaultScriptRelativePath = _positiveScriptRelativePath;

/// ohos target when neither `--device` nor `OHOS_DEVICE` is set; matches the
/// emulator address documented in AGENTS.md.
const _ohosDefaultDevice = '127.0.0.1:5555';

/// Absolute path of the auto script inside the app's internal files dir.
///
/// Android only: `/sdcard/Android/data/<pkg>/files/` is readable by the app only
/// when the app created that directory itself. A directory created by adb
/// belongs to `shell:ext_data_rw` with mode 0770, so the app cannot even
/// traverse it and the run dies with
/// `PathAccessException: ... Permission denied, errno = 13`. The internal dir
/// has no such dependency on who created it.
String _androidScriptPath(String runId) =>
    '/data/data/$_packageName/files/script_$runId.json';

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
  dart testing/single/auto_report.dart --platform android [--device emulator-5554] [--script <json>]
  dart testing/single/auto_report.dart --platform ios [--device <simulator-udid>]
  dart testing/single/auto_report.dart --platform ohos [--device 127.0.0.1:5555] [--script <json>]
  dart testing/single/auto_report.dart --android-report <dir> --ios-report <dir>
  dart testing/single/auto_report.dart --self-test

The positive path is the default script ($_positiveScriptRelativePath);
pass --script $_negativeScriptRelativePath
for the negative path. A run captures only APITEST events and crash evidence and
writes a local report under $_reportsRelativePath/<timestamp>/<platform>/.
Each execution also writes upgrade-report.md (human statistics) and
upgrade-report.json (structured statistics). Raw evidence: run.json,
steps.json, events.jsonl, crash.log, issues.md, summary.md, plus the full
device log (device.log.gz on Android, device.log on iOS and ohos).
All outputs are Git-ignored. Python 3 is required for report rendering.

ohos differences:
  - The Flutter executable is FLUTTER_BIN, else the project-pinned
    .fvm/flutter_sdk/bin/flutter, else flutter from PATH.
  - The device is OHOS_DEVICE or $_ohosDefaultDevice, overridden by --device.
  - hdc cannot write the app sandbox, so the script body is passed inline as
    --dart-define=API_SCRIPT=<json> instead of being pushed to the device.
  - APITEST events come from the flutter run output. If that output carries
    none, the run waits for its 8-minute timeout and then replays the
    `hdc shell hilog` capture in device.log.

The comparison mode reads two finished run directories on the same path and
writes $_reportsRelativePath/comparison-<timestamp>.md.
''');
    return;
  }

  final root = Directory.current.absolute;
  final androidReport = options['android-report'];
  final iosReport = options['ios-report'];
  if (androidReport != null || iosReport != null) {
    if (androidReport == null || iosReport == null) {
      throw const FormatException(
        'comparison requires --android-report and --ios-report',
      );
    }
    final comparison = await _compareReports(
      androidReport,
      iosReport,
      Directory('${root.path}/$_reportsRelativePath'),
    );
    stdout.writeln('Comparison report: ${comparison.outputPath}');
    if (comparison.mismatches > 0) exitCode = 1;
    return;
  }

  final requestedPlatform = options['platform'];
  if (requestedPlatform != 'android' &&
      requestedPlatform != 'ios' &&
      requestedPlatform != 'ohos') {
    throw const FormatException('--platform must be android, ios or ohos');
  }
  final platform = requestedPlatform!;
  final example = Directory('${root.path}/im_flutter_sdk/example');
  if (!await example.exists()) {
    throw StateError('Run this command from the worktree root.');
  }
  final requestedScript = options['script'] ?? _defaultScriptRelativePath;
  final script = requestedScript.startsWith('/')
      ? File(requestedScript)
      : File('${root.path}/$requestedScript');
  if (!await script.exists()) {
    throw StateError('Script not found: ${script.path}');
  }
  final scriptRelativePath = _relativeToRoot(root, script);
  final scriptKind = _scriptKindOf(scriptRelativePath);
  final scriptJson = Map<String, dynamic>.from(
    jsonDecode(await script.readAsString()) as Map,
  );
  final scriptSteps = <_ScriptStep>[
    for (final raw in scriptJson['steps'] as List? ?? const [])
      _ScriptStep.fromJson(Map<String, dynamic>.from(raw as Map)),
  ];

  final startedAt = DateTime.now().toUtc();
  // One timestamp directory per task; the platform directory below it holds
  // all evidence of that run. A numeric suffix disambiguates same-second runs.
  final stamp = _timestamp(startedAt);
  var runDirName = stamp;
  var suffix = 2;
  while (Directory('${root.path}/$_reportsRelativePath/$runDirName')
      .existsSync()) {
    runDirName = '$stamp.$suffix';
    suffix++;
  }
  final runId = '$runDirName-$platform';
  final reportDir = Directory(
    '${root.path}/$_reportsRelativePath/$runDirName/$platform',
  );
  await reportDir.create(recursive: true);
  final eventsFile = File('${reportDir.path}/events.jsonl');
  final crashFile = File('${reportDir.path}/crash.log');
  final eventsSink = eventsFile.openWrite();
  final crashSink = crashFile.openWrite();
  final state = _RunState(
    platform: platform,
    device: options['device'] ?? 'unresolved',
    runId: runId,
    reportDir: reportDir,
    eventsSink: eventsSink,
    crashSink: crashSink,
    scriptSteps: scriptSteps,
    scriptRelativePath: scriptRelativePath,
    scriptHostPath: script.absolute.path,
    scriptKind: scriptKind,
  );

  _DeviceLogCapture? deviceLog;
  try {
    await _writeRunMetadata(reportDir, root, script, state, startedAt);
    state.device = await _resolveDevice(platform, options['device']);
    await _prepareDevice(platform, state.device, example, script, runId);
    deviceLog = await _startDeviceLogCapture(state);
    await _runFlutter(state, example, root);
  } catch (error) {
    state.executionErrors.add(_sanitize('$error'));
    stderr.writeln('Execution failed: ${state.executionErrors.last}');
  } finally {
    if (deviceLog != null) {
      state.deviceLogFile = await deviceLog.stop(state.platform);
    }
    // ohos fallback: `flutter run` does not always forward the app's print
    // output. When the stdout channel produced no APITEST event at all, first
    // tail the live `hdc shell hilog` capture until script.done (the fork
    // flutter run may exit right after launch while the app keeps running),
    // then fall back to replaying whatever was captured. The event sinks are
    // still open here on purpose.
    if (state.platform == 'ohos' &&
        state.events.isEmpty &&
        state.deviceLogFile != null) {
      await _tailDeviceLogForScriptDone(state);
      if (state.events.isEmpty) {
        await _replayDeviceLog(state);
      }
    }
    await eventsSink.flush();
    await eventsSink.close();
    await crashSink.flush();
    await crashSink.close();
  }

  final finishedAt = DateTime.now().toUtc();
  await _writeSummary(reportDir, state, startedAt, finishedAt);
  stdout.writeln('Auto report: ${reportDir.path}');
  final report = await Process.run('python3', [
    '${root.path}/testing/report_upgrade.py',
    '--single',
    reportDir.path,
    '--output',
    reportDir.path,
  ]);
  stdout.write(report.stdout);
  stderr.write(report.stderr);
  if (report.exitCode != 0) exitCode = report.exitCode;
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

String _relativeToRoot(Directory root, File file) {
  final prefix = '${root.absolute.path}/';
  final path = file.absolute.path;
  return path.startsWith(prefix) ? path.substring(prefix.length) : path;
}

_ScriptKind _scriptKindOf(String relativePath) {
  final name = relativePath.split('/').last;
  if (name.contains('positive')) return _ScriptKind.positive;
  if (name.contains('negative')) return _ScriptKind.negative;
  return _ScriptKind.unknown;
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
      scriptRelativePath: _negativeScriptRelativePath,
      scriptHostPath: '/tmp/${_negativeScriptRelativePath.split('/').last}',
      scriptKind: _ScriptKind.negative,
    );
    final chunkedEvent = jsonEncode({
      'ts': 1,
      'seq': 1,
      'source': 'api.ExpectedError',
      'payload': {
        'success': false,
        'error': {'code': 305},
      },
    });
    final cut = chunkedEvent.length ~/ 2;
    _consumeChunk('1/2] ${chunkedEvent.substring(0, cut)}', state);
    if (state.events.isNotEmpty) {
      throw StateError('chunk reassembly self-test failed early');
    }
    _consumeChunk('2/2] ${chunkedEvent.substring(cut)}', state);
    _handleEventText(
      jsonEncode({
        'ts': 2,
        'seq': 2,
        'source': 'api.GroupReceipts',
        'payload': {
          'success': true,
          'data': {'cursor': '', 'list': [], 'totalCount': null},
        },
      }),
      state,
    );
    state.scriptDone = {'total': 2, 'failed': 0};
    state.finalizeOutcomes();
    if (state.events.length != 2 ||
        state.outcomes.length != 2 ||
        state.outcomes.any((item) => item.status != 'passed') ||
        !state.groupReceiptTotalCountMissing ||
        !_isBlockedResult(<String, dynamic>{'skipped': true}, const []) ||
        state.hasFailure) {
      throw StateError('step classification self-test failed');
    }
    if (_buildIssues(state).contains('fetch-group-receipt-missing-disabled')) {
      throw StateError('known-crash candidate must follow the script steps');
    }
    final receiptState = _RunState(
      platform: 'ios',
      device: 'simulator',
      runId: 'self-test-receipts',
      reportDir: temporary,
      eventsSink: eventsSink,
      crashSink: crashSink,
      scriptSteps: const [
        _ScriptStep(
          id: 'fetch_group_receipt_missing',
          api: 'ChatManager.fetchGroupMessageReadReceipts',
          expectation: {'success': true},
        ),
      ],
      scriptRelativePath: _negativeScriptRelativePath,
      scriptHostPath: '/tmp/${_negativeScriptRelativePath.split('/').last}',
      scriptKind: _ScriptKind.negative,
    );
    if (!_buildIssues(receiptState)
        .contains('fetch-group-receipt-missing-disabled')) {
      throw StateError('negative-path known-crash candidate self-test failed');
    }
    if (jsonEncode(
          _shapeOf(<String, dynamic>{
            'id': 'dynamic',
            'values': [
              <String, dynamic>{'count': 1},
            ],
          }),
        ) !=
        jsonEncode(<String, dynamic>{
          'id': 'String',
          'values': [
            <String, dynamic>{'count': 'int'},
          ],
        })) {
      throw StateError('shape self-test failed');
    }
    if (_differentShapePaths(
          _shapeOf(<String, dynamic>{
            'data': {'cursor': 'text', 'list': <dynamic>[]},
          }),
          _shapeOf(<String, dynamic>{
            'data': {'cursor': 'text', 'list': <dynamic>[], 'totalCount': 0},
          }),
        ).join(',') !=
        'data.totalCount') {
      throw StateError('shape difference self-test failed');
    }
    await _selfTestComparison(temporary);
  } finally {
    await eventsSink.close();
    await crashSink.close();
    await temporary.delete(recursive: true);
  }
}

Future<void> _selfTestComparison(Directory temporary) async {
  final android = Directory('${temporary.path}/android')..createSync();
  final ios = Directory('${temporary.path}/ios')..createSync();
  File('${android.path}/run.json').writeAsStringSync(
    jsonEncode({
      'runId': 'android-self-test',
      'script': _negativeScriptRelativePath,
    }),
  );
  File('${ios.path}/run.json').writeAsStringSync(
    jsonEncode({
      'runId': 'ios-self-test',
      'script': _negativeScriptRelativePath,
    }),
  );
  File('${android.path}/steps.json').writeAsStringSync(
    jsonEncode([
      {
        'id': 'receipt_missing',
        'api': 'ChatManager.sendMessageReadReceipts',
        'status': 'passed',
        'expected': {'errorCode': 500},
        'actual': {
          'success': false,
          'error': {'code': 1},
        },
      },
      {
        'id': 'renew_invalid_token',
        'api': 'ChatClient.renewToken',
        'status': 'passed',
        'expected': {'errorCode': 104},
        'actual': {
          'success': false,
          'error': {'code': 104},
        },
      },
    ]),
  );
  File('${ios.path}/steps.json').writeAsStringSync(
    jsonEncode([
      {
        'id': 'receipt_missing',
        'api': 'ChatManager.sendMessageReadReceipts',
        'status': 'passed',
        'expected': {'errorCode': 500},
        'actual': {
          'success': false,
          'error': {'code': 500},
        },
      },
      {
        'id': 'renew_invalid_token',
        'api': 'ChatClient.renewToken',
        'status': 'failed',
        'expected': {'errorCode': 104},
        'actual': {'success': true},
      },
    ]),
  );
  final comparison = await _compareReports(
    android.path,
    ios.path,
    Directory('${temporary.path}/out'),
  );
  final report = await File(comparison.outputPath).readAsString();
  if (comparison.kind != _ScriptKind.negative ||
      comparison.mismatches != 3 ||
      !report.contains('Error codes') ||
      !report.contains('receipt_missing')) {
    throw StateError('comparison self-test failed');
  }
}

Future<String> _resolveDevice(String platform, String? requested) async {
  if (requested != null && requested.isNotEmpty) return requested;
  if (platform == 'android') return 'emulator-5554';
  if (platform == 'ohos') {
    final fromEnvironment = Platform.environment['OHOS_DEVICE'];
    return fromEnvironment != null && fromEnvironment.isNotEmpty
        ? fromEnvironment
        : _ohosDefaultDevice;
  }
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
  Directory example,
  File script,
  String runId,
) async {
  if (platform == 'ohos') {
    await _ensureOhosDevice(device);
    return;
  }
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

  await _ensureAndroidAppInstalled(device, example);
  await _pushAndroidScript(device, script, runId);
  await Process.run('adb', ['-s', device, 'shell', 'input', 'keyevent', '224']);
  await _tryActivateAndroidWindow(device);
}

/// Confirms hdc can reach the target before starting a long `flutter run`.
///
/// ohos needs no adb-style app install or script push: the script travels
/// inline through `--dart-define`, and `flutter run` installs the hap itself.
Future<void> _ensureOhosDevice(String device) async {
  var probe = await Process.run('hdc', [
    '-t',
    device,
    'shell',
    'echo',
    'ohos-ready',
  ]);
  if (probe.exitCode == 0 && (probe.stdout as String).contains('ohos-ready')) {
    stdout.writeln('ohos device $device is reachable via hdc.');
    return;
  }
  if (device.contains(':')) {
    // Network targets (the emulator listens on 127.0.0.1:5555) need an
    // explicit connect after a host restart.
    await Process.run('hdc', ['tconn', device]);
    probe = await Process.run('hdc', [
      '-t',
      device,
      'shell',
      'echo',
      'ohos-ready',
    ]);
    if (probe.exitCode == 0 &&
        (probe.stdout as String).contains('ohos-ready')) {
      stdout.writeln('ohos device $device is reachable via hdc.');
      return;
    }
  }
  final targets = await Process.run('hdc', ['list', 'targets']);
  throw StateError(
    'ohos device $device is not reachable via hdc. Start the HarmonyOS '
    'emulator or device, check `hdc list targets` '
    '(${(targets.stdout as String).trim()}), and set OHOS_DEVICE or --device '
    'if needed.',
  );
}

/// Makes sure the debug build is on the device before the run starts.
///
/// The script is written through `adb shell run-as`, which requires an
/// installed, debuggable app. `flutter run` later reinstalls over it and keeps
/// the app's internal files dir, so the script is still there when auto mode
/// reads it.
Future<void> _ensureAndroidAppInstalled(
  String device,
  Directory example,
) async {
  final probe = await Process.run('adb', [
    '-s',
    device,
    'shell',
    'pm',
    'path',
    _packageName,
  ]);
  if ((probe.stdout as String).contains('package:')) return;

  final apk = File(
    '${example.path}/build/app/outputs/flutter-apk/app-debug.apk',
  );
  if (!await apk.exists()) {
    stdout.writeln('Building the debug APK to place the auto script...');
    await _checkedProcess('flutter', [
      'build',
      'apk',
      '--debug',
    ], workingDirectory: example.path);
  }
  stdout.writeln('Installing $_packageName to place the auto script...');
  await _checkedProcess('adb', ['-s', device, 'install', '-r', '-t', apk.path]);
}

/// Writes the script into the app's internal files dir as the app uid, so the
/// app can read it regardless of how the device was provisioned. The script
/// travels on stdin; a short or failed write is detected here instead of
/// showing up as an opaque script.error inside the app.
Future<void> _pushAndroidScript(
  String device,
  File script,
  String runId,
) async {
  final remotePath = _androidScriptPath(runId);
  // A freshly installed app has no files dir yet, and only the app uid may
  // create it.
  await _checkedProcess('adb', [
    '-s',
    device,
    'shell',
    'run-as',
    _packageName,
    'mkdir',
    '-p',
    '/data/data/$_packageName/files',
  ]);
  final process = await Process.start('adb', [
    '-s',
    device,
    'shell',
    'run-as',
    _packageName,
    'sh',
    '-c',
    "'cat > $remotePath'",
  ]);
  final stderrDone = process.stderr.transform(utf8.decoder).join();
  process.stdin.add(await script.readAsBytes());
  await process.stdin.flush();
  await process.stdin.close();
  final stderrText = await stderrDone;
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw StateError(
      'Unable to write $remotePath (run-as needs the debuggable debug build, '
      'so uninstall any release build and retry): $stderrText',
    );
  }

  final expected = await script.length();
  final sizeCheck = await Process.run('adb', [
    '-s',
    device,
    'shell',
    'run-as',
    _packageName,
    'sh',
    '-c',
    "'wc -c < $remotePath'",
  ]);
  final written = int.tryParse((sizeCheck.stdout as String).trim());
  if (sizeCheck.exitCode != 0 || written != expected) {
    throw StateError(
      'Script $remotePath is incomplete ($written of $expected bytes): '
      '${sizeCheck.stderr}',
    );
  }
  stdout.writeln('Pushed $remotePath ($expected bytes).');
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

/// Streams the device log into `device.log` under the report directory for
/// the whole app run, mirroring the multi-device convention: Android captures
/// the full logcat (no tag filter, so ONE SDK lines survive) and is archived
/// as `device.log.gz`; iOS streams the simulator log of the example app
/// process; ohos streams the full `hdc shell hilog`. iOS and ohos stay plain
/// text.
class _DeviceLogCapture {
  _DeviceLogCapture(this._process, this._sink, this._logPath);

  final Process _process;
  final IOSink _sink;
  final String _logPath;
  final _subscriptions = <StreamSubscription<String>>[];

  static Future<_DeviceLogCapture> start(_RunState state) async {
    final logPath = '${state.reportDir.path}/device.log';
    final sink = File(logPath).openWrite();
    final Process process;
    if (state.platform == 'android') {
      process = await Process.start('adb', [
        '-s',
        state.device,
        'logcat',
        '-v',
        'epoch',
        '-T',
        '1',
      ]);
    } else if (state.platform == 'ohos') {
      // Full hilog (no tag filter): the ohos fallback replays the APITEST
      // lines from this file, and native chatsdk lines stay searchable.
      // Clear the ring buffer first: hilog is device-global and still holds
      // APITEST lines from earlier runs, which a replay would misattribute
      // to this run.
      await Process.run('hdc', ['-t', state.device, 'shell', 'hilog', '-r']);
      process = await Process.start('hdc', [
        '-t',
        state.device,
        'shell',
        'hilog',
      ]);
    } else {
      process = await Process.start('xcrun', [
        'simctl',
        'spawn',
        state.device,
        'log',
        'stream',
        '--style',
        'compact',
        '--level',
        'debug',
        '--predicate',
        // Flutter prints carry no subsystem (NSLog-style, eventMessage starts
        // with "flutter:"); bridged native logs use the chatsdk subsystem.
        'process == "Runner" AND '
            '(subsystem == "com.hyphenate.chatsdk" OR '
            'eventMessage BEGINSWITH "flutter:")',
      ]);
    }
    final capture = _DeviceLogCapture(process, sink, logPath);
    // hilog carries non-UTF-8 bytes: decode leniently so one malformed chunk
    // cannot tear down the whole run.
    const lenientUtf8 = Utf8Decoder(allowMalformed: true);
    for (final stream in <Stream<List<int>>>[process.stdout, process.stderr]) {
      capture._subscriptions.add(
        stream
            .transform(lenientUtf8)
            .transform(const LineSplitter())
            .listen(sink.writeln),
      );
    }
    return capture;
  }

  /// Stops the collector and returns the archived log file name
  /// (`device.log.gz` on Android, `device.log` on iOS and ohos), or null when
  /// nothing usable was captured. A collector that ignores SIGINT is killed
  /// after five seconds; its already-captured bytes are still usable, so the
  /// exit path does not decide whether the log counts.
  Future<String?> stop(String platform) async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _process.kill(ProcessSignal.sigint);
    await _process.exitCode.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _process.kill(ProcessSignal.sigkill);
        return -1;
      },
    );
    await _sink.flush();
    await _sink.close();
    final logFile = File(_logPath);
    if (!await logFile.exists() || await logFile.length() == 0) {
      return null;
    }
    if (platform == 'android') {
      final bytes = await logFile.readAsBytes();
      final archived = File('${logFile.path}.gz');
      await archived.writeAsBytes(gzip.encode(bytes));
      return archived.path.split('/').last;
    }
    return logFile.path.split('/').last;
  }
}

Future<_DeviceLogCapture> _startDeviceLogCapture(_RunState state) async {
  final capture = await _DeviceLogCapture.start(state);
  stdout.writeln('Capturing device log to ${state.reportDir.path}/device.log');
  return capture;
}

Future<void> _runFlutter(
  _RunState state,
  Directory example,
  Directory root,
) async {
  final Process process;
  if (state.platform == 'ohos') {
    // hdc cannot write the app sandbox, so the script body travels inline as
    // the API_SCRIPT value; the engine decodes JSON strings directly.
    final inlineScript = jsonEncode(
      jsonDecode(await File(state.scriptHostPath).readAsString()),
    );
    final environment = Map<String, String>.from(Platform.environment);
    // Local emulator haps are unsigned unless the project configures signing.
    environment['OHOS_SKIP_CODESIGN'] ??= '1';
    // No shell: the inline JSON contains quotes and spaces, and the executable
    // is resolved to an absolute path here.
    process = await Process.start(
      _flutterExecutable(root),
      ['run', '-d', state.device, '--dart-define=API_SCRIPT=$inlineScript'],
      workingDirectory: example.path,
      environment: environment,
    );
  } else {
    final scriptArgument = state.platform == 'android'
        ? _androidScriptPath(state.runId)
        : state.scriptHostPath;
    process = await Process.start(
      'flutter',
      ['run', '-d', state.device, '--dart-define=API_SCRIPT=$scriptArgument'],
      workingDirectory: example.path,
      runInShell: true,
    );
  }

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
    state.timedOut = true;
    if (state.platform == 'ohos') {
      // The hilog capture may already hold the whole script; _replayDeviceLog
      // records the timeout as crash evidence only when that fallback fails.
      stdout.writeln(
        'No script.done from flutter run within 8 minutes; '
        'the hilog fallback will replay device.log.',
      );
    } else {
      state.recordCrash('REPORT_TIMEOUT: no script.done within 8 minutes');
    }
    process.kill(ProcessSignal.sigint);
  });

  state.processExitCode = await process.exitCode;
  timeout.cancel();
  await Future.wait([stdoutDone, stderrDone]);
}

/// ohos runs need the HarmonyOS fork of Flutter: FLUTTER_BIN wins, then the
/// project-pinned FVM SDK, then whatever `flutter` resolves to on PATH.
String _flutterExecutable(Directory root) {
  final fromEnvironment = Platform.environment['FLUTTER_BIN'];
  if (fromEnvironment != null && fromEnvironment.isNotEmpty) {
    return fromEnvironment;
  }
  final pinned = File('${root.path}/.fvm/flutter_sdk/bin/flutter');
  if (pinned.existsSync()) return pinned.path;
  return 'flutter';
}

Future<void> _consumeLines(Stream<List<int>> stream, _RunState state) async {
  await for (final line
      in stream
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())) {
    _consumeLine(line, state);
  }
}

void _consumeLine(String line, _RunState state) {
  final markerIndex = line.indexOf(_markerPrefix);
  if (markerIndex >= 0) {
    final rest = line.substring(markerIndex + _markerPrefix.length);
    if (rest.startsWith(']')) {
      _handleEventText(rest.substring(1).trim(), state);
    } else if (rest.startsWith('+')) {
      _consumeChunk(rest.substring(1), state);
    } else {
      // Keep unexpected shapes visible instead of dropping the event silently.
      // On ohos, hilog wraps long lines, so a torn chunk is a transport
      // artifact, not crash evidence; it stays visible via malformedLines.
      final sanitized = _sanitize(line);
      state.malformedLines.add(sanitized);
      if (state.platform != 'ohos') {
        state.crashSink.writeln(sanitized);
      }
    }
    return;
  }
  // The ohos fork `flutter run` exits right after launching while the app
  // keeps running on the device, so "Lost connection to device" on the
  // flutter stdout is expected there and must not be read as a crash; the
  // post-exit tail still catches real timeouts via REPORT_TIMEOUT.
  final lostConnectionIsCrash = state.platform != 'ohos';
  if (_isCrashEvidence(
    line,
    scriptCompleted: state.scriptDone != null,
    lostConnectionIsCrash: lostConnectionIsCrash,
  )) {
    state.crashLinesRemaining = 24;
  }
  if (state.crashLinesRemaining > 0) {
    final sanitized = _sanitize(line);
    state.crashLines.add(sanitized);
    state.crashSink.writeln(sanitized);
    state.crashLinesRemaining--;
  }
}

/// ohos fallback: the fork `flutter run` may exit right after launching the
/// app without forwarding any print output. The device-log capture keeps
/// streaming `hdc shell hilog` into device.log, so tail that file until
/// script.done shows up (8-minute budget, same as the stdout path).
Future<void> _tailDeviceLogForScriptDone(_RunState state) async {
  final logFile = File('${state.reportDir.path}/device.log');
  if (!await logFile.exists()) return;
  stdout.writeln(
    'No APITEST lines from flutter run; tailing device.log for script.done '
    '(8 min budget).',
  );
  final deadline = DateTime.now().add(const Duration(minutes: 8));
  const lenientUtf8 = Utf8Decoder(allowMalformed: true);
  var position = 0;
  var buffer = '';
  while (state.scriptDone == null && DateTime.now().isBefore(deadline)) {
    final length = await logFile.length();
    if (length > position) {
      final chunk = await logFile
          .openRead(position, length)
          .transform(lenientUtf8)
          .join();
      position = length;
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast();
      for (final line in lines) {
        _consumeLine(line, state);
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  if (state.scriptDone == null) {
    state.recordCrash('REPORT_TIMEOUT: no script.done within 8 minutes');
  }
  stdout.writeln(
    'Tailing captured ${state.events.length} APITEST event(s); '
    'scriptDone=${state.scriptDone != null}.',
  );
}

/// ohos fallback: replays the captured `hdc shell hilog` log through the same
/// parser when `flutter run` forwarded no APITEST line at all.
Future<void> _replayDeviceLog(_RunState state) async {
  final logFile = File('${state.reportDir.path}/device.log');
  if (!await logFile.exists() || await logFile.length() == 0) return;
  stdout.writeln(
    'No APITEST lines in the flutter run output; replaying device.log.',
  );
  await for (final line
      in logFile
          .openRead()
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())) {
    _consumeLine(line, state);
  }
  if (state.scriptDone == null && state.timedOut) {
    state.recordCrash('REPORT_TIMEOUT: no script.done within 8 minutes');
  }
  stdout.writeln(
    'Replayed ${state.events.length} APITEST event(s) from device.log.',
  );
}

void _handleEventText(String jsonText, _RunState state) {
  try {
    final event = Map<String, dynamic>.from(jsonDecode(jsonText) as Map);
    state.events.add(event);
    state.observeEvent(event);
    state.eventsSink.writeln(jsonEncode(event));
    stdout.writeln('$_stdoutPrefix ${jsonEncode(event)}');
    if (event['source'] == 'script.done') {
      state.scriptDone = Map<String, dynamic>.from(
        event['payload'] as Map? ?? const {},
      );
      if (!state.scriptDoneFuture.isCompleted) {
        state.scriptDoneFuture.complete();
      }
    }
  } catch (_) {
    // Torn chunks are expected on ohos (hilog wraps long lines); keep them
    // visible as malformed lines without poisoning the crash evidence.
    if (state.platform == 'ohos') {
      state.malformedLines.add(_sanitize(jsonText));
    } else {
      state.crashSink.writeln(_sanitize(jsonText));
    }
  }
}

/// Reassembles the ordered chunks that `LogStore` prints for events longer than
/// the device console line limit, e.g. `[APITEST+1/2] {"ts":...`.
void _consumeChunk(String text, _RunState state) {
  final close = text.indexOf(']');
  if (close <= 0) return;
  final progress = text.substring(0, close).split('/');
  if (progress.length != 2) return;
  final index = int.tryParse(progress[0]);
  final total = int.tryParse(progress[1]);
  if (index == null || total == null || total < 2) return;
  if (index < 1 || index > total) return;
  if (index == 1) state.pendingChunks = List<String?>.filled(total, null);
  final pending = state.pendingChunks;
  if (pending == null || pending.length != total) return;
  pending[index - 1] = text.substring(close + 1).trimLeft();
  if (pending.any((part) => part == null)) return;
  state.pendingChunks = null;
  _handleEventText(pending.join(), state);
}

bool _isCrashEvidence(
  String line, {
  required bool scriptCompleted,
  bool lostConnectionIsCrash = true,
}) {
  return line.contains('FATAL EXCEPTION') ||
      line.contains('NullPointerException') ||
      line.contains('SIGSEGV') ||
      (lostConnectionIsCrash &&
          !scriptCompleted &&
          line.contains('Lost connection to device')) ||
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

Future<void> _checkedProcess(
  String executable,
  List<String> args, {
  String? workingDirectory,
}) async {
  final result = await Process.run(
    executable,
    args,
    workingDirectory: workingDirectory,
  );
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
  final metadata = <String, Object?>{
    'schemaVersion': 1,
    'runId': state.runId,
    'startedAt': startedAt.toIso8601String(),
    'platform': state.platform,
    'device': state.device,
    'script': state.scriptRelativePath,
    'scriptKind': state.scriptKind.name,
    'commit': (commit.stdout as String).trim(),
    'worktreeDirty': (status.stdout as String).trim().isNotEmpty,
    'scriptSha256': (scriptHash.stdout as String).split(' ').first,
    'runnerSha256': (runnerHash.stdout as String).split(' ').first,
    'sensitiveValues': 'not included',
    'initOptions': {
      for (final entry
          in (jsonDecode(await script.readAsString())['init'] as Map? ??
                  const {})
              .entries)
        if (const [
              'debugMode',
              'enableUserInfo',
              'autoLoadConversations',
              'enableChatroomConversation',
            ].contains(entry.key) &&
            (entry.value is bool || entry.value is int))
          entry.key as String: entry.value,
    },
    'sdkVersion': RegExp(r'^version:\s*(\S+)', multiLine: true)
        .firstMatch(
          await File('${root.path}/im_flutter_sdk/pubspec.yaml').readAsString(),
        )
        ?.group(1),
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
  final metadataFile = File('${reportDir.path}/run.json');
  final metadata = await metadataFile.exists()
      ? Map<String, dynamic>.from(
          jsonDecode(await metadataFile.readAsString()) as Map,
        )
      : <String, dynamic>{
          'runId': state.runId,
          'platform': state.platform,
          'script': state.scriptRelativePath,
          'scriptKind': state.scriptKind.name,
          'startedAt': startedAt.toIso8601String(),
        };
  metadata.addAll({
    'device': state.device,
    'finishedAt': finishedAt.toIso8601String(),
    'processExitCode': state.processExitCode,
    'executionErrors': state.executionErrors,
    'deviceLog': state.deviceLogFile,
  });
  await metadataFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(metadata),
  );
  final counts = <String, int>{};
  for (final outcome in state.outcomes) {
    counts.update(outcome.status, (value) => value + 1, ifAbsent: () => 1);
  }
  final summary = StringBuffer()
    ..writeln('# Auto-mode run ${state.runId}')
    ..writeln()
    ..writeln('- Platform: `${state.platform}`')
    ..writeln('- Device: `${state.device}`')
    ..writeln('- Script: `${state.scriptRelativePath}`')
    ..writeln('- Path: `${state.scriptKind.name}`')
    ..writeln('- Started: `${startedAt.toIso8601String()}`')
    ..writeln('- Finished: `${finishedAt.toIso8601String()}`')
    ..writeln('- APITEST events: `${state.events.length}`')
    ..writeln('- script.done: `${done == null ? 'missing' : jsonEncode(done)}`')
    ..writeln('- Step outcomes: `${jsonEncode(counts)}`')
    ..writeln('- Malformed APITEST lines: `${state.malformedLines.length}`')
    ..writeln(
      '- Crash evidence: `${state.crashLines.isEmpty ? 'none' : 'see crash.log'}`',
    )
    ..writeln('- Device log: `${state.deviceLogFile ?? 'not captured'}`')
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

  await File('${reportDir.path}/issues.md').writeAsString(_buildIssues(state));
}

/// Builds the issue candidates for one run. The negative path always records the
/// intentionally masked Android crash case; a crash that still happens during a
/// run is recorded as its own candidate instead of being retried by a script.
String _buildIssues(_RunState state) {
  final issues = StringBuffer()
    ..writeln('# Issue candidates')
    ..writeln()
    ..writeln('Run: `${state.runId}`')
    ..writeln('- Script: `${state.scriptRelativePath}`')
    ..writeln('- Path: `${state.scriptKind.name}`')
    ..writeln()
    ..writeln(
      'Candidate keys are semantic labels for review, not external issue IDs. Mark each candidate as `confirmed`, `environment`, `blocked`, `accepted`, or `retest`.',
    )
    ..writeln();
  // The known-crash candidate belongs to the scripts that actually carry the
  // step (4.x/5.x negative scripts); the ohos 1.16.0 negative script has no
  // receipt steps, so it must not report this Android-native crash at all.
  final hasGroupReceiptStep = state.scriptSteps.any(
    (step) => step.id == 'fetch_group_receipt_missing',
  );
  if (state.scriptKind == _ScriptKind.negative && hasGroupReceiptStep) {
    issues
      ..writeln('## Candidate: `fetch-group-receipt-missing-disabled`')
      ..writeln(
        '- Step: `fetch_group_receipt_missing` (intentionally not executed)',
      )
      ..writeln(
        '- Actual: a missing message in `ChatManager.fetchGroupMessageReadReceipts` terminates the Android native process before it returns',
      )
      ..writeln(
        '- Expected: an error result consistent with the other two missing-message receipt APIs',
      )
      ..writeln('- Status: `known-crash`')
      ..writeln(
        '- Evidence: `crash.log` of `20260918041624-android-emulator-5554`; see `docs/porting/5.0.0/04-verification.md`',
      )
      ..writeln();
  }
  for (final outcome in state.outcomes.where(
    (item) => item.status == 'crashed',
  )) {
    issues
      ..writeln('## Candidate: `${outcome.step.id}-crash`')
      ..writeln('- Step: `${outcome.step.id}`')
      ..writeln('- API: `${outcome.step.api}`')
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
      ..writeln('- Actual: `${jsonEncode(outcome.result)}`');
    final note = _candidateNote(outcome);
    if (note.isNotEmpty) issues.writeln(note);
    issues
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
  if (state.groupReceiptTotalCountMissing) {
    issues
      ..writeln('## Candidate: `group-receipt-total-count-missing`')
      ..writeln(
        '- Actual: `${state.platform}` returned `totalCount: null` for a successful group-receipt pagination',
      )
      ..writeln(
        '- Expected: the native callback totalCount is forwarded as a number (`0` on iOS, `null` on Android 5.0.0)',
      )
      ..writeln('- Status: `confirmed` by Android/iOS comparison')
      ..writeln();
  }
  if (state.malformedLines.isNotEmpty) {
    issues
      ..writeln('## Candidate: `apitest-line-not-reassembled`')
      ..writeln(
        '- Actual: `${state.malformedLines.length}` `[APITEST` line(s) did not match the plain or chunked event format and were dropped',
      )
      ..writeln(
        '- Expected: every event arrives as `[APITEST] <json>` or as `[APITEST+<index>/<total>] <chunk>` chunks',
      )
      ..writeln('- Evidence: `crash.log`')
      ..writeln('- Status: `needs-review`')
      ..writeln();
  }
  return issues.toString();
}

String _candidateKey(_StepOutcome outcome) {
  if (outcome.step.id == 'group_message') {
    return 'receipt-service-unavailable';
  }
  if (outcome.step.id == 'modify_self') {
    return 'message-edit-service-unavailable';
  }
  return '${outcome.step.id}-unexpected-result';
}

String _candidateNote(_StepOutcome outcome) {
  if (outcome.step.id == 'modify_self') {
    return '- Note: `305` `SERVICE_NOT_ENABLE` means the message-edit service is not enabled for the configured environment; the positive path asserts the public contract, so this is an environment limitation.';
  }
  if (outcome.step.id == 'message_translate_self') {
    return '- Note: `305` `SERVICE_NOT_ENABLE` means the message-translation service is not enabled for the configured environment; the positive path asserts the public contract, so this is an environment limitation.';
  }
  if (outcome.step.id == 'receipt_missing' ||
      outcome.step.id == 'group_receipt_missing') {
    return '- Note: a batch without any resolvable message is expected to return the native `110` `INVALID_PARAM` (`messages is empty`); Flutter does not construct error codes or drop the batch.';
  }
  if (outcome.step.id == 'renew_invalid_token') {
    return '- Note: the target contract is `104` `INVALID_TOKEN`; a successful result means the native empty-token branch does not reject the input.';
  }
  return '';
}

String _timestamp(DateTime date) =>
    date.toIso8601String().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);

String _markdownCell(Object? value) =>
    (value ?? '').toString().replaceAll('|', r'\|').replaceAll('\n', ' ');

class _Comparison {
  const _Comparison({
    required this.outputPath,
    required this.kind,
    required this.stepMismatches,
    required this.errorCodeMismatches,
  });

  final String outputPath;
  final _ScriptKind kind;
  final int stepMismatches;
  final int errorCodeMismatches;

  int get mismatches => stepMismatches + errorCodeMismatches;
}

class _RunReport {
  const _RunReport({
    required this.runId,
    required this.script,
    required this.steps,
  });

  final String runId;
  final String script;
  final List<Map<String, dynamic>> steps;

  Map<String, Map<String, dynamic>> get byId => {
    for (final step in steps)
      if (step['id'] != null) step['id'].toString(): step,
  };
}

Future<_RunReport> _loadRunReport(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) {
    throw StateError('Run directory not found: $path');
  }
  final runFile = File('${directory.path}/run.json');
  final stepsFile = File('${directory.path}/steps.json');
  if (!await runFile.exists() || !await stepsFile.exists()) {
    throw StateError('run.json and steps.json are required in $path');
  }
  final metadata = Map<String, dynamic>.from(
    jsonDecode(await runFile.readAsString()) as Map,
  );
  final rawSteps = jsonDecode(await stepsFile.readAsString()) as List;
  return _RunReport(
    runId: metadata['runId']?.toString() ?? directory.path.split('/').last,
    script: metadata['script']?.toString() ?? '',
    steps: [for (final raw in rawSteps) Map<String, dynamic>.from(raw as Map)],
  );
}

/// Reads the expected error code per step id from the script referenced by a run.
Future<Map<String, int?>> _expectedErrorCodes(String scriptPath) async {
  if (scriptPath.isEmpty) return const {};
  final file = File(
    scriptPath.startsWith('/')
        ? scriptPath
        : '${Directory.current.path}/$scriptPath',
  );
  if (!await file.exists()) return const {};
  try {
    final script = Map<String, dynamic>.from(
      jsonDecode(await file.readAsString()) as Map,
    );
    final steps = script['steps'];
    if (steps is! List) return const {};
    return {
      for (final raw in steps)
        if (raw is Map && raw['id'] is String)
          raw['id'] as String: raw['expect'] is Map
              ? (raw['expect'] as Map)['errorCode'] as int?
              : null,
    };
  } catch (_) {
    return const {};
  }
}

Map<String, Object?> _resultSemantics(Map<String, dynamic>? outcome) {
  final actual = outcome?['actual'];
  final map = actual is Map ? actual : const {};
  final error = map['error'];
  return {
    'success': map['success'],
    'errorCode': error is Map ? error['code'] : null,
  };
}

Object? _shapeOf(Object? value) {
  if (value == null) return 'null';
  if (value is List) {
    return value.isEmpty ? <Object?>[] : <Object?>[_shapeOf(value.first)];
  }
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {for (final key in keys) key: _shapeOf(value[key])};
  }
  return value.runtimeType.toString();
}

List<String> _differentShapePaths(
  Object? first,
  Object? second, [
  String prefix = '',
]) {
  if (jsonEncode(first) == jsonEncode(second)) return const [];
  final location = prefix.isEmpty ? r'$' : prefix;
  if (first == null || second == null) return [location];
  if (first is List && second is List) {
    if (first.isEmpty || second.isEmpty) return [location];
    return _differentShapePaths(first.first, second.first, '$prefix[]');
  }
  if (first is! Map || second is! Map) return [location];
  final keys = <String>{
    ...first.keys.map((key) => key.toString()),
    ...second.keys.map((key) => key.toString()),
  }.toList()..sort();
  return [
    for (final key in keys)
      ..._differentShapePaths(
        first[key],
        second[key],
        prefix.isEmpty ? key : '$prefix.$key',
      ),
  ];
}

/// Compares two finished runs of the same path: step status and result semantics
/// for both paths, plus response shape; the negative path also gets an explicit
/// Android/iOS error-code table against the expected codes from the script.
Future<_Comparison> _compareReports(
  String androidPath,
  String iosPath,
  Directory outputRoot,
) async {
  final android = await _loadRunReport(androidPath);
  final ios = await _loadRunReport(iosPath);
  final kind = _scriptKindOf(
    android.script.isNotEmpty ? android.script : ios.script,
  );
  final androidById = android.byId;
  final iosById = ios.byId;
  final ids = <String>{...androidById.keys, ...iosById.keys}.toList()..sort();
  final expectedCodes = await _expectedErrorCodes(
    android.script.isNotEmpty ? android.script : ios.script,
  );

  var stepMismatches = 0;
  var errorCodeMismatches = 0;
  final lines = <String>[
    '# Android / iOS auto-mode comparison (${kind.name} path)',
    '',
    '- Android run: `${android.runId}`',
    '- iOS run: `${ios.runId}`',
    '- Script: `${android.script.isNotEmpty ? android.script : ios.script}`',
    '',
    '| step | Android | iOS | result semantics | response shape | status |',
    '| --- | --- | --- | --- | --- | --- |',
  ];
  final errorRows = <String>[];
  for (final id in ids) {
    final a = androidById[id];
    final i = iosById[id];
    var status = '✅';
    if (a == null ||
        i == null ||
        a['status'] != i['status'] ||
        a['status'] != 'passed') {
      status = '❌';
      stepMismatches++;
    }
    final aSemantics = _resultSemantics(a);
    final iSemantics = _resultSemantics(i);
    final semanticsEqual = jsonEncode(aSemantics) == jsonEncode(iSemantics);
    final aShape = _shapeOf(a?['actual']);
    final iShape = _shapeOf(i?['actual']);
    final shapeEqual = jsonEncode(aShape) == jsonEncode(iShape);
    if (status == '✅' && (!semanticsEqual || !shapeEqual)) status = '⚠️';
    lines.add(
      '| `${_markdownCell(id)}` | ${_markdownCell(a?['status'] ?? 'missing')} '
      '| ${_markdownCell(i?['status'] ?? 'missing')} '
      '| ${semanticsEqual ? 'same' : _markdownCell('A=${jsonEncode(aSemantics)}; I=${jsonEncode(iSemantics)}')} '
      '| ${shapeEqual ? 'same' : _markdownCell(_differentShapePaths(aShape, iShape).join(', '))} '
      '| $status |',
    );
    if (kind != _ScriptKind.negative) continue;
    final expected = expectedCodes[id];
    final aCode = aSemantics['errorCode'];
    final iCode = iSemantics['errorCode'];
    var codeStatus = '✅';
    if (aCode != iCode) {
      codeStatus = '❌';
      errorCodeMismatches++;
    } else if (expected != null && aCode != expected) {
      codeStatus = '⚠️';
    }
    errorRows.add(
      '| `${_markdownCell(id)}` | ${_markdownCell(expected ?? '-')} '
      '| ${_markdownCell(aCode ?? '-')} | ${_markdownCell(iCode ?? '-')} '
      '| $codeStatus |',
    );
  }
  lines
    ..add('')
    ..add(
      '- Step mismatches: `$stepMismatches`; error-code mismatches: `$errorCodeMismatches`',
    );
  if (errorRows.isNotEmpty) {
    lines
      ..add('')
      ..add('## Error codes')
      ..add('')
      ..add('| step | expected | Android | iOS | status |')
      ..add('| --- | --- | --- | --- | --- |')
      ..addAll(errorRows);
  }
  await outputRoot.create(recursive: true);
  final stamp = _timestamp(DateTime.now().toUtc());
  var output = File('${outputRoot.path}/comparison-${kind.name}-$stamp.md');
  var suffix = 2;
  while (await output.exists()) {
    output = File(
      '${outputRoot.path}/comparison-${kind.name}-$stamp-$suffix.md',
    );
    suffix++;
  }
  await output.writeAsString('${lines.join('\n')}\n');
  return _Comparison(
    outputPath: output.path,
    kind: kind,
    stepMismatches: stepMismatches,
    errorCodeMismatches: errorCodeMismatches,
  );
}

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
  try {
    return stepResultMatchesExpectation(result, expectation);
  } on FormatException {
    return false;
  }
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

enum _ScriptKind { positive, negative, unknown }

class _RunState {
  _RunState({
    required this.platform,
    required this.device,
    required this.runId,
    required this.reportDir,
    required this.eventsSink,
    required this.crashSink,
    required this.scriptSteps,
    required this.scriptRelativePath,
    required this.scriptHostPath,
    required this.scriptKind,
  });

  final String platform;
  String device;
  final String runId;
  final Directory reportDir;
  final IOSink eventsSink;
  final IOSink crashSink;
  final List<_ScriptStep> scriptSteps;
  final String scriptRelativePath;
  final String scriptHostPath;
  final _ScriptKind scriptKind;
  final events = <Map<String, dynamic>>[];
  final crashLines = <String>[];
  final malformedLines = <String>[];
  final outcomes = <_StepOutcome>[];
  final executionErrors = <String>[];
  int? processExitCode;

  /// Archived device log file name inside the report directory
  /// (`device.log.gz` on Android, `device.log` on iOS); null when the
  /// capture was unavailable.
  String? deviceLogFile;
  final scriptDoneFuture = Completer<void>();
  int crashLinesRemaining = 0;
  int nextStepIndex = 0;

  /// `flutter run` hit its timeout before `script.done`. On ohos the hilog
  /// replay may still recover the run, so the timeout only becomes crash
  /// evidence when the replay finds no `script.done` either.
  bool timedOut = false;
  List<String?>? pendingChunks;
  Map<String, dynamic>? scriptDone;

  bool get hasFailure =>
      scriptDone == null ||
      executionErrors.isNotEmpty ||
      outcomes.any((item) => item.status != 'passed');

  bool get hasConversationSerializationGap => outcomes.any((item) {
    if (item.step.id != 'conversations') return false;
    final data = item.result?['data'];
    return data is List &&
        data.any(
          (value) =>
              value.toString().startsWith("Instance of 'ChatConversation'"),
        );
  });

  /// A successful group-receipt pagination that does not forward `totalCount`
  /// as a number; observed on Android 5.0.0 while iOS returns `0`.
  bool get groupReceiptTotalCountMissing => outcomes.any((item) {
    if (item.step.id != 'group_receipts_server' || item.status != 'passed') {
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
