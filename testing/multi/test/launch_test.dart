import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/build.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/devices.dart';
import 'package:testing_v2/src/launch.dart';

import 'device_fakes.dart';

void main() {
  late Directory directory;
  late DeviceResult device;
  late OperationResult<BuildResult> build;
  late FakeProcess process;
  late FakeHost host;
  late BuildService builder;
  late HostCommandResult resolution;
  late HostCommandResult activityStart;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('testing-v2-launch-');
    final artifact = File(p.join(
        directory.path, 'build', 'run-1', 'build-1', 'android', 'app.apk'));
    await artifact.parent.create(recursive: true);
    await artifact.writeAsString('apk-content');
    build = OperationResult(
        runId: 'run-1',
        operationId: 'build-1',
        status: OperationStatus.success,
        data: BuildResult(
            platform: DevicePlatform.android,
            architectures: ['arm64-v8a'],
            applicationId: 'com.example.example',
            mode: 'debug',
            arguments: buildArguments(DevicePlatform.android),
            artifact: await fileRef(artifact.path)),
        errors: [],
        evidence: []);
    device = DeviceResult(
        platform: DevicePlatform.android,
        instance: 'Pixel_A',
        deviceId: 'emulator-5554',
        observedState: 'device',
        checkedAt: DateTime.now(),
        ready: true);
    process = FakeProcess();
    resolution = ok('priority=0 preferredOrder=0 match=0x108000 '
        'specificIndex=-1 isDefault=false\ncom.example.example/.MainActivity\n');
    activityStart = ok('Status: ok');
    host = FakeHost((exe, args) {
      if (p.basename(exe) == 'aapt')
        return ok(
            "package: name='com.example.example'\napplication-debuggable\nnative-code: 'arm64-v8a'\n");
      if (exe == 'emulator') return ok('Pixel_A\n');
      if (exe == 'flutter') return ok('[{"id":"emulator-5554"}]');
      if (args.join(' ') == 'devices')
        return ok('List of devices attached\nemulator-5554 device\n');
      if (args.contains('name')) return ok('Pixel_A\nOK\n');
      if (args.contains('get-state')) return ok('device');
      if (args.contains('sys.boot_completed')) return ok('1');
      if (args.contains('ro.product.cpu.abilist')) return ok('arm64-v8a');
      if (args.contains('path'))
        return ok('package:/data/app/example/base.apk');
      if (args.contains('resolve-activity')) {
        expect(args, [
          '-s',
          'emulator-5554',
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
          'com.example.example'
        ]);
        return resolution;
      }
      if (args.contains('log')) {
        process.out.add(utf8.encode(
            '${DateTime.now().microsecondsSinceEpoch / 1000000} 111 111 I testing_v2: ${args.last}\n'));
        return ok();
      }
      if (args.contains('start')) {
        expect(args, [
          '-s',
          'emulator-5554',
          'shell',
          'am',
          'start',
          '-W',
          '-n',
          const LineSplitter().convert(resolution.stdout.trim()).last,
          '-a',
          'android.intent.action.MAIN',
          '-c',
          'android.intent.category.LAUNCHER'
        ]);
        process.out.add(utf8.encode(
            '${DateTime.now().microsecondsSinceEpoch / 1000000} 999 999 I flutter: [AGENT_CONTROL] {"port":45678,"token":"pairing-secret","instanceId":"log-only-id"}\n'));
        return activityStart;
      }
      if (args.contains('pidof')) return ok('999');
      if (args.contains('forward')) return ok('45679');
      if (args.contains('install') || args.contains('force-stop')) return ok();
      throw StateError('Unexpected $exe $args');
    }, onStart: (_, __) => process);
    builder = BuildService(
        repository: directory,
        buildRoot: Directory(p.join(directory.path, 'build')),
        runner: host);
  });
  tearDown(() async {
    if (!process.killed) process.kill();
    await directory.delete(recursive: true);
  });

  LaunchService launcher(
          {String instance = 'http-instance', String state = 'accepting'}) =>
      LaunchService(
          devices: DeviceService(runner: host),
          builds: builder,
          runner: host,
          handshake: (_, __, ___) async => {
                'version': 2,
                'platform': 'android',
                'instanceId': instance,
                'state': state
              },
          timeout: const Duration(seconds: 3));

  test('actual device/build outputs become a complete authenticated launch',
      () async {
    final ctx = context(directory, 'launch');
    final result = await launcher().launch(ctx,
        caseName: 'presence',
        roles: {'alice': device},
        builds: {'alice': build});
    expect(result.isSuccess, isTrue, reason: jsonEncode(result.toJson()));
    expect(result.data!.roles['alice']!.instanceId, 'http-instance');
    expect(result.data!.roles['alice']!.token, 'pairing-secret');
    expect(result.data!.roles['alice']!.forward!.hostPort, 45679);
    expect(process.killed, isTrue);
    for (final evidence in result.evidence) {
      expect(await File(evidence.path).readAsString(),
          isNot(contains('pairing-secret')));
    }
    final checked = await launcher().recheck(context(directory, 'check'),
        connection: result.data!.roles['alice']!, device: device, build: build);
    expect(checked.isSuccess, isTrue);
  });

  test('rejected handshake keeps launch unusable and closes collectors',
      () async {
    final result = await launcher(state: 'uncertain').launch(
        context(directory, 'launch'),
        caseName: 'presence',
        roles: {'alice': device},
        builds: {'alice': build});
    expect(result.isSuccess, isFalse);
    expect(result.data!.roles, isEmpty);
    expect(process.killed, isTrue);
    expect(host.calls.any((call) => call.contains('--remove')), isTrue);
  });

  test('resolved launcher can have a different activity class or alias',
      () async {
    resolution = ok('com.example.example/com.example.launch.EntryAlias\n');
    final result = await launcher().launch(context(directory, 'launch'),
        caseName: 'presence',
        roles: {'alice': device},
        builds: {'alice': build});
    expect(result.isSuccess, isTrue, reason: jsonEncode(result.toJson()));
    expect(host.calls.singleWhere((call) => call.contains('start')),
        contains('com.example.example/com.example.launch.EntryAlias'));
  });

  for (final entry in {
    'missing': 'No activity found\n',
    'foreign package': 'android/com.android.internal.app.ResolverActivity\n',
    'malformed': 'com.example.example/.Bad Activity\n',
    'ambiguous': 'com.example.example/.First\ncom.example.example/.Second\n',
  }.entries) {
    test('${entry.key} launcher is rejected before activity startup', () async {
      resolution = ok(entry.value);
      final result = await launcher().launch(context(directory, 'launch'),
          caseName: 'presence',
          roles: {'alice': device},
          builds: {'alice': build});
      expect(result.isSuccess, isFalse);
      expect(result.data!.roles, isEmpty);
      expect(result.errors.single.message, contains(entry.value.trim()));
      expect(host.calls.any((call) => call.contains('start')), isFalse);
      expect(host.calls.any((call) => call.contains('pidof')), isFalse);
    });
  }

  test('failed activity resolution preserves stdout and prevents startup',
      () async {
    resolution = HostCommandResult(
        exitCode: 1, stdout: 'Resolution failed', stderr: '', timedOut: false);
    final result = await launcher().launch(context(directory, 'launch'),
        caseName: 'presence',
        roles: {'alice': device},
        builds: {'alice': build});
    expect(result.isSuccess, isFalse);
    expect(result.errors.single.message, contains('Resolution failed'));
    expect(host.calls.any((call) => call.contains('start')), isFalse);
  });

  test(
      'failed activity start preserves stdout instead of returning a connection',
      () async {
    activityStart = HostCommandResult(
        exitCode: 1,
        stdout: 'Error: Activity not started',
        stderr: '',
        timedOut: false);
    final result = await launcher().launch(context(directory, 'launch'),
        caseName: 'presence',
        roles: {'alice': device},
        builds: {'alice': build});
    expect(result.isSuccess, isFalse);
    expect(result.data!.roles, isEmpty);
    expect(
        result.errors.single.message, contains('Error: Activity not started'));
    expect(host.calls.any((call) => call.contains('pidof')), isFalse);
    expect(process.killed, isTrue);
  });

  test('all role artifacts accepted before any install side effect', () async {
    final bad = OperationResult<BuildResult>(
        runId: 'different-run',
        operationId: 'build-other',
        status: OperationStatus.success,
        data: build.data,
        errors: [],
        evidence: []);
    final second = DeviceResult(
        platform: DevicePlatform.android,
        instance: 'Pixel_B',
        deviceId: 'emulator-5556',
        observedState: 'device',
        checkedAt: DateTime.now(),
        ready: true);
    final result = await launcher().launch(context(directory),
        caseName: 'presence',
        roles: {'alice': device, 'bob': second},
        builds: {'alice': build, 'bob': bad});
    expect(result.isSuccess, isFalse);
    expect(host.calls.any((call) => call.contains('install')), isFalse);
    expect(host.calls.any((call) => call.contains('force-stop')), isFalse);
  });

  test('used connection rejected before state inspection or HTTP request',
      () async {
    final result = await launcher().launch(context(directory, 'launch'),
        caseName: 'presence',
        roles: {'alice': device},
        builds: {'alice': build});
    final connection = Connection.fromJson({
      ...result.data!.roles['alice']!.toJson(),
      'usedBy': {'caseName': 'presence', 'attempt': 1}
    });
    host.calls.clear();
    final checked = await launcher().recheck(context(directory, 'check'),
        connection: connection, device: device, build: build);
    expect(checked.isSuccess, isFalse);
    expect(host.calls, isEmpty);
  });

  test('changed handshake identity rejects previous connection', () async {
    final result = await launcher().launch(context(directory, 'launch'),
        caseName: 'presence',
        roles: {'alice': device},
        builds: {'alice': build});
    final checked = await launcher(instance: 'new-instance').recheck(
        context(directory, 'check'),
        connection: result.data!.roles['alice']!,
        device: device,
        build: build);
    expect(checked.isSuccess, isFalse);
    expect(checked.errors.single.message, contains('instance changed'));
  });

  test('pairing parser requires timestamp and exact process identity', () {
    final android = parsePairingLine(
        '1793970000.123 42 43 I flutter: [AGENT_CONTROL] {"port":1234,"token":"abc"}',
        DevicePlatform.android);
    expect(android!.processId, 42);
    expect(
        parsePairingLine('[AGENT_CONTROL] {"port":1234,"token":"abc"}',
            DevicePlatform.android),
        isNull);
    final ios = parsePairingLine(
        '2026-11-06 12:00:00.123 Df Runner[44:55] [AGENT_CONTROL] {"port":1234,"token":"abc"}',
        DevicePlatform.ios);
    expect(ios!.processId, 44);
    expect(
        parsePairingLine(
            '2026-11-06 12:00:00.123 Df Other[44:55] [AGENT_CONTROL] {"port":1234,"token":"abc"}',
            DevicePlatform.ios),
        isNull);
  });

  test('local HTTP handshake enforces status and authenticated request',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final listener = server.listen((request) {
      expect(request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer test-token');
      request.response.headers.contentType = ContentType.json;
      request.response.write(
          '{"version":2,"platform":"ios","instanceId":"i","state":"accepting"}');
      request.response.close();
    });
    try {
      final info = await requestInfo('http://127.0.0.1:${server.port}',
          'test-token', const Duration(seconds: 1));
      expect(() => validateInfo(info, DevicePlatform.ios), returnsNormally);
    } finally {
      await listener.cancel();
      await server.close(force: true);
    }
  });

  test(
      'log interval rejects historical credentials and accepts device clock offset',
      () async {
    final collector = FakeProcess();
    final deviceEpoch = DateTime.now()
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch /
        1000;
    final runner = FakeHost((_, args) {
      collector.out
          .add(utf8.encode('$deviceEpoch 1 1 I testing_v2: ${args.last}\n'));
      return ok();
    }, onStart: (_, __) => collector);
    final capture = await DeviceLogCapture.open(
        context: context(directory, 'offset'),
        runner: runner,
        role: 'alice',
        device: device,
        applicationId: 'example.app',
        processId: null,
        timeout: const Duration(seconds: 1));
    try {
      await capture.ready;
      collector.out.add(utf8.encode(
          '${deviceEpoch - 60} 42 42 I flutter: [AGENT_CONTROL] {"port":1234,"token":"old-secret"}\n'));
      collector.out.add(utf8.encode(
          '${deviceEpoch + 1} 99 99 I flutter: [AGENT_CONTROL] {"port":1234,"token":"wrong-process"}\n'));
      collector.out.add(utf8.encode(
          '${deviceEpoch + 2} 42 42 I flutter: [AGENT_CONTROL] {"port":1234,"token":"current-secret"}\n'));
      final pairing = await capture
          .credentialsAfter(DateTime.now(), 42)
          .timeout(const Duration(seconds: 1));
      expect(pairing.token, 'current-secret');
    } finally {
      await capture.close();
    }
    expect(await File(capture.path).readAsString(),
        isNot(contains('current-secret')));
    expect(collector.killed, isTrue);
  });

  test('log readiness timeout is bounded and caller can reclaim collector',
      () async {
    final collector = FakeProcess();
    final runner = FakeHost((_, __) => ok(), onStart: (_, __) => collector);
    final iosDevice = DeviceResult(
        platform: DevicePlatform.ios,
        instance: 'udid',
        deviceId: 'udid',
        observedState: 'Booted',
        checkedAt: DateTime.now(),
        ready: true);
    final capture = await DeviceLogCapture.open(
        context: context(directory, 'timeout'),
        runner: runner,
        role: 'alice',
        device: iosDevice,
        applicationId: 'example.app',
        processId: null,
        timeout: const Duration(milliseconds: 20));
    await expectLater(capture.ready, throwsA(isA<TimeoutException>()));
    await capture.close();
    expect(collector.killed, isTrue);
  });
}
