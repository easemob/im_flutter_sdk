import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'build.dart';
import 'contracts.dart';
import 'core.dart';
import 'devices.dart';

typedef InfoHandshake = Future<Map<String, Object?>> Function(
    String endpoint, String token, Duration timeout);

class LaunchService {
  LaunchService(
      {required this.devices,
      required this.builds,
      HostCommandRunner? runner,
      InfoHandshake? handshake,
      this.timeout = const Duration(minutes: 2)})
      : runner = runner ?? IoHostCommandRunner(),
        handshake = handshake ?? requestInfo;

  final DeviceService devices;
  final BuildService builds;
  final HostCommandRunner runner;
  final InfoHandshake handshake;
  final Duration timeout;

  Future<OperationResult<LaunchResult>> launch(OperationContext context,
      {required String caseName,
      required Map<String, DeviceResult> roles,
      required Map<String, OperationResult<BuildResult>> builds,
      Map<String, String> previousInstanceIds = const {}}) async {
    final connections = <String, Connection>{};
    final evidence = <EvidenceRef>[];
    final errors = <OperationError>[];
    if (roles.isEmpty ||
        roles.keys.toSet().difference(builds.keys.toSet()).isNotEmpty ||
        builds.keys.toSet().difference(roles.keys.toSet()).isNotEmpty ||
        roles.values
                .map((d) => '${d.platform.name}:${d.instance}')
                .toSet()
                .length !=
            roles.length) {
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.failure,
          data: null,
          errors: [
            OperationError(
                message:
                    'Launch requires complete role builds and distinct devices',
                field: 'roles',
                expected: roles.keys.toList(),
                actual: builds.keys.toList())
          ],
          evidence: []);
    }
    // Accept every role before making any installation side effect.
    for (final entry in roles.entries) {
      final result = builds[entry.key]!;
      if (result.runId != context.runId ||
          result.status != OperationStatus.success ||
          result.data == null) {
        errors.add(OperationError(
            message: 'Build handoff is not successful in this run',
            field: 'builds.${entry.key}',
            expected: context.runId,
            actual: result.runId));
        continue;
      }
      final checked = await this.builds.validate(
          _context(context, '${entry.key}-artifact'), result.data!,
          device: entry.value);
      evidence.addAll(checked.evidence);
      errors.addAll(checked.errors);
      final device = await devices.inspect(
          _context(context, '${entry.key}-ready'),
          entry.value.platform,
          entry.value.instance,
          requireReady: true);
      evidence.addAll(device.evidence);
      if (device.status != OperationStatus.success ||
          device.data?.deviceId != entry.value.deviceId ||
          !entry.value.ready) {
        errors.add(OperationError(
            message: 'Device handoff no longer matches',
            field: 'roles.${entry.key}.deviceId',
            expected: entry.value.deviceId,
            actual: device.data?.deviceId));
      }
    }
    if (errors.isEmpty) {
      for (final entry in roles.entries) {
        try {
          final connection = await _launchRole(
              _context(context, entry.key),
              entry.key,
              entry.value,
              builds[entry.key]!,
              previousInstanceIds[entry.value.deviceId],
              evidence);
          connections[entry.key] = connection;
        } catch (error) {
          errors.add(OperationError(
              message: context.redactor.text('$error'),
              field: 'roles.${entry.key}',
              expected: 'new authenticated accepting instance',
              actual: null));
          break;
        }
      }
    }
    return OperationResult(
        runId: context.runId,
        operationId: context.operationId,
        status:
            errors.isEmpty ? OperationStatus.success : OperationStatus.failure,
        data: LaunchResult(caseName: caseName, roles: connections),
        errors: errors,
        evidence: evidence);
  }

  Future<OperationResult<Connection>> recheck(OperationContext context,
      {required Connection connection,
      required DeviceResult device,
      required OperationResult<BuildResult> build}) async {
    final evidence = <EvidenceRef>[];
    final scoped = _context(context,
        connection.deviceId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_'));
    try {
      Connection.fromJson(connection.toJson());
      if (connection.usedBy != null ||
          connection.invalidatedAt != null ||
          connection.invalidatedReason != null ||
          build.runId != context.runId ||
          build.status != OperationStatus.success ||
          build.data == null ||
          build.operationId != connection.buildOperationId ||
          device.deviceId != connection.deviceId ||
          device.platform != connection.platform ||
          build.data!.applicationId != connection.applicationId ||
          build.data!.artifact.path != connection.artifact.path ||
          build.data!.artifact.sha256 != connection.artifact.sha256) {
        throw StateError(
            'Connection ownership, occupancy, or installed artifact is invalid');
      }
      final checkedDevice = await devices.inspect(
          _context(scoped, 'device'), device.platform, device.instance,
          requireReady: true);
      evidence.addAll(checkedDevice.evidence);
      if (checkedDevice.status != OperationStatus.success ||
          checkedDevice.data?.deviceId != connection.deviceId)
        throw StateError('Device state changed');
      final checkedBuild = await builds.validate(
          _context(scoped, 'artifact'), build.data!,
          device: checkedDevice.data!);
      evidence.addAll(checkedBuild.evidence);
      if (checkedBuild.status != OperationStatus.success)
        throw StateError('Installed artifact reference is invalid');
      final info =
          await handshake(connection.endpoint, connection.token, timeout);
      final handshakeLog =
          CommandLog(_context(scoped, 'handshake'), runner, timeout);
      await handshakeLog.note('handshake', info);
      evidence.addAll(await handshakeLog.evidence());
      validateInfo(info, connection.platform);
      if (info['instanceId'] != connection.instanceId)
        throw StateError('App instance changed; relaunch required');
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.success,
          data: connection,
          errors: [],
          evidence: evidence);
    } catch (error) {
      return OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.failure,
          data: null,
          errors: [
            OperationError(
                message: context.redactor.text('$error'),
                field: 'connection',
                expected: 'unused matching accepting connection',
                actual: null)
          ],
          evidence: evidence);
    }
  }

  Future<DeviceLogCapture> startCapture(OperationContext context,
      {required String role,
      required DeviceResult device,
      required String applicationId,
      int? processId}) async {
    if (!device.ready || device.deviceId == null)
      throw StateError('Log capture requires a ready device');
    return DeviceLogCapture.open(
        context: context,
        runner: runner,
        role: role,
        device: device,
        applicationId: applicationId,
        processId: processId,
        timeout: timeout);
  }

  Future<Connection> _launchRole(
      OperationContext context,
      String role,
      DeviceResult device,
      OperationResult<BuildResult> build,
      String? previousInstanceId,
      List<EvidenceRef> evidence) async {
    final deadline = DateTime.now().add(timeout);
    Duration remaining() {
      final value = deadline.difference(DateTime.now());
      if (value <= Duration.zero)
        throw TimeoutException(
            'App launch exceeded ${timeout.inMilliseconds}ms');
      return value;
    }

    final installed = await devices.install(
        _context(context, 'install'), device, build.data!);
    evidence.addAll(installed.evidence);
    if (installed.status != OperationStatus.success)
      throw StateError('Application installation failed');
    final log = CommandLog(context, runner, remaining());
    final app = build.data!.applicationId;
    DeviceLogCapture? capture;
    ForwardMapping? forward;
    var delivered = false;
    try {
      String? androidActivity;
      if (device.platform == DevicePlatform.android) {
        await log.run(
            'adb', ['-s', device.deviceId!, 'shell', 'am', 'force-stop', app],
            limit: remaining());
        final resolved = await log.run(
            'adb',
            [
              '-s',
              device.deviceId!,
              'shell',
              'cmd',
              'package',
              'resolve-activity',
              '--brief',
              '-a',
              'android.intent.action.MAIN',
              '-c',
              'android.intent.category.LAUNCHER',
              '-p',
              app
            ],
            allowFailure: true,
            limit: remaining());
        final lines = const LineSplitter()
            .convert(resolved.stdout)
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
        final component = lines.isEmpty ? '' : lines.last;
        final parts = component.split('/');
        if (resolved.exitCode != 0 ||
            resolved.timedOut ||
            lines.isEmpty ||
            lines.length > 2 ||
            (lines.length == 2 && !lines.first.startsWith('priority=')) ||
            parts.length != 2 ||
            parts.first != app ||
            !RegExp(r'^\.?[A-Za-z_$][A-Za-z0-9_$]*(\.[A-Za-z_$][A-Za-z0-9_$]*)*$')
                .hasMatch(parts.last)) {
          throw StateError('Cannot resolve launcher activity for $app: '
              'exit=${resolved.exitCode}, timeout=${resolved.timedOut}, '
              '${resolved.stdout} ${resolved.stderr}');
        }
        androidActivity = component;
      } else {
        final stopped = await log.run(
            'xcrun', ['simctl', 'terminate', device.deviceId!, app],
            allowFailure: true, limit: remaining());
        if (stopped.exitCode != 0 &&
            !RegExp(r'not running|found nothing to terminate|No such process',
                    caseSensitive: false)
                .hasMatch(stopped.stderr))
          throw StateError(
              'Cannot confirm previous App termination: ${stopped.stderr}');
      }
      capture = await startCapture(context,
          role: role, device: device, applicationId: app);
      await capture.ready.timeout(remaining());
      final startedAt = DateTime.now();
      int? processId;
      if (device.platform == DevicePlatform.android) {
        final launched = await log.run(
            'adb',
            [
              '-s',
              device.deviceId!,
              'shell',
              'am',
              'start',
              '-W',
              '-n',
              androidActivity!,
              '-a',
              'android.intent.action.MAIN',
              '-c',
              'android.intent.category.LAUNCHER',
            ],
            allowFailure: true,
            limit: remaining());
        if (launched.exitCode != 0 ||
            launched.timedOut ||
            RegExp(r'Error:|Exception')
                .hasMatch('${launched.stdout}\n${launched.stderr}'))
          throw StateError('Android activity launch failed: '
              'exit=${launched.exitCode}, timeout=${launched.timedOut}, '
              '${launched.stdout} ${launched.stderr}');
        final pid = await log.run(
            'adb', ['-s', device.deviceId!, 'shell', 'pidof', app],
            limit: remaining());
        processId = int.tryParse(pid.stdout.trim());
      } else {
        final launched = await log.run(
            'xcrun', ['simctl', 'launch', device.deviceId!, app],
            limit: remaining());
        processId = int.tryParse(
            RegExp(r':\s*(\d+)\s*$').firstMatch(launched.stdout)?.group(1) ??
                '');
      }
      if (processId == null)
        throw StateError(
            'Cannot prove the identity of the newly started App process');
      final credential = await capture
          .credentialsAfter(startedAt, processId)
          .timeout(remaining());
      context.redactor.add(credential.token);
      var port = credential.port;
      if (device.platform == DevicePlatform.android) {
        final mapping = await log.run(
            'adb', ['-s', device.deviceId!, 'forward', 'tcp:0', 'tcp:$port'],
            limit: remaining());
        final hostPort = int.tryParse(mapping.stdout.trim());
        if (hostPort == null || hostPort < 1 || hostPort > 65535)
          throw const FormatException('Invalid adb forwarded port');
        forward = ForwardMapping(
            serial: device.deviceId!, hostPort: hostPort, devicePort: port);
        port = hostPort;
      }
      final endpoint = 'http://127.0.0.1:$port';
      final info = await handshake(endpoint, credential.token, remaining());
      validateInfo(info, device.platform);
      if (info['instanceId'] == previousInstanceId)
        throw StateError('Previous App instance was reused');
      await log.note('handshake', {
        'endpoint': endpoint,
        'platform': info['platform'],
        'version': info['version'],
        'state': info['state'],
        'instanceId': info['instanceId'],
        'processId': processId,
        'startedAt': startedAt.toUtc().toIso8601String()
      });
      await capture.close();
      delivered = true;
      return Connection(
          deviceId: device.deviceId!,
          applicationId: app,
          platform: device.platform,
          buildOperationId: build.operationId,
          artifact: build.data!.artifact,
          endpoint: endpoint,
          token: credential.token,
          instanceId: info['instanceId'] as String,
          version: info['version'] as int,
          state: info['state'] as String,
          checkedAt: DateTime.now(),
          startedAt: startedAt,
          processId: processId,
          forward: forward,
          usedBy: null,
          invalidatedAt: null,
          invalidatedReason: null);
    } finally {
      if (capture != null) {
        try {
          await capture.close();
        } finally {
          evidence.addAll(capture.evidence);
        }
      }
      evidence.addAll(await log.evidence());
      if (!delivered && forward != null) {
        await CommandLog(_context(context, 'forward-cleanup'), runner,
                const Duration(seconds: 5))
            .run(
                'adb',
                [
                  '-s',
                  device.deviceId!,
                  'forward',
                  '--remove',
                  'tcp:${forward.hostPort}'
                ],
                allowFailure: true,
                limit: const Duration(seconds: 5));
      }
    }
  }

  OperationContext _context(OperationContext source, String suffix) =>
      OperationContext(
          runId: source.runId,
          operationId: '${source.operationId}-$suffix',
          tmpDirectory: source.tmpDirectory,
          redactor: source.redactor);
}

