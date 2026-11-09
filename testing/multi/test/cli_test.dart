import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/cli.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/devices.dart';
import 'package:testing_v2/src/data.dart';
import 'package:testing_v2/src/state.dart';

class FakeDevices extends DeviceService {
  var calls = 0;
  bool fail = false;
  @override
  Future<OperationResult<List<DeviceResult>>> list(
      OperationContext context, DevicePlatform platform) async {
    calls++;
    return OperationResult(
        runId: context.runId,
        operationId: context.operationId,
        status: fail ? OperationStatus.failure : OperationStatus.success,
        data: fail
            ? null
            : [
                DeviceResult(
                    platform: platform,
                    instance: 'sim',
                    deviceId: null,
                    observedState: 'Shutdown',
                    checkedAt: DateTime.now(),
                    ready: false)
              ],
        errors: fail ? [OperationError(message: 'host unavailable')] : [],
        evidence: []);
  }
}

class FakeAccounts extends DataService {
  @override
  Future<OperationResult<AccountData>> load(
          {required OperationContext context,
          required String sourcePath}) async =>
      OperationResult(
          runId: context.runId,
          operationId: context.operationId,
          status: OperationStatus.success,
          data: AccountData(environment: {
            'appKey': 'org#app',
            'accounts': [
              {'id': 'a', 'token': 'a-secret'},
              {'id': 'b', 'token': 'b-secret'}
            ],
            'groups': [],
            'rooms': []
          }),
          errors: [],
          evidence: []);
}

void main() {
  late Directory root;
  late FakeDevices devices;
  late List<String> output;
  late TestingCli cli;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('testing-v2-cli-');
    devices = FakeDevices();
    output = [];
    cli = TestingCli(root: root, devices: devices, output: output.add);
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  test(
      'all help pages work without generated accounts and have no side effects',
      () async {
    for (final operation in [
      '',
      'prepare',
      'devices',
      'build',
      'launch',
      'run',
      'report',
      'clean',
      'all'
    ]) {
      expect(await cli.run([if (operation.isNotEmpty) operation, '--help']), 0);
    }
    expect(devices.calls, 0);
    expect(await root.list().toList(), isEmpty);
    expect(output.join('\n'), contains('Exit 0'));
  });

  test(
      'irrelevant flags and ambiguous run selection rejected before operations',
      () async {
    expect(
        await cli
            .run(['devices', 'list', '--platform', 'ios', '--launch', 'old']),
        1);
    expect(
        await cli
            .run(['prepare', 'case.yaml', '--cases', 'x', '--run-id', 'y']),
        1);
    expect(await cli.run(['run', 'case.yaml']), 1);
    expect(devices.calls, 0);
    expect(await root.list().toList(), isEmpty);
  });

  test('account-independent device list persists real upstream output',
      () async {
    expect(await cli.run(['devices', 'list', '--platform', 'ios']), 0);
    expect(devices.calls, 1);
    final id =
        output.firstWhere((line) => line.startsWith('runId=')).substring(6);
    final run = await RunStore(root).load(id);
    expect(run.json['environment'], isNull);
    expect(run.json['status'], 'stopped');
    expect(run.operations.single['state'], 'completed');
    expect(DeviceResult.fromJson(run.devices['ios:sim']).ready, isFalse);
    expect(await File(p.join(run.directory.path, 'devices.json')).exists(),
        isTrue);
  });

  test(
      'failed device result does not become success or disappear on persistence',
      () async {
    devices.fail = true;
    expect(await cli.run(['devices', 'list', '--platform', 'ios']), 1);
    final id =
        output.firstWhere((line) => line.startsWith('runId=')).substring(6);
    final run = await RunStore(root).load(id);
    expect(run.operations.single['state'], 'completed');
    expect((run.operations.single['result'] as Map)['status'], 'failure');
    expect(run.devices, isEmpty);
  });

  test('failure of later selected case does not publish partial run input',
      () async {
    final source = p.join(root.path, 'data', '5.0.0-multi-a-positive.yaml');
    await File(source).parent.create(recursive: true);
    await File(source).writeAsString('''name: case-a
flowTimeoutMs: 1000
agents:
  alice: {script: 5.0.0-multi-a-positive.json}
  bob: {script: 5.0.0-multi-a-positive.json}
steps:
  - cmd: ping
    agent: alice
    as: global.biz.result.ping
''');
    await File(p.setExtension(source, '.json')).writeAsString(jsonEncode({
      'requiredBindings': ['global.biz.result.ping'],
      'steps': [
        {'id': 'ping', 'api': 'ping', 'params': <String, Object?>{}}
      ],
    }));
    final selection = File(p.join(root.path, 'cases.json'));
    await selection.writeAsString(jsonEncode({
      'cases': [
        {
          'yaml': source,
          'accounts': {'account1': 'a', 'account2': 'b'},
          'devices': {
            'alice': {'platform': 'ios', 'instance': 'sim-a'},
            'bob': {'platform': 'ios', 'instance': 'sim-b'}
          }
        },
        {
          'yaml': p.join(root.path, 'missing.yaml'),
          'accounts': <String, Object?>{},
          'devices': <String, Object?>{}
        },
      ]
    }));
    cli = TestingCli(
        root: root, data: FakeAccounts(), devices: devices, output: output.add);
    expect(await cli.run(['all', '--cases', selection.path]), 1);
    final id =
        output.firstWhere((line) => line.startsWith('runId=')).substring(6);
    final run = await RunStore(root).load(id);
    expect(run.cases, isEmpty);
    expect(run.json['environment'], isNull);
    expect(devices.calls, 0);
  });

  test('all cleanup removes empty snapshot without recreating deleted logs',
      () async {
    await Process.run('git', ['init', '--quiet'], workingDirectory: root.path);
    await File(p.join(root.path, '.gitignore'))
        .writeAsString('/tmp/\n/build/\n/reports/\n');
    expect(await cli.run(['devices', 'list', '--platform', 'ios']), 0);
    final id =
        output.firstWhere((line) => line.startsWith('runId=')).substring(6);
    expect(await cli.run(['clean', '--run-id', id, '--type', 'all']), 0,
        reason: output.join('\n'));
    expect(
        await File(p.join(root.path, 'tmp', id, 'run.json')).exists(), isFalse);
    expect(
        await File(p.join(root.path, 'tmp', id, 'run.log')).exists(), isFalse);
  });
}
