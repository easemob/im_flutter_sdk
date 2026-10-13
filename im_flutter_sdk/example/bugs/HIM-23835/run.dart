import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../tool/env_tool.dart';
import '../../tool/rest_resource_client.dart';

const _ticket = 'HIM-23835';
const _bundleId = 'com.example.example';
const _apiPrefix = '[APITEST] ';
const _phaseTimeout = Duration(minutes: 3);

Future<void> main(List<String> args) async {
  try {
    final options = _Options.parse(args);
    if (options.help) {
      _printHelp();
      return;
    }
    if (options.selfTest) {
      await _selfTest();
      stdout.writeln('$_ticket self-test passed');
      return;
    }

    await _Runner(Directory.current.absolute, options).run();
  } catch (error, stackTrace) {
    stderr.writeln('$_ticket: $error');
    if (error is! FormatException) stderr.writeln(stackTrace);
    exitCode = 1;
  }
}

void _printHelp() {
  stdout.writeln('''
Usage:
  bash im_flutter_sdk/example/bugs/HIM-23835/HIM-23835.sh [options]

Options:
  --devices <mirror,controller>  Use two specific simulator UDIDs.
  --config <path>                Use an external env-tool JSON config.
  --keep-apps                    Keep the example app installed afterward.
  --self-test                    Check orchestration data without devices.
  --help                         Show this help.

Run from the 5.0.0 worktree root. Configuration is resolved from --config,
HIM_23835_CONFIG, E2E_* environment variables, or the existing local config in
that order. Tokens and API_CONFIG are generated in a temporary directory. The
mirror receives callbacks; the controller performs UPDATE and KICK through the
Flutter SDK.
''');
}

final class _Options {
  const _Options({
    required this.devices,
    required this.configPath,
    required this.keepApps,
    required this.selfTest,
    required this.help,
  });

  factory _Options.parse(List<String> args) {
    String? devices;
    String? configPath;
    var keepApps = false;
    var selfTest = false;
    var help = false;

    for (var index = 0; index < args.length; index++) {
      switch (args[index]) {
        case '--devices':
          if (++index >= args.length) {
            throw const FormatException('--devices requires two UDIDs');
          }
          devices = args[index];
        case '--config':
          if (++index >= args.length) {
            throw const FormatException('--config requires a JSON path');
          }
          configPath = args[index];
        case '--keep-apps':
          keepApps = true;
        case '--self-test':
          selfTest = true;
        case '--help':
        case '-h':
          help = true;
        default:
          throw FormatException('Unknown argument: ${args[index]}');
      }
    }

    return _Options(
      devices: devices,
      configPath: configPath,
      keepApps: keepApps,
      selfTest: selfTest,
      help: help,
    );
  }

  final String? devices;
  final String? configPath;
  final bool keepApps;
  final bool selfTest;
  final bool help;
}

final class _Runner {
  _Runner(this.root, this.options);

  final Directory root;
  final _Options options;

  late final Directory example = Directory(
    '${root.path}/im_flutter_sdk/example',
  );
  late final Directory reportDirectory;
  late final Directory temporaryDirectory;
  late final File activeScript;
  late final File runtimeConfig;
  late final Directory runnerApp;
  late final _Devices devices;
  late final _TestConfig testConfig;

  RestResourceClient? restClient;
  String? groupId;
  String? threadId;
  var cleanupCompleted = false;
  var devicesSelected = false;
  var appInstallationStarted = false;
  var appsInstalled = false;