void validateInfo(Map<String, Object?> info, DevicePlatform platform) {
  if (info['version'] != 2 ||
      info['platform'] != platform.name ||
      info['instanceId'] is! String ||
      (info['instanceId'] as String).trim().isEmpty ||
      info['state'] != 'accepting')
    throw StateError('Control handshake is incompatible or not accepting');
}

Future<Map<String, Object?>> requestInfo(
    String endpoint, String token, Duration timeout) async {
  final uri = Uri.parse(endpoint);
  if (uri.scheme != 'http' ||
      !['127.0.0.1', 'localhost', '::1'].contains(uri.host) ||
      !uri.hasPort ||
      uri.port < 1 ||
      uri.port > 65535)
    throw ArgumentError('Control endpoint must be local HTTP');
  final client = HttpClient()..findProxy = (_) => 'DIRECT';
  try {
    return await (() async {
      final request = await client.getUrl(uri.resolve('/v1/info'));
      request.followRedirects = false;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close();
      if (response.statusCode != 200)
        throw HttpException('Control handshake HTTP ${response.statusCode}');
      final body = await utf8.decoder.bind(response).join();
      final value = jsonDecode(body);
      if (value is! Map<String, dynamic>)
        throw const FormatException('Control handshake must be an object');
      return Map<String, Object?>.from(value);
    })()
        .timeout(timeout);
  } finally {
    client.close(force: true);
  }
}

