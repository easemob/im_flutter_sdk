import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/build.dart';
import 'package:testing_v2/src/cli.dart';
import 'package:testing_v2/src/devices.dart';
import 'package:testing_v2/src/launch.dart';
import 'package:testing_v2/src/state.dart';

import 'device_fakes.dart';

void main() {
  test(
      'all composes actual module deliveries across two HTTP agents and reports the attempt',
      () async {
    final repository =
        await Directory.systemTemp.createTemp('testing-v2-integration-');
    final root = Directory(p.join(repository.path, 'testing', 'multi'));
    await Directory(p.join(root.path, 'lib')).create(recursive: true);
    await File(p.join(root.path, 'lib', 'accounts.g.dart')).writeAsString('''
const Map<String, Object?> environment = {
  'appKey': 'org#app',
  'accounts': [{'id': 'a', 'token': 'account-a-secret'}, {'id': 'b', 'token': 'account-b-secret'}, {'id': 'c', 'token': 'account-c-secret'}],
  'groups': <Object?>[], 'rooms': <Object?>[]
};
''');
    final source = Directory(p.join(root.path, 'data'));
    await source.create();
    final basename = '5.0.0-multi-handshake-positive';
    final yaml = File(p.join(source.path, '$basename.yaml'));
    await yaml.writeAsString(jsonEncode({
      'name': 'two-agent-contract',
      'flowTimeoutMs': 5000,
      'agents': {
        'alice': {'script': '$basename.json'},
        'bob': {'script': '$basename.json'}
      },
      'steps': [
        {'cmd': 'echo', 'agent': 'alice', 'as': 'global.biz.result.alice'},
        {'cmd': 'echo', 'agent': 'bob', 'as': 'global.biz.result.bob'},
      ],
    }));
    await File(p.join(source.path, '$basename.json')).writeAsString(jsonEncode({
      'requiredBindings': ['global.biz.result.alice', 'global.biz.result.bob'],
      'steps': [
        {
          'id': 'echo',
          'api': 'Test.echo',
          'params': {'value': 'ok'},
          'expect': {'success': true}
        }
      ],
    }));
    final selection = File(p.join(root.path, 'selection.json'));
    await selection.writeAsString(jsonEncode({
      'cases': [
        {
          'yaml': yaml.path,
          'accounts': {'account1': 'a', 'account2': 'b', 'account3': 'c'},
          'devices': {
            'alice': {'platform': 'android', 'instance': 'Pixel_A'},
            'bob': {'platform': 'android', 'instance': 'Pixel_B'},
          },
        }
      ]
    }));
    final servers = <String, HttpServer>{};
    final processes = <String, FakeProcess>{};
    final launched = <String, int>{};
    final commands = <String, List<String>>{};
    final finished = <String, bool>{};
    for (final serial in ['emulator-5554', 'emulator-5556']) {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      servers[serial] = server;
      commands[serial] = [];
      server.listen((request) async {
        request.response.headers.contentType = ContentType.json;
        if (request.headers.value(HttpHeaders.authorizationHeader) !=
            'Bearer pairing-$serial') {
          request.response.statusCode = 401;
        } else if (request.uri.path == '/v1/info') {
          request.response.write(jsonEncode({
            'version': 2,
            'platform': 'android',
            'instanceId': '$serial-${launched[serial]}',
            'state': finished[serial] == true ? 'closed' : 'accepting'
          }));
        } else if (request.uri.path == '/v1/events') {
          request.response.write('{"events":[]}');
        } else if (request.uri.path == '/v1/commands') {
          final body = jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
          commands[serial]!.add(body['api'] as String);
          request.response.statusCode = 202;
          request.response.write('{"status":"accepted"}');
        } else if (request.uri.path.startsWith('/v1/commands/')) {
          request.response
              .write('{"status":"done","success":true,"data":{"value":"ok"}}');
        } else if (request.uri.path == '/v1/finish') {
          finished[serial] = true;
          request.response.write('{}');
        } else {
          request.response.statusCode = 404;
        }
        await request.response.close();
      });
    }
    final host = FakeHost((exe, args) async {
      final serial = args.length > 1 && args[0] == '-s' ? args[1] : '';
      if (exe == 'emulator') return ok('Pixel_A\nPixel_B\n');
      if (exe == 'flutter' && args.first == 'devices')
        return ok('[{"id":"emulator-5554"},{"id":"emulator-5556"}]');
      if (exe == 'flutter' && args.first == '--version')
        return ok('{"frameworkVersion":"3.47.0"}');
      if (exe == 'flutter' && args.first == 'build') {
        final apk = File(p.join(repository.path, 'im_flutter_sdk', 'example',
            'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk'));
        await apk.parent.create(recursive: true);
        await apk.writeAsString('built-control-app');
        return ok();
      }
      if (p.basename(exe) == 'aapt')
        return ok(
            "package: name='example.app'\napplication-debuggable\nnative-code: 'arm64-v8a'\n");
      if (args.join(' ') == 'devices')
        return ok(
            'List of devices attached\nemulator-5554 device\nemulator-5556 device\n');
      if (args.contains('name'))
        return ok('${serial == 'emulator-5554' ? 'Pixel_A' : 'Pixel_B'}\nOK\n');
      if (args.contains('get-state')) return ok('device');
      if (args.contains('sys.boot_completed')) return ok('1');
      if (args.contains('ro.product.cpu.abilist')) return ok('arm64-v8a');
      if (args.contains('path')) return ok('package:/example/base.apk');
      if (args.contains('resolve-activity')) {
        expect(args, [
          '-s',
          serial,
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
          'example.app'
        ]);
        return ok('example.app/.LauncherActivity\n');
      }
      if (args.contains('log')) {
        processes[serial]!.out.add(utf8.encode(
            '${DateTime.now().microsecondsSinceEpoch / 1000000} 1 1 I testing_v2: ${args.last}\n'));
        return ok();
      }
      if (args.contains('start')) {
        expect(args, [
          '-s',
          serial,
          'shell',
          'am',
          'start',
          '-W',
          '-n',
          'example.app/.LauncherActivity',
          '-a',
          'android.intent.action.MAIN',
          '-c',
          'android.intent.category.LAUNCHER'
        ]);
        final pid = serial == 'emulator-5554' ? 111 : 222;
        launched[serial] = (launched[serial] ?? 0) + 1;
        finished[serial] = false;
        processes[serial]!.out.add(utf8.encode(
            '${DateTime.now().microsecondsSinceEpoch / 1000000} $pid $pid I flutter: [AGENT_CONTROL] {"port":${servers[serial]!.port},"token":"pairing-$serial"}\n'));
        return ok('Status: ok');
      }
      if (args.contains('pidof'))
        return ok(serial == 'emulator-5554' ? '111' : '222');
      if (args.contains('forward')) return ok('${servers[serial]!.port}');
      if (args.contains('install') || args.contains('force-stop')) return ok();
      throw StateError('Unexpected host command $exe $args');
    }, onStart: (_, args) {
      final serial = args[1];
      return processes[serial] = FakeProcess();
    });
    final devices = DeviceService(runner: host);
    final builds = BuildService(
        repository: repository,
        buildRoot: Directory(p.join(root.path, 'build')),
        runner: host);
    final launches =
        LaunchService(devices: devices, builds: builds, runner: host);
    final output = <String>[];
    final cli = TestingCli(
        root: root,
        devices: devices,
        builds: builds,
        launches: launches,
        output: output.add);
    try {
      final result = await cli.run(['all', '--cases', selection.path]);
      final runId =
          output.firstWhere((line) => line.startsWith('runId=')).substring(6);
      final snapshot = await RunStore(root).load(runId);
      expect(result, 0,
          reason: '${output.join('\n')}\n${snapshot.operations.map((entry) => {
                'stage': entry['stage'],
                'errors': (entry['result'] as Map?)?['errors']
              }).toList()}');
      expect(snapshot.attempts, hasLength(1));
      expect(
          ((snapshot.attempts.single['result'] as Map)['data']
              as Map)['verdict'],
          '是');
      expect(commands.values.every((list) => list.length == 1), isTrue);
      expect(finished.values.every((value) => value), isTrue);
      expect(processes.values.every((process) => process.killed), isTrue);
      final csv =
          await File(p.join(root.path, 'reports', runId, 'statistics.csv'))
              .readAsString();
      expect(csv, contains('two-agent-contract'));
      expect(csv, isNot(contains('account-a-secret')));
      expect(csv, isNot(contains('pairing-')));
      final initialCommandCount =
          commands.values.fold<int>(0, (sum, list) => sum + list.length);
      expect(await cli.run(['report', '--run-id', runId]), 0,
          reason: output.join('\n'));
      expect(commands.values.fold<int>(0, (sum, list) => sum + list.length),
          initialCommandCount);
      // Fixed account selection survives source edits; an unlogged account
      // still blocks dependent operations when its external outcome is unknown.
      final originalSelection = await selection.readAsString();
      await selection.writeAsString('{}');
      expect(await cli.run(['prepare', yaml.path, '--run-id', runId]), 0);
      final fixed = await RunStore(root).load(runId);
      expect((fixed.cases.single['accounts'] as Map)['account3'], 'c');
      fixed.issues.add({
        'status': 'open',
        'resources': ['account:c'],
        'message': 'Unknown outcome on unlogged recipient'
      });
      await fixed.save();
      final launchedBefore = launched.values.fold<int>(0, (sum, n) => sum + n);
      expect(await cli.run(['launch', yaml.path, '--run-id', runId]), 1);
      expect(output.lastWhere((s) => s.startsWith('error:')),
          contains('Shared resources'));
      expect(launched.values.fold<int>(0, (sum, n) => sum + n), launchedBefore);
      await selection.writeAsString(originalSelection);
      final external = File(p.join(root.path, 'external-build-result.json'));
      await external.writeAsString(jsonEncode(snapshot.builds.values.single));
      expect(
          await cli.run([
            'all',
            '--cases',
            selection.path,
            '--build-result',
            external.path
          ]),
          0,
          reason: output.join('\n'));
      final importedRunId =
          output.lastWhere((line) => line.startsWith('runId=')).substring(6);
      final importedRun = await RunStore(root).load(importedRunId);
      expect(importedRun.builds, hasLength(1));
      expect(
          importedRun.operations
              .where((operation) => operation['stage'] == 'build'),
          hasLength(1));
      expect(commands.values.fold<int>(0, (sum, list) => sum + list.length),
          initialCommandCount + 2);
    } finally {
      for (final process in processes.values) {
        if (!process.killed) process.kill();
      }
      for (final server in servers.values) {
        await server.close(force: true);
      }
      await repository.delete(recursive: true);
    }
  });
}