  Future<void> run() async {
    _validateRoot();
    final startedAt = DateTime.now().toUtc();
    final runId = '$_ticket-${_timestamp(startedAt)}';
    reportDirectory = Directory('${root.path}/reports/5.0.0/$runId');
    await reportDirectory.create(recursive: true);
    temporaryDirectory = await Directory.systemTemp.createTemp('$_ticket-');
    activeScript = File('${temporaryDirectory.path}/active.json');
    runtimeConfig = File('${temporaryDirectory.path}/runtime-config.json');

    Object? failure;
    StackTrace? failureStack;
    try {
      testConfig = await _readTestConfig();
      await _prepareRuntimeConfig();

      stdout.writeln(
        'Creating group, root message, and thread through REST...',
      );
      await _prepareResources(runId);

      devices = await _selectDevices(options.devices);
      devicesSelected = true;
      await _bootDevices();
      await _writeActiveScript('mirror', _mirrorScript());
      await _buildApp();
      appInstallationStarted = true;
      await _installApps();
      appsInstalled = true;

      stdout.writeln('Starting mirror account A on ${devices.mirror.name}...');
      await _startMirror();

      stdout.writeln('Updating the thread from controller account A...');
      final updateEvents = await _runPhase(
        role: 'controller-update',
        script: _updateScript(threadId!, runId),
      );
      _requireSuccessfulPhase('controller-update', updateEvents);
      await _waitForMirrorThreadEvent(
        event: 'CHAT_THREAD_UPDATE',
        threadId: threadId!,
      );

      stdout.writeln('Removing account B from the thread...');
      final kickEvents = await _runPhase(
        role: 'controller-kick',
        script: _kickScript(threadId!, testConfig.accountB),
      );
      _requireSuccessfulPhase('controller-kick', kickEvents);
      await _waitForMirrorThreadEvent(
        event: 'CHAT_THREAD_KICK',
        threadId: threadId!,
        expectedUser: testConfig.accountB,
      );

      stdout.writeln('Deleting REST test resources...');
      await _cleanupResources();
      cleanupCompleted = true;
    } catch (error, stackTrace) {
      failure = error;
      failureStack = stackTrace;
    } finally {
      if (!cleanupCompleted && groupId != null && restClient != null) {
        try {
          stdout.writeln('Retrying REST cleanup after failure...');
          await _cleanupResources();
          cleanupCompleted = true;
        } catch (cleanupError) {
          stderr.writeln('Cleanup failed: $cleanupError');
        }
      }
      restClient?.close();
      if (appsInstalled) {
        await _collectFinalLogs();
        await _stopApps();
      }
      if (appInstallationStarted && !options.keepApps) await _uninstallApps();
      if (devicesSelected) await _restoreDeviceBootState();
      await _writeRunMetadata(
        startedAt: startedAt,
        finishedAt: DateTime.now().toUtc(),
        passed: failure == null,
        error: failure,
      );
      if (!options.keepApps && await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(recursive: true);
      }
    }

    if (failure != null) {
      Error.throwWithStackTrace(failure, failureStack!);
    }
    stdout.writeln('$_ticket passed: ${reportDirectory.path}');
  }

  void _validateRoot() {
    if (!File('${example.path}/pubspec.yaml').existsSync()) {
      throw StateError('Run $_ticket from the 5.0.0 worktree root.');
    }
  }

  Future<_TestConfig> _readTestConfig() async {
    final environmentConfig = _configFromEnvironment();
    Map<String, dynamic> config;
    final requestedPath =
        options.configPath ?? Platform.environment['HIM_23835_CONFIG'];
    if (requestedPath != null && requestedPath.isNotEmpty) {
      final file = File(requestedPath).absolute;
      if (!await file.exists()) {
        throw StateError('Config file not found: ${file.path}');
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        throw FormatException('${file.path} must be a JSON object');
      }
      config = Map<String, dynamic>.from(decoded);
    } else if (environmentConfig != null) {
      config = environmentConfig;
    } else {
      final file = File('${example.path}/config.local.json');
      if (!await file.exists()) {
        throw StateError(
          'Provide --config, HIM_23835_CONFIG, or the E2E_* variables.',
        );
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        throw const FormatException(
          'example/config.local.json must be a JSON object',
        );
      }
      config = Map<String, dynamic>.from(decoded);
    }
    for (final key in const ['restApi', 'appKey', 'clientId', 'clientSecret']) {
      final value = config[key];
      if (value is! String || value.isEmpty || value.startsWith('TODO')) {
        throw FormatException('config field $key is missing or a placeholder');
      }
    }
    final rawAccounts = config['accounts'];
    if (rawAccounts is! List || rawAccounts.length < 2) {
      throw const FormatException(
        'HIM-23835 requires accounts[0] and accounts[1].',
      );
    }
    final ids = <String>[];
    for (var index = 0; index < 2; index++) {
      final account = rawAccounts[index];
      final id = account is Map ? account['id'] : null;
      if (id is! String || id.isEmpty || id.startsWith('TODO')) {
        throw FormatException(
          'accounts[$index].id is missing or a placeholder',
        );
      }
      ids.add(id);
    }
    if (ids[0] == ids[1]) {
      throw const FormatException('accounts[0] and accounts[1] must differ');
    }
    return _TestConfig(raw: config, accountA: ids[0], accountB: ids[1]);
  }