class PairingCredential {
  PairingCredential(this.port, this.token, this.time, this.processId);
  final int port;
  final String token;
  final DateTime time;
  final int processId;
}

class DeviceLogCapture {
  DeviceLogCapture._(this.context, this.process, this.platform, this.path,
      this.marker, this.timeout, this.processId);
  final OperationContext context;
  final HostProcess process;
  final DevicePlatform platform;
  final String path;
  final String marker;
  final Duration timeout;
  final int? processId;
  final Completer<void> _ready = Completer<void>();
  final List<PairingCredential> _credentials = [];
  final List<StreamSubscription<String>> _subscriptions = [];
  Future<void> _writes = Future<void>.value();
  Completer<void>? _changed;
  Object? _failure;
  DateTime? _deviceReadyTime;
  bool _closed = false;
  Future<void> get ready => _ready.future.timeout(timeout);
  List<EvidenceRef> get evidence => File(path).existsSync()
      ? [EvidenceRef(path: p.absolute(path), location: null)]
      : [];

  static Future<DeviceLogCapture> open(
      {required OperationContext context,
      required HostCommandRunner runner,
      required String role,
      required DeviceResult device,
      required String applicationId,
      required int? processId,
      required Duration timeout}) async {
    final marker =
        'testing_v2_${context.operationId}_${DateTime.now().microsecondsSinceEpoch}';
    final HostProcess process;
    if (device.platform == DevicePlatform.android) {
      process = await runner.start('adb', [
        '-s',
        device.deviceId!,
        'logcat',
        '-v',
        'epoch',
        '-T',
        '1',
        'flutter:I',
        'testing_v2:I',
        '*:S'
      ]);
    } else {
      process = await runner.start('xcrun', [
        'simctl',
        'spawn',
        device.deviceId!,
        'log',
        'stream',
        '--style',
        'compact',
        '--level',
        'debug',
        '--predicate',
        'process == "Runner"'
      ]);
    }
    final capture = DeviceLogCapture._(
        context,
        process,
        device.platform,
        p.join(context.tmpDirectory.path,
            '${context.operationId}-$role-device.log'),
        marker,
        timeout,
        processId);
    try {
      await writePrivateFile(capture.path, '');
    } catch (_) {
      await process.close();
      rethrow;
    }
    // Attach handlers before triggering readiness or launching the application.
    capture._subscriptions.add(process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(capture._line, onError: capture._fail));
    capture._subscriptions.add(process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(capture._line, onError: capture._fail));
    unawaited(process.exitCode.then((code) {
      if (!capture._closed)
        capture._fail(StateError('Log collector exited: $code'));
    }, onError: capture._fail));
    if (device.platform == DevicePlatform.android) {
      try {
        final result = await runner.run(
            'adb',
            [
              '-s',
              device.deviceId!,
              'shell',
              'log',
              '-t',
              'testing_v2',
              marker
            ],
            timeout: timeout);
        if (result.timedOut || result.exitCode != 0)
          throw StateError('Cannot establish logcat readiness');
      } catch (error) {
        capture._fail(error);
      }
    }
    // Consume early failures until the caller begins awaiting readiness.
    unawaited(capture.ready.catchError((Object _) {}));
    return capture;
  }

