import 'package:flow_runner/ast.dart';
import 'package:flow_runner/global_data.dart';
import 'package:flow_runner/interp.dart';
import 'package:flow_runner/parser.dart';
import 'package:flow_runner/report.dart';
import 'package:test/test.dart';

import 'mock_agent.dart';

GlobalData fixture() => GlobalData({
      'input': {'value': 42, 'nullable': null},
      'output': <String, Object?>{},
    }, outputRoots: [
      'global.output'
    ]);

FlowSpec flow(String steps, Map<String, Map<String, Object?>> commands) {
  final spec = parseFlow('''
name: generic
agents:
  a: {script: ''}
defaults: {stepTimeoutMs: 40}
steps:
$steps
''', options: const ParseOptions(verifyCommandIds: false));
  spec.scripts['a'] = DeviceScript(steps: commands);
  return spec;
}

void main() {
  test('missing and pending paths differ from an explicit null', () {
    final data = fixture();
    expect(data.read('global.input.nullable'), isNull);
    expect(() => data.read('global.input.typo'), throwsFormatException);
    data.claim('global.output.call');
    expect(() => data.read('global.output.call.data'), throwsFormatException);
    data.complete('global.output.call', {'data': null}, ok: true);
    expect(data.read('global.output.call.data'), isNull);
  });
  test('input snapshots, read results and snapshots cannot mutate storage', () {
    final source = <String, Object?>{
      'input': {'value': 42},
      'output': {}
    };
    final data = GlobalData(source, outputRoots: ['global.output']);
    (source['input'] as Map)['value'] = 0;
    (data.read('global.input') as Map)['value'] = 1;
    (data.snapshot()['input'] as Map)['value'] = 2;
    expect(data.read('global.input.value'), 42);
    expect(() => data.claim('global.input.newField'), throwsFormatException);
    expect(() => data.claim('global.input.value'), throwsFormatException);
  });
  test('outputs cannot be preloaded from a previous run', () {
    expect(
        () => GlobalData({
              'output': {'old': 1}
            }, outputRoots: [
              'global.output'
            ]),
        throwsFormatException);
  });
  test('reading a future producer is an explicit not-produced error', () async {
    final spec = flow('''
  - {cmd: read, agent: a}
  - {cmd: produce, agent: a, as: global.output.future}
''', {
      'read': {
        'api': 'must-not-run',
        'params': {'v': r'$global.output.future.data'}
      },
      'produce': {'api': 'produce', 'params': {}},
    });
    final agent = MockAgent()..onOk('produce', 2);
    final report = ReportCollector();
    await Interpreter(
            spec: spec, agents: {'a': agent}, report: report, global: fixture())
        .run();
    expect(agent.calls, ['produce']);
    expect(report.records.first.reason, contains('has not been produced'));
  });
  test('a duplicate binding fails before a second command is sent', () async {
    final agent = MockAgent()..onOk('do', {'value': 1});
    final report = ReportCollector();
    final data = fixture();
    final spec = flow('''
  - {cmd: work, agent: a, as: global.output.call}
  - {cmd: work, agent: a, as: global.output.call}
''', {
      'work': {'api': 'do', 'params': {}}
    });
    await Interpreter(
            spec: spec, agents: {'a': agent}, report: report, global: data)
        .run();
    expect(agent.calls, ['do']);
    expect(report.summary()['failed'], 1);
    expect(data.read('global.output.call.data.value'), 1);
  });
  test('bad parameter or assertion references never reach the device',
      () async {
    for (final badExpectation in [false, true]) {
      final agent = MockAgent()..onOk('do', 1);
      final report = ReportCollector();
      final spec = flow('  - {cmd: work, agent: a, as: global.output.call}', {
        'work': {
          'api': 'do',
          'params': badExpectation ? {} : {'value': r'$global.input.missing'},
          if (badExpectation)
            'expect': {
              'checks': [
                {'path': '', 'equals': r'$global.input.missing'}
              ]
            }
        },
      });
      final data = fixture();
      await Interpreter(
              spec: spec, agents: {'a': agent}, report: report, global: data)
          .run();
      expect(agent.calls, isEmpty);
      expect(data.read('global.output.call.failureKind'), 'tool');
      expect(data.read('global.output.call.data'), isNull);
      expect(report.records.single.result!['failureKind'], 'tool');
    }
  });
  test('failure blocks dependent commands but independent cleanup still runs',
      () async {
    final agent = MockAgent()
      ..onFail('fail', 'expected problem')
      ..onOk('cleanup', null);
    final report = ReportCollector();
    final spec = flow('''
  - {cmd: fail, agent: a, as: global.output.failed}
  - {cmd: dependent, agent: a, as: global.output.dependent}
  - {cmd: cleanup, agent: a, as: global.output.cleanup}
''', {
      'fail': {'api': 'fail', 'params': {}},
      'dependent': {
        'api': 'must-not-run',
        'params': {'value': r'$global.output.failed.data'}
      },
      'cleanup': {'api': 'cleanup', 'params': {}},
    });
    final data = fixture();
    await Interpreter(
            spec: spec, agents: {'a': agent}, report: report, global: data)
        .run();
    expect(agent.calls, ['fail', 'cleanup']);
    expect(report.summary(),
        {'passed': 1, 'failed': 1, 'timeout': 0, 'skipped': 1});
    expect(data.read('global.output.failed.error.code'), 500);
    expect(data.failed('global.output.dependent.data'), isTrue);
  });
  test('reserved root cannot be assigned by as, set or loop', () {
    for (final step in [
      '  - {cmd: x, agent: a, as: global}',
      '  - set: {global: 1}',
      '  - set: {global.input: 1}',
      '  - for: global in 1..2\n    do: []',
    ]) {
      expect(() => flow(step, {}), throwsA(isA<FlowParseError>()));
    }
  });
  test('concurrent duplicate writers cannot dispatch twice', () async {
    final agent = MockAgent()
      ..onOk('do', 1, delay: const Duration(milliseconds: 5));
    final spec = flow('''
  - parallel:
      one: [{cmd: work, agent: a, as: global.output.call}]
      two: [{cmd: work, agent: a, as: global.output.call}]
''', {
      'work': {'api': 'do', 'params': {}}
    });
    final report = ReportCollector();
    await Interpreter(
            spec: spec, agents: {'a': agent}, report: report, global: fixture())
        .run();
    expect(agent.calls, ['do']);
    expect(report.summary()['failed'], 1);
  });
  test('output from a previous run is absent from a fresh context', () {
    final first = fixture()..claim('global.output.call');
    first.complete('global.output.call', 1, ok: true);
    expect(() => fixture().read('global.output.call'), throwsFormatException);
  });
}