  Future<void> _prepareRuntimeConfig() async {
    final tokenClient = TokenClient();
    try {
      final appToken = await tokenClient.fetchAppToken(testConfig.raw);
      final accounts = await tokenClient.fetchUserTokens(
        config: testConfig.raw,
        appToken: appToken,
      );
      final environment = buildEnvironment(
        config: testConfig.raw,
        accounts: accounts,
      );
      await runtimeConfig.writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(environment)}\n',
        flush: true,
      );
      if (!Platform.isWindows) {
        await Process.run('chmod', ['600', runtimeConfig.path]);
      }
      restClient = RestResourceClient(
        restApi: testConfig.raw['restApi'] as String,
        appKey: testConfig.raw['appKey'] as String,
        appToken: appToken,
      );
    } finally {
      tokenClient.close();
    }
  }

  Future<void> _prepareResources(String runId) async {
    final client = restClient!;
    groupId = await client.createGroup(
      owner: testConfig.accountA,
      name: '$_ticket-$runId',
      description: '$_ticket multi-device regression',
      members: [testConfig.accountB],
      maxUsers: 20,
    );
    final messageId = await client.sendGroupTextMessage(
      from: testConfig.accountA,
      groupId: groupId!,
      text: '$_ticket root message',
    );
    threadId = await client.createThread(
      groupId: groupId!,
      name: '$_ticket-thread',
      owner: testConfig.accountA,
      messageId: messageId,
    );
    await client.addThreadMembers(threadId!, [testConfig.accountB]);
  }

  Future<void> _cleanupResources() async {
    Object? firstError;
    StackTrace? firstStack;
    if (threadId != null) {
      try {
        await restClient!.deleteThread(threadId!);
      } catch (error, stackTrace) {
        firstError = error;
        firstStack = stackTrace;
      }
    }
    try {
      await restClient!.deleteGroup(groupId!);
    } catch (error, stackTrace) {
      firstError ??= error;
      firstStack ??= stackTrace;
    }
    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStack!);
    }
  }

  Future<void> _buildApp() async {
    await _streamProcess('bash', ['tool/ci/ensure_example_env.sh'], root.path);
    await _streamProcess(
        'flutter',
        [
          'build',
          'ios',
          '--simulator',
          '--debug',
          '--dart-define=API_SCRIPT=${activeScript.path}',
          '--dart-define=API_CONFIG=${runtimeConfig.path}',
        ],
        example.path);
    runnerApp = Directory(
      '${example.path}/build/ios/iphonesimulator/Runner.app',
    );
    if (!await runnerApp.exists()) {
      throw StateError(
        'iOS simulator app was not produced at ${runnerApp.path}',
      );
    }
  }

  Future<void> _bootDevices() async {
    for (final device in devices.all) {
      if (!device.wasBooted) {
        await Process.run('xcrun', ['simctl', 'boot', device.udid]);
      }
      await _checkedProcess('xcrun', [
        'simctl',
        'bootstatus',
        device.udid,
        '-b',
      ]);
    }
  }

  Future<void> _installApps() async {
    for (final device in devices.all) {
      await Process.run('xcrun', [
        'simctl',
        'uninstall',
        device.udid,
        _bundleId,
      ]);
      await _checkedProcess('xcrun', [
        'simctl',
        'install',
        device.udid,
        runnerApp.path,
      ]);
    }
  }

  Future<void> _startMirror() async {
    await _writeActiveScript('mirror', _mirrorScript());
    final log = await _clearAppLog(devices.mirror);
    await _launch(devices.mirror);
    await _waitForEvents(
      log,
      (events) =>
          _hasSuccessfulLogin(events) &&
          events.any(
            (event) => event['source'] == 'ConnectionEventHandler.onConnected',
          ) &&
          _hasScriptDone(events),
      label: 'mirror login and connection',
    );
  }

  Future<List<Map<String, dynamic>>> _runPhase({
    required String role,
    required Map<String, dynamic> script,
  }) async {
    await _writeActiveScript(role, script);
    final log = await _clearAppLog(devices.controller);
    await _launch(devices.controller);
    final events = await _waitForEvents(
      log,
      _hasScriptDone,
      label: '$role script.done',
    );
    await _copyLog(log, role);
    return events;
  }

  Future<void> _waitForMirrorThreadEvent({
    required String event,
    required String threadId,
    String? expectedUser,
  }) async {
    final log = await _appLog(devices.mirror);
    await _waitForEvents(
      log,
      (events) => events.any((entry) {
        if (entry['source'] !=
            'ChatMultiDeviceEventHandler.onChatThreadEvent') {
          return false;
        }
        final payload = entry['payload'];
        if (payload is! Map ||
            payload['event'] != event ||
            payload['chatThreadId'] != threadId) {
          return false;
        }
        if (expectedUser == null) return true;
        final users = payload['userIds'];
        return users is List && users.contains(expectedUser);
      }),
      label: 'mirror $event callback',
    );
    await _copyLog(log, 'mirror-$event');
  }

  Future<void> _writeActiveScript(
    String role,
    Map<String, dynamic> script,
  ) async {
    final encoded = const JsonEncoder.withIndent('  ').convert(script);
    final temporary = File('${activeScript.path}.new');
    await temporary.writeAsString('$encoded\n', flush: true);
    if (await activeScript.exists()) await activeScript.delete();
    await temporary.rename(activeScript.path);

    final scripts = Directory('${reportDirectory.path}/scripts');
    await scripts.create(recursive: true);
    await File('${scripts.path}/$role.json').writeAsString('$encoded\n');
  }

  Future<File> _clearAppLog(_SimDevice device) async {
    final log = await _appLog(device);
    if (await log.exists()) await log.delete();
    return log;
  }

  Future<File> _appLog(_SimDevice device) async {
    final result = await _checkedProcess('xcrun', [
      'simctl',
      'get_app_container',
      device.udid,
      _bundleId,
      'data',
    ]);
    final container = (result.stdout as String).trim();
    if (container.isEmpty) {
      throw StateError('No app data container for ${device.name}');
    }
    return File('$container/Documents/api_test.log');
  }

  Future<void> _launch(_SimDevice device) async {
    await _checkedProcess('xcrun', [
      'simctl',
      'launch',
      '--terminate-running-process',
      device.udid,
      _bundleId,
    ]);
  }

  Future<List<Map<String, dynamic>>> _waitForEvents(
    File log,
    bool Function(List<Map<String, dynamic>>) predicate, {
    required String label,
  }) async {
    final stopwatch = Stopwatch()..start();
    var events = <Map<String, dynamic>>[];
    while (stopwatch.elapsed < _phaseTimeout) {
      events = await _readEvents(log);
      if (predicate(events)) return events;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw TimeoutException(
      '$label was not observed within ${_phaseTimeout.inMinutes} minutes',
    );
  }

  Future<void> _copyLog(File source, String role) async {
    if (!await source.exists()) return;
    await source.copy('${reportDirectory.path}/$role.log');
  }

  Future<void> _collectFinalLogs() async {
    try {
      await _copyLog(await _appLog(devices.mirror), 'mirror-final');
    } catch (_) {}
  }

  Future<void> _stopApps() async {
    for (final device in devices.all) {
      await Process.run('xcrun', [
        'simctl',
        'terminate',
        device.udid,
        _bundleId,
      ]);
    }
  }

  Future<void> _uninstallApps() async {
    for (final device in devices.all) {
      await Process.run('xcrun', [
        'simctl',
        'uninstall',
        device.udid,
        _bundleId,
      ]);
    }
  }

  Future<void> _restoreDeviceBootState() async {
    for (final device in devices.all.where((device) => !device.wasBooted)) {
      await Process.run('xcrun', ['simctl', 'shutdown', device.udid]);
    }
  }

  Future<void> _writeRunMetadata({
    required DateTime startedAt,
    required DateTime finishedAt,
    required bool passed,
    required Object? error,
  }) async {
    final commit = await Process.run(
        'git',
        [
          'rev-parse',
          'HEAD',
        ],
        workingDirectory: root.path);
    final metadata = <String, Object?>{
      'ticket': _ticket,
      'status': passed ? 'passed' : 'failed',
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt.toIso8601String(),
      'commit': commit.exitCode == 0
          ? (commit.stdout as String).trim()
          : '<unavailable>',
      if (appsInstalled)
        'devices': {
          'mirror': devices.mirror.udid,
          'controller': devices.controller.udid,
        },
      'threadIdCreated': threadId != null,
      'groupIdCreated': groupId != null,
      'cleanupCompleted': cleanupCompleted,
      if (error != null) 'error': error.toString(),
    };
    await File('${reportDirectory.path}/run.json').writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(metadata)}\n',
    );
    await File('${reportDirectory.path}/summary.md').writeAsString('''
# $_ticket iOS multi-device regression

- Status: ${passed ? 'PASS' : 'FAIL'}
- Resources prepared through REST: ${threadId != null ? 'yes' : 'no'}
- UPDATE callback matched the created thread: ${passed ? 'yes' : 'not confirmed'}
- KICK callback matched the created thread and member: ${passed ? 'yes' : 'not confirmed'}
- REST cleanup completed: ${cleanupCompleted ? 'yes' : 'no'}
${error == null ? '' : '- Error: ${error.toString()}\n'}''');
  }
}