  void _fail(Object error) {
    _failure ??= error;
    if (!_ready.isCompleted) _ready.completeError(error);
    if (_changed != null && !_changed!.isCompleted) _changed!.complete();
  }

  void _line(String line) {
    if (_closed) return;
    if (!_ready.isCompleted) {
      if (platform == DevicePlatform.android && line.contains(marker)) {
        final stamp = RegExp(r'^\s*(\d+\.\d+)\s+').firstMatch(line)?.group(1);
        if (stamp != null) {
          _deviceReadyTime = DateTime.fromMicrosecondsSinceEpoch(
              (double.parse(stamp) * 1000000).round());
          _ready.complete();
        }
      } else if (platform == DevicePlatform.ios &&
          line.contains('Filtering the log data using')) {
        _ready.complete();
      }
    }
    if (processId != null &&
        !line.contains(marker) &&
        !line.contains('Filtering the log data using')) {
      final pidText = platform == DevicePlatform.android
          ? RegExp(r'^\s*\d+\.\d+\s+(\d+)\s+\d+\s+').firstMatch(line)?.group(1)
          : RegExp(r'Runner\[(\d+):').firstMatch(line)?.group(1);
      if (int.tryParse(pidText ?? '') != processId) return;
    }
    if (line.contains('[AGENT_CONTROL]')) {
      final parsed = parsePairingLine(line, platform);
      if (parsed != null) {
        context.redactor.add(parsed.token);
        _credentials.add(parsed);
        if (_changed != null && !_changed!.isCompleted) _changed!.complete();
      }
      line =
          '${line.substring(0, line.indexOf('[AGENT_CONTROL]'))}[AGENT_CONTROL] <redacted pairing record>';
    }
    final sanitized = context.redactor.text(line);
    _writes = _writes.then((_) async {
      await File(path)
          .writeAsString('$sanitized\n', mode: FileMode.append, flush: true);
    }).catchError((Object error) {
      _fail(error);
    });
  }

