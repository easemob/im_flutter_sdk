import 'dart:io';

import 'package:flow_runner/parser.dart';
import 'package:test/test.dart';

import '../tools/data/roles.dart';
import '../tools/runner/context.dart';

void main() {
  final environment = <String, dynamic>{
    'appKey': 'example',
    'accounts': [
      {'id': 'a', 'token': 'ta'},
      {'id': 'b', 'token': 'tb'}
    ],
  };
  test('device ordering cannot change account mapping', () {
    final data = buildRoleData(environment, [
      'alice',
      'bob'
    ], {
      'accounts': {'alice': 0, 'bob': 1}
    });
    final devices = [
      {'role': 'bob', 'udid': 'device-2'},
      {'role': 'alice', 'udid': 'device-1'}
    ];
    final joined = joinAgents(devices, data, ['alice', 'bob']);
    expect(joined[0]['udid'], 'device-1');
    expect((joined[0]['env'] as Map)['userId'], 'a');
    expect(devices.every((d) => !d.containsKey('env')), isTrue);
  });
  test('missing, duplicate and undeclared roles cannot silently bind', () {
    final data = buildRoleData(environment, ['alice', 'bob'], {});
    for (final devices in [
      [
        {'role': 'alice'}
      ],
      [
        {'role': 'alice'},
        {'role': 'alice'}
      ],
      [
        {'role': 'alice'},
        {'role': 'unknown'}
      ],
    ]) {
      expect(() => joinAgents(devices, data, ['alice', 'bob']),
          throwsFormatException);
    }
  });
  test('global contract checks static inputs before any command dispatch', () {
    final path = 'testing/flows/5.0.0-multi-presence-positive.yaml';
    final spec = parseFlow(File(path).readAsStringSync(), sourcePath: path);
    final initial = globalDataFromRoles(buildRoleData(environment, [
      'alice',
      'bob'
    ], {
      'unique': {'presenceDescription': 'test-'},
    }));
    validateGlobalContract(spec, initial);
    ((initial['biz'] as Map)['input'] as Map).remove('presenceDescription');
    expect(() => validateGlobalContract(spec, initial), throwsFormatException);
  });
}