final class _TestConfig {
  const _TestConfig({
    required this.raw,
    required this.accountA,
    required this.accountB,
  });

  final Map<String, dynamic> raw;
  final String accountA;
  final String accountB;
}

Map<String, dynamic>? _configFromEnvironment() {
  const names = <String>[
    'E2E_REST_API',
    'E2E_APP_KEY',
    'E2E_CLIENT_ID',
    'E2E_CLIENT_SECRET',
    'E2E_USER_A_ID',
    'E2E_USER_B_ID',
  ];
  final environment = Platform.environment;
  if (!names.any(environment.containsKey)) return null;
  final missing = names.where(
    (name) => environment[name] == null || environment[name]!.isEmpty,
  );
  if (missing.isNotEmpty) {
    throw FormatException(
      'Incomplete E2E environment; missing ${missing.join(', ')}',
    );
  }
  return <String, dynamic>{
    'restApi': environment['E2E_REST_API'],
    'appKey': environment['E2E_APP_KEY'],
    'clientId': environment['E2E_CLIENT_ID'],
    'clientSecret': environment['E2E_CLIENT_SECRET'],
    'tokenTtl': 86400,
    'accounts': [
      {'id': environment['E2E_USER_A_ID']},
      {'id': environment['E2E_USER_B_ID']},
    ],
    'chatOptions': {
      'dataSyncType': 7,
      'debugMode': true,
      'enableUserInfo': true,
    },
  };
}