  Future<PairingCredential> credentialsAfter(DateTime time, int pid) async {
    final boundary =
        platform == DevicePlatform.android ? _deviceReadyTime : time;
    if (boundary == null)
      throw StateError('Device log interval has not been established');
    while (!_closed) {
      if (_failure != null) throw StateError('Log capture failed: $_failure');
      final candidates = _credentials
          .where((entry) =>
              entry.processId == pid &&
              !entry.time
                  .isBefore(boundary.subtract(const Duration(milliseconds: 2))))
          .toList();
      if (candidates.length > 1)
        throw StateError('Multiple pairing records from the new App');
      if (candidates.length == 1) return candidates.single;
      _changed = Completer<void>();
      await _changed!.future;
    }
    throw StateError('Log collector closed before pairing');
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    if (_changed != null && !_changed!.isCompleted) _changed!.complete();
    try {
      await process.close(timeout: const Duration(seconds: 2));
    } finally {
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      await _writes;
    }
    if (_failure != null) throw StateError('Log capture failed: $_failure');
  }
}

PairingCredential? parsePairingLine(String line, DevicePlatform platform) {
  try {
    final marker = line.indexOf('[AGENT_CONTROL]');
    if (marker < 0) return null;
    final value =
        jsonDecode(line.substring(marker + '[AGENT_CONTROL]'.length).trim());
    if (value is! Map ||
        value['port'] is! int ||
        value['token'] is! String ||
        (value['port'] as int) < 1 ||
        (value['port'] as int) > 65535 ||
        (value['token'] as String).isEmpty) return null;
    DateTime time;
    int pid;
    if (platform == DevicePlatform.android) {
      final match = RegExp(r'^\s*(\d+\.\d+)\s+(\d+)\s+\d+\s+').firstMatch(line);
      if (match == null) return null;
      time = DateTime.fromMicrosecondsSinceEpoch(
          (double.parse(match.group(1)!) * 1000000).round());
      pid = int.parse(match.group(2)!);
    } else {
      final match = RegExp(
              r'^(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d(?:\.\d+)?)\s+.*?Runner\[(\d+):')
          .firstMatch(line);
      if (match == null) return null;
      time = DateTime.parse(match.group(1)!);
      pid = int.parse(match.group(2)!);
    }
    return PairingCredential(
        value['port'] as int, value['token'] as String, time, pid);
  } on FormatException {
    return null;
  }
}
