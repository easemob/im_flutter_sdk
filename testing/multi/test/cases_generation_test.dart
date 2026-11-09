import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:testing_v2/src/contracts.dart';
import 'package:testing_v2/src/core.dart';
import 'package:testing_v2/src/data.dart';
import 'package:testing_v2/src/devices.dart';
import 'package:testing_v2/src/execution.dart';

import '../scripts/generate_cases.dart';
import 'device_fakes.dart';

void main() {
  late Directory root;
  late File selectionFile;
  late FakeHost host;
  late List<String> messages;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cases-generation-');
    await Directory(p.join(root.path, 'data')).create();
    await Directory(p.join(root.path, 'config')).create();
    await File(p.join(root.path, 'config', 'accounts-input.json'))
        .writeAsString(jsonEncode({
      'clientSecret': 'must-not-be-copied',
      'accounts': [
        {'id': 'user0'},
        {'id': 'user1'},
        {'id': 'user2'},
      ],
    }));
    selectionFile = File(p.join(root.path, 'config', 'cases.json'));
    messages = [];
    host = FakeHost((exe, args) {
      if (exe == 'emulator' && args.join(' ') == '-list-avds') {
        return ok('Device_C\nDevice_A\nDevice_B\n');
      }
      if (exe == 'adb' && args.join(' ') == 'devices') {
        return ok('List of devices attached\n');
      }
      if (exe == 'xcrun' &&
          args.join(' ') == 'simctl list devices available --json') {
        return ok(jsonEncode({
          'devices': {
            'runtime': [
              {'udid': 'UDID_B', 'state': 'Shutdown'},
              {'udid': 'UDID_A', 'state': 'Booted'},
              {'udid': 'UDID_C', 'state': 'Shutdown'},
            ]
          }
        }));
      }
      throw StateError('Unexpected command: $exe $args');
    });
  });
  tearDown(() async => root.delete(recursive: true));

  Future<String> fixture(String scene,
      {List<String> roles = const ['first', 'second'],
      String? disabledReason,
      bool absoluteScripts = false}) async {
    final name = '5.0.0-multi-$scene-positive';
    final jsonPath = p.join(root.path, 'data', '$name.json');
    final agentRoles = roles;
    await File(p.join(root.path, 'data', '$name.yaml'))
        .writeAsString(jsonEncode({
      'name': name,
      'agents': {
        for (final role in agentRoles)
          role: {'script': absoluteScripts ? jsonPath : '$name.json'},
      },
      'steps': [
        {
          'cmd': 'check',
          'agent': agentRoles.first,
          'as': 'global.biz.result.checked',
        }
      ],
    }));
    await File(jsonPath).writeAsString(jsonEncode({
      if (disabledReason != null)
        'selection': {'disabledReason': disabledReason},
      'steps': [
        {
          'id': 'check',
          'api': 'ChatClient.isConnected',
          'params': <String, Object?>{}
        },
      ],
      'requiredBindings': ['global.biz.result.checked'],
    }));
    return name;
  }

  Future<JsonObject> generate({
    DevicePlatform platform = DevicePlatform.android,
    List<String> cases = const [],
    List<String> accounts = const [],
    List<String> instances = const [],
  }) =>
      generateCases(
          root: root,
          platform: platform,
          caseNames: cases,
          accountIds: accounts,
          instances: instances,
          devices: DeviceService(runner: host),
          output: messages.add);

  List<JsonObject> rows(JsonObject result) =>
      (result['cases'] as List).map(readObject).toList();

  Future<List<CaseData>> accept(JsonObject result) async {
    final validation = await root.createTemp('accept-');
    final data = DataService();
    final cases = <CaseData>[];
    for (final row in rows(result)) {
      final path =
          p.normalize(p.join(selectionFile.parent.path, row['yaml'] as String));
      final loaded = await CaseLoader(data).freeze(path, validation);
      final delivered = data.createCaseData(
          context: OperationContext(
              runId: 'run-validation',
              operationId: 'data-validation',
              tmpDirectory: root,
              redactor: SecretRedactor()),
          environment: {
            'appKey': 'org#app',
            'accounts': [
              for (var i = 0; i < 3; i++) {'id': 'user$i', 'token': 'token-$i'},
            ],
            'groups': [],
            'rooms': [],
          },
          caseName: loaded.flow.name,
          caseBasename: p.basenameWithoutExtension(path),
          attempt: 1,
          accounts: readAccountSelection(row['accounts']),
          metadata: loaded.metadata);
      expect(delivered.isSuccess, isTrue, reason: '${delivered.errors}');
      cases.add(delivered.data!);
    }
    return cases;
  }

  test('three accounts and devices have independent mappings in selected order',
      () async {
    final name = await fixture('three', roles: ['first', 'second', 'third']);
    final result = await generate();
    expect(rows(result).single, {
      'yaml': '../data/$name.yaml',
      'accounts': {
        'account1': 'user0',
        'account2': 'user1',
        'account3': 'user2'
      },
      'devices': {
        'first': {'platform': 'android', 'instance': 'Device_A'},
        'second': {'platform': 'android', 'instance': 'Device_B'},
        'third': {'platform': 'android', 'instance': 'Device_C'},
      },
    });
    expect(jsonDecode(await selectionFile.readAsString()), result);
    expect(jsonEncode(result), isNot(contains('must-not-be-copied')));
    expect((await accept(result)).single.accounts, hasLength(3));
    expect(host.calls, [
      ['emulator', '-list-avds'],
      ['adb', 'devices'],
    ]);
  });

  test('explicit case, account and device orders are preserved on iOS',
      () async {
    final a = await fixture('alpha'), z = await fixture('zulu');
    final result = await generate(
        platform: DevicePlatform.ios,
        cases: [z, a],
        accounts: ['user2', 'user0'],
        instances: ['UDID_C', 'UDID_A']);
    expect(rows(result).map((r) => r['yaml']),
        ['../data/$z.yaml', '../data/$a.yaml']);
    expect(readObject(rows(result).first['devices'])['first'], {
      'platform': 'ios',
      'instance': 'UDID_C',
    });
    await accept(result);
    expect(rows(await generate(cases: [a])), hasLength(1));
  });

  test('all accounts remain available without copying or rewriting cases',
      () async {
    final name = await fixture('sync', absoluteScripts: true);
    final source = File(p.join(root.path, 'data', '$name.json'));
    final before = await source.readAsString();
    final result = await generate();
    final resolved = (await accept(result)).single;
    expect(resolved.accounts['account1']!['userId'], 'user0');
    expect(resolved.accounts['account2']!['userId'], 'user1');
    expect(resolved.accounts, hasLength(3));
    expect(readObject(rows(result).single['devices']), hasLength(2));
    expect(await source.readAsString(), before);
    expect(rows(result).single['yaml'], '../data/$name.yaml');
    expect(await Directory(p.join(root.path, 'config', 'case-data')).exists(),
        isFalse);
    expect(await generate(), result);
    final changed = await generate(accounts: ['user2', 'user0']);
    expect((await accept(changed)).single.accounts['account1']!['userId'],
        'user2');
    expect(
        (await accept(result)).single.accounts['account1']!['userId'], 'user0');
  });

  test('one account can serve three device roles', () async {
    await fixture('three', roles: ['one', 'two', 'three']);
    final result = await generate(accounts: ['user0']);
    expect(readObject(rows(result).single['devices']), hasLength(3));
    expect((await accept(result)).single.accounts.keys, ['account1']);
  });

  test('default discovery skips paused cases; explicit request fails',
      () async {
    final live = await fixture('enabled');
    final paused =
        await fixture('paused', disabledReason: 'Service unavailable');
    final result = await generate();
    expect(rows(result).single['yaml'], '../data/$live.yaml');
    expect(messages, contains('Skipped $paused: Service unavailable'));
    await expectLater(generate(cases: [paused]), throwsFormatException);
    expect(jsonDecode(await selectionFile.readAsString()), result);
  });

  test(
      'duplicate or missing resources are rejected without replacing selection',
      () async {
    final name = await fixture('ordinary');
    final original = await generate();
    for (final call in <Future<JsonObject> Function()>[
      () => generate(cases: ['missing']),
      () => generate(cases: [name, name]),
      () => generate(accounts: ['unknown']),
      () => generate(accounts: ['user0', 'user0']),
      () => generate(instances: ['unknown']),
      () => generate(instances: ['Device_A', 'Device_A']),
      () => generate(instances: ['Device_A']),
    ]) {
      await expectLater(call(), throwsFormatException);
      expect(jsonDecode(await selectionFile.readAsString()), original);
    }
  });

  test('empty account pool and duplicate account IDs are invalid', () async {
    await fixture('ordinary');
    for (final accounts in <List<JsonObject>>[
      [],
      [
        {'id': 'same'},
        {'id': 'same'}
      ]
    ]) {
      await File(p.join(root.path, 'config', 'accounts-input.json'))
          .writeAsString(jsonEncode({'accounts': accounts}));
      await expectLater(generate(), throwsFormatException);
    }
    expect(await selectionFile.exists(), isFalse);
  });

  test('obsolete account declarations are rejected', () async {
    final name = await fixture('invalid');
    final file = File(p.join(root.path, 'data', '$name.json'));
    final metadata = readObject(jsonDecode(await file.readAsString()));
    for (final selection in [
      {
        'accounts': {'first': 0}
      },
      {
        'accountInputs': {'recipientId': 1}
      }
    ]) {
      await file
          .writeAsString(jsonEncode({...metadata, 'selection': selection}));
      await expectLater(generate(), throwsFormatException);
    }
    expect(await selectionFile.exists(), isFalse);
  });

  test('static validation failure preserves previous selection', () async {
    final name = await fixture('ordinary');
    final previous = await generate();
    final json = File(p.join(root.path, 'data', '$name.json'));
    final metadata = readObject(jsonDecode(await json.readAsString()));
    metadata['requiredBindings'] = ['global.biz.result.missing'];
    await json.writeAsString(jsonEncode(metadata));
    await expectLater(generate(), throwsFormatException);
    expect(jsonDecode(await selectionFile.readAsString()), previous);
  });

  test('device discovery failure retains diagnostics and cannot publish',
      () async {
    await fixture('ordinary');
    host = FakeHost((_, __) => failed('Toolchain unavailable'));
    await expectLater(generate(), throwsStateError);
    expect(await selectionFile.exists(), isFalse);
    final logs = await Directory(p.join(root.path, 'tmp'))
        .list(recursive: true)
        .toList();
    expect(logs.whereType<File>(), isNotEmpty);
  });

  test(
      'real catalog generates eleven cases accepted by existing execution contracts',
      () async {
    for (final file in Directory('data').listSync().whereType<File>()) {
      if (['.yaml', '.json'].contains(p.extension(file.path))) {
        await file.copy(p.join(root.path, 'data', p.basename(file.path)));
      }
    }
    final result = await generate();
    expect(rows(result), hasLength(11));
    expect(jsonEncode(result), isNot(contains('message-recall')));
    final accepted = await accept(result);
    final sync =
        accepted.singleWhere((c) => c.caseName.contains('message-device-sync'));
    expect(sync.input.containsKey('recipientId'), isFalse);
    expect(sync.accounts['account2']!['userId'], 'user1');
  });
}