Map<String, dynamic> _mirrorScript() => {
      '_comment':
          '$_ticket mirror account A: stay online and record callbacks.',
      'steps': <Object?>[],
    };

Map<String, dynamic> _updateScript(String threadId, String runId) => {
      '_comment':
          '$_ticket controller account A updates the REST-created thread.',
      'steps': [
        {
          'api': 'ChatThreadManager.updateChatThreadName',
          'id': 'update_thread',
          'params': {
            'chatThreadId': threadId,
            'newName': '$_ticket-updated-$runId',
          },
          'expect': {'success': true},
        },
        _logoutStep,
      ],
    };

Map<String, dynamic> _kickScript(String threadId, String memberId) => {
      '_comment': '$_ticket controller account A removes account B.',
      'steps': [
        {
          'api': 'ChatThreadManager.removeMemberFromChatThread',
          'id': 'kick_member',
          'params': {'chatThreadId': threadId, 'memberId': memberId},
          'expect': {'success': true},
        },
        _logoutStep,
      ],
    };

const Map<String, dynamic> _logoutStep = {
  'api': 'ChatClient.logout',
  'id': 'logout',
  'params': {'unbindDeviceToken': false},
  'expect': {'success': true},
};

void _requireSuccessfulPhase(String role, List<Map<String, dynamic>> events) {
  if (!_hasSuccessfulLogin(events)) {
    throw StateError('$role did not log in successfully');
  }
  final done = events.lastWhere(
    (event) => event['source'] == 'script.done',
    orElse: () => const <String, dynamic>{},
  );
  final payload = done['payload'];
  if (payload is! Map || payload['failed'] != 0 || payload['blocked'] != 0) {
    throw StateError('$role failed: ${jsonEncode(payload)}');
  }
}

bool _hasSuccessfulLogin(List<Map<String, dynamic>> events) => events.any(
      (event) =>
          event['source'] == 'api.ChatClient.login' &&
          event['payload'] is Map &&
          (event['payload'] as Map)['success'] == true,
    );

bool _hasScriptDone(List<Map<String, dynamic>> events) =>
    events.any((event) => event['source'] == 'script.done');

Future<List<Map<String, dynamic>>> _readEvents(File file) async {
  if (!await file.exists()) return <Map<String, dynamic>>[];
  final events = <Map<String, dynamic>>[];
  for (final line in const LineSplitter().convert(await file.readAsString())) {
    if (!line.startsWith(_apiPrefix)) continue;
    try {
      events.add(
        Map<String, dynamic>.from(
          jsonDecode(line.substring(_apiPrefix.length)) as Map,
        ),
      );
    } catch (_) {
      // Ignore an incomplete final line while LogStore is appending it.
    }
  }
  return events;
}

Future<_Devices> _selectDevices(String? requested) async {
  final result = await _checkedProcess('xcrun', [
    'simctl',
    'list',
    'devices',
    'available',
    '--json',
  ]);
  final decoded = jsonDecode(result.stdout as String) as Map;
  final rawGroups = decoded['devices'];
  if (rawGroups is! Map) {
    throw StateError('simctl returned no available device groups');
  }
  final groups = <List<_SimDevice>>[];
  for (final entry in rawGroups.entries) {
    final values = entry.value;
    if (values is! List) continue;
    final devices = <_SimDevice>[
      for (final raw in values)
        if (raw is Map &&
            raw['isAvailable'] != false &&
            raw['name'].toString().startsWith('iPhone'))
          _SimDevice(
            udid: raw['udid'] as String,
            name: raw['name'] as String,
            runtime: entry.key.toString(),
            wasBooted: raw['state'] == 'Booted',
          ),
    ];
    if (devices.isNotEmpty) groups.add(devices);
  }
  final all = groups.expand((group) => group).toList();

  List<_SimDevice> selected;
  if (requested != null) {
    final ids = requested.split(',').map((value) => value.trim()).toList();
    if (ids.length != 2 || ids.toSet().length != 2) {
      throw const FormatException('--devices requires two distinct UDIDs');
    }
    selected = [
      for (final id in ids)
        all.firstWhere(
          (device) => device.udid == id,
          orElse: () => throw FormatException('Simulator not found: $id'),
        ),
    ];
  } else {
    final candidates = groups.where((group) => group.length >= 2).toList()
      ..sort((left, right) {
        final booted = right
            .where((device) => device.wasBooted)
            .length
            .compareTo(left.where((device) => device.wasBooted).length);
        if (booted != 0) return booted;
        return right.first.runtime.compareTo(left.first.runtime);
      });
    if (candidates.isEmpty) {
      throw StateError('Two iPhone simulators from one runtime are required');
    }
    final ordered = candidates.first.toList()
      ..sort((left, right) {
        if (left.wasBooted == right.wasBooted) return 0;
        return left.wasBooted ? -1 : 1;
      });
    selected = ordered.take(2).toList();
  }

  return _Devices(mirror: selected[0], controller: selected[1]);
}

final class _Devices {
  const _Devices({required this.mirror, required this.controller});

  final _SimDevice mirror;
  final _SimDevice controller;

  List<_SimDevice> get all => [mirror, controller];
}

final class _SimDevice {
  const _SimDevice({
    required this.udid,
    required this.name,
    required this.runtime,
    required this.wasBooted,
  });

  final String udid;
  final String name;
  final String runtime;
  final bool wasBooted;
}

Future<ProcessResult> _checkedProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
  );
  if (result.exitCode != 0) {
    throw ProcessException(
      executable,
      arguments,
      '${result.stdout}\n${result.stderr}'.trim(),
      result.exitCode,
    );
  }
  return result;
}

Future<void> _streamProcess(
  String executable,
  List<String> arguments,
  String workingDirectory,
) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    throw ProcessException(executable, arguments, 'exit code $code', code);
  }
}

String _timestamp(DateTime value) =>
    value.toIso8601String().replaceAll(RegExp(r'[-:.TZ]'), '').substring(0, 14);

Future<void> _selfTest() async {
  final update = _updateScript('thread-id', 'self-test');
  final kick = _kickScript('thread-id', 'member-id');
  if (((update['steps'] as List).first as Map)['api'] !=
          'ChatThreadManager.updateChatThreadName' ||
      ((kick['steps'] as List).first as Map)['api'] !=
          'ChatThreadManager.removeMemberFromChatThread') {
    throw StateError('controller phase scripts are incomplete');
  }

  final temporary = await Directory.systemTemp.createTemp('him-23835-test-');
  try {
    final log = File('${temporary.path}/events.log');
    final events = <Map<String, dynamic>>[
      {
        'source': 'api.ChatClient.login',
        'payload': {'success': true},
      },
      {
        'source': 'script.done',
        'payload': {'total': 2, 'failed': 0, 'blocked': 0},
      },
    ];
    await log.writeAsString(
      events.map((event) => '$_apiPrefix${jsonEncode(event)}').join('\n'),
    );
    _requireSuccessfulPhase('self-test', await _readEvents(log));
  } finally {
    await temporary.delete(recursive: true);
  }
}
